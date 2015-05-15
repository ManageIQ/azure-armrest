module Azure
  module ArmRest
    class VirtualMachineManager
      COMMON_URI = "https://management.azure.com/subscriptions"

      VALID_VM_SIZES = %w[
        Standard_A0
        Standard_A1
        Standard_A2
        Standard_A3
        Standard_A4
      ]

      attr_accessor :subscription_id
      attr_accessor :resource_group_name
      attr_accessor :uri
      attr_accessor :api_version

      def initialize(subscription_id, resource_group_name, api_version = '2015-01-01')
        @subscription_id = subscription_id
        @resource_group_name = resource_group_name
        @api_version = api_version

        @uri = COMMON_URI + "/#{subscription_id}"
        @uri += "/resourceGroups/#{resource_group_name}"
        @uri += "/providers/Microsoft.Compute/VirtualMachines"
      end

      # POST
      def capture
      end

      # PUT
      def create(options = {})
      end

      alias update create

      def deallocate
      end

      # DELETE
      def delete
      end

      # POST
      def generalize
      end

      # GET
      def get(model_view = true)
      end

      # GET
      def operations
      end

      # POST
      def restart
      end

      # POST
      def start
      end

      # POST
      def stop
      end
    end
  end
end
