define jenkins::thycotic_sync (
  $folder_id = undef,
  $thycotic_credentials,
) {
  include jenkins::params

  jenkins_thycotic_folder { " ${folder_id}":
    ensure            => present,
    thycotic_username => getsecret($thycotic_credentials,'UserName'),
    thycotic_password => getsecret($thycotic_credentials,'Password'),
    thycotic_url      => getsecret($thycotic_credentials,'URL'),
    require => [
      File['/data/jenkins/init.groovy.d/thycotic_sync.groovy'],
      File['/data/jenkins/init.groovy.d/thycotic_check.groovy'],
      File['/data/jenkins/init.groovy.d/usernamepassword_credentials.groovy'],
      Service['jenkins']
    ]
  }
}
