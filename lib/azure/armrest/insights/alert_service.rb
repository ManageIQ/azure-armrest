# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Insights namesspace
    module Insights
      # Base class for managing alert rules.
      class AlertService < ResourceGroupBasedService
        # Create and return a new AlertService instance.
        #
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'alertRules', 'Microsoft.Insights', options)
        end
      end # AlertService
    end # Insights
  end # Armrest
end # Azure
