module Azure
  module ArmRest
    # Abstract base class for the other manager classes.
    class ArmRestManager

      # The subscription ID (billing unit) for your Azure services
      attr_accessor :subscription_id

      # The resource group within the subscription.
      attr_accessor :resource_group_name

      # The API version of the REST interface. The default is 2015-1-1.
      attr_accessor :api_version

      # RESTful resource
      attr_accessor :uri

      # Do not instantiate directly. This is an abstract base class from which
      # all other manager classes should subclass, and call super within their
      # own constructors.
      #
      def initialize(subscription_id, resource_group_name, api_version = '2015-01-01')
        @subscription_id     = subscription_id
        @resource_group_name = resource_group_name
        @api_version         = api_version

        @uri = Azure::ArmRest::COMMON_URI + "/#{@subscription_id}"
      end
    end
  end
end
