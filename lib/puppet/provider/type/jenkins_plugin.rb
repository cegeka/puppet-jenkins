#!/usr/bin/ruby

Puppet::Type.newtype(:jenkins_plugin) do
  desc "Puppet type that manages jenkins plugins"
  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the jenkins plugin that should be installed"
  end
end
