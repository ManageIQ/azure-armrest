module Azure
  module Armrest
    module Network
      # Base class for managing subnets
      class SubnetService < ResourceGroupBasedSubservice
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'virtualNetworks', 'subnets', 'Microsoft.Network', options)
        end
      end
    end # Network
  end # Armrest
end # Azure
