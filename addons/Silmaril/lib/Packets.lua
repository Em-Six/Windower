function message_in(id, original, modified, injected, blocked)
    if id == 0x00A then -- Zone update
		zoning = false
        log("Zoning ["..tostring(zoning).."]")
    elseif id == 0x00B then -- Zone Response
		zoning = true
        move_to_exit = false
        log("Zoning ["..tostring(zoning).."]")
    elseif id == 0x03C then -- Shop
        log("Stop injectging from [0x03C] - Shop")
        injecting = false
    elseif id == 0x05C then -- Dialog information
        if injecting then
            local packet = packets.parse('incoming', original)
            log("npc_inject() called from [0x05C]")
            npc_inject()
        end
    elseif id == 0x028 then -- Action
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
    elseif id == 0x029 then -- Action Message
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
    elseif id == 0x032 or id == 0x033 or id == 0x034 then -- NPC Interaction
        -- This is in response to the client sending a Action packet to start interaction.
        if injecting then
            local packet = packets.parse('incoming', original)
            menu_id = packet['Menu ID']
            release_packet = packets.new('outgoing', 0x05B, 
            {
                ['Target'] = packet['NPC'],
                ['Option Index'] = 0,
                ['Target Index'] = packet['NPC Index'],
                ['Automated Message'] = false,
                ['Zone'] = packet['Zone'],
                ['Menu ID'] = packet['Menu ID'],
            })
            log("Release Packet Built")
            packet_log(release_packet)
            if id == 0x032 then
                log("npc_inject() called from [0x032]")
            elseif id == 0x033 then
                log("npc_inject() called from [0x033]")
            elseif id == 0x034 then
                log("npc_inject() called from [0x034]")
            end
            -- Send the first request in response to the NPC interaction
            npc_inject()
        end
    elseif id == 0x037 then -- Update Character
        if injecting then
            local packet = packets.parse('incoming', original)
            if packet['Status'] ~= 4 then -- Status 4 is Event
                if #mirror_message == 0 then -- All messages were sent
                    log("Player is released from menu")
                    injecting = false
                end
            end
        end
        if player_mirror then
            local packet = packets.parse('incoming', original)
            if packet['Status'] ~= 4 and mirroring and message_time + 1 < os.clock() then -- Status 4 is Event
                log("Mirror off via [0x037] packet")
                npc_in_complete()
                mirroring = false
            elseif packet['Status'] == 4 then
                -- Start the mirroring actions
                mirroring = true
            end
        end
    elseif id == 0x03E then  -- Open Buy/Sell
        if player_mirror then
            log("npc_buy() called from [0x03E]")
            npc_buy()
        end
    elseif id == 0x03F then -- Shop Buy Response
        --log("npc_in_complete() called from [0x03F]")
        --npc_in_complete()
    elseif id == 0x052 then -- NPC Release
        log("NPC Release recieved")
        local packet = packets.parse('incoming', original)
        if injecting then
            npc_in_release(packet)
        end
    elseif id == 0x063 then -- Player buff duration
        if original:byte(0x05) == 0x09 then
            local packet = packets.parse('incoming', original)
            local formattedString = "playerbuffs_"
            player_buffs = {}
            for i=1,32 do
                local buff = 'Buffs '..tostring(i)
                local duration = 'Time '..tostring(i)
                if packet[buff] ~= 255 and packet[buff] ~= 0 then
                    local buff_id = packet[buff]
                    local end_time = bufftime(packet[duration])
                    formattedString = formattedString..buff_id..','..end_time..'|'
                    --log('Buff ['..buff_id..'] End Time ['..end_time..']')
                end
            end
            player_buffs = formattedString:sub(1, #formattedString - 1) -- remove last character
        end
    elseif id == 0x076 then -- Buffs
        run_buffs(id, original) -- via Buffs.lua
    elseif id == 0x0F9 then -- Reraise Dialog
        local packet = packets.parse('incoming', original)
        if packet['Category'] == 1 then 
            log("Reraise Menu")
            local action = player.name..';packet_reraise_'
            send_packet(action)
        end
    end
end

function message_out(id, original, modified, injected, blocked)
    if id == 0x01A then -- Action
        local packet = packets.parse('outgoing', original)  
        if packet['Category'] == 0x00 then  -- NPC Interaction
            if player_mirror then
                mirroring = true
                message_time = os.clock()
                npc_interact(packet)
            end
        elseif packet['Category'] == 0x02 then  -- Engage monster
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
            if not player.target_index then
                player.target_index = 0
            end
            local action = player.name..';packet_disengage_'..player.target_index
            log(action)
            send_packet(action)
            player_attack_target = "attacking_0"
        end
    elseif id == 0x00D then
        if player_mirror and mirroring then
            log("Leaving zone - finish mirror")
            injecting = false
            mirroring = false
            npc_in_complete()
        end
    elseif id == 0x05B then  -- User dialog
        local packet = packets.parse('outgoing', original)  
        if player_mirror and mirroring then
            npc_out_dialog(packet)
        end
    elseif id == 0x05C then  -- Warp request
        local packet = packets.parse('outgoing', original)  
        if player_mirror and mirroring then
            npc_out_warp(packet)
        end
    elseif id == 0x05E then -- Zone
        local packet = packets.parse('outgoing', original)
        zoning = true
        player_info()
        player_location = windower.ffxi.get_mob_by_id(player.id)
        windower.send_ipc_message('zone '..player_location.id..' '..world.zone..' '..player_location.x..' '..player_location.y..' '..player_location.z..' '..packet['Type']..' '..packet['Zone Line'])
        log("IPC zone line sent")
        player_attack_target = "attacking_0"
    elseif id == 0x036 and false then -- Menu Item (Trade)
        if player_mirror then
            mirroring = true
            local packet = packets.parse('outgoing', original)
            local items = windower.ffxi.get_items(0)
            local formattedString = ","
            for i=0,9 do
                local item = 'Item Index '..tostring(i)
                local item_count = 'Item Count '..tostring(i)
                if items[packet[item]] then -- found in inventory
                    local inv_item = items[packet[item]].id
                    local inv_count = packet[item_count]
                    formattedString = formattedString..inv_item..'|'..inv_count..','
                end
            end
            formattedString = formattedString:sub(1, #formattedString - 1) -- remove last character
            npc_interact(packet) -- Start the mirroring actions
            npc_out_trade(packet, formattedString) -- Send the trade message
        end
    elseif id == 0x083 then -- Buy Item
        if player_mirror and false then
            local packet = packets.parse('outgoing', original)
            npc_out_buy(packet)
            log("npc_out_buy() called from [0x083]")
        end
    end
end

function packet_log(packet)
    for index, item in pairs(packet) do
        if not string.find(tostring(index), "_") then
            log("Packet: ["..tostring(index)..'] ['..tostring(item)..']')
        end
    end
end