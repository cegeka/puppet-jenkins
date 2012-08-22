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
    require => Package['jenkins'],
  }
}
