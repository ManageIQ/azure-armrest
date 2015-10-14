#################################################################################
# network_security_group_service_spec.rb
#
# Test suite for the Azure::Armrest::Network::NetworkSecurityGroupService class.
#################################################################################
require 'spec_helper'

describe "Network::NetworkSecurityGroupService" do
  before { setup_params }
  let(:nsg) { Azure::Armrest::Network::NetworkSecurityGroupService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::Network::NetworkSecurityGroupService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a nsg instance as expected" do
      expect(nsg).to be_kind_of(Azure::Armrest::Network::NetworkSecurityGroupService)
    end
  end

  context "instance methods" do
    it "defines a get method" do
      expect(nsg).to respond_to(:get)
    end

    it "defines a list method" do
      expect(nsg).to respond_to(:list)
    end

    it "defines a list_all method" do
      expect(nsg).to respond_to(:list_all)
    end
  end
end
