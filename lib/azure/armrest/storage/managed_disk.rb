# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Storage namespace
    module Storage
      # Base class for managing managed disks.
      module ManagedStorageHelper
        class ManagedDisk
          def initialize(storage_service, disk_name, resource_group, sas_url)
            @storage_service = storage_service
            @disk_name       = disk_name
            @resource_group  = resource_group
            @sas_url         = sas_url
          end

          def read(options = {})
            @storage_service.read(@sas_url, options)
          end

          def close
            @storage_service.close(@disk_name, @resource_group)
            @sas_url = nil
          end
        end # ManagedDisk
      end # ManagedStorageHelper
    end # Storage
  end # Armrest
end # Azure
