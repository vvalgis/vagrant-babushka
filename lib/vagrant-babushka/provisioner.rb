module VagrantPlugins
  module Babushka
    class Provisioner < Vagrant.plugin("2", :provisioner)

      def initialize(machine, config)
        super
      end

      def configure(root_config)
        @username = @machine.ssh_info[:username]
        @username = root_config.ssh.default.username unless @username
        @hostname = root_config.vm.hostname
        if @config.local_deps_path
          local_path = @config.local_deps_path
          remote_path = "/home/#{@username}/babushka-deps"
          opts = {id: 'babushka_deps', nfs: false}
          root_config.vm.synced_folder local_path, remote_path, opts
        end
      end

      def provision
        bootstrap_babushka! unless @machine.communicate.test('babushka --version')
        @config.deps.map do |(dep_source, dep_name, dep_args)|
          args = dep_args.to_a.map { |k, v| "#{k}='#{v}'" }.join(' ')
          run_remote "babushka --update --defaults --colour #{dep_source}'#{dep_name}' #{args}"
        end
      end

      private

      def bootstrap_babushka!
        require 'net/http'
        @machine.env.ui.info("Installing babushka on #{@hostname}.")
        local_tmpfile = remote_tmpfile = "/tmp/babushka_me_up"
        File.open(local_tmpfile, 'w') {|f| f.write `curl #{babushka_uri}` }
        @machine.communicate.upload(local_tmpfile, remote_tmpfile)
        run_remote "#{proxy_env} sh #{remote_tmpfile}"
      end

      def proxy_env
        vars = ''
        vars_from_env = ENV.select { |k, _| /https_proxy/i.match(k) }
        vars = vars_from_env.to_a.map{ |pair| pair.join('=') }.join(' ') unless vars_from_env.empty?
        vars
      end

      def babushka_uri
        uri = 'https://babushka.me/up'
        uri = "#{uri}/#{@config.bootstrap_branch}" unless @config.bootstrap_branch.nil?
        uri
      end

      def run_remote(command)
        @machine.communicate.sudo(command) do |type, data|
          color = type == :stdout ? :green : :red
          @machine.env.ui.info(data.chomp, :color => color, :prefix => false)
        end
      end

    end
  end
end
