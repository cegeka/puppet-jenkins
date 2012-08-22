# Class: puppet-jenkins
#
# This module manages puppet-jenkins
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class jenkins($jenkins_version=undef, $jenkins_plugins=undef, $ensure='present') {
  if $ensure in [present, absent] {
  } else {
    fail('Jenkins: ensure parameter must be present or absent')
  }

  if $ensure == 'absent' {
    $real_jenkins_ensure = $ensure
  } else {
    if ! $jenkins_version {
      $real_jenkins_ensure = 'latest'
    } else {
      $real_jenkins_ensure = $jenkins_version
    }
  }

  case $::operatingsystem {
      redhat, centos: { include jenkins::redhat }
      default: { fail("operatingsystem ${::operatingsystem} is not supported") }
  }
}
