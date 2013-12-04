require 'json'
require 'erb'

module Occi::Cli

  class ResourceOutputFactory

    @@allowed_formats = [:json, :plain, :json_pretty].freeze

    attr_reader :output_format

    def initialize(output_format = :plain)
      raise Occi::Cli::Errors::FormatterOutputTypeError,
            "Format #{output_format.inspect} is not supported!" unless @@allowed_formats.include? output_format
      @output_format = output_format
    end

    def format(data)
      # construct a method name from data type and output format
      if data.kind_of? Occi::Core::Resources
        method = "resources_to_#{@output_format}".to_sym
      elsif data.kind_of? Occi::Core::Mixins
        method = "mixins_to_#{@output_format}".to_sym
      elsif data.kind_of? Array
        raise Occi::Cli::Errors::FormatterInputTypeError,
              "Arrays with #{data.first.class.name.inspect} are not supported!" unless data.first.nil? || data.first.kind_of?(String)
        method = "locations_to_#{@output_format}".to_sym
      else
        raise Occi::Cli::Errors::FormatterInputTypeError,
              "Data format #{data.class.name.inspect} is not supported!"
      end

      send method, data
    end

    def self.allowed_formats
      @@allowed_formats
    end

    def resources_to_json(occi_resources)
      # generate JSON document from Occi::Core::Resources
      if @output_format == :json_pretty
        JSON.pretty_generate occi_resources.as_json
      else
        JSON.generate occi_resources.as_json
      end
    end
    alias_method :resources_to_json_pretty, :resources_to_json
    alias_method :mixins_to_json, :resources_to_json
    alias_method :mixins_to_json_pretty, :resources_to_json

    def locations_to_json(url_locations)
      # generate JSON document from an array of strings
      if @output_format == :json_pretty
        JSON.pretty_generate locations
      else
        JSON.generate locations
      end
    end
    alias_method :locations_to_json_pretty, :locations_to_json

    def resources_to_plain(occi_resources)
      # using ERB templates for known resource and mixin types
      file = "#{File.expand_path('..', __FILE__)}/templates/resources.erb"
      template = ERB.new(File.new(file).read, nil, '-')

      formatted_output = ""
      formatted_output << template.result(binding) unless occi_resources.blank?

      formatted_output
    end

    def mixins_to_plain(occi_resources)
      # using ERB templates for known resource and mixin types
      file = "#{File.expand_path('..', __FILE__)}/templates/mixins.erb"
      template = ERB.new(File.new(file).read, nil, '-')

      formatted_output = ""
      formatted_output << template.result(binding) unless occi_resources.blank?

      formatted_output
    end

    def locations_to_plain(url_locations)
      url_locations.join("\n")
    end

  end

end
