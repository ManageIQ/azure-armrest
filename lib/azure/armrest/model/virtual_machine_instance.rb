#
module Azure
  module Armrest
    #
    class VirtualMachineInstance < VirtualMachine
      attr_accessor :service

      def initialize(hash_string, service=Nil)
        super(service)
      end
    end
  end
end
