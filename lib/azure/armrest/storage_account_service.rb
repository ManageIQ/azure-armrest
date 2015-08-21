module Azure
  module Armrest
    # Class for managing storage accounts.
    class StorageAccountService < ArmrestService

      # Valid account types for the create or update method.
      VALID_ACCOUNT_TYPES = %w[
        Standard_LRS
        Standard_ZRS
        Standard_GRS
        Standard_RAGRS
      ]

      # Creates and returns a new StorageAccountService (SAM) instance. Most
      # methods for a SAM instance will return a StorageAccount object.
      def initialize(_armrest_configuration, _options = {})
        super
      end

      # Return information for the given storage account name for the
      # provided +group+. If no group is specified, it will use the
      # group set in the constructor.
      #
      # Example:
      #
      #   sam.get('portalvhdstjn1ty0dlc2dg')
      #   sam.get('portalvhdstjn1ty0dlc2dg', 'Default-Storage-CentralUS')
      #
      def get(account_name, group = armrest_configuration.resource_group)
        set_default_subscription

        raise ArgumentError, "must specify resource group" unless group

        @api_version = '2014-06-01'
        url = build_url(armrest_configuration.subscription_id, group, account_name)

        JSON.parse(rest_get(url))
      end

      # Returns a list of available storage accounts for the given subscription
      # for the provided +group+, or all resource groups if none is provided.
      #
      def list(group = armrest_configuration.resource_group)
        if group
          @api_version = '2014-06-01'
          url = build_url(armrest_configuration.subscription_id, group)
          JSON.parse(rest_get(url))['value'].first
        else
          array = []
          threads = []

          resource_groups.each do |rg|
            @api_version = '2014-06-01' # Must be set after resource_groups call
            url = build_url(armrest_configuration.subscription_id, rg['name'])

            threads << Thread.new do
              result = JSON.parse(rest_get(url))['value'].first
              array << result if result
            end
          end

          threads.each(&:join)

          array
        end
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

      private

      # Builds a URL based on subscription_id an resource_group and any other
      # arguments provided, and appends it with the api-version.
      def build_url(subscription_id, resource_group, *args)
        url = File.join(
          Azure::Armrest::COMMON_URI,
          subscription_id,
          'resourceGroups',
          resource_group,
          'providers',
          'Microsoft.ClassicStorage',
          'storageAccounts',
        )

        url = File.join(url, *args) unless args.empty?
        url << "?api-version=#{@api_version}"
      end
    end
  end
end
