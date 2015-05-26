# Azure namespace
module Azure
  # ArmRest namespace
  module ArmRest
    # Base class for managing virtual networks
    class VirtualNetworkManager < ArmRestManager

      # Create and return a new VirtualNetworkManager instance. Most
      # methods for a VirtualNetworkManager instance will return one or
      # more VirtualNetwork instances.
      #
      def initialize(subscription_id, resource_group_name, api_version = '2015-1-1')
        super

        @uri += "/resourceGroups/#{resource_group_name}"
        @uri += "/providers/Microsoft.Network/virtualNetworks"
      end

      # Creates a new virtual network using the given +options+. The possible
      # options are:
      #
      #   :name
      #   :id
      #   :location
      #   :tags
      #   :etag
      #   :properties
      #     :address_space
      #       :address_prefixes
      #     :dhcp_options
      #       :dns_servers
      #     :subnets
      #       :name
      #       :id
      #       :etag
      #       :provisioning_state
      #       :address_prefix
      #       :dhcp_options
      #       :ip_configurations
      #         :id
      #--
      def create(network_name, options = {})
        @uri += "/#{network_name}?api-version=#{api_version}"
      end

      # Deletes the +network_name+ availability set.
      def delete(network_name)
        @uri += "/#{network_name}?api-version=#{api_version}"
      end

      # Retrieves the options of an availability set.
      def get(network_name)
        @uri += "/#{network_name}?api-version=#{api_version}"
      end

      # List availability sets.
      def list
        @uri += "?api-version=#{api_version}"
      end
    end
  end
end
