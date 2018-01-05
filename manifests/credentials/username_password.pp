define jenkins::credentials::username_password (
    $pim_id,
    $description,
) {
  file { "/data/jenkins/init.groovy.d/usernamepassword_credential_${name}.groovy":
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0400',
    content => template('jenkins/usernamepassword_credential_instance.erb'),
    require => ['File[/data/jenkins/init.groovy.d]', 'Class[jenkins::credentials]'],
  }
}
