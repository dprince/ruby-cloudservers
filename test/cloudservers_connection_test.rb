$:.unshift File.dirname(__FILE__)
require 'test_helper'

class CloudServersConnectionTest < Test::Unit::TestCase

  def setup
    connection = stub()
    CloudServers::Authentication.stubs(:new).returns(connection)
  end
  
  def test_init_connection_no_credentials
    assert_raises(CloudServers::Exception::Authentication) do
      conn = CloudServers::Connection.new(:api_key => "AABBCCDD11")
    end
  end

  def test_init_connection_no_password
    assert_raises(CloudServers::Exception::Authentication) do
      conn = CloudServers::Connection.new(:username => "test_account")
    end
  end

  def test_init_connection_bad_auth_url
    assert_raises(CloudServers::Exception::InvalidArgument) do
      conn = CloudServers::Connection.new(:username => "test_account", :api_key => "AABBCCDD11", :auth_url => "***")
    end
  end

  def test_init_connection
      conn = CloudServers::Connection.new(:username => "test_account", :api_key => "AABBCCDD11", :auth_url => "https://a.b.c")
      assert_not_nil conn, "Connection.new returned nil."
  end

  def test_init_connection_with_custom_auth_url
      conn = CloudServers::Connection.new(:username => "test_account", :api_key => "AABBCCDD11", :auth_url => CloudServers::AUTH_UK)
      assert_not_nil conn, "Connection.new returned nil."
  end
    
end
