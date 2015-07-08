########################################################################
# availability_set_manager_spec.rb
#
# Test suite for the Azure::Armrest::AvailabilitySetManager class.
########################################################################

require 'spec_helper'

describe "AvailabilitySetManager" do
  before { setup_params }
  let(:asm) { Azure::Armrest::AvailabilitySetManager.new(@params) }

  context "inheritance" do
    it "is a subclass of ArmrestManager" do
      Azure::Armrest::AvailabilitySetManager.ancestors.should include(Azure::Armrest::ArmrestManager)
    end
  end

  context "constructor" do
    it "returns an asm instance as expected" do
      asm.should be_kind_of(Azure::Armrest::AvailabilitySetManager)
    end

    it "sets the default uri to the expected value" do
      expected = "https://management.azure.com"
      expected << "/resourceGroups/#{@res}/providers/Microsoft.Compute/availabilitySets"
      asm.base_url.should eq(expected)
    end
  end

  context "accessors" do
    it "defines a base_url accessor" do
      asm.should respond_to(:base_url)
      asm.should respond_to(:base_url=)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      asm.should respond_to(:create)
    end

    it "defines an update alias" do
      asm.should respond_to(:update)
      asm.method(:update).should eql(asm.method(:create))
    end

    it "defines a delete method" do
      asm.should respond_to(:delete)
    end

    it "defines a get method" do
      asm.should respond_to(:get)
    end

    it "defines a stop method" do
      asm.should respond_to(:list)
    end
  end
end
