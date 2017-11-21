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

  context "accessors" do
    it "defines a base_url accessor" do
      expect(hdi_as).to respond_to(:base_url)
      expect(hdi_as).to respond_to(:base_url=)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(hdi_as).to respond_to(:create)
    end

    it "defines an update alias for create" do
      expect(hdi_as).to respond_to(:update)
      expect(hdi_as.method(:create)).to eql(hdi_as.method(:update))
    end

    it "defines a delete method" do
      expect(hdi_as).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(hdi_as).to respond_to(:get)
    end

    it "defines a list method" do
      expect(hdi_as).to respond_to(:list)
    end
  end

  context "create" do
    it "requires multiple arguments" do
      expect { hdi_as.create }.to raise_error(ArgumentError)
    end
  end
end
