module VagrantPlugins
  module Babushka
    class Config < Vagrant.plugin("2", :config)
      attr_accessor :args, :deps

      def initialize
        @deps = UNSET_VALUE
      end

      def finalize!
        @deps = [] if @deps == UNSET_VALUE
      end

      def dep(dep_spec, args = {})
        deps << [dep_spec, args]
      end
    end
  end
end
