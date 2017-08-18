# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Storage namespace
    module Storage
      # Base class for managing disks.
      class DiskService < ResourceGroupBasedService
        require_relative './raw_blob_helper'
        include Azure::Armrest::Storage::RawBlobHelper

        # Create and return a new DiskService instance.
        #
        def initialize(configuration, options = {})
          super(configuration, 'disks', 'Microsoft.Compute', options)
        end
      end # DiskService
    end # Storage
  end # Armrest
end # Azure
