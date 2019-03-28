#!/usr/bin/ruby
require "net/http"
require "uri"
require "cgi"

Puppet::Type.newtype(:jenkins_thycotic_folder) do
  newparam(:folder_id, :namevar => true) do
    desc "The folder id to sync"
  end

  newparam(:thycotic_username, :namevar => false) do
    desc "The username of thycotic service account to use"
  end
  
  newparam(:thycotic_password, :namevar => false) do
    desc "The username of thycotic service account to use"
  end

  newparam(:thycotic_url, :namevar => false) do
    desc "The url of the thycotic server to use"
  end

  def exists?
    counter=0

    uri = URI.parse("http://localhost:8080/scriptText")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri)

    script = '
    def thycotic_username = "'+self[:thycotic_username]+'"
    def thycotic_password = "'+self[:thycotic_password]+'"
    def thycotic_hostname = "'+self[:thycotic_url]+'"

    def thycotic_folder_id      = '+self[:folder_id]+'
    '
    script += File.read("/data/jenkins/init.groovy.d/thycotic_check.groovy")
    request.body = "script="+CGI.escape(script)
  
    while counter <= 3 do 
      begin
        counter += 1
        response = http.request(request)
      rescue Exception => e
        if e.to_s == "Connection refused - connect(2)"
        then
          sleep 5
          next
        end
      end
      if response.code == "503"
      then
        sleep 10
        next
      end
      break
    end
    
    if response.code == "403" # Unauthenticated response code
      if self[:api_user].nil? && self[:api_token].nil? # check if we have a user and token
        if self[:ignore_api_errors] != true # if ignore errors is not false, exit with an error
          raise Puppet::ParseError, "No api_user and api_token defined, but jenkins needs a token"
        else
          return true
        end
      else
        request.basic_auth self[:api_user], self[:api_token]
        response = http.request(request)
      end
    end

    if response.code != "200" # check is NOT ok
      if self[:ignore_api_errors] != true # we ignore errors so puppet run will not fail
        raise Puppet::ParseError, "Error checking if secrets are in sync. Check api user and token?"
      else
        return true
      end
    else
      return response.body.include? "sync not needed"
    end
  end

  def destroy

    return true
  end

  def create
    uri = URI.parse("http://localhost:8080/scriptText")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri)

    script = '
    def thycotic_username = "'+self[:thycotic_username]+'"
    def thycotic_password = "'+self[:thycotic_password]+'"
    def thycotic_hostname = "'+self[:thycotic_url]+'"

    def thycotic_folder_id      = '+self[:folder_id]+'
    '
    script += File.read("/data/jenkins/init.groovy.d/thycotic_sync.groovy")
    request.body = "script="+CGI.escape(script)

    response = http.request(request)
    if response.code == "200"
      return true
    else
      return false
    end
  end
end
