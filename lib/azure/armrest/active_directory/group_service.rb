module Azure
  module Armrest
    module ActiveDirectory
      class GroupService < Azure::Armrest::ActiveDirectoryService
        # Creates a new ActiveDirectory::GroupService. The +configuration+
        # object must be an ActiveDirectoryConfiguration instance.
        #
        def initialize(configuration, options = {})
          options[:service_name] = 'groups'
          super(configuration, options)
        end

        # Gets the group's direct members.
        #
        def get_members(group_id, options = {})
          url = build_ad_url(group_id, options.merge(:property => 'members'))
          response = rest_get(url)
          model_class.new(response.body)
        end

        # Delete member +object_id+ from +group_id+. Returns a
        # ResponseHeader object.
        #
        def delete_member(group_id, object_id, options = {})
          options[:property] = "members/#{object_id}"
          url = build_ad_url(group_id, options.merge(:links => true))
          response = rest_delete(url)

          # A 204 (no body) indicates success.
          raise_api_exception(response) if response.code != 204

          Azure::Armrest::ResponseHeaders.new(response.headers).tap do |headers|
            headers.response_code = response.code
          end
        end

        # Adds a member with +object_id+ to +group_id+. Returns a
        # ResponseHeaders object.
        #
        def add_member(group_id, object_id, options = {})
          body = {
            :url => File.join(
              configuration.environment.graph_url,
              configuration.tenant_id,
              'directoryObjects',
              object_id
            )
          }

          url = build_ad_url(group_id, options.merge(:property => 'members', :links => true))
          response = rest_post(url, body.to_json)

          # A 204 (no body) indicates success.
          raise_api_exception(response) if response.code != 204

          Azure::Armrest::ResponseHeaders.new(response.headers).tap do |headers|
            headers.response_code = response.code
          end
        end
      end
    end
  end
end
