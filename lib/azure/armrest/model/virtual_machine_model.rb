#
module Azure
  module Armrest
    #
    class VirtualMachineModel < VirtualMachine
      attr_accessor :id
      attr_accessor :name
      attr_accessor :type
      attr_accessor :location
      attr_accessor :tags
      attr_accessor :properties

      def initialize(hash_string, service=nil)
        super(service)

        if hash_string.kind_of?(Hash)
          hash = hash_string
        else
          hash = JSON.parse(hash_string, symbolize_names: true)
        end

        properties_hash = hash[:properties]
        @id = hash[:id]
        @name = hash[:name]
        @type = hash[:type]
        @location = hash[:location]
        @tags = hash[:tags]

        @properties = VirtualMachineProperties.new(properties_hash)
      end

      def os_disk
        @properties.storage_profile.os_disk
      end

      def data_disks
        @properties.storage_profile.data_disks
      end

      def networks
        @properties.network_profile.network_interfaces
      end

      def inspect
        string = "<#{self.class} "
        string << instance_variables.map { |v| " #{v}=#{instance_variable_get(v)}" }.join(", \n")
        string << '>'
      end

      class VirtualMachineProperties
        attr_accessor :vm_id
        attr_accessor :hardware_profile
        attr_accessor :storage_profile
        attr_accessor :os_profile
        attr_accessor :network_profile
        attr_accessor :provisioning_state

        def initialize(hash)
          hardware_hash = hash[:hardwareProfile]
          storage_hash = hash[:storageProfile]
          os_hash = hash[:osProfile]
          network_hash = hash[:networkProfile]

          @vm_id = hash[:vmId]
          @provisioning_state = hash[:provisioningState]
          @hardware_profile = VirtualMachineHardwarePropertie.new(hardware_hash)
          @storage_profile = VirtualMachineStoragePropertie.new(storage_hash)
          @os_profile = VirtualMachineOsPropertie.new(os_hash)
          @network_profile = VirtualMachineNetworkPropertie.new(network_hash)
        end

        class VirtualMachineHardwarePropertie
          attr_accessor :vm_size

          def initialize(hash)
            @vm_size = hash[:vmSize]
          end
        end

        class VirtualMachineStoragePropertie
          attr_accessor :image_reference
          attr_accessor :os_disk
          attr_accessor :data_disks

          def initialize(hash)
            @image_reference = ImageReference.new(hash[:imageReference])
            @os_disk = OsDisk.new(hash[:osDisk])
            @data_disks ||= []

            data_disks_hash = hash[:dataDisks]
            data_disks_hash.each do |data_disk_hash|
              @data_disks.push DataDisk.new(data_disk_hash)
            end
          end

          #
          class ImageReference
            attr_accessor :publisher
            attr_accessor :offer
            attr_accessor :sku
            attr_accessor :version

            def initialize(hash)
              @publisher = hash[:publisher]
              @offer = hash[:offer]
              @sku = hash[:sku]
              @version = hash[:version]
            end
          end
        end

        #
        class VirtualMachineOsPropertie
          attr_accessor :computer_name
          attr_accessor :admin_username
          attr_accessor :linux_configuration
          attr_accessor :windows_configuration
          attr_accessor :secrets

          def initialize(hash)
            @computer_name = hash[:computerName]
            @admin_username = hash[:adminUsername]
            @linux_configuration = hash[:linuxConfiguration]
            @windows_configuration = hash[:windowsConfiguration]
            @secrets = hash[:secrets]
          end
        end

        #
        class VirtualMachineNetworkPropertie
          attr_accessor :network_interfaces

          def initialize(hash)
            @network_interfaces ||= []
            networks_interface_hash = hash[:networkInterfaces]
            networks_interface_hash.each do |network_interface_hash|
              @network_interfaces.push NetworkInterface.new(network_interface_hash)
            end
          end

          class NetworkInterface
            attr_accessor :id
            attr_accessor :properties

            def initialize(hash)
              @id = hash[:id]
              @properties = hash[:properties]
            end
          end
        end
      end
    end
  end
end
