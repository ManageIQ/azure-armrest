#################################################################################
# insights_diagnostic_service_spec.rb
#
# Test suite for the Azure::Armrest::Insights::DiagnosticService class.
#################################################################################
require 'spec_helper'

describe "Insights::DiagnosticService" do
  before { setup_params }
  let(:ias) { Azure::Armrest::Insights::DiagnosticService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::Insights::DiagnosticService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a ias instance as expected" do
      expect(ias).to be_kind_of(Azure::Armrest::Insights::DiagnosticService)
    end
  end

  context "instance methods" do
    it "defines a get method" do
      expect(ias).to respond_to(:get)
    end

    it "defines a create method" do
      expect(ias).to respond_to(:create)
    end

    it "defines a set alias" do
      expect(ias).to respond_to(:set)
      expect(ias.method(:set)).to eql(ias.method(:create))
    end
  end
end
