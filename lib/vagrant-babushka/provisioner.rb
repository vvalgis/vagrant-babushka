module VagrantPlugins
  module Babushka
    # The main implementation class for the Babushka provisioner
    class Provisioner < Vagrant.plugin("2", :provisioner)

      def initialize(machine, config)
        super
      end

      def configure(root_config)
        @username = root_config.ssh.username || root_config.ssh.default.username
        @hostname = root_config.vm.hostname
        if @config.local_deps_path
          local_path = @config.local_deps_path
          remote_path = "/home/#{@username}/babushka-deps"
          opts = {id: 'babushka_deps', nfs: false}
          root_config.vm.synced_folder local_path, remote_path, opts
        end
      end

      # This is the method called when the actual provisioning should
      # be done. The communicator is guaranteed to be ready at this
      # point, and any shared folders or networds are already set up.
      def provision
        render_messages!
        bootstrap_babushka! unless @machine.communicate.test('babushka --version')
        @config.deps.map do |dep|
          run_remote "babushka --update --defaults --color #{dep.command}"
        end
      end

      private
      # Renders the messages to the log output
      #
      # The config object maintains a list of "messages" to be shown
      # when provisioning occurs, since there's no way to show messages
      # at the time of configuration actually occurring. This displays
      # the messages that were saved.
      def render_messages!
        @config.messages.each do |(level, info, caller)|
          info = "vagrant-babushka: #{info}"
          info += "\nIn #{caller.first}" unless caller.nil?
          @machine.env.ui.send level.to_sym, info.to_s, :scope => @machine.name
        end
      end

      # Installs Babushka on the guest using the bootstrap script
      def bootstrap_babushka!
        require 'net/http'
        @machine.env.ui.info("Installing babushka on #{@hostname}.")
        local_tmpfile = remote_tmpfile = "/tmp/babushka_me_up"
        File.open(local_tmpfile, 'w') {|f| f.write `curl #{babushka_uri}` }
        @machine.communicate.upload(local_tmpfile, remote_tmpfile)
        run_remote "#{proxy_env} sh #{remote_tmpfile}"
      end

      # Extracts the HTTPS proxy from the host environment variables
      def proxy_env
        vars = ''
        vars_from_env = ENV.select { |k, _| /https_proxy/i.match(k) }
        vars = vars_from_env.to_a.map{ |pair| pair.join('=') }.join(' ') unless vars_from_env.empty?
        vars
      end

      # Retrieves the URL to use to bootstrap Babushka on the guest
      def babushka_uri
        uri = 'https://babushka.me/up'
        uri = "#{uri}/#{@config.bootstrap_branch}" unless @config.bootstrap_branch.nil?
        uri
      end

      # Executes a command on the guest and handles logging the output
      #
      #   * command: The command to execute (as a string)
      def run_remote(command)
        @machine.communicate.sudo(command) do |type, data|
          color = type == :stdout ? :green : :red
          @machine.env.ui.info(data.chomp, :color => color, :prefix => false)
        end
      end

    end
  end
end
