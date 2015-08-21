########################################################################
# test_virtual_machine_service.rb
#
# Test suite for the Azure::Armrest::VirtualMachineService class.
########################################################################
require 'spec_helper'

describe "VirtualMachineService" do
  before { setup_params }
  let(:vms) { Azure::Armrest::VirtualMachineService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::VirtualMachineService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a VMS instance as expected" do
      expect(vms).to be_kind_of(Azure::Armrest::VirtualMachineService)
    end
  end

  context "accessors" do
    it "defines a base_url accessor" do
      expect(vms).to respond_to(:base_url)
      expect(vms).to respond_to(:base_url=)
    end
  end

  context "instance methods" do
    it "defines a capture method" do
      expect(vms).to respond_to(:capture)
    end

    it "defines a create method" do
      expect(vms).to respond_to(:create)
    end

    it "defines a deallocate method" do
      expect(vms).to respond_to(:deallocate)
    end

    it "defines a delete method" do
      expect(vms).to respond_to(:delete)
    end

    it "defines a generalize method" do
      expect(vms).to respond_to(:generalize)
    end

    it "defines a get method" do
      expect(vms).to respond_to(:get)
    end

    it "defines an restart method" do
      expect(vms).to respond_to(:restart)
    end

    it "defines a start method" do
      expect(vms).to respond_to(:start)
    end

    it "defines a stop method" do
      expect(vms).to respond_to(:stop)
    end
  end
end
