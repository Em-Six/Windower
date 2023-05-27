function message_in(id, original)
    if id == 0x076 then -- Buffs
        run_buffs(id, original) -- via Buffs.lua
    elseif id == 0x028 then -- Action
        --[[
        Action packets
        [1] = 'Melee attack',
        [2] = 'Ranged attack finish',
        [3] = 'Weapon Skill finish',
        [4] = 'Casting finish',
        [5] = 'Item finish',
        [6] = 'Job Ability',
        [7] = 'Weapon Skill start',
        [8] = 'Casting start',
        [9] = 'Item start',
        [11] = 'NPC TP finish',
        [12] = 'Ranged attack start',
        [13] = 'Avatar TP finish',
        [14] = 'Job Ability DNC',
        [15] = 'Job Ability RUN',
        ]]--
        local data = windower.packets.parse_action(original)
        if data.actor_id == player.id then
            -- [2] = 'Ranged attack finish'
            if data.category == 2 and data.param == 26739 then
                action = player.name..';shooting_finished_2_Ranged Attack_'..data.targets[1].id
                send_packet(action)
                log("PACKET: Shooting Finished")
            -- [3] = 'Weapon Skill finish'
            elseif data.category == 3 and data.param ~= 0 then
                ability = all_weapon_skills[data.param]
                if ability and ability.en then
                    action = player.name..';weaponskill_blocked_'..ability.id..'_'..ability.en..'_'..data.targets[1].id
                    send_packet(action)
                    log('PACKET: Weaponskill ['..ability.en..'] on target ['..data.targets[1].id..']')
                end
            -- [4] = 'Casting finish'
            elseif data.category == 4 then
                action = player.name..';casting_finished_'..data.param..'_'..data.targets[1].id..'_'..data.targets[1].actions[1].message
                send_packet(action)
                log('PACKET: Casting has finished')
            -- [5] = 'Item finish'
            elseif data.category == 5 then
                action = player.name..';item_finished'
                send_packet(action)
                log("PACKET: Item Finished")
            -- [6] = 'Job Ability'
            elseif data.category == 6 then
			    ability = all_job_abilities[data.param]
			    if ability and ability.en and ability.id then
                    action = player.name..';jobability_blocked_'..ability.id..'_'..ability.en..'_'..data.targets[1].id
                    send_packet(action)
                    log('PACKET: Job Ability ['..ability.en..'] on target ['..data.targets[1].id..']')
			    end
            -- [8] = 'Casting start'
            elseif data.category == 8 then
                if data.param == 28787 then -- Spell Intrupted
                    if data.targets[1].actions[1].param ~= 0 then
						ability = all_spells[data.targets[1].actions[1].param]
                        if ability and ability.en then
                            action = player.name..';casting_interrupted_'..ability.id..'_'..ability.en..'_'..data.targets[1].id
                            send_packet(action)
                            log("PACKET: Casting was interrupted")
                        end
                    end
                elseif data.param == 24931 then -- Casting Spell
                    if data.targets[1].actions[1].param ~= 0 then
						ability = all_spells[data.targets[1].actions[1].param]
						if ability and ability.en then
                            action = player.name..';casting_blocked_'..ability.id..'_'..ability.en..'_'..data.targets[1].id..'_'..tostring(ability.cast_time + 2.1)
                            send_packet(action)
                            log('PACKET: Casting Spell ['..ability.en..'] on target '..data.targets[1].id)
						end
					end
                end
            -- [9] = 'Item start'
            elseif data.category == 9 then
                if data.param == 28787 then
                    action = player.name..';item_interrupted'
                    send_packet(action)
                    log("PACKET: Item use interrupted")
                else
                    action = player.name..';item_blocked'
                    send_packet(action)
                    log("PACKET: Item use started")
                end
            elseif data.category == 12 then
            -- [12] = 'Ranged attack start'
                if data.param == 24931 then -- shooting
                    action = player.name..';shooting_blocked_2_Ranged Attack_'..data.targets[1].id
                    send_packet(action)
                    log("PACKET: Shooting")
                elseif data.param == 28787 then -- interrupted
                    action = player.name..';shooting_interrupted_2_Ranged Attack_'..data.targets[1].id
                    send_packet(action)
                    log("PACKET: Shooting interrupted")
                end
            end
        end
        if data.category == 3 and data.param ~= 0 then -- Monitor others for Weaponskills and Skillchains
            run_skillchain_check(data)
            run_burst(data)
        elseif data.category == 4 then -- Monitor others for Immanence and Skillchains
            run_spell_check(data)
            run_burst(data)
        end
    elseif id == 0x29 then -- Action Message
        local packet = packets.parse('incoming', original)
        if packet['Message'] == 48 then -- Reraise Fail
            local action = player.name..';packet_castfail_'..packet['Param 1']..'_'..packet['Target']
            log(action)
            send_packet(action)
        elseif packet['Message'] == 206 then -- Effect wears off
            local action = player.name..';packet_statuswears_'..packet['Param 1']..'_'..packet['Target']
            log(action)
            send_packet(action)
        elseif packet['Message'] == 234 then -- Auto Target
            local action = player.name..';packet_autotarget_'..packet['Target Index']
            log(action)
            send_packet(action)
            player_attack_target = "attacking_"..packet['Target Index']
        end
    elseif id == 0x0F9 then -- Reraise Dialog
        local packet = packets.parse('incoming', original)
        if packet['Category'] == 1 then 
            log("Reraise Menu")
            local action = player.name..';packet_reraise_'
            send_packet(action)
        end
    end
end

function message_out(id, original)
    if id == 0x01A then -- Action
        local packet = packets.parse('outgoing', original)  
        if packet['Category'] == 0x02 then  -- Engage monster
            local action = player.name..';packet_engage_'..packet['Target Index']
            log(action)
            send_packet(action)
            player_attack_target = "attacking_"..packet['Target Index']
        elseif packet['Category'] == 0x0F then  -- Switch target
            local action = player.name..';packet_switch_'..packet['Target Index']
            log(action)
            send_packet(action)
            player_attack_target = "attacking_"..packet['Target Index']
        elseif packet['Category'] == 0x04 then  -- Disengage monster
            local action = player.name..';packet_disengage_'..player.target_index
            log(action)
            send_packet(action)
            player_attack_target = "attacking_0"
        end
    elseif id == 0x05E then -- Zone
        local packet = packets.parse('outgoing', original)
        if tonumber(packet['Type']) ~= 3 and player_location then  -- 03 for leaving the MH, 00 otherwise
            player = windower.ffxi.get_player()
            player_location = windower.ffxi.get_mob_by_id(player.id)
            windower.send_ipc_message('zone '..player_location.id..' '..player_location.x..' '..player_location.y)
            log("IPC zone line sent")
            player_attack_target = "attacking_0"
        end
    end
end