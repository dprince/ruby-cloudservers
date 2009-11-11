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
  require 'cloudservers/shared_ip_group'
  require 'cloudservers/exception'
  
  # Constants that set limits on server creation
  MAX_PERSONALITY_ITEMS = 5
  MAX_PERSONALITY_FILE_SIZE = 10240
  MAX_SERVER_PATH_LENGTH = 255
  MAX_PERSONALITY_METADATA_ITEMS = 5

end

# Monkey-patch the String class to get a method that will capitalize the first letter
class String
  def upcase_first
    self[0].chr.capitalize + self[1, size]
  end
end