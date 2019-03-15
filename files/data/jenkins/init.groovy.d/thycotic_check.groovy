import groovy.json.*
import java.io.File
import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl

def thycotic_fetch_token = {username, password, url ->
  def post = new URL(url+"/oauth2/token").openConnection();
  def message = "username="+username+"&password="+password+"&grant_type=password"
  post.setRequestMethod("POST")
  post.setDoOutput(true)
  
  post.setRequestProperty("Accept", "application/json")
  post.setRequestProperty("Content-Type", "application/x-www-form-urlencoded")


  post.getOutputStream().write(message.getBytes("UTF-8"));
  def postRC = post.getResponseCode();
  
  if(postRC.equals(200)) {
    def tokenResponse = post.getInputStream().getText()

    def jsonSlurper = new JsonSlurper()
    def tokenResult = jsonSlurper.parseText(tokenResponse)

    return tokenResult.access_token
  }
}

def thycotic_fetch_folder = {token, folder_id, template_id ->
  def get = new URL(thycotic_hostname+"/api/v1/secrets/?filter.folderId="+folder_id+"&filter.secretTemplateId="+template_id).openConnection();
  get.setRequestProperty("Accept", "application/json")
  get.setRequestProperty("Authorization", "Bearer "+token)

  def getRC = get.getResponseCode();
  if(getRC.equals(200)) {
    def secretResponse = get.getInputStream().getText()

    def jsonSlurper = new JsonSlurper()
    def secretResult = jsonSlurper.parseText(secretResponse)

    return secretResult
  }
}
def token = thycotic_fetch_token(thycotic_username, thycotic_password, thycotic_hostname)
def folder_secrets = thycotic_fetch_folder(token, thycotic_folder_id, thycotic_secret_type_id)

def jenkinsSecretList = []

for (secret in folder_secrets.records) {
  jenkinsSecretList.add("thycotic-"+secret.id)
}

domainName = null
credentialsStore = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0]?.getStore()
domain = new Domain(domainName, null, Collections.<DomainSpecification>emptyList())

def syncNeeded = false
def credentialsStore = credentialsStore?.getCredentials(domain)
if (credentialsStore.size() < jenkinsSecretList.size()) {
  syncNeeded = true
} else {
  credentialsStore.each{
    if (!jenkinsSecretList.contains(it.id)) {
      syncNeeded = true
    }
  }
}

if (syncNeeded) {
  println("sync needed");
} else {
  println("sync not needed")
}
return