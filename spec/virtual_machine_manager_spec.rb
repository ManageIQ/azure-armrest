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

  context "inheritance" do
    it "is a subclass of ArmRestManager" do
      Azure::ArmRest::VirtualMachineManager.ancestors.should include(Azure::ArmRest::ArmRestManager)
    end
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

  context "constants" do
    it "defines VALID_VM_SIZES" do
      Azure::ArmRest::VirtualMachineManager::VALID_VM_SIZES.should_not be_nil
      Azure::ArmRest::VirtualMachineManager::VALID_VM_SIZES.should be_a_kind_of(Array)
      Azure::ArmRest::VirtualMachineManager::VALID_VM_SIZES.size.should eql(5)
    end
  end

  context "accessors" do
    before(:each){ @vmm = Azure::ArmRest::VirtualMachineManager.new(@sub, @res, @ver) }

    it "defines a uri accessor" do
      @vmm.should respond_to(:uri)
      @vmm.should respond_to(:uri=)
    end

    after(:each){ @vmm = nil }
  end

  context "instance methods" do
    before(:each){ @vmm = Azure::ArmRest::VirtualMachineManager.new(@sub, @res, @ver) }

    it "defines a capture method" do
      @vmm.should respond_to(:capture)
    end

    it "defines a create method" do
      @vmm.should respond_to(:create)
    end

    it "defines a deallocate method" do
      @vmm.should respond_to(:deallocate)
    end

    it "defines a delete method" do
      @vmm.should respond_to(:delete)
    end

    it "defines a generalize method" do
      @vmm.should respond_to(:generalize)
    end

    it "defines a get method" do
      @vmm.should respond_to(:get)
    end

    it "defines an operations method" do
      @vmm.should respond_to(:operations)
    end

    it "defines an restart method" do
      @vmm.should respond_to(:restart)
    end

    it "defines a start method" do
      @vmm.should respond_to(:start)
    end

    it "defines a stop method" do
      @vmm.should respond_to(:stop)
    end

    after(:each){ @vmm = nil }
  end

  after do
    @sub = nil
    @res = nil
    @ver = nil
    @vmm = nil
  end
end
