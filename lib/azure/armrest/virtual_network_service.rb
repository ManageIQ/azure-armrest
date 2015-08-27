# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Base class for managing virtual networks
    class VirtualNetworkService < ArmrestService

      # Create and return a new VirtualNetworkService instance. Most
      # methods for a VirtualNetworkService instance will return one or
      # more VirtualNetwork instances.
      #
      def initialize(armrest_configuration, options = {})
        super

        @base_url += "resourceGroups/#{armrest_configuration.resource_group}/"
        @base_url += "providers/Microsoft.Network/virtualNetworks"
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
        @uri += "/#{network_name}?api-version=#{armrest_configuration.api_version}"
      end

      # Deletes the +network_name+ availability set.
      def delete(network_name)
        @uri += "/#{network_name}?api-version=#{armrest_configuration.api_version}"
      end

      # Retrieves the options of an availability set.
      def get(network_name)
        @uri += "/#{network_name}?api-version=#{armrest_configuration.api_version}"
      end

      # List availability sets.
      def list
        @uri += "?api-version=#{armrest_configuration.api_version}"
      end
    end
  end
end
