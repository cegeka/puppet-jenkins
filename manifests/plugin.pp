define jenkins::plugin($version=undef,$plugin_dir=undef) {
  $plugin = "${name}.hpi"

  if ! $plugin_dir {
    $real_plugin_dir = '/data/jenkins/plugins'
  } else {
    $real_plugin_dir = $plugin_dir
  }

  if ($version) {
    $base_url = "http://updates.jenkins-ci.org/download/plugins/${name}/${version}/"
  }
  else {
    $base_url   = 'http://updates.jenkins-ci.org/latest/'
  }

  exec {
    "download-${name}" :
      command  => "wget --no-check-certificate ${base_url}${plugin}",
      cwd      => $real_plugin_dir,
      require  => File[$real_plugin_dir],
      path     => ['/usr/bin', '/usr/sbin',],
      user     => 'jenkins',
      unless   => "test -f ${real_plugin_dir}/${plugin}",
      notify   => Service['jenkins'],
  }
}
