###########################################################################
# test_load_balancer_service.rb
#
# Test suite for the Azure::Armrest::Network::LoadBalancerService class.
###########################################################################
require 'spec_helper'

describe "Network::LoadBalancerService" do
  before { setup_params }
  let(:vns) { Azure::Armrest::Network::LoadBalancerService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::Network::LoadBalancerService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a Network::LoadBalancerService instance as expected" do
      expect(vns).to be_kind_of(Azure::Armrest::Network::LoadBalancerService)
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

    it "defines a list_all" do
      expect(vns).to respond_to(:list_all)
    end
  end
end
