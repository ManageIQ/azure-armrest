########################################################################
# test_virtual_network_manager.rb
#
# Test suite for the Azure::Armrest::VirtualNetworkManager class.
########################################################################

require 'spec_helper'

describe "VirtualNetworkManager" do
  before { setup_params }
  let(:vnm) { Azure::Armrest::VirtualNetworkManager.new(@params) }

  context "inheritance" do
    it "is a subclass of ArmrestManager" do
      Azure::Armrest::VirtualNetworkManager.ancestors.should include(Azure::Armrest::ArmrestManager)
    end
  end

  context "constructor" do
    it "returns a vnm instance as expected" do
      vnm.should be_kind_of(Azure::Armrest::VirtualNetworkManager)
    end

    it "sets the default uri to the expected value" do
      expected = "https://management.azure.com"
      expected << "/resourceGroups/#{@res}/providers/Microsoft.Network/virtualNetworks"
      vnm.base_url.should eql(expected)
    end
  end

  context "accessors" do
    it "defines a base_url accessor" do
      vnm.should respond_to(:base_url)
      vnm.should respond_to(:base_url=)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      vnm.should respond_to(:create)
    end

    it "defines a delete method" do
      vnm.should respond_to(:delete)
    end

    it "defines a get method" do
      vnm.should respond_to(:get)
    end

    it "defines a stop method" do
      vnm.should respond_to(:list)
    end
  end
end
