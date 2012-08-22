include jenkins
jenkins::plugin { 'ircbot':
  version    => '2.18',
  plugin_dir => '/data/jenkins/plugins',
}
jenkins::plugin { 'instant-messaging':
  version    => '1.16',
  plugin_dir => '/data/jenkins/plugins',
}
jenkins::plugin { 'active-directory':
  version    => 'latest',
  plugin_dir => '/data/jenkins/plugins',
}
