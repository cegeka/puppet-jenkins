import hudson.model.Node.Mode
import hudson.slaves.*
import jenkins.model.Jenkins
import hudson.plugins.sshslaves.SSHLauncher
import hudson.plugins.sshslaves.verifiers.NonVerifyingKeyVerificationStrategy


def ssh_slave = {String name, String credentialID, String description, String ip, int port, String home, String usage_mode, String executors, String agentLabels ->

    if (usage_mode == 'normal') {
        mode = Mode.NORMAL
    } else {
        mode = Mode.EXCLUSIVE
    }
    DumbSlave dumb = new DumbSlave(
        name,
        description,
        home,
        executors,
        mode, // "Usage" field, EXCLUSIVE is "only tied to node", NORMAL is "any"
        agentLabels,
        new SSHLauncher(ip, port, credentialID, "", "", "", "", 60, 3, 15, new NonVerifyingKeyVerificationStrategy()),
        RetentionStrategy.INSTANCE) // Is the "Availability" field, INSTANCE = always on
    Jenkins.instance.addNode(dumb)
}

return ssh_slave
