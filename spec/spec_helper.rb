#$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

$LOAD_PATH << "." unless $LOAD_PATH.include? "." # moronic 1.9.2 breaks things bad

require 'spec'
require 'yaml'

require 'amqp-spec/rspec'
require 'shared_examples'
#require File.join(File.dirname(__FILE__), '..', 'lib', 'amqp-spec', 'rspec.rb')

amqp_config = File.dirname(__FILE__) + '/amqp.yml'
if File.exists? amqp_config

  class Hash
    def symbolize_keys
      self.inject({}) { |result, (key, value)|
        new_key = case key
                    when String then
                      key.to_sym
                    else
                      key
                  end
        new_value = case value
                      when Hash then
                        value.symbolize_keys
                      else
                        value
                    end
        result[new_key] = new_value
        result
      }
    end
  end

  AMQP_OPTS = YAML::load_file(amqp_config).symbolize_keys[:test]
end