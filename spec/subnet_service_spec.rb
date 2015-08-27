########################################################################
# subnet_service_spec.rb
#
# Test suite for the Azure::Armrest::SubnetService class.
########################################################################
require 'spec_helper'

describe "SubnetService" do
  before { setup_params }
  let(:sns) { Azure::Armrest::SubnetService.new(@conf) }

  context "inheritance" do
    it "is a subclass of VirtualNetworkService" do
      ancestors = Azure::Armrest::SubnetService.ancestors
      expect(ancestors).to include(Azure::Armrest::VirtualNetworkService)
    end
  end

  context "constructor" do
    it "returns a SS instance as expected" do
      expect(sns).to be_kind_of(Azure::Armrest::SubnetService)
    end

    it "sets the default uri to the expected value" do
      expected = "https://management.azure.com"
      expected << "/resourceGroups/#{@res}/providers/Microsoft.Network/virtualNetworks/subnets"
      expect(sns.base_url).to eq(expected)
    end
  end

  context "accessors" do
    it "defines a base_url accessor" do
      expect(sns).to respond_to(:base_url)
      expect(sns).to respond_to(:base_url=)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(sns).to respond_to(:create)
    end

    it "defines a delete method" do
      expect(sns).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(sns).to respond_to(:get)
    end

    it "defines a stop method" do
      expect(sns).to respond_to(:list)
    end
  end
end
