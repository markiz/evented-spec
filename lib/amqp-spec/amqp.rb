require 'mq'

module AMQP

  # Initializes new AMQP client/connection without starting another EM loop
  def self.start_connection(opts={}, &block)
#    puts "!!!!!!!!! Existing connection: #{@conn}" if @conn
    @conn = connect opts
    @conn.callback(&block) if block
  end

  # Closes AMQP connection and raises optional exception AFTER the AMQP connection is 100% closed
  def self.stop_connection
    if AMQP.conn and not AMQP.closing
#   MQ.reset ?
      @closing = true
      @conn.close {
        yield if block_given?
        cleanup_state
      }
    end
  end

  def self.cleanup_state
#   MQ.reset ?
    Thread.current[:mq]    = nil
    Thread.current[:mq_id] = nil
    @conn                  = nil
    @closing               = false
  end
end