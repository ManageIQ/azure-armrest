module Azure
  module Armrest
    module RequestHelper
      private

      def rest_execute(path, query, http_method = :get, body = nil)
        configuration.token # Ensure token up to date
        path = path.chop if path[-1] == '/' # Trailing slashes can cause problems

        options = {
          :method         => http_method,
          :path           => path,
          :idempotent     => true,
          :retry_limit    => 3,
          :retry_interval => 5
        }

        options[:body] = body if body
        options[:query] = query if query

        response = configuration.connection.request(options)

        raise_api_exception(response) if response.status > 299

        response
      end

      def rest_get(path, query = nil)
        query ||= build_query_hash
        rest_execute(path, query) 
      end

      def rest_post(path, query = nil, body = nil)
        query ||= build_query_hash
        rest_execute(path, query, :post, body)
      end

      def rest_patch(path, query = nil, body = nil)
        query ||= build_query_hash
        rest_execute(path, query, :patch, body)
      end

      def rest_delete(path, query = nil)
        query ||= build_query_hash
        rest_execute(path, query, :delete)
      end

      def rest_put(path, query = nil, body = nil)
        query ||= build_query_hash
        rest_execute(path, query, :put, body)
      end

      def rest_head(path, query = nil)
        query ||= build_query_hash
        rest_execute(path, query, :head)
      end

      def raise_api_exception(response)
        exception_type = Azure::Armrest::EXCEPTION_MAP[response.status]
        exception_type ||= Azure::Armrest::ApiException

        error = JSON.parse(response.body)['error'] rescue nil

        if error && error['code']
          message = error['code'].to_s + ' - ' + error['message'].to_s
        else
          message = response.body.blank? ? response.status_line : response.body
        end

        raise exception_type.new(response.status, response.reason_phrase, message)
      end

      def build_query_hash(hash = {})
        hash['api-version'] ||= api_version if respond_to?(:api_version)

        token = hash.delete(:continuation_token) || {}

        hash.map do |key, value|
          key = key.to_s.downcase
          if ['select', 'top', 'expand', 'filter', 'skiptoken'].include?(key)
            key = "$#{key}"
          end
          [key, value]
        end.to_h.merge(token)
      end

      def build_path(resource_group = nil, *args)
        url = File.join('', 'subscriptions', configuration.subscription_id)
        url = File.join(url, 'resourceGroups', resource_group) if resource_group
        File.join(url, 'providers', provider, service_name, args)
      end
    end # RequestHelper
  end # Armrest
end # Azure
