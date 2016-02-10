module Azure
  module Armrest
    # Base class for services that have two levels in the path and need to run in a resource group
    class ResourceGroupBasedSubservice < ResourceGroupBasedService
      # Do not instantiate directly. This is an abstract base class from which
      # all other service classes should subclass, and call super within their
      # own constructors.
      #
      def initialize(armrest_configuration, service_name, subservice_name, default_provider, options)
        @subservice_name = subservice_name
        super(armrest_configuration, service_name, default_provider, options)
      end

      def create(resource, subresource, rgroup = armrest_configuration.resource_group, options = {})
        validate_resource_group(rgroup)
        validate_resource(resource)
        validate_subresource(subresource)
        super(combine(resource, subresource), rgroup, options)
      end

      alias update create

      def list(resource, rgroup = armrest_configuration.resource_group)
        validate_resource_group(rgroup)
        validate_resource(resource)

        url = build_url(rgroup, resource, @subservice_name)
        url = yield(url) || url if block_given?
        response = rest_get(url)
        JSON.parse(response)['value'].map{ |hash| model_class.new(hash) }
      end

      alias list_all list

      def get(resource, subresource, rgroup = armrest_configuration.resource_group)
        validate_resource_group(rgroup)
        validate_resource(resource)
        validate_subresource(subresource)
        super(combine(resource, subresource), rgroup)
      end

      def delete(resource, subresource, rgroup = armrest_configuration.resource_group)
        validate_resource_group(rgroup)
        validate_resource(resource)
        validate_subresource(subresource)
        super(combine(resource, subresource), rgroup)
      end

      private

      def validate_subresource(name)
        raise ArgumentError, "must specify #{@subservice_name.singularize.underscore.humanize}" unless name
      end

      def combine(resource, subresource)
        File.join(resource, @subservice_name, subresource)
      end
    end
  end
end
