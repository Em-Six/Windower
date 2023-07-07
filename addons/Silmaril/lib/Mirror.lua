do
    local sent_messages = {} -- Holds the packets that were sent
    local retry_count = 1
    local message_count = 0
    local single_mirror = true

------------------------ MIRRORER SECTION ----------------------------------------------

    -- 0x01A action packet with Param 0x00 via the outgoing packet
    -- This packet is generated when a player starts an interaction with NPC and mirroring is enabled
    function npc_interact(packet)
        sent_messages = {}
        mirror_message = {}
	    mirror_target = windower.ffxi.get_mob_by_id(packet['Target'])
        mirror_target.zone = world.zone
        local action = player.name..';packet_npc_interact'
        log('NPC Interaction Starting')
        mirroring_state = "Starting"
        send_packet(action) -- used to clear a buffer in Silmaril
        packet_log(packet)
    end

    function npc_buy()
        sent_messages = {}
        mirror_message = {}
	    mirror_target = player
        mirror_target.name = "NPC Buy"
        mirror_target.x = player_location.x
        mirror_target.y = player_location.y
        mirror_target.z = player_location.z
        mirror_target.zone = world.zone
        local action = player.name..';packet_npc_interact'
        log('NPC Interaction Starting')
        mirroring_state = "Starting"
        send_packet(action) -- used to clear a buffer
    end

    -- 0x05B
    -- This function sends the menu selection of the player to silmaril to build the menu transactions
    function npc_out_dialog(packet)
	    local action = player.name..';packet_npc_dialog_0x05B,'..packet['Target']..','..packet['Option Index']..','..packet['_unknown1']..','
        ..packet['Target Index']..','..tostring(packet['Automated Message'])..','..packet['_unknown2']..','..packet['Zone']..','..packet['Menu ID']
        log('Mirroring Dialog [0x05B]')
        send_packet(action)
        packet_log(packet)
    end

    -- 0x05C
    -- This function is for a warp request to silmaril
    function npc_out_warp(packet)
	    local action = player.name..';packet_npc_warp_0x05C,'..packet['X']..','..packet['Y']..','..packet['Z']..','..packet['Target ID']..','
        ..packet['_unknown1']..','..packet['Zone']..','..packet['Menu ID']..','..packet['Target Index']..','..packet['_unknown2']..','..packet['Rotation']
        log('Mirroring Warp [0x05C]')
        send_packet(action)
        packet_log(packet)
    end

    -- 0x036
    -- This functin is for trading
    function npc_out_trade(packet, formattedString)
	    local action = player.name..';packet_npc_trade_0x036,'..packet['Target']..','..packet['Target Index']..formattedString
        log('Mirroring Trade [0x036]')
        send_packet(action)
        packet_log(packet)
    end

    -- 0x083
    -- This functin is for buy/sell items
    function npc_out_buy(packet)
	    local action = player.name..';packet_npc_buy_0x083,'..packet['Count']..','..packet['_unknown2']..','..packet['Shop Slot']..','..packet['_unknown3']..','..packet['_unknown4']
        log('Mirroring Buy [0x083]')
        send_packet(action)
        packet_log(packet)
    end

    -- Once a NPC interaction is completed the server send a 0x037 packets with the player state change (4 -> 0)
    function npc_in_complete()
        local action = player.name..';packet_npc_send_'..mirror_target.index..','..mirror_target.x..','..mirror_target.y..','..mirror_target.z..','..mirror_target.zone
        log('NPC interaction completed')
        mirroring_state = "Completed"
        send_packet(action)
        if single_mirror then
            player_mirror = false
            log("Turning off mirroring")
        end
    end



