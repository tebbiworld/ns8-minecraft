*** Settings ***
Library     SSHLibrary
Resource    api.resource

*** Test Cases ***
Seed a probe file
    Run on node    runagent -m ${module_id} podman exec minecraft sh -c 'echo pre-backup > /data/ci_probe.txt'

Back up the module
    ${repo}    ${path} =    Back up the module to the cluster repository    ${module_id}
    Set Global Variable    ${BACKUP_REPO}    ${repo}
    Set Global Variable    ${BACKUP_PATH}    ${path}

Stop the original instance
    # the game port is published on the node: one server per port
    # Stopped, not removed: on Rocky 9 (systemd 252) a module removed and re-created
    # within seconds gets the same UID back, the user manager for that UID is not
    # started again and the agent of the new instance never comes up. Only the units shipped by
    # the module are stopped: its agent (agent.service) must keep running, or the
    # instance can no longer be removed.
    Run on node    runagent -m ${module_id} bash -c 'cd ~/.config/systemd/user && ls *.service *.timer 2>/dev/null | xargs -r systemctl --user disable --now'

Restore into a new instance
    ${rid} =    Restore the module from the cluster repository    ${BACKUP_REPO}    ${BACKUP_PATH}
    Set Global Variable    ${restored_id}    ${rid}
    Should Not Be Equal    ${restored_id}    ${module_id}

The restored instance has data, settings and secrets
    ${cfg} =    Run task    module/${restored_id}/get-configuration    {}
    Should Be Equal    ${cfg['motd']}    CI server
    Secrets are kept out of the module environment    ${restored_id}
    Wait Until Keyword Succeeds    90 times    10 seconds    Restored console answers
    ${out} =    Run on node    runagent -m ${restored_id} podman exec minecraft cat /data/ci_probe.txt
    Should Contain    ${out}    pre-backup

*** Keywords ***
Restored console answers
    ${res} =    Run task    module/${restored_id}/run-command    {"command":"list"}
    Should Contain    ${res['output']}    players
