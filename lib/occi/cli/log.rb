require 'logger'

module Occi::Cli
  class Log < ::Occi::Log

    SUBSCRIPTION_HANDLE = "rOCCI-cli.log"

    attr_reader :api_log

    def initialize(log_dev, log_prefix = '[rOCCI-cli]')
      @api_log = ::Occi::Api::Log.new(log_dev) 
      super
    end

    def close
      super
      @api_log.close
    end

    # @param severity [::Logger::Severity] severity
    def level=(severity)
      @api_log.level = severity
      super
    end

    def core_log
      @api_log.core_log
    end

  end
end