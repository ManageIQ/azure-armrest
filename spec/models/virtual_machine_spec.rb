########################################################################
# virtual_machine_spec.rb
#
# Test suite for the Azure::Armrest::VirtualMachine json model class.
########################################################################
require 'spec_helper'

describe 'VirtualMachine' do
  before do
    @json = '{
      "id": "/subscriptions/xxx/resourceGroups/group1/providers/Microsoft.Compute/virtualMachines/foo1",
      "name": "foo1",
      "type": "Microsoft.Compute/virtualMachines",
      "location": "westus",
      "properties": {
        "storageProfile": {
          "imageReference": {
            "publisher": "MicrosoftWindowsServer",
            "offer": "WindowsServer",
            "sku": "2008-R2-SP1",
            "version": "latest"
          },
          "osDisk": {
            "osType": "Windows",
            "name": "foo1",
            "createOption": "FromImage",
            "vhd": {
              "uri": "https://foo123.blob.core.windows.net/vhds/fooimage123456.vhd"
            },
            "caching": "ReadWrite"
          },
          "dataDisks": []
        }
      }
    }'
  end

  let(:virtual_machine) { Azure::Armrest::VirtualMachine.new(@json) }

  context "constructor" do
    it "returns a VirtualMachine class as expected" do
      expect(virtual_machine).to be_kind_of(Azure::Armrest::VirtualMachine)
    end
  end

  context "properties" do
    it "returns the expected VHD file for the URI properties" do
      uri = "https://foo123.blob.core.windows.net/vhds/fooimage123456.vhd"
      expect(virtual_machine.properties.storage_profile.os_disk.vhd.uri).to eql(uri)
    end
  end

  context "custom methods" do
    it "defines a storage_account method" do
      expect(virtual_machine).to respond_to(:storage_account)
    end

    it "defines a virtual_disk method" do
      expect(virtual_machine).to respond_to(:virtual_disk)
    end
  end
end
