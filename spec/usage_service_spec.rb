########################################################################
# usage_service_spec.rb
#
# Test suite for the Azure::Armrest::Billing::UsageService class.
########################################################################
require 'spec_helper'

describe "UsageService" do
  before { setup_params }
  let(:usrv) { Azure::Armrest::Billing::UsageService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::Billing::UsageService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a usrv instance as expected" do
      expect(usrv).to be_kind_of(Azure::Armrest::Billing::UsageService)
    end
  end

  context "accessors" do
    it "defines a provider method" do
      expect(usrv).to respond_to(:provider)
    end

    it "sets the default provider to the expected value" do
      expect(usrv.provider).to eq "Microsoft.Commerce"
    end
  end

  context "instance methods" do
    it "defines a list method" do
      expect(usrv).to respond_to(:list)
    end
  end
end
