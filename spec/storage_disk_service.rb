########################################################################
# storage_disk_service_spec.rb
#
# Test suite for the Azure::Armrest::Storage::DiskService class.
########################################################################
require 'spec_helper'

describe "Storage::DiskService" do
  before { setup_params }
  let(:disk) { Azure::Armrest::Storage::DiskService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::Storage::DiskService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns an DiskService instance as expected" do
      expect(disk).to be_kind_of(Azure::Armrest::Storage::DiskService)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(disk).to respond_to(:create)
    end

    it "defines an update alias" do
      expect(disk).to respond_to(:update)
      expect(disk.method(:update)).to eql(disk.method(:create))
    end

    it "defines a delete method" do
      expect(disk).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(disk).to respond_to(:get)
    end

    it "defines a stop method" do
      expect(disk).to respond_to(:list)
    end
  end
end
