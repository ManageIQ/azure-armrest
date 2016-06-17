require 'time'
require_relative 'model/base_model'

module Azure
  module Armrest
    # Abstract base class for the other service classes.
    class ArmrestService
      extend Gem::Deprecate

      # Configuration to access azure APIs
      attr_accessor :armrest_configuration

      alias configuration armrest_configuration

      # Base url used for REST calls.
      attr_accessor :base_url

      # Provider for service specific API calls
      attr_accessor :provider

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

        # Base URL used for REST calls. Modify within method calls as needed.
        @base_url = Azure::Armrest::RESOURCE

        set_service_api_version(options, service_name)
      end

      # Returns a list of the available resource providers. This is really
      # just a wrapper for Azure::Armrest::Configuration#providers.
      #
      delegate :providers, :to => :configuration, :prefix => :list

      alias providers list_providers
      deprecate :providers, :list_providers, 2018, 1

      # Need an "as_cache_key" method for the cache_method library interface.
      delegate :hash, :to => :configuration
      alias as_cache_key hash

      # Returns information about the specific provider +namespace+.
      #
      def get_provider(provider)
        configuration.providers.find { |rp| rp.namespace.casecmp(provider) == 0 }
      end

      alias geo_locations get_provider
      alias provider_info get_provider
      deprecate :provider_info, :get_provider, 2018, 1

      # Returns a list of all locations for all resource types of the given
      # +provider+. If you do not specify a provider, then the locations for
      # all providers will be returned.
      #
      # If you need individual details on a per-provider basis, use the
      # provider_info method instead.
      #--
      #
      def locations(provider = nil)
        list = configuration.providers
        list = list.select { |rp| rp.namespace.casecmp(provider) == 0 } if provider

        list.collect { |rp| rp.resource_types.map(&:locations) }.flatten.uniq.sort
      end

      # Returns a list of Subscription objects for the tenant.
      #
      def list_subscriptions
        url = url_with_api_version(configuration.api_version, @base_url, 'subscriptions')
        response = rest_get(url)
        JSON.parse(response.body)['value'].map { |hash| Azure::Armrest::Subscription.new(hash) }
      end

      alias subscriptions list_subscriptions
      deprecate :subscriptions, :list_subscriptions, 2018, 1

      # Return information for the specified subscription ID, or the
      # subscription ID that was provided in the constructor if none is
      # specified.
      #
      def get_subscription(subscription_id = configuration.subscription_id)
        url = url_with_api_version(
          configuration.api_version,
          @base_url,
          'subscriptions',
          subscription_id
        )

        response = rest_get(url)
        Azure::Armrest::Subscription.new(response.body)
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
      def tags
        url = url_with_api_version(
          configuration.api_version,
          @base_url,
          'subscriptions',
          configuration.subscription_id,
          'tagNames'
        )
        resp = rest_get(url)
        JSON.parse(resp.body)["value"].map{ |hash| Azure::Armrest::Tag.new(hash) }
      end

      # Returns a list of tenants that can be accessed.
      #
      def tenants
        url = url_with_api_version(configuration.api_version, @base_url, 'tenants')
        resp = rest_get(url)
        JSON.parse(resp.body)['value'].map{ |hash| Azure::Armrest::Tenant.new(hash) }
      end

      class << self
        private

        def rest_execute(options, http_method = :get)
          options = options.merge(
            :method => http_method,
            :url    => Addressable::URI.escape(options[:url])
          )
          RestClient::Request.execute(options)
        rescue RestClient::Exception => e
          raise_api_exception(e)
        end

        def rest_get(options)
          rest_execute(options, :get)
        end

        def rest_post(options)
          rest_execute(options, :post)
        end

        def rest_patch(options)
          rest_execute(options, :patch)
        end

        def rest_delete(options)
          rest_execute(options, :delete)
        end

        def rest_put(options)
          rest_execute(options, :put)
        end

        def rest_head(options)
          rest_execute(options, :head)
        end

        def raise_api_exception(e)
          begin
            response = JSON.parse(e.http_body)
            code = response['error']['code']
            message = response['error']['message']
          rescue
            message = e.http_body
          end
          message = e.http_body unless message

          exception_type = case e
                           when RestClient::NotFound
                             ResourceNotFoundException
                           when RestClient::BadRequest
                             BadRequestException
                           when RestClient::GatewayTimeout
                             GatewayTimeoutException
                           when RestClient::BadGateway
                             BadGatewayException
                           when RestClient::Unauthorized, RestClient::Forbidden
                             UnauthorizedException
                           when RestClient::TooManyRequests
                             TooManyRequestsException
                           else
                             ApiException
                           end

          raise exception_type.new(code, message, e)
        end
      end

      private

      # REST verb methods

      def rest_execute(url, body = nil, http_method = :get)
        options = {
          :url         => url,
          :proxy       => configuration.proxy,
          :ssl_version => configuration.ssl_version,
          :ssl_verify  => configuration.ssl_verify,
          :headers => {
            :accept        => configuration.accept,
            :content_type  => configuration.content_type,
            :authorization => configuration.token
          }
        }

        options[:payload] = body if body

        self.class.send(:rest_execute, options, http_method)
      end

      def rest_get(url)
        rest_execute(url)
      end

      def rest_put(url, body = '')
        rest_execute(url, body, :put)
      end

      def rest_post(url, body = '')
        rest_execute(url, body, :post)
      end

      def rest_patch(url, body = '')
        rest_execute(url, body, :patch)
      end

      def rest_delete(url)
        rest_execute(url, nil, :delete)
      end

      def rest_head(url)
        rest_execute(url, nil, :head)
      end

      # Take an array of URI elements and join the together with the API version.
      def url_with_api_version(api_version, *paths)
        File.join(*paths) << "?api-version=#{api_version}"
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
    end # ArmrestService
  end # Armrest
end # Azure
