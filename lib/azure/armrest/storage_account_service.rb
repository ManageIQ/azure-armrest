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

      # Return information for the given storage account name for the
      # provided +group+. If no group is specified, it will use the
      # group set in the constructor.
      #
      # If the +include_keys+ option is set to true, then the keys for that
      # storage account will be included in the output as well.
      #
      # Example:
      #
      #   sas.get('portalvhds1234', 'Default-Storage-CentralUS')
      #
      def get(account_name, group = armrest_configuration.resource_group, include_keys = false)
        storage = super(account_name, group) { |url| puts url; 'abc/bad' }

        if include_keys
          skeys = list_account_keys(account_name, group)
          skeys.each{ |k,v| storage.properties[k] = v }
        end

        storage
      end

      # Creates a new storage account, or updates an existing account with the
      # specified parameters. The possible parameters are:
      #
      # - :name
      #   Required. The name of the storage account within the specified
      #   resource stack. Must be 3-24 alphanumeric lowercase characters.
      #
      # - :validating
      #   Optional. Set to 'nameAvailability' to indicate that the account
      #   name must be checked for global availability.
      #
      # - :type
      #   The type of storage account. The default is "Standard_GRS".
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
      #       :location => "West US",
      #       :type     => "Standard_ZRS",
      #       :tags     => {:YourCompany => true}
      #     },
      #     "yourresourcegroup"
      #   )
      #
      def create(account_name, options = {}, rgroup = armrest_configuration.resource_group)
        # Mandatory options
        location = options.fetch(:location)

        # Optional
        tags = options[:tags]
        type = options[:type] || "Standard_GRS"

        properties = {:accountType => type}

        validate_account_type(type)
        validate_account_name(account_name)

        body = {
          :location   => location,
          :tags       => tags,
          :properties => properties
        }

        super(account_name, body, rgroup) do |url|
          url << "&validating=" << options[:validating] if options[:validating]
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
      def regenerate_storage_account_keys(account_name)
        raise ArgumentError, "must specify resource group" unless group

        url = build_url(group, account_name, 'regenerateKey')
        response = rest_post(url)
        response.return!
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
