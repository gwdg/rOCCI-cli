require 'base64'

module Occi::Cli
  class OcciOpts
    module Helper

      ALLOWED_CONTEXT_VARS = [:public_key, :user_data].freeze

      MIXIN_REGEXP = ACTION_REGEXP = /^(\S+?)#(\S+)$/
      CONTEXT_REGEXP = ATTR_REGEXP = /^(\S+?)=(.+)$/

      ATTR_NUM_EXP = /num\((?<number>\d+)\)/
      ATTR_BOOL_EXP = /bool\((?<bool>true|false)\)/
      ATTR_FLOAT_EXP = /float\((?<float>\d+\.\d+)\)/
      ATTR_INVALID_EXP = /num\(.*\)|bool\(.*\)|float\(.*\)/

      def self.parse_context_variable(cvar)
        ary = CONTEXT_REGEXP.match(cvar).to_a.drop 1
        raise ArgumentError, "Context variables must always contain ATTR=VALUE pairs!" unless ary.length == 2

        symbol = ary[0].to_sym
        unless ALLOWED_CONTEXT_VARS.include?(symbol)
          raise ArgumentError,
                "Only #{ALLOWED_CONTEXT_VARS.join(', ')} context " \
                "variables are supported! #{symbol.to_s.inspect}"
        end

        context_data = ary[1]
        if context_data.gsub!(/^file:\/\//,'')
          raise 'File does not exist! #{context_data}' unless File.exist? context_data
          context_data = File.read(context_data)
        end

        if symbol == :user_data
          context_data = Base64.encode64(context_data).gsub("\n", '')
        end

        [symbol, context_data.strip]
      end

      def self.parse_attribute(attribute)
        ary = ATTR_REGEXP.match(attribute).to_a.drop 1
        raise ArgumentError, "Attribute must always contain ATTR=VALUE pairs!" unless ary.length == 2

        ary[0] = "occi.core.#{ary[0]}" unless ary[0].include?('.')
        ary[1] = parse_attribute_value(ary[1])
        
        ary
      end

      def self.parse_mixin(mixin)
        parts = MIXIN_REGEXP.match(mixin).to_a.drop(1)
        raise "Unknown mixin format '#{mixin.inspect}'! Use SCHEME#TERM or SHORT_SCHEME#TERM!" unless parts.length == 2

        Occi::Core::Mixin.new("#{parts[0]}#", parts[1])
      end

      def self.parse_action(action)
        parts = ACTION_REGEXP.match(action).to_a.drop(1)
        raise "Unknown action format '#{action.inspect}'! Use SCHEME#TERM or SHORT_SCHEME#TERM!" unless parts.length == 2

        Occi::Core::Action.new("#{parts[0]}#", parts[1])
      end

      def self.parse_attribute_value(value)
        result = value

        ATTR_NUM_EXP =~ value
        result = Regexp.last_match(:number).to_i if Regexp.last_match(:number)

        ATTR_BOOL_EXP =~ value
        result = (Regexp.last_match(:bool) == 'true' ? true : false) if Regexp.last_match(:bool)

        ATTR_FLOAT_EXP =~ value
        result = Regexp.last_match(:float).to_f if Regexp.last_match(:float)

        raise ArgumentError, "Failed to cast attribute value #{result.inspect}!" if ATTR_INVALID_EXP =~ result.to_s

        result
      end

    end
  end
end