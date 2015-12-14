# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Role namespace
    module Role
      # Base class for managing Role Definitions
      class DefinitionService < ResourceGroupBasedService
        # The provider used in requests when gathering Role information.
        attr_reader :provider

        # Create and return a new DefinitionService instance.
        #
        def initialize(_armrest_configuration, options = {})
          super
          @provider = options[:provider] || 'Microsoft.Authorization'
          @service_name = 'roleDefinitions'
          set_service_api_version(options, @service_name)
        end
      end # DefinitionService
    end # Role
  end # Armrest
end # Azure
