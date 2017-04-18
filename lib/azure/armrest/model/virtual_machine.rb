module Azure
  module Armrest
    class VirtualMachine < BaseModel
      # Indicates whether the VM is backed by a managed disk or a regular
      # storage account.
      #
      def managed_disk?
        check_for_model_view('managed_disk?')
        properties.storage_profile.os_disk.try(:managed_disk) ? true : false
      end

      # Returns the size (aka series) for the VM, e.g. "Standard_A0".
      #
      def size
        check_for_model_view('size')
        properties.hardware_profile.vm_size
      end

      alias flavor size

      # The operating system for the image, e.g. "Linux" or "Windows".
      #
      def operating_system
        check_for_model_view('operating_sytem')
        properties.storage_profile.os_disk.os_type
      end

      alias os operating_system

      private

      def check_for_model_view(method_name)
        unless respond_to?(:properties)
          raise NoMethodError, "The method '#{method_name}' is only valid for model view objects."
        end
      end
    end
  end
end
