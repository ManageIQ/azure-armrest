module Azure
  module Armrest
    class ResourceGroupService < ArmrestService
      # The provider used in http requests. The default is 'Microsoft.Resources'
      attr_reader :provider

      # Creates and returns a new ResourceGroupService object.
      #
      def initialize(configuration, options = {})
        super(configuration, 'resourceGroups', 'Microsoft.Resources', options)
      end

      # Returns whether or not the given resource group exists.
      #
      def exists?(group)
        path = build_resource_group_path(group)
        rest_head(path) and true
      rescue Azure::Armrest::NotFoundException
        false
      end

      # List all the resources for the current subscription. You can optionally
      # pass :top or :filter options as well to restrict returned results. The
      # :filter option only applies to tags.
      #
      # Examples:
      #
      #   rgs = ResourceGroupService.new
      #   rgs.list(:top => 2)
      #   rgs.list(:filter => "sometag eq 'value'")
      #
      def list(options = {})
        path = build_resource_group_path
        query = build_query_hash(options)
        response = rest_get(path, query)
        Azure::Armrest::ArmrestCollection.create_from_response(response, Azure::Armrest::ResourceGroup)
      end

      # Creates a new +group+ in +location+ for the current subscription.
      # You may optionally apply +tags+.
      #
      def create(group, location, tags = nil)
        body = {:location => location, :tags => tags}.to_json
        path = build_resource_group_path(group)

        response = rest_put(path, nil, body)

        Azure::Armrest::ResourceGroup.new(response.body)
      end

      # Delete a resource group from the current subscription.
      #
      def delete(group)
        path = build_resource_group_path(group)
        response = rest_delete(path)
        Azure::Armrest::ResponseHeaders.new(response.headers)
      end

      # Returns information for the given resource group.
      #
      def get(group)
        path = build_resource_group_path(group)
        response = rest_get(path)
        Azure::Armrest::ResourceGroup.new(response.body)
      end

      # Updates the tags for the given resource group.
      #
      def update(group, tags)
        body = {:tags => tags}.to_json
        path = build_resource_group_path(group)
        response = rest_patch(path, nil, body)
        Azure::Armrest::ResponseHeaders.new(response.headers)
      end

      # Export a resource group as a template.
      #
      def export_template(group, resources = '*', options = 'IncludeParameterDefaultValue,IncludeComments')
        path = File.join(build_resource_group_path(group), 'exportTemplate')
        body = {:resources => resources, :options => options}.to_json

        response = rest_post(path, nil, body)
        Azure::Armrest::ResourceGroup.new(response.body)
      end

      private

      def build_resource_group_path(group = nil)
        url = File.join('', 'subscriptions', configuration.subscription_id, 'resourceGroups')
        url = File.join(url, group) if group
        url
      end 
    end # ResourceGroupService
  end # Armrest
end # Azure
