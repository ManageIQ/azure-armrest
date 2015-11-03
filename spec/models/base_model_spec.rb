########################################################################
# base_model_spec.rb
#
# Test suite for the Azure::Armrest::BaseModel json model class.
########################################################################
require 'spec_helper'

describe "BaseModel" do
  let(:json) do
    '{
      "firstName":"jeff",
      "lastName":"durand",
      "address": {"street":"22 charlotte rd", "zipcode":"01013"}
    }'
  end

  let(:base) { Azure::Armrest::BaseModel.new(json) }

  context "constructor" do
    it "constructs a BaseModel instance from a JSON string" do
      expect(base).to be_kind_of(Azure::Armrest::BaseModel)
    end

    it "constructs a BaseModel instance from a Hash object" do
      base = Azure::Armrest::BaseModel.new(JSON.parse(json))
      expect(base).to be_kind_of(Azure::Armrest::BaseModel)
    end
  end

  context "custom methods" do
    it "defines a resource_group method that returns nil by default" do
      expect(base).to respond_to(:resource_group)
      expect(base.resource_group).to eq(nil)
    end

    it "returns the expected value for the resource_group method" do
      json = {:id => '/foo/bar/resourceGroups/foo/x/y/z'}
      base = Azure::Armrest::BaseModel.new(json)
      expect(base.resource_group).to eq('foo')
    end
  end

  context "reserved hashes" do
    it "returns the expected hash for the tags method when defined" do
      json = {:name => 'test', :tags => {:foo => 1, :bar => 2}}
      base = Azure::Armrest::BaseModel.new(json)
      expect(base.tags).to eq({:foo => 1, :bar => 2})
    end

    it "returns the expected hash for the tags and other declared methods when defined" do
      json = {:name => 'test', :tags => {:foo => 1, :bar => 2}, :users => {:foo => 3, :bar => 4} }
      test = Class.new(Azure::Armrest::BaseModel) do
        attr_hash :users
      end.new(json)

      expect(test.tags).to eq({:foo => 1, :bar => 2})
      expect(test.users).to eq({:foo => 3, :bar => 4})
    end

    it "returns the expected hash for declared nested methods" do
      json = {
        :name => 'test',
        :attr1 => {
          :attr2 => [
            :attr3 => {:foo => 1, :bar => 2},
            :attr4 => {:foo => 3, :bar => 4}
          ]
        }
      }

      test = Class.new(Azure::Armrest::BaseModel) do
        attr_hash 'attr1#attr2#attr3'
      end.new(json)

      expect(test.attr1.attr2[0].attr3).to eq({:foo => 1, :bar => 2})
      expect(test.attr1.attr2[0].attr4).to be_kind_of(Azure::Armrest::BaseModel)
    end
  end

  context "inspection methods" do
    it "defines a to_s method that returns the original json" do
      expect(base.to_s).to eq(json)
    end

    it "defines a to_str method that returns the original json" do
      expect(base.to_str).to eq(json)
    end

    it "defines a to_json method that returns the original json" do
      expect(base.to_json).to eq(json)
    end

    it "defines a custom inspect method" do
      json = {:name => 'test', :age => 33}.to_json
      base = Azure::Armrest::BaseModel.new(json)
      expected = '<Azure::Armrest::BaseModel name="test", age=33>'
      expect(base.inspect).to eq(expected)
    end
  end

  context "dynamic method generation" do
    it "defines snake_case for each dynamic method" do
      expect(base).to respond_to(:first_name)
      expect(base).to respond_to(:last_name)
      expect(base).to respond_to(:address)
    end

    it "removes camel_case methods default from open_struct conversion" do
      expect(base).not_to respond_to(:firstName)
      expect(base).not_to respond_to(:lastName)
    end

    it "allows you to chain dynamic methods" do
      expect(base.address).to respond_to(:street)
      expect(base.address).to respond_to(:zipcode)
    end

    it "defines an underscore alias for any existing methods" do
      Object.class_eval{ def temp_stuff; 'hi'; end }
      Object.class_eval{ def tempStuff; 'hello'; end }

      json = {:name => 'test', :temp_stuff => 33, :tempStuff => 44}.to_json
      base = Azure::Armrest::BaseModel.new(json)

      expect(base).to respond_to(:_temp_stuff)
      expect(base).to respond_to(:_tempStuff)
      expect(base._temp_stuff).to eq(33)
      expect(base._tempStuff).to eq(44)
      expect(base.temp_stuff).to eq('hi')
      expect(base.tempStuff).to eq('hello')
    end
  end

  context "dynamic accessors" do
    it "returns expected value for first_name method" do
      expect(base.first_name).to eq('jeff')
    end

    it "returns expected value for last_name method" do
      expect(base.last_name).to eq('durand')
    end

    it "returns an object instantiated from a subclass of BaseModel for address method" do
      expect(base.address).to be_kind_of(Azure::Armrest::BaseModel)
    end

    it "returns expected value for zipcode method" do
      expect(base.address.zipcode).to eq('01013')
    end
  end

  context "equal comparison" do
    it "evaluates true for == when two models are constructed from the same data" do
      expect(base == Azure::Armrest::BaseModel.new(json)).to be true
    end

    it "evaluates true for eql? when two models are constructed from the same data" do
      expect(base.eql?(Azure::Armrest::BaseModel.new(json))).to be true
    end
  end
end
