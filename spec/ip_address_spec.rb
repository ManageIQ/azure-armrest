########################################################################
# ip_address_service_spec.rb
#
# Test suite for the Azure::Armrest::ResourceService class.
########################################################################
require 'spec_helper'

describe "Network::IpAddressService" do
  before { setup_params }
  let(:ip) { Azure::Armrest::Network::IpAddressService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::Network::IpAddressService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a ip instance as expected" do
      expect(ip).to be_kind_of(Azure::Armrest::Network::IpAddressService)
    end
  end

  context "instance methods" do
    it "defines a get method" do
      expect(ip).to respond_to(:get)
    end

    it "defines a get_ip method" do
      expect(ip).to respond_to(:get_ip)
    end

    it "defines a list method" do
      expect(ip).to respond_to(:list)
    end

    it "defines a list_all_for_subscription method" do
      expect(ip).to respond_to(:list_all_for_subscription)
    end

    it "defines a list_all alias method" do
      expect(ip).to respond_to(:list_all)
      expect(ip.method(:list_all)).to eql(ip.method(:list_all_for_subscription))
    end
  end
end
