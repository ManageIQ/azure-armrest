module Azure
  module Armrest
    module Sql
      class MysqlDatabaseService < ResourceGroupBasedSubservice
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'servers', 'databases', 'Microsoft.DBforMySQL', options)
        end
      end
    end
  end
end
