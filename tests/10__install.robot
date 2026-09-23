*** Settings ***
Library     SSHLibrary
Resource    api.resource

*** Variables ***
${CONFIG}    {"eula_accepted":true,"server_type":"PAPER","version":"LATEST","memory_mb":1536,"game_port":25565,"bedrock_enabled":false,"bedrock_port":19132,"motd":"CI server","gamemode":"survival","difficulty":"normal","max_players":5,"pvp":true,"online_mode":true,"whitelist":[],"ops":[],"seed":"","timezone":"Europe/Berlin","extra_env":[]}

*** Test Cases ***
Install the module
    IF    '${SCENARIO}' == 'update'
        ${output}  ${rc} =    Execute Command    add-module ${UPDATE_FROM} 1    return_rc=True
    ELSE
        ${output}  ${rc} =    Execute Command    add-module ${IMAGE_URL} 1    return_rc=True
    END
    Should Be Equal As Integers    ${rc}  0
    &{output} =    Evaluate    ${output}
    Set Global Variable    ${module_id}    ${output.module_id}

Configure the module
    Run task    module/${module_id}/configure-module    ${CONFIG}    decode_json=${FALSE}

The server console answers over RCON
    # proves that the generated RCON password reaches the container
    Wait Until Keyword Succeeds    90 times    10 seconds    Console lists the players    ${module_id}

Update to the image under test
    Skip If    '${SCENARIO}' != 'update'    scenario is ${SCENARIO}
    Run on node    api-cli run update-module --data '{"force":true,"module_url":"${IMAGE_URL}","instances":["${module_id}"]}'
    Wait Until Keyword Succeeds    90 times    10 seconds    Console lists the players    ${module_id}

Configuration reads back
    ${cfg} =    Run task    module/${module_id}/get-configuration    {}
    Should Be Equal    ${cfg['motd']}    CI server
    Should Be Equal As Integers    ${cfg['max_players']}    5

Secrets are stored in passwords.env only
    Secrets are kept out of the module environment    ${module_id}
    ${mode} =    Run on node    runagent -m ${module_id} bash -c 'stat -c \%a "$AGENT_STATE_DIR/minecraft.env"'
    Should Be Equal As Strings    ${mode.strip()}    600

*** Keywords ***
Console lists the players
    [Arguments]    ${mid}
    ${res} =    Run task    module/${mid}/run-command    {"command":"list"}
    Should Contain    ${res['output']}    players
