########################################################################
# configuration_spec.rb
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
end
