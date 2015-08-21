module Azure
  module Armrest
    # Abstract base class for the other service classes.
    class ArmrestService
      ArmrestConfiguration = Struct.new(
        :client_id,
        :client_key,
        :tenant_id,
        :subscription_id,
        :resource_group,
        :api_version,
        :grant_type,
        :content_type,
        :accept,
        :token
      )

      # Configuration to access azure APIs
      attr_accessor :armrest_configuration

      # Base url used for REST calls.
      attr_accessor :base_url

      @@providers = {} # Set in constructor

      @@tokens = {} # token caches

      @@subscriptions = {} # subscription caches

      # Create a configuration object based on input options.
      # This object can be used to create service objects.
      #
      # Possible options are:
      #
      #   - client_id
      #   - client_key
      #   - tenant_id
      #   - subscription_id
      #   - resource_group
      #   - api_version
      #   - grant_type
      #   - content_type
      #   - accept
      #   - token
      #
      # Of these, you should include a client_id, client_key and tenant_id.
      # The resource_group can be specified here, but many methods allow you
      # to specify a resource group if you prefer flexibility.
      #
      # If no subscription_id is provided then this method will attempt to find
      # a list of associated subscriptions and use the first one it finds as
      # the default. If no associated subscriptions are found, an ArgumentError
      # is raised.
      #
      # The other options (grant_type, content_type, accept, token, and
      # api_version) should generally NOT be set by you except in specific
      # circumstances.  Setting them explicitly will likely cause breakage.
      # The api_version will typically be overridden on a per-provider/resource
      # basis within subclasses anyway.
      #
      # You may need to associate your application with a subscription using
      # the new portal or the New-AzureRoleAssignment powershell command.
      #
      def self.configure(options)
        configuration = ArmrestConfiguration.new
        options.each do |k,v|
          configuration[k] = v
        end

        configuration.api_version     ||= '2015-01-01'
        configuration.grant_type      ||= 'client_credentials'
        configuration.content_type    ||= 'application/json'
        configuration.accept          ||= 'application/json'
        configuration.token           ||= fetch_token(configuration)
        configuration.subscription_id ||= fetch_subscription_id(configuration)

        configuration
      end

      def self.fetch_token(config)
        key = "#{config.grant_type}_#{config.tenant_id}_#{config.client_id}_#{config.client_key}"
        return @@tokens[key] if @@tokens.has_key?(key)

        token_url = Azure::Armrest::AUTHORITY + config.tenant_id + "/oauth2/token"

        response = RestClient.post(
          token_url,
          :grant_type    => config.grant_type,
          :client_id     => config.client_id,
          :client_secret => config.client_key,
          :resource      => Azure::Armrest::RESOURCE
        )
        token = 'Bearer ' + JSON.parse(response)['access_token']
        @@tokens[key] = token

        token
      end
      private_class_method :fetch_token

      def self.fetch_subscription_id(config)
        key = "#{config.token}"
        return @@subscriptions[key] if @@subscriptions.has_key?(key)

        url = File.join(Azure::Armrest::RESOURCE, "subscriptions?api-version=#{config.api_version}")

        response = RestClient.get(
          url,
          :content_type  => @@content_type,
          :authorization => @@token,
        )

        hash = JSON.parse(response.body)["value"].first

        raise ArgumentError, "No associated subscription found" if hash.empty?

        id = hash.fetch("subscriptionId")
        @@subscriptions[key] = id

        id
      end
      private_class_method :fetch_subscription_id

      # Do not instantiate directly. This is an abstract base class from which
      # all other service classes should subclass, and call super within their
      # own constructors.
      #
      def initialize(armrest_configuration, _options)
        self.armrest_configuration = armrest_configuration

        # Base URL used for REST calls. Modify within method calls as needed.
        @base_url = Azure::Armrest::RESOURCE

        set_providers_info
      end

      # Returns a list of the available resource providers.
      #
      def providers
        url = url_with_api_version(armrest_configuration.api_version, @base_url, 'providers')
        resp = rest_get(url)
        JSON.parse(resp.body)["value"]
      end

      # Returns information about the specific provider +namespace+.
      #
      def provider_info(provider)
        url = url_with_api_version(armrest_configuration.api_version, @base_url, 'providers', provider)
        response = rest_get(url)
        JSON.parse(response.body)
      end

      alias geo_locations provider_info

      # Returns a list of all locations for all resource types of the given
      # +provider+. If you do not specify a provider, then the locations for
      # all providers will be returned.
      #
      # If you need individual details on a per-provider basis, use the
      # provider_info method instead.
      #--
      #
      def locations(provider = nil)
        array = []

        if provider
          @@providers[provider].each do |key, data|
            array << data['locations']
          end
        else
          @@providers.each do |provider, resource_types|
            @@providers[provider].each do |resource_type, data|
              array << data['locations']
            end
          end
        end

        array.flatten.uniq
      end

      # Returns a list of subscriptions for the tenant.
      #
      def subscriptions
        url = url_with_api_version(armrest_configuration.api_version, @base_url, 'subscriptions')
        resp = rest_get(url)
        JSON.parse(resp.body)["value"]
      end

      # Return information for the specified subscription ID, or the
      # subscription ID that was provided in the constructor if none is
      # specified.
      #
      def subscription_info(subscription_id = armrest_configuration.subscription_id)
        url = url_with_api_version(
          armrest_configuration.api_version,
          @base_url,
          'subscriptions',
          armrest_configuration.subscription_id
        )

        resp = rest_get(url)
        JSON.parse(resp.body)
      end

      # Returns a list of resources for the current subscription. If a
      # +resource_group+ is provided, only list resources for that
      # resource group.
      #
      def resources(resource_group = nil)
        if resource_group
          url = url_with_api_version(
            armrest_configuration.api_version,
            @base_url,
            'subscriptions',
            armrest_configuration.subscription_id,
            'resourcegroups',
            resource_group,
            'resources'
          )
        else
          url = url_with_api_version(
            armrest_configuration.api_version,
            @base_url,
            'subscriptions',
            armrest_configuration.subscription_id,
            'resources'
          )
        end

        response = rest_get(url)

        JSON.parse(response.body)["value"]
      end

      # Returns a list of resource groups for the current subscription.
      #
      def resource_groups
        url = url_with_api_version(
          armrest_configuration.api_version,
          @base_url,
          'subscriptions',
          armrest_configuration.subscription_id,
          'resourcegroups'
        )
        response = rest_get(url)
        JSON.parse(response.body)["value"]
      end

      # Returns information on the specified +resource_group+ for the current
      # subscription, or the resource group specified in the constructor if
      # none is provided.
      #
      def resource_group_info(resource_group)
        url = url_with_api_version(
          armrest_configuration.api_version,
          @base_url,
          'subscriptions',
          armrest_configuration.subscription_id,
          'resourcegroups',
          resource_group
        )

        resp = rest_get(url)
        JSON.parse(resp.body)
      end

      # Returns a list of tags for the current subscription.
      #
      def tags
        url = url_with_api_version(
          armrest_configuration.api_version,
          @base_url,
          'subscriptions',
          armrest_configuration.subscription_id,
          'tagNames'
        )
        resp = rest_get(url)
        JSON.parse(resp.body)["value"]
      end

      # Returns a list of tenants that can be accessed.
      #
      def tenants
        url = url_with_api_version(armrest_configuration.api_version, @base_url, 'tenants')
        resp = rest_get(url)
        JSON.parse(resp.body)
      end

      private

      # REST verb methods

      def rest_get(url)
        RestClient.get(
          url,
          :accept        => armrest_configuration.accept,
          :content_type  => armrest_configuration.content_type,
          :authorization => armrest_configuration.token,
        )
      end

      def rest_put(url, body = '')
        RestClient.put(
          url,
          body,
          :accept        => armrest_configuration.accept,
          :content_type  => armrest_configuration.content_type,
          :authorization => armrest_configuration.token,
        )
      end

      def rest_post(url, body = '')
        RestClient.post(
          url,
          body,
          :accept        => armrest_configuration.accept,
          :content_type  => armrest_configuration.content_type,
          :authorization => armrest_configuration.token,
        )
      end

      def rest_patch(url, body = '')
        RestClient.patch(
          url,
          body,
          :accept        => armrest_configuration.accept,
          :content_type  => armrest_configuration.content_type,
          :authorization => armrest_configuration.token,
        )
      end

      def rest_delete(url)
        RestClient.delete(
          url,
          :accept        => armrest_configuration.accept,
          :content_type  => armrest_configuration.content_type,
          :authorization => armrest_configuration.token,
        )
      end

      # Take an array of URI elements and join the together with the API version.
      def url_with_api_version(api_version, *paths)
        File.join(*paths) << "?api-version=#{api_version}"
      end

      # Build a one-time lookup table for each provider & resource. This
      # lets subclasses set api-version strings properly for each method
      # depending on whichever provider they're using.
      #
      # e.g. @@providers['Microsoft.Compute']['virtualMachines']['api_version']
      #
      # Note that for methods that don't depend on a resource type should use
      # the @@api_version class variable instead or set it explicitly as needed.
      #
      def set_providers_info
        return unless @@providers.empty?

        providers.each do |info|
          provider_info = {}
          info['resourceTypes'].each do |resource|
            provider_info[resource['resourceType']] = {
              'api_version' => resource['apiVersions'].first,
              'locations'   => resource['locations'] - [''] # Ignore empty elements
            }
          end
          @@providers[info['namespace']] = provider_info
        end
      end

      # Each Azure API call may require different api_version.
      # The api_version in armrest_configuration is used for common methods provided
      # by ArmrestService
      #
      # The options hash for each service's constructor can contain key-value pair
      #   api_version => version
      # This version will be used for the service specific API calls
      #
      # Otherwise the service specific api_version is looked up from @@providers
      #
      # Finally api_version in armrest_configuration is used if service specific version
      # cannot be determined
      def set_service_api_version(options, service)
        @api_version =
          if options.has_key?('api_version')
            options['api_version']
          elsif @@providers.has_key?(@provider)
            @@providers[@provider][service]['api_version']
          else
            armrest_configuration.api_version
          end
      end
    end # ArmrestService
  end # Armrest
end # Azure
