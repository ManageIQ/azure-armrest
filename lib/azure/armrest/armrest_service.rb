require 'time'
require_relative 'model/base_model'

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
        :token,
        :token_expiration, # token expiration local system date
        :proxy,
        :ssl_verify,
        :ssl_version
      ) do
        @@tokens = Hash.new([])

        def as_cache_key
          "#{grant_type}_#{tenant_id}_#{client_id}_#{client_key}"
        end

        def token
          self[:token], self[:token_expiration] = @@tokens[as_cache_key] if self[:token].nil?

          if self[:token].nil? || Time.now > (self[:token_expiration] || Time.new(0))
            self[:token], self[:token_expiration] = fetch_token
          end
          self[:token]
        end

        def fetch_token
          token_url = Azure::Armrest::AUTHORITY + tenant_id + "/oauth2/token"

          response = JSON.parse(
            ArmrestService.rest_post(
              :url         => token_url,
              :proxy       => proxy,
              :ssl_version => ssl_version,
              :ssl_verify  => ssl_verify,
              :payload => {
                :grant_type    => grant_type,
                :client_id     => client_id,
                :client_secret => client_key,
                :resource      => Azure::Armrest::RESOURCE
              }
            )
          )

          token = 'Bearer ' + response['access_token']
          @@tokens[as_cache_key] = [token, Time.now + response['expires_in'].to_i]
        end

        private :fetch_token
      end

      # Configuration to access azure APIs
      attr_accessor :armrest_configuration

      alias configuration armrest_configuration

      # Base url used for REST calls.
      attr_accessor :base_url

      # provider for service specific API calls
      attr_accessor :provider

      # The api-version string used for each request.
      attr_accessor :api_version

      # The http proxy used for each request. Uses ENV['http_proxy'] if set.
      attr_accessor :proxy

      # The SSL verification method used for each request. The default is VERIFY_PEER.
      attr_accessor :ssl_verify

      # The SSL version used for each request. The default is TLSv1.
      attr_accessor :ssl_version

      # Clear class level caches.
      def self.clear_caches
        @@providers_hash = {} # Set in constructor
        @@tokens         = {} # token caches
        @@subscriptions  = {} # subscription caches
      end

      clear_caches

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
      #   - token,
      #   - token_expiration
      #   - proxy
      #   - ssl_verify
      #   - ssl_version
      #
      # Of these, you should include a :client_id, :client_key and :tenant_id.
      # The resource_group can be specified here, but many methods allow you
      # to specify a resource group if you prefer flexibility.
      #
      # If no :subscription_id is provided then this method will attempt to find
      # a list of associated subscriptions and use the first one it finds as
      # the default. If no associated subscriptions are found, an ArgumentError
      # is raised.
      #
      # The other options (:grant_type, :content_type, :accept, :token,
      # :token_expiration and :api_version) should generally NOT be set by you
      # except in specific circumstances. Setting them explicitly will likely
      # cause breakage.
      #
      # The :token and :token_expiration options must be set in pair. The
      # :token_expiration should be set in local system time.
      #
      # The :api_version will typically be overridden on a per-provider/resource
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

        unless configuration.client_id && configuration.client_key
          raise ArgumentError, "client_id and client_key must be specified"
        end

        # Set default values for certain configuration items.
        configuration.api_version  ||= '2015-01-01'
        configuration.grant_type   ||= 'client_credentials'
        configuration.content_type ||= 'application/json'
        configuration.accept       ||= 'application/json'
        configuration.proxy        ||= ENV['http_proxy']
        configuration.ssl_version  ||= 'TLSv1'

        # Allows for URI objects or Strings.
        configuration.proxy = configuration.proxy.to_s if configuration.proxy

        # After all other config options have been set, look for default subscription.
        configuration.subscription_id ||= fetch_subscription_id(configuration)

        configuration
      end

      # Find the first enabled subscription if one isn't provided or cached.
      #
      def self.fetch_subscription_id(config)
        return @@subscriptions[config.as_cache_key] if @@subscriptions.has_key?(config.as_cache_key)

        url = File.join(Azure::Armrest::RESOURCE, "subscriptions?api-version=#{config.api_version}")

        options = {
          :url         => url,
          :proxy       => config.proxy,
          :ssl_version => config.ssl_version,
          :ssl_verify  => config.ssl_verify,
          :headers     => {
            :content_type  => config.content_type,
            :authorization => config.token
          }
        }

        response = rest_get(options)
        array = JSON.parse(response)['value']

        if array.nil? || array.empty?
          raise ArgumentError, "No associated subscription found"
        end

        results = []

        # Skip over any invalid subscriptions
        array.each do |sub_hash|
          sub_id = sub_hash['subscriptionId']

          # Use tagNames as a test URL
          test_url = File.join(
            Azure::Armrest::RESOURCE, 'subscriptions', sub_id,
            "tagNames?api-version=#{config.api_version}"
          )

          begin
            options[:url] = test_url
            rest_get(options)
          rescue Azure::Armrest::UnauthorizedException, Azure::Armrest::BadRequestException
            next
          else
            results << sub_hash
            break if sub_hash['state'] == 'Enabled'
          end
        end

        # Look for the first enabled subscription, otherwise just take the first subscription found.
        hash = results.find { |h| h['state'] == 'Enabled' } || results.first

        id = hash.fetch('subscriptionId')

        warn "Warning: subscription #{id} is not enabled" unless hash['state'] == 'Enabled'

        @@subscriptions[config.as_cache_key] = id
      end

      private_class_method :fetch_subscription_id

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

      # Returns a list of the available resource providers.
      #
      def providers
        url = url_with_api_version(configuration.api_version, @base_url, 'providers')
        resp = rest_get(url)
        JSON.parse(resp.body)["value"].map{ |hash| Azure::Armrest::ResourceProvider.new(hash) }
      end

      # Returns information about the specific provider +namespace+.
      #
      def provider_info(provider)
        url = url_with_api_version(configuration.api_version, @base_url, 'providers', provider)
        response = rest_get(url)
        Azure::Armrest::ResourceProvider.new(response)
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
        hash = provider.nil? ? @@providers_hash : {provider => @@providers_hash[provider.downcase]}

        hash.collect do |_provider, provider_data|
          provider_data.collect { |_resource, resource_data| resource_data['locations'] }
        end.flatten.uniq
      end

      # Returns a list of subscriptions for the tenant.
      #
      def subscriptions
        url = url_with_api_version(configuration.api_version, @base_url, 'subscriptions')
        response = rest_get(url)
        JSON.parse(response.body)["value"].map{ |hash| Azure::Armrest::Subscription.new(hash) }
      end

      # Return information for the specified subscription ID, or the
      # subscription ID that was provided in the constructor if none is
      # specified.
      #
      def subscription_info(subscription_id = configuration.subscription_id)
        url = url_with_api_version(
          configuration.api_version,
          @base_url,
          'subscriptions',
          subscription_id
        )

        response = rest_get(url)
        Azure::Armrest::Subscription.new(response.body)
      end

      # Returns a list of resources for the current subscription. If a
      # +resource_group+ is provided, only list resources for that
      # resource group.
      #
      def resources(resource_group = nil)
        url_comps = [@base_url, 'subscriptions', configuration.subscription_id]
        url_comps += ['resourcegroups', resource_group] if resource_group
        url_comps << 'resources'

        url = url_with_api_version(configuration.api_version, url_comps)
        response = rest_get(url)

        JSON.parse(response)["value"].map{ |hash| Azure::Armrest::Resource.new(hash) }
      end

      # Returns a list of resource groups for the current subscription.
      #
      def resource_groups
        url = url_with_api_version(
          configuration.api_version,
          @base_url,
          'subscriptions',
          configuration.subscription_id,
          'resourcegroups'
        )
        response = rest_get(url)
        JSON.parse(response)["value"].map{ |hash| Azure::Armrest::ResourceGroup.new(hash) }
      end

      # Returns information on the specified +resource_group+ for the current
      # subscription, or the resource group specified in the constructor if
      # none is provided.
      #
      def resource_group_info(resource_group = configuration.resource_group)
        url = url_with_api_version(
          configuration.api_version,
          @base_url,
          'subscriptions',
          configuration.subscription_id,
          'resourcegroups',
          resource_group
        )

        response = rest_get(url)
        Azure::Armrest::ResourceGroup.new(response.body)
      end

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

      # The name of the file or handle used to log requests.
      #
      def self.log
        file = RestClient.log.instance_variable_get("@target_file")
        file || RestClient.log
      end

      # Sets the log to +output+, which can be a file or a handle.
      #
      def self.log=(output)
        RestClient.log = output
      end

      def self.rest_execute(options, http_method = :get)
        options = options.merge(
          :method => http_method,
          :url    => URI.escape(options[:url])
        )

        RestClient::Request.execute(options)
      rescue RestClient::Exception => e
        raise_api_exception(e)
      end

      def self.rest_get(options)
        rest_execute(options, :get)
      end

      def self.rest_post(options)
        rest_execute(options, :post)
      end

      def self.rest_patch(options)
        rest_execute(options, :patch)
      end

      def self.rest_delete(options)
        rest_execute(options, :delete)
      end

      def self.rest_put(options)
        rest_execute(options, :put)
      end

      def self.rest_head(options)
        rest_execute(options, :head)
      end

      def self.raise_api_exception(e)
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
                         else
                           ApiException
                         end

        raise exception_type.new(code, message, e)
      end

      private_class_method :raise_api_exception

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

        self.class.rest_execute(options, http_method)
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

      # Build a one-time lookup table for each provider & resource. This
      # lets subclasses set api-version strings properly for each method
      # depending on whichever provider they're using.
      #
      # e.g. @@providers_hash['Microsoft.Compute']['virtualMachines']['api_version']
      #
      # Note that for methods that don't depend on a resource type should use
      # armrest_configuration.api_version instead or set it explicitly as needed.
      #
      def set_providers_info
        return unless @@providers_hash.empty?

        providers.each do |info|
          provider_info = {}
          info.resource_types.each do |resource|
            provider_info[resource.resource_type.downcase] = {
              'api_version' => resource.api_versions.reject{ |version|
                version =~ /preview/i || Time.parse(version) > Time.now
              }.first,
              'locations' => resource.locations - [''] # Ignore empty elements
            }
          end
          # TODO: how does base model handle method naming collision?
          # rename or access through hash?
          # namespace is a method introduced by more_core_extensions
          @@providers_hash[info['namespace'].downcase] = provider_info
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
      # Otherwise the service specific api_version is looked up from @@providers_hash
      #
      # Finally api_version in armrest_configuration is used if service specific version
      # cannot be determined
      def set_service_api_version(options, service)
        set_providers_info
        @api_version =
          if options.has_key?('api_version')
            options['api_version']
          elsif @@providers_hash.has_key?(provider.downcase)
            @@providers_hash[provider.downcase][service.downcase]['api_version']
          else
            configuration.api_version
          end
      end

      # Parse the skip token value out of the nextLink attribute from a response.
      def parse_skip_token(json)
        return nil unless json['nextLink']
        json['nextLink'][/.*?skipToken=(.*?)$/i, 1]
      end
    end # ArmrestService
  end # Armrest
end # Azure
