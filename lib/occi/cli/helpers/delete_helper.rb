module Occi::Cli::Helpers::DeleteHelper

  def helper_delete(options, output = nil)
    if delete(options.resource)
      Occi::Log.info "Resource #{options.resource} successfully removed!"
    else
      Occi::Log.error "Failed to remove resource #{options.resource}!"
      raise "Failed to remove resource #{options.resource}!"
    end

    true
  end

end