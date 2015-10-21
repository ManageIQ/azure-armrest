require 'spec_helper'
require "timecop"

describe "ArmrestService" do
  let(:options) do
    Hash(
      :client_id  => 'cid' + Time.now.to_f.to_s,
      :client_key => 'ckey',
      :tenant_id  => 'tid'
    )
  end

  let(:options_with_subscription) do
    options.merge(:subscription_id => 'sid')
  end

  let(:token_response) do
    '{"expires_in":"3599","access_token":"eyJ0eXAiOiJKV1Q"}'
  end

  context 'token generation' do
    it 'caches the token to be reused for the same client' do
      token = "Bearer eyJ0eXAiOiJKV1Q"
      expect(RestClient).to receive(:post).exactly(1).times.and_return(token_response)
      expect(Azure::Armrest::ArmrestService.configure(options_with_subscription).token).to eql(token)
      Azure::Armrest::ArmrestService.configure(options_with_subscription).token
    end

    it 'generates different tokens for different clients' do
      expect(RestClient).to receive(:post).exactly(2).times.and_return(token_response)
      Azure::Armrest::ArmrestService.configure(options_with_subscription).token
      Azure::Armrest::ArmrestService.configure(options_with_subscription.merge(:client_id => 'cid2')).token
    end

    it 'regenerates the token if the old token expires' do
      expect(RestClient).to receive(:post).exactly(2).times.and_return(token_response)
      conf = Azure::Armrest::ArmrestService.configure(options_with_subscription)
      conf.token
      Timecop.freeze(Time.now + 3600) {conf.token}
    end
  end

  context 'auto fill attributes' do
    let(:subscription_response) do
      '{"value":[{"id":"/subscriptions/4f5a544b","subscriptionId":"4f5a544b"}]}'
    end

    it 'fills some attributes with default values' do
      conf = Azure::Armrest::ArmrestService.configure(options_with_subscription)
      expect(conf.api_version).to_not be_nil
      expect(conf.grant_type).to_not be_nil
      expect(conf.content_type).to_not be_nil
      expect(conf.accept).to_not be_nil
    end

    it 'finds a subscription id if not given' do
      expect(RestClient).to receive(:post).exactly(1).times.and_return(token_response)
      expect(RestClient).to receive(:get).exactly(1).times.and_return(subscription_response)
      conf = Azure::Armrest::ArmrestService.configure(options)
      expect(conf.subscription_id).to eql('4f5a544b')
    end
  end
end
