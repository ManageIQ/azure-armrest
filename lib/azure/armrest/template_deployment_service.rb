module Azure
  module Armrest
    # Base class for managing templates and deployments
    class TemplateDeploymentService < ResourceGroupBasedService

      def initialize(configuration, options = {})
        super(configuration, 'deployments', 'Microsoft.Resources', options)
      end

      # Get names of all deployments in a resource group
      def list_names(resource_group = configuration.resource_group)
        list(resource_group).map(&:name)
      end

      # Get all deployments for the current subscription
      def list_all
        list_in_all_groups
      end

      # Get all operations of a deployment in a resource group
      def list_deployment_operations(deploy_name, resource_group = configuration.resource_group)
        validate_resource_group(resource_group)
        validate_resource(deploy_name)

        url = build_url(resource_group, deploy_name, 'operations')
        response = rest_get(url)
        JSON.parse(response)['value'].map { |hash| TemplateDeploymentOperation.new(hash) }
      end

      # Get the operation of a deployment in a resource group
      def get_deployment_operation(op_id, deploy_name, resource_group = configuration.resource_group)
        validate_resource_group(resource_group)
        validate_resource(deploy_name)
        raise ArgumentError, "must specify operation id" unless op_id

        url = build_url(resource_group, deploy_name, 'operations', op_id)
        response = rest_get(url)
        TemplateDeploymentOperation.new(response)
      end
    end
  end
end
