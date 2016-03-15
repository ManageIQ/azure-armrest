########################################################################
# storage_account_spec.rb
#
# Test suite for the Azure::Armrest::StorageAccount json model class.
########################################################################
require 'spec_helper'

describe "StorageAccount" do
  before {
    @json = '{
      "name":"vhds",
      "properties":{"etag": "12345"}
    }'
  }

  let(:storage){ Azure::Armrest::StorageAccount.new(@json) }

  context "constructor" do
    it "returns a StorageAccount class as expected" do
      expect(storage).to be_kind_of(Azure::Armrest::StorageAccount)
    end
  end

  context "storage classes" do
    it "defines container and blob classes" do
      expect(Azure::Armrest::StorageAccount::Container)
      expect(Azure::Armrest::StorageAccount::ContainerProperty)
      expect(Azure::Armrest::StorageAccount::Blob)
      expect(Azure::Armrest::StorageAccount::BlobServiceProperty)
      expect(Azure::Armrest::StorageAccount::BlobServiceStat)
      expect(Azure::Armrest::StorageAccount::BlobMetadata)
      expect(Azure::Armrest::StorageAccount::Table)
      expect(Azure::Armrest::StorageAccount::TableData)
      expect(Azure::Armrest::StorageAccount::BlobSnapshot)
    end
  end

  context "accessors" do
    it "defines a storage_api_version accessor that defaults to 2015-02-01" do
      expect(storage).to respond_to(:storage_api_version)
      expect(storage.storage_api_version).to eq('2015-02-21')
    end

    it "defines a proxy accessor that defaults to the http_proxy environment variable" do
      proxy = "http://www.somewebsiteyyyyzzzz.com/bogusproxy"
      allow(ENV).to receive(:[]).with('http_proxy').and_return(proxy)

      expect(storage).to respond_to(:proxy)
      expect(storage.proxy).to eq(proxy)
    end

    it "defines an ssl_version accessor that defaults to TLSv1" do
      expect(storage).to respond_to(:ssl_version)
      expect(storage.ssl_version).to eq('TLSv1')
    end

    it "defines an ssl_verify accessor that defaults to nil" do
      expect(storage).to respond_to(:ssl_verify)
      expect(storage.ssl_verify).to be_nil
    end
  end

  context "custom methods" do
    it "defines a containers method" do
      expect(storage).to respond_to(:containers)
    end

    it "defines a container_properties method" do
      expect(storage).to respond_to(:container_properties)
    end

    it "defines a container_acl method" do
      expect(storage).to respond_to(:container_acl)
    end

    it "defines a blobs method" do
      expect(storage).to respond_to(:blobs)
    end

    it "defines an all_blobs method" do
      expect(storage).to respond_to(:all_blobs)
    end

    it "defines a blob_properties method" do
      expect(storage).to respond_to(:blob_properties)
    end

    it "defines a blob_service_properties method" do
      expect(storage).to respond_to(:blob_service_properties)
    end

    it "defines a blob_metadata method" do
      expect(storage).to respond_to(:blob_metadata)
    end

    it "defines a blob_service_stats method" do
      expect(storage).to respond_to(:blob_service_stats)
    end

    it "defines a copy_blob method" do
      expect(storage).to respond_to(:copy_blob)
    end

    it "defines a create_blob method" do
      expect(storage).to respond_to(:create_blob)
    end

    it "defines a delete_blob method" do
      expect(storage).to respond_to(:delete_blob)
    end

    it "defines a create_blob_snapshot method" do
      expect(storage).to respond_to(:create_blob_snapshot)
    end

    it "defines a get_blob_raw method" do
      expect(storage).to respond_to(:get_blob_raw)
    end

    it "defines a tables method" do
      expect(storage).to respond_to(:tables)
    end

    it "defines a table_info method" do
      expect(storage).to respond_to(:table_info)
    end

    it "defines a table_data method" do
      expect(storage).to respond_to(:table_data)
    end
  end
end
