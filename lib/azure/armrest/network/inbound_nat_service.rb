module Azure
  module Armrest
    module Network
      # Base class for managing subnets
      class InboundNatService < ResourceGroupBasedSubservice
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'loadBalancers', 'inboundNatRules', 'Microsoft.Network', options)
        end
      end
    end # Network
  end # Armrest
end # Azure
