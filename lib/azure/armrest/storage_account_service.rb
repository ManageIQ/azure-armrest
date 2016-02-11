require 'azure-signature'

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
      def initialize(armrest_configuration, options = {})
        options = {'api_version' => '2015-05-01-preview'}.merge(options) # Must hard code for now
        super(armrest_configuration, 'storageAccounts', 'Microsoft.Storage', options)
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
        validate_resource_group(group)

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
        validate_resource_group(group)

        url = build_url(group, account_name, 'regenerateKey')
        response = rest_post(url, options.to_json)
        JSON.parse(response)
      end

      # Returns a list of images that are available for provisioning for all
      # storage accounts in the provided resource group. The custom keys
      # :uri and :operating_system have been added for convenience.
      #
      def list_private_images(group = armrest_configuration.resource_group)
        results = []
        threads = []
        mutex = Mutex.new

        list(group).each do |lstorage_account|
          threads << Thread.new(lstorage_account) do |storage_account|
            key = list_account_keys(storage_account.name, group).fetch('key1')

            storage_account.all_blobs(key).each do |blob|
              next unless File.extname(blob.name).downcase == '.vhd'
              next unless blob.properties.lease_state.downcase == 'available'

              blob_properties = storage_account.blob_properties(blob.container, blob.name, key)
              next unless blob_properties.respond_to?(:x_ms_meta_microsoftazurecompute_osstate)
              next unless blob_properties.x_ms_meta_microsoftazurecompute_osstate.downcase == 'generalized'

              mutex.synchronize do
                hash = blob.to_h.merge(
                  :storage_account  => storage_account.to_h,
                  :blob_properties  => blob_properties.to_h,
                  :operating_system => blob_properties.try(:x_ms_meta_microsoftazurecompute_ostype),
                  :uri => File.join(
                    storage_account.properties.primary_endpoints.blob,
                    blob.container,
                    blob.name
                  )
                )
                results << StorageAccount::PrivateImage.new(hash)
              end
            end
          end
        end

        threads.each(&:join)

        results.flatten
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
