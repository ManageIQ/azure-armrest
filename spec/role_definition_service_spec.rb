#################################################################################
# role_definition_service_spec.rb
#
# Test suite for the Azure::Armrest::Role::DefinitionService class.
#################################################################################
require 'spec_helper'

describe "Role::DefinitionService" do
  before { setup_params }
  let(:rds) { Azure::Armrest::Role::DefinitionService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::Role::DefinitionService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a rds instance as expected" do
      expect(rds).to be_kind_of(Azure::Armrest::Role::DefinitionService)
    end
  end

  context "instance methods" do
    it "defines a get method" do
      expect(rds).to respond_to(:get)
    end

    it "defines a list method" do
      expect(rds).to respond_to(:list)
    end

    it "defines a list_all method" do
      expect(rds).to respond_to(:list_all)
    end
  end
end
