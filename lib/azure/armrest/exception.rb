module Azure
  module Armrest
    class Exception < StandardError
      attr_accessor :cause
      attr_writer :message

      def initialize(message = nil, cause_exception = nil)
        @message = message
        @cause = cause_exception
      end

      def to_s
        message
      end

      def message
        @message || self.class.name
      end
    end

    class ApiException < Exception
      attr_accessor :code

      def initialize(code, message, cause_exception)
        @code = code
        super(message, cause_exception)
      end

      def to_s
        "[#{code}] #{message}"
      end
    end

    class ResourceNotFoundException < ApiException; end

    class BadRequestException < ApiException; end

    class UnauthorizedException < ApiException; end

    class BadGatewayException < ApiException; end

    class GatewayTimeoutException < ApiException; end

  end
end
