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

  def exists?
    uri = URI.parse("http://localhost:8080")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new("/pluginManager/installed")
    request.add_field('Content-Type', 'text/xml')

    response = http.request(request)

    if response.code == "403"
      if self[:api_user].nil? && self[:api_token].nil?
        raise Puppet::ParseError, "No api_user and api_token defined, but jenkins needs a token"
      else
        request.basic_auth self[:api_user], self[:api_token]
        response = http.request(request)
      end
    end

    if response.code != "200"
      raise Puppet::ParseError, "Error checking install state for plugin #{self[:name]}. Check api user and token?"
    end

    return response.body.include? "data-plugin-id=\"#{self[:name]}\""
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
