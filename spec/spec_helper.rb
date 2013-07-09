require 'rubygems'
require 'occi-cli'

# enable coverage reports
if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

RSpec.configure do |c|
  # in RSpec 3 this will no longer be necessary.
  c.treat_symbols_as_metadata_keys_with_true_values = true
end
