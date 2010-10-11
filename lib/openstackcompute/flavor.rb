module OpenStackCompute
  class Flavor
  
    attr_reader :id
    attr_reader :name
    attr_reader :ram
    attr_reader :disk

    # This class provides an object for the "Flavor" of a server.  The Flavor can generally be taken as the server specification,
    # providing information on things like memory and disk space.
    #
    # The disk attribute is an integer representing the disk space in GB.  The memory attribute is an integer representing the RAM in MB.
    #
    # This is called from the get_flavor method on a OpenStackCompute::Connection object, returns a OpenStackCompute::Flavor object, and will likely not be called directly.
    #
    #   >> flavor = cs.get_flavor(1)
    #   => #<OpenStackCompute::Flavor:0x1014f8bc8 @name="256 server", @disk=10, @id=1, @ram=256>
    #   >> flavor.name
    #   => "256 server"
    def initialize(connection,id)
      response = connection.csreq("GET",connection.svrmgmthost,"#{connection.svrmgmtpath}/flavors/#{URI.escape(id.to_s)}",connection.svrmgmtport,connection.svrmgmtscheme)
      OpenStackCompute::Exception.raise_exception(response) unless response.code.match(/^20.$/)
      data = JSON.parse(response.body)['flavor']
      @id   = data['id']
      @name = data['name']
      @ram  = data['ram']
      @disk = data['disk']
    end
    
  end
end
