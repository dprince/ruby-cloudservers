module CloudServers
  class Exception
    
    # The list of exceptions as provided in the API Document
    class CloudServersFault < StandardError; end
    class ServiceUnavailable < StandardError; end
    class Unauthorized < StandardError; end
    class BadRequest < StandardError; end
    class OverLimit < StandardError; end
    class BadMediaType < StandardError; end
    class BadMethod < StandardError; end
    class ItemNotFound < StandardError; end
    class BuildInProgress < StandardError; end
    class ServerCapacityUnavailable < StandardError; end
    class BackupOrResizeInProgress < StandardError; end
    class ResizeNotAllowed < StandardError; end
    class NotImplemented < StandardError; end
    class Other < StandardError; end
    
    def self.raise_exception(response)
      return if response.code =~ /^20.$/
      fault,info = JSON.parse(response.body).first
      begin
        exception_class = self.const_get(fault.upcase_first)
        raise exception_class, info["message"]
      rescue NameError
        raise CloudServers::Exception::Other, "The server returned status #{response.code}"
      end
    end
    
  end
end

