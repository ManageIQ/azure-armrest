########################################################################
# availability_set_service_spec.rb
#
# Test suite for the Azure::Armrest::AvailabilitySetService class.
########################################################################
require 'spec_helper'

describe "AvailabilitySetService" do
  before { setup_params }
  let(:ass) { Azure::Armrest::AvailabilitySetService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::AvailabilitySetService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns an ASS instance as expected" do
      expect(ass).to be_kind_of(Azure::Armrest::AvailabilitySetService)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(ass).to respond_to(:create)
    end

    it "defines an update alias" do
      expect(ass).to respond_to(:update)
      expect(ass.method(:update)).to eql(ass.method(:create))
    end

    it "defines a delete method" do
      expect(ass).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(ass).to respond_to(:get)
    end

    it "defines a stop method" do
      expect(ass).to respond_to(:list)
    end
  end
end
