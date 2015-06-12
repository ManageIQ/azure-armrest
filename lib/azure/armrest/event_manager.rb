module Azure
  module ArmRest
    class EventManager < ArmRestManager

      def initialize(options = {})
        super

        @base_url += "providers/microsoft.insights/eventtypes/management/values"
        @base_url += "?api-version=#{@api_version}"
      end

      # check what data type the event channel is

      def get_rg_events(starttime, endtime, channels, rg_name )
        @uri += build_filter += " and resourceGroupName eq '#{rg_name}'"
      end

      def get_resource_events(starttime, endtime, channels, resource_uri )
        @uri += build_filter += " and resourceUri eq '#{resource_uri}'"
      end

      def build_filter(starttime, endtime, channels)
        "$filter=eventTimestamp ge '#{starttime}' and eventTimestamp le '#{endtime}'
         and eventChannels eq '#{channels}'"
      end

      def select_properties(property_names)
        "&$select={property_names}"
      end
    end
  end
end
