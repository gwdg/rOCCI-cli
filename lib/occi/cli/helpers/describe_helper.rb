module Occi::Cli::Helpers::DescribeHelper

  def helper_describe(options, output = nil)
    if resource_types.include?(options.resource) || options.resource.start_with?(options.endpoint) || options.resource.start_with?('/')
      Occi::Log.debug "#{options.resource} is a resource type or an actual resource."

      found = Occi::Core::Resources.new
      found.merge! describe(options.resource)
    elsif mixin_types.include? options.resource
      Occi::Log.debug "#{options.resourcre} is a mixin type."

      found = Occi::Core::Mixins.new
      mixins(options.resource).each do |mxn|
        mxn = mxn.split("#").last
        found.merge! mixin(mxn, options.resource, true)
      end
    elsif mixin_types.include? options.resource.split('#').first
      Occi::Log.debug "#{options.resource} is a specific mixin type."

      mxn_type, mxn = options.resource.split('#')

      found = Occi::Core::Mixins.new
      found.merge! mixin(mxn, mxn_type, true)
    else
      Occi::Log.error "I have no idea what #{options.resource} is ..."
      raise "Unknown resource #{options.resource}, there is nothing to describe here!"
    end

    helper_describe_output(found, options, output)
  end

  def helper_describe_output(found, options, output)
    return found unless output

    puts output.format(found)
  end

end