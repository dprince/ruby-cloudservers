module CloudServers
  class Connection
    
    attr_reader   :authuser
    attr_accessor :authtoken
    attr_reader   :authkey
    attr_accessor :authok
    attr_accessor :svrmgmthost
    attr_accessor :svrmgmtpath
    attr_accessor :svrmgmtport
    attr_accessor :svrmgmtscheme
    
    # Creates a new CloudFiles::Connection object.  Uses CloudFiles::Authentication to perform the login for the connection.
    # The authuser is the Rackspace Cloud username, the authkey is the Rackspace Cloud API key.
    #
    # Setting the optional retry_auth variable to false will cause an exception to be thrown if your authorization token expires.
    # Otherwise, it will attempt to reauthenticate.
    #
    # Setting the optional snet variable to true or setting an environment variable of RACKSPACE_SERVICENET to any value will cause 
    # storage URLs to be returned with a prefix pointing them to the internal Rackspace service network, instead of a public URL.  
    #
    # This is useful if you are using the library on a Rackspace-hosted system, as it provides faster speeds, keeps traffic off of
    # the public network, and the bandwidth is not billed.
    #
    # This will likely be the base class for most operations.
    #
    #   cf = CloudFiles::Connection.new(MY_USERNAME, MY_API_KEY)
    def initialize(authuser,authkey,retry_auth = true,snet=false) 
      @authuser = authuser
      @authkey = authkey
      @retry_auth = retry_auth
      @snet = (ENV['RACKSPACE_SERVICENET'] || snet) ? true : false
      @authok = false
      @http = {}
      CloudServers::Authentication.new(self)
    end
    
    # Returns true if the authentication was successful and returns false otherwise.
    #
    #   cs.authok?
    #   => true
    def authok?
      @authok
    end
    
    # This method actually makes the HTTP calls out to the server
    def csreq(method,server,path,port,scheme,headers = {},attempts = 0) # :nodoc:
      start = Time.now
      hdrhash = headerprep(headers)
      start_http(server,path,port,scheme,hdrhash)
      request = Net::HTTP.const_get(method.to_s.capitalize).new(path,hdrhash)
      response = @http[server].request(request)
      raise ExpiredAuthTokenException if response.code == "401"
      response
    rescue Errno::EPIPE, Timeout::Error, Errno::EINVAL, EOFError
      # Server closed the connection, retry
      raise ConnectionException, "Unable to reconnect to #{server} after #{count} attempts" if attempts >= 5
      attempts += 1
      @http[server].finish
      start_http(server,path,port,scheme,headers)
      retry
    rescue ExpiredAuthTokenException
      raise ConnectionException, "Authentication token expired and you have requested not to retry" if @retry_auth == false
      CloudFiles::Authentication.new(self)
      retry
    end
    
    def servers
      response = csreq("GET",svrmgmthost,"#{svrmgmtpath}/servers",svrmgmtport,svrmgmtscheme)
      raise InvalidResponseException, "Invalid response code #{response.code}" unless (response.code.match(/^20.$/))
      JSON.parse(response.body)["servers"]
    end
    
    def servers_detail
      response = csreq("GET",svrmgmthost,"#{svrmgmtpath}/servers/detail",svrmgmtport,svrmgmtscheme)
      raise InvalidResponseException, "Invalid response code #{response.code}" unless (response.code.match(/^20.$/))
      JSON.parse(response.body)["servers"]
    end
    
    private
    
    # Sets up standard HTTP headers
    def headerprep(headers = {}) # :nodoc:
      default_headers = {}
      default_headers["X-Auth-Token"] = @authtoken if (authok? && @account.nil?)
      default_headers["X-Storage-Token"] = @authtoken if (authok? && !@account.nil?)
      default_headers["Connection"] = "Keep-Alive"
      default_headers["User-Agent"] = "CloudServers Ruby API #{VERSION}"
      default_headers.merge(headers)
    end
    
    # Starts (or restarts) the HTTP connection
    def start_http(server,path,port,scheme,headers) # :nodoc:
      if (@http[server].nil?)
        begin
          @http[server] = Net::HTTP.new(server,port)
          if scheme == "https"
            @http[server].use_ssl = true
            @http[server].verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          @http[server].start
        rescue
          raise ConnectionException, "Unable to connect to #{server}"
        end
      end
    end
    
    
  end
end