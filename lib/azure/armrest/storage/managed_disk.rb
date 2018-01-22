# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Storage namespace
    module Storage
      # Base class for managing managed disks.
      module ManagedStorageHelper
        class ManagedDisk
          def initialize(storage_service, disk_name, resource_group, options)
            @storage_service = storage_service
            @disk_name       = disk_name
            @resource_group  = resource_group
            @sas_url         = storage_service.access_token(disk_name, resource_group, options)
          end

          def read(options = {})
            retries = 0
            begin
              @storage_service.read(@sas_url, options)
            rescue Azure::Armrest::ForbiddenException => err
              raise err if retries.positive?
              log('warn', "ManagedDisk.read: #{err} - getting new SAS URL")
              begin
                close
              rescue => err
                log('debug', "ManagedDisk.read: #{err} received on close ignored.")
              end
              @sas_url = @storage_service.access_token(@disk_name, @resource_group, options)
              retries += 1
              retry
            end
          end

          def close
            @storage_service.close(@disk_name, @resource_group)
            @sas_url = nil
          end
        end
      end
    end
  end
end
