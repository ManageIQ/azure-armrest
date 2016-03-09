#
module Azure
  #
  module Armrest
    #
    class DataDisk < BaseModel
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

      def inspect
        string = "<#{self.class} "
        string << instance_variables.map { |v| " #{v}=#{instance_variable_get(v)}" }.join(", \n")
        string << '>'
      end
    end
  end
end
