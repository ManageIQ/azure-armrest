module Azure
  module Armrest
    # Base class for services that need to run in a resource group
    class ResourceGroupBasedService < ArmrestService
      def create(name, rgroup = configuration.resource_group, options = {})
        validate_resource_group(rgroup)
        validate_resource(name)

        url = build_url(rgroup, name)
        url = yield(url) || url if block_given?
        response = rest_put(url, options.to_json)
        model_class.new(response) unless response.empty?
      end

      alias update create

      def list(rgroup = configuration.resource_group)
        validate_resource_group(rgroup)

        url = build_url(rgroup)
        url = yield(url) || url if block_given?
        response = rest_get(url)
        JSON.parse(response)['value'].map { |hash| model_class.new(hash) }
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
      def list_all(filter = {})
        url = build_url
        url = yield(url) || url if block_given?
        response = rest_get(url)
        results = JSON.parse(response)['value'].map { |hash| model_class.new(hash) }
        filter.empty? ? results : results.select { |obj| filter.all? { |k, v| obj.public_send(k) == v } }
      end

      def get(name, rgroup = configuration.resource_group)
        validate_resource_group(rgroup)
        validate_resource(name)

        url = build_url(rgroup, name)
        url = yield(url) || url if block_given?
        response = rest_get(url)
        model_class.new(response)
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
        response = rest_delete(url)

        if response.code == 204
          msg = "#{self.class} resource #{rgroup}/#{name} not found"
          raise Azure::Armrest::ResourceNotFoundException.new(response.code, msg, response)
        end

        Azure::Armrest::ResponseHeaders.new(response.headers)
      end

      private

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
        url = File.join(Azure::Armrest::COMMON_URI, configuration.subscription_id)
        url = File.join(url, 'resourceGroups', resource_group) if resource_group
        url = File.join(url, 'providers', @provider, @service_name)
        url = File.join(url, *args) unless args.empty?
        url << "?api-version=#{@api_version}"
      end

      def model_class
        @model_class ||= Object.const_get(self.class.to_s.sub(/Service$/, ''))
      end

      # Aggregate resources from all resource groups.
      #
      # To be used in the cases where the API does not support list_all with one call.
      #
      def list_in_all_groups
        array = []
        mutex = Mutex.new

        Parallel.each(list_resource_groups, :in_threads => configuration.max_threads) do |rg|
          response = rest_get(build_url(rg.name))
          results = JSON.parse(response)['value'].map { |hash| model_class.new(hash) }
          mutex.synchronize { array << results } unless results.blank?
        end

        array.flatten
      end
    end
  end
end
