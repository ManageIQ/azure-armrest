########################################################################
# availability_set_service_spec.rb
#
# Test suite for the Azure::Armrest::AvailabilitySetService class.
########################################################################
require 'spec_helper'

describe "AvailabilitySetService" do
  before { setup_params }
  let(:asm) { Azure::Armrest::AvailabilitySetService.new(@params) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::AvailabilitySetService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns an asm instance as expected" do
      expect(asm).to be_kind_of(Azure::Armrest::AvailabilitySetService)
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
