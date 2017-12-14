define jenkins::credentials::private_key (
	$pim_id,
	$username,
	$description,
) {
  file { "/data/jenkins/.ssh/private_key_${username}":
    path    	=> "/data/jenkins/.ssh/private_key_${username}",
    owner		=> 'jenkins',
    group		=> 'jenkins',
    mode		=> '0400',
    content 	=> getsecret($pim_id, 'Private Key'),
    require 	=> ['Class[jenkins::credentials]', 'File[/data/jenkins/.ssh]'],
  }

  file { "/data/jenkins/init.groovy.d/ssh_credential_${name}.groovy":
    path    	=> "/data/jenkins/init.groovy.d/ssh_credential_${name}.groovy",
    owner		=> 'jenkins',
    group		=> 'jenkins',
    mode		=> '0400',
    content 	=> template('jenkins/ssh_credential_instance.erb'),
    require 	=> ['File[/data/jenkins/init.groovy.d]', 'Class[jenkins::credentials]'],
  }
}