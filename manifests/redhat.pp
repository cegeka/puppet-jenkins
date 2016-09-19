class jenkins::redhat {

  Yum::Repo <| title == 'cegeka-custom-noarch' |>

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
        file { '/usr/lib/systemd/system/jenkins.service':
          ensure  => present,
          source  => "puppet:///modules/${module_name}/usr/lib/systemd/system/jenkins.service",
          require => Package['jenkins'],
          notify  => Exec['jenkins-daemon-reload'],
        }

        exec { 'jenkins-daemon-reload':
          command     => '/usr/bin/systemctl daemon-reload',
          user        => 'root',
          refreshonly => true,
          notify      => Service['jenkins'],
          require     => File['/usr/lib/systemd/system/jenkins.service'],
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
