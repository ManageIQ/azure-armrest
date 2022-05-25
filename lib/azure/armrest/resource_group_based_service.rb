require 'active_support'
require 'active_support/core_ext/hash/conversions'

module Azure
  module Armrest
    # Base class for services that need to run in a resource group
    class ResourceGroupBasedService < ArmrestService
      # Used to map service name strings to internal classes
      SERVICE_NAME_MAP = {
        'availabilitysets'      => Azure::Armrest::AvailabilitySet,
        'loadbalancers'         => Azure::Armrest::Network::LoadBalancer,
        'networkinterfaces'     => Azure::Armrest::Network::NetworkInterface,
        'networksecuritygroups' => Azure::Armrest::Network::NetworkSecurityGroup,
        'publicipaddresses'     => Azure::Armrest::Network::IpAddress,
        'storageaccounts'       => Azure::Armrest::StorageAccount,
        'virtualnetworks'       => Azure::Armrest::Network::VirtualNetwork,
        'subnets'               => Azure::Armrest::Network::Subnet,
        'inboundnatrules'       => Azure::Armrest::Network::InboundNat,
        'securityrules'         => Azure::Armrest::Network::NetworkSecurityRule,
        'routes'                => Azure::Armrest::Network::Route,
        'databases'             => Azure::Armrest::Sql::SqlDatabase,
        'extensions'            => Azure::Armrest::VirtualMachineExtension,
        'disks'                 => Azure::Armrest::Storage::Disk,
        'snapshots'             => Azure::Armrest::Storage::Snapshot,
        'images'                => Azure::Armrest::Storage::Image,
        'deployments'           => Azure::Armrest::TemplateDeployment,
        'operations'            => Azure::Armrest::TemplateDeploymentOperation
      }.freeze

      # Create a resource +name+ within the resource group +rgroup+, or the
      # resource group that was specified in the configuration, along with
      # a hash of appropriate +options+.
      #
      # Returns an instance of the object that was created if possible,
      # otherwise nil is returned.
      #
      # Note that this is an asynchronous operation. You can check the current
      # status of the resource by inspecting the :response_headers instance and
      # polling either the :azure_asyncoperation or :location URL.
      #
      # The +options+ hash keys are automatically converted to camelCase for
      # flexibility, so :createOption and :create_option will both work
      # when creating a virtual machine, for example.
      #
      def create(name, rgroup = configuration.resource_group, options = {})
        validate_resource_group(rgroup)
        validate_resource(name)

        url = build_url(rgroup, name)
        url = yield(url) || url if block_given?

        body = transform_create_options(options).to_json

        response = rest_put(url, body)

        headers = Azure::Armrest::ResponseHeaders.new(response.headers)
        headers.response_code = response.code

        if response.body.empty?
          obj = get(name, rgroup)
        else
          obj = model_class.new(response.body)
        end

        obj.response_headers = headers
        obj.response_code = headers.response_code

        obj
      end

      alias update create

      # List all resources within the resource group +rgroup+, or the
      # resource group that was specified in the configuration.
      #
      # Returns an ArmrestCollection, with the response headers set
      # for the operation as a whole.
      #
      def list(rgroup = configuration.resource_group, skip_accessors_definition = false)
        validate_resource_group(rgroup)

        url = build_url(rgroup)
        url = yield(url) || url if block_given?
        response = rest_get(url)

        get_all_results(response, skip_accessors_definition)
      end

      # Use a single call to get all resources for the service. You may
      # optionally provide a filter on various properties to limit the
      # result set.
      #
      # Example:
      #
      #   vms = Azure::Armrest::VirtualMachineService.new(conf)
      #   vms.list_all(:location => "eastus", :resource_group => "rg1")
      #
      # Note that comparisons against string values are caseless.
      #
      def list_all(filter = {})
        url = build_url
        url = yield(url) || url if block_given?

        skip_accessors_definition = filter.delete(:skip_accessors_definition) || false
        response = rest_get(url)
        results  = get_all_results(response, skip_accessors_definition)

        if filter.empty?
          results
        else
          results.select do |obj|
            filter.all? do |method_name, value|
              if value.kind_of?(String)
                if skip_accessors_definition
                  obj[method_name.to_s].casecmp(value).zero?
                else
                  obj.public_send(method_name).casecmp(value).zero?
                end
              else
                obj.public_send(method_name) == value
              end
            end
          end
        end
      end

      # This method returns a model object based on an ID string for a resource.
      #
      # Example:
      #
      #   vms = Azure::Armrest::VirtualMachineService.new(conf)
      #
      #   vm = vms.get('your_vm', 'your_group')
      #   nic_id = vm.properties.network_profile.network_interfaces[0].id
      #   nic = vm.get_by_id(nic_id)
      #
      def get_by_id(id_string)
        info = parse_id_string(id_string)
        url = convert_id_string_to_url(id_string, info)

        service_name = info['subservice_name'] || info['service_name'] || 'resourceGroups'

        model_class = SERVICE_NAME_MAP.fetch(service_name.downcase) do
          raise ArgumentError, "unable to map service name #{service_name} to model"
        end

        model_class.new(rest_get(url))
      end

      alias get_associated_resource get_by_id

      def delete_by_id(id_string)
        url = convert_id_string_to_url(id_string)
        delete_by_url(url, id_string)
      end

      # Get information about a single resource +name+ within resource group
      # +rgroup+, or the resource group that was set in the configuration.
      #
      def get(name, rgroup = configuration.resource_group)
        validate_resource_group(rgroup)
        validate_resource(name)

        url = build_url(rgroup, name)
        url = yield(url) || url if block_given?
        response = rest_get(url)

        obj = model_class.new(response.body)
        obj.response_headers = Azure::Armrest::ResponseHeaders.new(response.headers)
        obj.response_code = response.code

        obj
      end

      # Delete the resource with the given +name+ for the provided +resource_group+,
      # or the resource group specified in your original configuration object. If
      # successful, returns a ResponseHeaders object.
      #
      # If the delete operation returns a 204 (no body), which is what the Azure
      # REST API typically returns if the resource is not found, it is treated
      # as an error and a ResourceNotFoundException is raised.
      #
      def delete(name, rgroup = configuration.resource_group)
        validate_resource_group(rgroup)
        validate_resource(name)

        url = build_url(rgroup, name)
        url = yield(url) || url if block_given?

        delete_by_url(url, "#{rgroup}/#{name}")
      end

      private

      # By default, camelize all hash options for the create method.
      # Subclasses should override this behavior as needed.
      #
      def transform_create_options(hash)
        hash.deep_transform_keys{ |k| k.to_s.camelize(:lower) }
      end

      def convert_id_string_to_url(id_string, info = nil)
        if id_string.include?('api-version')
          File.join(configuration.environment.resource_url, id_string)
        else
          info ||= parse_id_string(id_string)
          api_version = api_version_lookup(info['provider'], info['service_name'], info['subservice_name'])
          File.join(configuration.environment.resource_url, id_string) + "?api-version=#{api_version}"
        end
      end

      # Parse the provider and service name out of an ID string.
      def parse_id_string(id_string)
        regex = %r{
          subscriptions/(?<subscription_id>[^\/]+)?
          (/resourceGroups/(?<resource_group>[^\/]+)?)?
          (/providers/(?<provider>[^\/]+)?)?
          (/(?<service_name>[^\/]+)?/(?<resource_name>[^\/]+))?
          (/(?<subservice_name>[^\/]+)?/(?<subservice_resource_name>[^\/]+))?
          \z
        }xi

        match = regex.match(id_string)
        raise ArgumentError, "Invalid ID string: #{id_string}" unless match
        Hash[match.names.zip(match.captures)]
      end

      def api_version_lookup(provider_name, service_name, subservice_name)
        provider_name ||= 'Microsoft.Resources'
        service_name  ||= 'resourceGroups'
        if subservice_name
          full_service_name = "#{service_name}/#{subservice_name}"
          api_version = configuration.provider_default_api_version(provider_name, full_service_name)
        end
        api_version ||= configuration.provider_default_api_version(provider_name, service_name)
        api_version || configuration.api_version
      end

      def delete_by_url(url, resource_name = '')
        response = rest_delete(url)

        if response.code == 204
          msg = "resource #{resource_name} not found"
          raise Azure::Armrest::ResourceNotFoundException.new(response.code, msg, response)
        end

        Azure::Armrest::ResponseHeaders.new(response.headers).tap do |headers|
          headers.response_code = response.code
        end
      end

      def validate_resource_group(name)
        raise ArgumentError, "must specify resource group" unless name
      end

      def validate_resource(name)
        raise ArgumentError, "must specify #{@service_name.singularize.underscore.humanize}" unless name
      end

      # Builds a URL based on subscription_id an resource_group and any other
      # arguments provided, and appends it with the api_version.
      #
      def build_url(resource_group = nil, *args)
        File.join(configuration.environment.resource_url, build_id_string(resource_group, *args))
      end

      def build_id_string(resource_group = nil, *args)
        id_string = File.join('', 'subscriptions', configuration.subscription_id)
        id_string = File.join(id_string, 'resourceGroups', resource_group) if resource_group
        id_string = File.join(id_string, 'providers', @provider, @service_name)

        query = "?api-version=#{@api_version}"

        args.each do |arg|
          if arg.kind_of?(Hash)
            arg.each do |key, value|
              key = key.to_s.camelize(:lower)

              if key.casecmp('top').zero?
                query << "&$top=#{value}"
              elsif key.casecmp('filter').zero?
                query << "&$filter=#{value}" # Allow raw filter
              elsif key.casecmp('expand').zero?
                query << "&$expand=#{value}"
              else
                if query.include?("$filter")
                  query << " and #{key} eq '#{value}'"
                else
                  query << "&$filter=#{key} eq '#{value}'"
                end
              end
            end
          else
            id_string = File.join(id_string, arg)
          end
        end

        id_string + query
      end

      # Aggregate resources from all resource groups.
      #
      # To be used in the cases where the API does not support list_all with
      # one call. Note that this does not set the skip token because we're
      # actually collating the results of multiple calls internally.
      #
      def list_in_all_groups(options = {})
        array   = []
        mutex   = Mutex.new
        headers = nil
        code    = nil

        Parallel.each(list_resource_groups, :in_threads => configuration.max_threads) do |rg|
          url = build_url(rg.name, options)
          response = rest_get(url)
          json_response = JSON.parse(response.body)['value']
          headers = Azure::Armrest::ResponseHeaders.new(response.headers)
          code = response.code
          results = json_response.map { |hash| model_class.new(hash) }
          mutex.synchronize { array << results } unless results.blank?
        end

        array = ArmrestCollection.new(array.flatten)

        # Use the last set of headers and response code for the overall result.
        array.response_headers = headers
        array.response_code = code

        array
      end
    end
  end
end
