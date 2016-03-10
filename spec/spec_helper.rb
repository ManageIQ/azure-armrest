require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'azure-armrest'

@@providers_hash = {'name' => {}}

def setup_params
  @sub = 'abc-123-def-456'
  @res = 'my_resource_group'
  @cid = "XXXXX"
  @key = "YYYYY"
  @ten = "ZZZZZ"
  @tok = "TTTTT"

  @ver = "2015-01-01"

  @conf = Azure::Armrest::ArmrestService.configure(
    :subscription_id  => @sub,
    :resource_group   => @res,
    :client_id        => @cid,
    :client_key       => @key,
    :tenant_id        => @ten,
    :token            => @tok,
    :token_expiration => Time.now + 3600
  )

  @req = {
    :method      => :get,
    :proxy       => nil,
    :ssl_verify  => nil,
    :ssl_version => 'TLSv1',
    :headers => {
      :accept        => "application/json",
      :content_type  => "application/json",
      :authorization => @tok
    }
  }
end
