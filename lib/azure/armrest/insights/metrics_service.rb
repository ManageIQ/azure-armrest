module Azure
  module Armrest
    module Insights
      class MetricsService < ArmrestService
        # Creates and returns a new MetricsService object.
        #
        def initialize(armrest_configuration, options = {})
          options['api_version'] = '2014-04-01' # Must hard code for now
          super(armrest_configuration, 'metricDefinitions', 'Microsoft.Insights', options)
        end

        # Return the metric definitions for the given +provider+, +resource_type+,
        # and +resource_name+ for +resource_group+. You may pass a :filter option as well.
        #
        # Example:
        #
        #   metrics = Azure::Armrest::Insights::MetricsService.new(conf)
        #
        #   metrics.list('Microsoft.SQL', 'servers', 'myServer/databases/myDB', 'mygroup')
        #   metrics.list('Microsoft.Compute', 'virtualMachines', 'myVm', 'mygroup')
        #
        def list(provider, resource_type, resource_name, resource_group = nil, options = {})
          resource_group ||= configuration.resource_group

          raise ArgumentError, "no resource group provided" unless resource_group

          url = build_url(provider, resource_type, resource_name, resource_group, options)

          response = rest_get(url)

          JSON.parse(response)['value'].map { |hash| Azure::Armrest::Insights::Metric.new(hash) }
        end

        private

        def build_url(provider, resource_type, resource_name, resource_group, options)
          sub_id = configuration.subscription_id

          url = File.join(
            Azure::Armrest::COMMON_URI,
            sub_id,
            'resourceGroups',
            resource_group,
            'providers',
            provider,
            resource_type,
            resource_name,
            'metricDefinitions'
          )

          url << "?api-version=#{@api_version}"
          url << "&$filter=#{options[:filter]}" if options[:filter]

          url
        end
      end # MetricsService
    end # Insights
  end # Armrest
end # Azure
