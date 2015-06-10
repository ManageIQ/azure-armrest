## Description
A Ruby interface for Azure using the new REST API.

## Synopsis
```
require 'azure/armrest'

# Still alpha at this point, interface subject to change.
vmm = Azure::ArmRest::VirtualMachineManager.new(
  :client_id       => 'XXXXX',
  :client_key      => 'YYYYY',
  :tenant_id       => 'ZZZZZ',
  :subscription_id => 'ABCDEFG'
)

# Now we can make method calls
vmm.get_token

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

= Tokens and methods
You will not be able to make any method calls until you first call the
get_token method.

= Subscriptions
If you do not provide a subscription ID to the constructor, then the first
subscription ID returned from a REST call will be used.

= Notes
Currently only the client credentials strategy is supported. Support for other
strategies may be added over time.

= Authors
* Daniel Berger
* Bronagh Sorota
