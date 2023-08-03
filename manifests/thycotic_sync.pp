define jenkins::thycotic_sync (
  $thycotic_credentials,
  $api_token,
  $api_user = 'jenkins',
  $folder_id = undef,
) {
  include jenkins::params

  jenkins_thycotic_folder { "${folder_id}":
    ensure            => present,
    thycotic_username => getsecret($thycotic_credentials,'Username'),
    thycotic_password => getsecret($thycotic_credentials,'Password'),
    thycotic_url      => getsecret($thycotic_credentials,'URL'),
    api_user          => $api_user,
    api_token         => getsecret($api_token, 'Password'),
    require           => [
      File['/data/jenkins/init.groovy.d/thycotic_sync.groovy'],
      File['/data/jenkins/init.groovy.d/thycotic_check.groovy'],
      File['/data/jenkins/init.groovy.d/usernamepassword_credentials.groovy'],
      Service['jenkins']
    ],
  }
}
