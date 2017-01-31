define jenkins::plugin(
  $version = undef,
  $plugin_dir = undef,
  $api_user = undef,
  $api_token = undef,
  $ignore_api_errors = false,
) {

  include jenkins::params

  $plugin = "${name}.hpi"

  if ! $plugin_dir {
    $real_plugin_dir = $jenkins::params::jenkins_plugin_dir
  } else {
    $real_plugin_dir = $plugin_dir
  }

  if ($version) {
    $base_url = "http://updates.jenkins-ci.org/download/plugins/${name}/${version}/"
  }
  else {
    $base_url   = 'http://updates.jenkins-ci.org/latest/'
  }

  jenkins_plugin { $name:
    ensure            => present,
    api_user          => $api_user,
    api_token         => $api_token,
    ignore_api_errors => $ignore_api_errors
  }

}
