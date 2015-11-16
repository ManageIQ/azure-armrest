#################################################################################
# network_security_group_service_spec.rb
#
# Test suite for the Azure::Armrest::Network::NetworkSecurityRuleService class.
#################################################################################
require 'spec_helper'

describe "Network::NetworkSecurityRuleService" do
  before { setup_params }
  let(:nsg) { Azure::Armrest::Network::NetworkSecurityRuleService.new(@conf) }

  context "inheritance" do
    it "is a subclass of NetworkSecurityGroupService" do
      ancestor = Azure::Armrest::Network::NetworkSecurityGroupService
      expect(Azure::Armrest::Network::NetworkSecurityRuleService.ancestors).to include(ancestor)
    end
  end

  context "constructor" do
    it "returns a nsg instance as expected" do
      expect(nsg).to be_kind_of(Azure::Armrest::Network::NetworkSecurityRuleService)
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
