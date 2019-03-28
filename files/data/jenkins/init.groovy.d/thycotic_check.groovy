import groovy.json.*
import java.io.File
import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl

//Fetch a token from PIM that we can use for future api calls
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

//Fetch all secret for a given folder and of a sepecific template. Template will
//control what fields are in a secret and how they are named (Password vs PassWord vs Pass, ...)
//This call will not return the secret itself, only the metadata
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
def folder_secrets = thycotic_fetch_folder(token, thycotic_folder_id, 9)

//Loop over all thycotic secrets and store the data
def jenkinsSecretList = []
for (secret in folder_secrets.records) {
  jenkinsSecretList.add("thycotic-"+secret.id)
}

//Fetch all jenkins secrets and compare if the number matches, after that check secret per secret if it's already defined
domainName = null
credentialsStore = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0]?.getStore()
domain = new Domain(domainName, null, Collections.<DomainSpecification>emptyList())

def syncNeeded = false
def credentialsStore = credentialsStore?.getCredentials(domain)
def jenkinsLocalSecretList = []
credentialsStore.each{
  jenkinsLocalSecretList.add(it.id)
}

if (credentialsStore.size() < jenkinsSecretList.size()) {
  syncNeeded = true
} else {
  jenkinsSecretList.each{
    if (!jenkinsLocalSecretList.contains(it)) {
      syncNeeded = true
    }
  }
}

//If a sync is needed, display it. The ruby code in puppet will search for sync needed/sync not needed
if (syncNeeded) {
  println("sync needed");
} else {
  //Look in /tmp/.jenkins-last-sync and see if the modified date if bigger that current date
  //If it isn't we're going to require a sync anyway to make sure manually edited values in jenkins are overwritten
  def tempPath = System.getProperty('java.io.tmpdir')
  def lastSyncFile = new File(tempPath+"/.jenkins-last-sync")
  def checkTime = new Date().time

  if(lastSyncFile.lastModified() >= checkTime) {
    println("sync not needed")
  } else {
    println("sync needed");
  }
}
return