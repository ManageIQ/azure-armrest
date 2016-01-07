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

      # The subscription ID used in requests and to gather token information.
      attr_accessor :subscription_id

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

        if @token.nil? || Time.now.utc > @token_expiration.utc
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
      # cache_key if no key is specified. If the value is nil, return
      # the epoch time.
      #
      def token_expiration(key = nil)
        key ? @@tokens[key].last : @@tokens[cache_key].last
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
    end
  end
end
