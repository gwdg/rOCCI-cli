require 'base64'

module Occi::Cli
  class OcciOpts
    module Helper

      ALLOWED_CONTEXT_VARS = [:public_key, :user_data].freeze

      MIXIN_REGEXP = /^(\S+?)#(\S+)$/
      CONTEXT_REGEXP = ATTR_REGEXP = /^(\S+?)=(.+)$/

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

        { symbol => context_data.strip }
      end

      def self.parse_attribute(attribute)
        ary = ATTR_REGEXP.match(attribute).to_a.drop 1
        raise ArgumentError, "Attribute must always contain ATTR=VALUE pairs!" unless ary.length == 2

        ary[0] = "occi.core.#{ary[0]}" unless ary[0].include?('.')
        
        { ary[0] => ary[1] }
      end

      def self.parse_mixin(mixin)
        parts = MIXIN_REGEXP.match(mixin).to_a.drop(1)
        raise "Unknown mixin format '#{mixin.inspect}'! Use SCHEME#NAME or TYPE#NAME!" unless parts.length == 2

        Occi::Core::Mixin.new("#{parts[0]}#", parts[1])
      end

    end
  end
end