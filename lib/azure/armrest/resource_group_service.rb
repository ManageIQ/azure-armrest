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
      # pass :top or :filter options as well to restrict returned results. The
      # :filter option only applies to tags.
      #
      # Examples:
      #
      #   rgs = ResourceGroupService.new
      #   rgs.list(:top => 2)
      #   rgs.list(:filter => "sometag=value")
      #
      def list(options = {})
        url = build_url
        url << "&$top=#{options[:top]}" if options[:top]
        url << "&$filter=#{options[:filter]}" if options[:filter]

        response = rest_get(URI.escape(url))

        JSON.parse(response)["value"].map{ |hash| Azure::Armrest::ResourceGroup.new(hash) }
      end

      # Creates a new +group+ in +location+ for the current subscription.
      # You may optionally apply +tags+.
      #
      def create(group, location, tags = nil)
        body = {:location => location, :tags => tags}.to_json
        url = build_url(group)

        response = rest_put(url, body)

        Azure::Armrest::ResourceGroup.new(response)
      end

      # Delete a resource group from the current subscription.
      #
      def delete(group)
        url = build_url(group)
        response = rest_delete(url)
        response.return!
      end

      # Returns information for the given resource group.
      #
      def get(group)
        url = build_url(group)
        response = rest_get(url)
        Azure::Armrest::ResourceGroup.new(response)
      end

      # Updates the tags for the given resource group.
      #
      def update(group, tags)
        body = {:tags => tags}.to_json
        url = build_url(group)
        response = rest_patch(url, body)
        response.return!
      end

      private

      def build_url(group = nil, *args)
        id = armrest_configuration.subscription_id
        url = File.join(Azure::Armrest::COMMON_URI, id, 'resourcegroups')
        url = File.join(url, group) if group
        url = File.join(url, *args) unless args.empty?
        url << "?api-version=#{@api_version}"
      end 

    end # ResourceGroupService
  end # Armrest
end # Azure
