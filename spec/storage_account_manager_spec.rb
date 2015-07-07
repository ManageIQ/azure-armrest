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
      Azure::Armrest::StorageAccountManager.ancestors.should include(Azure::Armrest::ArmrestManager)
    end
  end

  context "constructor" do
    it "returns a SAM instance as expected" do
      sam.should be_kind_of(Azure::Armrest::StorageAccountManager)
    end
  end

  context "constants" do
    it "defines VALID_ACCOUNT_TYPES" do
      Azure::Armrest::StorageAccountManager::VALID_ACCOUNT_TYPES.should_not be_nil
      Azure::Armrest::StorageAccountManager::VALID_ACCOUNT_TYPES.should be_a_kind_of(Array)
      Azure::Armrest::StorageAccountManager::VALID_ACCOUNT_TYPES.size.should eql(4)
    end
  end

  context "accessors" do
    it "defines a base_url accessor" do
      sam.should respond_to(:base_url)
      sam.should respond_to(:base_url=)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      sam.should respond_to(:create)
    end

    it "defines the update alias" do
      sam.should respond_to(:update)
      sam.method(:update).should eql(sam.method(:create))
    end

    it "defines a delete method" do
      sam.should respond_to(:delete)
    end

    it "defines a get method" do
      sam.should respond_to(:get)
    end

    it "defines a list method" do
      sam.should respond_to(:list)
    end

    it "defines a list_account_keys method" do
      sam.should respond_to(:list_account_keys)
    end

    it "defines a regenerate_storage_account_keys method" do
      sam.should respond_to(:regenerate_storage_account_keys)
    end
  end
end
