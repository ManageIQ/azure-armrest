module Azure
  module Armrest
    module Network
      # Base class for managing securityRules
      class NetworkSecurityRuleService < ResourceGroupBasedSubservice
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'networkSecurityGroups', 'securityRules', 'Microsoft.Network', options)
        end
      end
    end # Network
  end # Armrest
end # Azure
