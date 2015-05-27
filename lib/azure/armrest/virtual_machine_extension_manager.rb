# Azure namespace
module Azure
  # ArmRest namespace
  module ArmRest
    # Base class for managing virtual machine extensions
    class VirtualMachineExtensionManager < VirtualMachineManager

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
        #publisher = options.fetch(:publisher)
        #type = options.fetch(:type)
        #type_handler_version = options.fetch(:type_handler_version)

        url = @uri + "/#{vmname}/extensions/#{extension_name}?#{api_version}"
        url
      end

      alias update create

      # Delete the given +extension_name+ for +vmname+.
      #--
      # DELETE
      #
      def delete(vmname, extension_name)
        url = @uri + "/#{vmname}/extensions/#{extension_name}?#{api_version}"
        url
      end

      # Retrieves the settings of an extension. If the +instance_view+ option
      # is true, it will retrieve instance view information instead.
      #--
      # GET
      #
      def get(vmname, instance_view = false)
        url = @uri + "/#{vmname}/extensions/#{extension_name}?"
        url += "$expand=instanceView," if instance_view
        url += "#{api_version}"
        url
      end

      # Retrieves a list of extensions on the VM.
      def list(vmname, instance_view = false)
        url = @uri + "/#{vmname}/extensions"
        url += "$expand=instanceView," if instance_view
        url += "#{api_version}"
        url
      end
    end
  end
end
