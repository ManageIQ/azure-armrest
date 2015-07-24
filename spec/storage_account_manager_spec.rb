########################################################################
# storage_account_manager_spec.rb
#
# Test suite for the Azure::Armrest::StorageAccountManager class.
########################################################################
require 'spec_helper'

describe "StorageAccountManager" do
  before { setup_params }
  let(:sam) { Azure::Armrest::StorageAccountManager.new(@params) }

  context "inheritance" do
    it "is a subclass of ArmrestManager" do
      expect(Azure::Armrest::StorageAccountManager.ancestors).to include(Azure::Armrest::ArmrestManager)
    end
  end

  context "constructor" do
    it "returns a SAM instance as expected" do
      expect(sam).to be_kind_of(Azure::Armrest::StorageAccountManager)
    end
  end

  context "constants" do
    it "defines VALID_ACCOUNT_TYPES" do
      expect(Azure::Armrest::StorageAccountManager::VALID_ACCOUNT_TYPES).not_to be_nil
      expect(Azure::Armrest::StorageAccountManager::VALID_ACCOUNT_TYPES).to be_a_kind_of(Array)
      expect(Azure::Armrest::StorageAccountManager::VALID_ACCOUNT_TYPES.size).to eql(4)
    end
  end

  context "accessors" do
    it "defines a base_url accessor" do
      expect(sam).to respond_to(:base_url)
      expect(sam).to respond_to(:base_url=)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(sam).to respond_to(:create)
    end

    it "defines the update alias" do
      expect(sam).to respond_to(:update)
      expect(sam.method(:update)).to eql(sam.method(:create))
    end

    it "defines a delete method" do
      expect(sam).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(sam).to respond_to(:get)
    end

    it "defines a list method" do
      expect(sam).to respond_to(:list)
    end

    it "defines a list_account_keys method" do
      expect(sam).to respond_to(:list_account_keys)
    end

    it "defines a regenerate_storage_account_keys method" do
      expect(sam).to respond_to(:regenerate_storage_account_keys)
    end
  end
end
