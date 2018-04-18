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
      def list(options = {})
        url = build_url

        url << "&$top=#{options[:top]}" if options[:top]
        url << "&$expand=#{options[:expand]}" if options[:expand]

        response = rest_get(url)
        resources = JSON.parse(response)['value']
        resources.map{ |hash| Azure::Armrest::ResourceProvider.new(hash) }
      end

      memoize :list

      # List all the providers for Azure. This may include results that are
      # not available for the current subscription. The results of this method
      # are cached.
      #
      # The +options+ hash takes the following options:
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
      def list_all(options = {})
        url = File.join(configuration.environment.resource_url, 'providers')
        url << "?api-version=#{@api_version}"

        url << "&$top=#{options[:top]}" if options[:top]
        url << "&$expand=#{options[:expand]}" if options[:expand]

        response = rest_get(url)
        resources = JSON.parse(response)['value']

        resources.map{ |hash| Azure::Armrest::ResourceProvider.new(hash) }
      end

      memoize :list_all

      # Return information about a specific +namespace+ provider. The results
      # of this method are cached.
      #
      def get(namespace)
        url = build_url(namespace)
        body = rest_get(url).body
        Azure::Armrest::ResourceProvider.new(body)
      end

      memoize :get

      # Returns an array of geo-locations for the given +namespace+ provider.
      # The results of this method are cached.
      #
      def list_geo_locations(namespace)
        url = build_url(namespace)
        response = rest_get(url)
        JSON.parse(response)['resourceTypes'].first['locations']
      end
      memoize :list_geo_locations

      # Returns an array of supported api-versions for the given +namespace+ provider.
      # The results of this method are cached.
      #
      def list_api_versions(namespace)
        url = build_url(namespace)
        response = rest_get(url)
        JSON.parse(response)['resourceTypes'].first['apiVersions']
      end
      memoize :list_api_versions

      # Register the current subscription with the +namespace+ provider.
      #
      def register(namespace)
        url = build_url(namespace, 'register')
        rest_post(url)
        nil
      end

      # Unregister the current subscription from the +namespace+ provider.
      #
      def unregister(namespace)
        url = build_url(namespace, 'unregister')
        rest_post(url)
        nil
      end

      # Returns whether or not the +namespace+ provider is registered. If
      # the provider cannot be found, false is returned.
      #
      def registered?(namespace)
        get(namespace).registration_state.casecmp("registered").zero?
      rescue Azure::Armrest::NotFoundException
        false
      end

      # Returns whether or not the given +resource_type+ is supported by the
      # given +namespace+. By default it will search the Microsoft.Compute
      # namespace.
      #
      def supported?(resource_type, namespace = 'Microsoft.Compute')
        get(namespace).resource_types.map(&:resource_type).map(&:downcase).include?(resource_type.downcase)
      end

      private

      def build_url(namespace = nil, *args)
        id = configuration.subscription_id
        url = File.join(base_url, 'providers')
        url = File.join(url, namespace) if namespace
        url = File.join(url, *args) unless args.empty?
        url << "?api-version=#{@api_version}"
      end

    end # ResourceGroupService
  end # Armrest
end # Azure
