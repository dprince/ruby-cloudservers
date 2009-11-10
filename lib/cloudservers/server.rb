module CloudServers
  class Server
    
    attr_reader :id
    attr_reader :name
    attr_reader :status
    attr_reader :progress
    attr_reader :addresses
    attr_reader :metadata
    attr_reader :hostId
    
    def initialize(connection,id)
      @connection = connection
      @id = id
      @svrmgmthost = connection.svrmgmthost
      @svrmgmtpath = connection.svrmgmtpath
      @svrmgmtport = connection.svrmgmtport
      @svrmgmtscheme = connection.svrmgmtscheme
      populate
    end
    
    def populate
      response = @connection.csreq("GET",@svrmgmthost,"#{@svrmgmtpath}/servers/#{URI.encode(@id.to_s)}",@svrmgmtport,@svrmgmtscheme)
      raise InvalidResponseException, "Invalid response code #{response.code}" unless (response.code.match(/^20.$/))
      data = JSON.parse(response.body)["server"]
      @id        = data["id"]
      @name      = data["name"]
      @status    = data["status"]
      @progress  = data["progress"]
      @addresses = data["addresses"]
      @metadata  = data["metadata"]
      @hostId    = data["hostId"]
    end
    alias :refresh :populate
    
    def reboot(type="SOFT")
      data = JSON.generate(:reboot => {:type => type})
      response = @connection.csreq("POST",@svrmgmthost,"#{@svrmgmtpath}/servers/#{URI.encode(self.id.to_s)}/action",@svrmgmtport,@svrmgmtscheme,{'content-type' => 'application/json'},data)
      raise InvalidResponseException, "Invalid response code #{response.code}" unless (response.code.match(/^20.$/))
      true
    end
    
    def reboot!
      self.reboot("HARD")
    end
  end
end