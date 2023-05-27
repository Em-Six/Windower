--Monitors for Skillchian Partners

Skillchain_Leader_Name = ''
Skillchain_Leader_WS = ''
Skillchain_Leader_ID = 0
Skillchain_Leader_Delay = 0
Skillchain_Leader_Last = os.clock()

Skillchain_Leader_Name_2 = ''
Skillchain_Leader_WS_2 = ''
Skillchain_Leader_ID_2 = 0
Skillchain_Leader_Delay_2 = 0
Skillchain_Leader_Last_2 = os.clock()

Skillchain_Leader_Name_3 = ''
Skillchain_Leader_WS_3 = ''
Skillchain_Leader_ID_3 = 0
Skillchain_Leader_Delay_3 = 0
Skillchain_Leader_Last_3 = os.clock()

Skillchain_Leader_Name_4 = ''
Skillchain_Leader_WS_4 = ''
Skillchain_Leader_ID_4 = 0
Skillchain_Leader_Delay_4 = 0
Skillchain_Leader_Last_4 = os.clock()

function skillchain(Name, WS, ID, Delay)
    log("Skillchain #1 - Leader:["..Name.."], Weaponskill:["..WS.."], Delay:["..Delay.."]")
    if Name ~= 'none' and WS ~= 'none' and ID ~= 0 then
        if Name ~= Skillchain_Leader_Name and WS ~= Skillchain_Leader_WS then
            windower.add_to_chat(8,'Skillchain #1 - Monitoring ['..Name..'] for ['..WS..'].')
        end
        Skillchain_Leader_Name = Name
        Skillchain_Leader_WS = WS
        Skillchain_Leader_ID = tonumber(ID)
        Skillchain_Leader_Delay = tonumber(Delay)
    else
        Skillchain_Leader_Name = ''
        Skillchain_Leader_WS = ''
        Skillchain_Leader_ID = 0
        Skillchain_Leader_Delay = 0
    end
end

function skillchain2(Name, WS, ID, Delay)
    log("Skillchain #2 - Leader:["..Name.."], Weaponskill:["..WS.."], Delay:["..Delay.."]")
    if Name ~= 'none' and WS ~= 'none' and ID ~= 0 then
        if Name ~= Skillchain_Leader_Name_2 and WS ~= Skillchain_Leader_WS_2 then
            windower.add_to_chat(8,'Skillchain #2 - Monitoring ['..Name..'] for ['..WS..'].')
        end
        Skillchain_Leader_Name_2 = Name
        Skillchain_Leader_WS_2 = WS
        Skillchain_Leader_ID_2 = tonumber(ID)
        Skillchain_Leader_Delay_2 = tonumber(Delay)
    else
        Skillchain_Leader_Name_2 = ''
        Skillchain_Leader_WS_2 = ''
        Skillchain_Leader_ID_2 = 0
        Skillchain_Leader_Delay_2 = 0
    end
end

function skillchain3(Name, WS, ID, Delay)
    log("Skillchain #3 - Leader:["..Name.."], Weaponskill:["..WS.."], Delay:["..Delay.."]")
    if Name ~= 'none' and WS ~= 'none' and ID ~= 0 then
        if Name ~= Skillchain_Leader_Name_3 and WS ~= Skillchain_Leader_WS_3 then
            windower.add_to_chat(8,'Skillchain #3 - Monitoring ['..Name..'] for ['..WS..'].')
        end
        Skillchain_Leader_Name_3 = Name
        Skillchain_Leader_WS_3 = WS
        Skillchain_Leader_ID_3 = tonumber(ID)
        Skillchain_Leader_Delay_3 = tonumber(Delay)
    else
        Skillchain_Leader_Name_3 = ''
        Skillchain_Leader_WS_3 = ''
        Skillchain_Leader_ID_3 = 0
        Skillchain_Leader_Delay_3 = 0
    end
end

function skillchain4(Name, WS, ID, Delay)
    log("Skillchain #4 - Leader:["..Name.."], Weaponskill:["..WS.."], Delay:["..Delay.."]")
    if Name ~= 'none' and WS ~= 'none' and ID ~= 0 then
        if Name ~= Skillchain_Leader_Name_4 and WS ~= Skillchain_Leader_WS_4 then
            windower.add_to_chat(8,'Skillchain #4 - Monitoring ['..Name..'] for ['..WS..'].')
        end
        Skillchain_Leader_Name_4 = Name
        Skillchain_Leader_WS_4 = WS
        Skillchain_Leader_ID_4 = tonumber(ID)
        Skillchain_Leader_Delay_4 = tonumber(Delay)
    else
        Skillchain_Leader_Name_4 = ''
        Skillchain_Leader_WS_4 = ''
        Skillchain_Leader_ID_4 = 0
        Skillchain_Leader_Delay_4 = 0
    end
end

