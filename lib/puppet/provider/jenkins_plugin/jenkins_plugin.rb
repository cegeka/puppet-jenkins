#!/usr/bin/ruby
require "net/http"
require "uri"

Puppet::Type.type(:jenkins_plugin).provide(:jenkins_plugin) do

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
        raise Puppet::ParseError, "Error checking install state for plugin #{resource[:name]}. Check api user and token?"
      else
        return true
      end
    else
      return response.body.include? "data-plugin-id=\"#{resource[:name]}\""
    end

    #return response.body.include? "data-plugin-id=\"#{resource[:name]}\""
  end

  def destroy
    uri = URI.parse("http://localhost:8080")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new("/pluginManager/plugin/#{resource[:name]}/doUninstall")
    request.add_field('Content-Type', 'text/xml')
    request.body = ""

    response = http.request(request)

    if response.code == "403"
      if resource[:api_user].nil? && resource[:api_token].nil?
        raise Puppet::ParseError, "No api_user and api_token defined, but jenkins needs a token"
      else
        request.basic_auth resource[:api_user], resource[:api_token]
        response = http.request(request)
      end
    end

    if response.code != "302"
      raise Puppet::ParseError, "Error uninstalling plugin #{resource[:name]}"
    end

    return true
  end

  def create
    uri = URI.parse("http://localhost:8080")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new("/pluginManager/installNecessaryPlugins")
    request.add_field('Content-Type', 'text/xml')
    request.body = "<jenkins><install plugin=\"#{resource[:name]}@latest\" /></jenkins>"

    response = http.request(request)

    if response.code == "403"
      if resource[:api_user].nil? && resource[:api_token].nil?
        raise Puppet::ParseError, "No api_user and api_token defined, but jenkins needs a token"
      else
        request.basic_auth resource[:api_user], resource[:api_token]
        response = http.request(request)
      end
    end

    if response.code != "302"
      raise Puppet::ParseError, "Error installing plugin #{resource[:name]}"
    end

    return true
  end
end
