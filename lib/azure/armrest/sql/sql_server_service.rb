module Azure
  module Armrest
    module Sql
      class SqlServerService < ResourceGroupBasedService
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'servers', 'Microsoft.Sql', options)
        end
      end
    end
  end
end
