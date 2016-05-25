########################################################################
# armrest_service_spec.rb
#
# Test suite for the Azure::Armrest::ArmrestService class.
########################################################################
require 'spec_helper'

describe Azure::Armrest::ArmrestService do
  before { setup_params }

  subject { described_class.new(@conf, 'servicename', 'provider', {}) }

  context "constructor" do
    it "returns an armrest service instance as expected" do
      expect(subject).to be_kind_of(Azure::Armrest::ArmrestService)
    end
  end

  context "instance methods" do
    it "defines a locations method" do
      expect(subject).to respond_to(:locations)
    end

    it "defines a providers method" do
      expect(subject).to respond_to(:providers)
    end

    it "defines a provider_info method" do
      expect(subject).to respond_to(:provider_info)
    end

    it "defines a provider_info alias for get_provider" do
      expect(subject).to respond_to(:provider_info)
    end

    it "defines a resources method" do
      expect(subject).to respond_to(:resources)
    end

    it "defines a resource_groups method" do
      expect(subject).to respond_to(:resource_groups)
    end

    it "defines a subscriptions method" do
      expect(subject).to respond_to(:subscriptions)
    end

    it "defines a subscription_info method" do
      expect(subject).to respond_to(:subscription_info)
    end

    it "defines a tags method" do
      expect(subject).to respond_to(:tags)
    end

    it "defines a tenants method" do
      expect(subject).to respond_to(:tenants)
    end
  end

  context "delegated methods" do
    it "delegates the providers method to Azure::Armrest::Configuration" do
      expect(subject).to respond_to(:providers)
      expect(subject.providers).to be_kind_of(Array)
      expect(subject.providers.first).to be_kind_of(Azure::Armrest::ResourceProvider)
    end
  end

  context "accessors" do
    it "defines a base_url accessor" do
      expect(subject).to respond_to(:base_url)
      expect(subject).to respond_to(:base_url=)
      expect(subject.base_url).to eq(Azure::Armrest::RESOURCE)
    end
  end

  context "api exception handling" do
    it "converts exception from rest_get" do
      expect(RestClient::Request).to receive(:execute).and_raise(RestClient::Exception.new)
      expect { described_class.send(:rest_get, :url => '') }.to raise_error(Azure::Armrest::ApiException)
    end

    it "converts exception from rest_put" do
      expect(RestClient::Request).to receive(:execute).and_raise(RestClient::Exception.new)
      expect { described_class.send(:rest_put, :url => '', :body => '') }.to raise_error(Azure::Armrest::ApiException)
    end

    it "converts exception from rest_post" do
      expect(RestClient::Request).to receive(:execute).and_raise(RestClient::Exception.new)
      expect { described_class.send(:rest_post, :url => '', :body => '') }.to raise_error(Azure::Armrest::ApiException)
    end

    it "converts exception from rest_patch" do
      expect(RestClient::Request).to receive(:execute).and_raise(RestClient::Exception.new)
      expect { described_class.send(:rest_patch, :url => '', :body => '') }.to raise_error(Azure::Armrest::ApiException)
    end

    it "converts exception from rest_delete" do
      expect(RestClient::Request).to receive(:execute).and_raise(RestClient::Exception.new)
      expect { described_class.send(:rest_delete, :url => '') }.to raise_error(Azure::Armrest::ApiException)
    end
  end
end
