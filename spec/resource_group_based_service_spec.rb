########################################################################
# resource_group_based_service_spec.rb
#
# Test suite for the Azure::Armrest::ResourceGroupBasedService class.
########################################################################
require 'spec_helper'

describe "ResourceGroupBasedService" do
  before { setup_params }
  let(:rgbs) { Azure::Armrest::ResourceGroupBasedService.new(@conf, 'virtualMachines', 'Microsoft.Compute', {}) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::ResourceGroupBasedService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a rgbs instance as expected" do
      expect(rgbs).to be_kind_of(Azure::Armrest::ResourceGroupBasedService)
    end
  end

  context "instance methods" do
    it "defines a list method" do
      expect(rgbs).to respond_to(:list)
    end

    it "defines a list_all method" do
      expect(rgbs).to respond_to(:list_all)
    end

    it "defines a get method" do
      expect(rgbs).to respond_to(:get)
    end

    it "defines a get_by_id method" do
      expect(rgbs).to respond_to(:get_by_id)
    end

    it "defines a delete_by_id method" do
      expect(rgbs).to respond_to(:delete_by_id)
    end
  end

  context "get associated resource for service" do
    let(:id_string) do
      "/subscriptions/#{@sub}/resourceGroups/#{@res}/providers/Microsoft.Network/networkInterfaces/test123"
    end

    let(:hash) do
      {
        'name'       => 'test123',
        'id'         => id_string,
        'location'   => 'westus',
        'properties' => {'provisioningState' => 'Succeeded'}
      }
    end

    it "returns the expected result" do
      allow(rgbs).to receive(:rest_get).and_return(hash)
      allow(hash).to receive(:body).and_return(hash)
      result = rgbs.get_by_id(id_string)
      expect(result).to be_kind_of(Azure::Armrest::Network::NetworkInterface)
      expect(result.name).to eql('test123')
    end
  end

  context "get associated resource for subservice" do
    let(:sub_id_string) do
      "/subscriptions/#{@sub}/resourceGroups/#{@res}/providers/Microsoft.Network/virtualNetworks/testx/subnets/default"
    end

    let(:hash) do
      {
        'name'       => 'test123',
        'id'         => sub_id_string,
        'location'   => 'westus',
        'properties' => {'provisioningState' => 'Succeeded'}
      }
    end

    it "returns the expected result for a basic ID string" do
      allow(rgbs).to receive(:rest_get).and_return(hash)
      allow(hash).to receive(:body).and_return(hash)
      result = rgbs.get_by_id(sub_id_string)
      expect(result).to be_kind_of(Azure::Armrest::Network::Subnet)
      expect(result.name).to eql('test123')
    end

    it "returns the expected result for an ID string that contains hyphens and periods" do
      sub_id_string = "/subscriptions/#{@sub}/resourceGroups/foo-bar/providers/Microsoft.Compute"
      sub_id_string << "/virtualMachines/some_vm/extensions/Microsoft.Insights.VMDiagnosticsSettings"
      allow(rgbs).to receive(:rest_get).and_return(hash)
      allow(hash).to receive(:body).and_return(hash)
      result = rgbs.get_by_id(sub_id_string)
      expect(result).to be_kind_of(Azure::Armrest::VirtualMachineExtension)
      expect(result.name).to eql('test123')
    end

    it "returns the expected result for an ID string regardless of case" do
      string = sub_id_string.upcase
      allow(rgbs).to receive(:rest_get).and_return(hash)
      allow(hash).to receive(:body).and_return(hash)
      result = rgbs.get_by_id(string)
      expect(result).to be_kind_of(Azure::Armrest::Network::Subnet)
      expect(result.name).to eql('test123')
    end
  end
end
