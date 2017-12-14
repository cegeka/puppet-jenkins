define jenkins::plugin(
  $version = undef,
  $plugin_dir = undef,
  $api_user = undef,
  $api_token = undef,
  $ignore_api_errors = false,
) {
  include jenkins::params

  jenkins_plugin { $name:
    ensure            => present,
    api_user          => $api_user,
    api_token         => $api_token,
    ignore_api_errors => $ignore_api_errors,
    before            => Class["jenkins::credentials"]
  }
}