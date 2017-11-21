#####################################################################################
# hdinsight_application_service_spec.rb
#
# Test suite for the Azure::Armrest::HDInsight::HDInsightApplicationService class.
#####################################################################################
require 'spec_helper'

describe "HDInsight::HDInsightApplicationService" do
  before { setup_params }
  let(:hdi_as) { Azure::Armrest::HDInsight::HDInsightApplicationService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ResourceGroupBasedSubservice" do
      ancestors = Azure::Armrest::HDInsight::HDInsightApplicationService.ancestors
      expect(ancestors).to include(Azure::Armrest::ResourceGroupBasedSubservice)
    end
  end

  context "constructor" do
    it "returns a HDInsight::HDInsightApplicationService instance as expected" do
      expect(hdi_as).to be_kind_of(Azure::Armrest::HDInsight::HDInsightApplicationService)
    end
  end
end
