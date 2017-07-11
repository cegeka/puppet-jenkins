define jenkins::slave_slice(
  $user,
  $user_id,
  $slice_percentage
) {
  case $::operatingsystemrelease {
    /^7.*/: {
      file { "/usr/lib/systemd/system/user-${user_id}.slice" :
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        content => "[Slice]
CPUQuota=${slice_percentage}%",
        notify  => Exec["user-${user_id}-daemon-reload"],
        require => User[$user]
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
