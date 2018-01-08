class jenkins::config::master {

  file { '/data/jenkins/init.groovy.d/master_configuration.groovy':
    path    => '/data/jenkins/init.groovy.d/master_configuration.groovy',
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0400',
    content => template('jenkins/master_configuration.erb'),
    require => File['/data/jenkins/init.groovy.d'],
  }

}
