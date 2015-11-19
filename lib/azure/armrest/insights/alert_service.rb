# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Insights namesspace
    module Insights
      # Base class for managing alert rules.
      class AlertService < ResourceGroupBasedService
        # The provider used in requests when gathering Alert information.
        attr_reader :provider

        # Create and return a new AlertService instance.
        #
        def initialize(_armrest_configuration, options = {})
          super
          @provider = options[:provider] || 'Microsoft.Insights'
          set_service_api_version(options, 'alertrules')
          @service_name = 'alertRules'
        end
      end # AlertService
    end # Insights
  end # Armrest
end # Azure
