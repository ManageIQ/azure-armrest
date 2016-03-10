########################################################################
# virtual_machine_model_spec.rb
#
# Test suite for the Azure::Armrest::VirtualMachineModel  model class.
########################################################################
require 'spec_helper'

describe "VirtualMachineModel" do
  let(:json) do
    '{
        "id": "/subscriptions/########-####-####-####-############/resourceGroups/{resourceGroupName}/providers/Microsoft.Compute/virtualMachines/{virtualMachineName}",
        "name": "virtualMachineName",
        "type": "Microsoft.Compute/virtualMachines",
        "location": "westus",
        "tags": {
          "department": "finance"
        },
        "properties": {
          "licenseType": "Windows_Server",
          "availabilitySet": {
            "id": "/subscriptions/########-####-####-####-############/resourceGroups/{resourceGroupName}/providers/Microsoft.Compute/availabilitySets/{availabilitySetName}"
          },
          "hardwareProfile": {
            "vmSize": "Standard_A0"
          },
          "storageProfile": {
            "imageReference": {
              "publisher": "MicrosoftWindowsServerEssentials",
              "offer": "WindowsServerEssentials",
              "sku": "WindowsServerEssentials",
              "version": "1.0.131018"
            },
            "osDisk": {
              "osType": "Windows",
              "name": "osName-osDisk",
              "vhd": {
                "uri": "http://storageAccount.blob.core.windows.net/vhds/osDisk.vhd"
              },
              "caching": "ReadWrite",
              "createOption": "FromImage"
            },
            "dataDisks": [

            ]
          },
          "osProfile": {
            "computerName": "virtualMachineName",
            "adminUsername": "username",
            "adminPassword": "password",
            "customData": "",
            "windowsConfiguration": {
              "provisionVMAgent": true,
              "winRM": {
                "listeners": [{}]
              },
              "additionalUnattendContent": [{
                "pass": "oobesystem",
                "component": "Microsoft-Windows-Shell-Setup",
                "settingName": "FirstLogonCommands|AutoLogon",
                "content": "<XML unattend content>",
                "enableAutomaticUpdates": true
              }],
              "secrets": [

              ]
              }
            },
            "networkProfile": {
              "networkInterfaces": [{
                "id": "/subscriptions/########-####-####-####-############/resourceGroups/CloudDep/providers/Microsoft.Network/networkInterfaces/myNic"
              }]
            },
            "provisioningState": "succeeded"
          }
      } '
  end

  let(:hash) do
    {
      :id => "/subscriptions/########-####-####-####-############/resourceGroups/{resourceGroupName}/providers/Microsoft.Compute/virtualMachines/{virtualMachineName}",
      :name => "virtualMachineName",
        :type => "Microsoft.Compute/virtualMachines",
        :location => "westus",
        :tags => {
          :department => "finance"
        },
        :properties => {
          :licenseType => "Windows_Server",
          :availabilitySet => {
            :id => "/subscriptions/########-####-####-####-############/resourceGroups/{resourceGroupName}/providers/Microsoft.Compute/availabilitySets/{availabilitySetName}"
          },
          :hardwareProfile => {
            :vmSize => "Standard_A0"
          },
          :storageProfile => {
            :imageReference => {
              :publisher => "MicrosoftWindowsServerEssentials",
              :offer => "WindowsServerEssentials",
              :sku => "WindowsServerEssentials",
              :version => "1.0.131018"
            },
            :osDisk => {
              :osType => "Windows",
              :name => "osName-osDisk",
              :vhd => {
                :uri => "http://storageAccount.blob.core.windows.net/vhds/osDisk.vhd"
              },
              :caching => "ReadWrite",
              :createOption => "FromImage"
            },
            :dataDisks => [

            ]
          },
          :osProfile => {
            :computerName => "virtualMachineName",
            :adminUsername => "username",
            :adminPassword => "password",
            :customData => "",
            :windowsConfiguration => {
              :provisionVMAgent => true,
              :winRM => {
                :listeners => [{}]
              },
              :additionalUnattendContent => [{
                :pass => "oobesystem",
                :component => "Microsoft-Windows-Shell-Setup",
                :settingName => "FirstLogonCommands|AutoLogon",
                :content => "<XML unattend content>",
                :enableAutomaticUpdates => true
              }],
              :secrets => [
              ]
            }
          },
          :networkProfile => {
            :networkInterfaces => [{
              :id => "/subscriptions/########-####-####-####-############/resourceGroups/CloudDep/providers/Microsoft.Network/networkInterfaces/myNic"
            }]
          },
          :provisioningState => "succeeded"
        }
    }
  end

  before { setup_params }
  let(:vms) { Azure::Armrest::VirtualMachineModel.new(@conf) }
  let(:base) { Azure::Armrest::VirtualMachineModel.new(hash) }

  context "constructor" do
    it "constructs a VirtualMachineModel instance from a hash" do
      expect(base).to be_kind_of(Azure::Armrest::VirtualMachineModel)
    end
  end

  context "custom methods" do
  end
end
