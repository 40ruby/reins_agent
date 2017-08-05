# coding: utf-8

# filename: config.rb
require 'logger'

module Reins
  class << self
    attr_accessor :logger, :port

    def configure
      yield self
    end
  end
end

Reins.configure do |config|
  config.logger       = Logger.new(ENV['REINS_AGENT_LOGGER'] || "/tmp/reins_agent.log")
  config.port         = ENV['REINS_AGENT_PORT'] || 24_368
end

Reins.logger.level = ENV['REINS_AGENT_LOGLEVEL'] ? eval("Logger::#{ENV['REINS_AGENT_LOGLEVEL']}") : Logger::WARN
