########################################################################
# sql_database_service_spec.rb
#
# Test suite for the Azure::Armrest::Sql::SqlDatabaseService class.
########################################################################
require 'spec_helper'

describe "Sql::SqlDatabaseService" do
  before { setup_params }
  let(:sds) { Azure::Armrest::Sql::SqlDatabaseService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ResourceGroupBasedSubservice" do
      ancestors = Azure::Armrest::Sql::SqlDatabaseService.ancestors
      expect(ancestors).to include(Azure::Armrest::ResourceGroupBasedSubservice)
    end
  end

  context "constructor" do
    it "returns a Sql::SqlDatabaseService instance as expected" do
      expect(sds).to be_kind_of(Azure::Armrest::Sql::SqlDatabaseService)
    end
  end

  context "accessors" do
    it "defines a base_url accessor" do
      expect(sds).to respond_to(:base_url)
      expect(sds).to respond_to(:base_url=)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(sds).to respond_to(:create)
    end

    it "defines an update alias for create" do
      expect(sds).to respond_to(:update)
      expect(sds.method(:create)).to eql(sds.method(:update))
    end

    it "defines a delete method" do
      expect(sds).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(sds).to respond_to(:get)
    end

    it "defines a list method" do
      expect(sds).to respond_to(:list)
    end
  end

  context "create" do
    it "requires multiple arguments" do
      expect { sds.create }.to raise_error(ArgumentError)
    end
  end
end
