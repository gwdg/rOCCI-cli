require 'rubygems/tasks'

task :default => 'test'

desc "Run all tests; includes rspec and coverage reports"
task :test => 'rcov:all'

desc "Run all tests; includes rspec and coverage reports"
task :spec => 'test'

Gem::Tasks.new(:build => {:tar => true, :zip => true}, :sign => {:checksum => true, :pgp => false})

namespace :rcov do

  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:rspec) do |t|
    ENV['COVERAGE'] = "true"
  end

  desc "Run rspec to generate aggregated coverage"
  task :all do |t|
    rm "coverage/coverage.data" if File.exist?("coverage/coverage.data")
    Rake::Task['rcov:rspec'].invoke
  end

end

require 'yard'
YARD::Rake::YardocTask.new(:yard) do |t|
  t.options = ['--any', '--extra', '--opts'] # optional
end
