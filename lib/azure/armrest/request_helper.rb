module Azure
  module Armrest
    module RequestHelper
      def rest_execute(path, query, http_method = :get, body = nil)
        configuration.token # Ensure token up to date

        response = configuration.connection.request(:method => http_method, :path => path, :query => query, :body => body)

        raise_api_exception(response) if response.status > 299

        response
      end

      def rest_get(path, query)
        rest_execute(path, query) 
      end

      def rest_post(path, query, body = nil)
        rest_execute(path, query, :post, body)
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

      def raise_api_exception(response)
        exception_type = Azure::Armrest::EXCEPTION_MAP[response.status]
        exception_type ||= Azure::Armrest::ApiException
        error = JSON.parse(response.body)['error']

        if error && error['code']
          message = error['code'].to_s + ' - ' + error['message'].to_s
        else
          message = response.body
        end

        raise exception_type.new(response.status, response.reason_phrase, message)
      end

      def build_query_hash(hash = {})
        hash['api-version'] ||= api_version if respond_to?(:api_version)

        hash.map do |key, value|
          key = key.to_s.downcase
          if ['top', 'expand', 'filter'].include?(key)
            key = "$#{key}"
          end
          [key, value]
        end.to_h
      end
    end # RequestHelper
  end # Armrest
end # Azure
