# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Role namespace
    module Role
      # Base class for managing Role Assignments
      class AssignmentService < ResourceGroupBasedService
        # Create and return a new AssignmentService instance.
        #
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'roleAssignments', 'Microsoft.Authorization', options)
        end
      end # AssignmentService
    end # Role
  end # Armrest
end # Azure
