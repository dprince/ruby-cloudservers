require File.dirname(__FILE__) + '/test_helper'

class CloudServersServersTest < Test::Unit::TestCase

  include TestConnection

  def setup
    @conn=get_test_connection
  end
  
  def test_list_servers

json_response = %{{
  "servers" : [
      {
     "id" : 1234,
      "name" : "sample-server",
      "imageId" : 2,
      "flavorId" : 1,
      "hostId" : "e4d909c290d0fb1ca068ffaddf22cbd0",
      "status" : "BUILD",
      "progress" : 60,
      "addresses" : {
          "public" : [
              "67.23.10.132",
              "67.23.10.131"
          ],
          "private" : [
              "10.176.42.16"
          ]
      },
      "metadata" : {
          "Server Label" : "Web Head 1",
          "Image Version" : "2.1"
      }
      },
      {
    "id" : 5678,
      "name" : "sample-server2",
      "imageId" : 2,
      "flavorId" : 1,
      "hostId" : "9e107d9d372bb6826bd81d3542a419d6",
      "status" : "ACTIVE",
      "addresses" : {
          "public" : [
              "67.23.10.133"
          ],
          "private" : [
              "10.176.42.17"
          ]
      },
      "metadata" : {
          "Server Label" : "DB 1"
      }
      }
  ]
}}
    response = mock()
    response.stubs(:code => "200", :body => json_response)

    @conn.stubs(:csreq).returns(response)
    servers=@conn.list_servers

    assert_equal 2, servers.size
    assert_equal 1234, servers[0][:id]
    assert_equal "sample-server", servers[0][:name]

  end

  def test_get_server

    server=get_test_server
    assert "sample-server", server.name
    assert "2", server.imageId
    assert "1", server.flavorId
    assert "e4d909c290d0fb1ca068ffaddf22cbd0", server.hostId
    assert "BUILD", server.status
    assert "60", server.progress
    assert "67.23.10.132", server.addresses[:public][0]
    assert "67.23.10.131", server.addresses[:public][1]
    assert "10.176.42.16", server.addresses[:private][1]

  end

  def test_share_ip

    server=get_test_server
    response = mock()
    response.stubs(:code => "200")

    @conn.stubs(:csreq).returns(response)

    assert server.share_ip(:sharedIpGroupId => 100, :ipAddress => "67.23.10.132")
  end

  def test_share_ip_requires_shared_ip_group_id

    server=get_test_server

    assert_raises(CloudServers::Exception::MissingArgument) do
      assert server.share_ip(:ipAddress => "67.23.10.132")
    end

  end

  def test_share_ip_requires_ip_address

    server=get_test_server

    assert_raises(CloudServers::Exception::MissingArgument) do
      assert server.share_ip(:sharedIpGroupId => 100)
    end

  end

  def test_unshare_ip

    server=get_test_server
    response = mock()
    response.stubs(:code => "200")

    @conn.stubs(:csreq).returns(response)

    assert server.unshare_ip(:ipAddress => "67.23.10.132")

  end

  def test_unshare_ip_requires_ip_address

    server=get_test_server

    assert_raises(CloudServers::Exception::MissingArgument) do
      assert server.share_ip({})
    end

  end

private
  def get_test_server

json_response = %{{
  "server" : {
      "id" : 1234,
      "name" : "sample-server",
      "imageId" : 2,
      "flavorId" : 1,
      "hostId" : "e4d909c290d0fb1ca068ffaddf22cbd0",
      "status" : "BUILD",
      "progress" : 60,
      "addresses" : {
          "public" : [
               "67.23.10.132",
               "67.23.10.131"
          ],
          "private" : [
               "10.176.42.16"
          ]
      },
      "metadata" : {
          "Server Label" : "Web Head 1",
          "Image Version" : "2.1"
      }
  }
}}

    response = mock()
    response.stubs(:code => "200", :body => json_response)

    @conn=get_test_connection

    @conn.stubs(:csreq).returns(response)
    return @conn.server(1234) 

  end

end
