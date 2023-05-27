function initialize()
    log('Delay time is ['..delay_time..']')
    while not spells_have or #spells_have < 1 do -- cycle through till the player is logged in and found
        coroutine.sleep(delay_time)
        spells_have = windower.ffxi.get_spells() -- Run once to load all the learned spells the player has
    end
    player = windower.ffxi.get_player() -- one time update to populate information (also job change)
    player_location = windower.ffxi.get_mob_by_index(player.index) -- Update the player location information
    player_abilities = windower.ffxi.get_abilities()
    world = windower.ffxi.get_info() -- Update the info
    buff_maps() -- Calls the map to give buff.en a unique name for Silmaril mapping
    get_player_spells()
    loaded = true
end

function update() -- Update send data to the Silmaril when requested
    party_status() --Clears then updates the current party data in the table "party_data" via Party.lua
    player_info() -- Get the player info and generates the self buffs in the "party_buffs" table and also updates the "player_status" string via Player.lua
    get_abilities_recast() -- Get player ability recast timers and saves to the string "player_job_abilities_recasts" via Abilities.lua
    get_spell_recast() -- Get player spell recast timers and saves to the string "player_spell_recasts" via Spells.lua
    get_world_data() -- Get get information on the world via World.lua
    get_enemy_data() -- Get get enemy information via World.lua
    send_info() -- Send the block of info to Silmaril if connected
end

function send_info()
    --Begin updates via a heartbeat check
    local packet_data = player.name..';heartbeat;'
    --Party data to the Silmaril Program - Generated from Party.Lua
    for index, value in pairs(party_data) do
       packet_data = packet_data..';'..value
    end
    --Buffs to the Silmaril Program - Generated via packets and Player.lua
    for index, value in pairs(party_buffs) do
       packet_data = packet_data..';'..value
    end
    --Player status from Player.lua
    if player_status then
        packet_data = packet_data..';'..player_status
    end
    --Job ability recasts to the Silmaril Program
    if player_job_abilities_recasts then
        packet_data = packet_data..';'..player_job_abilities_recasts
    end
    --Spell recasts to the Silmaril Program
    if player_spell_recasts then
        packet_data = packet_data..';'..player_spell_recasts
    end
    --World data to the Silmaril Program via World.lua
    if player_world_data then
        packet_data = packet_data..';'..player_world_data
    end
    --Enemy data to the Silmaril Program via World.lua
    if player_enemy_data then
        packet_data = packet_data..';'..player_enemy_data
    end
    --NPC data to the Silmaril Program via World.lua
    if player_npc_data then
        packet_data = packet_data..';'..player_npc_data
    end
     --Item data to the Silmaril Program via World.lua
    if player_item_data then
        packet_data = packet_data..';'..player_item_data
        --log("Inventory sent to Silmaril")
    end
    --Task data to the Silmaril Program via Burst and Skillchain Lua
    for index, value in pairs(player_task_data) do
       packet_data = packet_data..';'..value
    end
    --Used to keep track of what mob is being attacked
    packet_data = packet_data..';'..player_attack_target
    --Process the information and generate a response
    packet_data = packet_data..';action'
    send_packet(packet_data)
    player_task_data = {}
    player_item_data = nil
end