do
    local old_pos = {x=0, y=0, z=0} -- Stores last movement location
    local player_buffs = "playerbuffs_"
    local motion = false
    local player = {}
    local player_location = {}
    local stop_time = os.clock()
    local player_moving = false

    -- Used to calculate buff durations
    local epoc_now = os.time() -- Offset from 
    local hour, min = (os.difftime(epoc_now, os.time(os.date('!*t', epoc_now))) / 3600):modf()
    local timezone = '%+.2d:%.2d':format(hour, 60 * min)
    local fn = function(ts) return os.date('%Y-%m-%dT%H:%M:%S' .. timezone, ts) end
    local time = function(ts) return fn(os.time() - ts) end
    local bufftime = function(ts) return fn(1009810800 + (ts / 60) + 0x100000000 / 60 * 9) end

    function update_player_info()

        -- This is updated at high speed
        local now = os.clock()

        -- get/set the world data
        local w = windower.ffxi.get_info()
        set_world(w)
        if not w then return end

        player = windower.ffxi.get_player()
        if not player then return end

        player_location = windower.ffxi.get_mob_by_id(player.id)
        if not player_location then return end

        -- Determine if player is moving
        local movement = math.sqrt((player_location.x-old_pos.x)^2 + (player_location.y-old_pos.y)^2 + (player_location.z-old_pos.z)^2 ) > 0.025

        -- Change of state
        if movement and not motion then
	        motion = true
        elseif not movement and motion then
            stop_time = now
	        motion = false
        end

        if not motion and now - stop_time > .25 then 
            player_moving = false
        else
            player_moving = true
        end

        -- Store the old location
   	    old_pos.x = player_location.x
	    old_pos.y = player_location.y
	    old_pos.z = player_location.z

        --target_index
        if not player.target_index then
            player.target_index = 0
        end

        -- Create a player to update the IPC table
        local character = { 
            id = player.id,
            name = get_player_name(), 
            zone = w.zone, 
            x = player_location.x, 
            y = player_location.y, 
            z = player_location.z, 
            heading = player_location.heading, 
            status = player.status,
            target_index = player.target_index}

        -- Update the party table with your information
		set_party_location(character)

        --Send the information to others via IPC
	    windower.send_ipc_message('update '..
            player.id..' '..
            get_player_name()..' '..
            w.zone..' '..
            round(player_location.x,3)..' '..
            round(player_location.y,3)..' '..
            round(player_location.z,3)..' '..
            round(player_location.heading,3)..' '..
            player.status..' '..
            player.target_index)
    end

    function get_player_info()
        local player_info = "player_"
        local jp_spent = player.job_points[player.main_job:lower()].jp_spent
        local locked_on = false

        --target_locked
        if player.target_locked then
            locked_on = true
        end

        -- No sub job unlocked or Oddy
        if not player.sub_job_id then
            player.sub_job_id = 0
            player.sub_job_level = 0
        end

        -- Update character status
        player_info = 'player_'..
            tostring(player.main_job_id)..','..
            tostring(player.main_job_level)..','..
            tostring(player.sub_job_id)..','..
            tostring(player.sub_job_level)..','..
            tostring(jp_spent)..','..
            tostring(locked_on)..','..
            tostring(player_moving)..','..
            tostring(get_following())..','..
            tostring(get_autorun_target())..','..
            tostring(get_autorun_type())..','..
            tostring(get_mirroring())..','..
            tostring(get_injecting())..','

        return player_info
    end

    function first_time_buffs()
        local formattedString = "playerbuffs_"
        local p = get_player()
        if p then
            local intIndex = 1
            for index, value in pairs(p.buffs) do
                formattedString = formattedString..tostring(value)..',Unknown'
                if intIndex ~= tablelength(p.buffs) then
                    formattedString = formattedString .."|"
                end
                intIndex = intIndex + 1
            end
        end
        player_buffs = formattedString
    end

    function player_packet_buffs(original)    
        local packet = packets.parse('incoming', original)
        local formattedString = "playerbuffs_"
        for i=1,32 do
            local buff = 'Buffs '..tostring(i)
            local duration = 'Time '..tostring(i)
            if packet[buff] ~= 255 and packet[buff] ~= 0 then
                local buff_id = packet[buff]
                local end_time = bufftime(packet[duration])
                formattedString = formattedString..buff_id..','..end_time..'|'
            end
        end
        player_buffs = formattedString:sub(1, #formattedString - 1)
    end

    function get_moving()
		return moving
	end

    function get_player()
		return player
	end

    function set_player(p)
		player = p
	end

    function get_player_location()
		return player_location
	end

    function set_player_location(loc)
		player_location = loc
	end

    function get_player_buffs()
        return player_buffs
    end

    function get_player_name()

        -- Something wrong happened here - couldn't find the player
        if not player or not player.name then info("Player not found") return "Unknown" end

        -- return the normal name if protection off
        if not get_protection() then return player.name end

        -- Protection is on so get the reverse name
        local cache = get_name_cache()

        -- No table is set so return default name
        if not cache then log("No name cache set") return player.name end

        if cache[player.name] then return cache[player.name] end

        -- Wasn't found in table so return normal name anyway
        log("Couldn't find the name in the protection cache")
        return player.name
    end

    function get_player_id()
        if player and player.id then
            return player.id
        else
            return 0
        end
    end
end