module Occi::Cli::Helpers::DiscoverHelper

  def helper_discover(options, output = nil)
    found = Occi::Core::Kinds.new

    case options.entity_type
    when :resource
      # get everything related to Occi::Core::Resource
      resource_type_identifiers.each { |resource_ti| found << model.get_by_id(resource_ti) }
    when :link
      # get everything related to Occi::Core::Link
      link_type_identifiers.each { |link_ti| found << model.get_by_id(link_ti) }
    else
      Occi::Cli::Log.warn "Attempting to discover an " \
                          "unknown entity type #{options.entity_type.to_s.inspect}"
      raise "Unknown entity type #{options.entity_type.to_s.inspect}, " \
            "terminating discovery!"
    end

    helper_discover_output(found, options, output)
  end

  def helper_discover_output(found, options, output)
    return found unless output

    puts output.format(found)
  end

end
