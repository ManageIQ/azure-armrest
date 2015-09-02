########################################################################
# resource_service_spec.rb
#
# Test suite for the Azure::Armrest::ResourceService class.
########################################################################
require 'spec_helper'

describe "ResourceService" do
  before { setup_params }
  let(:rsrv) { Azure::Armrest::ResourceService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::ResourceService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a rsrv instance as expected" do
      expect(rsrv).to be_kind_of(Azure::Armrest::ResourceService)
    end
  end

  context "accessors" do
    it "defines a provider method" do
      expect(rsrv).to respond_to(:provider)
    end

    it "sets the default provider to the expected value" do
      expect(rsrv.provider).to eq "Microsoft.Resources"
    end
  end

  context "instance methods" do
    it "defines a list method" do
      expect(rsrv).to respond_to(:list)
    end

    it "defines a move method" do
      expect(rsrv).to respond_to(:move)
    end

    it "defines a check_resource method" do
      expect(rsrv).to respond_to(:check_resource)
    end

    it "defines a check_resource? method" do
      expect(rsrv).to respond_to(:check_resource?)
    end
  end
end
