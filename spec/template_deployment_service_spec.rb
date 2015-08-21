########################################################################
# template_deployment_service_spec.rb
#
# Test suite for the Azure::Armrest::TemplateDeploymentService class.
########################################################################
require 'spec_helper'

describe "TemplateDeploymentService" do
  before { setup_params }
  let(:tdm) { Azure::Armrest::TemplateDeploymentService.new(@params) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::TemplateDeploymentService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a tdm instance as expected" do
      expect(tdm).to be_kind_of(Azure::Armrest::TemplateDeploymentService)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expected_url = "https://management.azure.com/subscriptions/abc-123-def-456/resourceGroups/groupname/deployments/deployname?api-version=2014-04-01-preview"
      expect(RestClient).to receive(:put).with(expected_url, anything, anything).and_return('{}')
      tdm.create('deployname', {}, 'groupname')
    end

    it "defines a delete method" do
      expected_url = "https://management.azure.com/subscriptions/abc-123-def-456/resourceGroups/groupname/deployments/deployname?api-version=2014-04-01-preview"
      expect(RestClient).to receive(:delete).with(expected_url, anything)
      tdm.delete('deployname', 'groupname')
    end

    it "defines a list method" do
      expected_url = "https://management.azure.com/subscriptions/abc-123-def-456/resourceGroups/groupname/deployments?api-version=2014-04-01-preview"
      expected_return = '{"value":[{"name":"deployname"}]}'
      expect(RestClient).to receive(:get).with(expected_url, anything).and_return(expected_return)
      tdm.list('groupname')
    end

    it "defines a list_with_details method" do
      expected_url = "https://management.azure.com/subscriptions/abc-123-def-456/resourceGroups/groupname/deployments?api-version=2014-04-01-preview"
      expect(RestClient).to receive(:get).with(expected_url, anything).and_return('{}')
      tdm.list_with_details('groupname')
    end

    it "defines a get method" do
      expected_url = "https://management.azure.com/subscriptions/abc-123-def-456/resourceGroups/groupname/deployments/deployname?api-version=2014-04-01-preview"
      expect(RestClient).to receive(:get).with(expected_url, anything).and_return('{}')
      tdm.get('deployname', 'groupname')
    end

    it "defines a list_deployment_operations method" do
      expected_url = "https://management.azure.com/subscriptions/abc-123-def-456/resourceGroups/groupname/deployments/deployname/operations?api-version=2014-04-01-preview"
      expect(RestClient).to receive(:get).with(expected_url, anything).and_return('{}')
      tdm.list_deployment_operations('deployname', 'groupname')
    end

    it "defines a get_deployment_operation method" do
      expected_url = "https://management.azure.com/subscriptions/abc-123-def-456/resourceGroups/groupname/deployments/deployname/operations/opid?api-version=2014-04-01-preview"
      expect(RestClient).to receive(:get).with(expected_url, anything).and_return('{}')
      tdm.get_deployment_operation('deployname', 'opid', 'groupname')
    end
  end
end
