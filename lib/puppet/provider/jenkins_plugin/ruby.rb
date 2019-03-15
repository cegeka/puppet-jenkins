#!/usr/bin/ruby
require "net/http"
require "uri"

Puppet::Type.newtype(:jenkins_plugin) do
  newparam(:name, :namevar => true) do
      desc "Jenkins plugin name"
  end

  newparam(:api_user) do
    desc "The username to use to log in on jenkins"
  end

  newparam(:api_token) do
    desc "The token to use to log in on jenkins"
  end

  newparam(:ignore_api_errors) do
    desc "Dont fail when plugins could not be handled"
  end
  
  def exists?
    counter=0
    uri = URI.parse("http://localhost:8080")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new("/pluginManager/installed")
    request.add_field('Content-Type', 'text/xml')

    while counter <=3 do 
      begin
        counter +=1
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
        raise Puppet::ParseError, "Error checking install state for plugin #{self[:name]}. Check api user and token?"
      else
        return true
      end
    else
      return response.body.include? "data-plugin-id=\"#{self[:name]}\""
    end

    #return response.body.include? "data-plugin-id=\"#{self[:name]}\""
  end

  def destroy
    uri = URI.parse("http://localhost:8080")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new("/pluginManager/plugin/#{self[:name]}/doUninstall")
    request.add_field('Content-Type', 'text/xml')
    request.body = ""

    response = http.request(request)

    if response.code == "403"
      if self[:api_user].nil? && self[:api_token].nil?
        raise Puppet::ParseError, "No api_user and api_token defined, but jenkins needs a token"
      else
        request.basic_auth self[:api_user], self[:api_token]
        response = http.request(request)
      end
    end

    if response.code != "302"
      raise Puppet::ParseError, "Error uninstalling plugin #{self[:name]}"
    end

    return true
  end

  def create
    uri = URI.parse("http://localhost:8080")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new("/pluginManager/installNecessaryPlugins")
    request.add_field('Content-Type', 'text/xml')
    request.body = "<jenkins><install plugin=\"#{self[:name]}@latest\" /></jenkins>"

    response = http.request(request)

    if response.code == "403"
      if self[:api_user].nil? && self[:api_token].nil?
        raise Puppet::ParseError, "No api_user and api_token defined, but jenkins needs a token"
      else
        request.basic_auth self[:api_user], self[:api_token]
        response = http.request(request)
      end
    end

    if response.code != "302"
      raise Puppet::ParseError, "Error installing plugin #{self[:name]}"
    end

    return true
  end
end
