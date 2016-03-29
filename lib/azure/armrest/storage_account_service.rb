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
      def initialize(configuration, options = {})
        options = {'api_version' => '2015-05-01-preview'}.merge(options) # Must hard code for now
        super(configuration, 'storageAccounts', 'Microsoft.Storage', options)
      end

      # Same as other resource based get methods, but also sets the proxy on the model object.
      #
      def get(name, resource_group = configuration.resource_group)
        super.tap do |m|
          m.proxy       = configuration.proxy
          m.ssl_version = configuration.ssl_version
          m.ssl_verify  = configuration.ssl_verify
        end
      end

      # Same as other resource based list methods, but also sets the proxy on each model object.
      #
      def list(resource_group = configuration.resource_group)
        super.each do |m|
          m.proxy       = configuration.proxy
          m.ssl_version = configuration.ssl_version
          m.ssl_verify  = configuration.ssl_verify
        end
      end

      # Same as other resource based list_all methods, but also sets the proxy on each model object.
      #
      def list_all
        super.each do |m|
          m.proxy       = configuration.proxy
          m.ssl_version = configuration.ssl_version
          m.ssl_verify  = configuration.ssl_verify
        end
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
      #   sas.create(
      #     "your_storage_account",
      #     "your_resource_group",
      #     {
      #       :location   => "West US",
      #       :properties => {:accountType => "Standard_ZRS"},
      #       :tags       => {:YourCompany => true}
      #     }
      #   )
      #
      def create(account_name, rgroup = configuration.resource_group, options)
        validating = options.delete(:validating)
        validate_account_type(options[:properties][:accountType])
        validate_account_name(account_name)

        acct = super(account_name, rgroup, options) do |url|
          url << "&validating=" << validating if validating
        end

        # An initial create call will return nil because the response body is
        # empty. In that case, make another call to get the object properties.
        acct = get(account_name, rgroup) unless acct

        acct.proxy       = configuration.proxy
        acct.ssl_version = configuration.ssl_version
        acct.ssl_verify  = configuration.ssl_verify

        acct
      end

      # Returns the primary and secondary access keys for the given
      # storage account as a hash.
      #
      def list_account_keys(account_name, group = configuration.resource_group)
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
      def regenerate_storage_account_keys(account_name, group = configuration.resource_group, options = {})
        validate_resource_group(group)

        url = build_url(group, account_name, 'regenerateKey')
        response = rest_post(url, options.to_json)
        JSON.parse(response)
      end

      # Returns a list of images that are available for provisioning for all
      # storage accounts in the provided resource group. The custom keys
      # :uri and :operating_system have been added for convenience.
      #
      def list_private_images(group = configuration.resource_group)
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

      def accounts_by_name
        @accounts_by_name ||= list_all.each_with_object({}) { |sa, sah| sah[sa.name] = sa }
      end

      def parse_uri(uri)
        uri = URI.parse(uri)
        host_components = uri.host.split('.')

        rh = {
          :scheme        => uri.scheme,
          :account_name  => host_components[0],
          :service_name  => host_components[1],
          :resource_path => uri.path
        }

        # TODO: support other service types.
        return rh unless rh[:service_name] == "blob"

        blob_components = uri.path.split('/', 3)
        if blob_components[2]
          rh[:container] = blob_components[1]
          rh[:blob]      = blob_components[2]
        else
          rh[:container] = '$root'
          rh[:blob]      = blob_components[1]
        end

        return rh unless uri.query && uri.query.start_with?("snapshot=")
        rh[:snapshot] = uri.query.split('=', 2)[1]
        rh
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
