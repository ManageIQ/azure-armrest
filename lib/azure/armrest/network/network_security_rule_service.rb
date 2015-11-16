module Azure
  module Armrest
    module Network
      # Base class for managing securityRules
      class NetworkSecurityRuleService < NetworkSecurityGroupService
        # Creates a new +rule_name+ on +security_group+ using the given +options+.
        def create(rule_name, security_group, resource_group = armrest_configuration.resource_group, options = {})
          super(combine(security_group, rule_name), resource_group, options)
        end

        alias update create

        # Deletes the given +rule_name+ in +security_group+.
        #
        def delete(rule_name, security_group, resource_group = armrest_configuration.resource_group)
          super(combine(security_group, rule_name), resource_group)
        end

        # Retrieves information for the provided +rule_name+ in +security_group+ for
        # the current subscription.
        #
        def get(rule_name, security_group, resource_group = armrest_configuration.resource_group)
          super(combine(security_group, rule_name), resource_group)
        end

        # List available security rules on +security_group+ for the given +resource_group+.
        #
        def list(security_group, resource_group = armrest_configuration.resource_group)
          raise ArgumentError, "must specify resource group" unless resource_group
          raise ArgumentError, "must specify name of the resource" unless security_group

          url = build_url(resource_group, security_group, 'securityRules')
          response = rest_get(url)
          JSON.parse(response)['value'].map{ |hash| model_class.new(hash) }
        end

        alias list_all list

        private

        def combine(virtual_network, subnet)
          File.join(virtual_network, 'securityRules', subnet)
        end
      end
    end # Network
  end # Armrest
end # Azure
