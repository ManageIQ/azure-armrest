module Azure
  module Armrest
    module Network
      # Class for managing public IP addresss.
      class IpAddressService < ArmrestService

        # Creates and returns a new IpAddressService instance.
        #
        def initialize(_armrest_configuration, options = {})
          super
          @provider = options[:provider] || 'Microsoft.Network'
          set_service_api_version(options, 'publicIPAddresses')
        end

        # Return information for the given IP address name for the
        # provided +resource_group+. If no group is specified, it will use
        # the resource group set in the constructor.
        #
        # Example:
        #
        #   # Where 'your_ip_name' likely corresponds to a VM name.
        #   ip.get('your_ip_name', 'your_resource_group')
        #
        def get(ip_name, resource_group = armrest_configuration.resource_group)
          raise ArgumentError, "must specify resource group" unless resource_group
          url = build_url(resource_group, ip_name)
          response = rest_get(url)
          Azure::Armrest::Network::IpAddress.new(response)
        end

        # Shortcut method that returns just the IP address for the given public
        # IP address name.
        #
        def get_ip(ip_name, resource_group = armrest_configuration.resource_group)
          get(ip_name, resource_group).properties.ipAddress
        end

        alias get_ip_address get_ip

        # Returns a list of available IP addresss in the current subscription
        # for the provided +resource_group+.
        #
        def list(resource_group = armrest_configuration.resource_group)
          raise ArgumentError, "must specify resource group" unless resource_group
          url = build_url(resource_group)
          response = rest_get(url)
          JSON.parse(response)['value'].map{ |hash|
            Azure::Armrest::Network::IpAddress.new(hash)
          } 
        end

        # List all IP addresss for the current subscription.
        #
        def list_all
          sub_id = armrest_configuration.subscription_id
          url = File.join(
            Azure::Armrest::COMMON_URI, sub_id, 'providers',
            @provider, 'publicIPAddresses'
          )
          url << "?api-version=#{@api_version}"

          response = rest_get(url)

          JSON.parse(response)['value'].map{ |hash|
            Azure::Armrest::Network::IpAddress.new(hash)
          } 
        end

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
            'publicIPAddresses',
          )

          url = File.join(url, *args) unless args.empty?
          url << "?api-version=#{@api_version}"
        end
      end
    end # Network
  end # Armrest
end # Azure
