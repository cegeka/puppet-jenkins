import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl

def usernamepassword_credential = {id, secret_id, description ->
	def jenkins = jenkins.model.Jenkins.instance
	def domain = com.cloudbees.plugins.credentials.domains.Domain.global()
	def store = jenkins.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

	def username = "java -jar /data/jenkins/init.groovy.d/secretserver-jconsole.jar -s ${secret_id} UserName".execute()
	def password = "java -jar /data/jenkins/init.groovy.d/secretserver-jconsole.jar -s ${secret_id} Password".execute()

	username.waitFor() //groovy processes are async, so we have to wait
	password.waitFor()

	if (username.exitValue() == 0 && password.exitValue() == 0) {
		username = username.text.trim()
		password = password.text.trim()
	} else {
		println "Failed getting username and password!"
		return
	}

	if (username.contains('java.lang.Exception')) { // The java api does not use errorcodes, so this is needed
		println "Failed getting username, error message is: ${username}"
		return
	}

	if (password.contains('java.lang.Exception')) { // The java api does not use errorcodes, so this is needed
		println "Failed getting password, error message is: ${password}"
		return
	}

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