## Description

A Ruby interface for Azure using the new REST API.

[![Gem Version](https://badge.fury.io/rb/azure-armrest.svg)](http://badge.fury.io/rb/azure-armrest)
[![Build Status](https://travis-ci.org/ManageIQ/azure-armrest.svg)](https://travis-ci.org/ManageIQ/azure-armrest)
[![Code Climate](https://codeclimate.com/github/ManageIQ/azure-armrest/badges/gpa.svg)](https://codeclimate.com/github/ManageIQ/azure-armrest)
[![Test Coverage](https://codeclimate.com/github/ManageIQ/azure-armrest/badges/coverage.svg)](https://codeclimate.com/github/ManageIQ/azure-armrest/coverage)
[![Dependency Status](https://gemnasium.com/ManageIQ/azure-armrest.svg)](https://gemnasium.com/ManageIQ/azure-armrest)

## Synopsis

```ruby
require 'azure/armrest'

# Create a configuration object. All service objects will then use the
# information you set here.
# A token will be retrieved based on the information you provided

conf = Azure::Armrest::ArmrestService.configure(
  :client_id       => 'XXXXX',
  :client_key      => 'YYYYY',
  :tenant_id       => 'ZZZZZ',
  :subscription_id => 'ABCDEFG'
)

# This will then use the configuration info set above.
# You can add other options specific to the service to be created
vms = Azure::Armrest::VirtualMachineService.new(conf, options)

# Create a virtual machine
vmm.create_virtual_machine(
  :name           => 'some_vm',
  :location       => 'West US',
  :vm_size        => 'Standard_A1',
  :computer_name  => 'whatever',
  :admin_username => 'admin_user',
  :admin_password => 'adminxxxxxx',
  :os_disk        => {:name => 'disk_name1', :os_type => 'Linux', :caching => 'read'},
  :data_disks     => {:name => 'data_disk1', :lun => 0, :caching => 'read'}
)
```

## Subscriptions

If you do not provide a subscription ID to the constructor, then the first
subscription ID returned from a REST call will be used.

## Notes

Currently only the client credentials strategy is supported. Support for other
strategies may be added over time.

## License

The gem is available as open source under the terms of the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0).

## Authors

* Daniel Berger
* Bronagh Sorota
* Bill Wei

