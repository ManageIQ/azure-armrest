module Azure
  module Armrest
    module Sql
      class MysqlServerService < ResourceGroupBasedService
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'servers', 'Microsoft.DBforMySQL', options)
        end
      end
    end
  end
end
