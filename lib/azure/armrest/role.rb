module Azure
  module Armrest
    # Abstract base class for use by role related service classes.
    class RoleService < ArmrestService
      # Most methods accept any one the following options, and their possible
      # values, that defines the scope for that operation:
      #
      # :subscription   => Set to true for subscription level scope
      # :resource_group => Name of resource group
      # :resource       => A resource.id string
      #
      # The options you define determine the scope of the request:
      #
      # :subscription   => /subscriptions/{subscription-id}
      # :resource_group => /subscriptions/{subscription-id}/resourceGroups/some_group
      # :resource       => /subscriptions/{subscription-id}/resourceGroups/some_group/providers/Microsoft.Web/sites/mysite1
      #
      # Lastly, you can supply a :filter in order to filter results.
      #
      # Various list methods have been provided for convenience as well, such
      # as the list_all method, which lists all roles at the subscription level.

      # Gets information for the role assignment by name, where the "name"
      # is really just the last portion (GUID) of an ID string.
      #
      def get_by_name(role_name, options = {})
        url = build_url(options.merge(:subscription => true), role_name)
        response = rest_get(url)
        model_class.new(response.body)
      end

      alias get get_by_name

      # Gets information for the role assignment via a resource string ID.
      #
      def get_by_id(role_id, options = {})
        url = build_url(options.merge(:resource => role_id))
        response = rest_get(url)
        model_class.new(response.body)
      end

      alias get_by_resource get_by_id

      # List all role assignments for the current subscription.
      #
      def list_all(options = {})
        url = build_url(options.merge(:subscription => true))
        response = rest_get(url)
        Azure::Armrest::ArmrestCollection.create_from_response(response, model_class)
      end

      alias list_for_subscription list_all

      # List all role assignments for the given +resource_group+.
      #
      def list(resource_group, options = {})
        url = build_url(options.merge(:resource_group => resource_group))
        response = rest_get(url)
        Azure::Armrest::ArmrestCollection.create_from_response(response, model_class)
      end

      alias list_for_resource_group list

      # List all role assignments for the given +resource+.
      #
      # Example:
      #
      #   vms = Azure::Armrest::VirtualMachineService.new(conf)
      #   ads = Azure::Armrest::Role::AssignmentService.new(conf)
      #
      #   vm = vms.get('some_vm', 'some_group')
      #   ads.list_for_resource(vm.id)
      #
      def list_for_resource(resource, options = {})
        url = build_url(options.merge(:resource => resource))
        response = rest_get(url)
        Azure::Armrest::ArmrestCollection.create_from_response(response, model_class)
      end

      private

      def build_url(options = {}, property = nil)
        resource = options.delete(:resource)
        resource_group = options.delete(:resource_group)
        subscription = options.delete(:subscription)

        if subscription
          url = File.join(base_url, 'providers', provider, service_name)
        elsif resource_group
          url = File.join(base_url, 'resourceGroups', resource_group, 'providers', provider, service_name)
        else # resource
          url = File.join(configuration.environment.resource_url, resource, 'providers', provider, service_name)
        end

        url = File.join(url, property) if property 
        url = "#{url}?api-version=#{api_version}"

        options.each { |key, value| url << "&$#{key}=#{value}" }

        url
      end
    end #RoleService 
  end
end
