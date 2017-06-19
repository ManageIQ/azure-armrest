########################################################################
# test_container_service.rb
#
# Test suite for the Azure::Armrest::ContainerService class.
########################################################################
require 'spec_helper'

describe "ContainerService" do
  before { setup_params }
  let(:cs) { Azure::Armrest::ContainerService.new(@conf) }
  let(:singleton) { Azure::Armrest::ContainerService }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::ContainerService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a container instance as expected" do
      expect(cs).to be_kind_of(Azure::Armrest::ContainerService)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(cs).to respond_to(:create)
    end

    it "defines a delete method" do
      expect(cs).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(cs).to respond_to(:get)
    end

    it "defines a list method" do
      expect(cs).to respond_to(:list)
    end

    it "defines a list_all method" do
      expect(cs).to respond_to(:list_all)
    end
  end
end
