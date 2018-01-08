import hudson.model.Node.Mode
import hudson.slaves.*
import jenkins.model.Jenkins
import hudson.plugins.sshslaves.SSHLauncher

def ssh_slave = {String name,String credentialID,String description,String ip, int port,String home,String executors,String agentLabels ->
    DumbSlave dumb = new DumbSlave(
        name,
        description,
        home,
        executors,
        Mode.NORMAL, // "Usage" field, EXCLUSIVE is "only tied to node", NORMAL is "any"
        agentLabels,
        new SSHLauncher(ip, port, credentialID, "", "", "", "", 60, 3, 15),
        RetentionStrategy.INSTANCE) // Is the "Availability" field, INSTANCE = always on
    Jenkins.instance.addNode(dumb)
}

return ssh_slave
