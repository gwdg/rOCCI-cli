module Occi::Cli::Helpers::TriggerHelper

  def helper_trigger(options, output = nil)
    unless resource_types.include?(options.resource) || resource_type_identifiers.include?(options.resource) \
                                                     || \
           options.resource.start_with?(options.endpoint) || options.resource.start_with?('/')
      Occi::Log.error "I have no idea what #{options.resource.inspect} is ..."
      raise "Unknown resource #{options.resource.inspect}, there is nothing to trigger here!"
    end

    action_instance = Occi::Core::ActionInstance.new
    action_instance.action = helper_trigger_normalize_action(options.trigger_action)
    action_instance.attributes = options.attributes

    if trigger(options.resource, action_instance)
      Occi::Log.info "Action #{options.trigger_action.type_identifier.inspect} " \
                     "triggered on #{options.resource.inspect}!"
    else
      message = "Failed to trigger an action on #{options.resource.inspect}!"
      Occi::Log.error message
      raise message
    end

    true
  end

  def helper_trigger_normalize_action(action)
    return action if action_type_identifiers.include?(action.type_identifier)

    ti = action_type_identifier(action.term)
    if ti.blank?
      message = "Failed to identify action #{action.type_identifier.inspect} in the model!"
      Occi::Log.error message
      raise message
    end

    splt = ti.split '#'
    action.term = splt.last
    action.scheme = "#{splt.first}#"

    action
  end

end