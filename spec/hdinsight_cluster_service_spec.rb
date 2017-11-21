#############################################################################
# hdinsight_cluster_service_spec.rb
#
# Test suite for the Azure::Armrest::HDInsight::HDInsightClusterService class.
#############################################################################
require 'spec_helper'

describe "HDInsight::HDInsightClusterService" do
  before { setup_params }
  let(:service) { Azure::Armrest::HDInsight::HDInsightClusterService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::HDInsight::HDInsightClusterService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a HDInsightCluster instance as expected" do
      expect(service).to be_kind_of(Azure::Armrest::HDInsight::HDInsightClusterService)
    end
  end
end
