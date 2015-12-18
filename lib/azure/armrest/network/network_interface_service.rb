module Azure
  module Armrest
    module Network
      # Class for managing network interfaces.
      class NetworkInterfaceService < ResourceGroupBasedService
        # Creates and returns a new NetworkInterfaceService instance.
        #
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'networkInterfaces', 'Microsoft.Network', options)
        end
      end
    end # Network
  end # Armrest
end # Azure
