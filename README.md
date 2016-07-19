## Description

A Ruby interface for Azure using the new REST API.

[![Gem Version](https://badge.fury.io/rb/azure-armrest.svg)](http://badge.fury.io/rb/azure-armrest)
[![Build Status](https://travis-ci.org/ManageIQ/azure-armrest.svg)](https://travis-ci.org/ManageIQ/azure-armrest)
[![Code Climate](https://codeclimate.com/github/ManageIQ/azure-armrest/badges/gpa.svg)](https://codeclimate.com/github/ManageIQ/azure-armrest)
[![Test Coverage](https://codeclimate.com/github/ManageIQ/azure-armrest/badges/coverage.svg)](https://codeclimate.com/github/ManageIQ/azure-armrest/coverage)
[![Dependency Status](https://gemnasium.com/ManageIQ/azure-armrest.svg)](https://gemnasium.com/ManageIQ/azure-armrest)
[![Security](https://hakiri.io/github/ManageIQ/azure-armrest/master.svg)](https://hakiri.io/github/ManageIQ/azure-armrest/master)

## Synopsis

```ruby
require 'azure/armrest'

# Create a configuration object. All service objects will then use the
# information you set here.
#
# A token will be retrieved based on the information you provided

conf = Azure::Armrest::Configuration.new(
  :client_id       => 'XXXXX',
  :client_key      => 'YYYYY',
  :tenant_id       => 'ZZZZZ',
  :subscription_id => 'ABCDEFG'
)

# This will then use the configuration info set above.
# You can add other options specific to the service to be created
vms = Azure::Armrest::VirtualMachineService.new(conf, options)

# List all virtual machines for a given resource group:
vms.list(some_group).each do |vm|
  puts vm.name
  puts vm.resource_group
  puts vm.location
  puts vm.properties.hardware_profile.vm_size
end
```

## Subscriptions

As of version 0.3.0 you must provide a subscription ID. In previous versions,
if you did not provide a subscription ID in your configuration object, then the
first subscription ID returned from a REST call would be used.

## Notes

Currently only the client credentials strategy is supported. Support for other
strategies may be added over time.

## License

The gem is available as open source under the terms of the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0).

## Authors

* Daniel Berger
* Bronagh Sorota
* Bill Wei

