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
