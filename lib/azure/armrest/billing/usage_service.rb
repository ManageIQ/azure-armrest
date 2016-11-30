module Azure
  module Armrest
    module Billing
      class UsageService < ArmrestService
        # Creates and returns a new UsageService object.
        #
        def initialize(configuration, options = {})
          options = options.merge('api_version' => '2015-06-01-preview')
          super(configuration, 'subscriptions', 'Microsoft.Commerce', options)
        end

        # List usage details. The +options+ hash may include the following
        # filters:
        #
        #   :reportedStartTime        # e.g. 2016-05-30T00:00:00Z. Mandatory.
        #   :reportedEndTime          # e.g. 2016-06-01T00:00:00Z. Mandatory.
        #   :aggregationGranularity   # Either 'Daily' or 'Hourly'. Default is Daily.
        #   :showDetails              # Either true or false. Default is true.
        #   :continuationToken        # Token received from previous call. No default.
        #
        # You may also pass ':all => true' to retrieve all records instead of
        # dealing with continuation tokens yourself. By default Azure will only
        # return the first 1000 records.
        #
        # The :reportedStartTime and :reportedEndTime values should be in
        # UTC + iso8601 format. For "Daily" aggregation, the time should be set
        # to midnight. For "Hourly" aggregation, only the hour should be
        # set, with minutes and seconds set to "00".
        #
        # Example:
        #
        #   require 'azure-armrest'
        #   require 'time'
        #
        #   conf = Azure::Armrest::Configuration.new(<your_credentials>)
        #   bill = Azure::Armrest::Billing::UsageService.new(conf)
        #
        #   options = {
        #     :reportedStartTime      => Time.new(2016,10,1,0,0,0,0).utc.iso8601,
        #     :reportedEndTime        => Time.new(2016,10,31,0,0,0,0).utc.iso8601,
        #     :showDetails            => true,
        #     :aggregationGranularity => 'Daily',
        #     :all                    => true
        #   }
        #
        #   list = bill.list(options)
        #
        def list(options = {})
          url = build_url(options)
          response = rest_get(url)

          if options[:all]
            get_all_results(response)
          else
            Azure::Armrest::ArmrestCollection.create_from_response(response, Azure::Armrest::Billing::Usage)
          end
        end

        private

        def build_url(options = {})
          url = File.join(
            Azure::Armrest::COMMON_URI,
            configuration.subscription_id,
            'providers',
            @provider,
            'UsageAggregates'
          )

          url << "?api-version=#{@api_version}"

          options.each do |key, value|
            url << "&#{key}=#{value}"
          end

          url
        end
      end
    end
  end
end
