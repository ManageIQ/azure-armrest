########################################################################
# resource_manager_spec.rb
#
# Test suite for the Azure::Armrest::ResourceManager class.
########################################################################
require 'spec_helper'

describe "ResourceManager" do
  before { setup_params }
  let(:rmgr) { Azure::Armrest::ResourceManager.new(@params) }

  context "inheritance" do
    it "is a subclass of ArmrestManager" do
      expect(Azure::Armrest::ResourceManager.ancestors).to include(Azure::Armrest::ArmrestManager)
    end
  end

  context "constructor" do
    it "returns a rmgr instance as expected" do
      expect(rmgr).to be_kind_of(Azure::Armrest::ResourceManager)
    end
  end

  context "accessors" do
    it "defines a provider method" do
      expect(rmgr).to respond_to(:provider)
    end

    it "sets the default provider to the expected value" do
      expect(rmgr.provider).to eq "Microsoft.Resources"
    end
  end

  context "instance methods" do
    it "defines a list method" do
      expect(rmgr).to respond_to(:list)
    end

    it "defines a move method" do
      expect(rmgr).to respond_to(:move)
    end

    it "defines a check_resource method" do
      expect(rmgr).to respond_to(:check_resource)
    end

    it "defines a check_resource? method" do
      expect(rmgr).to respond_to(:check_resource?)
    end
  end
end
