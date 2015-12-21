########################################################################
# armrest_service_spec.rb
#
# Test suite for the Azure::Armrest::ArmrestService class.
########################################################################
require 'spec_helper'

describe "ArmrestService" do
  before(:all){ @@providers_hash = {'name' => {}} }
  before { setup_params }

  let(:arm) { Azure::Armrest::ArmrestService.new(@conf, 'servicename', 'provider', {}) }

  context "constructor" do
    it "returns an armrest service instance as expected" do
      expect(arm).to be_kind_of(Azure::Armrest::ArmrestService)
    end
  end

  context "methods" do
    it "defines a locations method" do
      expect(arm).to respond_to(:locations)
    end

    it "defines a providers method" do
      expect(arm).to respond_to(:providers)
    end

    it "defines a provider_info method" do
      expect(arm).to respond_to(:provider_info)
    end

    it "defines a geo_locations alias for provider_info" do
      expect(arm).to respond_to(:geo_locations)
      expect(arm.method(:geo_locations)).to eq(arm.method(:provider_info))
    end

    it "defines a resources method" do
      expect(arm).to respond_to(:resources)
    end

    it "defines a resource_groups method" do
      expect(arm).to respond_to(:resource_groups)
    end

    it "defines a resource_group_info method" do
      expect(arm).to respond_to(:resource_group_info)
    end

    it "defines a subscriptions method" do
      expect(arm).to respond_to(:subscriptions)
    end

    it "defines a subscription_info method" do
      expect(arm).to respond_to(:subscription_info)
    end

    it "defines a tags method" do
      expect(arm).to respond_to(:tags)
    end

    it "defines a tenants method" do
      expect(arm).to respond_to(:tenants)
    end
  end

  context "accessors" do
    it "defines a subscription_id accessor" do
      expect(arm.armrest_configuration).to respond_to(:subscription_id)
      expect(arm.armrest_configuration).to respond_to(:subscription_id=)
      expect(arm.armrest_configuration.subscription_id).to eq(@sub)
    end

    it "defines a resource_group accessor" do
      expect(arm.armrest_configuration).to respond_to(:resource_group)
      expect(arm.armrest_configuration).to respond_to(:resource_group=)
      expect(arm.armrest_configuration.resource_group).to eq(@res)
    end

    it "defines a api_version accessor" do
      expect(arm.armrest_configuration).to respond_to(:api_version)
      expect(arm.armrest_configuration).to respond_to(:api_version=)
      expect(arm.armrest_configuration.api_version).to eq(@ver)
    end

    it "defines a base_url accessor" do
      expect(arm).to respond_to(:base_url)
      expect(arm).to respond_to(:base_url=)
      expect(arm.base_url).to eq(Azure::Armrest::RESOURCE)
    end

    it "defines a token accessor" do
      expect(arm.armrest_configuration).to respond_to(:token)
      expect(arm.armrest_configuration).to respond_to(:token=)
      expect(arm.armrest_configuration.token).to eq(@tok)
    end

    it "defines a content_type reader" do
      expect(arm.armrest_configuration).to respond_to(:content_type)
      expect(arm.armrest_configuration.content_type).to eq('application/json')
    end

    it "defines a grant_type reader" do
      expect(arm.armrest_configuration).to respond_to(:grant_type)
      expect(arm.armrest_configuration.grant_type).to eq('client_credentials')
    end
  end

  context "api exception handling" do
    it "converts exception from rest_get" do
      expect(RestClient).to receive(:get).and_raise(RestClient::Exception.new)
      expect{ Azure::Armrest::ArmrestService.rest_get('') }.to raise_error(Azure::Armrest::ApiException)
    end

    it "converts exception from rest_put" do
      expect(RestClient).to receive(:put).and_raise(RestClient::Exception.new)
      expect{ Azure::Armrest::ArmrestService.rest_put('', '') }.to raise_error(Azure::Armrest::ApiException)
    end

    it "converts exception from rest_post" do
      expect(RestClient).to receive(:post).and_raise(RestClient::Exception.new)
      expect{ Azure::Armrest::ArmrestService.rest_post('', '') }.to raise_error(Azure::Armrest::ApiException)
    end

    it "converts exception from rest_patch" do
      expect(RestClient).to receive(:patch).and_raise(RestClient::Exception.new)
      expect{ Azure::Armrest::ArmrestService.rest_patch('', '') }.to raise_error(Azure::Armrest::ApiException)
    end

    it "converts exception from rest_delete" do
      expect(RestClient).to receive(:delete).and_raise(RestClient::Exception.new)
      expect{ Azure::Armrest::ArmrestService.rest_delete('') }.to raise_error(Azure::Armrest::ApiException)
    end
  end
end
