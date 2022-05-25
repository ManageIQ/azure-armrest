########################################################################
# environment_spec.rb
#
# Specs for the Azure::Armrest::Environment class
########################################################################
require 'spec_helper'
require 'timecop'

describe Azure::Armrest::Environment do
  let(:options) do
    {
      :name                       => 'test',
      :active_directory_authority => 'https://login.microsoftonline.com/',
      :resource_manager_url       => 'https://management.azure.com/'
    }
  end

  subject { described_class.new(options) }

  context 'constructor' do
    it 'requires a single argument' do
      expect { described_class.new }.to raise_error(ArgumentError)
    end

    it 'requires a name' do
      options.delete(:name)
      expect { described_class.new(options) }.to raise_error(ArgumentError)
    end

    it 'requires a active_directory_authority' do
      options.delete(:active_directory_authority)
      expect { described_class.new(options) }.to raise_error(ArgumentError)
    end

    it 'requires a resource_manager_url' do
      options.delete(:resource_manager_url)
      expect { described_class.new(options) }.to raise_error(ArgumentError)
    end
  end

  context 'instances' do
    it 'defines an name method' do
      expect(subject.name).to eql('test')
    end

    it 'defines an active_directory_authority method' do
      expect(subject.active_directory_authority).to eql('https://login.microsoftonline.com/')
    end

    it 'defines a resource_manager_url method' do
      expect(subject.resource_manager_url).to eql('https://management.azure.com/')
    end

    it 'defines a gallery_url method' do
      expect(subject).to respond_to(:gallery_url)
    end

    it 'defines a graph_url method' do
      expect(subject).to respond_to(:graph_url)
    end

    it 'defines a graph_api_version method' do
      expect(subject).to respond_to(:graph_api_version)
    end

    it 'defines a key_vault_dns_suffix method' do
      expect(subject).to respond_to(:key_vault_dns_suffix)
    end

    it 'defines a key_vault_service_resource_id method' do
      expect(subject).to respond_to(:key_vault_service_resource_id)
    end

    it 'defines a publish_settings_file_url method' do
      expect(subject).to respond_to(:publish_settings_file_url)
    end

    it 'defines a resource_manager_url method' do
      expect(subject).to respond_to(:resource_manager_url)
    end

    it 'defines a service_management_url method' do
      expect(subject).to respond_to(:service_management_url)
    end

    it 'defines a sql_database_dns_suffix method' do
      expect(subject).to respond_to(:sql_database_dns_suffix)
    end

    it 'defines a storage_suffix method' do
      expect(subject).to respond_to(:storage_suffix)
    end

    it 'defines a traffic_manager_dns_suffix method' do
      expect(subject).to respond_to(:traffic_manager_dns_suffix)
    end
  end

  context "aliases" do
    it 'defines an authority_url alias for active_directory_authority' do
      expect(subject.method(:active_directory_authority)).to eql(subject.method(:authority_url))
    end

    it 'defines a login_endpoint alias for active_directory_authority' do
      expect(subject.method(:login_endpoint)).to eql(subject.method(:authority_url))
    end

    it 'defines a resource_url alias for resource_manager_url' do
      expect(subject.method(:resource_url)).to eql(subject.method(:resource_manager_url))
    end

    it 'defines a gallery_endpoint alias for gallery_url' do
      expect(subject.method(:gallery_endpoint)).to eql(subject.method(:gallery_url))
    end

    it 'defines a graph_endpoint alias for graph_url' do
      expect(subject.method(:graph_endpoint)).to eql(subject.method(:graph_url))
    end
  end

  context "predefined environments" do
    it 'defines a Public environment' do
      expect(described_class.constants).to include(:Public)
      expect(described_class::Public).to be_kind_of(described_class)
      expect(described_class::Public.active_directory_authority).to eql('https://login.microsoftonline.com/')
    end

    it 'defines a USGovernment environment' do
      expect(described_class.constants).to include(:USGovernment)
      expect(described_class::USGovernment).to be_kind_of(described_class)
      expect(described_class::USGovernment.active_directory_authority).to eql('https://login.microsoftonline.us/')
    end

    it 'defines a China environment' do
      expect(described_class.constants).to include(:China)
      expect(described_class::China).to be_kind_of(described_class)
      expect(described_class::China.active_directory_authority).to eql('https://login.chinacloudapi.cn')
    end
  end

  context "discovery" do
    let(:json) do
      '{
        "galleryEndpoint": "https://gallery.azure.com/",
        "graphEndpoint": "https://graph.windows.net/",
        "portalEndpoint": "https://portal.azure.com/",
        "authentication": {
          "loginEndpoint": "https://login.windows.net/",
          "audiences": [
            "https://management.core.windows.net/",
            "https://management.azure.com/"
          ]
        }
      }'
    end

    it 'defines a singleton discover method' do
      expect(described_class).to respond_to(:discover)
    end

    it 'returns an environment object for the given resource url' do
      allow(Azure::Armrest::ArmrestService).to receive(:send).and_return(json)
      allow(json).to receive(:body).and_return(json)

      env = described_class.discover(:name => 'Test', :url => 'https://some_endpoint.com')
      expect(env.name).to eql('Test')
      expect(env.gallery_url).to eql('https://gallery.azure.com/')
      expect(env.graph_url).to eql('https://graph.windows.net/')
      expect(env.active_directory_authority).to eql('https://login.windows.net/')
      expect(env.active_directory_resource_id).to eql('https://management.core.windows.net/')
      expect(env.resource_manager_url).to eql('https://some_endpoint.com')
    end
  end
end
