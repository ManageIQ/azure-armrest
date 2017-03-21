# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Storage namespace
    module Storage
      # Base class for managing images.
      class ImageService < ResourceGroupBasedService
        # Create and return a new DiskService instance.
        #
        def initialize(configuration, options = {})
          super(configuration, 'images', 'Microsoft.Compute', options)
        end
      end # ImageService
    end # Storage
  end # Armrest
end # Azure
