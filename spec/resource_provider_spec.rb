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

  context "list_api_versions" do
    let(:response) { IO.read('spec/fixtures/resource_api_versions.json') }
    let(:namespace) { 'Microsoft.Resources' }
    let(:service_name) { 'deployments' }

    before do
      allow(rpsrv).to receive(:rest_get).and_return(response)
    end

    it "requires two arguments" do
      expect { rpsrv.list_api_versions }.to raise_error(ArgumentError)
      expect { rpsrv.list_api_versions(namespace) }.to raise_error(ArgumentError)
      expect { rpsrv.list_api_versions(namespace, service_name, 'something') }.to raise_error(ArgumentError)
    end

    it "returns the expected value when valid values are supplied" do
      array = %w[2016-09-01 2016-07-01 2016-06-01 2016-02-01 2015-11-01 2015-01-01 2014-04-01-preview]
      expect(rpsrv.list_api_versions(namespace, service_name)).to eql(array)
      expect(rpsrv.list_api_versions(namespace, 'extensionsMetadata')).to eql(['2015-01-01', '2014-04-01-preview'])
    end

    it "ignores the case of the service name" do
      array = %w[2016-09-01 2016-07-01 2016-06-01 2016-02-01 2015-11-01 2015-01-01 2014-04-01-preview]
      expect(rpsrv.list_api_versions(namespace, service_name.upcase)).to eql(array)
    end

    it "raises an ArgumentError if it cannot find the service name" do
      expect { rpsrv.list_api_versions(namespace, 'bogus') }.to raise_error(ArgumentError)
    end
  end
end
