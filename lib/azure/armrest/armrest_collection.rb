# Custom array class we use in order to track extra attributes
# on a collection of results.
module Azure
  module Armrest
    class ArmrestCollection < Array
      attr_accessor :continuation_token
      attr_accessor :response_headers

      # Creates and returns a ArmrestCollection object based on JSON input,
      # using +klass+ to generate the list elements. In addition, both the
      # response headers and continuation token are set.
      #
      # You may optionally pass a plain array instead, in which case you
      # get back an array re-wrapped as an ArmrestCollection object, but
      # the response_headers and continuation_token properties are not set
      # automatically.
      #
      def initialize(response, klass = nil)
        if response.kind_of?(Array)
          super(response)
        else
          json_response = JSON.parse(response)
          @response_headers = response.headers
          @continuation_token = parse_skip_token(json_response)
          super(json_response['value'].map { |hash| klass.new(hash) })
        end
      end

      alias skip_token continuation_token
      alias skip_token= continuation_token=

      private

      # Parse the skip token value out of the nextLink attribute from a response.
      def parse_skip_token(json)
        return nil unless json['nextLink']
        json['nextLink'][/.*?skipToken=(.*?)$/i, 1]
      end
    end
  end
end
