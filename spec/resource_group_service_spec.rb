########################################################################
# resource_group_service_spec.rb
#
# Test suite for the Azure::Armrest::ResourceService class.
########################################################################
require 'spec_helper'

describe "ResourceGroupService" do
  before { setup_params }
  let(:rgsrv) { Azure::Armrest::ResourceGroupService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::ResourceGroupService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a rgsrv instance as expected" do
      expect(rgsrv).to be_kind_of(Azure::Armrest::ResourceGroupService)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(rgsrv).to respond_to(:create)
    end

    it "defines a delete method" do
      expect(rgsrv).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(rgsrv).to respond_to(:get)
    end

    it "defines a list method" do
      expect(rgsrv).to respond_to(:list)
    end

    it "defines an update method" do
      expect(rgsrv).to respond_to(:update)
    end
  end
end
