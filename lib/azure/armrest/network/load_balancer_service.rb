module Azure
  module Armrest
    module Network
      # Class for managing load balancers
      class LoadBalancerService < ResourceGroupBasedService
        # Creates and returns a new LoadBalancerService instance.
        #
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'loadBalancers', 'Microsoft.Network', options)
        end
      end
    end # Network
  end # Armrest
end # Azure
