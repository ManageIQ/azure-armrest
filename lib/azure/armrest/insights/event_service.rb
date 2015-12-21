# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Insights namespace
    module Insights

      # Base class for managing events.
      class EventService < ArmrestService
        # Create and return a new EventService instance.
        #
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'eventTypes', 'Microsoft.Insights', options)
        end

        # Returns a list of management events for the current subscription.
        # The +filter+ option can be used to filter the result set. Additionally,
        # you may restrict the results to only return certain fields using
        # the +select+ option. The possible fields for both filtering and selection
        # are:
        #
        # authorization, channels, claims, correlationId, description, eventDataId,
        # eventName, eventSource, eventTimestamp, httpRequest, level, operationId,
        # operationName, properties, resourceGroupName, resourceProviderName,
        # resourceUri, status, submissionTimestamp, subStatus and subscriptionId.
        #
        # Example:
        #
        #   ies = Azure::Armrest::Insights::EventService.new(conf)
        #
        #   date   = (Time.now - 86400).httpdate
        #   filter = "eventTimestamp ge #{date} and eventChannels eq 'Admin, Operation'"
        #   select = "resourceGroupName, operationName"
        #
        #   ies.list(filter, select).each{ |event|
        #     p event
        #   }
        #
        def list(filter = nil, select = nil)
          url = build_url(filter, select)
          response = rest_get(url)
          JSON.parse(response.body)['value'].map{ |e| Azure::Armrest::Insights::Event.new(e) }
        end

        private

        def build_url(filter = nil, select = nil)
          sub_id = armrest_configuration.subscription_id

          url =
            File.join(
              Azure::Armrest::COMMON_URI,
              sub_id,
              'providers',
              provider,
              'eventtypes',
              'management',
              'values'
            )

          url << "?api-version=#{@api_version}"
          url << "&$filter=#{filter}" if filter
          url << "&$select=#{select}" if select

          url
        end
      end # EventService

    end # Insights
  end # Armrest
end # Azure
