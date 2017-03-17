# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Base class for managing disks.
    class DiskService < ResourceGroupBasedService
      # Create and return a new DiskService instance.
      #
      def initialize(configuration, options = {})
        super(configuration, 'disks', 'Microsoft.Compute', options)
      end
    end # AvailabilitySetService
  end # Armrest
end # Azure
