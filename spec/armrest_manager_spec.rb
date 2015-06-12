########################################################################
# armrest_manager_manager_spec.rb
#
# Test suite for the Azure::ArmRest::ArmRestManager class.
########################################################################

require 'spec_helper'

describe "ArmRestManager" do
  before { setup_params }
  let(:arm) { Azure::ArmRest::ArmRestManager.new(@params) }

  context "constructor" do
    it "returns an armrest manager instance as expected" do
      expect(arm).to be_kind_of(Azure::ArmRest::ArmRestManager)
    end
  end

  context "accessors" do
    it "defines a subscription_id accessor" do
      expect(arm).to respond_to(:subscription_id)
      expect(arm).to respond_to(:subscription_id=)
      expect(arm.subscription_id).to eq(@sub)
    end

    it "defines a resource_group accessor" do
      expect(arm).to respond_to(:resource_group)
      expect(arm).to respond_to(:resource_group=)
      expect(arm.resource_group).to eq(@res)
    end

    it "defines a api_version accessor" do
      expect(arm).to respond_to(:api_version)
      expect(arm).to respond_to(:api_version=)
      expect(arm.api_version).to eq(@ver)
    end

    it "defines a base_url accessor" do
      expect(arm).to respond_to(:base_url)
      expect(arm).to respond_to(:base_url=)
      expect(arm.base_url).to eq(Azure::ArmRest::RESOURCE)
    end

    it "defines a token accessor" do
      expect(arm).to respond_to(:token)
      expect(arm).to respond_to(:token=)
      expect(arm.token).to eq(nil)
    end

    it "defines a content_type reader" do
      expect(arm).to respond_to(:content_type)
      expect(arm.content_type).to eq('application/json')
    end

    it "defines a grant_type reader" do
      expect(arm).to respond_to(:grant_type)
      expect(arm.grant_type).to eq('client_credentials')
    end
  end
end
