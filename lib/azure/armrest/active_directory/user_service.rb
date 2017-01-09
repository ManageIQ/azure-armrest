module Azure
  module Armrest
    module ActiveDirectory
      class UserService < Azure::Armrest::ActiveDirectoryService
        # Creates a new ActiveDirectory::UserService. The +configuration+
        # object must be an ActiveDirectoryConfiguration instance.
        #
        def initialize(configuration, options = {})
          options[:service_name] = 'users'
          super(configuration, options)
        end

        # Gets the user's manager.
        #
        def get_manager(user, options = {})
          url = build_ad_url(user, options.merge(:property => 'manager'))
          response = rest_get(url)
          model_class.new(response.body)
        end

        # Gets the user's direct reports. Returns an ArmrestCollection.
        #
        def get_direct_reports(user, options = {})
          url = build_ad_url(user, options.merge(:property => 'directReports'))
          response = rest_get(url)
          Azure::Armrest::ArmrestCollection.create_from_response(response, model_class)
        end

        # Gets the user's roles and groups in a single call.
        # Returns an ArmrestCollection.
        #
        def get_roles_and_groups(user, options = {})
          url = build_ad_url(user, options.merge(:property => 'memberOf'))
          response = rest_get(url)
          json = JSON.parse(response.body)['value']

          results = Azure::Armrest::ArmrestCollection.new

          json.each do |item|
            if item['odata.type'] == 'Microsoft.DirectoryServices.Group'
              results << Azure::Armrest::ActiveDirectory::Group.new(item)
            else
              results << Azure::Armrest::ActiveDirectory::Role.new(item)
            end
          end

          results.response_headers = Azure::Armrest::ResponseHeaders.new(response.headers)

          results
        end
      end
    end
  end
end
