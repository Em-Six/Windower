function input_message(type, index, param, option)
    --[[
	enums['action'] = {
        [0x00] = 'NPC Interaction',
        [0x02] = 'Engage monster',
        [0x03] = 'Magic cast',
        [0x04] = 'Disengage',
        [0x05] = 'Call for Help',
        [0x07] = 'Weaponskill usage',
        [0x09] = 'Job ability usage',
        [0x0C] = 'Assist',
        [0x0D] = 'Reraise dialogue',
        [0x0E] = 'Cast Fishing Rod',
        [0x0F] = 'Switch target',
        [0x10] = 'Ranged attack',
        [0x11] = 'Chocobo dig',
        [0x12] = 'Dismount Chocobo',
        [0x13] = 'Tractor Dialogue',
        [0x14] = 'Zoning/Appear', -- I think, the resource for this is ambiguous.
        [0x19] = 'Monsterskill',
        [0x1A] = 'Mount',
    }
    ]]--
    if option then
        log('Input - type ['..type..'], index ['..index..'], param ['..param..'], option ['..option..']')
    else
        log('Input - type ['..type..'], index ['..index..'], param ['..param..']')
    end
    target = windower.ffxi.get_mob_by_index(index)
    if not target then
        target = windower.ffxi.get_mob_by_id(index)
        if not target then
            target = party_location[tonumber(index)]
            if not target then
                log("target not found")
                if following then
                    runStop()
                end
                return
            end
        end
    end
	if type == "JobAbility" then
        Action_Message('0x09',target,param)
		log("Job Ability")
	elseif type == "Magic" then
        if target.valid_target and math.sqrt(target.distance) <= 25 then
            Action_Message('0x03',target,param)
		    log("Magic")
        else
            log(target)
        end
	elseif type == "WeaponSkill" then
        if target.valid_target and math.sqrt(target.distance) <= 23 then
            Action_Message('0x07',target,param)
		    log("Weapon Skill")
        else
            log("Distance is too far to weaponskill")
        end
	elseif type == "Engage" then
        if target.valid_target and target.spawn_type == 16 and math.sqrt(target.distance) <= 30 then
            Action_Message('0x02',target,param)
		    log("Engage")
        else
            log("Distance is too far to attack")
        end
    elseif type == "Assist" then
        if target.valid_target and target.spawn_type == 16 and math.sqrt(target.distance) <= 30 then
            Action_Message('0x0C',target,"")
		    log("Assist")
        else
            log("Distance is too far to attack")
        end
    elseif type == "Switch" then
        if target.valid_target and target.spawn_type == 16 and math.sqrt(target.distance) <= 30 then
            Action_Message('0x0F',target,param)
		    log("Switch")
        else
            log("Switch target not found")
        end
    elseif type == "AcceptRaise" then
            Action_Message('0x0D',target,param)
		    log("Accept Raise")
    elseif type == "Shoot" then
        if target.valid_target and target.spawn_type == 16 and math.sqrt(target.distance) <= 25 then
            Action_Message('0x10',target,param)
		    log("Shoot")
        else
            log("Distance is too far to shoot")
        end
	elseif type == "Disengage" then
            Action_Message('0x04',target,param)
		    log("Disengage")
	elseif type == "RunAway" then
        if target.valid_target and math.sqrt(target.distance) <= 50 then
            -- Call the movement section
            runaway(target,param)
        else
            log("Distance is too far to run")
            runStop()
        end
    elseif type == "RunTo" then
        if target.valid_target and math.sqrt(target.distance) <= 50 then
            -- Call the movement section
            runto(target,param)
        else
            log("Distance is too far to run")
            runStop()
        end
    elseif type == "RunStop" then
        if target.valid_target and math.sqrt(target.distance) <= 50 then
            -- Call the movement section
            runStop()
        else
            log("Stop Running")
            runStop()
        end
    elseif type == "Follow" then
        if target.valid_target and math.sqrt(target.distance) <= 50 then
            -- Call the movement section
            follow(target,param)
        else
            log("Distance is too far to run")
            runStop()
        end
    elseif type == "FastFollow" then
        if player.zone == target.zone or world.mog_house then
            -- Call the movement section
            fastfollow(target,param, option)
        else
            log("Distance is too far to run")
            runStop()
        end
    elseif type == "Face" then
        if target.valid_target and math.sqrt(target.distance) <= 50 then
            -- Call the movement section
            facemob(target)
		    log("Face on")
        else
            log("Distance is too far to face")
        end
    elseif type == "LockOn" then
        if target.valid_target and math.sqrt(target.distance) <= 50 then
            -- Call the lockon section
            lockon(target,param)
		    log("LockOn")
        else
            log("Distance is too far to Lock On to")
        end
    elseif type == "Script" then
        if target.valid_target and math.sqrt(target.distance) <= 25 then
            if option then
                Action_Message('0x??',target,option)
		        log("Script")
            else
                log("Script missing option text")
            end
        else
            log("Distance is too far to execute script")
        end
    elseif type == "Item" then
        if target.valid_target then
            Action_Message('0x037',target,param)
            if option == "Party" then
                log("Warn Party")
                command = 'input /party Item Warning ['..all_items[tonumber(param)].en..']!'
                windower.send_command(command)
            elseif option ~= "" then
                log("Warn Player: "..option)
                command = 'input /tell '..option..' Item Warning ['..all_items[tonumber(param)].en..']!'
                windower.send_command(command)
            end
        else
            log(target)
        end
    elseif type == "Message" then
        if param == "0" then -- Tell
            command = 'input /tell '..target.name..' '..option..''
            windower.send_command(command)
        elseif param == "1" then -- Party
            command = 'input /party '..option..''
            windower.send_command(command)
        elseif param == "2" then -- Echo player only
            command = 'input /echo '..option..''
            windower.send_command(command)
        elseif param == "3" then -- Echo party
            command = 'input /echo '..option..''
            windower.send_command(command)
            windower.send_ipc_message('message '..option)
        end
    elseif type == "Mirror" then
        if target.index == player.index then
            if tonumber(param) == 0 then
                windower.add_to_chat(80,'------- License Not Found -------')
            elseif tonumber(param) == 1 then
                if player_mirror then
                    player_mirror = false
                    mirroring = false
                    mirror_target = {}
                    injecting = false
                    mirror_sequence = false
                    sm_npc:hide()
                    windower.add_to_chat(1, ('\31\200[\31\05Silmaril\31\200]\31\207'..' Mirror: \31\03[OFF]'))
                    windower.send_ipc_message('mirror')
                else
                    player_mirror = true
                    mirror_target = {}
                    injecting = false
                    mirror_sequence = false
                    windower.add_to_chat(1, ('\31\200[\31\05Silmaril\31\200]\31\207'..' Mirror: \31\06[ON]'))
                    windower.send_ipc_message('mirror')
                end
            elseif tonumber(param) == 2 then
               npc_mirror_state(1) -- Mirror once
            elseif tonumber(param) == 3 then
               npc_mirror_state(2) -- Leave active
            end
        else
            npc_build_message(target, option)
        end
	end
