require 'delegate'
require 'ostruct'

module Azure
  module ArmRest
    # Base class for JSON wrapper classes. Each Manager class should have
    # a corresponding class that wraps the JSON it collects, and each of
    # them should subclass this base class.
    class BaseWrapper < Delegator
      # Access the json instance variable directly.
      attr_accessor :json

      # Constructs and returns a new JSON wrapper class. Pass in a plain
      # JSON string and it will automatically give you accessor methods
      # that make it behave like a typical Ruby object.
      #
      # Example:
      #   class Person < Azure::ArmRest::BaseJsonWrapper; end
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
        @json = json
        @ostruct = JSON.parse(json, object_class: OpenStruct)
        __setobj__(@ostruct)
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
            __setobj__(res) if res.is_a?(OpenStruct)
          end
          snake = m.to_s.gsub(/(.)([A-Z])/,'\1_\2').downcase.to_sym
          obj.instance_eval("alias #{snake} #{m}")
        }
      end
    end
  end
end
