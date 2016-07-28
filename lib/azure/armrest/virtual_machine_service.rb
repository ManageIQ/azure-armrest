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
      # Because these resources could be associated with multiple VM's, you
      # should be careful about deleting them. That said, attempting to
      # delete these items with associated resources still attached will
      # typically fail automatically. We make no guarantees here, though.
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

        sas = Azure::Armrest::StorageAccountService.new(self.configuration)
        nis = Azure::Armrest::Network::NetworkInterfaceService.new(self.configuration)
        ips = Azure::Armrest::Network::IpAddressService.new(self.configuration)

        vm   = get(vmname, vmgroup)
        nics = vm.properties.network_profile.network_interfaces.map(&:id)

        # Delete operations are asynchronous, so we have to poll after
        # submitting delete operations.

        delete(vmname, vmgroup)
        puts "Deleting VM #{vmname}..." if options[:verbose]

        sleep 10 while list(vmgroup).find{ |vm| vm.name == vmname }
        puts "VM #{vmname} deleted" if options[:verbose]

        nics.each do |nic_string|
          nic_group = nic_string[/.*resourceGroups\/(.*?)\//i, 1]
          nic_name = File.basename(nic_string)
          nic = nis.get(nic_name, nic_group)

          if options[:network_interfaces]
            nis.delete(nic_name, nic_group)
            puts "Deleting NIC #{nic_name}..." if options[:verbose]

            sleep 10 while nis.list(nic_group).find{ |n| n.name == nic_name }
            puts "NIC #{nic_name} deleted" if options[:verbose]

            if options[:ip_addresses]
              nic.properties.ip_configurations.each do |ip|
                ip_string = ip.properties.public_ip_address.id
                ip_group = ip_string[/.*resourceGroups\/(.*?)\//i, 1]
                ip_name = File.basename(ip_string)
                ips.delete(ip_name, ip_group)
                puts "Deleting Public IP #{ip_name}..." if options[:verbose]
              end
            end
          end
        end

        uri = Addressable::URI.parse(vm.properties.storage_profile.os_disk.vhd.uri)

        storage_acct_name = uri.host.split('.').first
        storage_acct      = sas.list_all.find{ |s| s.name == storage_acct_name }
        storage_acct_key  = sas.list_account_keys(storage_acct.name, storage_acct.resource_group)['key1']

        if options[:os_disk]
          storage_acct.all_blobs(storage_acct_key).each do |blob|
            storage_acct.delete_blob(blob.container, blob.name, storage_acct_key)
            sleep 10 while storage_acct.all_blobs.find{ |b| b.name == blob.name }
          end
        end

        if options[:storage_account]
          sas.delete(storage_acct.name, storage_acct.resource_group)
        end
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
