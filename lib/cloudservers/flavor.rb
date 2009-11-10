module CloudServers
  class Flavor
    
    attr_reader :id
    attr_reader :name
    attr_reader :ram
    attr_reader :disk
    
    def initialize(connection,id)
      response = connection.csreq("GET",connection.svrmgmthost,"#{connection.svrmgmtpath}/flavors/#{URI.escape(id.to_s)}",connection.svrmgmtport,connection.svrmgmtscheme)
      raise InvalidResponseException, "Invalid response code #{response.code}" unless (response.code.match(/^20.$/))
      data = JSON.parse(response.body)['flavor']
      @id   = data['id']
      @name = data['name']
      @ram  = data['ram']
      @disk = data['disk']
    end
    
  end
end