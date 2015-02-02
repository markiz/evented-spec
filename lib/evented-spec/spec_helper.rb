# You can include one of the following modules into your example groups:
# EventedSpec::SpecHelper,
# EventedSpec::AMQPSpec,
# EventedSpec::EMSpec.
#
# EventedSpec::SpecHelper module defines #ampq and #em methods that can be safely used inside
# your specs (examples) to test code running inside AMQP.start or EM.run loop
# respectively. Each example is running in a separate event loop,you can control
# for timeouts either with :spec_timeout option given to #amqp/#em method or setting
# a default timeout using default_timeout(timeout) macro inside describe/context block.
#
# If you include EventedSpec::Spec module into your example group, each example of this group
# will run inside AMQP.start loop without the need to explicitly call 'amqp'. In order to
# provide options to AMQP loop, default_options({opts}) macro is defined.
#
# Including EventedSpec::EMSpec module into your example group, each example of this group will
# run inside EM.run loop without the need to explicitly call 'em'.
#
# In order to stop AMQP/EM loop, you should call 'done' AFTER you are sure that your
# example is finished and your expectations executed. For example if you are using
# subscribe block that tests expectations on messages, 'done' should be probably called
# at the end of this block.
#
module EventedSpec

  # EventedSpec::SpecHelper module defines #ampq and #em methods that can be safely used inside
  # your specs (examples) to test code running inside AMQP.start or EM.run loop
  # respectively. Each example is running in a separate event loop, you can control
  # for timeouts either with :spec_timeout option given to #amqp/#em/#coolio method or setting
  # a default timeout using default_timeout(timeout) macro inside describe/context block.
  module SpecHelper
    # Error which shows in RSpec log when example does not call #done inside
    # of event loop.
    SpecTimeoutExceededError = Class.new(RuntimeError)

    # Class methods (macros) for any example groups that includes SpecHelper.
    # You can use these methods as macros inside describe/context block.
    module GroupMethods
      # Returns evented-spec related metadata for particular example group.
      # Metadata is cloned from parent to children, so that children inherit
      # all the options and hooks set in parent example groups
      #
      # @return [Hash] hash with example group metadata
      def evented_spec_metadata
        if @evented_spec_metadata
          @evented_spec_metadata
        else
          @evented_spec_metadata = superclass.evented_spec_metadata rescue {}
          @evented_spec_metadata = EventedSpec::Util.deep_clone(@evented_spec_metadata)
        end
      end # evented_spec_metadata

      # Sets/retrieves default timeout for running evented specs for this
      # example group and its nested groups.
      #
      # @param [Float] desired timeout for the example group
      # @return [Float]
      def default_timeout(spec_timeout = nil)
        if spec_timeout
          default_options[:spec_timeout] = spec_timeout
        else
          default_options[:spec_timeout] || self.superclass.default_timeout
        end
      end

      # Sets/retrieves default AMQP.start options for this example group
      # and its nested groups.
      #
      # @param [Hash] context-specific options for helper methods like #amqp, #em, #coolio
      # @return [Hash]
      def default_options(opts = nil)
        evented_spec_metadata[:default_options] ||= {}
        if opts
          evented_spec_metadata[:default_options].merge!(opts)
        else
          evented_spec_metadata[:default_options]
        end
      end

      # Collection of evented hooks for current example group
      #
      # @return [Hash] hash with hooks
      def evented_spec_hooks
        evented_spec_metadata[:es_hooks] ||= Hash.new
      end

      # Collection of evented hooks of predefined type for current example group
      #
      # @param [Symbol] hook type
      # @return [Array] hooks
      def evented_spec_hooks_for(type)
        evented_spec_hooks[type] ||= []
      end # evented_spec_hooks_for
    end

    def self.included(example_group)
      unless example_group.respond_to? :default_timeout
        example_group.extend GroupMethods
      end
    end

    # Retrieves default options passed in from enclosing example groups
    #
    # @return [Hash] default option for currently running example
    def default_options
      @default_options ||= (self.class.default_options.dup rescue {})
    end

    # Executes an operation after certain delay
    #
    # @param [Float] time to wait before operation
    def delayed(time, &block)
      @evented_example.delayed(time) do
        @example_group_instance.instance_eval(&block)
      end
    end # delayed

    # Breaks the event loop and finishes the spec. This should be called after
    # you are reasonably sure that your expectations succeeded.
    # Done yields to any given block first, then stops EM event loop.
    # For amqp specs, stops AMQP and cleans up AMQP state.
    #
    # You may pass delay (in seconds) to done. If you do so, please keep in mind
    # that your (default or explicit) spec timeout may fire before your delayed done
    # callback is due, leading to SpecTimeoutExceededError
    #
    # @param [Float] Delay before event loop is stopped
    def done(*args, &block)
      @evented_example.done *args, &block if @evented_example
    end

    # Manually sets timeout for currently running example. If spec doesn't call
    # #done before timeout, it is marked as failed on timeout.
    #
    # @param [Float] Delay before event loop is stopped with error
    def timeout(*args)
      @evented_example.timeout *args if @evented_example
    end

  end # module SpecHelper
end # EventedSpec
