module Occi::Cli::Helpers::ListHelper

  def helper_list(options, output = nil)
    found = []

    if resource_types.include?(options.resource) || resource_type_identifiers.include?(options.resource)
      Occi::Log.debug "#{options.resource} is a resource type."
      found = list options.resource
    elsif mixin_types.include?(options.resource) || mixin_type_identifiers.include?(options.resource)
      Occi::Log.debug "#{options.resource} is a mixin type."
      found = mixin_list options.resource
    else
      Occi::Log.error "I have no idea what #{options.resource} is ..."
      raise "Unknown resource #{options.resource}, there is nothing to list here!"
    end

    helper_list_output(found, options, output)
  end

  def helper_list_output(found, options, output)
    return found unless output

    puts output.format(found)
  end

end