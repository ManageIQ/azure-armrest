$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require_relative '../lib/azure-armrest'
require 'pp'

conf = Azure::Armrest::ArmrestService.configure(
  :client_id       => 'client_id',
  :client_key      => 'client_key',
  :tenant_id       => 'tenant_id',
  :subscription_id => 'subscription_id',
  :resource_group  => 'resource_group'
)

vms = Azure::Armrest::VirtualMachineService.new(conf)
vm_model = vms.get('my_machine_name', conf.resource_group, true)

pp vm_model
pp vm_model.properties
pp vm_model.os_disk
pp vm_model.data_disks
pp vm_model.networks

# actions
vm_model.start
vm_model.stop
vm_model.deallocate
