module CloudServers
  class Server
    
    attr_reader   :id
    attr_reader   :name
    attr_reader   :status
    attr_reader   :progress
    attr_reader   :addresses
    attr_reader   :metadata
    attr_reader   :hostId
    attr_reader   :imageId
    attr_reader   :flavorId
    attr_reader   :metadata
    attr_accessor :adminPass
    
    def initialize(connection,id)
      @connection    = connection
      @id            = id
      @svrmgmthost   = connection.svrmgmthost
      @svrmgmtpath   = connection.svrmgmtpath
      @svrmgmtport   = connection.svrmgmtport
      @svrmgmtscheme = connection.svrmgmtscheme
      populate
      return self
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
      @imageId   = data["imageId"]
      @flavorId  = data["flavorId"]
      @metadata  = data["metadata"]
      true
    end
    alias :refresh :populate
    
    def flavor
      CloudServers::Flavor.new(@connection,self.flavorId)
    end
    
    def image
      CloudServers::Image.new(@connection,self.imageId)
    end
    
    def reboot(type="SOFT")
      data = JSON.generate(:reboot => {:type => type})
      response = @connection.csreq("POST",@svrmgmthost,"#{@svrmgmtpath}/servers/#{URI.encode(self.id.to_s)}/action",@svrmgmtport,@svrmgmtscheme,{'content-type' => 'application/json'},data)
      raise InvalidResponseException, "Invalid response code #{response.code}" unless (response.code.match(/^20.$/))
      true
    end
    
    def reboot!
      self.reboot("HARD")
    end
    
    # Options: {:name => "NewName", :adminPass => "MyNewPassword"}
    # Changing the password will reboot the server
    def update(options)
      data = JSON.generate(:server => options)
      response = @connection.csreq("PUT",@svrmgmthost,"#{@svrmgmtpath}/servers/#{URI.encode(self.id.to_s)}",@svrmgmtport,@svrmgmtscheme,{'content-type' => 'application/json'},data)
      raise InvalidResponseException, "Invalid response code #{response.code}" unless (response.code.match(/^20.$/))
      # If we rename the instance, repopulate the object
      self.populate if options[:name]
      true
    end
    
    def delete!
      response = @connection.csreq("DELETE",@svrmgmthost,"#{@svrmgmtpath}/servers/#{URI.encode(self.id.to_s)}",@svrmgmtport,@svrmgmtscheme)
      raise InvalidResponseException, "Invalid response code #{response.code}" unless (response.code.match(/^20.$/))
      true
    end
    
    def rebuild!(imageId)
      data = JSON.generate(:rebuild => {:imageId => imageId})
      response = @connection.csreq("POST",@svrmgmthost,"#{@svrmgmtpath}/servers/#{URI.encode(self.id.to_s)}/action",@svrmgmtport,@svrmgmtscheme,{'content-type' => 'application/json'},data)
      raise InvalidResponseException, "Invalid response code #{response.code}" unless (response.code.match(/^20.$/))
      self.populate
      true
    end
    
    def create_image(name)
      data = JSON.generate(:image => {:serverId => self.id, :name => name})
      response = @connection.csreq("POST",@svrmgmthost,"#{@svrmgmtpath}/images",@svrmgmtport,@svrmgmtscheme,{'content-type' => 'application/json'},data)
      raise InvalidResponseException, "Invalid response code #{response.code}" unless (response.code.match(/^20.$/))
      CloudServers::Image.new(@connection,JSON.parse(response.body)['id'])
    end
    
  end
end