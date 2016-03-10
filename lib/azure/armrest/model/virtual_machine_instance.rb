#
module Azure
  module Armrest
    #
    class VirtualMachineInstance < VirtualMachine
      attr_accessor :service

      def initialize(hash_string, service = Nil)
        super(service)

        if hash_string.kind_of?(Hash)
          hash = hash_string
        else
          hash = JSON.parse(hash_string, symbolize_names: true)
        end
      end
    end
  end
end