------------------------ INJECTION SECTION ----------------------------------------------


    -- Build the message que for when server asks for it.
    -- Only send the action packet here
    function npc_build_message(target, message)
        mirror_target = target
        mirror_target.zone = world.zone
        retry_count = 1
        sent_messages = {}
        mirror_message = {}
        local packet_out = {}
        -- Builds the messages into a table
        for item in string.gmatch(message, "([^|]+)") do
            table.insert(mirror_message, item)
        end
        message_count = #mirror_message
        for item in string.gmatch(mirror_message[1], "([^,]+)") do
            table.insert(packet_out, item)
        end
        if packet_out[1] == "0x05B" or packet_out[1] == "0x05C" then -- Dialog
            injecting = true
            mirror_blocked = true
            -- Start the interation
            local packet = packets.new('outgoing', 0x01A, 
            {
                ['Target'] = mirror_target.id,
                ['Target Index'] = mirror_target.index,
                ['Category'] = 0x00,
                ['Param'] = 0
            })
            packets.inject(packet)
            message_time = os.clock()
            mirroring_state = "Injecting [0x01A]"
            log(mirroring_state)
            packet_log(packet)
        elseif packet_out[1] == "0x036" then
            injecting = false
            log("Trade Action")
            -- Call NPC inject straight from here
        end
    end

    -- Called if an event release is not detected
    function npc_retry()
        if injecting then
            retry_count = retry_count + 1
            local packet = packets.new('outgoing', 0x01A, 
            {
                ['Target'] = mirror_target.id,
                ['Target Index'] = mirror_target.index,
                ['Category'] = 0x00,
                ['Param'] = 0
            })
            packets.inject(packet)
            message_time = os.clock()
            mirroring_state = "Injecting [0x01A] - Retry"
            log(mirroring_state)
            packet_log(packet)
        end
    end

    -- Once a 0x032/0x033/0x034 Packet is recieved from the initial Action always first 0x05B Packet sent
    -- Once a follow up 0x05C is recieved send the next dialog reqest/warp
    function npc_inject()
        if injecting and #mirror_message > 0 then
            local packet_out = {}
		    for item in string.gmatch(mirror_message[1], "([^,]+)") do
                table.insert(packet_out, item)
            end
            if packet_out[1] == "0x05B" and tonumber(menu_id) ~= tonumber(packet_out[9]) then
                info("Incorrect Menu - Player Cannot Mirror")
                log("Player Menu ["..menu_id..'] and Mirror Menu ['..packet_out[9]..']')
                sent_messages = {}
                mirror_message = {}
            elseif packet_out[1] == "0x05B" then
                local automated = false
                if packet_out[6] == 'true' then automated = true end
                local packet = packets.new('outgoing', 0x05B, 
                {
                    ['Target'] = tonumber(packet_out[2]),
                    ['Option Index'] = tonumber(packet_out[3]),
                    ['_unknown1'] = tonumber(packet_out[4]),
                    ['Target Index'] = tonumber(packet_out[5]),
                    ['Automated Message'] = automated,
                    ['_unknown2'] = packet_out[7],
                    ['Zone'] = tonumber(packet_out[8]),
                    ['Menu ID'] = tonumber(packet_out[9]),
                })
                packets.inject(packet)
                message_time = os.clock()
                table.insert(sent_messages, packet)
                table.remove(mirror_message,1)
                mirroring_state = "Injecting [0x05B] ("..#sent_messages..' of '..message_count..')'
                log(mirroring_state)
                packet_log(packet)
            elseif packet_out[1] == "0x05C" then
                local packet = packets.new('outgoing', 0x05C, 
                {
                    ['X'] = tonumber(packet_out[2]),
                    ['Y'] = tonumber(packet_out[3]),
                    ['Z'] = tonumber(packet_out[4]),
                    ['Target ID'] = tonumber(packet_out[5]),
                    ['_unknown1'] = tonumber(packet_out[6]),
                    ['Zone'] = tonumber(packet_out[7]),
                    ['Menu ID'] = tonumber(packet_out[8]),
                    ['Target Index'] = tonumber(packet_out[9]),
                    ['_unknown2'] = packet_out[10],
                    ['Rotation'] = packet_out[11],
                })
                packets.inject(packet)
                message_time = os.clock()
                table.insert(sent_messages, packet)
                table.remove(mirror_message,1)
                mirror_message = {} --Testing only injecting one warp packet and letting client close from warp
                mirroring_state = "Injecting [0x05C] ("..#sent_messages..' of '..message_count..')'
                log(mirroring_state)
                packet_log(packet)
            elseif packet_out[1] == "0x083" then
                local packet = packets.new('outgoing', 0x083, 
                {
                    ['Count'] = tonumber(packet_out[2]),
                    ['_unknown2'] = tonumber(packet_out[3]),
                    ['Shop Slot'] = tonumber(packet_out[4]),
                    ['_unknown3'] = tonumber(packet_out[5]),
                    ['_unknown4'] = tonumber(packet_out[6]),
                })
                packets.inject(packet)
                message_time = os.clock()
                table.insert(sent_messages, packet)
                table.remove(mirror_message,1)
                mirroring_state = "Injecting [0x083] ("..#sent_messages..' of '..message_count..')'
                log(mirroring_state)
                packet_log(packet)
            end
        end
    end

    function npc_in_release(packet)
        if packet['Type'] == 0x00 then
            log('NPC Release [Standard]')
            if retry_count < 11 then
                log("Retry Menu ["..retry_count..'/10]')
                npc_retry()
                send_packet(player.name..";packet_npc_status_retry_"..retry_count)
            else
                info("Mirroring Failed - Reseting")
                npc_reset()
                send_packet(player.name..";packet_npc_status_failed")
            end
        elseif packet['Type'] == 0x01 then
            log('NPC Release [Event]')
            if #mirror_message == 0 then
                log("Injecting completed")
                injecting = false
                npc_reset()
                send_packet(player.name..";packet_npc_status_completed")
            else
                npc_inject()
                send_packet(player.name..";packet_npc_status_inject")
            end
        elseif packet['Type'] == 0x02 then
            log('NPC Release [Event Skipped]')
            if #mirror_message == 0 then
                log("Injecting completed")
                injecting = false
                npc_reset()
                send_packet(player.name..";packet_npc_status_completed")
            else
                npc_reset()
                send_packet(player.name..";packet_npc_status_failed")
            end
        elseif packet['Type'] == 0x03 then
            log('NPC Release [String Event]')
            if #mirror_message == 0 then
                log("Injecting completed")
                injecting = false
                npc_reset()
                send_packet(player.name..";packet_npc_status_completed")
            else
                npc_inject()
                send_packet(player.name..";packet_npc_status_inject")
            end
        elseif packet['Type'] == 0x04 then
            log('NPC Release [Fishing]')
        end
    end

    function npc_reset()
        if release_packet then
            injecting = false
            log("Silmaril Reset - Trying to release")
            packets.inject(release_packet)
            packet_log(release_packet)
        else
            log("No release packet was made.")
        end
    end

    function packet_log(packet)
        for index, item in pairs(packet) do
            if not string.find(tostring(index), "_") then
                log("Packet: ["..tostring(index)..'] ['..tostring(item)..']')
            end
        end
    end

    function npc_mirror_state(state)
        if state == 1 then
            single_mirror = true
            log("Mirror State is single use")
        elseif state == 2 then
            single_mirror = false
            log("Mirror State is multiple use")
        end
    end
end