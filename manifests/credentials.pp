class jenkins::credentials {

  file { '/data/jenkins/init.groovy.d/ssh_credentials.groovy':
    source  => 'puppet:///modules/jenkins/data/jenkins/init.groovy.d/ssh_credentials.groovy',
    owner   => 'jenkins',
    group   => 'jenkins',
    require => File['/data/jenkins/init.groovy.d'],
  }

#  file { '/data/jenkins/init.groovy.d/usernamepassword_credentials.groovy':
#    source  => 'puppet:///modules/jenkins/data/jenkins/init.groovy.d/usernamepassword_credentials.groovy',
#    owner   => 'jenkins',
#    group   => 'jenkins',
#    require => File['/data/jenkins/init.groovy.d'],
#  }

  file { '/data/jenkins/init.groovy.d/ssh_slave.groovy':
    source  => 'puppet:///modules/jenkins/data/jenkins/init.groovy.d/ssh_slave.groovy',
    owner   => 'jenkins',
    group   => 'jenkins',
    require => File['/data/jenkins/init.groovy.d'],
  }

#  file { '/data/jenkins/init.groovy.d/ditem.dat':
#    ensure  => file,
#    mode    => '0400',
#    owner   => 'jenkins',
#    content => getsecret(95460,'File')
#  }
#
#  file { '/data/jenkins/init.groovy.d/key.dat':
#    ensure  => file,
#    mode    => '0400',
#    owner   => 'jenkins',
#    content => getsecret(95462,'File')
#  }
#
#  file { '/data/jenkins/init.groovy.d/logininfo.dat':
#    ensure  => file,
#    mode    => '0400',
#    owner   => 'jenkins',
#    content => getsecret(95463,'File')
#  }
#
#  file { '/data/jenkins/init.groovy.d/options.dat':
#    ensure  => file,
#    mode    => '0400',
#    owner   => 'jenkins',
#    content => getsecret(95464,'File')
#  }
#
#  file { '/data/jenkins/init.groovy.d/pitem.dat':
#    ensure  => file,
#    mode    => '0400',
#    owner   => 'jenkins',
#    content => getsecret(95461,'File')
#  }
#
#  file { '/data/jenkins/init.groovy.d/secretserver-jconsole.jar':
#    ensure  => file,
#    mode    => '0400',
#    owner   => 'jenkins',
#    content => getsecret(95465,'File')
#  }
}
