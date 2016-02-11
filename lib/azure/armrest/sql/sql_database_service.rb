module Azure
  module Armrest
    module Sql
      class SqlDatabaseService < ResourceGroupBasedSubservice
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'servers', 'databases', 'Microsoft.Sql', options)
        end
      end
    end
  end
end
