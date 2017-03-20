# Class: jenkins
#
# This module manages jenkins
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class jenkins(
  $jenkins_version = undef,
  $jenkins_plugins = undef,
  $ensure = 'present',
  $disable_csrf = false,
  $api_user = undef,
  $api_token = undef,
  $ignore_api_errors = false,
  $jenkins_java_options = []
) {

  if $ensure in [present, absent] {
  } else {
    fail('Jenkins: ensure parameter must be present or absent')
  }

  if $ensure == 'absent' {
    $real_jenkins_ensure = $ensure
  } else {
    if ! $jenkins_version {
      $real_jenkins_ensure = 'present'
    } else {
      $real_jenkins_ensure = $jenkins_version
    }
  }

  case $::operatingsystem {
      redhat, centos: { include jenkins::redhat }
      default: { fail("operatingsystem ${::operatingsystem} is not supported") }
  }
  if $jenkins_plugins {
    jenkins::plugin { $jenkins_plugins:
      api_user          => $api_user,
      api_token         => $api_token,
      ignore_api_errors => $ignore_api_errors
    }
  }
  if ! empty($jenkins_java_options) {
    #transform java_opts to string
    $string_jenkins_java_options=join($jenkins_java_options,' ')
    #add escaped ' and " for augeas
    $value="\'\"${string_jenkins_java_options}\"\'"
    augeas { 'set JENKINS JENKINS_JAVA_OPTIONS':
      incl    => '/etc/sysconfig/jenkins',
      lens    => 'Properties.lns',
      changes => "set JENKINS_JAVA_OPTIONS ${value}",
      notify  => Service['jenkins']
    }
  }
}
