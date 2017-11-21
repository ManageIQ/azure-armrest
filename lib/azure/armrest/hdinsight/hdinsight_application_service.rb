module Azure
  module Armrest
    module HDInsight
      class HDInsightApplicationService < ResourceGroupBasedSubservice
        def initialize(armrest_configuration, options = {})
          super(armrest_configuration, 'clusters', 'applications', 'Microsoft.HDInsight', options)
        end
      end
    end
  end
end
