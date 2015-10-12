module Azure
  module Armrest
    module Network
      # Class for managing network security groups.
      class NetworkSecurityGroupService < ArmrestService

        # Creates and returns a new NetworkSecurityGroupService instance.
        #
        def initialize(_armrest_configuration, options = {})
          super
          @provider = options[:provider] || 'Microsoft.Network'
          set_service_api_version(options, 'networkSecurityGroups')
        end

        # Return information for the given network security group name for the
        # provided +resource_group+. If no group is specified, it will use the
        # resource group set in the constructor.
        #
        # Example:
        #
        #   # Where 'your_security_group' is likely same as the name of a VM.
        #   nsg.get('your_security_group', 'your_resource_group')
        #
        def get(ns_group_name, resource_group = armrest_configuration.resource_group)
          raise ArgumentError, "must specify resource group" unless resource_group
          url = build_url(resource_group, ns_group_name)
          response = rest_get(url)
          Azure::Armrest::Network::NetworkSecurityGroup.new(response)
        end

        # Returns a list of available network security groups for the given subscription
        # for the provided +group+, or for all resource groups if no group is specified.
        #
        def list(resource_group = armrest_configuration.resource_group)
          url = build_url(resource_group)
          response = rest_get(url)
          JSON.parse(response)['value'].map do |hash|
            Azure::Armrest::Network::NetworkSecurityGroup.new(hash)
          end
        end

        # List all network security groups for the current subscription.
        #
        def list_all
          sub_id = armrest_configuration.subscription_id
          url = File.join(
            Azure::Armrest::COMMON_URI, sub_id, 'providers',
            @provider, 'networkSecurityGroups'
          )
          url << "?api-version=#{@api_version}"

          response = rest_get(url)

          JSON.parse(response)['value'].map do |hash|
            Azure::Armrest::Network::NetworkSecurityGroup.new(hash)
          end
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
            'networkSecurityGroups',
          )

          url = File.join(url, *args) unless args.empty?
          url << "?api-version=#{@api_version}"
        end
      end
    end # Network
  end # Armrest
end # Azure
