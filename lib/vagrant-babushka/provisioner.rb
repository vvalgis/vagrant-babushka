module VagrantPlugins
  module Babushka
    class Provisioner < Vagrant.plugin("2", :provisioner)

      def initialize(machine, config)
        super
      end

      def configure(root_config)
      end

      def provision
      end

    end
  end
end