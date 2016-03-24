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

        # Returns an +EventList+ containing a list of management evnets for the
        # current subscription as well as a +next_link+ attribute that can be
        # used to obtain the next batch of events for this result.
        #
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
        # The +skip_token+ option can be used to grab the next batch of events
        # when the first call reaches the maximum number of events that the API
        # can return in one batch (API default 200).
        #
        # Example:
        #
        #   ies = Azure::Armrest::Insights::EventService.new(conf)
        #
        #   date   = (Time.now - 86400).httpdate
        #   filter = "eventTimestamp ge #{date} and eventChannels eq 'Admin, Operation'"
        #   select = "resourceGroupName, operationName"
        #
        #   ies.list(filter, select, skip_token).events.each{ |event|
        #     p event
        #   }
        #
        def list(filter = nil, select = nil, skip_token = nil)
          url = build_url(filter, select, skip_token)
          response = rest_get(url)
          json_response = JSON.parse(response.body)

          events          = json_response['value'].map{ |e| Azure::Armrest::Insights::Event.new(e) }
          next_link       = json_response['nextLink']
          next_skip_token = next_link[/.*?skipToken=(.*?)$/, 1] if next_link
          Azure::Armrest::Insights::EventList.new(events, next_skip_token)
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
        # +list_all+ differs from the +list+ method in that it will list all of
        # the events that would be returned for the given +filter+ and +select+
        # instead of returning only the first page of events as defined by the
        # Azure API event threshold (200 per page, by default).
        #
        # Example:
        #
        #   ies = Azure::Armrest::Insights::EventService.new(conf)
        #
        #   date   = (Time.now - 86400).httpdate
        #   filter = "eventTimestamp ge #{date} and eventChannels eq 'Admin, Operation'"
        #   select = "resourceGroupName, operationName"
        #
        #   ies.list_all(filter, select).each{ |event|
        #     p event
        #   }
        #
        def list_all(filter = nil, select = nil)
          event_list = list(filter, select)
          events = event_list.events

          while skip_token = event_list.skip_token do
            event_list = list(filter, select, skip_token)
            events += event_list.events
          end
          events
        end

        private

        def build_url(filter = nil, select = nil, skip_token = nil)
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
          url << "&$skipToken=#{skip_token}" if skip_token

          url
        end
      end # EventService

    end # Insights
  end # Armrest
end # Azure
