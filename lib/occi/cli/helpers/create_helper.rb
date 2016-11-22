module Occi::Cli::Helpers::CreateHelper

  MIN_TIMEOUT = 5

  def helper_create(options, output = nil)
    location = nil

    if resource_types.include?(options.resource) || resource_type_identifiers.include?(options.resource)
      location = helper_create_resource(options)
    else
      Occi::Cli::Log.warn "I have no idea what #{options.resource.inspect} is ..."
      raise "Unknown resource #{options.resource.inspect}, there is nothing to create here!"
    end

    return location if output.nil?

    puts location
  end

  def helper_create_resource(options)
    Occi::Cli::Log.debug "#{options.resource.inspect} is a resource type."

    res = resource(options.resource)

    Occi::Cli::Log.debug "Creating #{options.resource.inspect}: #{res.inspect}"

    helper_create_attach_mixins(options, res)

    if res.kind_of? Occi::Infrastructure::Compute
      helper_create_attach_links(options, res)
      # TODO: context vars are only attributes!
      helper_create_attach_context_vars(options, res)
    end

    options.attributes.names.each_pair do |attribute, value|
      res.attributes[attribute.to_s] = value
    end

    # TODO: OCCI-OS uses occi.compute.hostname instead of title
    if res.kind_of? Occi::Infrastructure::Compute
      res.hostname = options.attributes["occi.core.title"] if res.hostname.blank?
    end

    # TODO: enable check
    #res.check

    Occi::Cli::Log.debug "Creating #{options.resource.inspect}: #{res.inspect}"
    new_link = create(res)
    helper_create_wait(new_link, options.wait_for_active) if options.wait_for_active > 0

    new_link
  end

  def helper_create_wait(resource_link, timeout)
    begin
      Timeout::timeout(timeout) {
        Occi::Cli::Log.debug "Starting #{timeout}s wait period for #{resource_link.inspect} to become active"
        while true
          desrc = describe(resource_link).first
          break if !desrc.respond_to?(:state) || desrc.state == 'active'
          sleep MIN_TIMEOUT
        end
      }
    rescue Timeout::Error
      Occi::Cli::Log.warn "Attempted to wait #{timeout}s for #{resource_link.inspect} to become active"
    end
  end

  def helper_create_attach_links(options, res)
    return unless options.links
    Occi::Cli::Log.debug "with links: #{options.links.inspect}"

    options.links.each do |link|
      if link.start_with? options.endpoint
        link.gsub!(options.endpoint.chomp('/'), '')
      end

      if link.include? "/storage/"
        Occi::Cli::Log.debug "Adding storagelink to #{options.resource.inspect}"
        res.storagelink link
      elsif link.include? "/network/"
        Occi::Cli::Log.debug "Adding networkinterface to #{options.resource.inspect}"
        res.networkinterface link
      else
        raise "Unknown link type #{link.inspect}, stopping here!"
      end
    end
  end

  def helper_create_attach_mixins(options, res)
    return unless options.mixins
    Occi::Cli::Log.debug "with mixins: #{options.mixins.inspect}"

    options.mixins.to_a.each do |mxn|
      Occi::Cli::Log.debug "Adding mixin #{mxn.inspect} to #{options.resource.inspect}"

      orig_mxn = model.get_by_id(mxn.type_identifier)
      if orig_mxn.blank?
        orig_mxn = mixin(mxn.term, mxn.scheme.chomp('#'), true)
        raise Occi::Cli::Errors::MixinLookupError,
            "The specified mixin is not declared in the model! #{mxn.type_identifier.inspect}" if orig_mxn.blank?
      end

      res.mixins << orig_mxn
    end
  end

  def helper_create_attach_context_vars(options, res)
    # TODO: find a better/universal way to do contextualization
    return unless options.context_vars
    Occi::Cli::Log.debug "with context variables: #{options.context_vars.inspect}"

    options.context_vars.each_pair do |var, val|
      schema = nil
      mxn_attrs = Occi::Core::Attributes.new

      case var
      when 'public_key', :public_key
        schema = "http://schemas.openstack.org/instance/credentials#"
        mxn_attrs['org.openstack.credentials.publickey.name'] = {}
        mxn_attrs['org.openstack.credentials.publickey.data'] = {}
      when 'user_data', :user_data
        schema = "http://schemas.openstack.org/compute/instance#"
        mxn_attrs['org.openstack.compute.user_data'] = {}
      else
        Occi::Cli::Log.warn "Unknown context variable! #{var.to_s.inspect}"
        schema = "http://schemas.ogf.org/occi/core#"
      end

      mxn = Occi::Core::Mixin.new(schema, var.to_s, 'OS contextualization mixin', mxn_attrs)
      res.mixins << mxn

      case var
      when 'public_key', :public_key
        # Not setting `publickey.name` to avoid conflicts with already registered keys
        # res.attributes['org.openstack.credentials.publickey.name'] = 'Public SSH key'
        res.attributes['org.openstack.credentials.publickey.data'] = val
      when 'user_data', :user_data
        res.attributes['org.openstack.compute.user_data'] = val
      else
        Occi::Cli::Log.warn "Not setting attributes for an unknown context variable! #{var.to_s.inspect}"
      end
    end
  end

end
