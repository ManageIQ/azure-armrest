###########################################################################
# test_virtual_network_service.rb
#
# Test suite for the Azure::Armrest::Network::VirtualNetworkService class.
###########################################################################
require 'spec_helper'

describe "Network::VirtualNetworkService" do
  before { setup_params }
  let(:vns) { Azure::Armrest::Network::VirtualNetworkService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::Network::VirtualNetworkService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a Network::VirtualNetworkService instance as expected" do
      expect(vns).to be_kind_of(Azure::Armrest::Network::VirtualNetworkService)
    end
  end

  context "accessors" do
    it "defines a base_url accessor" do
      expect(vns).to respond_to(:base_url)
      expect(vns).to respond_to(:base_url=)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(vns).to respond_to(:create)
    end

    it "defines a delete method" do
      expect(vns).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(vns).to respond_to(:get)
    end

    it "defines a list method" do
      expect(vns).to respond_to(:list)
    end

    it "defines a list_all_for_subscription method" do
      expect(vns).to respond_to(:list_all_for_subscription)
    end
  end
end
