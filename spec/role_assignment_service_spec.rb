#################################################################################
# role_assignment_service_spec.rb
#
# Test suite for the Azure::Armrest::Role::AssignmentService class.
#################################################################################
require 'spec_helper'

describe "Role::AssignmentService" do
  before { setup_params }
  let(:ras) { Azure::Armrest::Role::AssignmentService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::Role::AssignmentService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a ras instance as expected" do
      expect(ras).to be_kind_of(Azure::Armrest::Role::AssignmentService)
    end
  end

  context "instance methods" do
    it "defines a get method" do
      expect(ras).to respond_to(:get)
    end

    it "defines a list method" do
      expect(ras).to respond_to(:list)
    end

    it "defines a list_all method" do
      expect(ras).to respond_to(:list_all)
    end
  end
end
