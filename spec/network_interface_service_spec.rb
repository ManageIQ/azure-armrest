#############################################################################
# network_interface_service_spec.rb
#
# Test suite for the Azure::Armrest::Network::NetworkInterfaceService class.
#############################################################################
require 'spec_helper'

describe "Network::NetworkInterfaceService" do
  before { setup_params }
  let(:nis) { Azure::Armrest::Network::NetworkInterfaceService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::Network::NetworkInterfaceService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a NetworkInterfaceService instance as expected" do
      expect(nis).to be_kind_of(Azure::Armrest::Network::NetworkInterfaceService)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(nis).to respond_to(:create)
    end

    it "defines the update alias" do
      expect(nis).to respond_to(:update)
      expect(nis.method(:update)).to eql(nis.method(:create))
    end

    it "defines a delete method" do
      expect(nis).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(nis).to respond_to(:get)
    end

    it "defines a list method" do
      expect(nis).to respond_to(:list)
    end

    it "defines a list_all method" do
      expect(nis).to respond_to(:list_all)
    end
  end

  context "create" do
    it "requires an interface name" do
      expect{ nis.create }.to raise_error(ArgumentError)
    end
  end
end
