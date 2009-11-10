module CloudServers
  class Connection
    
    attr_reader   :authuser
    attr_accessor :authtoken
    attr_reader   :authkey
    attr_accessor :authok
    
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
  end
end