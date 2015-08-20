########################################################################
# armrest_manager_configure_spec.rb
#
# Test suite for the Azure::Armrest::ArmrestManager class.
########################################################################
require 'spec_helper'

describe "ArmrestManager" do
  context "configuration" do
    it "detects whether global options have been configured" do
      expect(Azure::Armrest::ArmrestManager.configured?).to be_false

      expect(RestClient).to receive(:post).with(anything, anything).and_return(
        '{"access_token":"atoken"}')
      Azure::Armrest::ArmrestManager.configure(
        :subscription_id => "sid",
        :client_id       => "cid",
        :client_key      => "ckey",
        :tenant_id       => "tid"
      )
      expect(Azure::Armrest::ArmrestManager.configured?).to be_true
    end
  end
end
