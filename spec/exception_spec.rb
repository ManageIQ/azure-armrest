########################################################################
# exception_spec.rb
#
# Test suite for the Azure::Armrest::Exception class and
# Azure::Armrest::ApiException subclass.
########################################################################
require 'spec_helper'

describe Azure::Armrest::Exception do
  before { setup_params }

  let(:message) { 'test message' }
  let(:code)    { 'ResourceNotFound' }
  let(:cause)   { '404 Not Found' }

  context "constructor" do
    it "may be instantiated with no arguments" do
      expect(described_class.new).to be_kind_of(Azure::Armrest::Exception)
    end

    it "may include an optional message" do
      error = described_class.new(message)
      expect(error.message).to eql(message)
    end

    it "uses the class name for the message if not defined" do
      error = described_class.new
      expect(error.message).to eql(described_class.name)
    end

    it "may include an optional cause" do
      error = described_class.new(message, cause)
      expect(error.cause).to eql(cause)
    end

    it "defines to_s and returns the message" do
      error = described_class.new(message, cause)
      expect(error.to_s).to eql("#{message} (cause: #{error.cause})")
    end
  end

  context "ApiException subclass" do
    subject { Azure::Armrest::ApiException.new(code, message, cause) }

    it "is a subclass of Armrest::Exception" do
      expect(subject).to be_kind_of(Azure::Armrest::Exception)
    end

    it "defines a code accessor that returns the expected value" do
      expect(subject).to respond_to(:code)
      expect(subject.code).to eql(code)
    end

    it "defines a code message that returns the expected value" do
      expect(subject).to respond_to(:message)
      expect(subject.message).to eql(message)
    end

    it "defines a cause message that returns the expected value" do
      expect(subject).to respond_to(:cause)
      expect(subject.cause).to eql(cause)
    end

    it "defines a custom to_s method that returns the expected result" do
      string = "[#{subject.code}] #{subject.message} (cause: #{subject.cause})"
      expect(subject.to_s).to eql(string)
    end
  end

  context "subclasses of ApiException" do
    it "defines the expected subclasses" do
      expect(Azure::Armrest::ResourceNotFoundException).to_not be_nil
      expect(Azure::Armrest::BadRequestException).to_not be_nil
      expect(Azure::Armrest::UnauthorizedException).to_not be_nil
      expect(Azure::Armrest::BadGatewayException).to_not be_nil
      expect(Azure::Armrest::GatewayTimeoutException).to_not be_nil
      expect(Azure::Armrest::TooManyRequestsException).to_not be_nil
    end
  end
end
