module Azure
  module ArmRest
    class ArmRestManager

      attr_accessor :subscription_id
      attr_accessor :resource_group_name
      attr_accessor :api_version

      def initialize(subscription_id, resource_group_name, api_version = '2015-01-01')
        @subscription_id     = subscription_id
        @resource_group_name = resource_group_name
        @api_version         = api_version

        @uri = Azure::ArmRest::COMMON_URI + "/#{@subscription_id}"

      end
    end
  end
end
