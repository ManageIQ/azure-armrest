########################################################################
# availability_set_manager_spec.rb
#
# Test suite for the Azure::ArmRest::AvailabilitySetManager class.
########################################################################
require 'azure/armrest'
require 'rspec/autorun'

describe "AvailabilitySetManager" do
  before do
    @sub = 'abc-123-def-456'
    @res = 'my_resource_group'
    @ver = '2015-1-1'
    @asm = nil
  end

  context "inheritance" do
    it "is a subclass of ArmRestManager" do
      Azure::ArmRest::AvailabilitySetManager.ancestors.should include(Azure::ArmRest::ArmRestManager)
    end
  end

  context "constructor" do
    it "returns a vnm instance as expected" do
      @asm = Azure::ArmRest::AvailabilitySetManager.new(@sub, @res, @ver)
      @asm.should be_kind_of(Azure::ArmRest::AvailabilitySetManager)
    end

    it "requires at least two arguments" do
      expect{ Azure::ArmRest::AvailabilitySetManager.new }.to raise_error(ArgumentError)
      expect{ Azure::ArmRest::AvailabilitySetManager.new(@sub) }.to raise_error(ArgumentError)
    end

    it "accepts up to three arguments" do
      expect{ Azure::ArmRest::AvailabilitySetManager.new(@sub, @res, @ver, @ver) }.to raise_error(ArgumentError)
    end

    it "sets the api_version to the expected default value if none is provided" do
      @asm = Azure::ArmRest::AvailabilitySetManager.new(@sub, @res)
      @asm.api_version.should eql("2015-1-1")
    end

    it "sets the default uri to the expected value" do
      expected = "https://management.azure.com/subscriptions/#{@sub}"
      expected << "/resourceGroups/#{@res}/providers/Microsoft.Compute/availabilitySets"
      @asm = Azure::ArmRest::AvailabilitySetManager.new(@sub, @res)
      @asm.uri.should eql(expected)
    end
  end

  context "accessors" do
    before(:each){ @asm = Azure::ArmRest::AvailabilitySetManager.new(@sub, @res, @ver) }

    it "defines a uri accessor" do
      @asm.should respond_to(:uri)
      @asm.should respond_to(:uri=)
    end

    after(:each){ @asm = nil }
  end

  context "instance methods" do
    before(:each){ @asm = Azure::ArmRest::AvailabilitySetManager.new(@sub, @res, @ver) }

    it "defines a create method" do
      @asm.should respond_to(:create)
    end

    it "defines an update alias" do
      @asm.should respond_to(:update)
      @asm.method(:update).should eql(@asm.method(:create))
    end

    it "defines a delete method" do
      @asm.should respond_to(:delete)
    end

    it "defines a get method" do
      @asm.should respond_to(:get)
    end

    it "defines a stop method" do
      @asm.should respond_to(:list)
    end

    after(:each){ @asm = nil }
  end

  after do
    @sub = nil
    @res = nil
    @ver = nil
    @asm = nil
  end
end
