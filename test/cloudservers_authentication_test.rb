require File.dirname(__FILE__) + '/test_helper'

class CloudserversAuthenticationTest < Test::Unit::TestCase
 
  def test_good_authentication
    response = {'x-server-management-url' => 'http://server-manage.example.com/path', 'x-auth-token' => 'dummy_token'}
    response.stubs(:code).returns('204')
    server = mock(:use_ssl= => true, :verify_mode= => true, :start => true, :finish => true)
    server.stubs(:get).returns(response)
    Net::HTTP.stubs(:new).returns(server)
    connection = stub(:authuser => 'bad_user', :authkey => 'bad_key', :auth_host => "a.b.c", :auth_port => "443", :auth_scheme => "https", :authok= => true, :authtoken= => true, :svrmgmthost= => "", :svrmgmtpath= => "", :svrmgmtpath => "", :svrmgmtport= => "", :svrmgmtscheme= => "", :proxy_host => nil, :proxy_port => nil)
    result = OpenStackCompute::Authentication.new(connection)
    assert_equal result.class, OpenStackCompute::Authentication
  end
  
  def test_bad_authentication
    response = mock()
    response.stubs(:code).returns('499')
    server = mock(:use_ssl= => true, :verify_mode= => true, :start => true)
    server.stubs(:get).returns(response)
    Net::HTTP.stubs(:new).returns(server)
    connection = stub(:authuser => 'bad_user', :authkey => 'bad_key', :auth_host => "a.b.c", :auth_port => "443", :auth_scheme => "https", :authok= => true, :authtoken= => true, :proxy_host => nil, :proxy_port => nil)
    assert_raises(OpenStackCompute::Exception::Authentication) do
      result = OpenStackCompute::Authentication.new(connection)
    end
  end
    
  def test_bad_hostname
    Net::HTTP.stubs(:new).raises(OpenStackCompute::Exception::Connection)
    connection = stub(:authuser => 'bad_user', :authkey => 'bad_key', :auth_host => "a.b.c", :auth_port => "443", :auth_scheme => "https", :authok= => true, :authtoken= => true, :proxy_host => nil, :proxy_port => nil)
    assert_raises(OpenStackCompute::Exception::Connection) do
      result = OpenStackCompute::Authentication.new(connection)
    end
  end
    
end
