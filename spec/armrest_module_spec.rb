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
end
