module CloudServers
  class Authentication
    def initialize(connection)
      path = '/v1.0'
      hdrhash = { "X-Auth-User" => connection.authuser, "X-Auth-Key" => connection.authkey }
      begin
        server = Net::HTTP.new('auth.api.rackspacecloud.com',443)
        server.use_ssl = true
        server.verify_mode = OpenSSL::SSL::VERIFY_NONE
        server.start
      rescue
        raise ConnectionException, "Unable to connect to #{server}"
      end
      response = server.get(path,hdrhash)
      if (response.code == "204")
        connection.authtoken = response["x-auth-token"]
        connection.svrmgmthost = URI.parse(response["x-server-management-url"]).host
        connection.svrmgmtpath = URI.parse(response["x-server-management-url"]).path
        connection.svrmgmtport = URI.parse(response["x-server-management-url"]).port
        connection.svrmgmtscheme = URI.parse(response["x-server-management-url"]).scheme
        connection.authok = true
      else
        connection.authtoken = false
        raise AuthenticationException, "Authentication failed"
      end
      server.finish
    end
  end
end