function run_skillchain_check(data)
    local ability = all_weapon_skills[data.param]
    local now = os.clock()
    if ability then
        if data.actor_id == Skillchain_Leader_ID and ability.en == Skillchain_Leader_WS and now - Skillchain_Leader_Last > Skillchain_Leader_Delay then
            log('['..Skillchain_Leader_Name..'] Weaponskill ['..ability.en..'] on ['..data.targets[1].id..'] Follower #1')
            Skillchain_Leader_Last = now
            action = 'skillchain_'..ability.en..'_'..Skillchain_Leader_Name..'_'..data.targets[1].id
            table.insert(player_task_data, action)
			log(action)
        elseif data.actor_id == Skillchain_Leader_ID_2 and ability.en == Skillchain_Leader_WS_2 and now - Skillchain_Leader_Last_2 > Skillchain_Leader_Delay_2 then
            log('['..Skillchain_Leader_Name_2..'] Weaponskill ['..ability.en..'] on ['..data.targets[1].id..'] Follower #2')
            Skillchain_Leader_Last_2 = now
            action = 'skillchain2_'..ability.en..'_'..Skillchain_Leader_Name_2..'_'..data.targets[1].id
            table.insert(player_task_data, action)
			log(action)
        elseif data.actor_id == Skillchain_Leader_ID_3 and ability.en == Skillchain_Leader_WS_3 and now - Skillchain_Leader_Last_3 > Skillchain_Leader_Delay_3 then
            Skillchain_Leader_Last_3 = now
            log('['..Skillchain_Leader_Name_3..'] Weaponskill ['..ability.en..'] on ['..data.targets[1].id..'] Follower #3')
            action = 'skillchain3_'..ability.en..'_'..Skillchain_Leader_Name_3..'_'..data.targets[1].id
            table.insert(player_task_data, action)
			log(action)
        elseif data.actor_id == Skillchain_Leader_ID_4 and ability.en == Skillchain_Leader_WS_4 and now - Skillchain_Leader_Last_4 > Skillchain_Leader_Delay_4 then
            log('['..Skillchain_Leader_Name_4..'] Weaponskill ['..ability.en..'] on ['..data.targets[1].id..'] Follower #4')
            Skillchain_Leader_Last_4 = now
            action = 'skillchain4_'..ability.en..'_'..Skillchain_Leader_Name_4..'_'..data.targets[1].id
            table.insert(player_task_data, action)
			log(action)
        end
    end
end

function run_spell_check(data)
    local ability = all_spells[data.param]
    local now = os.clock()
    if ability then
        if data.actor_id == Skillchain_Leader_ID and ability.en == Skillchain_Leader_WS and now - Skillchain_Leader_Last > Skillchain_Leader_Delay then
            log('['..Skillchain_Leader_Name..'] skillchain with spell ['..ability.en..'] on ['..data.targets[1].id..'] for Follower #1')
            Skillchain_Leader_Last = now
            action = 'skillchain_'..ability.en..'_'..Skillchain_Leader_Name..'_'..data.targets[1].id
            table.insert(player_task_data, action)
			log(action)
        elseif data.actor_id == Skillchain_Leader_ID_2 and ability.en == Skillchain_Leader_WS_2 and now - Skillchain_Leader_Last_2 > Skillchain_Leader_Delay_2 then
            log('['..Skillchain_Leader_Name_2..'] skillchain with spell ['..ability.en..'] on ['..data.targets[1].id..'] for Follower #2')
            Skillchain_Leader_Last_2 = now
            action = 'skillchain2_'..ability.en..'_'..Skillchain_Leader_Name_2..'_'..data.targets[1].id
            table.insert(player_task_data, action)
			log(action)
        elseif data.actor_id == Skillchain_Leader_ID_3 and ability.en == Skillchain_Leader_WS_3 and now - Skillchain_Leader_Last_3 > Skillchain_Leader_Delay_3 then
            log('['..Skillchain_Leader_Name_3..'] skillchain with spell ['..ability.en..'] on ['..data.targets[1].id..'] for Follower #3')
            Skillchain_Leader_Last_3 = now
            action = 'skillchain3_'..ability.en..'_'..Skillchain_Leader_Name_3..'_'..data.targets[1].id
            table.insert(player_task_data, action)
			log(action)
        elseif data.actor_id == Skillchain_Leader_ID_4 and ability.en == Skillchain_Leader_WS_4 and now - Skillchain_Leader_Last_4 > Skillchain_Leader_Delay_4 then
            log('['..Skillchain_Leader_Name_4..'] skillchain with spell ['..ability.en..'] on ['..data.targets[1].id..'] for Follower #4')
            Skillchain_Leader_Last_4 = now
            action = 'skillchain4_'..ability.en..'_'..Skillchain_Leader_Name_4..'_'..data.targets[1].id
            table.insert(player_task_data, action)
			log(action)
        end
    end
end

function skillchain_property(name, target)
    local now = os.clock()
    if Skillchain_Leader_WS == name and Skillchain_Leader_Last > Skillchain_Leader_Delay then
        log('['..name..'] on ['..target..'] Follower #1')
        Skillchain_Leader_Last = now
        action = 'skillchain_'..name..'_Anyone_'..target
        table.insert(player_task_data, action)
		log(action)
    elseif Skillchain_Leader_WS_2 == name and Skillchain_Leader_Last_2 > Skillchain_Leader_Delay_2 then
        log('['..name..'] on ['..target..'] Follower #2')
        Skillchain_Leader_Last_2 = now
        action = 'skillchain2_'..name..'_Anyone_'..target
        table.insert(player_task_data, action)
		log(action)
    elseif Skillchain_Leader_WS_3 == name and Skillchain_Leader_Last_3 > Skillchain_Leader_Delay_3 then
        log('['..name..'] on ['..target..'] Follower #3')
        Skillchain_Leader_Last_3 = now
        action = 'skillchain3_'..name..'_Anyone_'..target
        table.insert(player_task_data, action)
	    log(action)
    elseif Skillchain_Leader_WS_4 == name and Skillchain_Leader_Last_4 > Skillchain_Leader_Delay_4 then
        log('['..name..'] on ['..target..'] Follower #4')
        Skillchain_Leader_Last_4 = now
        action = 'skillchain4_'..name..'_Anyone_'..target
        table.insert(player_task_data, action)
	    log(action)
    end
end