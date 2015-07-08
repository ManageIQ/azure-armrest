########################################################################
# armest_module_spec.rb
#
# Test suite for the base Azure::Armrest module.
########################################################################

require 'spec_helper'

describe "Armrest" do
  context "module" do
    it "is a module, not a class" do
      Azure::Armrest.should be_a_kind_of(Module)
    end
  end

  context "constants" do
    it "defines the AUTHORITY constant" do
      Azure::Armrest::AUTHORITY.should_not be_nil
      Azure::Armrest::AUTHORITY.should be_a_kind_of(String)
      Azure::Armrest::AUTHORITY.should eql("https://login.windows.net/")
    end

    it "defines the RESOURCE constant" do
      Azure::Armrest::RESOURCE.should_not be_nil
      Azure::Armrest::RESOURCE.should be_a_kind_of(String)
      Azure::Armrest::RESOURCE.should eql("https://management.azure.com/")
    end

    it "defines the COMMON_URI constant" do
      Azure::Armrest::COMMON_URI.should_not be_nil
      Azure::Armrest::COMMON_URI.should be_a_kind_of(String)
      Azure::Armrest::COMMON_URI.should eql("https://management.azure.com/subscriptions/")
    end
  end
end
