# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Role namespace
    module Role
      # Base class for managing Role Assignments
      class AssignmentService < ResourceGroupBasedService
        # The provider used in requests when gathering Role information.
        attr_reader :provider

        # Create and return a new AssignmentService instance.
        #
        def initialize(_armrest_configuration, options = {})
          super
          @provider = options[:provider] || 'Microsoft.Authorization'
          @service_name = 'roleAssignments'
          set_service_api_version(options, @service_name)
        end
      end # AssignmentService
    end # Role
  end # Armrest
end # Azure
