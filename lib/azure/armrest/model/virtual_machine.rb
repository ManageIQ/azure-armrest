module Azure
  module Armrest
    class VirtualMachine < BaseModel
      def initialize(json)
        super
      end

      # Return the storage account for the current virtual machine model. The
      # argument must be a StorageAccountService object.
      #
      def storage_account(storage_account_service)
        uri = Addressable::URI.parse(properties.storage_profile.os_disk.vhd.uri)

        # The uri looks like https://foo123.blob.core.windows.net/vhds/something123.vhd
        name = uri.host.split('.').first # storage name, e.g. 'foo123'

        # Look for the storage account in the VM's resource group first. If
        # it's not found, look through all the storage accounts.
        begin
          acct = storage_account_service.get(name, resource_group)
        rescue Azure::Armrest::NotFoundException
          acct = storage_account_service.list_all.find { |s| s.name == name }
        end

        raise Azure::Armrest::NotFoundException unless acct

        acct
      end
    
      # Get information for the underlying VHD file backing the VM. The
      # argument must be a StorageAccountService object.
      #
      def virtual_disk(storage_account_service)
        uri = Addressable::URI.parse(properties.storage_profile.os_disk.vhd.uri)

        # The uri looks like https://foo123.blob.core.windows.net/vhds/something123.vhd
        disk = File.basename(uri.to_s)       # disk name, e.g. 'something123.vhd'
        path = File.dirname(uri.path)[1..-1] # container, e.g. 'vhds'

        acct = storage_account(storage_account_service)
        keys = storage_account_service.list_account_keys(acct.name, acct.resource_group)
        key  = keys['key1'] || keys['key2']

        acct.blob_properties(path, disk, key)
      end
    end
  end
end
