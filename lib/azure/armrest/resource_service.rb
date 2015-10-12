module Azure
  module Armrest
    class ResourceService < ArmrestService
      # The provider used in http requests. The default is 'Microsoft.Resources'
      attr_reader :provider

      # Creates and returns a new ResourceService object.
      #
      def initialize(_armrest_configuration, options = {})
        super
        @provider = options[:provider] || 'Microsoft.Resources'
        set_service_api_version(options, 'subscriptions')
      end

      # List all the resources for the current subscription. You can optionally
      # pass :top or :filter options as well to restrict returned results.
      #
      # If you pass a :resource_group option, then only resources for that
      # resource group are returned.
      #
      # Examples:
      #
      #   rs = ResourceService.new
      #   rs.list(:top => 2)
      #   rs.list(:filter => "location eq 'centralus'")
      #
      def list(options = {})
        subscription_id = armrest_configuration.subscription_id

        if options[:resource_group]
          url = File.join(
            Azure::Armrest::COMMON_URI, subscription_id, 'resourcegroups',
            options[:resource_group], 'resources'
          )
        else
          url = File.join(Azure::Armrest::COMMON_URI, subscription_id, 'resources')
        end

        url << "?api-version=#{@api_version}"
        url << "&$top=#{options[:top]}" if options[:top]
        url << "&$filter=#{options[:filter]}" if options[:filter]

        response = rest_get(URI.escape(url))

        JSON.parse(response)["value"].map{ |hash| Azure::Armrest::Resource.new(hash) }
      end

      # Move the resources from +source_group+ under +source_subscription+,
      # which may be a different subscription.
      #
      def move(source_group, source_subscription = armrest_configuration.subscription_id)
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

    end # ResourceService
  end # Armrest
end # Azure
