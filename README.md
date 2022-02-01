## Description

[![Join the chat at https://gitter.im/ManageIQ/azure-armrest](https://badges.gitter.im/ManageIQ/azure-armrest.svg)](https://gitter.im/ManageIQ/azure-armrest?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A Ruby interface for Azure using the new REST API.

[![Gem Version](https://badge.fury.io/rb/azure-armrest.svg)](http://badge.fury.io/rb/azure-armrest)
[![Build Status](https://travis-ci.org/ManageIQ/azure-armrest.svg)](https://travis-ci.org/ManageIQ/azure-armrest)
[![Code Climate](https://codeclimate.com/github/ManageIQ/azure-armrest/badges/gpa.svg)](https://codeclimate.com/github/ManageIQ/azure-armrest)
[![Test Coverage](https://codeclimate.com/github/ManageIQ/azure-armrest/badges/coverage.svg)](https://codeclimate.com/github/ManageIQ/azure-armrest/coverage)

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
vms = Azure::Armrest::VirtualMachineService.new(conf)

# You can add other options specific to the service to be created,
# such as the provider.

options = {:provider => 'Microsoft.ClassicCompute'}
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

As of version 0.4.0 you a subscription ID is not longer strictly necessary in
the Configuration constructor, but almost all service classes require it in
their own constructor. Only the SubscriptionService class does not.

In version 0.3.x the subscription ID was mandatory. Prior to 0.3.x, if you did
not provide a subscription ID in your configuration object, then the first
subscription ID returned from a REST call would be used.

## Notes

Currently only the client credentials strategy is supported. Support for other
strategies may be added over time.

## License

The gem is available as open source under the terms of the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0).

## Authors

* Daniel Berger
* Bronagh Sorota
* Bill Wei

