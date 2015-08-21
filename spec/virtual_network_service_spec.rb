########################################################################
# test_virtual_network_service.rb
#
# Test suite for the Azure::Armrest::VirtualNetworkService class.
########################################################################
require 'spec_helper'

describe "VirtualNetworkService" do
  before { setup_params }
  let(:vnm) { Azure::Armrest::VirtualNetworkService.new(@params) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::VirtualNetworkService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a vnm instance as expected" do
      expect(vnm).to be_kind_of(Azure::Armrest::VirtualNetworkService)
    end

    it "sets the default uri to the expected value" do
      expected = "https://management.azure.com"
      expected << "/resourceGroups/#{@res}/providers/Microsoft.Network/virtualNetworks"
      expect(vnm.base_url).to eql(expected)
    end
  end

  context "accessors" do
    it "defines a base_url accessor" do
      expect(vnm).to respond_to(:base_url)
      expect(vnm).to respond_to(:base_url=)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(vnm).to respond_to(:create)
    end

    it "defines a delete method" do
      expect(vnm).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(vnm).to respond_to(:get)
    end

    it "defines a stop method" do
      expect(vnm).to respond_to(:list)
    end
  end
end
