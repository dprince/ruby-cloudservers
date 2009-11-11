module CloudServers
  class Connection
    
    attr_reader   :authuser
    attr_reader   :authkey
    attr_accessor :authtoken
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
    def csreq(method,server,path,port,scheme,headers = {},data = nil,attempts = 0) # :nodoc:
      start = Time.now
      hdrhash = headerprep(headers)
      start_http(server,path,port,scheme,hdrhash)
      request = Net::HTTP.const_get(method.to_s.capitalize).new(path,hdrhash)
      request.body = data
      response = @http[server].request(request)
      raise CloudServers::Exception::ExpiredAuthToken if response.code == "401"
      response
    rescue Errno::EPIPE, Timeout::Error, Errno::EINVAL, EOFError
      # Server closed the connection, retry
      raise CloudServers::Exception::Connection, "Unable to reconnect to #{server} after #{count} attempts" if attempts >= 5
      attempts += 1
      @http[server].finish
      start_http(server,path,port,scheme,headers)
      retry
    rescue CloudServers::Exception::ExpiredAuthToken
      raise CloudServers::Exception::Connection, "Authentication token expired and you have requested not to retry" if @retry_auth == false
      CloudFiles::Authentication.new(self)
      retry
    end
    
    # Returns the CloudServers::Server object identified by the given id.
    def get_server(id)
      CloudServers::Server.new(self,id)
    end
    alias :server :get_server
    
    def list_servers
      response = csreq("GET",svrmgmthost,"#{svrmgmtpath}/servers",svrmgmtport,svrmgmtscheme)
      CloudServers::Exception.raise_exception(response) unless response.code.match(/^20.$/)
      JSON.parse(response.body)["servers"]
    end
    alias :servers :list_servers
    
    def list_servers_detail
      response = csreq("GET",svrmgmthost,"#{svrmgmtpath}/servers/detail",svrmgmtport,svrmgmtscheme)
      CloudServers::Exception.raise_exception(response) unless response.code.match(/^20.$/)
      JSON.parse(response.body)["servers"]
    end
    alias :servers_detail :list_servers_detail
    
    # name, flavorId, and imageId are required.
    # For :personality, pass a hash of the form {'local_path' => 'server_path'}.  The file located at local_path will be base64-encoded
    # and placed at the location identified by server_path on the new server.
    # Returns a CloudServers::Server object.  The root password is available in the adminPass instance method.
    def create_server(options)
      raise CloudServers::Exception::MissingArgument, "Server name, flavor ID, and image ID must be supplied" unless (options[:name] && options[:flavorId] && options[:imageId])
      options[:personality] = get_personality(options[:personality])
      raise TooManyMetadataItems, "Metadata is limited to a total of #{MAX_PERSONALITY_METADATA_ITEMS} key/value pairs" if options[:metadata].is_a?(Hash) && options[:metadata].keys.size > MAX_PERSONALITY_METADATA_ITEMS
      data = JSON.generate(:server => options)
      response = csreq("POST",svrmgmthost,"#{svrmgmtpath}/servers",svrmgmtport,svrmgmtscheme,{'content-type' => 'application/json'},data)
      CloudServers::Exception.raise_exception(response) unless response.code.match(/^20.$/)
      server_info = JSON.parse(response.body)['server']
      server = CloudServers::Server.new(self,server_info['id'])
      server.adminPass = server_info['adminPass']
      return server
    end
    
    # Gives a list of available server images
    def list_images
      response = csreq("GET",svrmgmthost,"#{svrmgmtpath}/images/detail",svrmgmtport,svrmgmtscheme)
      CloudServers::Exception.raise_exception(response) unless response.code.match(/^20.$/)
      return JSON.parse(response.body)['images']
    end
    alias :images :list_images
    
    def get_image(id)
      CloudServers::Image.new(self,id)
    end
    alias :image :get_image
    
    # Gives a list of available server flavors
    def list_flavors
      response = csreq("GET",svrmgmthost,"#{svrmgmtpath}/flavors/detail",svrmgmtport,svrmgmtscheme)
      CloudServers::Exception.raise_exception(response) unless response.code.match(/^20.$/)
      return JSON.parse(response.body)['flavors']
    end
    alias :flavors :list_flavors
    
    def get_flavor(id)
      CloudServers::Flavor.new(self,id)
    end
    alias :flavor :get_flavor
    
    def list_shared_ip_groups
      response = csreq("GET",svrmgmthost,"#{svrmgmtpath}/shared_ip_groups/detail",svrmgmtport,svrmgmtscheme)
      CloudServers::Exception.raise_exception(response) unless response.code.match(/^20.$/)
      return JSON.parse(response.body)['sharedIpGroups']
    end
    alias :shared_ip_groups :list_shared_ip_groups
      
    def get_shared_ip_group(id)
      CloudServers::SharedIPGroup.new(self,id)
    end
    alias :shared_ip_group :get_shared_ip_group
    
    # Options: {:name => 'Group Name', :server => serverId}
    def create_shared_ip_group(options)
      data = JSON.generate(:sharedIpGroup => options)
      response = csreq("POST",svrmgmthost,"#{svrmgmtpath}/shared_ip_groups",svrmgmtport,svrmgmtscheme,{'content-type' => 'application/json'},data)
      CloudServers::Exception.raise_exception(response) unless response.code.match(/^20.$/)
      ip_group = JSON.parse(response.body)['sharedIpGroup']
      CloudServers::SharedIPGroup.new(self,ip_group['id'])
    end
    
    private
    
    # Sets up standard HTTP headers
    def headerprep(headers = {}) # :nodoc:
      default_headers = {}
      default_headers["X-Auth-Token"] = @authtoken if (authok? && @account.nil?)
      default_headers["X-Storage-Token"] = @authtoken if (authok? && !@account.nil?)
      default_headers["Connection"] = "Keep-Alive"
      default_headers["User-Agent"] = "CloudServers Ruby API #{VERSION}"
      default_headers["Accept"] = "application/json"
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
    
    def get_personality(options)
      return if options.nil?
      require 'base64'
      data = []
      itemcount = 0
      options.each do |localpath,srvpath|
        raise CloudServers::Exception::TooManyPersonalityItems, "Personality files are limited to a total of #{MAX_PERSONALITY_ITEMS} items" if itemcount >= MAX_PERSONALITY_ITEMS
        raise CloudServers::Exception::PersonalityFilePathTooLong, "Server-side path of #{srvpath} exceeds the maximum length of #{MAX_SERVER_PATH_LENGTH} characters" if srvpath.size > MAX_SERVER_PATH_LENGTH
        raise CloudServers::Exception::PersonalityFileTooLarge, "Local file #{localpath} exceeds the maximum size of #{MAX_PERSONALITY_FILE_SIZE} bytes" if File.size(localpath) > MAX_PERSONALITY_FILE_SIZE
        b64 = Base64.encode64(IO.read(localpath))
        data.push({:path => srvpath, :contents => b64})
        itemcount += 1
      end
      return data
    end
    
    
  end
end