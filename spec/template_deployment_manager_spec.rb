########################################################################
# template_deployment_manager_spec.rb
#
# Test suite for the Azure::Armrest::TemplateDeploymentManager class.
########################################################################
require 'spec_helper'

describe "TemplateDeploymentManager" do
  before { setup_params }
  let(:tdm) { Azure::Armrest::TemplateDeploymentManager.new(@params) }

  context "inheritance" do
    it "is a subclass of ArmrestManager" do
      expect(Azure::Armrest::TemplateDeploymentManager.ancestors).to include(Azure::Armrest::ArmrestManager)
    end
  end

  context "constructor" do
    it "returns a tdm instance as expected" do
      expect(tdm).to be_kind_of(Azure::Armrest::TemplateDeploymentManager)
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

    it "defines a deployments method" do
      expected_url = "https://management.azure.com/subscriptions/abc-123-def-456/resourceGroups/groupname/deployments?api-version=2014-04-01-preview"
      expected_return = '{"value":[{"name":"deployname"}]}'
      expect(RestClient).to receive(:get).with(expected_url, anything).and_return(expected_return)
      tdm.deployments('groupname')
    end

    it "defines a deployments method" do
      expected_url = "https://management.azure.com/subscriptions/abc-123-def-456/resourceGroups/groupname/deployments?api-version=2014-04-01-preview"
      expect(RestClient).to receive(:get).with(expected_url, anything).and_return('{}')
      tdm.deployments_with_details('groupname')
    end

    it "defines a get_deployment method" do
      expected_url = "https://management.azure.com/subscriptions/abc-123-def-456/resourceGroups/groupname/deployments/deployname?api-version=2014-04-01-preview"
      expect(RestClient).to receive(:get).with(expected_url, anything).and_return('{}')
      tdm.get_deployment('deployname', 'groupname')
    end

    it "defines a deployment_operations method" do
      expected_url = "https://management.azure.com/subscriptions/abc-123-def-456/resourceGroups/groupname/deployments/deployname/operations?api-version=2014-04-01-preview"
      expect(RestClient).to receive(:get).with(expected_url, anything).and_return('{}')
      tdm.deployment_operations('deployname', 'groupname')
    end

    it "defines a get_deployment_operation method" do
      expected_url = "https://management.azure.com/subscriptions/abc-123-def-456/resourceGroups/groupname/deployments/deployname/operations/opid?api-version=2014-04-01-preview"
      expect(RestClient).to receive(:get).with(expected_url, anything).and_return('{}')
      tdm.get_deployment_operation('deployname', 'opid', 'groupname')
    end
  end
end
