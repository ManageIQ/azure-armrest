module Azure
  module ArmRest
    # Abstract base class for the other manager classes.
    class ArmRestManager

      # The subscription ID (billing unit) for your Azure services
      attr_accessor :subscription_id

      # The resource group within the subscription.
      attr_accessor :resource_group

      # The API version of the REST interface. The default is 2015-1-1.
      attr_accessor :api_version

      # RESTful resource
      attr_accessor :uri

      # The bearer token set in the constructor.
      attr_accessor :token

      # The content-type use for requests.
      attr_reader :content_type

      # Do not instantiate directly. This is an abstract base class from which
      # all other manager classes should subclass, and call super within their
      # own constructors.
      #
      # The possible options to the constructor are:
      #
      # * subscription_id - Your Azure subscription ID. If no subscription
      #     is specifified, then information for all subscriptions will be
      #     collected.
      #
      # * resource_group - The resource group within the subscription. If no
      #     resource group is specified, then information for all resource
      #     groups will be gathered.
      #
      # * client_id - Your Azure client ID. Mandatory.
      #
      # * client_key - The key (secret) for your client ID. Mandatory.
      #
      # * tenant_id - Your Azure tenant ID. Mandatory.
      #
      # * api_version - The REST API version to use for internal REST calls.
      #     The default is '2015-01-01'. You will typically not set this
      #     as it could cause breakage.
      #
      def initialize(options = {})
        # Mandatory params
        @client_id  = options.fetch(:client_id)
        @client_key = options.fetch(:client_key)
        @tenant_id  = options.fetch(:tenant_id)

        # Optional params
        @subscription_id = options[:subscription_id]
        @resource_group  = options[:resource_group]
        @api_version     = options[:api_version] || '2015-01-01'

        # Get token, re-use it for other objects.
        token_url = Azure::ArmRest::AUTHORITY + @tenant_id + "/oauth2/token"

        resp = RestClient.post(
          token_url,
          :grant_type    => 'client_credentials',
          :client_id     => @client_id,
          :client_secret => @client_key,
          :resource      => Azure::ArmRest::RESOURCE
        )

        # TODO: Allow other token types?
        @token = 'Bearer ' + JSON.parse(resp)['access_token']

        @content_type = 'application/json'
      end

      # Returns a list of subscriptions for the tenant.
      #
      def subscriptions
        url = Azure::ArmRest::RESOURCE + "subscriptions" + "?api-version=#{api_version}"

        resp = RestClient.get(
          url,
          :content_type  => @content_type,
          :authorization => @token
        )

        JSON.parse(resp.body)["value"]
      end

      private

      # REST verb methods

      def rest_get(url)
        resp = RestClient.get(
          url,
          :content_type  => 'application/json',
          :authorization => 'Bearer ' + @token
        )
      end

    end # ArmRestManager
  end # ArmRest
end # Azure
