module VagrantPlugins
  module Babushka
    # A class representing a Babushka dep that should be met
    #
    # This represents the dep after parameters are bound (if there are
    # any). So it's not so much a "dep", but more in line with the
    # "DepRequirement" class from Babushka itself.
    class Dep
      attr_reader :dep_name

      # Initialezes a dep from a name and options
      #
      #   * dep_name: The name of the dep (excluding source prefix)
      #   * options:  A Hash of options. Valid keys:
      #        * source: The name of the source containing the dep
      #                  (will be used as a source prefix if provided,
      #                  otherwise no source prefix will be used)
      #        * params: A Hash of parameters to pass to the dep
      #                  (mapping parameter names as keys to values)
      def initialize(dep_name, options = {})
        @dep_name = dep_name.to_s
        @options = options
      end

      # Retrieves the full name of this dep (including source prefix)
      #
      # This will be in the format "source:dep_name" if a source was
      # specified, otherwise it will be the bare dep name (in which
      # case Babushka would look for it in the default sources).
      def id
        if source
          "#{source}:#{dep_name}"
        else
          dep_name
        end
      end

      # Determines the source that this dep belongs to
      #
      # If the source can't be determined (a source wasn't specified),
      # nil is returned.
      def source
        @options[:source] ? @options[:source].to_s : nil
      end

      # Set sudo prefix for babushka command
      #
      # If the run_with_sudo is set to true return 'sudo' prefix, if not
      # empty string is returned.
      def sudo
        @options[:run_with_sudo] ? 'sudo' : ''
      end

      # Retrieves the parameters for the dep
      #
      # Parameters are values for variables that the dep accepts. This
      # method returns a Hash mapping parameter names as keys to their
      # values.
      def params
        @options[:params] || Hash.new
      end

      # Retrieves the command-line arguments for the dep
      #
      # This returns a hash including all the Babushka command-line
      # arguments (to override the global settings) when meeting this
      # dep.
      def arguments
        @options.select {|key, value| Config::ARGUMENTS.include? key }
      end

      def ==(other)
        other.class == self.class && other.state == state
      end
      alias_method :eql?, :==

      protected
        # An array of state data used to compare and test for equality
        def state
          [@dep_name, @options[:params], @options[:source]]
        end
    end
  end
end
