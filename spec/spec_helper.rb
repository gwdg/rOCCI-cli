# make sure the local files will be loaded first;
# this should prevent installed versions of this
# gem to be included in the testing process
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.dirname(__FILE__))

# enable coverage reports
if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

require 'occi-api'

RSpec.configure do |c|
  # in RSpec 3 this will no longer be necessary.
  c.treat_symbols_as_metadata_keys_with_true_values = true
end
