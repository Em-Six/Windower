do
    local sent_messages = {} -- Holds the packets that were sent
    local retry_count = 1
    local message_count = 0
    local single_mirror = true
    local action_packet = {}
    local release_packet = {}

------------------------ MIRRORER SECTION ----------------------------------------------

    -- 0x01A action packet with Param 0x00 via the outgoing packet
    -- This packet is generated when a player starts an interaction with NPC and mirroring is enabled
    function npc_interact(packet)
        sent_messages = {}
        mirror_message = {}
	    mirror_target = windower.ffxi.get_mob_by_id(packet['Target'])
        if mirror_target and world.zone then
            mirror_target.zone = world.zone
            local action = player.name..';packet_npc_interact'
            log('NPC Interaction Starting')
            mirroring_state = "Starting"
            sm_result:hide()
            send_packet(action) -- used to clear a buffer in Silmaril
            packet_log(packet)
        end
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
        if mirror_target then
            local action = player.name..';packet_npc_send_'..tostring(mirror_target.index)..','..tostring(mirror_target.x)..','..tostring(mirror_target.y)..','..tostring(mirror_target.z)..','..tostring(mirror_target.zone)
            log('NPC interaction completed')
            mirroring_state = "Completed"
            send_packet(action)
            if single_mirror then
                player_mirror = false
               windower.add_to_chat(1, ('\31\200[\31\05Silmaril\31\200]\31\207'..' Mirror: \31\03[OFF]'))
            end
        end
    end



------------------------ INJECTION SECTION ----------------------------------------------


    -- Build the message que for when server asks for it.
    -- Only send the action packet here
    function npc_build_message(target, message)
        local packet_out = {}
        local packet_out2 = {}
        mirror_target = target
        mirror_target.zone = world.zone
        retry_count = 1
        sent_messages = {}
        mirror_message = {}
        action_packet = {}
        release_packet = {}
        recieved_packet = {}
        menu_id = nil
        -- Builds the messages into a table
        for item in string.gmatch(message, "([^|]+)") do
            table.insert(mirror_message, item)
        end
        -- Parse the first message
        message_count = #mirror_message
        for item in string.gmatch(mirror_message[1], "([^,]+)") do
            table.insert(packet_out, item)
        end
        if packet_out[1] == "0x05B" or packet_out[1] == "0x05C" then -- Dialog
            injecting = true
            -- Start the interation
            action_packet = packets.new('outgoing', 0x01A, 
            {
                ['Target'] = mirror_target.id,
                ['Target Index'] = mirror_target.index,
                ['Category'] = 0x00,
                ['Param'] = 0
            })
            packets.inject(action_packet)
            message_time = os.clock()
            mirroring_state = "Injecting [0x01A]"
            log(mirroring_state)
            packet_log(action_packet)
        elseif packet_out[1] == "0x036" then
            injecting = false
            log("Trade Action")
            -- Call NPC inject straight from here
        end
        -- Parse the last message (should be a release)
        for item in string.gmatch(mirror_message[#mirror_message], "([^,]+)") do
            table.insert(packet_out2, item)
        end
        if packet_out2[1] == "0x05B" and packet_out2[6] == 'false' then
            -- Build the release packet
            release_packet = packets.new('outgoing', 0x05B, 
            {
                ['Target'] = tonumber(packet_out2[2]),
                ['Option Index'] = tonumber(packet_out2[3]),
                ['_unknown1'] = tonumber(packet_out2[4]),
                ['Target Index'] = tonumber(packet_out2[5]),
                ['Automated Message'] = false,
                ['_unknown2'] = packet_out2[7],
                ['Zone'] = tonumber(packet_out2[8]),
                ['Menu ID'] = tonumber(packet_out2[9]),
            })
            log("Release Packet Built")
        else
            -- Build the release packet
            release_packet = packets.new('outgoing', 0x05B, 
            {
                ['Target'] = tonumber(packet_out[2]),
                ['Option Index'] = tonumber(packet_out[3]),
                ['Target Index'] = tonumber(packet_out[5]),
                ['Automated Message'] = false,
                ['Zone'] = tonumber(packet_out[8]),
                ['Menu ID'] = tonumber(packet_out[9]),
            })
            log("Release Packet Built (None Found - building from scratch)")
        end
    end

    -- Called if an event release is not detected
    function npc_retry()
        if injecting and release_packet['Zone'] ==  world.zone then
            retry_count = retry_count + 1
            packets.inject(action_packet)
            message_time = os.clock()
            mirroring_state = "Injecting [0x01A] - Retry"
            log(mirroring_state)
            packet_log(packet)
        else
            injecting = false
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
            if packet_out[1] == "0x05B" and menu_id and tonumber(menu_id) ~= tonumber(packet_out[9]) then
                info("Incorrect Menu - Player Cannot Mirror")
                log("Player Menu ["..menu_id..'] and Mirror Menu ['..packet_out[9]..']')
                -- Build the release packet for the different menu
                release_packet = packets.new('outgoing', 0x05B, 
                {
                    ['Target'] = recieved_packet['NPC'],
                    ['Option Index'] = 0,
                    ['Target Index'] = recieved_packet['NPC Index'],
                    ['Automated Message'] = false,
                    ['Zone'] = recieved_packet['Zone'],
                    ['Menu ID'] = recieved_packet['Menu ID'],
                })
                log("Release Packet Built Due to wrong Menu")
                packets.inject(release_packet)
                message_time = os.clock()
                packet_log(release_packet)
                mirroring_state = "Injecting [0x05B] (Release Packet - Wrong Menu)"
                log(mirroring_state)
                send_packet(player.name..";packet_npc_status_failed")
                recieved_packet = {}
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
            if retry_count < 11 and not menu_id then -- Poke the NPC
                log("Retry Menu ["..retry_count..'/10]')
                npc_retry()
                send_packet(player.name..";packet_npc_status_retry_"..retry_count)
            elseif #mirror_message ~= 0 then -- Continue to inject
                npc_inject()
                send_packet(player.name..";packet_npc_status_inject")
            else -- zero message left so assuming completed
                log("Injecting completed")
                send_packet(player.name..";packet_npc_status_completed")
                injecting = false
            end
        elseif packet['Type'] == 0x01 then
            log('NPC Release [Event]')
            if #mirror_message == 0 then
                send_packet(player.name..";packet_npc_status_completed")
                log("Injecting completed")
                injecting = false
            else
                npc_inject()
                send_packet(player.name..";packet_npc_status_inject")
            end
        elseif packet['Type'] == 0x02 then
            log('NPC Release [Event Skipped]')
            log("Injecting completed")
            send_packet(player.name..";packet_npc_status_failed")
            injecting = false
        elseif packet['Type'] == 0x03 then
            log('NPC Release [String Event]')
            log("Injecting completed")
            send_packet(player.name..";packet_npc_status_completed")
            injecting = false
        elseif packet['Type'] == 0x04 then
            log('NPC Release [Fishing]')
        end
    end

    function npc_reset()
        if release_packet then
            packets.inject(release_packet)
            message_time = os.clock()
            packet_log(release_packet)
            injecting = false
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