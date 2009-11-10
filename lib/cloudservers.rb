#!/usr/bin/env ruby
# 
# == Cloud Servers API
module CloudServers

  VERSION = '0.0.1'
  require 'net/http'
  require 'net/https'
  require 'uri'
  require 'digest/md5'
  require 'time'
  require 'rubygems'
  require 'json'

  unless "".respond_to? :each_char
    require "jcode"
    $KCODE = 'u'
  end

  $:.unshift(File.dirname(__FILE__))
  require 'cloudservers/authentication'
  require 'cloudservers/connection'
  require 'cloudservers/server'
  require 'cloudservers/image'
  require 'cloudservers/flavor'
  
  MAX_PERSONALITY_ITEMS = 5
  MAX_PERSONALITY_FILE_SIZE = 10240
  MAX_SERVER_PATH_LENGTH = 255
  MAX_PERSONALITY_METADATA_ITEMS = 5

end



class SyntaxException             < StandardError # :nodoc:
end
class ConnectionException         < StandardError # :nodoc:
end
class AuthenticationException     < StandardError # :nodoc:
end
class InvalidResponseException    < StandardError # :nodoc:
end
class ExpiredAuthTokenException   < StandardError # :nodoc:
end
class MissingArgumentException    < StandardError # :nodoc:
end
class TooManyPersonalityItemsException     < StandardError # :nodoc:
end
class PersonalityFilePathTooLongException  < StandardError # :nodoc:
end
class PersonalityFileTooLargeException     < StandardError # :nodoc:
end
class UnauthorizedException < StandardError # :nodoc:
end