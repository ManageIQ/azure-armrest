########################################################################
# network_security_group_service_spec.rb
#
# Test suite for the Azure::Armrest::ResourceService class.
########################################################################
require 'spec_helper'

describe "NetworkSecurityGroupService" do
  before { setup_params }
  let(:nsg) { Azure::Armrest::NetworkSecurityGroupService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::NetworkSecurityGroupService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a nsg instance as expected" do
      expect(nsg).to be_kind_of(Azure::Armrest::NetworkSecurityGroupService)
    end
  end

  context "instance methods" do
    it "defines a get method" do
      expect(nsg).to respond_to(:get)
    end

    it "defines a list method" do
      expect(nsg).to respond_to(:list)
    end

    it "defines a list_all_for_subscription method" do
      expect(nsg).to respond_to(:list_all_for_subscription)
    end

    it "defines a list_all alias method" do
      expect(nsg).to respond_to(:list_all)
      expect(nsg.method(:list_all)).to eql(nsg.method(:list_all_for_subscription))
    end
  end
end
