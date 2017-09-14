module Azure
  module Armrest
    module RequestHelper
      def rest_execute(path, query, http_method = :get)
        configuration.token # Ensure token up to date
        configuration.connection.request(:method => http_method, :path => path, :query => query)
      rescue Excon::Error => err
        raise_api_exception(err)
      end

      def rest_get(path, query)
        rest_execute(path, query) 
      end

      def rest_post(path, query)
        rest_execute(path, query, :post)
      end

      def rest_patch(path, query)
        rest_execute(path, query, :patch)
      end

      def rest_delete(path, query)
        rest_execute(path, query, :delete)
      end

      def rest_put(path, query)
        rest_execute(path, query, :put)
      end

      def rest_head(path, query)
        rest_execute(path, query, :head)
      end

      def raise_api_exception(err)
        exception_type = Azure::Armrest::EXCEPTION_MAP[err.response.status]

        # If this is an exception that doesn't map directly to an HTTP code
        # then parse it the exception class name and re-raise it as our own.
        if exception_type.nil?
          begin
            klass = "Azure::Armrest::" + err.class.to_s.split("::").last + "Exception"
            exception_type = const_get(klass)
          rescue NameError
            exception_type = Azure::Armrest::ApiException
          end
        end

        raise exception_type.new(err.response.status, err.response.reason_phrase, err)
      end
    end # RequestHelper
  end # Armrest
end # Azure
