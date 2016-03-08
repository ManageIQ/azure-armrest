#
module Azure
  #
  module Armrest
    #
    class DataDisk
      attr_accessor :lun
      attr_accessor :name
      attr_accessor :create_option
      attr_accessor :vhd
      attr_accessor :caching

      def initialize(hash)
        @lun = hash[:lun]
        @name = hash[:name]
        @create_option = hash[:createOption]
        @vhd = hash[:vhd]
        @caching = hash[:caching]
      end
    end
  end
end
