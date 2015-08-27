module Azure
  module Armrest
    class ResourceGroupService < ArmrestService
      # The provider used in http requests. The default is 'Microsoft.Resources'
      attr_reader :provider

      # Creates and returns a new ResourceGroupService object.
      #
      def initialize(_armrest_configuration, options = {})
        super

        @provider = options[:provider] || 'Microsoft.Resources'

        set_service_api_version(options, 'resourceGroups')
      end

      # List all the resources for the current subscription. You can optionally
      # pass :top or :filter options as well to restrict returned results.
      #
      # If you pass a :resource_group option, then only resources for that
      # resource group are returned.
      #
      # Examples:
      #
      #   rgs = ResourceGroupService.new
      #   rgs.list(:top => 2)
      #   rgs.list(:filter => "location eq 'centralus'")
      #
      def list(options = {})
        url = File.join(Azure::Armrest::COMMON_URI, subscription_id, 'resourcegroups')

        url << "?api-version=#{api_version}"
        url << "&$top=#{options[:top]}" if options[:top]
        url << "&$filter=#{options[:filter]}" if options[:filter]

        response = rest_get(URI.escape(url))

        JSON.parse(response.body)["value"]
      end

      # Creates a new +group+ in +location+ for the current subscription.
      # You may optionally apply +tags+.
      #
      def create_resource_group(group, location, tags = nil)
        body = {:location => location, :tags => tags}.to_json

        url = File.join(Azure::Armrest::COMMON_URI, subscription_id, 'resourcegroups', group)
        url << "?api-version=#{api_version}"

        response = rest_put(url, body)

        JSON.parse(response.body)
      end

      # Delete a resource group from the current subscription.
      #
      def delete_resource_group(group)
        url = File.join(Azure::Armrest::COMMON_URI, subscription_id, 'resourcegroups', group)
        url << "?api-version=#{api_version}"

        response = rest_delete(url)
        response.return!
      end

      # Returns information for the given resource group.
      #
      def get_resource_group(group)
        url = File.join(Azure::Armrest::COMMON_URI, subscription_id, 'resourcegroups', group)
        url << "?api-version=#{api_version}"

        response = rest_get(url)

        JSON.parse(response.body)
      end

      # Updates the tags for the given resource group.
      #
      def update_resource_group(group, tags)
        body = {:tags => tags}.to_json

        url = File.join(Azure::Armrest::COMMON_URI, subscription_id, 'resourcegroups', group)
        url << "?api-version=#{api_version}"

        response = rest_patch(url, body)
        response.return!
      end

    end # ResourceGroupService
  end # Armrest
end # Azure
