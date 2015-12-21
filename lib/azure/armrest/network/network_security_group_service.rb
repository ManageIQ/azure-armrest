module Azure
  module Armrest
    module Network
      # Class for managing network security groups.
      class NetworkSecurityGroupService < ResourceGroupBasedService

        # Creates and returns a new NetworkSecurityGroupService instance.
        #
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'networkSecurityGroups', 'Microsoft.Network', options)
        end
      end
    end # Network
  end # Armrest
end # Azure
