module Azure
  module Armrest
    module Insights
      # Base class for managing diagnostics
      class DiagnosticService < ArmrestService
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'diagnosticSettings', 'Microsoft.Insights', options)
        end

        def get(resource_id)
          url = build_url(resource_id)
          response = rest_get(url)
          Diagnostic.new(JSON.parse(response))
        end

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

          url += "?api-version=#{api_version}"
        end
      end
    end
  end
end
