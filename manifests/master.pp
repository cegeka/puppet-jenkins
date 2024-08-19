class jenkins::master {
  Cegeka_yum::Repo <| title == 'cegeka-custom-noarch' |>

  if $jenkins::ensure == 'absent' {
    $real_jenkins_ensure = $jenkins::ensure
  } else {
    if ! $jenkins::jenkins_version {
      $real_jenkins_ensure = 'present'
    } else {
      $real_jenkins_ensure = $jenkins::jenkins_version
    }
  }

  # these values are used in the jenkins.sysconfig.erb template
  $java_opts = join($jenkins::jenkins_java_options, ' ' )

  package { 'jenkins' :
    ensure => $real_jenkins_ensure,
  }

  if $facts['os']['release']['major'] == '8' {
    realize Dnf::Module['javapackages-runtime']

    # make sure the javapackages-runtime dnf module is active before the package requirement or it won't find the package
    Dnf::Module['javapackages-runtime'] -> Package["java-${jenkins::jenkins_java_version}-openjdk-headless"]
  }

  package { "java-${jenkins::jenkins_java_version}-openjdk-headless":
    ensure  => present,
  }

  # the java command is needed in the service template
  $java_cmd = $jenkins::jenkins_java_path
  systemd::unit_file { 'jenkins.service':
    ensure  => 'present',
    path    => '/usr/lib/systemd/system',
    content => template("${module_name}/jenkins.service.erb"),
    require => Package['jenkins'],
  }
  ~> service { 'jenkins' :
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['jenkins'],
  }

  file { '/data/jenkins' :
    ensure => directory,
    owner  => 'jenkins',
    group  => 'jenkins',
  }

  file { '/data/jenkins/plugins' :
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => [
      Package['jenkins'],
      Service['jenkins'],
    ],
  }

  file { '/data/jenkins/init.groovy.d':
    ensure  => 'directory',
    owner   => 'jenkins',
    group   => 'jenkins',
    require => File['/data/jenkins/'],
  }

  file { '/etc/sysconfig/jenkins' :
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/jenkins.sysconfig.erb"),
  }

  if $jenkins::slice_percentage {
    systemd::service_limits { 'activemq.service':
      ensure          => present,
      limits          => "CPUQuota: ${jenkins::slice_percentage}%",
      restart_service => false,
      notify          => Exec['systemctl daemon-reload'],
    }
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
