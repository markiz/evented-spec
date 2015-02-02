require "spec_helper"

if !(RUBY_PLATFORM =~ /java/ || RUBY_VERSION =~ /^1\.8/)
  describe "EventedSpec cool.io bindings" do
    def coolio_running?
      !!Coolio::Loop.default.instance_variable_get(:@running)
    end # coolio_running?

    include EventedSpec::SpecHelper
    default_timeout 0.5

    it "can run inside of em loop" do
      coolio_running?.must_equal false
      coolio do
        coolio_running?.must_equal true
        done
      end
      coolio_running?.must_equal false
    end

    describe "hooks" do
      describe "hooks" do
        def hooks
          @hooks ||= []
        end

        before { hooks << :before }
        coolio_before { hooks << :coolio_before }
        coolio_after { hooks << :coolio_after }
        after { hooks << :after }

        it "execute in proper order" do
          hooks.must_equal [:before]
          coolio do
            hooks.must_equal [:before, :coolio_before]
            done
          end
          hooks.must_equal [:before, :coolio_before, :coolio_after]
        end
      end
    end


  describe "#delayed" do
    default_timeout 0.7
    it "works as intended" do
      coolio do
        time = Time.now
        delayed(0.3) { Time.now.must_be_close_to time + 0.3, 0.1 }
        done(0.4)
      end
    end
  end

  describe EventedSpec::CoolioSpec do
    include EventedSpec::CoolioSpec
    it "wraps the whole example" do
      coolio_running?.must_equal true
      done
    end
  end

  end
end
