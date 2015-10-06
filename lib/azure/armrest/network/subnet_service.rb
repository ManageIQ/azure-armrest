module Azure
  module Armrest
    module Network
      # Base class for managing subnets
      class SubnetService < VirtualNetworkService

        # Create and return a new SubnetService instance. Most methods for a
        # SubnetService instance will return one or Subnet instances.
        #
        def initialize(_armrest_configuration, options = {})
          super
          @provider = options[:provider] || 'Microsoft.Network'
          set_service_api_version(options, 'virtualNetworks')
        end

        # Creates a new +subnet_name+ on +virtual_network+ using the given
        # +options+.  The +options+ argument is a hash that supports the
        # following keys and subkeys.
        #
        # - :properties
        #   - :addressPrefix
        #   - :networkSecurityGroup
        #     - :id
        #   - :routeTable
        #     - :id
        #
        def create(subnet_name, virtual_network, options = {}, resource_group = armrest_configuration.resource_group)
          resource_group = options.delete(:resource_group) || resource_group
          raise ArgumentError, "no resource group provided" unless resource_group 
          url = build_url(resource_group, virtual_network, subnet_name)
          body = options.to_json
          response = rest_put(url, body)
          response.return!
        end

        alias update create

        # Deletes the given +subnet_name+ in +virtual_network+.
        #
        def delete(subnet_name, virtual_network, resource_group = armrest_configuration.resource_group)
          raise ArgumentError, "no resource group provided" unless resource_group
          url = build_url(resource_group, virtual_network, subnet_name)
          response = rest_delete(url)
          response.return!
        end

        # Retrieves information for the provided +subnet_name+ in +virtual_network+ for
        # the current subscription.
        #
        def get(subnet_name, virtual_network, resource_group = armrest_configuration.resource_group)
          raise ArgumentError, "no resource group provided" unless resource_group 
          url = build_url(resource_group, virtual_network, subnet_name)
          JSON.parse(rest_get(url))
        end

        # List available subnets on +virtual_network+ for the given +resource_group+.
        #
        def list(virtual_network, resource_group = armrest_configuration.resource_group)
          raise ArgumentError, "no resource group provided" unless resource_group 
          url = build_url(resource_group, virtual_network)
          JSON.parse(rest_get(url))['value']
        end

        private

        def build_url(resource_group, virtual_network_name, *args)
          super(resource_group, virtual_network_name, 'subnets', *args)
        end
      end
    end # Network
  end # Armrest
end # Azure
