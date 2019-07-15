#!/usr/bin/ruby
require "net/http"
require "uri"
require "cgi"

Puppet::Type.type(:jenkins_thycotic_folder).provide(:jenkins_thycotic_folder) do

  def exists?
    counter=0

    uri = URI.parse("http://localhost:8080/scriptText")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri)

    script = '
    def thycotic_username = "'+resource[:thycotic_username]+'"
    def thycotic_password = "'+resource[:thycotic_password]+'"
    def thycotic_hostname = "'+resource[:thycotic_url]+'"

    def thycotic_folder_id      = '+resource[:folder_id]+'
    '
    script += File.read("/data/jenkins/init.groovy.d/thycotic_check.groovy")
    request.body = "script="+CGI.escape(script)
  
    while counter <= 10 do
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
      if resource[:api_user].nil? && resource[:api_token].nil? # check if we have a user and token
        if resource[:ignore_api_errors] != true # if ignore errors is not false, exit with an error
          raise Puppet::ParseError, "No api_user and api_token defined, but jenkins needs a token"
        else
          return true
        end
      else
        request.basic_auth resource[:api_user], resource[:api_token]
        response = http.request(request)
      end
    end

    if response.code != "200" # check is NOT ok
      if resource[:ignore_api_errors] != true # we ignore errors so puppet run will not fail
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
    def thycotic_username = "'+resource[:thycotic_username]+'"
    def thycotic_password = "'+resource[:thycotic_password]+'"
    def thycotic_hostname = "'+resource[:thycotic_url]+'"

    def thycotic_folder_id      = '+resource[:folder_id]+'
    '
    script += File.read("/data/jenkins/init.groovy.d/thycotic_sync.groovy")
    request.body = "script="+CGI.escape(script)

    if ! resource[:api_token].nil?
       request.basic_auth resource[:api_user], resource[:api_token]
    end

    response = http.request(request)

    if response.code == "200"
      return true
    else
      return false
    end
  end
end
