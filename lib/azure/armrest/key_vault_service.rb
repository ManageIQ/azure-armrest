# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Base class for managing key vaults.
    class KeyVaultService < ResourceGroupBasedService
      # Create and return a new KeyVaultService instance.
      #
      def initialize(configuration, options = {})
        super(configuration, 'vaults', 'Microsoft.KeyVault', options)
      end

      # Gets the deleted Azure key vault.
      #
      def get_deleted(vault_name, location)
        url = File.join(base_url, 'providers', provider, 'locations', location, 'deletedVaults', vault_name)
        url << "?api-version=#{api_version}"
        response = rest_get(url)
        get_all_results(response)
      end

      # Gets information about the deleted vaults in a subscription.
      #
      def list_deleted
        url = File.join(base_url, 'providers', provider, 'deletedVaults') + "?api-version=#{api_version}"
        response = rest_get(url)
        get_all_results(response)
      end

      # Permanently removes the deleted +vault_name+ at +location+.
      #
      def purge_deleted(vault_name, location)
        url = File.join(base_url, 'providers', provider, 'locations', location, 'deletedVaults', vault_name, 'purge')
        url << "?api-version=#{api_version}"
        response = rest_post(url)
        get_all_results(response)
      end
    end
  end
end
