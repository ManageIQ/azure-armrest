#################################################################################
# insights_event_service_spec.rb
#
# Test suite for the Azure::Armrest::Insights::EventService class.
#################################################################################
require 'spec_helper'

describe "Insights::EventService" do
  before { setup_params }
  let(:ies) { Azure::Armrest::Insights::EventService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::Insights::EventService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a ies instance as expected" do
      expect(ies).to be_kind_of(Azure::Armrest::Insights::EventService)
    end
  end

  context "instance methods" do
    it "defines a list method" do
      expect(ies).to respond_to(:list)
    end
  end
end
