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

  context "constants" do
    it "defines VALID_ACCOUNT_TYPES" do
      expect(Azure::Armrest::StorageAccountService::VALID_ACCOUNT_TYPES).not_to be_nil
      expect(Azure::Armrest::StorageAccountService::VALID_ACCOUNT_TYPES).to be_a_kind_of(Array)
      expect(Azure::Armrest::StorageAccountService::VALID_ACCOUNT_TYPES.size).to eql(4)
    end
  end

  context "accessors" do
    it "defines a base_url accessor" do
      expect(sas).to respond_to(:base_url)
      expect(sas).to respond_to(:base_url=)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(sas).to respond_to(:create)
    end

    it "defines the update alias" do
      expect(sas).to respond_to(:update)
      expect(sas.method(:update)).to eql(sas.method(:create))
    end

    it "defines a delete method" do
      expect(sas).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(sas).to respond_to(:get)
    end

    it "defines a list method" do
      expect(sas).to respond_to(:list)
    end

    it "defines a list_account_keys method" do
      expect(sas).to respond_to(:list_account_keys)
    end

    it "defines a list_all_for_subscription method" do
      expect(sas).to respond_to(:list_all_for_subscription)
    end

    it "defines a regenerate_storage_account_keys method" do
      expect(sas).to respond_to(:regenerate_storage_account_keys)
    end
  end

  context "create" do
    it "requires both an account name and a location" do
      expect{ sas.create }.to raise_error(KeyError)
      expect{ sas.create(:name => "test") }.to raise_error(KeyError)
      expect{ sas.create(:location => "West US") }.to raise_error(KeyError)
    end

    it "requires a valid account name" do
      expect{ sas.create(:name => "xx", :location => "West US") }.to raise_error(ArgumentError)
      expect{ sas.create(:name => "^&123***", :location => "West US") }.to raise_error(ArgumentError)
    end

    it "requires a valid account type" do
      expect{ sas.create(:name => "test", :location => "West US", :type => "bogus") }.to raise_error(ArgumentError)
    end
  end
end
