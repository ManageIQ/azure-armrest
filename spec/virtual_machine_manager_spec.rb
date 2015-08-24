########################################################################
# test_virtual_machine_manager.rb
#
# Test suite for the Azure::Armrest::VirtualMachineManager class.
########################################################################
require 'spec_helper'

describe "VirtualMachineManager" do
  before { setup_params }
  let(:vmm) { Azure::Armrest::VirtualMachineManager.new(@params) }

  context "inheritance" do
    it "is a subclass of ArmrestManager" do
      expect(Azure::Armrest::VirtualMachineManager.ancestors).to include(Azure::Armrest::ArmrestManager)
    end
  end

  context "constructor" do
    it "returns a vmm instance as expected" do
      expect(vmm).to be_kind_of(Azure::Armrest::VirtualMachineManager)
    end
  end

  context "accessors" do
    it "defines a base_url accessor" do
      expect(vmm).to respond_to(:base_url)
      expect(vmm).to respond_to(:base_url=)
    end
  end

  context "instance methods" do
    it "defines a capture method" do
      expect(vmm).to respond_to(:capture)
    end

    it "defines a create method" do
      expect(vmm).to respond_to(:create)
    end

    it "defines a deallocate method" do
      expect(vmm).to respond_to(:deallocate)
    end

    it "defines a delete method" do
      expect(vmm).to respond_to(:delete)
    end

    it "defines a generalize method" do
      expect(vmm).to respond_to(:generalize)
    end

    it "defines a get method" do
      expect(vmm).to respond_to(:get)
    end

    it "defines an restart method" do
      expect(vmm).to respond_to(:restart)
    end

    it "defines a start method" do
      expect(vmm).to respond_to(:start)
    end

    it "defines a stop method" do
      expect(vmm).to respond_to(:stop)
    end
  end

  context "private methods" do
    it "does not make internal methods public" do
      expect(vmm).not_to respond_to(:add_network_profile)
      expect(vmm).not_to respond_to(:get_nic_profile)
      expect(vmm).not_to respond_to(:add_power_status)
      expect(vmm).not_to respond_to(:build_url)
    end
  end
end
