require 'delegate'
require 'ostruct'

module Azure
  module Armrest
    # Base class for JSON wrapper classes. Each Service class should have
    # a corresponding class that wraps the JSON it collects, and each of
    # them should subclass this base class.
    class BaseModel < Delegator
      def self.excl_list
        # initially inherit the exclusion list from parent class or create an empty Set
        @excl_list ||= superclass.respond_to?(:excl_list, true) ? superclass.send(:excl_list) : Set.new
      end
      private_class_method :excl_list

      def self.attr_hash(*attrs)
        # merge the declared exclusive attributes to the existing list
        @excl_list = excl_list | Set.new(attrs.map(&:to_s))
      end
      private_class_method :attr_hash

      attr_hash :tags

      # Constructs and returns a new JSON wrapper class. Pass in a plain
      # JSON string and it will automatically give you accessor methods
      # that make it behave like a typical Ruby object. You may also pass
      # in a hash.
      #
      # Example:
      #   class Person < Azure::ArmRest::BaseModel; end
      #
      #   json_string = '{"firstname":"jeff", "lastname":"durand",
      #     "address": { "street":"22 charlotte rd", "zipcode":"01013"}
      #   }'
      #
      #   # Or whatever your subclass happens to be.
      #   person = Person.new(json_string)
      #
      #   # The JSON properties are now available as methods.
      #   person.firstname        # => 'jeff'
      #   person.address.zipcode  # => '01013'
      #
      #   # Or you can get back the original JSON if necessary.
      #   person.to_json # => Returns original JSON
      #
      def initialize(json)
        # Find the exclusion list for the model of next level (@embedModel)
        # '#' is the separator between levels. Remove attributes
        # before the first separator.
        child_excl_list = self.class.send(:excl_list).map do |e|
          e.index('#') ? e[e.index('#') + 1 .. -1] : ''
        end
        @embedModel = Class.new(BaseModel) do
          attr_hash *child_excl_list
        end

        if json.is_a?(Hash)
          hash = json
          @json = json.to_json
        else
          hash = JSON.parse(json)
          @json = json
        end

        @ostruct = OpenStruct.new(hash)
        super(@ostruct)
      end

      def resource_group
        @resource_group ||= id[/resourceGroups\/(.+?)\//i, 1] rescue nil
      end

      def resource_group=(rg)
        @resource_group = rg
      end

      def to_json
        @json
      end

      def to_s
        @json
      end

      def to_str
        @json
      end

      def inspect
        string = "<#{self.class} "
        method_list = methods(false).select{ |m| !m.to_s.include?('=') }
        string << method_list.map{ |m| "#{m}=#{send(m).inspect}" }.join(", ")
        string << ">"
      end

      def ==(other)
        return false unless other.kind_of?(BaseModel)
        __getobj__ == other.__getobj__
      end

      def eql?(other)
        return false unless other.kind_of?(BaseModel)
        __getobj__.eql?(other.__getobj__)
      end

      protected

      # Interface method required to make delegation work. Do
      # not use this method directly.
      def __getobj__
        @ostruct
      end

      # A custom Delegator interface method that creates snake_case
      # versions of the camelCase delegate methods.
      def __setobj__(obj)
        excl_list = self.class.send(:excl_list)
        obj.methods(false).each{ |m|
          if m.to_s[-1] != '=' && !excl_list.include?(m.to_s) # Must deal with nested models
            res = obj.send(m)
            if res.is_a?(Array)
              newval = res.map { |elem| elem.is_a?(Hash) ? @embedModel.new(elem) : elem }
              obj.send("#{m}=", newval)
            elsif res.is_a?(Hash)
              obj.send("#{m}=", @embedModel.new(res))
            end
          end

          snake = m.to_s.gsub(/(.)([A-Z])/,'\1_\2').downcase.to_sym

          begin
            obj.instance_eval("alias #{snake} #{m}; undef :#{m}") unless snake == m
          rescue SyntaxError
            next
          end
        }
      end
    end

    # Initial class definitions. Reopen these classes as needed.

    class AvailabilitySet < BaseModel; end
    class Event < BaseModel; end
    class Resource < BaseModel; end
    class ResourceGroup < BaseModel; end
    class ResourceProvider < BaseModel; end
    class StorageAccount < BaseModel; end
    class Subscription < BaseModel; end
    class Tag < BaseModel; end
    class TemplateDeployment < BaseModel
      attr_hash 'properties#parameters', 'properties#outputs'
    end
    class TemplateDeploymentOperation < TemplateDeployment; end
    class Tenant < BaseModel; end
    class VirtualMachine < BaseModel; end
    class VirtualMachineInstance < VirtualMachine; end
    class VirtualMachineModel < VirtualMachine; end
    class VirtualMachineExtension < BaseModel; end
    class VirtualMachineImage < BaseModel; end
    class VirtualMachineSize < BaseModel; end

    module Network
      class IpAddress < BaseModel; end
      class NetworkInterface < BaseModel; end
      class NetworkSecurityGroup < BaseModel; end
      class VirtualNetwork < BaseModel; end
      class Subnet < VirtualNetwork; end
    end
  end
end

require_relative 'storage_account' 
