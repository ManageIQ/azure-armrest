module Azure
  module Armrest
    class ResourceProviderService < ArmrestService
      extend Memoist

      # The provider used in http requests. The default is 'Microsoft.Resources'
      attr_reader :provider

      # Creates and returns a new ResourceProviderService object.
      #
      # Note that many ResourceProviderService instance methods are cached.
      #
      # You can also set the provider. The default is 'Microsoft.Resources'.
      #
      def initialize(configuration, options = {})
        super(configuration, 'resourceGroups', 'Microsoft.Resources', options)
      end

      # List all the providers for the current subscription. The results of
      # this method are cached.
      #
      def list(query_options = {})
        path = File.join('subscriptions', configuration.subscription_id, 'providers')
        query = build_query_hash(query_options)

        response = rest_get(path, query)
        Azure::Armrest::ArmrestCollection.create_from_response(response, Azure::Armrest::ResourceProvider)
      end

      memoize :list

      # List all the providers for Azure. This may include results that are
      # not available for the current subscription. The results of this method
      # are cached.
      #
      # The +query_options+ hash takes the following options:
      #
      # * :top    => Limit the result set to the top x results.
      # * :expand => Additional properties to include in the results.
      #
      # Examples:
      #
      #   rps.list_all                        # Get everything
      #   rps.list_all(:top => 3)             # Get first 3 results
      #   rps.list_all(:expand => 'metadata') # Include metadata in results
      #
      #--
      # NOTE: As of September, 2017, this call does not appear to be honoring
      # the :top parameter. This is an Azure bug.
      #
      def list_all(query_options = {})
        query = build_query_hash(query_options)
        response = rest_get('/providers', query)
        Azure::Armrest::ArmrestCollection.create_from_response(response, Azure::Armrest::ResourceProvider)
      end

      memoize :list_all

      # Return information about a specific +namespace+ provider. The results
      # of this method are cached.
      #
      # Example:
      #
      #   rps.get('Microsoft.Compute')
      #
      def get(namespace, query_options = {})
        path = build_url(namespace)
        query = build_query_hash(query_options)
        response = rest_get(path, query)
        Azure::Armrest::ResourceProvider.new(response.body)
      end

      memoize :get

      # Returns an array of geo-locations for the given +namespace+ provider.
      # The results of this method are cached.
      #
      def list_geo_locations(namespace, query_options = {})
        path = build_url(namespace)
        query = build_query_hash(query_options)
        response = rest_get(path, query)
        JSON.parse(response.body)['resourceTypes'].first['locations']
      end

      memoize :list_geo_locations

      # Returns an array of supported api-versions for the given +namespace+ provider.
      # The results of this method are cached.
      #
      def list_api_versions(namespace, query_options = {})
        path = build_url(namespace)
        query = build_query_hash(query_options)
        response = rest_get(path, query)
        JSON.parse(response.body)['resourceTypes'].first['apiVersions']
      end

      memoize :list_api_versions

      # Register the current subscription with the +namespace+ provider.
      #
      def register(namespace)
        path = build_url(namespace, 'register')
        rest_post(path)
      end

      # Unregister the current subscription from the +namespace+ provider.
      #
      def unregister(namespace)
        path = build_url(namespace, 'unregister')
        rest_post(path)
      end

      # Returns whether or not the +namespace+ provider is registered. If
      # the provider cannot be found, false is returned.
      #
      def registered?(namespace)
        get(namespace).registration_state.casecmp('registered').zero?
      rescue Azure::Armrest::NotFoundException
        false
      end

      private

      def build_url(namespace = nil, *args)
        url = File.join(base_path, 'providers')
        url = File.join(url, namespace) if namespace
        url = File.join(url, *args) unless args.empty?
        url
      end
    end # ResourceGroupService
  end # Armrest
end # Azure
