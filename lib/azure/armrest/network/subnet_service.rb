module Azure
  module Armrest
    module Network
      # Base class for managing subnets
      class SubnetService < VirtualNetworkService
        # Creates a new +subnet_name+ on +virtual_network+ using the given
        # +options+.  The +options+ argument is a hash that supports the
        # following keys and subkeys.
        #
        # - :properties
        #   - :addressPrefix
        #   - :networkSecurityGroup
        #     - :id
        #   - :routeTable
        #     - :id
        #
        def create(subnet_name, virtual_network, options = {}, resource_group = armrest_configuration.resource_group)
          super(combine(virtual_network, subnet_name), resource_group)
        end

        alias update create

        # Deletes the given +subnet_name+ in +virtual_network+.
        #
        def delete(subnet_name, virtual_network, resource_group = armrest_configuration.resource_group)
          super(combine(virtual_network, subnet_name), resource_group)
        end

        # Retrieves information for the provided +subnet_name+ in +virtual_network+ for
        # the current subscription.
        #
        def get(subnet_name, virtual_network, resource_group = armrest_configuration.resource_group)
          super(combine(virtual_network, subnet_name), resource_group)
        end

        # List available subnets on +virtual_network+ for the given +resource_group+.
        #
        def list(virtual_network, resource_group = armrest_configuration.resource_group)
          raise ArgumentError, "must specify resource group" unless resource_group
          raise ArgumentError, "must specify name of the resource" unless virtual_network

          url = build_url(resource_group, virtual_network, 'subnets')
          response = rest_get(url)
          JSON.parse(response)['value'].map{ |hash| model_class.new(hash) }
        end

        alias list_all list

        private

        def combine(virtual_newtork, subnet)
          File.join(virtual_newtork, 'subnets', subnet)
        end
      end
    end # Network
  end # Armrest
end # Azure
