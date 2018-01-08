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
        # can return in one batch (API default 200). You may also set the :all
        # option to true, in which case all batches will automatically be
        # collected for you.
        #
        # In practice you should always set a filter for eventTimestamp because
        # you are restricted to 90 days worth of events. If you do not set the
        # filter and/or you try to retrieve more than 90 days worth of events
        # then you will get an error. This is a limitation of the Azure API.
        #
        # Example:
        #
        #   ies = Azure::Armrest::Insights::EventService.new(conf)
        #
        #   date   = (Time.now - 86400).httpdate
        #   filter = "eventTimestamp ge #{date} and eventChannels eq 'Admin, Operation'"
        #   select = "resourceGroupName, operationName"
        #
        #   ies.list(:filter => filter, :select => select, :all => true).each{ |event|
        #     p event
        #   }
        #
        def list(options = {})
          path = build_path(nil, 'management', 'values')
          query = build_query_hash(options)
          response = rest_get(path, query)

          if options[:all]
            list_all(options)
          else
            klass  = Azure::Armrest::Insights::Event
            Azure::Armrest::ArmrestCollection.create_from_response(response, klass)
          end
        end

        def list_all(options = {})
          path = build_path(nil, 'management', 'values')
          query = build_query_hash(options)
          response = rest_get(path, query)
          get_all_results(response)
        end
      end # EventService
    end # Insights
  end # Armrest
end # Azure
