module Occi::Cli::Helpers::DeleteHelper

  def helper_delete(options, output = nil)
    unless resource_types.include?(options.resource) || resource_type_identifiers.include?(options.resource) || options.resource.start_with?(options.endpoint) || options.resource.start_with?('/')
      message = "Resource #{options.resource.inspect} cannot be deleted!"

      Occi::Log.error message
      raise ArgumentError, message
    end

    if delete(options.resource)
      Occi::Log.info "Resource #{options.resource.inspect} successfully removed!"
    else
      message = "Failed to remove resource #{options.resource.inspect}!"

      Occi::Log.error message
      raise message
    end

    true
  end

end