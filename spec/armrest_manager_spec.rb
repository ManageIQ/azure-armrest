########################################################################
# armrest_manager_manager_spec.rb
#
# Test suite for the Azure::ArmRest::ArmRestManager class.
########################################################################
require 'azure/armrest'
require 'rspec/autorun'

describe "ArmRestManager" do
  before do
    @sub = 'abc-123-def-456'
    @res = 'my_resource_group'
    @cid = "XXXXX"
    @key = "YYYYY"
    @ten = "ZZZZZ"

    @params = {
      :subscription_id => @sub,
      :resource_group  => @res,
      :client_id       => @cid,
      :client_key      => @key,
      :tenant_id       => @ten
    }

    @arm = nil
  end

  context "constructor" do
    it "returns an armrest manager instance as expected" do
      @arm = Azure::ArmRest::ArmRestManager.new(@params)
      expect(@arm).to be_kind_of(Azure::ArmRest::ArmRestManager)
    end
  end

  after do
    @sub = nil
    @res = nil
    @cid = nil
    @key = nil
    @ten = nil
    @arm = nil
    @params = nil
  end
end
