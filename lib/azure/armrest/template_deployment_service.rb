module Azure::Armrest
  # Base class for managing templates and deployments
  class TemplateDeploymentService < ArmrestService

    def initialize(_armrest_configuration, options = {})
      super
      @provider = options[:provider] || 'Microsoft.Resources'
      #set_service_api_version(options, 'deploymenttemplates')
      # Has to be hard coded for now
      set_service_api_version({'api_version' => '2014-04-01-preview'}, '')
    end

    # Get names of all deployments in a resource group
    def list_names(resource_group = armrest_configuration.resource_group)
      list(resource_group).map(&:name)
    end

    # Get all deployments for the current subscription in a resource group
    def list(resource_group = armrest_configuration.resource_group)
      raise ArgumentError, "must specify resource group" unless resource_group
      url = build_deployment_url(resource_group)
      response = rest_get(url)
      JSON.parse(response)['value'].map{ |hash| Azure::Armrest::TemplateDeployment.new(hash) }
    end

    # Get all deployments for the current subscription
    def list_all
      array = []
      threads = []
      mutex = Mutex.new

      resource_groups.each do |rg|
        threads << Thread.new(rg['name']) do |group|
          url = build_deployment_url(group)
          response = rest_get(url)

          results = JSON.parse(response)['value'].map do |hash|
            hash['resourceGroup'] = group
            Azure::Armrest::TemplateDeployment.new(hash)
          end

          if results && !results.empty?
            mutex.synchronize{ array << results }
          end
        end
      end

      threads.each(&:join)

      array.flatten
    end

    # Get the deployment in a resource group
    def get(deploy_name, resource_group = armrest_configuration.resource_group)
      raise ArgumentError, "must specify resource group" unless resource_group
      url = build_deployment_url(resource_group, deploy_name)
      response = rest_get(url)
      Azure::Armrest::TemplateDeployment.new(response)
    end

    # Get all operations of a deployment in a resource group
    def list_deployment_operations(deploy_name, resource_group = armrest_configuration.resource_group)
      raise ArgumentError, "must specify resource group" unless resource_group
      url = build_deployment_url(resource_group, deploy_name, 'operations')
      response = rest_get(url)
      JSON.parse(response)['value'].map{ |hash| TemplateDeploymentOperation.new(hash) }
    end

    # Get the operation of a deployment in a resource group
    def get_deployment_operation(deploy_name, op_id, resource_group = armrest_configuration.resource_group)
      url = build_deployment_url(resource_group, deploy_name, 'operations', op_id)
      response = rest_get(url)
      TemplateDeploymentOperation.new(response)
    end

    # Create a template deployment
    # The template and parameters should be provided through the options hash
    def create(deploy_name, options, resource_group = armrest_configuration.resource_group)
      url = build_deployment_url(resource_group, deploy_name)
      body = options.has_key?('properties') ? options.to_json : {'properties' => options}.to_json
      JSON.parse(rest_put(url, body))
    end

    # Delete a deployment
    def delete(deploy_name, resource_group = armrest_configuration.resource_group)
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
        armrest_configuration.subscription_id,
        'resourceGroups',
        resource_group,
        'deployments',
      )

      url = File.join(url, *args) unless args.empty?
      url << "?api-version=#{@api_version}"
    end
  end
end
