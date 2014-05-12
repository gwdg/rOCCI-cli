require 'optparse'
require 'uri'
require 'erb'

# load all parts of OcciOpts
Dir[File.join(File.dirname(__FILE__), 'occi_opts', '*.rb')].each { |file| require file.gsub('.rb', '') }

module Occi::Cli

  class OcciOpts

    AUTH_METHODS = [:x509, :basic, :digest, :none].freeze
    MEDIA_TYPES = ["application/occi+json", "text/plain,text/occi", "text/plain", "text/occi"].freeze
    ACTIONS = [:list, :describe, :create, :delete, :trigger, :link, :unlink].freeze
    LOG_OUTPUTS = [:stdout, :stderr].freeze
    LOG_LEVELS = [:debug, :error, :fatal, :info, :unknown, :warn].freeze

    REQ_CREATE_ATTRS = ["occi.core.title"].freeze

    def self.parse(args, test_env = false)

      @@quiet = test_env

      options = Hashie::Mash.new
      set_defaults(options)

      opts = OptionParser.new do |opts|
        opts.banner = %{Usage: occi [OPTIONS]}

        opts.separator ""
        opts.separator "Options:"

        opts.on("-e",
                "--endpoint URI",
                String,
                "OCCI server URI, defaults to #{options.endpoint.inspect}") do |endpoint|
          options.endpoint = URI(endpoint).to_s
        end

        opts.on("-n",
                "--auth METHOD",
                AUTH_METHODS,
                "Authentication method, only: [#{AUTH_METHODS.join('|')}], defaults " \
                "to #{options.auth.type.inspect}") do |auth|
          options.auth.type = auth.to_s
        end

        opts.on("-k",
                "--timeout SEC",
                Integer,
                "Default timeout for all HTTP connections, in seconds") do |timeout|
          raise "Timeout has to be a number larger than 0!" if timeout < 1
          options.timeout = timeout
        end

        opts.on("-u",
                "--username USER",
                String,
                "Username for basic or digest authentication, defaults to " \
                "#{options.auth.username.inspect}") do |username|
          options.auth.username = username
        end

        opts.on("-p",
                "--password PASSWORD",
                String,
                "Password for basic, digest and x509 authentication") do |password|
          options.auth.password = password
          options.auth.user_cert_password = password
        end

        opts.on("-c",
                "--ca-path PATH",
                String,
                "Path to CA certificates directory, defaults to #{options.auth.ca_path.inspect}") do |ca_path|
          raise ArgumentError, "Path specified in --ca-path is not a directory!" unless File.directory? ca_path
          raise ArgumentError, "Path specified in --ca-path is not readable!" unless File.readable? ca_path

          options.auth.ca_path = ca_path
        end

        opts.on("-f",
                "--ca-file PATH",
                String,
                "Path to CA certificates in a file") do |ca_file|
          raise ArgumentError, "File specified in --ca-file is not a file!" unless File.file? ca_file
          raise ArgumentError, "File specified in --ca-file is not readable!" unless File.readable? ca_file

          options.auth.ca_file = ca_file
        end

        opts.on("-s",
                "--skip-ca-check",
                "Skip server certificate verification [NOT recommended]") do
          silence_warnings { OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE) }
        end

        opts.on("-F",
                "--filter CATEGORY",
                String,
                "Category type identifier to filter categories from model, must " \
                "be used together with the -m option") do |filter|
          options.filter = filter
        end

        opts.on("-x",
                "--user-cred FILE",
                String,
                "Path to user's x509 credentials, defaults to #{options.auth.user_cert.inspect}") do |user_cred|
          raise ArgumentError, "File specified in --user-cred is not a file!" unless File.file? user_cred
          raise ArgumentError, "File specified in --user-cred is not readable!" unless File.readable? user_cred

          options.auth.user_cert = user_cred
        end

        opts.on("-X",
                "--voms",
                "Using VOMS credentials; modifies behavior of the X509 authN module") do |voms|

          options.auth.voms = true
        end

        opts.on("-y",
                "--media-type MEDIA_TYPE",
                MEDIA_TYPES,
                "Media type for client <-> server communication, only: [#{MEDIA_TYPES.join('|')}], " \
                "defaults to #{options.media_type.inspect}") do |media_type|
          options.media_type = media_type
        end

        opts.on("-r",
                "--resource RESOURCE",
                String,
                "Term, identifier or URI of a resource to be queried, required") do |resource|
          options.resource = resource
        end

        opts.on("-t",
                "--attribute ATTR",
                Array,
                "An \"attribute='value'\" pair, mandatory attrs for creating new resource instances: " \
                "[#{REQ_CREATE_ATTRS.join(', ')}]") do |attributes|
          options.attributes ||= Occi::Core::Attributes.new

          attributes.each do |attribute|
            key, value = Occi::Cli::OcciOpts::Helper.parse_attribute(attribute)
            options.attributes[key] = value
          end
        end

        opts.on("-T",
                "--context CTX_VAR",
                Array,
                "A \"context_variable='value'\" pair for new 'compute' resource instances, " \
                "only: [#{Occi::Cli::OcciOpts::Helper::ALLOWED_CONTEXT_VARS.join(', ')}]") do |context|
          options.context_vars ||= {}

          context.each do |ctx|
            key, value = Occi::Cli::OcciOpts::Helper.parse_context_variable(ctx)
            options.context_vars[key] = value
          end
        end

        opts.on("-a",
                "--action ACTION",
                ACTIONS,
                "Action to be performed on a resource instance, required") do |action|
          options.action = action
        end

        opts.on("-M",
                "--mixin IDENTIFIER",
                Array,
                "Identifier of a mixin, formatted as SCHEME#TERM or SHORT_SCHEME#TERM") do |mixins|
          options.mixins ||= Occi::Core::Mixins.new

          mixins.each do |mixin|
            options.mixins << Occi::Cli::OcciOpts::Helper.parse_mixin(mixin)
          end
        end

        opts.on("-j",
                "--link URI",
                Array,
                "URI of an instance to be linked with the given resource, applicable only for action 'link'") do |links|
          options.links ||= []

          links.each do |link|
            link_relative_path = URI(link).path
            raise ArgumentError, "Specified link URI is not valid!" unless link_relative_path.start_with? '/'
            options.links << link_relative_path
          end
        end

        opts.on("-g",
                "--trigger-action ACTION",
                String,
                "Action to be triggered on the resource, formatted as SCHEME#TERM or TERM") do |trigger_action|
          options.trigger_action = Occi::Cli::OcciOpts::Helper.parse_action(trigger_action)
        end

        opts.on("-l",
                "--log-to OUTPUT",
                LOG_OUTPUTS,
                "Log to the specified device, only: [#{LOG_OUTPUTS.join('|')}], defaults to 'stderr'") do |log_to|
          options.log.out = STDOUT if log_to.to_s == "stdout"
        end

        opts.on("-o",
                "--output-format FORMAT",
                Occi::Cli::ResourceOutputFactory.allowed_formats,
                "Output format, only: [#{Occi::Cli::ResourceOutputFactory.allowed_formats.join('|')}], " \
                "defaults to #{options.output_format.to_s.inspect}") do |output_format|
          options.output_format = output_format
        end

        opts.on("-b",
                "--log-level LEVEL",
                LOG_LEVELS,
                "Set the specified logging level, only: [#{LOG_LEVELS.join('|')}]") do |log_level|
          unless options.log.level == Occi::Cli::Log::DEBUG
            options.log.level = Occi::Cli::Log.const_get(log_level.to_s.upcase)
          end
        end

        opts.on_tail("-z",
                     "--examples",
                     "Show usage examples") do |examples|
          if examples
            if @@quiet
              exit true
            else
              file = "#{File.expand_path('..', __FILE__)}/occi_opts/cli_examples.erb"
              template = ERB.new(File.new(file).read, nil, '-')

              puts template.result(binding)
              exit! true
            end
          end
        end

        opts.on_tail("-m",
                     "--dump-model",
                     "Contact the endpoint and dump its model") do |dump_model|
          options.dump_model = dump_model
        end

        opts.on_tail("-d",
                     "--debug",
                     "Enable debugging messages") do |debug|
          options.debug = debug
          options.log.level = Occi::Cli::Log::DEBUG
        end

        opts.on_tail("-h",
                     "--help",
                     "Show this message") do
          if @@quiet
            exit true
          else
            puts opts
            exit! true
          end
        end

        opts.on_tail("-v",
                     "--version",
                     "Show version") do
          if @@quiet
            exit true
          else
            if options.debug
              puts "CLI:  #{Occi::Cli::VERSION}"
              puts "API:  #{Occi::Api::VERSION}"
              puts "Core: #{Occi::VERSION}"
            else
              puts Occi::Cli::VERSION
            end
            exit! true
          end
        end
      end

      begin
        opts.parse!(args)
      rescue Exception => ex
        if @@quiet
          exit false
        else
          puts ex.message.capitalize
          puts opts
          exit!
        end
      end

      check_restrictions options, opts

      options
    end

    private

    def self.set_defaults(options)
      options.debug = false

      options.log = {}
      options.log.out = STDERR
      options.log.level = Occi::Cli::Log::ERROR

      options.filter = nil
      options.dump_model = false

      options.endpoint = "http://localhost:3000"
      options.timeout = nil

      options.auth = {}
      options.auth.type = "none"
      options.auth.user_cert = "#{ENV['HOME']}/.globus/usercred.pem"
      options.auth.ca_path = "/etc/grid-security/certificates"
      options.auth.username = "anonymous"
      options.auth.ca_file = nil
      options.auth.voms = nil

      options.output_format = :plain

      options.mixins = Occi::Core::Mixins.new
      options.links = nil
      options.attributes = Occi::Core::Attributes.new
      options.context_vars = nil

      # TODO: change media type back to occi+json after the rOCCI-server update
      #options.media_type = "application/occi+json"
      options.media_type = "text/plain,text/occi"

      options
    end

    def self.check_restrictions(options, opts)
      check_incompatible_args(options, opts)

      return if options.dump_model

      mandatory = get_mandatory_args(options)
      check_hash(options, mandatory, opts)

      check_attributes(options.attributes, REQ_CREATE_ATTRS, opts) if options.action == :create
    end

    def self.check_incompatible_args(options, opts)
      if !options.dump_model && options.filter
        if @@quiet
          exit false
        else
          puts "You cannot use '--filter' without '--dump-model'!"
          puts opts
          exit!
        end
      end

      if options.voms && options.auth.type != "x509"
        if @@quiet
          exit false
        else
          puts "You cannot use '--voms' without '--auth x509'!"
          puts opts
          exit!
        end
      end
    end

    def self.get_mandatory_args(options)
      mandatory = []

      if options.action == :trigger
        mandatory << :trigger_action
      end

      if options.action == :create
        if options.mixins.blank? && options.resource == 'compute'
          mandatory << :links
        end

        mandatory << :attributes
      end

      if options.action == :link
        mandatory << :links
      end

      mandatory.concat [:resource, :action]

      mandatory
    end

    def self.check_hash(hash, mandatory, opts)
      unless hash.is_a?(Hash)
        hash = hash.marshal_dump
      end

      missing = mandatory.select { |param| hash[param].blank? }
      report_missing missing, opts
    end

    def self.check_attributes(attributes, mandatory, opts)
      missing = []
      attributes = Occi::Core::Attributes.new(attributes)

      mandatory.each do |attribute|
        begin
          attributes[attribute]
          raise Occi::Errors::AttributeMissingError,
                "Attribute #{attribute.inspect} is empty!" unless attributes[attribute]
        rescue Occi::Errors::AttributeMissingError
          missing << attribute
        end
      end

      report_missing missing, opts
    end

    def self.report_missing(missing, opts)
      unless missing.empty?
        if @@quiet
          exit false
        else
          puts "Missing required arguments: #{missing.join(', ')}"
          puts opts
          exit!
        end
      end
    end
  end

end
