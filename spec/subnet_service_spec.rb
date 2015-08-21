########################################################################
# subnet_service_spec.rb
#
# Test suite for the Azure::Armrest::SubnetService class.
########################################################################
require 'spec_helper'

describe "SubnetService" do
  before { setup_params }
  let(:snm) { Azure::Armrest::SubnetService.new(@params) }

  context "inheritance" do
    it "is a subclass of VirtualNetworkService" do
      ancestors = Azure::Armrest::SubnetService.ancestors
      expect(ancestors).to include(Azure::Armrest::VirtualNetworkService)
    end
  end

  context "constructor" do
    it "returns a vnm instance as expected" do
      expect(snm).to be_kind_of(Azure::Armrest::SubnetService)
    end

    it "sets the default uri to the expected value" do
      expected = "https://management.azure.com"
      expected << "/resourceGroups/#{@res}/providers/Microsoft.Network/virtualNetworks/subnets"
      expect(snm.base_url).to eq(expected)
    end
  end

  context "accessors" do
    it "defines a base_url accessor" do
      expect(snm).to respond_to(:base_url)
      expect(snm).to respond_to(:base_url=)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(snm).to respond_to(:create)
    end

    it "defines a delete method" do
      expect(snm).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(snm).to respond_to(:get)
    end

    it "defines a stop method" do
      expect(snm).to respond_to(:list)
    end
  end
end
