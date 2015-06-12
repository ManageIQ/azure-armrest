# Azure namespace
module Azure
  # ArmRest namespace
  module ArmRest
    # Base class for managing virtual machines
    class VirtualMachineManager < ArmRestManager

      # Valid sizes that may be used when creating or updating a virtual machine.
      VALID_VM_SIZES = %w[
        Standard_A0
        Standard_A1
        Standard_A2
        Standard_A3
        Standard_A4
      ]

      # Create and return a new VirtualMachineManager (VMM) instance. Most
      # methods for a VMM instance will return one or more VirtualMachine
      # instances.
      #
      def initialize(options = {})
        super

        @base_url = Azure::ArmRest::COMMON_URI + @subscription_id
        @base_url += "resourceGroups/#{@resource_group}/"
        @base_url += "providers/Microsoft.ClassicCompute/virtualMachines"

        @api_version = '2014-06-01'
      end

      # Returns a list of available virtual machines for the given subscription.
      def list
        url = @base_url + "?api-version=#{api_version}"

        rest_get(url)

        # The specific hashes we can grab are:
        # p JSON.parse(resp.body)["value"][0]["properties"]["instanceView"]
        # p JSON.parse(resp.body)["value"][0]["properties"]["hardwareProfile"]
        # p JSON.parse(resp.body)["value"][0]["properties"]["storageProfile"]
      end

      alias get_vms list

      # Captures the +vmname+ and associated disks into a reusable CSM template.
      #--
      # POST
      def capture(vmname, action = 'capture')
        uri = @uri + "/#{vmname}/#{action}?api-version=#{api_version}"
        uri
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
      #   vmm = VirtualMachineManager.new(x, y, z)
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
      #
      def create(options = {})
        #name = options.fetch(:name)
        #location = options.fetch(:location)
        #tags = option[:tags]
        vmsize = options.fetch(:vmsize)

        unless VALID_VM_SIZES.include?(vmsize)
          raise ArgumentError, "Invalid vmsize '#{vmsize}'"
        end
      end

      alias update create

      # Stop the VM and deallocate the tenant in Fabric.
      #--
      # POST
      def deallocate(vmname, action = 'deallocate')
        uri = @uri + "/#{vmname}/#{action}?api-version=#{api_version}"
        uri
      end

      # Deletes the +vmname+ that you specify.
      #--
      # DELETE
      def delete(vmname)
        uri = @uri + "/#{vmname}?api-version=#{api_version}"
        uri
      end

      # Sets the OSState for the +vmname+ to 'Generalized'.
      #--
      # POST
      def generalize(vmname, action = 'generalize')
        uri = @uri + "/#{vmname}/#{action}?api-version=#{api_version}"
        uri
      end

      # Retrieves the settings of the VM named +vmname+. By default this
      # method will retrieve the model view. If the +model_view+ parameter
      # is false, it will retrieve an instance view. The difference is
      # in the details of the information retrieved.
      #--
      # GET
      #
      def get(vmname, model_view = true)
        if model_view
          uri = @base_url + "/#{vmname}?api-version=#{api_version}"
        else
          uri = @base_url + "/#{vmname}/InstanceView?api-version=#{api_version}"
        end

        rest_get(uri)
      end

      # Returns a complete list of operations.
      #--
      # GET
      def operations
        # Base URI works as-is.
      end

      # Restart the VM.
      #--
      # POST
      def restart(vmname, action = 'restart')
        uri = @uri + "/#{vmname}/#{action}?api-version=#{api_version}"
        uri
      end

      # Start the VM.
      #--
      # POST
      def start(vmname, action = 'start')
        uri = @uri + "/#{vmname}/#{action}?api-version=#{api_version}"
        uri
      end

      # Stop the VM gracefully. However, a forced shutdown will occur
      # after 15 minutes.
      #--
      # POST
      def stop(vmname, action = 'stop')
        uri = @uri + "/#{vmname}/#{action}?api-version=#{api_version}"
        uri
      end
    end
  end
end
