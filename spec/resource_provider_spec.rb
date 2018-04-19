########################################################################
# resource_provider_service_spec.rb
#
# Test suite for the Azure::Armrest::ResourceProviderService class.
########################################################################
require 'spec_helper'

describe "ResourceProviderService" do
  before { setup_params }
  let(:rpsrv) { Azure::Armrest::ResourceProviderService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::ResourceProviderService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a rpsrv instance as expected" do
      expect(rpsrv).to be_kind_of(Azure::Armrest::ResourceProviderService)
    end
  end

  context "accessors" do
    it "defines a provider method" do
      expect(rpsrv).to respond_to(:provider)
    end

    it "sets the default provider to the expected value" do
      expect(rpsrv.provider).to eq "Microsoft.Resources"
    end
  end

  context "instance methods" do
    it "defines a list method" do
      expect(rpsrv).to respond_to(:list)
    end

    it "defines a list_all method" do
      expect(rpsrv).to respond_to(:list_all)
    end

    it "defines a get method" do
      expect(rpsrv).to respond_to(:get)
    end

    it "defines a list_geo_locations method" do
      expect(rpsrv).to respond_to(:list_geo_locations)
    end

    it "defines a list_api_versions method" do
      expect(rpsrv).to respond_to(:list_api_versions)
    end

    it "defines a register method" do
      expect(rpsrv).to respond_to(:register)
    end

    it "defines an unregister method" do
      expect(rpsrv).to respond_to(:unregister)
    end

    it "defines a registered? method" do
      expect(rpsrv).to respond_to(:registered?)
    end

    it "defines a supported? method" do
      expect(rpsrv).to respond_to(:supported?)
    end
  end
end
