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
    it "defines a create_resource_group method" do
      expect(rgsrv).to respond_to(:create_resource_group)
    end

    it "defines a delete_resource_group method" do
      expect(rgsrv).to respond_to(:delete_resource_group)
    end

    it "defines a get_resource_group method" do
      expect(rgsrv).to respond_to(:get_resource_group)
    end

    it "defines a list method" do
      expect(rgsrv).to respond_to(:list)
    end

    it "defines an update_resource_group method" do
      expect(rgsrv).to respond_to(:update_resource_group)
    end
  end
end
