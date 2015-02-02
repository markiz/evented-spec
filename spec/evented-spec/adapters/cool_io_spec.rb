require 'spec_helper'

describe EventedSpec::SpecHelper, "Cool.io bindings", :nojruby => true do
  include EventedSpec::SpecHelper
  default_timeout 1

  def coolio_running?
    !!Coolio::Loop.default.instance_variable_get(:@running)
  end # coolio_running?

  after(:each) {
    coolio_running?.should == false
  }

  context "shared examples", :adapter => "coolio" do
    it_should_behave_like "EventedSpec adapter"
  end


  describe EventedSpec::CoolioSpec do
    include EventedSpec::CoolioSpec
    it "should run inside of coolio loop" do
      coolio_running?.should == true
      Coolio::Loop.default.has_active_watchers?.should == true
      done
    end
  end

end
