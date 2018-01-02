########################################################################
# configuration_spec.rb
#
# Specs for the Azure::Armrest::Configuration class.
########################################################################
require 'spec_helper'
require 'timecop'

describe Azure::Armrest::Configuration do
  let(:options) do
    {
      :client_id       => 'cid' + Time.now.to_f.to_s,
      :client_key      => 'ckey',
      :tenant_id       => 'tid',
    }
  end

  subject do
    described_class.new(options.symbolize_keys)
  end

  let(:proxy)          { 'http://www.somewebsiteyyyyzzzz.com/bogusproxy' }
  let(:singleton)      { Azure::Armrest::Configuration }
  let(:token_response) { '{"expires_in":"3599","access_token":"eyJ0eXAiOiJKV1Q"}' }

  before { setup_params }

  context 'constructor' do
    it 'requires a single argument' do
      expect { described_class.new }.to raise_error(ArgumentError)
    end

    it 'requires a client_id' do
      options.delete(:client_id)
      expect { described_class.new(options) }.to raise_error(ArgumentError)
    end

    it 'requires a client_key' do
      options.delete(:client_key)
      expect { described_class.new(options) }.to raise_error(ArgumentError)
    end

    it 'does not require a subscription_id' do
      options.delete(:subscription_id)
      expect { described_class.new(options) }.to_not raise_error
    end
  end

  context 'instances' do
    context 'regular methods' do
      it 'defines a subscription_id= method' do
        expect(subject).to respond_to(:subscription_id=)
      end

      it 'defines a subscriptions method' do
        expect(subject).to respond_to(:subscriptions)
      end
    end

    context 'accessors' do
      it 'defines an api_version accessor' do
        expect(subject.api_version).to eql('2017-05-10')
        subject.api_version = '2017-12-01'
        expect(subject.api_version).to eql('2017-12-01')
      end

      it 'defines a resource_group accessor' do
        expect(subject.resource_group).to be_nil
        subject.resource_group = 'agroup'
        expect(subject.resource_group).to eql('agroup')
      end

      it 'defines a client_id accessor' do
        expect(subject.client_id).to eql(options[:client_id])
        subject.client_id = 'new_id'
        expect(subject.client_id).to eql('new_id')
      end

      it 'defines a client_key accessor' do
        expect(subject.client_key).to eql(options[:client_key])
        subject.client_key = 'new_key'
        expect(subject.client_key).to eql('new_key')
      end

      it 'defines a tenant_id accessor' do
        expect(subject.tenant_id).to eql(options[:tenant_id])
        subject.tenant_id = 'new_id'
        expect(subject.tenant_id).to eql('new_id')
      end

      it 'defines a subscription_id reader' do
        allow(subject).to receive(:validate_subscription).and_return(true)
        expect(subject.subscription_id).to eql(options[:subscription_id])
        subject.subscription_id = 'new_id'
        expect(subject.subscription_id).to eql('new_id')
      end

      it 'defines an environment reader' do
        expect(subject.environment).to eql(Azure::Armrest::Environment::Public)
      end
    end

    context 'http proxy' do
      before do
        allow(ENV).to receive(:[]).with('http_proxy').and_return(proxy)
      end

      it 'uses the http_proxy environment variable for the proxy value if set' do
        expect(subject.proxy).to eq(proxy)
      end

      it 'accepts a URI object for a proxy' do
        options['proxy'] = URI.parse(proxy)
        expect(subject.proxy).to eq(proxy)
      end
    end

    context 'providers' do
      it 'defines a providers method that returns the expected value' do
        expect(subject.providers).to eql(@providers_response)
      end

      it 'supports provider and service api version query' do
        expect(subject.provider_default_api_version('microsoft.compute', 'services')).to eql('2016-03-25')
        expect(subject.provider_default_api_version('Microsoft.Compute', 'operations')).to eql('2016-03-25')
        expect(subject.provider_default_api_version('microsoft.storage', 'Stuff')).to eql('2016-03-25')
      end
    end

    context 'tokens' do
      it 'raises an error if the token expiration is invalid' do
        token = Azure::Armrest::Token.new(:access_token => 'xxx', :expires_on => Time.now - 100)
        expect { subject.token = token }.to raise_error(ArgumentError)
      end

      context 'token generation' do
        it 'caches the token to be reused for the same client' do
          token = "Bearer eyJ0eXAiOiJKV1Q"
          expect(Excon).to receive(:execute).exactly(1).times.and_return(token_response)
          expect(subject.token.access_token).to eql(token)
        end

        it 'generates different tokens for different clients' do
          expect(Excon).to receive(:execute).exactly(2).times.and_return(token_response)
          subject.token
          described_class.new(options.merge(:client_id => 'cid2')).token
        end

        it 'regenerates the token if the old token expires' do
          expect(Excon).to receive(:execute).exactly(2).times.and_return(token_response)
          subject.token
          Timecop.freeze(Time.now.utc + 3600) { subject.token }
        end
      end
    end

    context 'subscription validation' do
      it 'raises an error if the subscription is invalid' do
        allow_any_instance_of(Azure::Armrest::Configuration).to receive(:validate_subscription).and_raise(ArgumentError)
        expect { Azure::Armrest::Configuration.new(options) }.to raise_error(ArgumentError)
      end
    end
  end

  context 'logging' do
    before(:all) { @log = 'azure-armrest.log' }
    after(:all) { File.delete(@log) if File.exist?(@log) }

    after { subject.log.close }

    it 'accepts a file name for a log' do
      subject.log = @log
      expect(subject.log).to be_kind_of(Logger)
    end

    it 'accepts a file handle for a log' do
      File.open(@log, 'w+') do |fh|
        subject.log = fh
        expect(subject.log).to be_kind_of(Logger)
      end
    end

    it 'accepts a Logger instance' do
      logger = Logger.new($stdout.dup)
      subject.log = logger
      expect(subject.log).to eq(logger)
    end
  end
end
