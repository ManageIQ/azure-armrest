# Azure namespace
module Azure
  # ArmRest namespace
  module ArmRest
    # Base class for managing subnets
    class SubnetManager < VirtualNetworkManager

      # Create and return a new SubnetManager instance. Most methods for a
      # SubnetManager instance will return one or Subnet instances.
      #
      def initialize(subscription_id, resource_group_name, api_version = '2015-1-1')
        super

        @uri += "/resourceGroups/#{resource_group_name}"
        @uri += "/providers/Microsoft.Network/virtualNetworks/subnets"
      end

      # Creates a new subnet using the given +options+.
      #
      # The possible options are:
      #
      #   :name
      #   :id
      #   :location
      #   :tags
      #   :etag
      #   :properties
      #     :provisioning_state
      #     :address_prefixes
      #     :dhcp_options
      #       :dns_servers
      #     :ip_configurations
      #--
      def create(subnet_name, options = {})
        @uri += "/#{subnet_name}?api-version=#{api_version}"
      end

      # Deletes the given subnet.
      def delete(subnet_name)
        @uri += "/#{subnet_name}?api-version=#{api_version}"
      end

      # Retrieves information for the given subnet.
      def get(subnet_name)
        @uri += "/#{subnet_name}?api-version=#{api_version}"
      end

      # List available subnets.
      def list
        @uri += "?api-version=#{api_version}"
      end

      # Patch an existing subnet. This is similar to a create/update
      # but the available options are more limited.
      def patch(subnet_name, options = {})
        @uri += "?api-version=#{api_version}"
      end
    end
  end
end
