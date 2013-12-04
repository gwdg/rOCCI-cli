module Occi::Cli::Helpers::DescribeHelper

  def helper_describe(options, output = nil)
    if resource_types.include?(options.resource) || resource_type_identifiers.include?(options.resource) || options.resource.start_with?(options.endpoint) || options.resource.start_with?('/')
      Occi::Log.debug "#{options.resource.inspect} is a resource type, type identifier or an actual resource."

      found = Occi::Core::Resources.new
      found.merge describe(options.resource)
    elsif mixin_types.include?(options.resource) || mixin_type_identifiers.include?(options.resource)
      Occi::Log.debug "#{options.resourcre.inspect} is a mixin type or type identifier."

      found = Occi::Core::Mixins.new
      found.merge mixins(options.resource)
    else
      Occi::Log.error "I have no idea what #{options.resource.inspect} is ..."
      raise "Unknown resource #{options.resource.inspect}, there is nothing to describe here!"
    end

    helper_describe_output(found, options, output)
  end

  def helper_describe_output(found, options, output)
    return found unless output

    puts output.format(found)
  end

end