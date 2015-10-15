# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Base class for managing availability sets.
    class AvailabilitySetService < ResourceGroupBasedService
      # The provider used in requests when gathering AvailabilitySet information.
      attr_reader :provider

      # Create and return a new AvailabilitySetService instance.
      #
      def initialize(_armrest_configuration, options = {})
        super
        @provider = options[:provider] || 'Microsoft.Compute'
        set_service_api_version(options, 'availabilitySets')
        @service_name = 'availabilitySets'
      end

      def list_all
        list_in_all_groups
      end
    end # AvailabilitySetService
  end # Armrest
end # Azure
