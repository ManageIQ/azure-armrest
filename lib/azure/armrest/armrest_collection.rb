# Custom array class we use in order to track extra attributes
# on a collection of results.
module Azure
  module Armrest
    class ArmrestCollection < Array
      attr_accessor :next_link
      attr_accessor :continuation_token
      attr_accessor :response_headers
      attr_accessor :response_code

      alias skip_token continuation_token
      alias skip_token= continuation_token=

      class << self
        # Creates and returns a ArmrestCollection object based on JSON input,
        # using +klass+ to generate the list elements. In addition, both the
        # response headers and continuation token are set.
        #
        def create_from_response(response, klass = nil)
          json_response = JSON.parse(response)
          array = new(json_response['value'].map { |hash| klass.new(hash) })

          array.response_code = response.code
          array.response_headers = response.headers
          array.next_link = json_response['nextLink']
          array.continuation_token = parse_skip_token(array.next_link)

          array
        end

        private

        # Parse the skip token value out of the nextLink attribute from a response.
        def parse_skip_token(next_link)
          return nil unless next_link
          next_link[/.*?skipToken=(.*?)$/i, 1]
        end
      end
    end
  end
end
