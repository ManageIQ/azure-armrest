# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Role namespace
    module Role
      # Base class for managing Role Definitions
      class DefinitionService < ResourceGroupBasedService
        # Create and return a new DefinitionService instance.
        #
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'roleDefinitions', 'Microsoft.Authorization', options)
        end
      end # DefinitionService
    end # Role
  end # Armrest
end # Azure
