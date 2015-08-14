require 'cache_method'

module Azure
  module Armrest
    class ResourceProviderManager < ArmrestManager
      # The provider used in http requests. The default is 'Microsoft.Resources'
      attr_reader :provider

      # The amount of time in seconds to cache certain methods. The default is 24 hours.
      @cache_time = 24 * 60 * 60

      class << self
        attr_accessor :cache_time
      end

      # Creates and returns a new ResourceProviderManager object.
      #
      # Note that many ResourceProviderManager instance methods are cached. You
      # can set the cache_time for certain methods in the constructor, but keep in
      # mind that it is a global setting for the class. You can also set this
      # at the class level if desired. The default cache time is 24 hours.
      #
      # You can also set the provider. The default is 'Microsoft.Resources'.
      #
      def initialize(options = {})
        super

        @provider = options[:provider] || 'Microsoft.Resources'

        if options[:cache_time]
          @cache_time = options[:cache_time]
          self.class.send(:cache_time=, @cache_time)
        end

        # Typically only empty in testing.
        unless @@providers.empty?
          @api_version = @@providers[@provider]['resourceGroups']['api_version']
        end
      end

      # List all the providers for the current subscription. The results of
      # this method are cached.
      #
      def list
        url = File.join(Azure::Armrest::COMMON_URI, subscription_id, 'providers')
        url << "?api-version=#{api_version}"

        response = rest_get(url)

        JSON.parse(response.body)["value"]
      end

      cache_method(:list, cache_time)

      # Return information about a specific +namespace+ provider. The results
      # of this method are cached.
      #
      def get_provider(namespace)
        url = File.join(Azure::Armrest::COMMON_URI, subscription_id, 'providers', namespace)
        url << "?api-version=#{api_version}"

        response = rest_get(url)

        JSON.parse(response.body)
      end

      cache_method(:get_provider, cache_time)

      # Returns an array of geo-locations for the given +namespace+ provider.
      # The results of this method are cached.
      #
      def geo_locations(namespace)
        url = File.join(Azure::Armrest::RESOURCE, 'providers', namespace)
        url << "?api-version=#{api_version}"

        response = rest_get(url)

        JSON.parse(response.body)['resourceTypes'].first['locations']
      end

      cache_method(:geo_locations, cache_time)

      # Returns an array of supported api-versions for the given +namespace+ provider.
      # The results of this method are cached.
      #
      def api_versions(namespace)
        url = File.join(Azure::Armrest::RESOURCE, 'providers', namespace)
        url << "?api-version=#{api_version}"

        response = rest_get(url)

        JSON.parse(response.body)['resourceTypes'].first['apiVersions']
      end

      cache_method(:api_versions, cache_time)

      # Register the current subscription with the +namespace+ provider.
      #
      def register(namespace)
        url = File.join(Azure::Armrest::COMMON_URI, subscription_id, 'providers', namespace, 'register')
        url << "?api-version=#{api_version}"

        response = rest_post(url)
        response.return!
      end

      # Unregister the current subscription from the +namespace+ provider.
      #
      def unregister(namespace)
        url = File.join(Azure::Armrest::COMMON_URI, subscription_id, 'providers', namespace, 'unregister')
        url << "?api-version=#{api_version}"

        response = rest_post(url)
        response.return!
      end

    end # ResourceGroupManager
  end # Armrest
end # Azure
