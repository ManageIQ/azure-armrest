########################################################################
# armest_module_spec.rb
#
# Test suite for the base Azure::Armrest module.
########################################################################
require 'spec_helper'

describe "Armrest" do
  context "module" do
    it "is a module, not a class" do
      expect(Azure::Armrest).to be_a_kind_of(Module)
    end
  end

  context "constants" do
    it "defines the AUTHORITY constant" do
      expect(Azure::Armrest::AUTHORITY).not_to be_nil
      expect(Azure::Armrest::AUTHORITY).to be_a_kind_of(String)
      expect(Azure::Armrest::AUTHORITY).to eql("https://login.windows.net/")
    end

    it "defines the RESOURCE constant" do
      expect(Azure::Armrest::RESOURCE).not_to be_nil
      expect(Azure::Armrest::RESOURCE).to be_a_kind_of(String)
      expect(Azure::Armrest::RESOURCE).to eql("https://management.azure.com/")
    end

    it "defines the COMMON_URI constant" do
      expect(Azure::Armrest::COMMON_URI).not_to be_nil
      expect(Azure::Armrest::COMMON_URI).to be_a_kind_of(String)
      expect(Azure::Armrest::COMMON_URI).to eql("https://management.azure.com/subscriptions/")
    end
  end
end
