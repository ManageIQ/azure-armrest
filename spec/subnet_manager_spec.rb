########################################################################
# subnet_manager_spec.rb
#
# Test suite for the Azure::ArmRest::SubnetManager class.
########################################################################

require 'spec_helper'

describe "SubnetManager" do
  before do
    @sub = 'abc-123-def-456'
    @res = 'my_resource_group'
    @ver = '2015-1-1'
    @vnm = nil
  end

  context "inheritance" do
    it "is a subclass of VirtualNetworkManager" do
      ancestors = Azure::ArmRest::SubnetManager.ancestors
      ancestors.should include(Azure::ArmRest::VirtualNetworkManager)
    end
  end

  context "constructor" do
    it "returns a vnm instance as expected" do
      @vnm = Azure::ArmRest::SubnetManager.new(@sub, @res, @ver)
      @vnm.should be_kind_of(Azure::ArmRest::SubnetManager)
    end

    it "requires at least two arguments" do
      expect{ Azure::ArmRest::SubnetManager.new }.to raise_error(ArgumentError)
      expect{ Azure::ArmRest::SubnetManager.new(@sub) }.to raise_error(ArgumentError)
    end

    it "accepts up to three arguments" do
      expect{ Azure::ArmRest::SubnetManager.new(@sub, @res, @ver, @ver) }.to raise_error(ArgumentError)
    end

    it "sets the api_version to the expected default value if none is provided" do
      @vnm = Azure::ArmRest::SubnetManager.new(@sub, @res)
      @vnm.api_version.should eql("2015-1-1")
    end

    it "sets the default uri to the expected value" do
      expected = "https://management.azure.com/subscriptions/#{@sub}"
      expected << "/resourceGroups/#{@res}/providers/Microsoft.Network/virtualNetworks/subnets"
      @vnm = Azure::ArmRest::SubnetManager.new(@sub, @res)
      @vnm.uri.should eql(expected)
    end
  end

  context "accessors" do
    before(:each){ @vnm = Azure::ArmRest::SubnetManager.new(@sub, @res, @ver) }

    it "defines a uri accessor" do
      @vnm.should respond_to(:uri)
      @vnm.should respond_to(:uri=)
    end

    after(:each){ @vnm = nil }
  end

  context "instance methods" do
    before(:each){ @vnm = Azure::ArmRest::SubnetManager.new(@sub, @res, @ver) }

    it "defines a create method" do
      @vnm.should respond_to(:create)
    end

    it "defines a delete method" do
      @vnm.should respond_to(:delete)
    end

    it "defines a get method" do
      @vnm.should respond_to(:get)
    end

    it "defines a stop method" do
      @vnm.should respond_to(:list)
    end

    after(:each){ @vnm = nil }
  end

  after do
    @sub = nil
    @res = nil
    @ver = nil
    @vnm = nil
  end
end
