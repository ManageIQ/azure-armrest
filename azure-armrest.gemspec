# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'azure/armrest/version'

Gem::Specification.new do |spec|
  spec.name          = 'azure-armrest'
  spec.version       = Azure::Armrest::VERSION
  spec.authors       = ['Daniel J. Berger', 'Bronagh Sorota', 'Greg Blomquist']
  spec.email         = ['dberger@redhat.com', 'bsorota@redhat.com', 'gblomqui@redhat.com']

  spec.summary       = 'An interface for ARM/JSON Azure REST API'
  spec.description   = <<-EOF
This is a Ruby interface for Azure using the newer REST API. This is
different than the current azure gem, which uses the older (XML) interface
behind the scenes.
  EOF
  spec.homepage      = 'http://github.com/ManageIQ/azure-armrest'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "codeclimate-test-reporter"
  spec.add_development_dependency "timecop", "~> 0.7"

  spec.add_dependency 'json'
  spec.add_dependency 'rest-client'
end
