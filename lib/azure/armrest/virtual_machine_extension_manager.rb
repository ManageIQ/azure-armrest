# Azure namespace
module Azure
  # ArmRest namespace
  module ArmRest
    # Base class for managing virtual machine extensions
    class VirtualMachineExtensionManager < ArmRestManager

      # Create and return a new VirtualMachineExtensionManager (VMEM) instance.
      # Most methods for a VME instance will return one or more VirtualMachine
      # instances.
      #
      def initialize(subscription_id, resource_group_name, api_version = '2015-1-1')
        super

        @uri += "/resourceGroups/#{resource_group_name}"
        @uri += "/providers/Microsoft.Compute/virtualMachines"
      end

      # Creates a new virtual machine extension for +vmname+ with the given
      # +extension_name+, and the given +options+. Possible options are:
      #
      #   :tags - Optional. A list of key value pairs. Max 10 pairs.
      #   :publisher - Required. Name of extension publisher.
      #   :type - Required. The type of extension.
      #   :type_handler_version - Required. Specifies the extension version.
      #   :settings - Optional. Public configuration that does not require encryption.
      #   :protected_settings - Optional. Private configuration that is encrypted.
      #
      def create(vmname, extension_name, options = {})
        publisher = options.fetch(:publisher)
        type = options.fetch(:type)
        type_handler_version = optios.fetch(:type_handler_version)

        @uri += "/#{vmname}/extensions/#{extension_name}?#{api_version}"
      end

      # Delete the given +extension_name+ for +vmname+.
      #--
      # DELETE
      #
      def delete(vmname, extension_name)
        @uri += "/#{vmname}/extensions/#{extension_name}?#{api_version}"
      end

      # Retrieves the settings of an extension. If the +instance_view+ option
      # is true, it will retrieve instance view information instead.
      #--
      # GET
      #
      def get(vmname, instance_view = false)
        @uri += "/#{vmname}/extensions/#{extension_name}?"
        @uri += "$expand=instanceView," if instance_view
        @uri += "#{api_version}"
      end

      # Retrieves a list of extensions on the VM.
      def list(vmname, instance_view = false)
        @uri += "/#{vmname}/extensions"
        @uri += "$expand=instanceView," if instance_view
        @uri += "#{api_version}"
      end
    end
  end
end
