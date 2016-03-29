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
        #   ies.list(:filter => filter, :select => select, :all => true).events.each{ |event|
        #     p event
        #   }
        #
        def list(options = {})
          url = build_url(options)
          response = rest_get(url)
          json_response = JSON.parse(response.body)

          events = ArmrestCollection.new(
            json_response['value'].map do |hash|
              Azure::Armrest::Insights::Event.new(hash)
            end
          )

          events.continuation_token = parse_skip_token(json_response)

          if options[:all] && events.continuation_token
            events.push(*list(options.merge(:skip_token => events.continuation_token)))
            events.continuation_token = nil # Clear when finished
          end

          events
        end

        private

        def build_url(options = {})
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
          url << "&$filter=#{options[:filter]}" if options[:filter]
          url << "&$select=#{options[:select]}" if options[:select]
          url << "&$skipToken=#{options[:skip_token]}" if options[:skip_token]

          url
        end
      end # EventService

    end # Insights
  end # Armrest
end # Azure
