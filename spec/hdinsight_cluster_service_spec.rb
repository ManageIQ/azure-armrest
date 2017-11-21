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

  context "accessors" do
    it "defines a base_url accessor" do
      expect(service).to respond_to(:base_url)
      expect(service).to respond_to(:base_url=)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(service).to respond_to(:create)
    end

    it "defines the update alias" do
      expect(service).to respond_to(:update)
      expect(service.method(:update)).to eql(service.method(:create))
    end

    it "defines a delete method" do
      expect(service).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(service).to respond_to(:get)
    end

    it "defines a list method" do
      expect(service).to respond_to(:list)
    end

    it "defines a list_all method" do
      expect(service).to respond_to(:list_all)
    end
  end

  context "create" do
    it "requires a service name" do
      expect { service.create }.to raise_error(ArgumentError)
    end
  end
end
