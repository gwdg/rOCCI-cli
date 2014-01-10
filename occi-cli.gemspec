# coding: utf-8
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'occi/cli/version'

Gem::Specification.new do |gem|
  gem.name          = "occi-cli"
  gem.version       = Occi::Cli::VERSION
  gem.authors       = ["Florian Feldhaus","Piotr Kasprzak", "Boris Parak"]
  gem.email         = ["florian.feldhaus@gwdg.de", "piotr.kasprzak@gwdg.de", "xparak@mail.muni.cz"]
  gem.description   = %q{This gem is a client implementation of the Open Cloud Computing Interface in Ruby}
  gem.summary       = %q{Executable OCCI client}
  gem.homepage      = 'https://github.com/gwdg/rOCCI-cli'
  gem.license       = 'Apache License, Version 2.0'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec}/*`.split("\n")
  gem.require_paths = ["lib"]

  gem.add_dependency 'occi-api', '= 4.2.0.beta.9'
  gem.add_dependency 'json'
  gem.add_dependency 'highline'

  gem.required_ruby_version     = ">= 1.9.3"
end
