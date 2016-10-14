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
  end

  context "get_by_id" do
    let(:id_string) {
      "/subscriptions/#{@sub}/resourceGroups/#{@res}/providers/Microsoft.Network/networkInterfaces/test123"
    }

    let(:hash){
      {
        'name'       => 'test123',
        'id'         => id_string,
        'location'   => 'westus',
        'properties' => { 'provisioningState' => 'Succeeded' }
      }
    }

    it "returns the expected result" do
      allow(rgbs).to receive(:rest_get).and_return(hash)
      result = rgbs.get_by_id(id_string)
      expect(result).to be_kind_of(Azure::Armrest::Network::NetworkInterface)
      expect(result.name).to eql('test123')
    end
  end
end
