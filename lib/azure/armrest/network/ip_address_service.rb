module Azure
  module Armrest
    module Network
      # Class for managing public IP addresss.
      class IpAddressService < ArmrestService

        # Creates and returns a new IpAddressService instance.
        #
        def initialize(_armrest_configuration, options = {})
          super
          @provider = options[:provider] || 'Microsoft.Network'
          set_service_api_version(options, 'publicIPAddresses')
        end

        # Return information for the given IP address name for the
        # provided +resource_group+. If no group is specified, it will use
        # the resource group set in the constructor.
        #
        # Example:
        #
        #   # Where 'your_ip_name' likely corresponds to a VM name.
        #   ip.get('your_ip_name', 'your_resource_group')
        #
        def get(ip_name, resource_group = armrest_configuration.resource_group)
          raise ArgumentError, "must specify resource group" unless resource_group
          url = build_url(resource_group, ip_name)
          JSON.parse(rest_get(url))
        end

        # Shortcut method that returns just the IP address for the given public
        # IP address name.
        #
        def get_ip(ip_name, resource_group = armrest_configuration.resource_group)
          get(ip_name, resource_group)['properties']['ipAddress']
        end

        # Returns a list of available IP addresss for the given subscription
        # for the provided +group+, or for all resource groups if no group is specified.
        #
        def list(group = nil)
          if group
            url = build_url(group)
            JSON.parse(rest_get(url))['value']
          else
            array = []
            threads = []
            mutex = Mutex.new

            resource_groups.each do |rg|
              threads << Thread.new(rg['name']) do |group|
                url = build_url(group)
                response = rest_get(url)
                results = JSON.parse(response)['value']
                if results && !results.empty?
                  mutex.synchronize{
                    results.each{ |hash| hash['resourceGroup'] = group }
                    array << results
                  }
                end
              end
            end

            threads.each(&:join)

            array.flatten
          end
        end

        # List all IP addresss for the current subscription.
        #
        def list_all_for_subscription
          sub_id = armrest_configuration.subscription_id
          url = File.join(
            Azure::Armrest::COMMON_URI, sub_id, 'providers',
            @provider, 'publicIPAddresses'
          )
          url << "?api-version=#{@api_version}"
          JSON.parse(rest_get(url))['value']
        end

        alias list_all list_all_for_subscription

        private

        # Builds a URL based on subscription_id an resource_group and any other
        # arguments provided, and appends it with the api-version.
        def build_url(resource_group, *args)
          url = File.join(
            Azure::Armrest::COMMON_URI,
            armrest_configuration.subscription_id,
            'resourceGroups',
            resource_group,
            'providers',
            @provider,
            'publicIPAddresses',
          )

          url = File.join(url, *args) unless args.empty?
          url << "?api-version=#{@api_version}"
        end
      end
    end # Network
  end # Armrest
end # Azure
