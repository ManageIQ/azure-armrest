module Azure::Armrest
# Base class for managing templates and deployments
class TemplateDeploymentService < ArmrestService

  def initialize(options = {})
    super
    @api_version = '2014-04-01-preview' # has to be hard coded for now
  end

  # Get names of all deployments in a resource group
  def list(resource_group = @resource_group)
    list_with_details(resource_group).map {|e| e['name']}
  end

  # Get all deployments in a resource group
  def list_with_details(resource_group = @resource_group)
    url = build_deployment_url(resource_group)
    JSON.parse(rest_get(url))['value']
  end

  # Get the deployment in a resource group
  def get(deploy_name, resource_group = @resource_group)
    url = build_deployment_url(resource_group, deploy_name)
    JSON.parse(rest_get(url))
  end

  # Get all operations of a deployment in a resource group
  def list_deployment_operations(deploy_name, resource_group = @resource_group)
    url = build_deployment_url(resource_group, deploy_name, 'operations')
    JSON.parse(rest_get(url))['value']
  end

  # Get the operation of a deployment in a resource group
  def get_deployment_operation(deploy_name, op_id, resource_group = @resource_group)
    url = build_deployment_url(resource_group, deploy_name, 'operations', op_id)
    JSON.parse(rest_get(url))
  end

  # Create a template deployment
  # The template and parameters should be provided through the options hash
  def create(deploy_name, options, resource_group = @resource_group)
    url = build_deployment_url(resource_group, deploy_name)
    body = options.has_key?('properties') ? options.to_json : {'properties' => options}.to_json
    JSON.parse(rest_put(url, body))
  end

  # Delete a deployment
  def delete(deploy_name, resource_group = @resource_group)
    url = build_deployment_url(resource_group, deploy_name)
    rest_delete(url)
  end

  private


  # Builds a URL based on subscription_id an resource_group and any other
  # arguments provided, and appends it with the api_version.
  #
  def build_deployment_url(resource_group, *args)
    url = File.join(
      Azure::Armrest::COMMON_URI,
      subscription_id,
      'resourceGroups',
      resource_group,
      'deployments',
    )

    url = File.join(url, *args) unless args.empty?
    url << "?api-version=#{api_version}"
  end
end
end
