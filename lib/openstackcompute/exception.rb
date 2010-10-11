module OpenStackCompute
  class Exception

    class OpenStackComputeError < StandardError

      attr_reader :response_body
      attr_reader :response_code

      def initialize(message, code, response_body)
        @response_code=code
        @response_body=response_body
        super(message)
      end

    end
    
    class OpenStackComputeFault           < OpenStackComputeError # :nodoc:
    end
    class ServiceUnavailable          < OpenStackComputeError # :nodoc:
    end
    class Unauthorized                < OpenStackComputeError # :nodoc:
    end
    class BadRequest                  < OpenStackComputeError # :nodoc:
    end
    class OverLimit                   < OpenStackComputeError # :nodoc:
    end
    class BadMediaType                < OpenStackComputeError # :nodoc:
    end
    class BadMethod                   < OpenStackComputeError # :nodoc:
    end
    class ItemNotFound                < OpenStackComputeError # :nodoc:
    end
    class BuildInProgress             < OpenStackComputeError # :nodoc:
    end
    class ServerCapacityUnavailable   < OpenStackComputeError # :nodoc:
    end
    class BackupOrResizeInProgress    < OpenStackComputeError # :nodoc:
    end
    class ResizeNotAllowed            < OpenStackComputeError # :nodoc:
    end
    class NotImplemented              < OpenStackComputeError # :nodoc:
    end
    class Other                       < OpenStackComputeError # :nodoc:
    end
    
    # Plus some others that we define here
    
    class ExpiredAuthToken            < StandardError # :nodoc:
    end
    class MissingArgument             < StandardError # :nodoc:
    end
    class InvalidArgument             < StandardError # :nodoc:
    end
    class TooManyPersonalityItems     < StandardError # :nodoc:
    end
    class PersonalityFilePathTooLong  < StandardError # :nodoc:
    end
    class PersonalityFileTooLarge     < StandardError # :nodoc:
    end
    class Authentication              < StandardError # :nodoc:
    end
    class Connection                  < StandardError # :nodoc:
    end
        
    # In the event of a non-200 HTTP status code, this method takes the HTTP response, parses
    # the JSON from the body to get more information about the exception, then raises the
    # proper error.  Note that all exceptions are scoped in the OpenStackCompute::Exception namespace.
    def self.raise_exception(response)
      return if response.code =~ /^20.$/
      begin
        fault = nil
        info = nil
        JSON.parse(response.body).each_pair do |key, val|
			fault=key
			info=val
		end
        exception_class = self.const_get(fault[0,1].capitalize+fault[1,fault.length])
        raise exception_class.new(info["message"], response.code, response.body)
      rescue NameError
        raise OpenStackCompute::Exception::Other.new("The server returned status #{response.code}", response.code, response.body)
      end
    end
    
  end
end

