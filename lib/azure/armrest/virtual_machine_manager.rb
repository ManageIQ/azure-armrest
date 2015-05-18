module Azure
  module ArmRest
    # Base class for managing virtual machines.
    class VirtualMachineManager < ArmRestManager

      # Valid sizes that may be used when creating or updating a virtual machine.
      VALID_VM_SIZES = %w[
        Standard_A0
        Standard_A1
        Standard_A2
        Standard_A3
        Standard_A4
      ]

      # REST resource
      attr_accessor :uri

      # Create and return a new VirtualMachineManager instance.
      def initialize(subscription_id, resource_group_name, api_version = '2015-1-1')
        super

        @uri += "/resourceGroups/#{resource_group_name}"
        @uri += "/providers/Microsoft.Compute/VirtualMachines"
      end

      #
      #--
      # POST
      def capture
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
        name = options.fetch(:name)
        location = options.fetch(:location)
        tags = option[:tags]
        vmsize = options.fetch(:vmsize)

        unless VALID_VM_SIZES.include?(vmsize)
          raise ArgumentError, "Invalid vmsize '#{vmsize}'"
        end
      end

      alias update create

      def deallocate
      end

      # DELETE
      def delete
      end

      # POST
      def generalize
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
          uri = @uri + "/#{vmname}?api-version=#{api_version}"
        else
          uri = @uri + "/#{vmname}/InstanceView?api-version=#{api_version}"
        end
      end

      # GET
      def operations
      end

      # POST
      def restart
      end

      # POST
      def start
      end

      # POST
      def stop
      end
    end
  end
end
