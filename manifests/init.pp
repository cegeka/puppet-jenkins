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
  $ensure = 'present',
  $jenkins_version = undef,
  $jenkins_plugins = undef,
  $jenkins_slave_config = undef,
  $jenkins_thycotic_config = undef,
  $jenkins_master_config = undef,
  $jenkins_user = 'jenkins',
  $disable_csrf = false,
  $api_user = undef,
  $api_token = undef,
  $ignore_api_errors = false,
  $jenkins_java_version = undef,
  $jenkins_java_options = [],
  $slice_percentage = undef
) inherits jenkins::params {

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
      'RedHat', 'CentOS': { include jenkins::redhat }
      default: { fail("operatingsystem ${::operatingsystem} is not supported") }
  }

  if ! empty($jenkins_plugins) {
    jenkins::plugin { $jenkins_plugins:
      api_user          => $api_user,
      api_token         => $api_token,
      ignore_api_errors => $ignore_api_errors,
      require           => Service[jenkins]
    }
  }

  if ! empty($jenkins_slave_config) {
      file { '/data/jenkins/init.groovy.d/ssh_slave.groovy':
        source  => 'puppet:///modules/jenkins/data/jenkins/init.groovy.d/ssh_slave.groovy',
        owner   => 'jenkins',
        group   => 'jenkins',
        require => File['/data/jenkins/init.groovy.d'],
      }
      create_resources('jenkins::config::slave', $jenkins_slave_config)
  }

  if ! empty($jenkins_thycotic_config) {
      file { '/data/jenkins/init.groovy.d/thycotic_check.groovy':
        source  => 'puppet:///modules/jenkins/data/jenkins/init.groovy.d/thycotic_check.groovy',
        owner   => 'jenkins',
        group   => 'jenkins',
        require => File['/data/jenkins/init.groovy.d'],
      }
      file { '/data/jenkins/init.groovy.d/thycotic_sync.groovy':
        source  => 'puppet:///modules/jenkins/data/jenkins/init.groovy.d/thycotic_sync.groovy',
        owner   => 'jenkins',
        group   => 'jenkins',
        require => File['/data/jenkins/init.groovy.d'],
      }
      file { '/data/jenkins/init.groovy.d/usernamepassword_credentials.groovy':
        source  => 'puppet:///modules/jenkins/data/jenkins/init.groovy.d/usernamepassword_credentials.groovy',
        owner   => 'jenkins',
        group   => 'jenkins',
        require => File['/data/jenkins/init.groovy.d'],
      }


      create_resources('::jenkins::thycotic_sync', $jenkins_thycotic_config)
  }

  if $jenkins_master_config {
    include jenkins::config::master
  }
}
