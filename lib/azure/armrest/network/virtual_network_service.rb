module Azure
  module Armrest
    module Network
      # Class for managing virtual networks.
      class VirtualNetworkService < ResourceGroupBasedService

        # Creates and returns a new VirtualNetworkService instance.
        #
        def initialize(_armrest_configuration, options = {})
          super
          @provider = options[:provider] || 'Microsoft.Network'
          @service_name = 'virtualNetworks'
          set_service_api_version(options, @service_name)
        end
      end
    end # Network
  end # Armrest
end # Azure
