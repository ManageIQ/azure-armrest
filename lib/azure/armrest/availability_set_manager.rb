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
      def initialize(options = {})
        super

        @base_url += "resourceGroups/#{@resource_group}/"
        @base_url += "providers/Microsoft.Compute/availabilitySets"
      end

      # Creates a new availability set.
      #
      # TODO: The current documentation doesn't seem to list all the possible
      # options at this time.
      #--
      def create(set_name, options = {})
        url = @uri + "#{set_name}?api-version=#{api_version}"
        url
      end

      alias update create

      # Deletes the +set_name+ availability set.
      def delete(set_name)
        url = @uri + "#{set_name}?api-version=#{api_version}"
        url
      end

      # Retrieves the options of an availability set.
      def get(set_name)
        url = @uri + "#{set_name}?api-version=#{api_version}"
        url
      end

      # List availability sets.
      def list
        url = @uri + "?api-version=#{api_version}"
        url
      end
    end
  end
end
