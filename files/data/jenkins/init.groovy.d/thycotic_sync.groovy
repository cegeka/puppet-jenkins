import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl
import groovy.json.*
import java.io.File

//This file contains the function to create new credentials in jenkins
def usernamepassword_credential = evaluate(new File("/data/jenkins/init.groovy.d/usernamepassword_credentials.groovy"))

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

//Fetch a secret, this will include username, password, notes, ...
def thycotic_fetch_secret = {token, secret_id ->
  def get = new URL(thycotic_hostname+"/api/v1/secrets/"+secret_id).openConnection();
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

//Look over all fields in a secret and return the one we need
//The response doesn't include a key/value way, a loop until
//you find the one you're looking for is needed
def get_field = {secret, fieldname ->
  for (item in secret.items) {
    if (item.fieldName == fieldname) {
      return item.itemValue
    }
  }
}


def token = thycotic_fetch_token(thycotic_username, thycotic_password, thycotic_hostname)
def folder_secrets = thycotic_fetch_folder(token, thycotic_folder_id, 9) //9 is template 'Web Password' in pim

//Loop over all secrets returned and create them
for (secret in folder_secrets.records) {
  def secret_data = thycotic_fetch_secret(token, secret.id)

  usernamepassword_credential.call(
    id          = "thycotic-"+secret_data.id,
    username    = get_field(secret_data, "UserName"),
    password    = get_field(secret_data, "Password"),
    description = get_field(secret_data, "Notes")
  )
}

//This makes sure the last modified timestamp of /tmp/.jenkins-last-sync is set next to tomorrow
//This is checked in the thycotic_check.groovy in order to not do this every puppet run
def tempPath = System.getProperty('java.io.tmpdir')
def lastSyncFile = new File(tempPath+"/.jenkins-last-sync")

lastSyncFile.setLastModified(new Date().next().time)

return