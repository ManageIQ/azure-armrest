module Azure
  module Armrest
    class ResourceService < ArmrestService
      # The provider used in http requests. The default is 'Microsoft.Resources'
      attr_reader :provider

      # Creates and returns a new ResourceService object.
      #
      def initialize(configuration, options = {})
        super(configuration, 'subscriptions', 'Microsoft.Resources', options)
      end

      # List all the resources for the current subscription in the specified
      # resource group. You can optionally pass :top or :filter options as well
      # to restrict returned results.
      #
      # Examples:
      #
      #   rs = Azure::Armrest::ResourceService.new
      #   rs.list(your_group, :top => 2)
      #   rs.list(your_group, :filter => "location eq 'centralus'")
      #
      def list(resource_group, options = {})
        url = build_url(resource_group, options)
        response = rest_get(url)
        Azure::Armrest::ArmrestCollection.create_from_response(response, Azure::Armrest::Resource)
      end

      # Same as Azure::Armrest::ResourceService#list but returns all resources
      # for all resource groups.
      #
      def list_all(options = {})
        url = build_url(nil, options)
        response = rest_get(url)
        Azure::Armrest::ArmrestCollection.create_from_response(response, Azure::Armrest::Resource)
      end

      # Move the resources from +source_group+ under +source_subscription+,
      # which may be a different subscription.
      #
      def move(source_group, source_subscription = configuration.subscription_id)
        url = File.join(
          Azure::Armrest::COMMON_URI, source_subscription,
          'resourcegroups', source_group, 'moveresources'
        )

        url << "?api-version=#{@api_version}"

        response = rest_post(url)
        response.return!
      end

      # Checks to see if the given 'resource_name' and 'resource_type' is allowed.
      # This returns a JSON string that will indicate the status, including an error
      # code and message on failure.
      #
      # If you want a simple boolean check, use the check_resource? method instead.
      #
      def check_resource(resource_name, resource_type)
        body = JSON.dump(:Name => resource_name, :Type => resource_type)
        url = File.join(Azure::Armrest::RESOURCE, 'providers', provider, 'checkresourcename')
        url << "?api-version=#{@api_version}"

        response = rest_post(url, body)
        response.return!
      end

      # Similar to the check_resource method, but returns a boolean instead.
      #
      def check_resource?(resource_name, resource_type)
        check_resource(resource_name, resource_type)['status'] == 'Allowed'
      end

      private

      def build_url(resource_group = nil, options = {})
        url = File.join(Azure::Armrest::COMMON_URI, configuration.subscription_id)

        if resource_group
          url = File.join(url, 'resourceGroups', resource_group, 'resources')
        else
          url = File.join(url, 'resources')
        end

        url << "?api-version=#{@api_version}"
        url << "&$top=#{options[:top]}" if options[:top]
        url << "&$filter=#{options[:filter]}" if options[:filter]

        url
      end
    end # ResourceService
  end # Armrest
end # Azure
