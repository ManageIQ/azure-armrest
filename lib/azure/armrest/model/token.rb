module Azure
  module Armrest
    class Token < BaseModel
      def bearer_token
        "Bearer #{access_token}"
      end

      def expiration
        Time.at(expires_on.to_i).utc
      end
    end
  end
end
