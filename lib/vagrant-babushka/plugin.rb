module VagrantPlugins
  module Babushka
    class Plugin < Vagrant.plugin("2")
      name "Babushka"
      description <<-END
        Provides support for provisioning your virtual machines using
        Babushka.
      END

      config :babushka, :provisioner do
        require_relative "config"
        Config
      end

      provisioner :babushka do
        require_relative "provisioner"
        Provisioner
      end
    end
  end
end
