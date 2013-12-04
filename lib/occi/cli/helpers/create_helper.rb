module Occi::Cli::Helpers::CreateHelper

  def helper_create(options, output = nil)
    location = nil

    if resource_types.include?(options.resource) || resource_type_identifiers.include?(options.resource)
      Occi::Log.debug "#{options.resource.inspect} is a resource type."
      raise "Not yet implemented!" unless options.resource.include? "compute"

      res = resource options.resource

      Occi::Log.debug "Creating #{options.resource.inspect}:\n#{res.inspect}"

      helper_attach_links(options, res)
      helper_attach_mixins(options, res)
      helper_attach_context_vars(options, res)

      # TODO: set other attributes
      # TODO: OCCI-OS uses occi.compute.hostname instead of title
      res.title = options.attributes[:title]
      res.hostname = options.attributes[:title]

      Occi::Log.debug "Creating #{options.resource.inspect}:\n#{res.inspect}"

      location = create res
    else
      Occi::Log.warn "I have no idea what #{options.resource.inspect} is ..."
      raise "Unknown resource #{options.resource.inspect}, there is nothing to create here!"
    end

    return location if output.nil?

    puts location
  end

  def helper_attach_links(options, res)
    return unless options.links
    Occi::Log.debug "with links: #{options.links.inspect}"

    options.links.each do |link|
      if link.start_with? options.endpoint
        link.gsub!(options.endpoint.chomp('/'), '')
      end

      if link.include? "/storage/"
        Occi::Log.debug "Adding storagelink to #{options.resource.inspect}"
        res.storagelink link
      elsif link.include? "/network/"
        Occi::Log.debug "Adding networkinterface to #{options.resource.inspect}"
        res.networkinterface link
      else
        raise "Unknown link type #{link.inspect}, stopping here!"
      end
    end
  end

  def helper_attach_mixins(options, res)
    return unless options.mixins
    Occi::Log.debug "with mixins: #{options.mixins}"

    options.mixins.to_a.each do |mxn|
      Occi::Log.debug "Adding mixin #{mxn.inspect} to #{options.resource.inspect}"
      res.mixins << mxn
    end
  end

  def helper_attach_context_vars(options, res)
    # TODO: find a better/universal way to do contextualization
    return unless options.context_vars
    Occi::Log.debug "with context variables: #{options.context_vars}"

    options.context_vars.each_pair do |var, val|
      schema = nil
      mxn_attrs = Occi::Core::Attributes.new

      case var
      when :public_key
        schema = "http://schemas.openstack.org/instance/credentials#"
        mxn_attrs['org.openstack.credentials.publickey.name'] = {}
        mxn_attrs['org.openstack.credentials.publickey.data'] = {}
      when :user_data
        schema = "http://schemas.openstack.org/compute/instance#"
        mxn_attrs['org.openstack.compute.user_data'] = {}
      else
        schema = "http://schemas.ogf.org/occi/core#"
      end

      mxn = Occi::Core::Mixin.new(schema, var.to_s, 'OS contextualization mixin', mxn_attrs)
      res.mixins << mxn

      case var
      when :public_key
        res.attributes['org.openstack.credentials.publickey.name'] = 'Public SSH key'
        res.attributes['org.openstack.credentials.publickey.data'] = val
      when :user_data
        res.attributes['org.openstack.compute.user_data'] = val
      else
        # do nothing
      end
    end
  end

end