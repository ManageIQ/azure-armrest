########################################################################
# template_deployment_service_spec.rb
#
# Test suite for the Azure::Armrest::TemplateDeploymentService class.
########################################################################
require 'spec_helper'

describe "TemplateDeploymentService" do
  before do
    setup_params
    allow_any_instance_of(String).to receive(:headers).and_return({})
    allow_any_instance_of(String).to receive(:code).and_return(200)
  end

  let(:tds) { Azure::Armrest::TemplateDeploymentService.new(@conf) }
  let(:api_version) { tds.api_version }
  let(:url_prefix) { "https://management.azure.com/subscriptions/abc-123-def-456/resourceGroups/groupname/providers/Microsoft.Resources/deployments" }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::TemplateDeploymentService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a TDS instance as expected" do
      expect(tds).to be_kind_of(Azure::Armrest::TemplateDeploymentService)
    end
  end

=begin
  context "instance methods" do
    let(:empty_hash_string) { "{}" }

    before do
      allow(empty_hash_string).to receive(:body).and_return(empty_hash_string)
    end

    it "defines a create method" do
      expected = @req.merge(
        :url     => url_prefix + "/deployname?api-version=#{api_version}",
        :method  => :put,
        :payload => "{}"
      )
      expect(RestClient::Request).to receive(:execute).with(expected).and_return(empty_hash_string)
      tds.create('deployname', 'groupname', {})
    end

    it "defines a get_template method" do
      expected = @req.merge(
        :url     => url_prefix + "/deployname/exportTemplate?api-version=#{api_version}",
        :method  => :post,
        :payload => ''
      )
      expect(RestClient::Request).to receive(:execute).with(expected).and_return('{"template":{}}')
      tds.get_template('deployname', 'groupname')
    end

    it "defines a delete method" do
      expected = @req.merge(
        :url    => url_prefix + "/deployname?api-version=#{api_version}",
        :method => :delete
      )

      response = '{}'
      expect(RestClient::Request).to receive(:execute).with(expected).and_return(response)
      tds.delete('deployname', 'groupname')
    end

    it "defines a list_names method" do
      expected = @req.merge(:url => url_prefix + "?api-version=#{api_version}")
      expected_return = '{"value":[{"name":"deployname"}]}'
      expect(RestClient::Request).to receive(:execute).with(expected).and_return(expected_return)
      tds.list_names('groupname')
    end

    it "defines a list method" do
      expected = @req.merge(:url => url_prefix + "?api-version=#{api_version}")
      expect(RestClient::Request).to receive(:execute).with(expected).and_return('{"value":{}}')
      tds.list('groupname')
    end

    it "defines a get method" do
      expected = @req.merge(:url => url_prefix + "/deployname?api-version=#{api_version}")
      expect(RestClient::Request).to receive(:execute).with(expected).and_return(empty_hash_string)
      tds.get('deployname', 'groupname')
    end

    it "defines an exists? method" do
      allow(tds).to receive(:rest_head).and_return('')
      expect(tds.exists?('deployname', 'groupname')).to eql(true)
    end

    it "returns false for the exists method if a 404 is raised" do
      allow(tds).to receive(:rest_head).and_raise(Azure::Armrest::NotFoundException.new(404, "not found", nil))
      expect(tds.exists?('deployname', 'groupname')).to eql(false)
    end

    it "defines a list_deployment_operations method" do
      expected = @req.merge(:url => url_prefix + "/deployname/operations?api-version=#{api_version}")
      expect(RestClient::Request).to receive(:execute).with(expected).and_return('{"value":{}}')
      tds.list_deployment_operations('deployname', 'groupname')
    end

    it "defines a get_deployment_operation method" do
      expected = @req.merge(:url => url_prefix + "/deployname/operations/opid?api-version=#{api_version}")
      expect(RestClient::Request).to receive(:execute).with(expected).and_return(empty_hash_string)
      tds.get_deployment_operation('opid', 'deployname', 'groupname')
    end

    it "defines a delete_associated_resources method" do
      id_pattern = '/subscriptions/123/resourceGrups/group/services/resource'
      operations = [
        Azure::Armrest::TemplateDeploymentOperation.new(
          'properties' => {'provisioningOperation' => 'Create', 'targetResource' => {'id' => id_pattern + '1'}}
        ),
        Azure::Armrest::TemplateDeploymentOperation.new(
          'properties' => {'provisioningOperation' => 'Create', 'targetResource' => {'id' => id_pattern + '2'}}
        )
      ]
      expect(tds).to receive(:list_deployment_operations).and_return(operations)

      response = double("rest_delete", :headers => {}, :code => 200 )
      expect(RestClient::Request).to receive(:execute).exactly(3).times.and_return(response)

      tds.delete_associated_resources('deployname', 'groupname')
    end
  end
=end
end
