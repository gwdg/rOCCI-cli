# a bunch of OCCI client helpers for bin/occi
module Occi::Cli::Helpers; end

# load all
Dir[File.join(File.dirname(__FILE__), 'helpers', '*.rb')].each { |file| require file.gsub('.rb', '') }

extend Occi::Cli::Helpers::CommonHelper
extend Occi::Cli::Helpers::ListHelper
extend Occi::Cli::Helpers::DescribeHelper
extend Occi::Cli::Helpers::CreateHelper
extend Occi::Cli::Helpers::DeleteHelper
extend Occi::Cli::Helpers::TriggerHelper
extend Occi::Cli::Helpers::LinkHelper
extend Occi::Cli::Helpers::DiscoverHelper
