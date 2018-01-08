########################################################################
# inbound_nat_service_spec.rb
#
# Test suite for the Azure::Armrest::Network::InboundNatService class.
########################################################################
require 'spec_helper'

describe "Network::InboundNatService" do
  before { setup_params }
  let(:sns) { Azure::Armrest::Network::InboundNatService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ResourceGroupBasedSubservice" do
      ancestors = Azure::Armrest::Network::InboundNatService.ancestors
      expect(ancestors).to include(Azure::Armrest::ResourceGroupBasedSubservice)
    end
  end

  context "constructor" do
    it "returns a Network::InboundNatService instance as expected" do
      expect(sns).to be_kind_of(Azure::Armrest::Network::InboundNatService)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(sns).to respond_to(:create)
    end

    it "defines an update alias for create" do
      expect(sns).to respond_to(:update)
      expect(sns.method(:create)).to eql(sns.method(:update))
    end

    it "defines a delete method" do
      expect(sns).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(sns).to respond_to(:get)
    end

    it "defines a list method" do
      expect(sns).to respond_to(:list)
    end
  end
end
