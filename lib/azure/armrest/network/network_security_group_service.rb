module Azure
  module Armrest
    module Network
      # Class for managing network security groups.
      class NetworkSecurityGroupService < ResourceGroupBasedService

        # Creates and returns a new NetworkSecurityGroupService instance.
        #
        def initialize(_armrest_configuration, options = {})
          super
          @provider = options[:provider] || 'Microsoft.Network'
          @service_name = 'networkSecurityGroups'
          set_service_api_version(options, @service_name)
        end
      end
    end # Network
  end # Armrest
end # Azure
