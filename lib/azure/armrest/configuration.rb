module Azure
  module Armrest
    class Configuration
      # Used to store unique token information.
      @@tokens = Hash.new([])

      # The client ID used to gather token information.
      attr_accessor :client_id

      # The client key used to gather token information.
      attr_accessor :client_key

      # The tenant ID used to gather token information.
      attr_accessor :tenant_id

      # The resource group used for a given http request.
      attr_accessor :resource_group

      # The API version used for a given http request. The default is 2015-01-01.
      attr_accessor :api_version

      # The grant type. The default is client_credentials
      attr_accessor :grant_type

      # The content type specified for http requests. The default is 'application/json'
      attr_accessor :content_type

      # The accept type specified for http request results. The default is 'application/json'
      attr_accessor :accept

      # Explicitly set the token.
      attr_writer :token

      # Yields a new Azure::Armrest::Configuration objects. Note that you must
      # specify a client_id and client_key. All other parameters are optional.
      #
      # Example:
      #
      #   config = Azure::Armrest::Configuration.new(
      #     :client_id  => 'xxxx',
      #     :client_key => 'yyyy',
      #     :tenant_id  => 'zzzz'
      #   )
      #
      def initialize(hash)
        @subscriptions = Hash.new([]) # Used internally

        hash.each{ |key,value| send("#{key}=", value) }

        unless client_id && client_key
          raise ArgumentError, "client_id and client_key must both be specified"
        end

        # Set defaults if not already set
        @accept           ||= 'application/json'
        @content_type     ||= 'application/json'
        @grant_type       ||= 'client_credentials'
        @api_version      ||= '2015-01-01'
        @token_expiration ||= Time.new(0)

        fetch_subscription_id unless @subscription_id
      end

      # Returns a list of subscriptions currently attached to the
      # current credentials.
      #
      def subscriptions
        @subscriptions[cache_key]
      end

      # Returns the current subscription ID. If there are multiple
      # subscriptions associated with the configuration, then it returns
      # the last subscription that was added.
      #
      def subscription_id
        @subscriptions[cache_key].last
      end

      # A synonym for add_subscription.
      #
      def subscription_id=(value)
        add_subscription(value)
      end

      # Add a subscription to the current credentials, and makes it
      # the current subscription ID.
      #
      # Note that if you add a subscription that already exists, then the
      # the configuration object assumes that you wish to make the provided
      # subscription the current subscription.
      #
      def add_subscription(value)
        if @subscriptions[cache_key].include?(value)
          @subscriptions[cache_key].delete(value) 
        end

        @subscriptions[cache_key] << value
        @subscription_id = value
      end

      # A combination of grant_type, tenant_id, client_id and client_key,
      # as a single string joined by underscores.
      #
      # Used to identify unique sessions.
      #
      def as_cache_key
        "#{grant_type}_#{tenant_id}_#{client_id}_#{client_key}"
      end

      alias cache_key as_cache_key

      # Returns the token for the given cache_key, or sets it if it does not
      # exist or it has expired.
      #
      def token
        @token, @token_expiration = @@tokens[cache_key] if @token.nil?

        if @token.nil? || Time.now.utc > @token_expiration
          @token, @token_expiration = fetch_token
        end

        @token
      end

      # Set the token value and expiration time.
      #
      def set_token(token, token_expiration)
        @token, @token_expiration = token, token_expiration
      end

      # Returns the expiration datetime for given key, or the current
      # cache_key if no key is specified.
      #
      def token_expiration(key = cache_key)
        @@tokens[key].last
      end

      # Set the time in which the token expires. The time is automatically
      # converted to UTC.
      #
      def token_expiration=(time)
        @token_expiration = time.utc
      end

      private

      def fetch_token
        token_url = File.join(Azure::Armrest::AUTHORITY, tenant_id, 'oauth2/token')

        response = JSON.parse(ArmrestService.rest_post(
          token_url,
          :grant_type    => grant_type,
          :client_id     => client_id,
          :client_secret => client_key,
          :resource      => Azure::Armrest::RESOURCE
        ))

        token = 'Bearer ' + response['access_token']

        @@tokens[cache_key] = [token, Time.now.utc + response['expires_in'].to_i]
      end

      def fetch_subscription_id
        return @subscriptions[cache_key] if @subscriptions.has_key?(cache_key)

        url = File.join(Azure::Armrest::RESOURCE, "subscriptions?api-version=#{api_version}")

        response = ArmrestService.rest_get(
          url,
          :content_type  => content_type,
          :authorization => token
        )

        hash = JSON.parse(response)['value'].first

        raise ArgumentError, 'No associated subscription found' if hash.empty?

        @subscription_id = hash.fetch('subscriptionId')
        @subscriptions[cache_key] << @subscription_id
      end
    end
  end
end
