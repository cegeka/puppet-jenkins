#!/usr/bin/ruby
require "net/http"
require "uri"

Puppet::Type.type(:jenkins_plugin).provide(:ruby) do
  def exists?
    uri = URI.parse("http://localhost:8080")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new("/pluginManager/installed")
    request.add_field('Content-Type', 'text/xml')

    response = http.request(request)

    if response.code != "200"
      raise Puppet::ParseError, "Error checking install state for plugin #{resource[:name]}"
    end

    return response.body.include? "data-plugin-id=\"#{resource[:name]}\""
  end

  def destroy
    uri = URI.parse("http://localhost:8080")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new("/pluginManager/plugin/#{resource[:name]}/doUninstall")
    request.add_field('Content-Type', 'text/xml')
    request.body = ""

    response = http.request(request)

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

    if response.code != "302"
      raise Puppet::ParseError, "Error installing plugin #{resource[:name]}"
    end

    return true
  end
end
