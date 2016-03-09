#
module Azure
  #
  module Armrest
    #
    class OsDisk < BaseModel
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
        @create_option = hash[:createOption]
      end

      def inspect
        string = "<#{self.class} "
        string << instance_variables.map { |v| " #{v}=#{instance_variable_get(v)}" }.join(", \n")
        string << '>'
      end
    end
  end
end
