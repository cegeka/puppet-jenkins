//
// Import some required Java libraries
//
import jenkins.model.*;
import com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey;

//
// Assign Jenkins connection to 'instance' variable. Don't ever edit this
//
def instance = Jenkins.getInstance()

// Function to configure add a private key to the Jenkins keystore
def ssh_credential = {id, username, description, keyfile, privateKeySource=new com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey.UsersPrivateKeySource(), passphrase='' ->
  // Retrieve the Global credential store
  def domain = com.cloudbees.plugins.credentials.domains.Domain.global()
  def store = instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

  // Create the SSH credential
  def jenkins_creds = new com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey(
    com.cloudbees.plugins.credentials.CredentialsScope.GLOBAL,
    id,
    username,
    new BasicSSHUserPrivateKey.FileOnMasterPrivateKeySource(keyfile), //privateKeySource,
    passphrase,
    description
  )
  store.addCredentials(domain, jenkins_creds)
  println "Adding ${id} ssh credentials"
}

return ssh_credential