########################################################################
# storage_account_manager_spec.rb
#
# Test suite for the Azure::ArmRest::StorageAccountManager class.
########################################################################

require 'spec_helper'

describe "StorageAccountManager" do
  before do
    @sub = 'abc-123-def-456'
    @res = 'my_resource_group'
    @ver = '2015-1-1'
    @sam = nil
  end

  context "inheritance" do
    it "is a subclass of ArmRestManager" do
      Azure::ArmRest::StorageAccountManager.ancestors.should include(Azure::ArmRest::ArmRestManager)
    end
  end

  context "constructor" do
    it "returns a SAM instance as expected" do
      @sam = Azure::ArmRest::StorageAccountManager.new(@sub, @res, @ver)
      @sam.should be_kind_of(Azure::ArmRest::StorageAccountManager)
    end

    it "requires at least two arguments" do
      expect{ Azure::ArmRest::StorageAccountManager.new }.to raise_error(ArgumentError)
      expect{ Azure::ArmRest::StorageAccountManager.new(@sub) }.to raise_error(ArgumentError)
    end

    it "accepts up to three arguments" do
      expect{ Azure::ArmRest::StorageAccountManager.new(@sub, @res, @ver, @ver) }.to raise_error(ArgumentError)
    end

    it "sets the api_version to the expected default value if none is provided" do
      @sam = Azure::ArmRest::StorageAccountManager.new(@sub, @res)
      @sam.api_version.should eql("2015-1-1")
    end
  end

  context "constants" do
    it "defines VALID_ACCOUNT_TYPES" do
      Azure::ArmRest::StorageAccountManager::VALID_ACCOUNT_TYPES.should_not be_nil
      Azure::ArmRest::StorageAccountManager::VALID_ACCOUNT_TYPES.should be_a_kind_of(Array)
      Azure::ArmRest::StorageAccountManager::VALID_ACCOUNT_TYPES.size.should eql(4)
    end
  end

  context "accessors" do
    before(:each){ @sam = Azure::ArmRest::StorageAccountManager.new(@sub, @res, @ver) }

    it "defines a uri accessor" do
      @sam.should respond_to(:uri)
      @sam.should respond_to(:uri=)
    end

    after(:each){ @sam = nil }
  end

  context "instance methods" do
    before(:each){ @sam = Azure::ArmRest::StorageAccountManager.new(@sub, @res, @ver) }

    it "defines a create method" do
      @sam.should respond_to(:create)
    end

    it "defines the update alias" do
      @sam.should respond_to(:update)
      @sam.method(:update).should eql(@sam.method(:create))
    end

    it "defines a delete method" do
      @sam.should respond_to(:delete)
    end

    it "defines a get method" do
      @sam.should respond_to(:get)
    end

    it "defines a list method" do
      @sam.should respond_to(:list)
    end

    it "defines a list_account_keys method" do
      @sam.should respond_to(:list_account_keys)
    end

    it "defines a regenerate_storage_account_keys method" do
      @sam.should respond_to(:regenerate_storage_account_keys)
    end

    after(:each){ @sam = nil }
  end

  after do
    @sub = nil
    @res = nil
    @ver = nil
    @sam = nil
  end
end
