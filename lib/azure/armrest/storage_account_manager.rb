module Azure
  module ArmRest
    # Class for managing storage accounts.
    class StorageAccountManager < ArmRestManager

      # Valid account types for the create or update method.
      VALID_ACCOUNT_TYPES = %w[
        Standard_LRS
        Standard_ZRS
        Standard_GRS
        Standard_RAGRS
      ]

      # Creates and returns a new StorageAccountManager (SAM) instance. Most
      # methods for a SAM instance will return a StorageAccount object.
      def initialize(options = {})
        super

        @base_url += "resourceGroups/#{@resource_group}/"
        @base_url += "providers/Microsoft.Storage/storageAccounts"
      end

      # Creates a new storage account, or updates an existing account with the
      # specified parameters. The possible parameters are:
      #
      # - :account_name
      #   Required. The name of the storage account within the specified
      #   resource stack. Must be 3-24 alphanumeric lowercase characters.
      #
      # - :validating
      #   Optional. Set to 'nameAvailability' to indicate that the account
      #   name must be checked for global availability.
      #
      # - :location
      #   Required: One of the Azure geo regions, e.g. 'West US'.
      #
      # - :tags
      #   A hash of tags to describe the resource. You may have a maximum of
      #   10 tags, and each key has a max size of 128 characters, and each
      #   value has a max size of 256 characters.
      #
      # -:properties
      #   - :account_type
      #   - :custom_domains
      #     - :custom_domain
      #       - :name
      #       - :use_subdomain_name
      #--
      # PUT
      #
      def create(option = {})
        #account_name = options.fetch(:account_name)
        #location = options.fetch(:location)
        validating = options[:validating]
        #tags = options[:tags]

        url = @uri + "/#{account_name}"

        if validating
          url += "?validating=nameAvailability"
        end

        url
      end

      alias update create

      # Delete the given storage account name.
      def delete(account_name)
        url = @uri + "/#{account_name}?api-version=#{api_version}"
        url
      end

      # Return information for the given storage account name.
      def get(account_name)
        url = @uri + "/#{account_name}?api-version=#{api_version}"
        url
      end

      # List all storage accounts for the given resource group.
      def list
        url = @uri + "?api-version=#{api_version}"
        url
      end

      # Returns the primary and secondary access keys for the given
      # storage account.
      #--
      # POST
      #
      def list_account_keys(account_name)
        url = @uri + "/#{account_name}/listKeys?api-version=#{api_version}"
        url
      end

      # Regenerates the primary and secondary access keys for the given
      # storage account.
      #--
      # POST
      def regenerate_storage_account_keys(account_name)
        url = @uri + "/#{account_name}/regenerateKey?api-version=#{api_version}"
        url
      end
    end
  end
end
