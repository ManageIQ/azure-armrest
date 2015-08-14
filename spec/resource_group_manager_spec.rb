########################################################################
# resource_group_manager_spec.rb
#
# Test suite for the Azure::Armrest::ResourceManager class.
########################################################################
require 'spec_helper'

describe "ResourceGroupManager" do
  before { setup_params }
  let(:rgmgr) { Azure::Armrest::ResourceGroupManager.new(@params) }

  context "inheritance" do
    it "is a subclass of ArmrestManager" do
      expect(Azure::Armrest::ResourceGroupManager.ancestors).to include(Azure::Armrest::ArmrestManager)
    end
  end

  context "constructor" do
    it "returns a rgmgr instance as expected" do
      expect(rgmgr).to be_kind_of(Azure::Armrest::ResourceGroupManager)
    end
  end

  context "instance methods" do
    it "defines a create_resource_group method" do
      expect(rgmgr).to respond_to(:create_resource_group)
    end

    it "defines a delete_resource_group method" do
      expect(rgmgr).to respond_to(:delete_resource_group)
    end

    it "defines a get_resource_group method" do
      expect(rgmgr).to respond_to(:get_resource_group)
    end

    it "defines a list method" do
      expect(rgmgr).to respond_to(:list)
    end

    it "defines an update_resource_group method" do
      expect(rgmgr).to respond_to(:update_resource_group)
    end
  end
end
