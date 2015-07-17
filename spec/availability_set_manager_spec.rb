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
      expect(Azure::Armrest::AvailabilitySetManager.ancestors).to include(Azure::Armrest::ArmrestManager)
    end
  end

  context "constructor" do
    it "returns an asm instance as expected" do
      expect(asm).to be_kind_of(Azure::Armrest::AvailabilitySetManager)
    end

    it "sets the default uri to the expected value" do
      expected = "https://management.azure.com"
      expected << "/resourceGroups/#{@res}/providers/Microsoft.Compute/availabilitySets"
      expect(asm.base_url).to eq(expected)
    end
  end

  context "accessors" do
    it "defines a base_url accessor" do
      expect(asm).to respond_to(:base_url)
      expect(asm).to respond_to(:base_url=)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(asm).to respond_to(:create)
    end

    it "defines an update alias" do
      expect(asm).to respond_to(:update)
      expect(asm.method(:update)).to eql(asm.method(:create))
    end

    it "defines a delete method" do
      expect(asm).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(asm).to respond_to(:get)
    end

    it "defines a stop method" do
      expect(asm).to respond_to(:list)
    end
  end
end
