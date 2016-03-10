#
module Azure
  module Armrest
    #
    class VirtualMachineInstance < VirtualMachine
      attr_accessor :service
      attr_accessor :hash

      def initialize(hash_string, service = Nil)
        super(service)

        hash = if hash_string.kind_of? Hash
                 hash_string
               else
                 JSON.parse(hash_string, :symbolize_names => true)
               end

        @hash = hash
      end
    end
  end
end
