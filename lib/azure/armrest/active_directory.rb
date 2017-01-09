module Azure
  module Armrest
    class ActiveDirectoryService < ArmrestService
      # Creates a new ActiveDirectoryService. The +configuration+
      # object must be an ActiveDirectoryConfiguration instance.
      #
      def initialize(configuration, options = {})
        @armrest_configuration = configuration
        @api_version = options[:api_version] || '1.6'
        @service_name = options[:service_name]
      end

      # Create resource using the given +options+, which should be a hash
      # that contains keys that match the valid parameters for that resource.
      #
      # Returns a model class object.
      #
      def create(options = {})
        url = build_ad_url
        response = rest_post(url, options.to_json)
        model_class.new(response.body)
      end

      # Delete resource +name+. Returns a ResponseHeader object. Note that
      # a 204 indicates success.
      #
      def delete(resource)
        url = build_ad_url(resource)
        response = rest_delete(url)

        # A 204 (no body) indicates success.
        raise_api_exception(response) if response.code != 204

        Azure::Armrest::ResponseHeaders.new(response.headers).tap do |headers|
          headers.response_code = response.code
        end
      end

      # Get information for +name+. The options hash may contain :links,
      # :filter, :orderby, :expand, :top, :format, or :property keys.
      #
      def get(name, options = {})
        url = build_ad_url(name, options)
        response = rest_get(url)
        model_class.new(response.body)
      end

      # Returns a collection of objects based on a +list+ of object ID's. You
      # may optionally specify a +type+ as well, e.g. "groups".
      #
      def get_by_id(list, type = nil, options = {})
        url = build_ad_url('getObjectsByObjectIds', options, false)

        body = {:objectIds => [list].flatten} # Allow single id's as well.
        body[:types] = type if type

        response = rest_post(url, body.to_json)
        Azure::Armrest::ArmrestCollection.create_from_response(response, model_class)
      end

      # Returns the object ID for the given application ID.
      #
      def get_object_id_for_service_principal(app_id, options = {})
        url = build_ad_url('servicePrincipalsByAppId', options.merge(:property => "#{app_id}/objectId"), false)
        response = rest_get(url)
        JSON.parse(response.body)['value']
      end

      # Get a list of objects. The options hash may contain :links,
      # :filter, :orderby, :expand, :top, :format, or :property keys.
      #
      # By default this will only collect the first 100 results. If you
      # want to make sure you get all results, use the list_all method.
      #
      def list(options = {})
        url = build_ad_url(nil, options)
        response = rest_get(url)
        Azure::Armrest::ArmrestCollection.create_from_response(response, model_class)
      end

      # Get a list of objects. The options hash may contain :links,
      # :filter, :orderby, :expand, :top, :format, or :property keys.
      #
      # Unlike the list method, this will use continuation tokens to collect
      # all results. Please consider using a filter of some sort for large
      # data sets.
      #
      def list_all(options = {})
        results = list(options)

        if results.continuation_token
          results.concat(list(options.merge(:skiptoken => results.continuation_token)))
          results.continuation_token = nil # Clear when finished
        end

        results
      end

      # Returns a plain list that contains the object IDs of the groups that
      # the resource (contact, user, group, or service principal) is a member
      # of.
      #
      def list_groups(resource, options = {})
        url = build_ad_url(resource, options.merge(:property => 'getMemberGroups'))
        response = rest_post(url, {:securityEnabledOnly => true}.to_json)
        JSON.parse(response.body)['value']
      end

      # Update +resource+. Returns a ResponseHeader object. Note that
      # a 204 indicates success.
      #
      def update(resource, options = {})
        url = build_ad_url(resource, options) 
        response = rest_patch(url)

        # A 204 (no body) indicates success.
        raise_api_exception(response) if response.code != 204

        Azure::Armrest::ResponseHeaders.new(response.headers).tap do |headers|
          headers.response_code = response.code
        end
      end

      private

      # Builds a standard URL for use with the ActiveDirectory related Service
      # classes. The URL is modified depending on the presence of +object_id+
      # (which could be a user ID, group ID, etc).
      #
      # The options hash may contain :links, :filter, :orderby, :expand, :top,
      # :format, or :property keys.
      #
      # If :links is set to true, then the "$links" string is appended
      # to the URL, and any :property will be appended as well.
      #
      # If :filter, :orderby, :format, :expand, or :top options are present, then
      # they will be appended as part of the query string. The api-version
      # is automatically appended.
      #
      def build_ad_url(object_id = nil, options = {}, include_service_name = true)
        url = File.join(configuration.environment.graph_url, configuration.tenant_id)
        url = File.join(url, service_name) if include_service_name
        url = File.join(url, object_id) if object_id

        # Remove these before appending query values
        links = options.delete(:links)
        property = options.delete(:property)

        if property
          if links
            url = File.join(url, "$links", property)
          else
            url = File.join(url, property)
          end
        end

        url = "#{url}?api-version=#{api_version}"

        options.each{ |key, value| url << "&$#{key}=#{value}" }

        url
      end
    end
  end
end
