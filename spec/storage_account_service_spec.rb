########################################################################
# storage_account_service_spec.rb
#
# Test suite for the Azure::Armrest::StorageAccountService class.
########################################################################
require 'spec_helper'

describe "StorageAccountService" do
  before { setup_params }
  let(:sas) { Azure::Armrest::StorageAccountService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::StorageAccountService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a SAS instance as expected" do
      expect(sas).to be_kind_of(Azure::Armrest::StorageAccountService)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(sas).to respond_to(:create)
    end

    it "defines the update method" do
      expect(sas).to respond_to(:update)
    end

    it "defines a delete method" do
      expect(sas).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(sas).to respond_to(:get)
    end

    it "defines a list_account_keys method" do
      expect(sas).to respond_to(:list_account_keys)
    end

    it "defines a list_account_key_objects method" do
      expect(sas).to respond_to(:list_account_key_objects)
    end


    it "defines a regenerate_account_keys method" do
      expect(sas).to respond_to(:regenerate_storage_account_keys)
    end

    it "defines a regenerate_account_key_objects method" do
      expect(sas).to respond_to(:regenerate_account_key_objects)
    end

    it "defines a list_private_images method" do
      expect(sas).to respond_to(:list_private_images)
    end

    it "defines a list_all_private_images method" do
      expect(sas).to respond_to(:list_all_private_images)
    end

    it "defines a parse_uri method" do
      expect(sas).to respond_to(:parse_uri)
    end

    it "defines a accounts_by_name method" do
      expect(sas).to respond_to(:accounts_by_name)
    end

    it "defines a get_from_vm method" do
      expect(sas).to respond_to(:get_from_vm)
    end

    it "defines a get_virtual_disk method" do
      expect(sas).to respond_to(:get_os_disk)
    end
  end

  context "list" do
    let(:response) { IO.read('spec/fixtures/unmanaged_storage_accounts.json') }
    let(:hash) { {:content_type=>"application/json; charset=utf-8"} }

    before do
      allow(sas).to receive(:rest_get).and_return(response)
      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:headers).and_return(hash)
      allow(response).to receive(:body).and_return(response)
    end

    it "defines a list method" do
      expect(sas).to respond_to(:list)
    end

    it "returns the expected results with default resource group" do
      expect(sas.list.size).to eql(3)
      expect(sas.list.first.name).to eql('foo1')
    end

    it "returns the expected results with explicit resource group" do
      expect(sas.list('foo1').size).to eql(3)
      expect(sas.list('foo1').first.name).to eql('foo1')
    end

    it "returns the expected results with skipped accessors" do
      expect(sas.list('foo1', {}, true).size).to eql(3)
      expect(sas.list('foo1', {}, true).first['name']).to eql('foo1')
      expect(sas.list('foo1', {}, true).first.respond_to?(:name)).to eql(false)
    end
  end

  context "list_all" do
    let(:response) { IO.read('spec/fixtures/unmanaged_storage_accounts.json') }
    let(:hash) { {:content_type=>"application/json; charset=utf-8"} }

    before do
      allow(sas).to receive(:rest_get).and_return(response)
      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:headers).and_return(hash)
      allow(response).to receive(:body).and_return(response)
    end

    it "defines a list_all method" do
      expect(sas).to respond_to(:list_all)
    end

    it "returns the expected results with no arguments" do
      expect(sas.list_all.size).to eql(3)
      expect(sas.list_all.first.name).to eql('foo1')
    end

    it "returns the expected results with a filter" do
      expect(sas.list_all(:name => 'foo1disks560').size).to eql(1)
      expect(sas.list_all(:name => 'foo1disks560').first.name).to eql('foo1disks560')
    end

    it "returns the expected results if skip accessors is used" do
      expect(sas.list_all({:name => 'foo1disks560'}, {}, true).size).to eql(1)
      expect(sas.list_all({:name => 'foo1disks560'}, {}, true).first['name']).to eql('foo1disks560')
    end

    it "raises an error if an invalid filter is selected" do
      expect { sas.list_all(:bogus => 1) }.to raise_error(NoMethodError)
    end
  end

  context "create" do
    it "requires a valid account name" do
      options = {:location => "West US", :properties => {:accountType => "Standard_GRS"}}
      expect { sas.create("xx", @res, options) }.to raise_error(ArgumentError)
      expect { sas.create("^&123***", @res, options) }.to raise_error(ArgumentError)
    end
  end

  context "parse_uri" do
    before(:all) do
      @account           = "abc12345"
      @container         = "mycontainer"
      @service_name      = "blob"
      @simple_blob_name  = "myblob"
      @complex_blob_name = "aaaa/bbbb/cccc/myblob"
      @snapshot          = "2011-03-09T01:42:34.9360000Z"

      @simple_blob_uri   = "http://#{@account}.#{@service_name}.core.windows.net/#{@container}/#{@simple_blob_name}"
      @complex_blob_uri  = "http://#{@account}.#{@service_name}.core.windows.net/#{@container}/#{@complex_blob_name}"
      @root_blob_uri     = "http://#{@account}.#{@service_name}.core.windows.net/#{@simple_blob_name}"

      @simple_blob_snap_uri  = "#{@simple_blob_uri}?snapshot=#{@snapshot}"
      @complex_blob_snap_uri = "#{@complex_blob_uri}?snapshot=#{@snapshot}"
      @root_blob_snap_uri    = "#{@root_blob_uri}?snapshot=#{@snapshot}"
    end

    it "should return the scheme" do
      uri_info = sas.parse_uri(@simple_blob_uri)
      expect(uri_info[:scheme]).to eq("http")
    end

    it "should return the account name" do
      uri_info = sas.parse_uri(@simple_blob_uri)
      expect(uri_info[:account_name]).to eq(@account)
    end

    it "should return the service name" do
      uri_info = sas.parse_uri(@simple_blob_uri)
      expect(uri_info[:service_name]).to eq(@service_name)
    end

    it "should return the container name (simple blob)" do
      uri_info = sas.parse_uri(@simple_blob_uri)
      expect(uri_info[:container]).to eq(@container)
    end

    it "should return the blob name (simple blob)" do
      uri_info = sas.parse_uri(@simple_blob_uri)
      expect(uri_info[:blob]).to eq(@simple_blob_name)
    end

    it "snapshot should be nil (simple blob)" do
      uri_info = sas.parse_uri(@simple_blob_uri)
      expect(uri_info[:snapshot]).to be_nil
    end

    it "should return the container name (complex blob)" do
      uri_info = sas.parse_uri(@complex_blob_uri)
      expect(uri_info[:container]).to eq(@container)
    end

    it "should return the blob name (complex blob)" do
      uri_info = sas.parse_uri(@complex_blob_uri)
      expect(uri_info[:blob]).to eq(@complex_blob_name)
    end

    it "snapshot should be nil (complex blob)" do
      uri_info = sas.parse_uri(@complex_blob_uri)
      expect(uri_info[:snapshot]).to be_nil
    end

    it "should return the container name = '$root' (root blob)" do
      uri_info = sas.parse_uri(@root_blob_uri)
      expect(uri_info[:container]).to eq("$root")
    end

    it "should return the blob name (root blob)" do
      uri_info = sas.parse_uri(@root_blob_uri)
      expect(uri_info[:blob]).to eq(@simple_blob_name)
    end

    it "snapshot should be nil (root blob)" do
      uri_info = sas.parse_uri(@root_blob_uri)
      expect(uri_info[:snapshot]).to be_nil
    end

    it "should return the blob name (simple blob + snapshot)" do
      uri_info = sas.parse_uri(@simple_blob_snap_uri)
      expect(uri_info[:blob]).to eq(@simple_blob_name)
    end

    it "should return the snapshot timestamp (simple blob + snapshot)" do
      uri_info = sas.parse_uri(@simple_blob_snap_uri)
      expect(uri_info[:snapshot]).to eq(@snapshot)
    end

    it "should return the blob name (complex blob + snapshot)" do
      uri_info = sas.parse_uri(@complex_blob_snap_uri)
      expect(uri_info[:blob]).to eq(@complex_blob_name)
    end

    it "should return the snapshot timestamp (complex blob + snapshot)" do
      uri_info = sas.parse_uri(@complex_blob_snap_uri)
      expect(uri_info[:snapshot]).to eq(@snapshot)
    end

    it "should return the blob name (root blob + snapshot)" do
      uri_info = sas.parse_uri(@root_blob_snap_uri)
      expect(uri_info[:blob]).to eq(@simple_blob_name)
    end

    it "should return the snapshot timestamp (root blob + snapshot)" do
      uri_info = sas.parse_uri(@root_blob_snap_uri)
      expect(uri_info[:snapshot]).to eq(@snapshot)
    end
  end
end
