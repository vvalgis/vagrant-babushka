module VagrantPlugins
  module Babushka
    # Main configuration object for Vagrant Babushka provisioner
    class Config < Vagrant.plugin("2", :config)
      # Configuration keys that are used as Babushka command-line args
      ARGUMENTS = [
        :color,
        :debug,
        :dry_run,
        :show_args,
        :silent,
        :update,
      ]

      attr_accessor :deps, :local_deps_path, :bootstrap_branch, :bootstrap_url
      attr_reader :messages

      # Command-line argument options
      attr_accessor *ARGUMENTS

      def initialize
        super
        @deps = []
        @local_deps_path = UNSET_VALUE
        @bootstrap_branch = UNSET_VALUE
        @bootstrap_url = UNSET_VALUE
        @messages = []

        # Reset all argument values to UNSET_VALUE
        ARGUMENTS.each {|a| self.send "#{a}=".to_sym, UNSET_VALUE }
      end

      # This is called as a last-minute hook that allows the
      # configuration object to finalize itself before it will be put
      # into use. This is a useful place to do some defaults in the
      # case the user didn't configure something or so on.
      def finalize!
        @deps = [] if @deps == UNSET_VALUE
        @local_deps_path  = nil if @local_deps_path  == UNSET_VALUE
        @bootstrap_branch = nil if @bootstrap_branch == UNSET_VALUE

        # Setup bootstrap URL if not set
        if @bootstrap_url == UNSET_VALUE
          @bootstrap_url = "https://babushka.me/up"
          @bootstrap_url += "/#{@bootstrap_branch}" if @bootstrap_branch
        end

        # Set defaults for command-line arguments
        @color = nil if @color == UNSET_VALUE
        @debug = false if @debug == UNSET_VALUE
        @dry_run = false if @dry_run == UNSET_VALUE
        @show_args = false if @show_args == UNSET_VALUE
        @silent = false if @silent == UNSET_VALUE
        @update = true if @update == UNSET_VALUE
      end

      # Retrieves a Hash of the command-line argument config values
      #
      # The returned Hash will have command-line argument names for
      # keys, and the value for the argument as the corresponding
      # value.
      def arguments
        ARGUMENTS.inject(Hash.new) {|hash, key| hash.merge({key => send(key)}) }
      end

      # Meets a local dep on the guest
      #
      # NOTE: This method is deprecated. Please use the new #meet
      # instead.
      #
      #   * dep_name: The name of the dep to meet
      #   * params:    Parameter options to pass to the dep (optional)
      def local_dep(dep_name, params = {})
        @messages << [:warn, "#local_dep is deprecated, use #meet", caller]
        @deps << Dep.new(dep_name, :params => params)
      end

      # Meets a remote dep on the guest
      #
      # NOTE: This method is deprecated. Please use the new #meet
      # instead.
      #
      #  * source:   The name of the dep's source (GitHub username)
      #  * dep_name: The name of the dep to meet
      #  * params:   Parameter options to pass to the dep (optional)
      def remote_dep(source, dep_name, params = {})
        @messages << [:warn, "#remote_dep is deprecated, use #meet", caller]
        @deps << Dep.new(dep_name, :source => source, :params => params)
      end

      # The main method to meet deps on the guest virtual machine
      #
      # This method adds a single dep to a list of deps to be met on
      # the virtual machine. This method replaces the older #local_dep
      # and #remote_dep, unifying the interface for both remote and
      # local deps.
      #
      #   * dep_name: The name of the dep (excluding source prefix)
      #   * options:  A Hash of options. Valid keys:
      #        * source: The name of the source containing the dep
      #                  (will be used as a source prefix if provided,
      #                  otherwise no source prefix will be used)
      #        * params: A Hash of parameters to pass to the dep
      #                  (mapping parameter names as keys to values)
      def meet(dep_name, options = {})
        @deps << Dep.new(dep_name, options)
      end
    end
  end
end
