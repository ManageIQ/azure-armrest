########################################################################
# virtual_machine_instance_spec.rb
#
# Test suite for the Azure::Armrest::VirtualMachineInstance model class.
########################################################################
require 'spec_helper'

describe "VirtualMachineInstance" do
  let(:json) do
    '{
      "platformUpdateDomain": 0,
      "platformFaultDomain": 0,
      "vmAgent": {
        "vmAgentVersion": "2.5.1198.709",
        "statuses": [
          {
            "code": "ProvisioningState/succeeded",
            "level": "Info",
            "displayStatus": "Ready",
            "message": "GuestAgent is running and accepting new configurations.",
            "time": "2015-04-21T11:42:44-07:00"
          }
        ]
      },
      "disks": [
        {
          "name": "msvm-os-20150410-074408-487548",
          "statuses": [
            {
              "code": "ProvisioningState/succeeded",
              "level": "Info",
              "displayStatus": "Provisioning succeeded",
              "time": "2015-04-10T12:44:10.4562812-07:00"
            }
          ]
        }
      ],
      "statuses": [
        {
          "code": "ProvisioningState/succeeded",
          "level": "Info",
          "displayStatus": "Provisioning succeeded",
          "time": "2015-04-10T12:50:09.0031588-07:00"
        },
        {
          "code": "PowerState/running",
          "level": "Info",
          "displayStatus": "VM running"
        }
      ]
    }'
  end

    let(:hash) do
      {
        platformUpdateDomain: 0,
        platformFaultDomain: 0,
        vmAgent: {
          vmAgentVersion: "2.5.1198.709",
          statuses: [
            {
              code: "ProvisioningState/succeeded",
              level: "Info",
              displayStatus: "Ready",
              message: "GuestAgent is running and accepting new configurations.",
              time: "2015-04-21T11:42:44-07:00"
            }
          ]
        },
        disks: [
          {
            name: "msvm-os-20150410-074408-487548",
            statuses: [
              {
                code: "ProvisioningState/succeeded",
                level: "Info",
                displayStatus: "Provisioning succeeded",
                time: "2015-04-10T12:44:10.4562812-07:00"
              }
            ]
          }
        ],
        statuses: [
          {
            code: "ProvisioningState/succeeded",
            level: "Info",
            displayStatus: "Provisioning succeeded",
            time: "2015-04-10T12:50:09.0031588-07:00"
          },
          {
            code: "PowerState/running",
            level: "Info",
            displayStatus: "VM running"
          }
        ]
      }
    end

    before { setup_params }
    let(:vms) { Azure::Armrest::VirtualMachineService.new(@conf) }
    let(:base) { Azure::Armrest::VirtualMachineInstance.new(hash, vms) }

    context "constructor" do
      it "constructs a VirtualMachineInstance instance from a hash" do
        expect(base).to be_kind_of(Azure::Armrest::VirtualMachineInstance)
      end
    end

    context "custom methods" do
    end
  end
