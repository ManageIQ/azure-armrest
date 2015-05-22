# Azure namespace
module Azure
  # ArmRest namespace
  module ArmRest
    # Base class for managing availability sets.
    class AvailabilitySetManager < ArmRestManager

      # Create and return a new AvailabilitySetManager (ASM) instance. Most
      # methods for an ASM instance will return one or more AvailabilitySet
      # instances.
      #
      def initialize(subscription_id, resource_group_name, api_version = '2015-1-1')
        super

        @uri += "/resourceGroups/#{resource_group_name}"
        @uri += "/providers/Microsoft.Compute/availabilitySets"
      end

      # Creates a new availability set.
      #
      # TODO: The current documentation doesn't seem to list all the possible
      # options at this time.
      #--
      def create(set_name, options = {})
        @uri += "#{set_name}?api-version=#{api_version}"
      end

      # Deletes the +set_name+ availability set.
      def delete(set_name)
        @uri += "#{set_name}?api-version=#{api_version}"
      end

      # Retrieves the options of an availability set.
      def get(set_name)
        @uri += "#{set_name}?api-version=#{api_version}"
      end

      # List availability sets.
      def list
        @uri += "?api-version=#{api_version}"
      end
    end
  end
end
