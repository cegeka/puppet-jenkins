class jenkins::redhat {
  package { 'jenkins' :
    ensure => $jenkins::real_jenkins_ensure,
  }

  service { 'jenkins' :
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['jenkins'],
  }

  file { '/data/jenkins/plugins' :
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => [
      Package['jenkins'],
      Service['jenkins'],
    ]
  }

  case $::operatingsystemrelease {
      /^7.*/: {
        file_line { 'jenkins_systemd_service':
          ensure  => present,
          path    => '/usr/lib/systemd/system/jenkins.service',
          line    => "ExecStart=/usr/bin/java -Djenkins.install.runSetupWizard=false -Dcom.sun.akuma.Daemon=daemonized \${JENKINS_JAVA_OPTIONS} -DJENKINS_HOME=\${JENKINS_HOME} -jar /usr/lib/jenkins/jenkins.war --logfile=/var/log/jenkins/jenkins.log --webroot=/var/cache/jenkins/war --daemon --httpPort=\${JENKINS_PORT} --debug=\${JENKINS_DEBUG_LEVEL} --handlerCountMax=\${JENKINS_HANDLER_MAX} --handlerCountMaxIdle=\${JENKINS_HANDLER_IDLE}",
          match   => '^ExecStart\=',
          require => Package['jenkins'],
          notify  => Exec['jenkins-daemon-reload'],
        }

        exec { 'jenkins-daemon-reload':
          command     => '/usr/bin/systemctl daemon-reload',
          user        => 'root',
          refreshonly => true,
          notify      => Service['jenkins'],
          require     => File_Line['jenkins_systemd_service'],
        }
      }
      default: {}
  }

  if $jenkins::disable_csrf {
    augeas { 'jenkins_csrf':
      lens    => 'Xml.lns',
      incl    => '/data/jenkins/config.xml',
      changes => 'rm /files/data/jenkins/config.xml/hudson/crumbIssuer',
      notify  => Service['jenkins'],
    }
  }
}
