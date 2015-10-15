require 'delegate'
require 'ostruct'

module Azure
  module Armrest
    # Base class for JSON wrapper classes. Each Service class should have
    # a corresponding class that wraps the JSON it collects, and each of
    # them should subclass this base class.
    class BaseModel < Delegator

      # Declare that a method should return a plain hash instead of an
      # OpenStruct instance.
      #--
      # TODO: Handle nested properties.
      def self.hash_properties(method)
        define_method(method){ @ostruct[method].to_h }
      end

      hash_properties :tags

      # Access the json instance variable directly.
      attr_accessor :json

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
      #   person.json # => Returns original JSON
      #
      def initialize(json)
        json = json.to_json unless json.is_a?(String)
        @json = json
        @resource_group = nil
        @ostruct = JSON.parse(json, object_class: OpenStruct)
        __setobj__(@ostruct)
      end

      # Return the resource group for the current object.
      def resource_group
        @resource_group ||= id[/resourceGroups\/(.+?)\//i, 1] rescue nil
      end

      # Returns the original JSON string passed to the constructor.
      def to_json
        @json
      end

      # Explicitly convert the object to the original JSON string.
      def to_s
        @json
      end

      # Implicitly convert the object to the original JSON string.
      def to_str
        @json
      end

      # Custom inspect method that shows the current class and methods.
      #--
      # TODO: Make this recursive.
      def inspect
        string = "<#{self.class} "
        method_list = methods(false).select{ |m| !m.to_s.include?('=') }
        string << method_list.map{ |m| "#{m}=#{send(m)}" }.join(" ")
        string << ">"
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
        obj.methods(false).each{ |m|
          if m.to_s[-1] != '=' # Must deal with nested ostruct's
            res = obj.send(m)
            if res.respond_to?(:each)
              res.each{ |o| __setobj__(o) if o.is_a?(OpenStruct) }
            else
              __setobj__(res) if res.is_a?(OpenStruct)
            end
          end

          snake = m.to_s.gsub(/(.)([A-Z])/,'\1_\2').downcase.to_sym

          begin
            obj.instance_eval("alias #{snake} #{m}") unless snake == m
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
    class TemplateDeployment < BaseModel; end
    class TemplateDeploymentOperation < TemplateDeployment; end
    class Tenant < BaseModel; end
    class VirtualMachine < BaseModel; end
    class VirtualMachineInstance < VirtualMachine; end
    class VirtualMachineModel < VirtualMachine; end
    class VirtualMachineExtension < BaseModel; end
    class VirtualMachineImage < BaseModel; end

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
