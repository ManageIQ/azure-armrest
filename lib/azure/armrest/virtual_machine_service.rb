# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Base class for managing virtual machines
    class VirtualMachineService < ArmrestService

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
        set_service_api_version(options, 'virtualMachines')
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

      # Returns a list of available virtual machines for the given subscription
      # for the provided +group+, or all resource groups if none is provided.
      #
      # Examples:
      #
      #   # Get VM's for all resource groups
      #   vmm.list
      #
      #   # Get VM's only for a specific group
      #   vmm.list('some_group')
      #--
      # The specific hashes we can grab are:
      # p JSON.parse(resp.body)["value"][0]["properties"]["instanceView"]
      # p JSON.parse(resp.body)["value"][0]["properties"]["hardwareProfile"]
      # p JSON.parse(resp.body)["value"][0]["properties"]["storageProfile"]
      #
      def list(group = armrest_configuration.resource_group)
        array = []

        if group
          url = build_url(group)
          array << JSON.parse(rest_get(url))['value']
        else
          threads = []
          mutex = Mutex.new

          resource_groups.each do |rg|
            threads << Thread.new(rg['name']) do |rgroup|
              response = rest_get(build_url(rgroup))
              result = JSON.parse(response)['value']
              if result
                mutex.synchronize{
                  result.each{ |hash| hash['resourceGroup'] = rgroup }
                  array << result
                }
              end
            end
          end

          threads.each(&:join)

          array = array.flatten

          if provider.downcase == 'microsoft.compute'
            add_network_profile(array)
            add_power_status(array)
          end
        end

        array
      end

      alias get_vms list

      # Captures the +vmname+ and associated disks into a reusable CSM template.
      # The 3rd argument is a hash of options that supports the following keys:
      #
      # * prefix    - The prefix in the name of the blobs.
      # * container - The name of the container inside which the image will reside.
      # * overwrite - Boolean that indicates whether or not to overwrite any VHD's
      #               with the same prefix. The default is false.
      #
      # The :prefix and :container options are mandatory. You may optionally
      # specify the :resource_group as an option, or as the 3rd argument, but
      # it is also mandatory if not already set in the constructor.
      #
      # Note that this is a long running operation. You are expected to
      # poll on the client side to check the status of the operation.
      #
      def capture(vmname, options = {}, group = nil)
        prefix = options.fetch(:prefix)
        container = options.fetch(:container)
        overwrite = options[:overwrite] || false
        group ||= options[:resource_group] || armrest_configuration.resource_group

        raise ArgumentError, "no resource group provided" unless group

        body = {
          :vhdPrefix => prefix,
          :destinationContainerName => container,
          :overwriteVhds => overwrite
        }.to_json

        url = build_url(group, vmname, 'capture')

        response = rest_post(url, body)
        response.return!
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

      #alias update create

      # Stop the VM +vmname+ in +group+ and deallocate the tenant in Fabric.
      #
      def deallocate(vmname, group = armrest_configuration.resource_group)
        raise ArgumentError, "no resource group provided" unless group
        url = build_url(group, vmname, 'deallocate')
        response = rest_post(url)
        response.return!
      end

      # Deletes the +vmname+ in +group+ that you specify. Note that associated
      # disks are not deleted.
      #
      def delete(vmname, group = armrest_configuration.resource_group)
        raise ArgumentError, "no resource group provided" unless group
        url = build_url(group, vmname)
        response = rest_delete(url)
        response.return!
      end

      # Sets the OSState for the +vmname+ in +group+ to 'Generalized'.
      #
      def generalize(vmname, group = armrest_configuration.resource_group)
        raise ArgumentError, "no resource group provided" unless group
        url = build_url(group, vmname, 'generalize')
        response = rest_post(url)
        response.return!
      end

      # Retrieves the settings of the VM named +vmname+ in resource group
      # +group+, which will default to the same as the name of the VM.
      #
      # By default this method will retrieve the model view. If the +model_view+
      # parameter is false, it will retrieve an instance view. The difference is
      # in the details of the information retrieved.
      #
      def get(vmname, group = armrest_configuration.resource_group, model_view = true)
        raise ArgumentError, "no resource group provided" unless group

        if model_view
          url = build_url(group, vmname)
        else
          url = build_url(group, vmname, 'instanceView')
        end

        JSON.parse(rest_get(url))
      end

      # Convenient wrapper around the get method that retrieves the model view
      # for +vmname+ in resource_group +group+.
      #
      def get_model_view(vmname, group = armrest_configuration.resource_group)
        raise ArgumentError, "no resource group provided" unless group
        get(vmname, group, true)
      end

      # Convenient wrapper around the get method that retrieves the instance view
      # for +vmname+ in resource_group +group+.
      #
      def get_instance_view(vmname, group = armrest_configuration.resource_group)
        raise ArgumentError, "no resource group provided" unless group
        get(vmname, group, false)
      end

      # Restart the VM +vmname+ for the given +group+, which will default
      # to the same as the vmname.
      #
      # This is an asynchronous operation that returns a response object
      # which you can inspect, such as response.code or response.headers.
      #
      def restart(vmname, group = armrest_configuration.resource_group)
        raise ArgumentError, "no resource group provided" unless group
        url = build_url(group, vmname, 'restart')
        response = rest_post(url)
        response.return!
      end

      # Start the VM +vmname+ for the given +group+, which will default
      # to the same as the vmname.
      #
      # This is an asynchronous operation that returns a response object
      # which you can inspect, such as response.code or response.headers.
      #
      def start(vmname, group = armrest_configuration.resource_group)
        raise ArgumentError, "no resource group provided" unless group
        url = build_url(group, vmname, 'start')
        response = rest_post(url)
        response.return!
      end

      # Stop the VM +vmname+ for the given +group+ gracefully. However,
      # a forced shutdown will occur after 15 minutes.
      #
      # This is an asynchronous operation that returns a response object
      # which you can inspect, such as response.code or response.headers.
      #
      def stop(vmname, group = armrest_configuration.resource_group)
        raise ArgumentError, "no resource group provided" unless group
        url = build_url(group, vmname, 'powerOff')
        response = rest_post(url)
        response.return!
      end

      private

      def add_network_profile(vms)
        vms.each { |vm|
          vm['properties']['networkProfile']['networkInterfaces'].each { |net|
            get_nic_profile(net)
          }
        }
      end

      def get_nic_profile(nic)
        url = File.join(
          Azure::Armrest::RESOURCE,
          nic['id'],
          "?api-version=#{@api_version}"
        )

        nic['properties'] = JSON.parse(rest_get(url))['properties']['ipConfigurations']
        nic['properties'].each do |n|
          next if n['properties']['publicIPAddress'].nil?

          # public IP is a URI so we need to make another rest call to get it.
          url = File.join(
            Azure::Armrest::RESOURCE,
            n['properties']['publicIPAddress']['id'],
            "?api-version=#{@api_version}"
          )

          public_ip = JSON.parse(rest_get(url))['properties']['ipAddress']
          n['properties']['publicIPAddress'] = public_ip
        end
      end

      def add_power_status(vms)
        vms.each do |vm|
          i_view            = get_instance_view(vm["name"], vm["resourceGroup"])
          powerstatus_hash  = i_view["statuses"].find {|h| h["code"].include? "PowerState"}
          vm["powerStatus"] = powerstatus_hash['displayStatus'] unless powerstatus_hash.nil?
        end
      end

      # If no default subscription is set, then use the first one found.
      def set_default_subscription
        @subscription_id ||= subscriptions.first['subscriptionId']
      end

      # Builds a URL based on subscription_id an resource_group and any other
      # arguments provided, and appends it with the api_version.
      #
      def build_url(resource_group, *args)
        url = File.join(
          Azure::Armrest::COMMON_URI,
          armrest_configuration.subscription_id,
          'resourceGroups',
          resource_group,
          'providers',
          @provider,
          'virtualMachines',
        )

        url = File.join(url, *args) unless args.empty?
        url << "?api-version=#{@api_version}"
      end
    end
  end
end
