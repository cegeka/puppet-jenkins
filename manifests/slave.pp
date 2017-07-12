define jenkins::slave(
  $user_id,
  $slice_percentage,
  $home_prefix = '/data',
  $disk_size = '2G',
  $fs_type = 'xfs',
  $secret_id = undef,
  $password = undef
) {

  if $secret_id == undef and $password == undef {
    fail('You must privide a password or a secret_id to ::jenkins::slave')
  }

  if $secret_id != undef {
    $user_password = getsecret($secret_id, 'Password')
  } else {
    $user_password = $password
  }

  file {"${home_prefix}/${name}":
    ensure  => directory,
    owner   => $name,
    group   => $name,
    require => User[$name],
  }

  user { $name :
    ensure  => present,
    home    => "${home_prefix}/${name}",
    uid     => $user_id,
    shell   => '/bin/bash',
    comment => "Jenkins Slave User - ${name}",
  }

  ::lvm::logical_volume { $name :
    ensure       => 'present',
    volume_group => 'vgroot',
    fs_type      => $fs_type,
    size         => $disk_size,
    mountpath    => "${home_prefix}/${name}"
  }


  case $::operatingsystemrelease {
    /^7.*/: {
      file { "/usr/lib/systemd/system/user-${user_id}.slice" :
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        content => "[Slice]
CPUQuota=${slice_percentage}%",
        notify  => Exec["user-${user_id}-daemon-reload"],
        require => User[$name]
      }
      exec { "user-${user_id}-daemon-reload":
        command     => '/usr/bin/systemctl daemon-reload',
        user        => 'root',
        refreshonly => true,
      }
    }
    default: {}
  }
}
