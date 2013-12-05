require 'rubygems'
require 'occi-api'

module Occi::Cli; end

require 'occi/cli/version'
require 'occi/cli/errors'
require 'occi/cli/resource_output_factory'
require 'occi/cli/occi_opts'

# get DSL definitions
extend Occi::Api::Dsl

# include helpers
require 'occi/cli/helpers'