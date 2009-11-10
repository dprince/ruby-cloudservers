module CloudServers
  class SharedIPGroup
    
    attr_reader :id
    attr_reader :name
    attr_reader :servers
    
    def initialize(connection,id)
      @connection = connection
      @id = id
      populate
    end
    
    def populate
      response = @connection.csreq("GET",@connection.svrmgmthost,"#{@connection.svrmgmtpath}/shared_ip_groups/#{URI.escape(self.id.to_s)}",@connection.svrmgmtport,@connection.svrmgmtscheme)
      raise InvalidResponseException, "Invalid response code #{response.code}" unless (response.code.match(/^20.$/))
      data = JSON.parse(response.body)['sharedIpGroup']
      @id = data['id']
      @name = data['name']
      @servers = data['servers']
    end
    alias :refresh :populate
    
    # Doesn't seem to be actually deleting anything
    def delete!
      response = @connection.csreq("DELETE",@connection.svrmgmthost,"#{@connection.svrmgmtpath}/shared_ip_groups/#{URI.escape(self.id.to_s)}",@connection.svrmgmtport,@connection.svrmgmtscheme)
      raise InvalidResponseException, "Invalid response code #{response.code}" unless (response.code.match(/^204$/))
      true
    end
    
  end
end