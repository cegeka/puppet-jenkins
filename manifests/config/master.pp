class jenkins::config::master {
  $enable_ssl = lookup('profile::iac::jenkins::nginx::enable_ssl')
  $jenkins_url = lookup('profile::iac::jenkins::url')
  $admin_email = lookup('profile::iac::jenkins::admin_email')

  file { '/data/jenkins/init.groovy.d/master_configuration.groovy':
    path    => '/data/jenkins/init.groovy.d/master_configuration.groovy',
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0400',
    content => template('jenkins/master_configuration.erb'),
    require => [File['/data/jenkins/init.groovy.d'], Service['jenkins']],
  }
}
