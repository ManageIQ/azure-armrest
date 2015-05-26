module Azure
  module ArmRest
    class StorageAccountManager < ArmRestManager
      # Valid account types for the create or update method.
      VALID_ACCOUNT_TYPES = %w[
        Standard_LRS
        Standard_ZRS
        Standard_GRS
        Standard_RAGRS
      ]

      def initialize(subscription_id, resource_group_name, api_version = '2015-1-1')
        super

        @uri += "/resourceGroups/#{resource_group_name}"
        @uri += "/providers/Microsoft.Storage/storageAccounts"
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

      def delete(account_name)
        url = @uri + "/#{account_name}?api-version=#{api_version}"
        url
      end

      alias update create

      def get(account_name)
        url = @uri + "/#{account_name}?api-version=#{api_version}"
        url
      end

      def list
        url = @uri + "?api-version=#{api_version}"
        url
      end

      #--
      # POST
      #
      def list_account_keys(account_name)
        url = @uri + "/#{account_name}/listKeys?api-version=#{api_version}"
        url
      end

      def regenerate_storage_account_keys(account_name)
        url = @uri + "/#{account_name}/regenerateKey?api-version=#{api_version}"
        url
      end
    end
  end
end
