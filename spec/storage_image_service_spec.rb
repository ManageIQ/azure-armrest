########################################################################
# storage_image_service_spec.rb
#
# Test suite for the Azure::Armrest::Storage::ImageService class.
########################################################################
require 'spec_helper'

describe "Storage::ImageService" do
  before { setup_params }
  let(:image) { Azure::Armrest::Storage::ImageService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::Storage::ImageService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns an ImageService instance as expected" do
      expect(image).to be_kind_of(Azure::Armrest::Storage::ImageService)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(image).to respond_to(:create)
    end

    it "defines an update alias" do
      expect(image).to respond_to(:update)
      expect(image.method(:update)).to eql(image.method(:create))
    end

    it "defines a delete method" do
      expect(image).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(image).to respond_to(:get)
    end

    it "defines a stop method" do
      expect(image).to respond_to(:list)
    end
  end
end
