require 'rubygems'

Gem::Specification.new do |spec|
  spec.name      = 'azure-armrest'
  spec.version   = '0.1.0'
  spec.authors   = ['Daniel J. Berger', 'Bronagh Sorota', 'Greg Blomquist']
  spec.license   = 'Artistic 2.0'
  spec.homepage  = 'http://github.com/djberg96/azure-profile'
  spec.summary   = 'An interface for ARM/JSON Azure REST API'
  spec.test_file = 'test/test_azure_armrest.rb'
  spec.files     = Dir['**/*'].delete_if{ |item| item.include?('git') }

  spec.extra_rdoc_files = ['CHANGES', 'README', 'MANIFEST']

  spec.add_dependency('json')
  spec.add_dependency('rest-client')

  spec.add_development_dependency('minitest')
  spec.add_development_dependency('rake')

  spec.description = <<-EOF
    This is a Ruby interface for Azure using the newer REST API. This is
    different than the current azure gem, which uses the older (XML) interface
    behind the scenes.
  EOF
end
