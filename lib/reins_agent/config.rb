# coding: utf-8

# filename: config.rb
require 'logger'

module ReinsAgent
  class << self
    attr_accessor :logger, :client_key, :client_port, :server_host, :server_port

    def configure
      yield self
    end
  end
end

ReinsAgent.configure do |config|
  config.logger      = Logger.new(ENV['REINS_AGENT_LOGGER'] || "/tmp/reins_agent.log")
  config.client_key  = ENV['REINS_AGENT_KEY']  || "40ruby"
  config.client_port = ENV['REINS_AGENT_PORT'] || 24_368
  config.server_host = ENV['REINS_SERVER_HOST'] || "127.0.0.1"
  config.server_port = ENV['REINS_PORT'] || 16_383
end

ReinsAgent.logger.level = ENV['REINS_AGENT_LOGLEVEL'] ? eval("Logger::#{ENV['REINS_AGENT_LOGLEVEL']}") : Logger::WARN
