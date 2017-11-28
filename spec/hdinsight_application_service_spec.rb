#####################################################################################
# hdinsight_application_service_spec.rb
#
# Test suite for the Azure::Armrest::HDInsight::ApplicationService class.
#####################################################################################
require 'spec_helper'

describe "HDInsight::ApplicationService" do
  before { setup_params }
  let(:hdi_as) { Azure::Armrest::HDInsight::ApplicationService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ResourceGroupBasedSubservice" do
      ancestors = Azure::Armrest::HDInsight::ApplicationService.ancestors
      expect(ancestors).to include(Azure::Armrest::ResourceGroupBasedSubservice)
    end
  end

  context "constructor" do
    it "returns a HDInsight::ApplicationService instance as expected" do
      expect(hdi_as).to be_kind_of(Azure::Armrest::HDInsight::ApplicationService)
    end
  end
end
