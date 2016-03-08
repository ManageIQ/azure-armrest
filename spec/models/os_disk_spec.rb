########################################################################
# os_disk_spec.rb
#
# Test suite for the Azure::Armrest::OsDisk json model class.
########################################################################
require 'spec_helper'

describe "OsDisk" do
  let(:json) do
    '{
      "osType": "Linux",
      "name": "osdisk",
      "createOption": "Empty"
      "vhd": {"uri" : "https://toot.tototototo.vhd"}
      "caching": "ReadWrite"
    }'
  end

  let(:hash) do
    {
      osType: 'Linux',
      name: 'osdisk',
      createOption: 'Empty',
      vhd: {uri: 'https://toot.tototototo.vhd'},
      caching: 'ReadWrite',
    }
  end

  let(:base) { Azure::Armrest::OsDisk.new(hash) }

  context "constructor" do
    it "constructs a OsDisk instance from a hash" do
      expect(base).to be_kind_of(Azure::Armrest::OsDisk)
    end
  end

  context "custom methods" do
  end
end
