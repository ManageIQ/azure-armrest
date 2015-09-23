########################################################################
# network_interface_service_spec.rb
#
# Test suite for the Azure::Armrest::NetworkInterfaceService class.
########################################################################
require 'spec_helper'

describe "NetworkInterfaceService" do
  before { setup_params }
  let(:sas) { Azure::Armrest::NetworkInterfaceService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::NetworkInterfaceService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a SAS instance as expected" do
      expect(sas).to be_kind_of(Azure::Armrest::NetworkInterfaceService)
    end
  end

  context "accessors" do
    it "defines a base_url accessor" do
      expect(sas).to respond_to(:base_url)
      expect(sas).to respond_to(:base_url=)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(sas).to respond_to(:create)
    end

    it "defines the update alias" do
      expect(sas).to respond_to(:update)
      expect(sas.method(:update)).to eql(sas.method(:create))
    end

    it "defines a delete method" do
      expect(sas).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(sas).to respond_to(:get)
    end

    it "defines a list method" do
      expect(sas).to respond_to(:list)
    end

    it "defines a list_all_for_subscription method" do
      expect(sas).to respond_to(:list_all_for_subscription)
    end

    it "defines a list_all alias for list_all_for_subscription" do
      expect(sas.method(:list_all)).to eql(sas.method(:list_all_for_subscription))
    end
  end

  context "create" do
    it "requires an interface name" do
      expect{ sas.create }.to raise_error(ArgumentError)
    end
  end
end
