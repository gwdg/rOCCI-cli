require 'json'
require 'erb'

module Occi::Cli

  class ResourceOutputFactory

    @@allowed_formats = [:json, :plain, :json_pretty, :json_extended, :json_extended_pretty].freeze

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
      elsif data.kind_of? Occi::Core::Links
        method = "links_to_#{@output_format}".to_sym
      elsif data.kind_of? Occi::Core::Mixins
        method = "mixins_to_#{@output_format}".to_sym
      elsif data.kind_of? Occi::Core::Kinds
        method = "kinds_to_#{@output_format}".to_sym
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
      occi_resources = occi_resources.to_a

      if @output_format.to_s.end_with? '_pretty'
        output_first = "[\n"
        output_ary = occi_resources.collect do |r|
          local_hash = @output_format.to_s.include?('_extended') ? extended_json(r) : r.as_json.to_hash
          JSON.pretty_generate(local_hash)
        end
        separator = ",\n"
        output_last = "\n]"
      else
        output_first = "["
        output_ary = occi_resources.collect do |r|
          local_hash = @output_format.to_s.include?('_extended') ? extended_json(r) : r.as_json.to_hash
          JSON.generate(local_hash)
        end
        separator = ","
        output_last = "]"
      end

      "#{output_first}#{output_ary.join(separator)}#{output_last}"
    end
    alias_method :resources_to_json_pretty, :resources_to_json
    alias_method :links_to_json, :resources_to_json
    alias_method :links_to_json_pretty, :resources_to_json
    alias_method :mixins_to_json, :resources_to_json
    alias_method :mixins_to_json_pretty, :resources_to_json

    alias_method :resources_to_json_extended, :resources_to_json
    alias_method :resources_to_json_extended_pretty, :resources_to_json
    alias_method :links_to_json_extended, :resources_to_json
    alias_method :links_to_json_extended_pretty, :resources_to_json
    alias_method :mixins_to_json_extended, :resources_to_json
    alias_method :mixins_to_json_extended_pretty, :resources_to_json

    # Renders Occi::Core::Links as a full JSON, not just a String
    # array.
    #
    # @param resource [Occi::Core::Resource] resource to be rendered into extended JSON
    # @return [Hash] extended JSON represented as a Hash instance
    def extended_json(resource)
      return resource.as_json.to_hash unless resource.respond_to?(:links)
      return resource.as_json.to_hash unless resource.links.kind_of?(Occi::Core::Links)

      links = resource.links
      ext_json = resource.as_json
      ext_json.links = links.as_json
      ext_json.to_hash
    end

    def locations_to_json(url_locations)
      # generate JSON document from an array of strings
      if @output_format == :json_pretty
        JSON.pretty_generate url_locations
      else
        JSON.generate url_locations
      end
    end
    alias_method :locations_to_json_pretty, :locations_to_json
    alias_method :locations_to_json_extended_pretty, :locations_to_json
    alias_method :locations_to_json_extended, :locations_to_json

    def resources_to_plain(occi_resources)
      # using ERB templates for known resource types
      file = "#{File.expand_path('..', __FILE__)}/templates/resources.erb"
      template = ERB.new(File.new(file).read, nil, '-')

      formatted_output = ""
      formatted_output << template.result(binding) unless occi_resources.blank?

      formatted_output
    end

    def links_to_plain(occi_links)
      # using ERB templates for known link types
      file = "#{File.expand_path('..', __FILE__)}/templates/links.erb"
      template = ERB.new(File.new(file).read, nil, '-')

      formatted_output = ""
      formatted_output << template.result(binding) unless occi_links.blank?

      formatted_output
    end

    def mixins_to_plain(occi_mixins)
      # using ERB templates for known mixin types
      file = "#{File.expand_path('..', __FILE__)}/templates/mixins.erb"
      template = ERB.new(File.new(file).read, nil, '-')

      formatted_output = ""
      formatted_output << template.result(binding) unless occi_mixins.blank?

      formatted_output
    end

    def locations_to_plain(url_locations)
      url_locations.join("\n")
    end

    def kinds_to_plain(occi_kinds)
      # using ERB templates for known kinds
      file = "#{File.expand_path('..', __FILE__)}/templates/kinds.erb"
      template = ERB.new(File.new(file).read, nil, '-')

      formatted_output = ""
      formatted_output << template.result(binding) unless occi_kinds.blank?

      formatted_output
    end

    def kinds_to_json(occi_kinds)
      # generate JSON document from Occi::Core::Kinds
      occi_kinds = occi_kinds.to_a

      if @output_format.to_s.end_with? '_pretty'
        output_first = "[\n"
        output_ary = occi_kinds.collect do |r|
          JSON.pretty_generate(r.as_json.to_hash)
        end
        separator = ",\n"
        output_last = "\n]"
      else
        output_first = "["
        output_ary = occi_kinds.collect do |r|
          JSON.generate(r.as_json.to_hash)
        end
        separator = ","
        output_last = "]"
      end

      "#{output_first}#{output_ary.join(separator)}#{output_last}"
    end
    alias_method :kinds_to_json_pretty, :kinds_to_json
    alias_method :kinds_to_json_extended_pretty, :kinds_to_json
    alias_method :kinds_to_json_extended, :kinds_to_json

  end

end
