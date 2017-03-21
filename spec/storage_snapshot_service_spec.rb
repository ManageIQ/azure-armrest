########################################################################
# storage_snapshot_service_spec.rb
#
# Test suite for the Azure::Armrest::Storage::SnapshotService class.
########################################################################
require 'spec_helper'

describe "Storage::SnapshotService" do
  before { setup_params }
  let(:snapshot) { Azure::Armrest::Storage::SnapshotService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::Storage::SnapshotService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns an SnapshotService instance as expected" do
      expect(snapshot).to be_kind_of(Azure::Armrest::Storage::SnapshotService)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(snapshot).to respond_to(:create)
    end

    it "defines an update alias" do
      expect(snapshot).to respond_to(:update)
      expect(snapshot.method(:update)).to eql(snapshot.method(:create))
    end

    it "defines a delete method" do
      expect(snapshot).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(snapshot).to respond_to(:get)
    end

    it "defines a stop method" do
      expect(snapshot).to respond_to(:list)
    end
  end
end
