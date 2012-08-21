class jenkins::redhat {
  package { 'jenkins':
    ensure => $jenkins::real_jenkins_ensure,
  }
}
