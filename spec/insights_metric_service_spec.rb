#################################################################################
# insights_metric_service_spec.rb
#
# Test suite for the Azure::Armrest::Insights::MetricsService class.
#################################################################################
require 'spec_helper'

describe "Insights::MetricsService" do
  before { setup_params }
  let(:ms) { Azure::Armrest::Insights::MetricsService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::Insights::MetricsService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a ms instance as expected" do
      expect(ms).to be_kind_of(Azure::Armrest::Insights::MetricsService)
    end
  end

  context "instance methods" do
    it "defines a list method" do
      expect(ms).to respond_to(:list)
    end
  end
end
