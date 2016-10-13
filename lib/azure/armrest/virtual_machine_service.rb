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
      # as "Basic_A1", though other information is included as well.
      #
      def series(location)
        namespace = 'microsoft.compute'
        version = configuration.provider_default_api_version(namespace, 'locations/vmsizes')

        unless version
          raise ArgumentError, "Unable to find resources for #{namespace}"
        end

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

      # Delete the VM and associated resources. By default, this will
      # delete the VM, its NIC, the associated IP address, and the
      # image file (.vhd) for the VM.
      #
      # If you want to delete any attached disks, the VM's underlying
      # storage account, associated network security groups or
      # availability set, you must explicitly specify them as an option.
      #
      # Because these resources could be associated with multiple VM's, an
      # attempt to delete a resource that cannot be deleted because it's still
      # associated with some other VM will be logged and skipped.
      #
      # Note that if all of your related resources are in a self-contained
      # resource group, you do not necessarily need this method. You could
      # just delete the resource group itself, which would automatically
      # delete all of its resources
      #
      def delete_associated(vmname, vmgroup, options = {})
        options = {
          :network_interfaces     => true,
          :ip_addresses           => true,
          :os_disk                => true,
          :data_disks             => false,
          :network_security_group => false,
          :attached_disks         => false,
          :storage_account        => false,
          :virtual_network        => false,
          :scale_set              => false,
          :verbose                => false
        }.merge(options)

        nis = Azure::Armrest::Network::NetworkInterfaceService.new(self.configuration)
        ips = Azure::Armrest::Network::IpAddressService.new(self.configuration)

        vm   = get(vmname, vmgroup)
        nics = vm.properties.network_profile.network_interfaces.map(&:id)

        delete_and_wait(self, vmname, vmgroup, options[:verbose])

        nics.each do |nic_string|
          nic_group = nic_string[/.*resourceGroups\/(.*?)\//i, 1]
          nic_name = File.basename(nic_string)
          nic = nis.get(nic_name, nic_group)

          if options[:network_interfaces]
            delete_and_wait(nis, nic_name, nic_group, options[:verbose])

            if options[:ip_addresses]
              nic.properties.ip_configurations.each do |ip|
                ip_string = ip.properties.public_ip_address.id
                ip_group = ip_string[/.*resourceGroups\/(.*?)\//i, 1]
                ip_name = File.basename(ip_string)
                delete_and_wait(ips, ip_name, ip_group, options[:verbose])
              end
            end
          end
        end

        if options[:os_disk]
          delete_associated_disk(vm)
        end

        if options[:storage_account]
          delete_and_wait(sas, storage_acct_obj.name, storage_acct_obj.resource_group, options[:verbose])
        end
      end

      def model_class
        VirtualMachineModel
      end

      private

      # This deletes the OS disk from the storage account that's backing the
      # virtual machine, along with the .status file. This does NOT delete
      # copies of the disk.
      #
      def delete_associated_disk(vm)
        uri = Addressable::URI.parse(vm.properties.storage_profile.os_disk.vhd.uri)

        # The uri looks like https://foo123.blob.core.windows.net/vhds/something123.vhd
        storage_acct_name = uri.host.split('.').first     # storage name, e.g. 'foo123'
        storage_acct_disk = File.basename(uri.to_s)       # disk name, e.g. 'something123.vhd'
        storage_acct_path = File.dirname(uri.path)[1..-1] # container, e.g. 'vhds'

        # Must find it this way because the resource group information isn't provided
        sas = Azure::Armrest::StorageAccountService.new(self.configuration)
        storage_acct_obj  = sas.list_all.find{ |s| s.name == storage_acct_name }
        storage_acct_keys = sas.list_account_keys(storage_acct_obj.name, storage_acct_obj.resource_group)

        key = storage_acct_keys['key1'] || storage_acct_keys['key2']

        storage_acct_obj.blobs(storage_acct_path, key).each do |blob|
          extension = File.extname(blob.name)
          next unless ['.vhd', '.status'].include?(extension)

          if blob.name == storage_acct_disk
            storage_acct_obj.delete_blob(blob.container, blob.name, key)
          end

          if extension == '.status' && blob.name.start_with?(vm.name)
            storage_acct_obj.delete_blob(blob.container, blob.name, key)
          end
        end
      end

      # Delete a +service+ type resource using its name and resource group,
      # and wait for the operation to complete before returning.
      #
      # If the operation fails because a dependent resource is still attached,
      # then the error is logged (in verbose mode) and ignored.
      #
      def delete_and_wait(service, name, group, verbose = false)
        resource_type = service.class.to_s.sub('Service', '').split('::').last
        puts "Deleting #{resource_type} #{name}/#{group}..." if verbose
        headers = service.delete(name, group)
        wait(headers)
        puts "Deleted #{resource_type} #{name}/#{group}" if verbose
      rescue Azure::Armrest::BadRequestException, Azure::Armrest::PreconditionFailedException => err
        puts "Unable to delete #{resource_type} #{name}/#{group}. Message: #{err.message}"
      end

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
