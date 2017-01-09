module Azure
  module Armrest
    class ActiveDirectoryConfiguration < Azure::Armrest::Configuration
      clear_caches

      # A subclass of the base Configuration class, this uses different
      # endpoints to obtain an authorization token. This configuration
      # object should be used for any ActiveDirectory service classes.
      #
      def initialize(args)
        options = args.symbolize_keys

        @tenant_id       = options[:tenant_id]
        @client_id       = options[:client_id]
        @client_key      = options[:client_key]
        @subscription_id = options.delete(:subscription_id)

        unless client_id && client_key && tenant_id
          raise ArgumentError, "client_id, client_key, and tenant_id must all be specified"
        end

        @environment     = options[:environment] || Azure::Armrest::Environment::Public
        @grant_type      = options[:grant_type]  || 'client_credentials'
        @proxy           = options[:proxy]       || ENV['http_proxy']
        @ssl_version     = options[:ssl_version] || 'TLSv1'

        # Fetch and set the token and token expiration before calling super
        # so that it doesn't try to fetch it again from the wrong resource.

        unless options[:token] || options[:token_expiration]
          fetch_token
          options[:token] = @token
          options[:token_expiration] = @token_expiration
        end

        super(options) 
      end

      private

      def fetch_token
        token_url = File.join(environment.active_directory_authority, tenant_id, 'oauth2', 'token')
        get_token(token_url, environment.graph_url)
      end
    end
  end
end
