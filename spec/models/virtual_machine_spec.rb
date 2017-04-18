########################################################################
# virtual_machine_spec.rb
#
# Test suite for the Azure::Armrest::VirtualMachine json model class.
########################################################################
require 'spec_helper'

describe "VirtualMachine" do
  let(:json) do
    '{
      "type": "Microsoft.Compute/virtualMachines",
      "location": "westus",
      "id": "/subscriptions/xxx/resourceGroups/yyy/providers/Microsoft.Compute/virtualMachines/a-managed-disk",
      "name": "a-managed-disk",
      "properties": {
        "vmId": "229b17b2-1424-469f-a194-5a14f742be4e",
          "hardwareProfile": {
            "vmSize": "Standard_A0"
          },
        "storageProfile": {
          "imageReference": {
            "publisher": "RedHat",
            "offer": "RHEL",
            "sku": "7.3",
            "version": "latest"
          },
          "osDisk": {
            "osType": "Linux",
            "name": "dberger-managed-disk",
            "createOption": "FromImage",
            "caching": "ReadWrite",
            "managedDisk": {
              "storageAccountType": "Standard_LRS",
              "id": "/subscriptions/xxx/resourceGroups/yyy/providers/Microsoft.Compute/disks/a-managed-disk"
            },
            "diskSizeGB": 32
          }
        }
      }
    }'
  end

  let(:vm) { Azure::Armrest::VirtualMachine.new(json) }

  context "custom methods" do
    it "defines a managed_disk? method that returns the expected result" do
      expect(vm).to respond_to(:managed_disk?)
      expect(vm.managed_disk?).to eql(true)
    end

    it "defines a size method that returns the expected result" do
      expect(vm).to respond_to(:size)
      expect(vm.size).to eql("Standard_A0")
    end

    it "defines a flavor alias for size" do
      expect(vm).to respond_to(:flavor)
      expect(vm.method(:size)).to eql(vm.method(:flavor))
    end

    it "defines an operating_system method that returns the expected result" do
      expect(vm).to respond_to(:operating_system)
      expect(vm.operating_system).to eql("Linux")
    end

    it "defines an os alias for operating_system" do
      expect(vm).to respond_to(:os)
      expect(vm.method(:os)).to eql(vm.method(:operating_system))
    end
  end
end
