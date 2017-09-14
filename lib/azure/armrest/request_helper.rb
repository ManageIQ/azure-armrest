module Azure
  module Armrest
    module RequestHelper
      def rest_execute(path, query, http_method = :get)
        configuration.token # Ensure token up to date
        configuration.connection.request(:method => http_method, :path => path, :query => query)
      end

      def rest_get(path, query)
        rest_execute(path, query) 
      end
    end
  end
end
