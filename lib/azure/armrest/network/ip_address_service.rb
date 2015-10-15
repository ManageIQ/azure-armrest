module Azure
  module Armrest
    module Network
      # Class for managing public IP addresss.
      class IpAddressService < ResourceGroupBasedService

        # Creates and returns a new IpAddressService instance.
        #
        def initialize(_armrest_configuration, options = {})
          super
          @provider = options[:provider] || 'Microsoft.Network'
          @service_name = 'publicIPAddresses'
          set_service_api_version(options, @service_name)
        end

        # Shortcut method that returns just the IP address for the given public
        # IP address name.
        #
        def get_ip(ip_name, resource_group = armrest_configuration.resource_group)
          get(ip_name, resource_group).properties.ipAddress
        end

        alias get_ip_address get_ip
      end
    end # Network
  end # Armrest
end # Azure
