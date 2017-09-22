########################################################################
# storage_key_spec.rb
#
# Test suite for the Azure::Armrest::StorageAccountKey model class.
########################################################################
require 'spec_helper'

describe "StorageAccountKey" do
  before do
    @json = '{
      "keyName":     "key1",
      "value":       "key1Value",
      "permissions": "FULL"
    }'
  end

  let(:acct_key) { Azure::Armrest::StorageAccountKey.new(@json) }

  context "constructor" do
    it "returns a StorageAccount class as expected" do
      expect(acct_key).to be_kind_of(Azure::Armrest::StorageAccountKey)
    end
  end

  context "custom methods" do
    it "defines a key method that returns the expected value" do
      expect(acct_key).to respond_to(:key)
      expect(acct_key.key).to eql('key1Value')
    end

    it "defines a key1 method that returns the expected value" do
      expect(acct_key).to respond_to(:key1)
      expect(acct_key.key1).to eql('key1Value')
    end

    it "defines a key2 method that returns the expected value" do
      expect(acct_key).to respond_to(:key2)
      expect(acct_key.key2).to be_nil
    end

    it "defines a key_name_from_hash method that returns the expected value" do
      expect(acct_key).to respond_to(:key_name_from_hash)
      expect(acct_key.key_name_from_hash).to eq("key1")
    end

    it "defines a value_from_hash method that returns the expected value" do
      expect(acct_key).to respond_to(:value_from_hash)
      expect(acct_key.value_from_hash).to eq("key1Value")
    end
  end
end
