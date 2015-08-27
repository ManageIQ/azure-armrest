# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Base class for managing availability sets.
    class AvailabilitySetService < ArmrestService
      # The provider used in requests when gathering ASM information.
      attr_reader :provider

      # Create and return a new AvailabilitySetService (ASM) instance.
      #
      def initialize(_armrest_configuration, options = {})
        super

        @provider = options[:provider] || 'Microsoft.Compute'

        set_service_api_version(options, 'availabilitySets')
      end

      # Creates a new availability set with the given name. The optional +tags+
      # argument should be a hash, if provided.
      #
      def create(name, location, tags = nil, resource_group = armrest_configuration.resource_group)
        raise ArgumentError, "No resource group specified" if resource_group.nil?

        url = build_url(resource_group, name)
        body = {:name => name, :location => location, :tags => tags}.to_json
        response = rest_put(url, body)
        response.return!
      end

      alias update create

      # Deletes the +name+ availability set.
      #
      def delete(name, resource_group = armrest_configuration.resource_group)
        raise ArgumentError, "No resource group specified" if resource_group.nil?
        url = build_url(resource_group, name)
        response = rest_delete(url)
        response.return!
      end

      # Retrieves the options of an availability set +name+.
      #
      def get(name, resource_group = armrest_configuration.resource_group)
        raise ArgumentError, "No resource group specified" if resource_group.nil?
        url = build_url(resource_group, name)
        response = rest_get(url)
        JSON.parse(response.body)
      end

      # List availability sets.
      #
      def list(resource_group = armrest_configuration.resource_group)
        array = []

        if resource_group
          url = build_url(resource_group)
          response = rest_get(url)
          array << JSON.parse(response.body)['value']
        else
          threads = []
          mutex = Mutex.new

          resource_groups.each do |group|
            url = build_url(group['name'])

            threads << Thread.new(url) do |thread_url|
              response = rest_get(thread_url)
              result = JSON.parse(response)['value']
              mutex.synchronize{ array << result if result }
            end
          end

          threads.each(&:join)
        end

        array.flatten
      end

      # Builds a URL based on subscription_id an resource_group and any other
      # arguments provided, and appends it with the api_version.
      #
      def build_url(resource_group, *args)
        url = File.join(
          Azure::Armrest::COMMON_URI,
          armrest_configuration.subscription_id,
          'resourceGroups',
          resource_group,
          'providers',
          @provider,
          'availabilitySets',
        )

        url = File.join(url, *args) unless args.empty?
        url << "?api-version=#{@api_version}"
      end
    end # AvailabilitySetService
  end # Armrest
end # Azure
