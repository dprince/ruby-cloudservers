require File.dirname(__FILE__) + '/test_helper'

class OpenStackComputeConnectionTest < Test::Unit::TestCase

  def setup
    connection = stub()
    OpenStackCompute::Authentication.stubs(:new).returns(connection)
  end
  
  def test_init_connection_no_credentials
    assert_raises(OpenStackCompute::Exception::MissingArgument) do
      conn = OpenStackCompute::Connection.new(:api_key => "AABBCCDD11", :api_url => "a.b.c")
    end
  end

  def test_init_connection_no_password
    assert_raises(OpenStackCompute::Exception::MissingArgument) do
      conn = OpenStackCompute::Connection.new(:username => "test_account", :api_url => "a.b.c")
    end
  end

  def test_init_connection_no_api_url
    assert_raises(OpenStackCompute::Exception::MissingArgument) do
      conn = OpenStackCompute::Connection.new(:username => "test_account", :api_key => "AABBCCDD11")
    end
  end

  def test_init_connection_bad_api_url
    assert_raises(OpenStackCompute::Exception::InvalidArgument) do
      conn = OpenStackCompute::Connection.new(:username => "test_account", :api_key => "AABBCCDD11", :api_url => "***")
    end
  end

  def test_init_connection
      conn = OpenStackCompute::Connection.new(:username => "test_account", :api_key => "AABBCCDD11", :api_url => "https://a.b.c")
      assert_not_nil conn, "Connection.new returned nil."
  end
    
end
