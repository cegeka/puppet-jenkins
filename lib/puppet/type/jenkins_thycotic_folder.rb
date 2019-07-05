#!/usr/bin/ruby

Puppet::Type.newtype(:jenkins_thycotic_folder) do
  desc "Puppet type that allows you to sync a thycotic folder to jenkins"
  ensurable

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
