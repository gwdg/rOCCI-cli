module Occi::Cli::Errors; end

# load all
Dir[File.join(File.dirname(__FILE__), 'errors', '*.rb')].each { |file| require file.gsub('.rb', '') }