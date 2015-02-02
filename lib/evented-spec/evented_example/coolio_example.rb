require 'evented-spec/ext/coolio'
#
# Cool.io loop is a little bit trickier to test, since it
# doesn't go into a loop if there are no watchers.
#
# Basically, all we do is add a timeout watcher and run some callbacks
#
module EventedSpec
  module SpecHelper
    # Evented example which is run inside of cool.io loop.
    # See {EventedExample} details and method descriptions.
    class CoolioExample < EventedExample
      # see {EventedExample#run}
      def run
        require 'cool.io'
        require 'cool.io/dsl'
        reset
        delayed(0) do
          begin
            run_hooks :coolio_before
            @example_group_instance.instance_eval(&@block)
          rescue Exception => e
            @spec_exception ||= e
            done
          end
        end
        timeout(@opts[:spec_timeout]) if @opts[:spec_timeout]
        Coolio::DSL.run
      end

      # see {EventedExample#timeout}
      def timeout(time = 1)
        @spec_timer = delayed(time) do
          @spec_exception ||= SpecTimeoutExceededError.new("timed out")
          done
        end
      end

      # see {EventedExample#done}
      def done(delay = nil, &block)
        @spec_timer.detach
        delayed(delay) do
          yield if block_given?
          finish_loop
        end
      end

      # Stops the loop and finalizes the example
      def finish_loop
        run_hooks :coolio_after
        default_loop.stop
        finish_example
      end

      # see {EventedExample#delayed}
      def delayed(delay = nil, &block)
        timer = Coolio::TimerWatcher.new(delay.to_f, false)
        instance = self
        timer.on_timer do
          instance.instance_eval(&block)
        end
        timer.attach(default_loop)
        timer
      end

      protected

      def default_loop
        Coolio::Loop.default
      end

      #
      # Here is the drill:
      # If you get an exception inside of Cool.io event loop, you probably can't
      # do anything with it anytime later. You'll keep getting C-extension exceptions
      # when trying to start up. Replacing the Coolio default event loop with a new
      # one is relatively harmless.
      #
      # @private
      def reset
        Coolio::Loop.default_loop = Coolio::Loop.new
      end
    end # class CoolioExample
  end # module SpecHelper
end # module EventedSpec
