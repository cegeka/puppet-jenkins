define jenkins::config::slave (
  $credential_id,
  $ip,
  $port,
  $home,
  $executors,
  $labels
) {

  file { "/data/jenkins/init.groovy.d/ssh_slave_${name}.groovy":
    path    => "/data/jenkins/init.groovy.d/ssh_slave_${name}.groovy",
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0400',
    content => template('jenkins/ssh_slave_add.erb'),
    require => ['File[/data/jenkins/init.groovy.d]'],
  }
}
