########################################################################
# resource_provider_manager_spec.rb
#
# Test suite for the Azure::Armrest::ResourceProviderManager class.
########################################################################
require 'spec_helper'

describe "ResourceProviderManager" do
  before { setup_params }
  let(:rpmgr) { Azure::Armrest::ResourceProviderManager.new(@params) }

  context "inheritance" do
    it "is a subclass of ArmrestManager" do
      expect(Azure::Armrest::ResourceProviderManager.ancestors).to include(Azure::Armrest::ArmrestManager)
    end
  end

  context "constructor" do
    it "returns a rpmgr instance as expected" do
      expect(rpmgr).to be_kind_of(Azure::Armrest::ResourceProviderManager)
    end
  end

  context "accessors" do
    it "defines a provider method" do
      expect(rpmgr).to respond_to(:provider)
    end

    it "sets the default provider to the expected value" do
      expect(rpmgr.provider).to eq "Microsoft.Resources"
    end
  end

  context "instance methods" do
    it "defines a list method" do
      expect(rpmgr).to respond_to(:list)
    end

    it "defines a get_provider method" do
      expect(rpmgr).to respond_to(:get_provider)
    end

    it "defines a geo_locations method" do
      expect(rpmgr).to respond_to(:geo_locations)
    end

    it "defines a api_versions method" do
      expect(rpmgr).to respond_to(:api_versions)
    end

    it "defines a register method" do
      expect(rpmgr).to respond_to(:register)
    end

    it "defines an unregister method" do
      expect(rpmgr).to respond_to(:unregister)
    end
  end
end
