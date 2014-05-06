require 'forwardable'
require 'shellwords'

module VagrantPlugins
  module Babushka
    # The main implementation class for the Babushka provisioner
    class Provisioner < Vagrant.plugin("2", :provisioner)

      # Exception raised if cURL isn't on the VM and can't be installed
      class CurlMissingError < Vagrant::Errors::VagrantError
        def error_message
          <<-END.gsub(/ {8}|\n\Z/, "")
            cURL couldn't be found on the VM, and this plugin doesn't
            know how to install it on the guest OS.

            Try installing it manually, or consider adding the
            functionality to the plugin and opening a pull request.
          END
        end
      end

      # Allow delegation of methods to an accessor
      extend Forwardable

      # Delegate some methods to @machine (to reduce boilerplate)
      delegate [:communicate, :env, :name] => :@machine
      delegate :ui => :env

      attr_accessor :username, :group

      # Called with the root configuration of the machine so the
      # provisioner can add some configuration on top of the machine.
      #
      # During this step, and this step only, the provisioner should
      # modify the root machine configuration to add any additional
      # features it may need. Examples include sharing folders,
      # networking, and so on. This step is guaranteed to be called
      # before any of those steps are done so the provisioner may do
      # that.
      def configure(root_config)
        @username = root_config.ssh.username || root_config.ssh.default.username
        share_local_deps(root_config) if config.local_deps_path
      end

      # This is the method called when the actual provisioning should
      # be done. The communicator is guaranteed to be ready at this
      # point, and any shared folders or networds are already set up.
      def provision
        detect_ssh_group
        render_messages
        prepare
        do_babushka_run
      end

      # Shares local deps with the virtual machine
      def share_local_deps(root_config)
        local_path = config.local_deps_path
        remote_path = "/home/#{escape username}/babushka-deps"
        opts = {:id => 'babushka_deps', :nfs => false}
        root_config.vm.synced_folder local_path, remote_path, opts
      end

      # Determines and saves the name of the SSH user's primary group
      def detect_ssh_group
        @group = ""

        # Save stdout into @group
        communicate.execute("id -gn #{escape username}") do |type, data|
          @group += data if type == :stdout
        end

        # Remove trailing newline from command output
        @group.gsub! /\n\Z/, ""
      end

      # Renders the messages to the log output
      #
      # The config object maintains a list of "messages" to be shown
      # when provisioning occurs, since there's no way to show messages
      # at the time of configuration actually occurring. This displays
      # the messages that were saved.
      def render_messages
        config.messages.each do |(level, info, caller)|
          info = "vagrant-babushka: #{info}"
          info += "\nIn #{caller.first}" unless caller.nil?
          ui.send level.to_sym, info.to_s, :scope => name
        end
      end

      # Performs preparation necessary before Babushka can be invoked
      #
      # Installs Babushka if it's not available. If Babushka needs to
      # be installed, cURL will be installed first so that Babushka
      # can be downloaded over HTTPS (as wget may not support HTTPS).
      def prepare
        unless in_path? "babushka"
          # Install cURL first to ensure we can download over HTTPS
          install_curl! unless in_path? "curl"
          create_destination!
          install_babushka!
          patch_babushka_binary!
          ui.info "\n\n\n"
        end
      end

      # Invokes Babushka on the virtual machine to meet requested deps
      #
      # Since Babushka can only meet one dep at a time, if multiple
      # deps are in the meet list (the user has requested multiple
      # deps to be run) then we have to have multiple invokations,
      # once for each dep.
      def do_babushka_run
        if config.deps.empty?
          ui.warn <<-END.gsub(/ {12}|\n\Z/, ""), :scope => name
            Didn't find any Babushka deps to be met on the VM.
            Add some to your Vagrantfile: babushka.meet 'my dep'
          END
        else
          ui.info "Provisioning VM using Babushka...", :scope => name
          config.deps.each do |dep|
            ui.info "Meeting Babushka dep '#{dep.id}'", :scope => name
            ui.info "Executing '#{command_for(dep).strip}'...", :scope => name
            options = {:error_key => "vagrant_babushka_provision_error"}
            communicate.execute command_for(dep), options, &log_stdout
          end
        end
      end

      private
        # Determines if the virtual machine has a command in its $PATH
        #
        #   command: The name of the command to look for
        def in_path?(command)
          communicate.test("which #{escape command}").tap do |result|
            if result
              ui.info "'#{command}' found on guest", :scope => name
            end
          end
        end

        # Installs cURL on the virtual machine
        def install_curl!
          raise CurlMissingError.new unless in_path? "apt-get"
          ui.info "Installing cURL package on VM...", :scope => name
          communicate.sudo "apt-get --quiet --assume-yes install curl"
        end

        # Creates the Babushka installation directory on the VM
        #
        # This will create the directory (as root), then set up the
        # permissions on it to belong to the SSH user's primary group,
        # and give the group read and write privileges. The permissions
        # are also adjusted on /usr/local/bin, so Babushka can symlink
        # itself into the PATH.
        def create_destination!
          ui.info "Creating Babushka directory...", :scope => name
          communicate.sudo [
            # Create directory, and parent directories if also missing
            "mkdir -p /usr/local/babushka",

            # Change Babushka directory's group to user's primary group
            "chgrp #{escape group} /usr/local/babushka /usr/local/bin",

            # Add read/write privileges where Babushka needs them
            "chmod g+rw /usr/local/babushka /usr/local/bin",
          ].join(" && ")
        end

        # Installs Babushka on the virtual machine
        def install_babushka!
          ui.info <<-END.gsub(/ {12}|\n\Z/, ""), :scope => name
            Installing Babushka via bootstrap script at \
            #{config.bootstrap_url}...
          END

          unless config.bootstrap_url =~ %r[^https://]
            ui.warn "WARNING: Using non-SSL source", :scope => name
          end

          # Log stdout straight to Vagrant's output
          communicate.execute install_babushka_command, &log_stdout
        end

        # Installs the patched binary distributed with this plugin
        #
        # The patched binary ensures stdout and stderr are unbuffered,
        # so they will be flushed after every write. This avoids
        # progress bars and status messages from being hidden during
        # long-running processes.
        #
        # The patched binary is at dist/babushka.rb, relative to the
        # root of this project.
        def patch_babushka_binary!
          ui.info "Patching Babushka binary...", :scope => name
          root = File.expand_path '../..', File.dirname(__FILE__)
          source = File.join root, 'dist', 'babushka.rb'
          communicate.upload source, '/usr/local/bin/babushka'
        end

        # The command used to install Babushka on the virtual machine
        def install_babushka_command
          %Q[#{vars} sh -c "`#{vars} curl #{escape config.bootstrap_url}`"]
        end

        # Retrieves the environment variables to use for VM commands
        #
        # Extracts the HTTPS proxy from the host environment variables
        #
        # Returns a string that can be used as a prefix to a command in
        # order to assign the variables for that command.
        def vars
          proxy_env = ENV.select {|k, _| /https_proxy/i.match(k) }
          proxy_env.map{|k, v| "#{escape k}=#{escape v}" }.join(" ")
        end

        # A block that logs stdout, when passed to a communicator
        #
        #   type: The stream where the output in data came from, one of
        #         :stdout or :stderr
        #   data: The echoed data as a string
        def log_stdout
          lambda do |type, data|
            ui.info data, :new_line => false
          end
        end

        # Creates a command string to use for a dep on the command line
        #
        # This will return a string which can be used as a command to
        # run Babushka to meet a particular dep.
        #
        #   * dep: The Dep to generate the command string for
        def command_for(dep)
          [
            vars, dep.sudo, "babushka", "meet",
            args_for(dep),  # Babushka command-line arguments
            escape(dep.id), # Identifier for the dep to be met
            dep.params.map {|k, v| "#{escape k}=#{escape v}" },
          ].flatten.join(" ")
        end

        # Generates the Babushka command-line arguments for a dep
        #
        # Given a dep, this method merges the configuration options for
        # the specific dep with the configuration of the provisioner as
        # "defaults" if values aren't set on the dep itself.
        #
        #   * dep: The Dep to generate the command string for
        def args_for(dep)
          result = config.arguments.merge(dep.arguments)
          result[:color] = ui.is_a? Vagrant::UI::Colored if result[:color].nil?
          [
            '--defaults', # Must use defaults -- stdin not connected
            result[:color]     ? '--color'     : '--no-color',
            result[:debug]     ? '--debug'     : nil,
            result[:dry_run]   ? '--dry-run'   : nil,
            result[:show_args] ? '--show-args' : nil,
            result[:silent]    ? '--silent'    : nil,
            result[:update]    ? '--update'    : nil,
          ].compact.join(" ") # Remove nil values and concatenate
        end

        # Alias for Shellwords.escape
        def escape(string)
          Shellwords.escape(string.to_s)
        end
    end
  end
end
