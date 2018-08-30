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

      # Get information for the specified +secret_name+ in +vault_name+ within
      # the given +resource_group+.
      #
      def get_secret(secret_name, vault_name, resource_group = configuration.resource_group)
        url = build_url(resource_group, vault_name, 'secrets', secret_name)
        model_class.new(rest_get(url))
      end

      # Get a list secrets for the given +vault_name+ within +resource_group+.
      # You may optionally specify the +maxresults+, which defaults to 25.
      #
      def list_secrets(vault_name, resource_group = configuration.resource_group, options = {})
        url = build_url(resource_group, vault_name, 'secrets')
        url << "&maxresults=#{options[:maxresults]}" if options[:maxresults]

        response = rest_get(url)
        get_all_results(response)
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
