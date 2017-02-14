module Occi::Cli::Helpers::UpdateHelper
  def helper_update(options, output = nil)
    unless resource_types.include?(options.resource) || resource_type_identifiers.include?(options.resource) \
                                                     || \
           options.resource.start_with?(options.endpoint) || options.resource.start_with?('/')
      Occi::Cli::Log.error "I have no idea what #{options.resource.inspect} is ..."
      raise "Unknown resource #{options.resource.inspect}, there is nothing to update here!"
    end

    raise "No updatable mixins were provided!" if options.mixins.blank?
    mxns = ::Occi::Core::Mixins.new
    options.mixins.to_a.each do |mxn|
      Occi::Cli::Log.debug "Adding mixin #{mxn.inspect} to #{options.resource.inspect}"

      orig_mxn = model.get_by_id(mxn.type_identifier)
      if orig_mxn.blank?
        orig_mxn = mixin(mxn.term, mxn.scheme.chomp('#'), true)
        raise Occi::Cli::Errors::MixinLookupError,
            "The specified mixin is not declared in the model! #{mxn.type_identifier.inspect}" if orig_mxn.blank?
      end

      mxns << orig_mxn
    end

    unless update(options.resource, mxns)
      message = "Failed to update #{options.resource.inspect}!"
      Occi::Cli::Log.error message
      raise message
    end
    Occi::Cli::Log.info "Update performed on #{options.resource.inspect}!"

    true
  end
end
