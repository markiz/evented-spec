require 'spec_helper'
describe EventedSpec::SpecHelper, "AMQP bindings" do
  include EventedSpec::SpecHelper
  default_timeout 0.5

  def amqp_running?
    EM.reactor_running? && !!AMQP.connection
  end # em_running?

  context "shared examples", :adapter => 'amqp' do
    it_should_behave_like "EventedSpec adapter"
  end

  describe EventedSpec::AMQPSpec do
    include EventedSpec::AMQPSpec
    it "should run inside of amqp block" do
      amqp_running?.should == true
      done
    end
  end

  describe "actual AMQP functionality" do
    include EventedSpec::SpecHelper
    default_options AMQP_OPTS if defined? AMQP_OPTS

    def publish_and_consume_once(queue_name="test_sink", data="data")
      amqp(:spec_timeout => 0.5) do
        AMQP::Channel.new do |channel, _|
          exchange = channel.direct(queue_name)
          queue = channel.queue(queue_name).bind(exchange)
          queue.subscribe do |hdr, msg|
            hdr.should be_an AMQP::Header
            msg.should == data
            done { queue.unsubscribe; queue.delete }
          end
          EM.add_timer(0.2) do
            exchange.publish data
          end
        end
      end
    end

    it 'sends data to the queue' do
      publish_and_consume_once
    end

    it 'does not hang sending data to the same queue, again' do
      publish_and_consume_once
    end

    it 'cleans Thread.current[:mq] after pubsub examples' do
      Thread.current[:mq].should be_nil
    end
  end

end
