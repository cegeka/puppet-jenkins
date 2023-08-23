import hudson.model.Node.Mode
import hudson.slaves.*
import jenkins.model.Jenkins
import hudson.plugins.sshslaves.SSHLauncher
import hudson.plugins.sshslaves.verifiers.NonVerifyingKeyVerificationStrategy


def ssh_slave = {String name, String credentialID, String description, String ip, int port, String home, int executors, String usage_mode, String agentLabels ->

    if (usage_mode == 'normal') {
        mode = Mode.NORMAL
    } else {
        mode = Mode.EXCLUSIVE
    }
    DumbSlave dumb = new DumbSlave(
        name,
        home,
        new SSHLauncher(ip, port, credentialID, "", "", "", "", 60, 3, 15, new NonVerifyingKeyVerificationStrategy()),
    )
    dumb.nodeDescription = description
    dumb.numExecutors = executors
    dumb.labelString = agentLabels
    dumb.mode = mode
    dumb.retentionStrategy = RetentionStrategy.INSTANCE
    Jenkins.instance.addNode(dumb)
}

return ssh_slave
