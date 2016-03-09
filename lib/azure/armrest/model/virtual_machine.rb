#
module Azure
  module Armrest
    #
    class VirtualMachine
      attr_accessor :service

      def initialize(service=Nil)
        @service = service
      end

      # VM actions
      # Stop the VM deallocate the tenant in Fabric.
      def deallocate
        @service.deallocate(@name)
      end

      def capture
        @service.capture(@name)
      end

      # Sets the OSState 'Generalized'.
      def generalize
        @service.generalize(@name)
      end
      
      # Restart the VM
      def restart
        @service.restart(@name)
      end

      # Start the VM
      def start
        @service.start(@name)
      end

      # Stop the VM
      def stop
        @service.stop(@name)
      end

      # Delete VM
      def delete
        @service.delete(@name)
      end
    end
  end
end
