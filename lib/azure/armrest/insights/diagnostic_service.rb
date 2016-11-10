module Azure
  module Armrest
    module Insights
      # Base class for managing diagnostics
      class DiagnosticService < ArmrestService
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'diagnosticSettings', 'Microsoft.Insights', options)
        end

        # Get diagnostic information for the given +resource_id+. Note that
        # this information is only available for a limited subset of resources.
        #
        # Example:
        #
        # ids = Azure::Armrest::Insights::DiagnosticService.new(config)
        # nsg = Azure::Armrest::Network::NetworkSecurityGroupService.new(config)
        #
        # sgrp = nsg.get(your_security_group, your_resource_group)
        # p ids.get(sgrp.id)
        #
        def get(resource_id)
          url = build_url(resource_id)
          response = rest_get(url)
          Diagnostic.new(JSON.parse(response))
        end

        # Create or update a diagnostic setting for the given +resource_id+.
        #
        # Example:
        #
        # # Update network security group log settings
        # ids = Azure::Armrest::Insights::DiagnosticService.new(config)
        # sas = Azure::Armrest::StorageAccountService.new(config)
        # nsg = Azure::Armrest::Network::NetworkSecurityGroupService.new(config)
        #
        # acct = sas.get(your_storage, your_resource_group)
        # sgrp = nsg.get(your_network_security_group, your_resource_group)
        #
        # options = {
        #   :properties => {
        #     :storageAccountId => acct.id,
        #     :logs => [
        #       {
        #         :category => "NetworkSecurityGroupEvent",
        #         :enabled  => true,
        #         :retentionPolicy => {
        #           :enabled => true,
        #           :days    => 3
        #         }
        #       },
        #       {
        #         :category => "NetworkSecurityGroupRuleCounter",
        #         :enabled  => true,
        #         :retentionPolicy => {
        #           :enabled => true,
        #           :days    => 3
        #         }
        #       }
        #     ]
        #   }
        # }
        #
        # ids.set(sgrp.id, options)
        #
        def create(resource_id, options = {})
          url = build_url(resource_id)
          body = options.merge(:id => resource_id).to_json
          response = rest_put(url, body)

          headers = Azure::Armrest::ResponseHeaders.new(response.headers)
          headers.response_code = response.code

          headers
        end

        alias update create
        alias set create

        private

        def build_url(resource_id)
          url = File.join(
            Azure::Armrest::RESOURCE,
            resource_id,
            'providers',
            provider,
            'diagnosticSettings',
            'service'
          )

          url + "?api-version=#{api_version}"
        end
      end
    end
  end
end
