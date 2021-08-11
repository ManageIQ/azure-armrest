module Azure
  module Armrest
    module Sql
      class PostgresqlDatabaseService < ResourceGroupBasedSubservice
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'servers', 'databases', 'Microsoft.DBforPostgreSQL', options)
        end
      end
    end
  end
end
