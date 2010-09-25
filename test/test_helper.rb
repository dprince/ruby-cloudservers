require 'test/unit'
$:.unshift File.dirname(__FILE__) + '/../lib'
require 'cloudservers'
require 'rubygems'
require 'mocha'

module TestConnection

def get_test_connection 

    conn_response = {'x-server-management-url' => 'http://server-manage.example.com/path', 'x-auth-token' => 'dummy_token'}
    conn_response.stubs(:code).returns('204')
    #server = mock(:use_ssl= => true, :verify_mode= => true, :start => true, :finish => true)
    server = mock(:start => true, :finish => true)
    server.stubs(:get => conn_response, :use_ssl= => true, :verify_mode= => true)
    #server.stubs(:get).returns(conn_response)
    Net::HTTP.stubs(:new).returns(server)

    CloudServers::Connection.new(:username => "test_account", :api_key => "AABBCCDD11", :api_url => "http://a.b.c")

end

end
