module Azure
  module Armrest
    module Network
      # Class for managing virtual networks.
      class VirtualNetworkService < ArmrestService

        # Creates and returns a new VirtualNetworkService instance.
        #
        def initialize(_armrest_configuration, options = {})
          super
          @provider = options[:provider] || 'Microsoft.Network'
          set_service_api_version(options, 'virtualNetworks')
        end

        # Return information for the given virtual network for the provided
        # +resource_group+. If no group is specified, it will use the resource
        # group set in the constructor.
        #
        # Example:
        #
        #   vns.get('vn_name', 'your_resource_group')
        #
        def get(vn_name, resource_group = armrest_configuration.resource_group)
          raise ArgumentError, "must specify resource group" unless resource_group
          url = build_url(resource_group, vn_name)
          response = rest_get(url)
          Azure::Armrest::Network::VirtualNetwork.new(response)
        end

        # Returns a list of available virtual networks in the current subscription
        # for the provided +resource_group+.
        #
        def list(resource_group = armrest_configuration.resource_group)
          raise ArgumentError, "no resource group provided" unless resource_group
          url = build_url(resource_group)
          response = rest_get(url)
          JSON.parse(response)['value'].map{ |hash| Azure::Armrest::Network::VirtualNetwork.new(hash) }
        end

        # List all virtual networks for the current subscription.
        #
        def list_all
          sub_id = armrest_configuration.subscription_id
          url = File.join(Azure::Armrest::COMMON_URI, sub_id, 'providers', @provider, 'virtualNetworks')
          url << "?api-version=#{@api_version}"
          response = rest_get(url)
          JSON.parse(response)['value'].map{ |hash| Azure::Armrest::Network::VirtualNetwork.new(hash) }
        end

        # Delete the given virtual network in +resource_group+.
        #
        def delete(vn_name, resource_group = armrest_configuration.resource_group)
          raise ArgumentError, "must specify resource group" unless resource_group

          url = build_url(resource_group, vn_name)
          response = rest_delete(url)
          response.return!
        end

        # Create a new virtual network, or update an existing virtual network if it
        # already exists. The first argument is a hash of options.
        #
        # - :location
        # - :tags
        # - :etag
        # - :properties
        #   - :addressSpace
        #     - :addressPrefixes[]
        #   - :dhcpOptions
        #     - :dnsServers[]
        #     - :subnets
        #       [
        #         - :name
        #         - :properties
        #           - :addressPrefix
        #           - :networkSecurityGroup
        #             - :id
        #       ]
        #
        def create(vn_name, options, resource_group = armrest_configuration.resource_group)
          resource_group = options.delete(:resource_group) || resource_group

          raise ArgumentError, "no resource group specified" unless resource_group

          body = options.to_json

          url = build_url(resource_group, vn_name)

          response = rest_put(url, body)
          response.return!
        end

        alias update create

        private

        # Builds a URL based on subscription_id an resource_group and any other
        # arguments provided, and appends it with the api-version.
        def build_url(resource_group, *args)
          url = File.join(
            Azure::Armrest::COMMON_URI,
            armrest_configuration.subscription_id,
            'resourceGroups',
            resource_group,
            'providers',
            @provider,
            'virtualNetworks',
          )

          url = File.join(url, *args) unless args.empty?
          url << "?api-version=#{@api_version}"
        end
      end
    end # Network
  end # Armrest
end # Azure
