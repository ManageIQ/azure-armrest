########################################################################
# configuration_spec.rb
#
# Specs for the Azure::Armrest::Configuration class.
########################################################################
require 'spec_helper'
require 'timecop'

describe 'Configuration' do
  before { setup_params }

  let(:options) do
    {
      :client_id       => 'cid' + Time.now.to_f.to_s,
      :client_key      => 'ckey',
      :tenant_id       => 'tid',
      :subscription_id => 'sid'
    }
  end

  let(:log) { 'azure-armrest.log' }
  let(:proxy) { 'http://www.somewebsiteyyyyzzzz.com/bogusproxy' }
  let(:singleton) { Azure::Armrest::Configuration }
  let(:token_response) { '{"expires_in":"3599","access_token":"eyJ0eXAiOiJKV1Q"}' }
  let(:providers_response) { @providers_response }

  before(:each) do
    allow_any_instance_of(singleton).to receive(:fetch_providers).and_return(providers_response)
    @config = Azure::Armrest::Configuration.new(options)
  end

  after(:each) do
    File.delete(log) if File.exist?(log)
  end

  context 'constructor' do
    it 'requires a single argument' do
      expect { Azure::Armrest::Configuration.new }.to raise_error(ArgumentError)
    end

    it 'requires a client_id' do
      options.delete(:client_id)
      expect { Azure::Armrest::Configuration.new(options) }.to raise_error(ArgumentError)
    end

    it 'requires a client_key' do
      options.delete(:client_key)
      expect { Azure::Armrest::Configuration.new(options) }.to raise_error(ArgumentError)
    end

    it 'requires a subscription_id' do
      options.delete(:subscription_id)
      expect { Azure::Armrest::Configuration.new(options) }.to raise_error(ArgumentError)
    end
  end

  context 'instances' do
    context 'accessors' do
      it 'defines an api_version accessor with a default value' do
        expect(@config).to respond_to(:api_version)
        expect(@config).to respond_to(:api_version=)
        expect(@config.api_version).to eql('2015-01-01')
      end

      it 'defines a resource_group accessor with a default value of nil' do
        expect(@config).to respond_to(:resource_group)
        expect(@config).to respond_to(:resource_group=)
        expect(@config.resource_group).to be_nil
      end

      it 'defines a content_type accessor with a default value' do
        expect(@config).to respond_to(:content_type)
        expect(@config).to respond_to(:content_type=)
        expect(@config.content_type).to eql('application/json')
      end

      it 'defines a grant_type accessor with a default value' do
        expect(@config).to respond_to(:grant_type)
        expect(@config).to respond_to(:grant_type=)
        expect(@config.grant_type).to eql('client_credentials')
      end

      it 'defines an accept accessor with a default value' do
        expect(@config).to respond_to(:accept)
        expect(@config).to respond_to(:accept=)
        expect(@config.accept).to eql('application/json')
      end

      it 'defines a client_id accessor that is set to value from constructor' do
        expect(@config).to respond_to(:client_id)
        expect(@config).to respond_to(:client_id=)
        expect(@config.client_id).to eql(options[:client_id])
      end

      it 'defines a client_key accessor that is set to value from constructor' do
        expect(@config).to respond_to(:client_key)
        expect(@config).to respond_to(:client_key=)
        expect(@config.client_key).to eql(options[:client_key])
      end

      it 'defines a tenant_id accessor that is set to value from constructor' do
        expect(@config).to respond_to(:tenant_id)
        expect(@config).to respond_to(:tenant_id=)
        expect(@config.tenant_id).to eql(options[:tenant_id])
      end

      it 'defines a subscription_id accessor that is set to value from constructor' do
        expect(@config).to respond_to(:subscription_id)
        expect(@config).to respond_to(:subscription_id=)
        expect(@config.subscription_id).to eql(options[:subscription_id])
      end
    end

    context 'cache_key' do
      it 'sets the cache key to a combination of tenant_id, client_id, and client_key' do
        key = [options[:tenant_id], options[:client_id], options[:client_key]].join('_')
        expect(@config.send(:cache_key)).to eql(key)
      end
    end

    context 'http proxy' do
      before(:each) do
        allow(ENV).to receive(:[]).with('http_proxy').and_return(proxy)
      end

      it 'uses the http_proxy environment variable for the proxy value if set' do
        @config = Azure::Armrest::Configuration.new(options)
        expect(@config.proxy).to eq(proxy)
      end

      it 'accepts a URI object for a proxy' do
        uri = URI.parse(proxy)
        @config = Azure::Armrest::Configuration.new(options.merge(:proxy => uri))
        expect(@config.proxy).to eq(proxy)
      end
    end

    context 'providers' do
      it 'defines a providers method that returns the expected value' do
        expect(@config).to respond_to(:providers)
        expect(@config.providers).to eql(providers_response)
      end
    end

    context 'tokens' do
      it 'defines a token method' do
        expect(@config).to respond_to(:token)
      end

      it 'defines a tokens method' do
        expect(@config).to respond_to(:token)
      end

      it 'defines a set_token method which takes a token string an token expiration time' do
        time = Time.now.utc + 1000
        expect(@config).to respond_to(:set_token)
        expect(@config.set_token('xxx', time)).to eql(['xxx', time])
      end

      it 'raises an error if the token expiration is invalid in set_token' do
        expect { @config.set_token('xxx', Time.now.utc - 100) }.to raise_error(ArgumentError)
      end

      it 'defines a token_expiration method that returns the expected value' do
        expect(@config).to respond_to(:token_expiration)
        expect(@config.token_expiration).to be_nil

        time = Time.now.utc + 1000
        @config.set_token('xxx', time)

        expect(@config.token_expiration('xxx')).to eql(time.utc)
        expect(@config.token).to eql('xxx')
        expect(@config.token_expiration('xxx')).to eql(time.utc)
      end

      it 'defines a token_expiration= method that returns the expected value' do
        time = Time.now.utc + 1000
        expect(@config).to respond_to(:token_expiration=)
        expect(@config.token_expiration = time).to eql(time.utc)
      end

      context 'token generation' do
        it 'caches the token to be reused for the same client' do
          token = "Bearer eyJ0eXAiOiJKV1Q"
          expect(RestClient::Request).to receive(:execute).exactly(1).times.and_return(token_response)
          expect(@config.token).to eql(token)
        end

        it 'generates different tokens for different clients' do
          expect(RestClient::Request).to receive(:execute).exactly(2).times.and_return(token_response)
          Azure::Armrest::Configuration.new(options).token
          Azure::Armrest::Configuration.new(options.merge(:client_id => 'cid2')).token
        end

        it 'regenerates the token if the old token expires' do
          expect(RestClient::Request).to receive(:execute).exactly(2).times.and_return(token_response)
          conf = Azure::Armrest::Configuration.new(options)
          conf.token
          Timecop.freeze(Time.now.utc + 3600) { conf.token }
        end
      end
    end
  end

  context 'singletons' do
    before(:each) do
      Azure::Armrest::Configuration.clear_caches
    end

    it 'defines a tokens method' do
      expect(singleton).to respond_to(:token_cache)
    end

    it 'defines a providers method that is an empty Hash initially' do
      expect(singleton).to respond_to(:provider_version_cache)
      expect(singleton.provider_version_cache).to eql({})
    end

    it 'sets the providers class instance variable to the expected hash after an instance is created' do
      Azure::Armrest::Configuration.new(options)
      hash = {
        'microsoft.compute' => {'services' => '2016-03-25', 'operations' => '2016-03-25'},
        'microsoft.storage' => {'stuff' => '2016-03-25'}
      }
      expect(singleton.provider_version_cache).to eql(hash)
    end

    it 'does not set the providers if already set' do
      Azure::Armrest::Configuration.new(options)
      id1 = singleton.provider_version_cache.object_id
      Azure::Armrest::Configuration.new(options)
      id2 = singleton.provider_version_cache.object_id
      expect(id1).to eql(id2)
    end

    it 'defines a clear_caches method that resets tokens, providers and subscriptions' do
      expect(singleton).to respond_to(:clear_caches)
      expect(singleton.clear_caches).to be_empty
      expect(singleton.token_cache).to be_empty
      expect(singleton.provider_version_cache).to be_empty
    end

    context 'logging' do
      it 'accepts a string for a log' do
        Azure::Armrest::Configuration.log = log
        expect(singleton.log).to eq(log)
      end

      it 'accepts a handle for a log' do
        File.open(log, 'w+') do |fh|
          Azure::Armrest::Configuration.log = fh
          expect(singleton.log).to eq(fh)
        end
      end
    end
  end
end
