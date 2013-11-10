begin
  require "vagrant"
rescue LoadError
  raise "vagrant-babushka must be loaded from within Vagrant."
end

module VagrantPlugins
  module Babushka
    # Main configuration object for Vagrant Babushka provisioner
    class Config < Vagrant.plugin("2", :config)
      attr_accessor :args, :deps, :local_deps_path, :bootstrap_branch

      def initialize
        super
        @deps = []
        @local_deps_path = UNSET_VALUE
        @bootstrap_branch = UNSET_VALUE
      end

      # This is called as a last-minute hook that allows the
      # configuration object to finalize itself before it will be put
      # into use. This is a useful place to do some defaults in the
      # case the user didn't configure something or so on.
      def finalize!
        @deps = [] if @deps == UNSET_VALUE
        @local_deps_path  = nil if @local_deps_path  == UNSET_VALUE
        @bootstrap_branch = nil if @bootstrap_branch == UNSET_VALUE
      end

      # Meets a local dep on the guest
      #
      #   * dep_name: The name of the dep to meet
      #   * params:    Parameter options to pass to the dep (optional)
      def local_dep(dep_name, params = {})
        @deps << Dep.new(dep_name, :params => params)
      end

      # Meets a remote dep on the guest
      #
      #  * source:   The name of the dep's source (GitHub username)
      #  * dep_name: The name of the dep to meet
      #  * params:   Parameter options to pass to the dep (optional)
      def remote_dep(source, dep_name, params = {})
        @deps << Dep.new(dep_name, :source => source, :params => params)
      end
    end
  end
end
