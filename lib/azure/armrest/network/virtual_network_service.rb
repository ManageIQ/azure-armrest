module Azure
  module Armrest
    module Network
      # Class for managing virtual networks.
      class VirtualNetworkService < ResourceGroupBasedService

        # Creates and returns a new VirtualNetworkService instance.
        #
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'virtualNetworks', 'Microsoft.Network', options)
        end
      end
    end # Network
  end # Armrest
end # Azure
