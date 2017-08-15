module Occi::Cli::Helpers::LinkHelper

  def helper_link(options, output = nil)
    location = nil

    unless options.resource.start_with?(options.endpoint) || options.resource.start_with?('/')
      raise "Given resource is not a valid instance URL! #{options.resource.inspect}"
    end

    unless options.links.length == 1
      raise "You can assign only one link at a time!"
    end

    link = sanitize_instance_link(options.links.first)
    unless link.start_with?('/')
      raise "Given link is not a valid instance URL! #{link.inspect}"
    end

    link_kind = helper_link_kind(options, link)
    location = helper_link_create_link(options, link_kind, link)

    return location if output.nil?

    puts location
  end

  def helper_link_kind(options, link)
    raise "No valid links given!" if link.blank?

    case link
    when /\/network\//, /\/ipreservation\//
      link_kind = model.get_by_id("http://schemas.ogf.org/occi/infrastructure#networkinterface")
      raise "#{options.endpoint.inspect} does not support networkinterface links!" unless link_kind
    when /\/storage\//
      link_kind = model.get_by_id("http://schemas.ogf.org/occi/infrastructure#storagelink")
      raise "#{options.endpoint.inspect} does not support storagelink links!" unless link_kind
    when /\/securitygroup\//
      link_kind = model.get_by_id("http://schemas.ogf.org/occi/infrastructure#securitygrouplink")
      raise "#{options.endpoint.inspect} does not support securitygroup links!" unless link_kind
    else
      raise "Unknown link target #{link.inspect}! Only network and storage targets are supported!"
    end

    link_kind
  end

  def helper_link_create_link(options, link_kind, link)
    Occi::Cli::Log.debug "Linking #{link.inspect} to #{options.resource.inspect}"

    link_instance = Occi::Core::Link.new(link_kind)
    link_instance.source = sanitize_instance_link(options.resource)
    link_instance.target = link

    helper_link_attach_mixins(options.mixins, link_instance)

    options.attributes.names.each_pair do |attribute, value|
      link_instance.attributes[attribute.to_s] = value
    end

    create link_instance
  end

  def helper_link_attach_mixins(mixins, link)
    return if mixins.blank?

    Occi::Cli::Log.debug "with mixins: #{mixins.inspect}"

    mixins.to_a.each do |mxn|
      Occi::Cli::Log.debug "Adding mixin #{mxn.inspect} to #{link.inspect}"

      orig_mxn = model.get_by_id(mxn.type_identifier)
      if orig_mxn.blank?
        orig_mxn = mixin(mxn.term, mxn.scheme.chomp('#'), true)
        raise Occi::Cli::Errors::MixinLookupError,
            "The specified mixin is not declared in the model! #{mxn.type_identifier.inspect}" if orig_mxn.blank?
      end

      link.mixins << orig_mxn
    end
  end

end
