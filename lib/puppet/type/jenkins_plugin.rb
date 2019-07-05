#!/usr/bin/ruby

Puppet::Type.newtype(:jenkins_plugin) do
  desc "Puppet type that manages jenkins plugins"
  ensurable

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
end
