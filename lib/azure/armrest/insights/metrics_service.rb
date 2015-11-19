module Azure
  module Armrest
    module Insights
      class MetricsService < ArmrestService
        # Creates and returns a new MetricsService object. Note that unlike
        # other service classes, there is no default provider for this class.
        #
        def initialize(_armrest_configuration, options = {})
          super
        end

        # Return the metric definitions for the given +provider+, +resource_type+,
        # and +resource_name+ for +resource_group+. You may pass a :filter option as well.
        #
        # Example:
        #
        #   metrics = Azure::Armrest::Insights::MetricsService.new(conf)
        #   metrics.get('Microsoft.SQL', 'servers', 'myServer/databases/myDB', 'mygroup')
        # 
        def get(provider, resource_type, resource_name, resource_group = nil, options = {})
          subscription_id = armrest_configuration.subscription_id
          resource_group ||= armrest_configuration.resource_group

          raise ArgumentError, "no resource group provided" unless resource_group

          url = File.join(
            Azure::Armrest::COMMON_URI,
            subscription_id,
            'resourcegroups',
            resource_group,
            'providers',
            provider,
            resource_type,
            resource_name,
            'metricDefinitions'
          )

          url << "?api-version=#{@api_version}"
          url << "&$filter=#{options[:filter]}" if options[:filter]

          response = rest_get(URI.escape(url))

          JSON.parse(response)["value"].map{ |hash| Azure::Armrest::Metrics.new(hash) }
        end

      end
    end # Insights
  end # Armrest
end # Azure
