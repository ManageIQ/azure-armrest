module Azure
  module Armrest
    module Sql
      class PostgresqlServerService < ResourceGroupBasedService
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'servers', 'Microsoft.DBforPostgreSQL', options)
        end
      end
    end
  end
end
