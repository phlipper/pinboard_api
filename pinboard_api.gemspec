# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pinboard_api/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Phil Cohen"]
  gem.email         = ["github@phlippers.net"]
  gem.description   = %q{A Ruby client for the Pinboard.in API}
  gem.summary       = %q{A Ruby client for the Pinboard.in API}
  gem.homepage      = "http://phlippers.net/pinboard_api"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "pinboard_api"
  gem.require_paths = ["lib"]
  gem.version       = PinboardApi::VERSION

  gem.required_ruby_version = ">= 1.9.2"

  gem.add_runtime_dependency "faraday", "~> 0.8.0"
  gem.add_runtime_dependency "faraday_middleware", "~> 0.8.7"
  gem.add_runtime_dependency "multi_xml", "~> 0.5.1"

  gem.add_development_dependency "guard-minitest"
  gem.add_development_dependency "growl"
  gem.add_development_dependency "minitest"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "rb-fsevent"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "vcr"
end
