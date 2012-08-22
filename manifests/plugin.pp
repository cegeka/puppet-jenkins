define jenkins::plugin($version=undef,$plugin_dir=undef) {
  $plugin = "${name}.hpi"

  if ! $plugin_dir {
    $plugin_dir = '/data/jenkins/plugins'
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
      cwd      => $plugin_dir,
      require  => File[$plugin_dir],
      path     => ['/usr/bin', '/usr/sbin',],
      user     => 'jenkins',
      unless   => "test -f ${plugin_dir}/${plugin}",
      notify   => Service['jenkins'],
  }
}
