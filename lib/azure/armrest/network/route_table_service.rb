module Azure
  module Armrest
    module Network
      # Class for managing load balancers
      class RouteTableService < ResourceGroupBasedService
        # Creates and returns a new LoadBalancerService instance.
        #
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'routeTables', 'Microsoft.Network', options)
        end
      end
    end # Network
  end # Armrest
end # Azure
