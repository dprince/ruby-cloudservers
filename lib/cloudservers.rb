#!/usr/bin/env ruby
# 
# == Cloud Servers API
module CloudServers

  VERSION = '0.0.1'
  require 'net/http'
  require 'net/https'
  require 'rexml/document'
  require 'uri'
  require 'digest/md5'
  require 'time'
  require 'rubygems'

  unless "".respond_to? :each_char
    require "jcode"
    $KCODE = 'u'
  end

  $:.unshift(File.dirname(__FILE__))
  require 'cloudservers/authentication'

  def self.lines(str)
    (str.respond_to?(:lines) ? str.lines : str).to_a.map { |x| x.chomp }
  end
end



class SyntaxException             < StandardError # :nodoc:
end
class ConnectionException         < StandardError # :nodoc:
end
class AuthenticationException     < StandardError # :nodoc:
end
class InvalidResponseException    < StandardError # :nodoc:
end
