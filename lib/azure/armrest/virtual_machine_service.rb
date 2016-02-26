# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Base class for managing virtual machines
    class VirtualMachineService < ResourceGroupBasedService
      # Create and return a new VirtualMachineService (VMM) instance. Most
      # methods for a VMM instance will return one or more VirtualMachine
      # instances.
      #
      # This subclass accepts the additional :provider option as well. The
      # default is 'Microsoft.ClassicCompute'. You may need to set this to
      # 'Microsoft.Compute' for your purposes.
      #
      def initialize(configuration, options = {})
        super(configuration, 'virtualMachines', 'Microsoft.Compute', options)
      end

      # Return a list of available VM series (aka sizes, flavors, etc), such
      # as "Basic_A1", though information is included as well.
      #
      def series(location)
        unless @@providers_hash[provider.downcase] && @@providers_hash[provider.downcase]['locations/vmsizes']
          raise ArgumentError, "Invalid provider '#{provider}'"
        end

        version = @@providers_hash[provider.downcase]['locations/vmsizes']['api_version']

        url = url_with_api_version(
          version, @base_url, 'subscriptions', configuration.subscription_id,
          'providers', provider, 'locations', location, 'vmSizes'
        )

        JSON.parse(rest_get(url))['value'].map{ |hash| VirtualMachineSize.new(hash) }
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
      def capture(vmname, options, group = configuration.resource_group)
        vm_operate('capture', vmname, group, options)
      end

      # Stop the VM +vmname+ in +group+ and deallocate the tenant in Fabric.
      #
      def deallocate(vmname, group = configuration.resource_group)
        vm_operate('deallocate', vmname, group)
      end

      # Sets the OSState for the +vmname+ in +group+ to 'Generalized'.
      #
      def generalize(vmname, group = configuration.resource_group)
        vm_operate('generalize', vmname, group)
      end

      # Retrieves the settings of the VM named +vmname+ in resource group
      # +group+, which will default to the same as the name of the VM.
      #
      # By default this method will retrieve the model view. If the +model_view+
      # parameter is false, it will retrieve an instance view. The difference is
      # in the details of the information retrieved.
      #
      def get(vmname, group = configuration.resource_group, model_view = true)
        model_view ? super(vmname, group) : get_instance_view(vmname, group)
      end

      # Convenient wrapper around the get method that retrieves the model view
      # for +vmname+ in resource_group +group+.
      #
      def get_model_view(vmname, group = configuration.resource_group)
        get(vmname, group, true)
      end

      # Convenient wrapper around the get method that retrieves the instance view
      # for +vmname+ in resource_group +group+.
      #
      def get_instance_view(vmname, group = configuration.resource_group)
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
      def restart(vmname, group = configuration.resource_group)
        vm_operate('restart', vmname, group)
      end

      # Start the VM +vmname+ for the given +group+, which will default
      # to the same as the vmname.
      #
      # This is an asynchronous operation that returns a response object
      # which you can inspect, such as response.code or response.headers.
      #
      def start(vmname, group = configuration.resource_group)
        vm_operate('start', vmname, group)
      end

      # Stop the VM +vmname+ for the given +group+ gracefully. However,
      # a forced shutdown will occur after 15 minutes.
      #
      # This is an asynchronous operation that returns a response object
      # which you can inspect, such as response.code or response.headers.
      #
      def stop(vmname, group = configuration.resource_group)
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
