########################################################################
# test_virtual_machine_manager.rb
#
# Test suite for the Azure::ArmRest::VirtualMachineManager class.
########################################################################
require 'azure/armrest'
require 'rspec/autorun'

describe "VirtualMachineManager" do
  before do
    @sub = 'abc-123-def-456'
    @res = 'my_resource_group'
    @ver = '2015-1-1'
    @vmm = nil
  end

  context "constructor" do
    it "returns a vmm instance as expected" do
      @vmm = Azure::ArmRest::VirtualMachineManager.new(@sub, @res, @ver)
      @vmm.should be_kind_of(Azure::ArmRest::VirtualMachineManager)
    end

    it "requires at least two arguments" do
      expect{ Azure::ArmRest::VirtualMachineManager.new }.to raise_error(ArgumentError)
      expect{ Azure::ArmRest::VirtualMachineManager.new(@sub) }.to raise_error(ArgumentError)
    end

    it "accepts up to three arguments" do
      expect{ Azure::ArmRest::VirtualMachineManager.new(@sub, @res, @ver, @ver) }.to raise_error(ArgumentError)
    end

    it "sets the api_version to the expected default value if none is provided" do
      @vmm = Azure::ArmRest::VirtualMachineManager.new(@sub, @res)
      @vmm.api_version.should eql("2015-1-1")
    end
  end

  after do
    @sub = nil
    @res = nil
    @ver = nil
    @vmm = nil
  end
end
