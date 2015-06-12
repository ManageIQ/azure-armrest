require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'azure-armrest'

def setup_params
  @sub = 'abc-123-def-456'
  @res = 'my_resource_group'
  @cid = "XXXXX"
  @key = "YYYYY"
  @ten = "ZZZZZ"

  @ver = "2015-01-01"

  @params = {
    :subscription_id => @sub,
    :resource_group  => @res,
    :client_id       => @cid,
    :client_key      => @key,
    :tenant_id       => @ten,
  }
end
