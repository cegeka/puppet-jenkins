import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl

def usernamepassword_credential = {id, username, password, description ->
	def jenkins = jenkins.model.Jenkins.instance
	def domain = com.cloudbees.plugins.credentials.domains.Domain.global()
	def store = jenkins.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

    def usernameAndPassword = new UsernamePasswordCredentialsImpl(com.cloudbees.plugins.credentials.CredentialsScope.GLOBAL, id, description, username, password)
    
	def creds = com.cloudbees.plugins.credentials.CredentialsProvider.lookupCredentials(
        com.cloudbees.plugins.credentials.common.StandardUsernameCredentials.class,
        jenkins
    )

    // search for a credential with the same id, update and create are different
    def c = creds.findResult { it.id == id ? it : null }

    if (c) {
		def result = store.updateCredentials(domain, c, usernameAndPassword)
		println "Updated username and password for ${id}"
	} else {
		def result = store.addCredentials(domain, usernameAndPassword)
		println "Added username and password for ${id}"
	}
}

return usernamepassword_credential