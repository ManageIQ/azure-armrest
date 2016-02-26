# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Base class for managing virtual machine extensions
    class VirtualMachineExtensionService < VirtualMachineService

      # Creates and returns a new VirtualMachineExtensionService object.
      #
      def initialize(_configuration, options = {})
        super
        set_service_api_version(options, 'virtualMachines/extensions')
      end

      # Creates a new extension for the provided VM with the given +options+.
      # The possible options are:
      #
      # - :location - The location for the extension. Mandatory.
      # - :type - The type of compute resource. The default is "Microsoft.Compute/virtualMachines/extensions".
      # - :tags - A list of key value pairs. Max 10 pairs. Optional.
      # - :properties
      #   - :type - The type of extension. Required.
      #   - :publisher - Name of extension publisher. Default is the provider.
      #   - :typeHandlerVersion - Optional. Specifies the extension version. Default is "1.*".
      #   - :settings - Public configuration that does not require encryption. Optional.
      #     - :fileUris - The script file path.
      #     - :commandToExecute - The command used to execute the script.
      #
      # For convenience, you may also specify a :resource_group as an option.
      #
      def create(vm_name, ext_name, options = {}, rgroup = nil)
        rgroup ||= options.delete(:resource_group) || configuration.resource_group

        raise ArgumentError, "no resource group provided" unless rgroup

        # Optional params with defaults
        options[:type] ||= "Microsoft.Compute/virtualMachines/extensions"
        options[:name] ||= ext_name
        options[:properties][:publisher] ||= @provider
        options[:properties][:typeHandlerVersion] ||= "1.*"

        url = build_url(rgroup, vm_name, ext_name)
        body = options.to_json

        response = rest_put(url, body)
        response.return!
      end

      alias update create

      # Delete the given extension for the provided VM and resource group.
      #
      def delete(vm_name, ext_name, rgroup = configuration.resource_group)
        raise ArgumentError, "no resource group provided" unless rgroup
        url = build_url(rgroup, vm_name, ext_name)
        response = rest_delete(url)
        response.return!
      end

      # Retrieves the settings of an extension for the provided VM.
      # If the +instance_view+ option is true, it will retrieve instance
      # view information instead.
      #
      def get(vm_name, ext_name, rgroup = configuration.resource_group, instance_view = false)
        raise ArgumentError, "no resource group provided" unless rgroup
        url = build_url(rgroup, vm_name, ext_name)
        url << "&expand=instanceView" if instance_view
        response = rest_get(url)
        Azure::Armrest::VirtualMachineExtension.new(response)
      end

      # Shortcut to get an extension in model view.
      def get_model_view(vm_name, ext_name, rgroup = configuration.resource_group)
        raise ArgumentError, "no resource group provided" unless rgroup
        get(vm_name, ext_name, rgroup, false)
      end

      # Shortcut to get an extension in instance view.
      def get_instance_view(vm_name, ext_name, rgroup = configuration.resource_group)
        raise ArgumentError, "no resource group provided" unless rgroup
        get(vm_name, ext_name, rgroup, true)
      end

      # Retrieves a list of extensions on the VM in the provided resource group.
      # If the +instance_view+ option is true, it will retrieve a list of instance
      # view information instead.
      #
      # NOTE: As of August 2015, this is not currently supported because the
      # MS SDK does not support it.
      #--
      # BUG: https://github.com/Azure/azure-xplat-cli/issues/1826
      #
      def list(vm_name, rgroup = configuration.resource_group, instance_view = false)
        raise ArgumentError, "no resource group provided" unless rgroup
        url = build_url(rgroup, vm_name)
        url << "&expand=instanceView" if instance_view
        response = rest_get(url)
        JSON.parse(response)['value'].map{ |hash| Azure::Armrest::VirtualMachineExtension.new(hash) }
      end

      # Shortcut to get a list in model view.
      def list_model_view(vmname, rgroup = configuration.resource_group)
        raise ArgumentError, "no resource group provided" unless rgroup
        list(vmname, false, rgroup)
      end

      # Shortcut to get a list in instance view.
      def list_instance_view(vmname, rgroup = configuration.resource_group)
        raise ArgumentError, "no resource group provided" unless rgroup
        list(vmname, true, rgroup)
      end

      private

      # Builds a URL based on subscription_id an resource_group and any other
      # arguments provided, and appends it with the api_version.
      #
      def build_url(resource_group, vm, *args)
        url = File.join(
          Azure::Armrest::COMMON_URI,
          configuration.subscription_id,
          'resourceGroups',
          resource_group,
          'providers',
          @provider,
          'virtualMachines',
          vm,
          'extensions'
        )

        url = File.join(url, *args) unless args.empty?
        url << "?api-version=#{@api_version}"
      end
    end
  end
end
