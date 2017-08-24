class jenkins::redhat {

  Yum::Repo <| title == 'cegeka-custom-noarch' |>

  $user = $jenkins::jenkins_user
  $java_cmd = '/usr/lib/jvm/jre/bin/java'

  package { 'jenkins' :
    ensure => $jenkins::real_jenkins_ensure,
  }

  package { "java-${jenkins::jenkins_java_version}-openjdk":
    ensure =>  present
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

  if ! empty($jenkins::jenkins_java_options) {
    #transform java_opts to string
    $string_jenkins_java_options=join($jenkins::jenkins_java_options,' ')
    #add escaped ' and " for augeas
    $value="\'\"${string_jenkins_java_options}\"\'"
    augeas { 'set JENKINS JENKINS_JAVA_OPTIONS':
      incl    => '/etc/sysconfig/jenkins',
      lens    => 'Properties.lns',
      changes => "set JENKINS_JAVA_OPTIONS ${value}",
      notify  => Service['jenkins'],
      require => Package['jenkins']
    }
  }

  augeas { 'set JENKINS JENKINS_JAVA_CMD':
    incl    => '/etc/sysconfig/jenkins',
    lens    => 'Properties.lns',
    changes => "set JENKINS_JAVA_CMD ${java_cmd}",
    notify  => Service['jenkins'],
    require => Package["java-${jenkins::jenkins_java_version}-openjdk"]
  }

  case $::operatingsystemrelease {
      /^7.*/: {
        if $::jenkins::slice_percentage {
          $slice_percentage = $::jenkins::slice_percentage

          file { '/usr/lib/systemd/system/jenkins.service.d' :
            ensure  => directory,
            owner   => 'root',
            group   => 'root',
            require => Package['jenkins']
          }

          file { '/usr/lib/systemd/system/jenkins.service.d/jenkins.conf' :
            ensure  => present,
            owner   => 'root',
            group   => 'root',
            content => '[Service]
Slice=jenkins.slice',
            require => [ File['/usr/lib/systemd/system/jenkins.service.d'], File['/usr/lib/systemd/system/jenkins.slice'] ],
          }

          file { '/usr/lib/systemd/system/jenkins.slice' :
            ensure  => present,
            owner   => 'root',
            group   => 'root',
            content => template("${module_name}/jenkins-default.slice.erb")
          }
        }
        file { "/usr/lib/systemd/system/jenkins.service":
          ensure  => present,
          content => template("${module_name}/jenkins.service.erb"),
          notify  => Exec["jenkins-daemon-reload"],
          require => Package['jenkins']
        }
        exec { 'jenkins-daemon-reload':
          command     => '/usr/bin/systemctl daemon-reload',
          user        => 'root',
          refreshonly => true,
          notify      => Service['jenkins']
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
