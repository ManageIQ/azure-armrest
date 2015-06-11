########################################################################
# virtual_machine_extension_manager_spec.rb
#
# Specs for the Azure::ArmRest::VirtualMachineExtensionManager class.
########################################################################

require 'spec_helper'

describe "VirtualMachineExtensionManager" do
  before do
    @sub = 'abc-123-def-456'
    @res = 'my_resource_group'
    @ver = '2015-1-1'
    @vmem = nil
  end

  context "inheritance" do
    it "is a subclass of VirtualMachineManager" do
      ancestors = Azure::ArmRest::VirtualMachineExtensionManager.ancestors
      ancestors.should include(Azure::ArmRest::VirtualMachineManager)
    end
  end

  context "constructor" do
    it "returns a vmem instance as expected" do
      @vmem = Azure::ArmRest::VirtualMachineExtensionManager.new(@sub, @res, @ver)
      @vmem.should be_kind_of(Azure::ArmRest::VirtualMachineExtensionManager)
    end

    it "requires at least two arguments" do
      expect{ Azure::ArmRest::VirtualMachineExtensionManager.new }.to raise_error(ArgumentError)
      expect{ Azure::ArmRest::VirtualMachineExtensionManager.new(@sub) }.to raise_error(ArgumentError)
    end

    it "accepts up to three arguments" do
      expect{ Azure::ArmRest::VirtualMachineExtensionManager.new(@sub, @res, @ver, @ver) }.to raise_error(ArgumentError)
    end

    it "sets the api_version to the expected default value if none is provided" do
      @vmem = Azure::ArmRest::VirtualMachineExtensionManager.new(@sub, @res)
      @vmem.api_version.should eql("2015-1-1")
    end
  end

  context "accessors" do
    before{ @vmem = Azure::ArmRest::VirtualMachineExtensionManager.new(@sub, @res, @ver) }

    it "defines a uri accessor" do
      @vmem.should respond_to(:uri)
      @vmem.should respond_to(:uri=)
    end
  end

  context "instance methods" do
    before{ @vmem = Azure::ArmRest::VirtualMachineExtensionManager.new(@sub, @res, @ver) }

    it "defines a create method" do
      @vmem.should respond_to(:create)
    end

    it "defines an update alias" do
      @vmem.should respond_to(:update)
      @vmem.method(:update).should eql(@vmem.method(:create))
    end

    it "defines a delete method" do
      @vmem.should respond_to(:delete)
    end

    it "defines a get method" do
      @vmem.should respond_to(:get)
    end

    it "defines a list method" do
      @vmem.should respond_to(:list)
    end
  end
end
