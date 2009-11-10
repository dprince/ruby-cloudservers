module CloudServers
  class Image
    
    attr_reader :id
    attr_reader :name
    attr_reader :serverId
    attr_reader :updated
    attr_reader :created
    attr_reader :status
    attr_reader :progress
    
    def initialize(connection,id)
      @id = id
      @connection = connection
      populate
    end
    
    def populate
      response = @connection.csreq("GET",@connection.svrmgmthost,"#{@connection.svrmgmtpath}/images/#{URI.escape(self.id.to_s)}",@connection.svrmgmtport,@connection.svrmgmtscheme)
      raise InvalidResponseException, "Invalid response code #{response.code}" unless (response.code.match(/^20.$/))
      data = JSON.parse(response.body)['image']
      @id = data['id']
      @name = data['name']
      @serverId = data['serverId']
      @updated = DateTime.parse(data['updated'])
      @created = DateTime.parse(data['created'])
      @status = data['status']
      @progress = data['progress']
      return true
    end
    alias :refresh :populate
    
    # Delete an image.  This should be returning invalid permissions when attempting to delete system images, but it's not.
    def delete!
      response = @connection.csreq("DELETE",@connection.svrmgmthost,"#{@connection.svrmgmtpath}/images/#{URI.escape(self.id.to_s)}",@connection.svrmgmtport,@connection.svrmgmtscheme)
      raise UnauthorizedException, "You are not authorized to delete image #{self.id} (#{self.name})" if (response.code.match(/^401$/))
      raise InvalidResponseException, "Invalid response code #{response.code}" unless (response.code.match(/^204$/))
      true
    end
    
  end
end