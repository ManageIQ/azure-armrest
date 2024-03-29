# coding: utf-8
require_relative 'lib/azure/armrest/version'

Gem::Specification.new do |spec|
  spec.name     = 'azure-armrest'
  spec.version  = Azure::Armrest::VERSION
  spec.authors  = ['Daniel J. Berger', 'Bronagh Sorota', 'Greg Blomquist', 'Bill Wei']
  spec.email    = ['dberger@redhat.com', 'bsorota@redhat.com', 'gblomqui@redhat.com', 'billwei@redhat.com']
  spec.summary  = 'An interface for ARM/JSON Azure REST API'
  spec.homepage = 'http://github.com/ManageIQ/azure-armrest'
  spec.license  = 'Apache-2.0'
  spec.files    = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }

  spec.description = <<-EOF
This is a Ruby interface for Azure using the newer REST API. This is
different than the current azure gem, which uses the older (XML) interface
behind the scenes.
  EOF

  spec.add_dependency "activesupport",   ">= 4.2.2"
  spec.add_dependency "addressable",     "~> 2.8"
  spec.add_dependency "azure-signature", "~> 0.3.0"
  spec.add_dependency "json",            "~> 2"
  spec.add_dependency "memoist",         "~> 0.15"
  spec.add_dependency "parallel",        "~> 1.22"
  spec.add_dependency "rest-client",     "~> 2.1.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "manageiq-style"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec",     "~> 3.0"
  spec.add_development_dependency "simplecov", ">= 0.21.2"
  spec.add_development_dependency "timecop",   "~> 0.7"
end
