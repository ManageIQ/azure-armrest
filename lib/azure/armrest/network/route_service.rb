module Azure
  module Armrest
    module Network
      # Base class for managing routes in a route table
      class RouteService < ResourceGroupBasedSubservice
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'routeTables', 'routes', 'Microsoft.Network', options)
        end
      end
    end # Network
  end # Armrest
end # Azure
