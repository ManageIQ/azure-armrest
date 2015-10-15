module Azure
  module Armrest
    # Class for managing storage accounts.
    class StorageAccountService < ResourceGroupBasedService

      # Valid account types for the create or update method.
      VALID_ACCOUNT_TYPES = %w[
        Standard_LRS
        Standard_ZRS
        Standard_GRS
        Standard_RAGRS
      ]

      # Creates and returns a new StorageAccountService (SAS) instance.
      #
      def initialize(_armrest_configuration, options = {})
        super
        @provider = options[:provider] || 'Microsoft.Storage'
        #set_service_api_version(options, 'storageAccounts')
        @api_version = '2015-05-01-preview' # Must hard code for now
        @service_name = 'storageAccounts'
      end

      # Creates a new storage account, or updates an existing account with the
      # specified parameters.
      #
      # Note that the name of the storage account within the specified
      # must be 3-24 alphanumeric lowercase characters.
      #
      # The options available are as follows:
      #
      # - :validating
      #   Optional. Set to 'nameAvailability' to indicate that the account
      #   name must be checked for global availability.
      #
      # - :properties
      #   - :accountType
      #     The type of storage account, e.g. "Standard_GRS".
      #
      # - :location
      #   Required: One of the Azure geo regions, e.g. 'West US'.
      #
      # - :tags
      #   A hash of tags to describe the resource. You may have a maximum of
      #   10 tags, and each key has a max size of 128 characters, and each
      #   value has a max size of 256 characters. These are optional.
      #
      # Example:
      #
      #   sas = Azure::Armrest::StorageAccountService(config)
      #
      #   sas.create("yourstorageaccount1",
      #     {
      #       :location   => "West US",
      #       :properties => {:accountType => "Standard_ZRS"},
      #       :tags       => {:YourCompany => true}
      #     },
      #     "yourresourcegroup"
      #   )
      #
      def create(account_name, rgroup = armrest_configuration.resource_group, options)
        validating = options.delete(:validating)
        validate_account_type(options[:properties][:accountType])
        validate_account_name(account_name)

        super(account_name, rgroup, options) do |url|
          url << "&validating=" << validating if validating
        end
      end


      # Returns the primary and secondary access keys for the given
      # storage account as a hash.
      #
      def list_account_keys(account_name, group = armrest_configuration.resource_group)
        raise ArgumentError, "must specify resource group" unless group

        url = build_url(group, account_name, 'listKeys')
        response = rest_post(url)
        JSON.parse(response)
      end

      # Regenerates the primary and secondary access keys for the given
      # storage account.
      #
      # options have only one key with two possible values:
      #   {
      #     "keyName": "key1|key2"
      #   }
      #
      def regenerate_storage_account_keys(account_name, group = armrest_configuration.resource_group, options)
        raise ArgumentError, "must specify resource group" unless group

        url = build_url(group, account_name, 'regenerateKey')
        response = rest_post(url, options.to_json)
        JSON.parse(response)
      end

      private

      def validate_account_type(account_type)
        unless VALID_ACCOUNT_TYPES.include?(account_type)
          raise ArgumentError, "invalid account type '#{account_type}'"
        end
      end

      def validate_account_name(name)
        if name.size < 3 || name.size > 24 || name[/\W+/]
          raise ArgumentError, "name must be 3-24 alpha-numeric characters only"
        end
      end
    end
  end
end
