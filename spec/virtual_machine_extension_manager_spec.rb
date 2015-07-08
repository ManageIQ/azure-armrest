########################################################################
# virtual_machine_extension_manager_spec.rb
#
# Specs for the Azure::Armrest::VirtualMachineExtensionManager class.
########################################################################

require 'spec_helper'

describe "VirtualMachineExtensionManager" do
  before { setup_params }
  let(:vmem) { Azure::Armrest::VirtualMachineExtensionManager.new(@params) }

  context "inheritance" do
    it "is a subclass of VirtualMachineManager" do
      ancestors = Azure::Armrest::VirtualMachineExtensionManager.ancestors
      ancestors.should include(Azure::Armrest::VirtualMachineManager)
    end
  end

  context "constructor" do
    it "returns a vmem instance as expected" do
      vmem.should be_kind_of(Azure::Armrest::VirtualMachineExtensionManager)
    end
  end

  context "accessors" do
    it "defines a base_url accessor" do
      vmem.should respond_to(:base_url)
      vmem.should respond_to(:base_url=)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      vmem.should respond_to(:create)
    end

    it "defines an update alias" do
      vmem.should respond_to(:update)
      vmem.method(:update).should eql(vmem.method(:create))
    end

    it "defines a delete method" do
      vmem.should respond_to(:delete)
    end

    it "defines a get method" do
      vmem.should respond_to(:get)
    end

    it "defines a list method" do
      vmem.should respond_to(:list)
    end
  end
end
