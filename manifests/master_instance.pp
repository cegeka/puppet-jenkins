define jenkins::master_instance(
  $user = undef,
  $slice_percentage = undef,
  $port = undef,
  $java_cmd = '',
  $ajp_port = undef,
  $debug_level = '5',
  $access_log = 'no',
  $handler_max = '100',
  $handler_idle = '20',
  $jenkins_args = '',
  $java_opts = ''
) {
  user { $user :
    ensure  => present,
    home    => "/data/${user}",
    groups  => 'jenkins',
    comment => "Jenkins service user - ${user}",
    require => Package['jenkins']
  }

  service { $user :
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [ File["/data/${user}"], File["/var/log/${user}"],File["/var/log/${user}"],File["/etc/sysconfig/${user}"], File["/usr/lib/systemd/system/${user}.service"] ]
  }

  file { "/data/${user}/plugins" :
    ensure  => directory,
    owner   => $user,
    group   => $user,
    require => User[$user]
  }

  file { "/var/log/${user}" :
    ensure  => directory,
    owner   => $user,
    group   => $user,
    require => User[$user]
  }
  file { "/var/cache/${user}" :
    ensure  => directory,
    owner   => $user,
    group   => $user,
    require => User[$user]
  }

  file { "/data/${user}" :
    ensure  => directory,
    owner   => $user,
    group   => $user,
    require => User[$user]
  }

  file { "/etc/sysconfig/${user}" :
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/jenkins.sysconfig.erb"),
    require => User[$user]
  }

  case $::operatingsystemrelease {
      /^7.*/: {
        if $::jenkins::slice_percentage {

          file { "/usr/lib/systemd/system/${user}.service":
            ensure  => present,
            content => template("${module_name}/jenkins.service.erb"),
            notify  => Exec["${user}-daemon-reload"],
            require => File["/usr/lib/systemd/system/${user}.service.d/${user}.conf"]
          }

          file { "/usr/lib/systemd/system/${user}.service.d" :
            ensure  => directory,
            owner   => 'root',
            group   => 'root',
            require => User[$user]
          }

          file { "/usr/lib/systemd/system/${user}.service.d/${user}.conf" :
            ensure  => present,
            owner   => 'root',
            group   => 'root',
            content => "[Service]
Slice=${user}.slice",
            require => [ File["/usr/lib/systemd/system/${user}.service.d"], File["/usr/lib/systemd/system/${user}.slice"] ]
          }

          file { "/usr/lib/systemd/system/${user}.slice" :
            ensure  => present,
            owner   => 'root',
            group   => 'root',
            content => template("${module_name}/jenkins-default.slice.erb"),
            require => User[$user]
          }
        }
        else {
          file { "/usr/lib/systemd/system/${user}.service":
            ensure  => present,
            source  => template("${module_name}/jenkins.service.erb"),
            require => User[$user],
            notify  => Exec["${user}-daemon-reload"],
          }
        }

        exec { "${user}-daemon-reload":
          command     => '/usr/bin/systemctl daemon-reload',
          user        => 'root',
          refreshonly => true,
          notify      => Service[$user]
        }
      }
      default: {}
  }

  if $jenkins::disable_csrf {
    augeas { "jenkins_csrf_${user}":
      lens    => 'Xml.lns',
      incl    => "/data/${user}/config.xml",
      changes => "rm /files/data/${user}/config.xml/hudson/crumbIssuer",
      notify  => Service['jenkins'],
    }
  }
}
