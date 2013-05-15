module VagrantPlugins
  module Babushka
    class Provisioner < Vagrant.plugin("2", :provisioner)

      def initialize(machine, config)
        super
      end

      def configure(root_config)
        @hostname = root_config.vm.hostname
      end

      def provision
        bootstrap_babushka! unless @machine.communicate.test('babushka --version')
 
        commands = @config.deps.map do |(dep_name, dep_args)|
          args = dep_args.to_a.map { |k, v| "#{k}='#{v}'" }.join(' ')
          "babushka --update --defaults --colour '#{dep_name}' #{args}"
        end
        commands.each do |command|
          @machine.communicate.sudo(command) do |type, data|
            color = type == :stdout ? :green : :red
            @machine.env.ui.info(data.chomp, :color => color, :prefix => false)
          end
        end
      end

      private

      def bootstrap_babushka!
        require 'net/http'
        @machine.env.ui.info("Installing babushka on #{@hostname}.")
        local_tmpfile = remote_tmpfile = "/tmp/babushka_me_up"
        File.open(local_tmpfile, 'w') {|f| f.write `curl https://babushka.me/up` }
        @machine.communicate.upload(local_tmpfile, remote_tmpfile)
        @machine.communicate.sudo("bash #{remote_tmpfile}") do |type, data|
          color = type == :stdout ? :green : :red
          @machine.env.ui.info(data.chomp, :color => color, :prefix => false)
        end
      end

    end
  end
end