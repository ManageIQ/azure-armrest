#
module Azure
  #
  module Armrest
    #
    class OsDisk
      attr_accessor :os_type
      attr_accessor :name
      attr_accessor :vhd
      attr_accessor :caching
      attr_accessor :create_option

      def initialize(hash)
        @os_type = hash[:osType]
        @name = hash[:name]
        @vhd = hash[:vhd]
        @caching = hash[:caching]
        @create_option = hash[:create_option]
      end
    end
  end
end
