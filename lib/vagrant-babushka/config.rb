module VagrantPlugins
  module Babushka
    class Config < Vagrant.plugin("2", :config)
      attr_accessor :args, :deps, :local_deps_path

      def initialize
        super
        @deps = []
        @local_deps_path = UNSET_VALUE
      end

      def finalize!
        @deps = [] if @deps == UNSET_VALUE
        @local_deps_path  = nil if @local_deps_path  == UNSET_VALUE
      end

      def local_dep(dep_name, args = {})
        @deps << ['', dep_name, args]
      end

      def remote_dep(source, dep_name, args = {})
        @deps << ["#{source}:", dep_name, args]
      end
    end
  end
end
