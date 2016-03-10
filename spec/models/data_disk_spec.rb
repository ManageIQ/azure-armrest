########################################################################
# data_disk.rb
#
# Test suite for the Azure::Armrest::DataDisk json model class.
########################################################################
require 'spec_helper'

describe "DataDisk" do
  let(:json) do
    '{
      "lun": 0,
      "name": "datadisk",
      "createOption": "Empty"
      "vhd": {"uri" : "https://toot.tototototo.vhd"}
      "caching": "None"
    }'
  end

  let(:hash) do
    {
      :lun          => 0,
      :name         => 'datadisk',
      :createOption => 'Empty',
      :vhd          => {:uri       => 'https://toot.tototototo.vhd'},
      :caching      => 'None'
    }
  end

  let(:base) { Azure::Armrest::DataDisk.new(hash) }

  context "constructor" do
    it "constructs a DataDisk instance from a hash" do
      expect(base).to be_kind_of(Azure::Armrest::DataDisk)
    end
  end

  context "custom methods" do
  end
end
