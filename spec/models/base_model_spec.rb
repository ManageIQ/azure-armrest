########################################################################
# base_model_spec.rb
#
# Test suite for the Azure::Armrest::BaseModel json model class.
########################################################################
require 'spec_helper'

describe "BaseModel" do
  before {
    @json = '{
      "firstName":"jeff",
      "lastName":"durand",
      "address": {"street":"22 charlotte rd", "zipcode":"01013"}
    }'
  }

  let(:base){ Azure::Armrest::BaseModel.new(@json) }

  context "constructor" do
    it "returns a BaseModel class as expected" do
      expect(base).to be_kind_of(Azure::Armrest::BaseModel)
    end
  end

  context "accessors" do
    it "defines a json accessor that returns the original json" do
      expect(base.json).to eq(@json)
    end
  end

  context "custom methods" do
    it "defines a resource_group method that returns nil by default" do
      expect(base).to respond_to(:resource_group)
      expect(base.resource_group).to eq(nil)
    end

    it "returns the expected value for the resource_group method" do
      @json = {:id => '/foo/bar/resourceGroups/foo/x/y/z'}.to_json
      base = Azure::Armrest::BaseModel.new(@json)
      expect(base.resource_group).to eq('foo')
    end

    it "defines a tags method that returns an empty hash by default" do
      expect(base).to respond_to(:tags)
      expect(base.tags).to eq({})
    end

    it "returns the expected hash for the tags method when defined" do 
      @json = {:name => 'test', :tags => {:foo => 1, :bar => 2}}.to_json
      base = Azure::Armrest::BaseModel.new(@json)
      expect(base.tags).to eq({:foo => 1, :bar => 2})
    end
  end

  context "inspection methods" do
    it "defines a to_s method that returns the original json" do
      expect(base.to_s).to eq(@json)
    end

    it "defines a to_str method that returns the original json" do
      expect(base.to_str).to eq(@json)
    end

    it "defines a to_json method that returns the original json" do
      expect(base.to_json).to eq(@json)
    end

    it "defines a custom inspect method" do
      @json = {:name => 'test', :age => 33}.to_json
      base = Azure::Armrest::BaseModel.new(@json)
      expected = "<Azure::Armrest::BaseModel name=test age=33>"
      expect(base.inspect).to eq(expected)
    end
  end

  context "dynamic method generation" do
    it "defines a method for each json property" do
      expect(base).to respond_to(:firstName)
      expect(base).to respond_to(:lastName)
      expect(base).to respond_to(:address)
    end

    it "defines snake_case aliases for each dynamic method" do
      expect(base).to respond_to(:first_name)
      expect(base).to respond_to(:last_name)
      expect(base).to respond_to(:address)
    end

    it "allows you to chain dynamic methods" do
      expect(base.address).to respond_to(:street)
      expect(base.address).to respond_to(:zipcode)
    end
  end

  context "dynamic accessors" do
    it "returns expected value for firstName method" do
      expect(base.firstName).to eq('jeff')
      expect(base.first_name).to eq('jeff')
    end

    it "returns expected value for lastName method" do
      expect(base.lastName).to eq('durand')
      expect(base.last_name).to eq('durand')
    end

    it "returns expected value for address method" do
      expect(base.address).to be_kind_of(OpenStruct)
    end

    it "returns expected value for zipcode method" do
      expect(base.address.zipcode).to eq('01013')
    end
  end
end
