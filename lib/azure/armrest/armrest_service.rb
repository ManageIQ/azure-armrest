require 'time'
require 'active_support/core_ext/hash/conversions'
require_relative 'model/base_model'

module Azure
  module Armrest
    # Abstract base class for the other service classes.
    class ArmrestService
      extend Gem::Deprecate
      include Azure::Armrest::RequestHelper

      # Configuration to access azure APIs
      attr_accessor :armrest_configuration

      alias configuration armrest_configuration

      # Base path with subscription information used for most REST calls.
      attr_accessor :base_path

      # Provider for service specific API calls
      attr_accessor :provider

      # The service name for the Service class
      attr_accessor :service_name

      # The api-version string for this particular service
      attr_accessor :api_version

      # Returns a new Armrest::Configuration object.
      #
      # This method is deprecated, but is provided for backwards compatibility.
      #
      def self.configure(options)
        Azure::Armrest::Configuration.new(options)
      end

      # Do not instantiate directly. This is an abstract base class from which
      # all other service classes should subclass, and call super within their
      # own constructors.
      #
      def initialize(armrest_configuration, service_name, default_provider, options)
        @armrest_configuration = armrest_configuration
        @service_name = service_name
        @provider = options[:provider] || default_provider

        if configuration.subscription_id.nil?
          raise ArgumentError, 'subscription_id must be specified for this Service class'
        end

        # Base path used for REST calls. Modify within method calls as needed.
        @base_path = File.join('', 'subscriptions', configuration.subscription_id)

        set_service_api_version(options, service_name)
      end

      # Returns a list of the available resource providers. This is really
      # just a wrapper for Azure::Armrest::Configuration#providers.
      #
      delegate :providers, :to => :configuration, :prefix => :list

      # Returns information about the specific provider +namespace+.
      #
      def get_provider(provider)
        configuration.providers.find { |rp| rp.namespace.casecmp(provider) == 0 }
      end

      alias geo_locations get_provider

      # Returns a list of Location objects for the current subscription.
      #
      def list_locations
        url = File.join(base_path, 'locations')
        response = rest_get(url)
        Azure::Armrest::ArmrestCollection.create_from_response(response, Location)
      end

      # Returns a list of subscriptions for the current tenant.
      def list_subscriptions
        Azure::Armrest::SubscriptionService.new(configuration).list
      end

      alias subscriptions list_subscriptions
      deprecate :subscriptions, :list_subscriptions, 2018, 1

      # Return information for the specified subscription ID, or the
      # subscription ID that was provided in the constructor if none is
      # specified.
      #
      def get_subscription(subscription_id = configuration.subscription_id)
        subs = Azure::Armrest::SubscriptionService.new(configuration)
        subs.get(subscription_id)
      end

      alias subscription_info get_subscription
      deprecate :subscription_info, :get_subscription, 2018, 1

      # Returns an array of Resource objects for the current subscription. If a
      # +resource_group+ is provided, only list resources for that
      # resource group.
      #
      def list_resources(resource_group = nil)
        if resource_group
          Azure::Armrest::ResourceService.new(configuration).list(resource_group)
        else
          Azure::Armrest::ResourceService.new(configuration).list_all
        end
      end

      alias resources list_resources
      deprecate :resources, :list_resources, 2018, 1

      # Returns an array of ResourceGroup objects for the current subscription.
      #
      def list_resource_groups
        Azure::Armrest::ResourceGroupService.new(configuration).list
      end

      alias resource_groups list_resource_groups
      deprecate :resource_groups, :list_resource_groups, 2018, 1

      # Returns a list of tags for the current subscription.
      #
      def list_tags
        url = File.join(base_path, 'tagNames')
        response = rest_get(url)
        Azure::Armrest::ArmrestCollection.create_from_response(response, Tag)
      end

      # Returns a list of tenants that can be accessed.
      #
      def list_tenants
        response = rest_get('tenants')
        Azure::Armrest::ArmrestCollection.create_from_response(response, Tenant)
      end

      # Poll a resource and return its current operations status. The
      # +response+ argument should be a ResponseHeaders object that
      # contains the :azure_asyncoperation header. It may optionally
      # be an object that returns a URL from a .to_s method.
      #
      # This is meant to check the status of asynchronous operations,
      # such as create or delete.
      #
      def poll(response)
        return 'Succeeded' if [200, 201].include?(response.response_code)
        url = response.try(:azure_asyncoperation) || response.try(:location)
        response = rest_get(url).body
        unless response.blank?
          status = JSON.parse(response)['status']
        end
        status || 'Succeeded' # assume succeeded otherwise the wait method may hang
      end

      # Wait for the given +response+ to return a status of 'Succeeded', up
      # to a maximum of +max_time+ seconds, and return the operations status.
      # The first argument must be a ResponseHeaders object that contains
      # the azure_asyncoperation header.
      #
      # Internally this will poll the response header every :retry_after
      # seconds (or 10 seconds if that header isn't found), up to a maximum of
      # 60 seconds by default. There is no timeout limit if +max_time+ is 0.
      #
      # For most resources the +max_time+ argument should be more than sufficient.
      # Certain resources, such as virtual machines, could take longer.
      #
      def wait(response, max_time = 60, default_interval = 10)
        sleep_time = response.respond_to?(:retry_after) ? response.retry_after.to_i : default_interval
        total_time = 0

        until (status = poll(response)) =~ /^succe/i # success or succeeded
          total_time += sleep_time
          break if max_time > 0 && total_time >= max_time
          sleep sleep_time
        end

        status
      end

      # Each Azure API call may require different api_version.
      # The api_version in armrest_configuration is used for common methods provided
      # by ArmrestService
      #
      # The options hash for each service's constructor can contain key-value pair
      #   api_version => version
      # This version will be used for the service specific API calls
      #
      # Otherwise the service specific api_version is looked up from configuration.providers
      #
      # Finally api_version in armrest_configuration is used if service specific version
      # cannot be determined
      def set_service_api_version(options, service)
        @api_version =
          options['api_version'] ||
          configuration.provider_default_api_version(provider, service) ||
          configuration.api_version
      end

      # Parse the skip token value out of the nextLink attribute from a response.
      def parse_skip_token(json)
        return nil unless json['nextLink']
        json['nextLink'][/.*?skipToken=(.*?)$/i, 1]
      end

      # Make additional calls and concatenate the results if a continuation URL is found.
      def get_all_results(response, skip_accessors_definition = false)
        results  = Azure::Armrest::ArmrestCollection.create_from_response(response, model_class, skip_accessors_definition)
        nextlink = results.next_link

        while nextlink
          uri = Addressable::URI.parse(nextlink)
          response = rest_get(uri.path, uri.query)
          more = Azure::Armrest::ArmrestCollection.create_from_response(response, model_class, skip_accessors_definition)
          results.concat(more)
          nextlink = more.next_link
        end

        results
      end

      def model_class
        @model_class ||= Object.const_get(self.class.to_s.sub(/Service$/, ''))
      end

      def log(level = 'info', msg)
        Excon::LoggingInstrumentor.logger.try(level, msg)
      end
    end # ArmrestService
  end # Armrest
end # Azure
