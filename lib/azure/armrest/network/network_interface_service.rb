module Azure
  module Armrest
    # Class for managing network interfaces.
    class NetworkInterfaceService < ArmrestService

      # Creates and returns a new NetworkInterfaceService instance.
      #
      def initialize(_armrest_configuration, options = {})
        super
        @provider = options[:provider] || 'Microsoft.Network'
        set_service_api_version(options, 'networkInterfaces')
      end

      # Return information for the given network interface card for the
      # provided +resource_group+. If no group is specified, it will use the
      # resource group set in the constructor.
      #
      # Example:
      #
      #   nsg.get('your_interface', 'your_resource_group')
      #
      def get(interface, resource_group = armrest_configuration.resource_group)
        raise ArgumentError, "must specify resource group" unless resource_group
        url = build_url(resource_group, interface)
        JSON.parse(rest_get(url))
      end

      # Returns a list of available network interfaces in the current subscription
      # for the provided +resource_group+.
      #
      def list(resource_group = armrest_configuration.resource_group)
        raise ArgumentError, "no resource group provided" unless resource_group
        url = build_url(resource_group)
        JSON.parse(rest_get(url))['value']
      end

      # List all network interfaces for the current subscription.
      #
      def list_all_for_subscription
        sub_id = armrest_configuration.subscription_id
        url = File.join(Azure::Armrest::COMMON_URI, sub_id, 'providers', @provider, 'networkInterfaces')
        url << "?api-version=#{@api_version}"
        JSON.parse(rest_get(url))['value']
      end

      alias list_all list_all_for_subscription

      # Delete the given network interface in +resource_group+.
      #
      def delete(interface, resource_group = armrest_configuration.resource_group)
        raise ArgumentError, "must specify resource group" unless resource_group

        url = build_url(group, account_name)
        response = rest_delete(url)
        response.return!
      end

      # Create a new network interface, or update an existing network interface if it
      # already exists. The first argument is a hash of options.
      #
      # - :name # Mandatory
      # - :location # Mandatory
      # - :tags
      # - :properties
      #   - :networkSecurityGroup
      #     - :id
      #   - :ipConfigurations
      #   [
      #     - :name # Mandatory
      #     - :properties
      #       - :subnet
      #         - :id # Mandatory
      #       - :privateIPAddress
      #       - :privateIPAllocationMethod # Mandatory
      #       - :publicIPAddress
      #         - :id
      #       - :loadBalancerBackendAddressPools
      #         - :id
      #       - :loadBalancerInboundNatRules
      #         - :id
      #   ]
      #
      #   - :dnsSettings
      #     - :dnsServers[ <ip1>, <ip2>, ... ]
      #
      # For convenience, you may also pass the :resource_group as a hash option.
      #
      def create(options, resource_group = armrest_configuration.resource_group)
        resource_group = options.delete(:resource_group) || resource_group
        name = options.delete(:name)

        raise ArgumentError, "no resource group specified" unless resource_group
        raise Argument, "no interface name specified" unless name

        body = options.to_json

        url = build_url(resource_group, name)

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
          'networkInterfaces',
        )

        url = File.join(url, *args) unless args.empty?
        url << "?api-version=#{@api_version}"
      end
    end
  end
end