end

function Action_Message(category, target, param)
    local command = ""
	if not target then
        log("target not found")
		return
	end
    -- use input commands so that gearswap can swap our gear for us - use target ID
    if category == '0x09' then
        command = 'input /ja "'..all_job_abilities[tonumber(param)].en..'" '..target.id
        windower.send_command(command)
        log(command)
    elseif category == '0x07' then
        command = 'input /ws "'..all_weapon_skills[tonumber(param)].en..'" '..target.id
        windower.send_command(command)
        log(command)
    elseif category == '0x037' then
        command = 'input /item "'..all_items[tonumber(param)].en..'" '..target.id
        windower.send_command(command)
        log(command)
    elseif category == '0x03' then
        command = 'input /ma "'..all_spells[tonumber(param)].en..'" '..target.id
        windower.send_command(command)
        log(command)
    elseif category == '0x10' then
        command = 'input /ra '..target.id
        windower.send_command(command)
        log(command)
    elseif category == '0x??' then
        command = 'input '..param..' '..target.id
        windower.send_command(command)
        log(command)
    else
        packets.inject(packets.new('outgoing', 0x1A, {
			    ['Target'] = target.id,
			    ['Target Index'] = target.index,
			    ['Category'] = category, -- Spell Cast
                ['Param'] = param, -- Spell ID
	    }))
        log("Packet Injected ["..category..'] ['..target.name..']')
    end
end
