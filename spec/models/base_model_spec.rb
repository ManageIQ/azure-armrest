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

  let(:hash) do
    {
      'firstName' => 'jeff',
      'lastName'  => 'durand',
      'address'   => {'street' => '22 charlotte rd', 'zipcode' => '01013'}
    }
  end

  let(:base) { Azure::Armrest::BaseModel.new(json) }

  context "constructor" do
    it "constructs a BaseModel instance from a JSON string" do
      expect(base).to be_kind_of(Azure::Armrest::BaseModel)
    end

    it "constructs a BaseModel instance from a Hash object" do
      base = Azure::Armrest::BaseModel.new(hash)
      expect(base).to be_kind_of(Azure::Armrest::BaseModel)
    end

    it "constructs a BaseModel instance without name conflicting" do
      class Conflict; end
      base = Azure::Armrest::BaseModel.new(hash.merge(:conflict => {}))
      expect(base.conflict).to be_kind_of(Azure::Armrest::BaseModel::Conflict)
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

    it "returns the expected value for the resource_group if no trailing slash" do
      json = {:id => '/foo/bar/resourceGroups/foo'}
      base = Azure::Armrest::BaseModel.new(json)
      expect(base.resource_group).to eq('foo')
    end

    it "defines a subscription_id method that returns nil by default" do
      expect(base).to respond_to(:subscription_id)
      expect(base.subscription_id).to eq(nil)
    end

    it "returns the expected value for the subscription_id method" do
      json = {:id => '/subscriptions/bar_sub/resourceGroups/foo/x/y/z'}
      base = Azure::Armrest::BaseModel.new(json)
      expect(base.subscription_id).to eq('bar_sub')
    end

    it "returns the expected value for the subscription_id if no trailing slash" do
      json = {:id => '/subscriptions/bar_sub'}
      base = Azure::Armrest::BaseModel.new(json)
      expect(base.subscription_id).to eq('bar_sub')
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

      Test = Class.new(Azure::Armrest::BaseModel) do
        attr_hash 'attr1#attr2#attr3'
      end
      test = Test.new(json)

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

    it "defines a to_h method that returns the original hash" do
      expect(base.to_h).to eql(hash)
    end

    it "defines a custom inspect method" do
      json = {:name => 'test', :age => 33}.to_json
      base = Azure::Armrest::BaseModel.new(json)
      expected = /^#<Azure::Armrest::BaseModel:0x\h+ name="test", age=33>$/
      expect(base.inspect).to match(expected)
    end

    it "defines a pretty_print method when pp is available" do
      json = {:name => 'test', :age => 33, :array => ["stuff"]}.to_json
      base = Azure::Armrest::BaseModel.new(json)
      expected = /\A#<Azure::Armrest::BaseModel:0x\h+\n/
      expect(base.pretty_inspect).to match(expected)
      expect(base.pretty_inspect).to include('name="test"')
      expect(base.pretty_inspect).to include('age=33')
      expect(base.pretty_inspect).to include('array=["stuff"]')
    end

    it "handles an array of models when converting to json" do
      expect([base, base].to_json).to include(json)
    end
  end

  context "dynamic method generation" do
    it "defines snake_case for each dynamic method" do
      expect(base).to respond_to(:first_name)
      expect(base).to respond_to(:last_name)
      expect(base).to respond_to(:address)
    end

    it "does not respond to removes camel_case methods" do
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

      json = {:name => 'test', :tempStuff => 44}.to_json
      base = Azure::Armrest::BaseModel.new(json)

      expect(base).to respond_to(:_temp_stuff)
      expect(base).not_to respond_to(:_tempStuff)
      expect(base._temp_stuff).to eq(44)
      expect(base.temp_stuff).to eq('hi')
      expect(base.tempStuff).to eq('hello')
    end

    it "handles all-caps keys as expected" do
      json = {'TIMESTAMP' => 123}
      base = Azure::Armrest::BaseModel.new(json)
      expect(base).to respond_to(:timestamp)
    end

    it "handles a mix of lowercase and all-caps keys as expected" do
      json = {'TIMESTAMP' => 123, 'timestamp' => 456}
      base = Azure::Armrest::BaseModel.new(json)
      expect(base).to respond_to(:timestamp)
      expect(base.timestamp).to eq(123)
      expect(base).to respond_to(:_timestamp)
      expect(base._timestamp).to eq(456)
    end

    it "handles strings with spaces as expected" do
      json = {'Foo Bar' => 123}
      base = Azure::Armrest::BaseModel.new(json)
      expect(base).to respond_to(:foo_bar)
      expect(base.foo_bar).to eq(123)
    end
  end

  context "dynamic accessors" do
    it "returns expected value for first_name method" do
      expect(base.first_name).to eq('jeff')
    end

    it "returns expected value for last_name method" do
      expect(base.last_name).to eq('durand')
    end

    it "returns an object instantiated from a named class derived from BaseModel for address method" do
      puts base.address.class
      expect(base.address).to be_kind_of(Azure::Armrest::BaseModel::Address)
    end

    it "returns expected value for zipcode method" do
      expect(base.address.zipcode).to eq('01013')
    end

    it "supports hash style accessors" do
      expect(base['firstName']).to eq('jeff')

      base['firstName'] = 'bob'
      expect(base['firstName']).to eq('bob')
      expect(base.first_name).to eq('bob')
    end

    it "defines new accessor methods to newly added hash key/value" do
      expect(base).not_to respond_to(:birth_place)
      expect(base).not_to respond_to(:birth_place=)

      base['birthPlace'] = 'dc'
      expect(base.birth_place).to eq('dc')

      base.birth_place = 'ca'
      expect(base.birth_place).to eq('ca')
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

  describe "#attr_from_hash" do
    around(:each) do |example|
      class ::SubKlass < Azure::Armrest::BaseModel
        attr_from_hash :first_name => :firstName
      end

      example.run

      Object.send(:remove_const, :SubKlass)
    end

    subject { SubKlass.new(json) }

    it "defines the accessor_method for the given attr name/hash key pair" do
      expect(subject.first_name_from_hash).to eq("jeff")
    end

    it "maps it source location to the correct file" do
      expect(subject.method(:first_name_from_hash).source_location).to include(__FILE__)
    end

    context "with multiple attributes" do
      around(:each) do |example|
        class ::SubKlass2 < Azure::Armrest::BaseModel
          attr_from_hash :first_name => :firstName,
                         :last_name  => :lastName
        end

        example.run

        Object.send(:remove_const, :SubKlass2)
      end
      subject { SubKlass2.new(json) }

      it "defines the accessor_method for each of the given attr name/hash key pairs" do
        expect(subject.first_name_from_hash).to eq("jeff")
        expect(subject.last_name_from_hash).to eq("durand")
      end

      it "maps it source location of each method to the correct file" do
        expect(subject.method(:first_name_from_hash).source_location).to include(__FILE__)
        expect(subject.method(:last_name_from_hash).source_location).to include(__FILE__)
      end
    end
  end
end
