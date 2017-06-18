# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Base class for managing containers.
    class ContainerService < ResourceGroupBasedService
      def initialize(configuration, options = {})
        super(configuration, 'containerServices', 'Microsoft.ContainerService', options)
      end
    end
  end
end
