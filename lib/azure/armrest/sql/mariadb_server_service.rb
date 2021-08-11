module Azure
  module Armrest
    module Sql
      class MariadbServerService < ResourceGroupBasedService
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'servers', 'Microsoft.DBforMariaDB', options)
        end
      end
    end
  end
end
