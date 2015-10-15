# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Base class for managing virtual machines
    class VirtualMachineService < ResourceGroupBasedService

      # The provider used in requests when gathering VM information.
      attr_reader :provider

      # Create and return a new VirtualMachineService (VMM) instance. Most
      # methods for a VMM instance will return one or more VirtualMachine
      # instances.
      #
      # This subclass accepts the additional :provider option as well. The
      # default is 'Microsoft.ClassicCompute'. You may need to set this to
      # 'Microsoft.Compute' for your purposes.
      #
      def initialize(_armrest_configuration, options = {})
        super
        @provider = options[:provider] || 'Microsoft.Compute'
        @service_name = 'virtualMachines'
        set_service_api_version(options, @service_name)
      end

      # Set a new provider to use the default for other methods. This may alter
      # the api_version used for future requests. In practice, only
      # 'Microsoft.Compute' or 'Microsoft.ClassicCompute' should be used.
      #
      def provider=(name, options = {})
        @provider = name
        set_service_api_version(options, 'virtualMachines')
      end

      # Return a list of available VM series (aka sizes, flavors, etc), such
      # as "Basic_A1", though information is included as well.
      #
      def series(location)
        unless @@providers_hash[@provider.downcase] && @@providers_hash[@provider.downcase]['locations/vmSizes']
          raise ArgumentError, "Invalid provider '#{provider}'"
        end

        version = @@providers_hash[@provider.downcase]['locations/vmSizes']['api_version']

        url = url_with_api_version(
          version, @base_url, 'subscriptions', armrest_configuration.subscription_id,
          'providers', provider, 'locations', location, 'vmSizes'
        )

        JSON.parse(rest_get(url))['value']
      end

      alias sizes series

      # Captures the +vmname+ and associated disks into a reusable CSM template.
      # The 3rd argument is a hash of options that supports the following keys:
      #
      # * vhdPrefix                - The prefix in the name of the blobs.
      # * destinationContainerName - The name of the container inside which the image will reside.
      # * overwriteVhds            - Boolean that indicates whether or not to overwrite any VHD's
      #                              with the same prefix. The default is false.
      #
      def capture(vmname, options, group = armrest_configuration.resource_group)
        vm_operate('capture', vmname, group, options)
      end

      # Creates a new virtual machine (or updates an existing one). Pass a hash
      # of options to configure the VM as you see fit. Some options are
      # mandatory. The following are a list of possible options:
      #
      # - :name
      #   Required. The name of the virtual machine. The name must be unique
      #   within the availability set that it belongs to.
      #
      # - :location
      #   Required. The location where the VM should be created, e.g. "West US".
      #
      # - :tags
      #   Optional. Specifies an identifier for the availability set.
      #
      # - :hardwareprofile
      #   Required. Contains a collection of hardware settings for the VM.
      #
      #   - :vmsize
      #     Required. Specifies the size of the virtual machine. Possible
      #     sizes are Standard_A0..Standard_A4.
      #
      # - :osprofile
      #   Required. Contains a collection of settings for the OS configuration
      #   which must contain all of the following:
      #
      #   - :computername
      #   - :adminusername
      #   - :adminpassword
      #   - :username
      #   - :password
      #
      # - :storageprofile
      #   Required. Contains a collection of settings for storage and disk
      #   settings for the VM. You must specify an :osdisk and :name. The
      #   :datadisks setting is optional.
      #
      #   - :osdisk
      #     Required. Contains a collection of settings for the operating
      #     system disk.
      #
      #     - :name
      #     - :ostype
      #     - :caching
      #     - :image
      #     - :vhd
      #
      #   - :datadisks
      #     Optional. Contains a collection of settings for data disks.
      #
      #     - :name
      #     - :image
      #     - :vhd
      #     - :lun
      #     - :caching
      #
      #   - :name
      #     Required. Specifies the name of the disk.
      #
      # For clarity, we recommend using the update method for existing VM's.
      #
      # Example:
      #
      #   vmm = VirtualMachineService.new(x, y, z)
      #
      #   vm = vmm.create(
      #     :name            => 'test1',
      #     :location        => 'West US',
      #     :hardwareprofile => {:vmsize => 'Standard_A0'},
      #     :osprofile       => {
      #       :computername  => 'some_name',
      #       :adminusername => 'admin_user',
      #       :adminpassword => 'adminxxxxxx',
      #       :username      => 'some_user',
      #       :password      => 'userpassxxxxxx',
      #     },
      #     :storageprofile  => {
      #       :osdisk => {
      #         :ostype  => 'Windows',
      #         :caching => 'Read'
      #       }
      #     }
      #   )
      #--
      # PUT operation
      # TODO: Implement
      #def create(options = {})
      #end

      # Stop the VM +vmname+ in +group+ and deallocate the tenant in Fabric.
      #
      def deallocate(vmname, group = armrest_configuration.resource_group)
        vm_operate('deallocate', vmname, group)
      end

      # Sets the OSState for the +vmname+ in +group+ to 'Generalized'.
      #
      def generalize(vmname, group = armrest_configuration.resource_group)
        vm_operate('generalize', vmname, group)
      end

      # Retrieves the settings of the VM named +vmname+ in resource group
      # +group+, which will default to the same as the name of the VM.
      #
      # By default this method will retrieve the model view. If the +model_view+
      # parameter is false, it will retrieve an instance view. The difference is
      # in the details of the information retrieved.
      #
      def get(vmname, group = armrest_configuration.resource_group, model_view = true)
        model_view ? super(vmname, group) : get_instance_view(vmname, group)
      end

      # Convenient wrapper around the get method that retrieves the model view
      # for +vmname+ in resource_group +group+.
      #
      def get_model_view(vmname, group = armrest_configuration.resource_group)
        get(vmname, group, true)
      end

      # Convenient wrapper around the get method that retrieves the instance view
      # for +vmname+ in resource_group +group+.
      #
      def get_instance_view(vmname, group = armrest_configuration.resource_group)
        raise ArgumentError, "must specify resource group" unless group
        raise ArgumentError, "must specify name of the resource" unless vmname

        url = build_url(group, vmname, 'instanceView')
        response = rest_get(url)
        VirtualMachineInstance.new(response)
      end

      # Restart the VM +vmname+ for the given +group+, which will default
      # to the same as the vmname.
      #
      # This is an asynchronous operation that returns a response object
      # which you can inspect, such as response.code or response.headers.
      #
      def restart(vmname, group = armrest_configuration.resource_group)
        vm_operate('restart', vmname, group)
      end

      # Start the VM +vmname+ for the given +group+, which will default
      # to the same as the vmname.
      #
      # This is an asynchronous operation that returns a response object
      # which you can inspect, such as response.code or response.headers.
      #
      def start(vmname, group = armrest_configuration.resource_group)
        vm_operate('start', vmname, group)
      end

      # Stop the VM +vmname+ for the given +group+ gracefully. However,
      # a forced shutdown will occur after 15 minutes.
      #
      # This is an asynchronous operation that returns a response object
      # which you can inspect, such as response.code or response.headers.
      #
      def stop(vmname, group = armrest_configuration.resource_group)
        vm_operate('powerOff', vmname, group)
      end

      def model_class
        VirtualMachineModel
      end

      private

      def vm_operate(action, vmname, group, options = {})
        raise ArgumentError, "must specify resource group" unless group
        raise ArgumentError, "must specify name of the vm" unless vmname

        url = build_url(group, vmname, action)
        rest_post(url)
        nil
      end
    end
  end
end
