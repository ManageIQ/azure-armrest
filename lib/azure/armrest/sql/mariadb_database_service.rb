module Azure
  module Armrest
    module Sql
      class MariadbDatabaseService < ResourceGroupBasedSubservice
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'servers', 'databases', 'Microsoft.DBforMariaDB', options)
        end
      end
    end
  end
end
