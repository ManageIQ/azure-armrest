module Azure
  module Armrest
    class Exception < StandardError
      attr_accessor :cause
      attr_writer :message

      # Create a new Armrest::Exception object. The +message+ should be an
      # error string, while +cause_exception+ is typically set to the
      # raw RestClient exception.
      #
      # You will not typically use this object directly.
      #
      def initialize(message = nil, cause_exception = nil)
        @message = message
        @cause = cause_exception
      end

      # The stringified version (message) of the exception.
      #
      def to_s
        if cause
          "#{message} (cause: #{cause})"
        else
          message
        end
      end

      # The error message or, if the message is not set, the name of the
      # exception class.
      #
      def message
        @message || self.class.name
      end
    end

    class ApiException < Exception
      attr_accessor :code

      # Create a new ApiException class. The +code+ is the error code.
      #
      # This class serves as the parent
      def initialize(code, message, cause_exception)
        @code = code
        super(message, cause_exception)
      end

      # A stringified version of the error. If self is a plain ApiException,
      # then the cause is included to aid in debugging.
      #
      def to_s
        "[#{code}] #{super}"
      end
    end

    # A list of predefined exceptions that we wrap around RestClient exceptions.

    class ResourceNotFoundException < ApiException; end

    class BadRequestException < ApiException; end

    class UnauthorizedException < ApiException; end

    class BadGatewayException < ApiException; end

    class GatewayTimeoutException < ApiException; end

    class TooManyRequestsException < ApiException; end

  end
end
