function input_message(type, index, param, option)

    local target = windower.ffxi.get_mob_by_index(index)
    if not target then
        target = windower.ffxi.get_mob_by_id(index)
        if not target then
            local pt_loc = get_party_location()
            target = pt_loc[tonumber(index)]
            if not target then
                log("Target not found Type: ["..type.."] Index ["..index.."] Param ["..param.."] Option ["..option.."]")
                return
            else
                log("Using Party Table")
            end
        end
    end

	if type == "JobAbility" then
        Action_Message('0x09',target,param)

	elseif type == "Magic" then
        if not target.valid_target then return end
        if math.sqrt(target.distance) > 22 then return end
        Action_Message('0x03',target,param)

	elseif type == "WeaponSkill" then
        if not target.valid_target then return end
        Action_Message('0x07',target,param)

	elseif type == "Engage" then
        if not target.valid_target then return end
        if target.spawn_type ~= 16 then return end
        if math.sqrt(target.distance) > 30 then return end
        if target.hpp == 0 then return end
        Action_Message('0x02',target,param)

    elseif type == "Assist" then
        if not target.valid_target then return end
        if target.spawn_type ~= 16 then return end
        if math.sqrt(target.distance) > 30 then return end
        if target.hpp == 0 then return end
        Action_Message('0x0C',target,"")

    elseif type == "Switch" then
        if not target.valid_target then return end
        if target.spawn_type ~= 16 then return end
        if math.sqrt(target.distance) > 30 then return end
        if target.hpp == 0 then return end
        Action_Message('0x0F',target,param)

    elseif type == "AcceptRaise" then
        Action_Message('0x0D',target,param)

    elseif type == "Shoot" then
        if not target.valid_target then return end
        if target.spawn_type ~= 16 then return end
        if math.sqrt(target.distance) > 30 then return end
        if target.hpp == 0 then return end
        Action_Message('0x10',target,param)

	elseif type == "Disengage" then
        Action_Message('0x04',target,param)

	elseif type == "RunAway" then -- done via Moving.lua
        runaway(target,param)

    elseif type == "RunTo" then -- done via Moving.lua
        runto(target,param)

    elseif type == "RunToLocation" then -- done via Moving.lua
        runtolocation(target,param,option)

    elseif type == "RunStop" then -- done via Moving.lua
        runstop()

    elseif type == "FastFollow" then -- done via Moving.lua
        if option == "True" then
            set_fast_follow(true, target)
        else
            set_fast_follow(false, target)
        end

    elseif type == "Face" then -- done via Moving.lua
        face_target(target, param)

    elseif type == "LockOn" then -- done via Moving.lua
        if not target.valid_target then return end
        if math.sqrt(target.distance) > 50 then return end
        lockon(target,param)

    elseif type == "Cancel" then
        windower.packets.inject_outgoing(0xF1,string.char(0xF1,0x04,0,0,tostring(param)%256,math.floor(tostring(param)/256),0,0))
		log("Cancel ["..tostring(param)..']')

    elseif type == "Script" then
        if not option then log("Script missing option text") return end
        Action_Message('0x??',target,option)

    elseif type == "RawInput" then
        Action_Message('raw',target,option)

    elseif type == "Item" then
        Action_Message('0x037',target,param)

    elseif type == "Message" then
        if param == "0" then windower.send_command('input /tell '..target.name..' '..option..'') -- Tell
        elseif param == "1" then windower.send_command('input /party '..option..'') -- Party
        elseif param == "2" then windower.send_command('input /echo '..option..'') -- Echo player only
        elseif param == "3" then windower.send_command('input /echo '..option..'') windower.send_ipc_message('message '..option) end -- Echo party

    elseif type == "Mirror" then
        Mirror_Message(target, param, option)

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
        command = 'input /ja "'..get_ability(tonumber(param)).en..'" '..target.id
        windower.send_command(command)
        log(command)
    elseif category == '0x07' then
        command = 'input /ws "'..get_weaponskill(tonumber(param)).en..'" '..target.id
        windower.send_command(command)
        log(command)
    elseif category == '0x037' then
        command = 'input /item "'..get_item(tonumber(param)).en..'" '..target.id
        windower.send_command(command)
        log(command)
    elseif category == '0x03' then
        command = 'input /ma "'..get_spell(tonumber(param)).en..'" '..target.id
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
    elseif category == 'raw' then
        windower.send_command(param)
        log(param)
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

function Mirror_Message(target, param, option)
    local type =  tonumber(param)

    -- License was not found
    if type == 0 then
        windower.add_to_chat(80,'------- License Not Found -------')

    -- Turns on/off Mirroring
    elseif type == 1 then
        if get_mirror_on() then
            set_mirror_on(false)
            windower.add_to_chat(1, ('\31\200[\31\05Silmaril\31\200]\31\207'..' Mirror: \31\03[OFF]'))
        else
            set_mirror_on(true)
            windower.add_to_chat(1, ('\31\200[\31\05Silmaril\31\200]\31\207'..' Mirror: \31\06[ON]'))
        end
        clear_npc_data()
        npc_box_status() -- done via Display.lua
        send_packet(get_player_id()..";mirror_off") -- Send to other players to turn off via Silmaril.exe

    -- Inject messages
    elseif type == 2 then
        clear_npc_data()
        set_injecting(true)
        npc_build_message(target, option)

    -- Spare
    elseif type == 3 then


    -- Turn off mirroring for other toons
    elseif type == 4 then 
        set_mirror_on(false)
        clear_npc_data()
        npc_box_status()

    -- Turn off screen
    elseif type == 5 then 
        sm_result_hide()
        clear_npc_data()

    end
end

