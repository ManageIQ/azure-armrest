########################################################################
# key_vault_service_spec.rb
#
# Test suite for the Azure::Armrest::KeyVaultService class.
########################################################################
require 'spec_helper'

describe "KeyVaultService" do
  before { setup_params }
  let(:vault) { Azure::Armrest::KeyVaultService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::KeyVaultService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns an Azure::Armrest::KeyVaultService instance as expected" do
      expect(vault).to be_kind_of(Azure::Armrest::KeyVaultService)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(vault).to respond_to(:create)
    end

    it "defines an update alias" do
      expect(vault).to respond_to(:update)
      expect(vault.method(:update)).to eql(vault.method(:create))
    end

    it "defines a delete method" do
      expect(vault).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(vault).to respond_to(:get)
    end

    it "defines a list_all method" do
      expect(vault).to respond_to(:list_all)
    end

    it "defines a list_deleted method" do
      expect(vault).to respond_to(:list_deleted)
    end

    it "defines a purge_deleted method" do
      expect(vault).to respond_to(:purge_deleted)
    end

    it "defines a get_deleted method" do
      expect(vault).to respond_to(:get_deleted)
    end
  end
end
