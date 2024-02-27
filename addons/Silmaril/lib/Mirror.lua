do
    local sent_messages = {} -- Holds the packets that were sent
    local retry_count = 0 -- How many times a retry was conducted
    local message_count = 0 -- Total messages in que to mirror
    local single_mirror = true -- Determins if mirroring should be kept on after a mirror event is completed
    local action_packet = nil -- This is the packet used to poke a NPC
    local black_list = {}   -- NPC's to avoid when mirroring is turned on
    local injecting = false -- In the process of injecting packets (end users)
    local mirror_on = false -- If the player has mirroring enabled
    local mirroring = false -- If the player is in the process of building a mirror image to silmaril
    local mirror_target = nil -- NPC the interaction for (used in Display)
    local message_time = os.clock() -- Time set to figure out if the player is timming out
    local poke_time = os.clock() -- used to find when the last poke happened
    local menu_id = nil -- This is the menu that the player is interacting with
    local temp_menu_id = nil -- Used to store the active dialog (warps/doors)
    local mirror_message = nil -- Message to transmit
    local mirroring_state = '' -- this is used to notify the player of the actions
    local blacklisted = false -- Determines if the NPC is to be blacklisted
    local mirror_release = false -- Used to validate a player state change
    local mid_inject = false -- Determines if the player is mid injection incase times out or packet drops
    local block_release = false -- This is used for warp portals when the player is already in a menu (block to server the event skip)

    -- Outline of events

    -- Player starts by interactiong with a NPC by sending an action packet 0x01A with a category of 0x000.
    -- This is captured in Packets.lua and calls npc_interact(packet_in) to start the process of recording.
    -- In response to the Action packet the server send the client a 0x032/0x033/0x034 packet.  This contains the menu the NPC is displaying.
    -- Because of this the menu needs to be blocked.  This is done after the packet is processed by returning "true" to windower in Silmaril.lua


-----------------------------------------------------------------------
------------------------- MIRRORER SECTION ----------------------------
-----------------------------------------------------------------------


    -- This packet is generated when a player starts an interaction with NPC and mirroring is enabled (outgoing to server)
    function npc_mirror_start(packet_in)

        -- Clear old action
        clear_npc_data()
        sm_result_hide()

        -- Used to look up NPC for blacklist
        local npc = windower.ffxi.get_mob_by_id(packet_in['Target'])
        if not npc then log("Couldn't get target ["..tostring(packet_in['Target']).."]") return end

        log('valid_target ['..tostring(npc.valid_target)..']')
        log('is_npc ['..tostring(npc.is_npc)..']')
        log('entity_type ['..tostring(npc.entity_type)..']')

        local p = get_player()
        if not p then return end

        local w = get_world()
        if not w then return end

        if w.mog_house and npc.name == 'Moogle' then return end

        -- Check for a black listed NPC
        for index, item in ipairs(black_list) do
            if npc.name == item.name then
                if w.zone == tonumber(item.zone) or tonumber(item.zone) == 0 then
                    if npc.index == tonumber(item.index) or tonumber(item.index) == 0 then
                        blacklisted = true
                    end
                end
            end
        end

        --Send the info to silmaril to notify a sequence is starting
        if not blacklisted then
        	mirror_target = npc
            mirror_target.zone = w.zone
            mirroring_state = "Recording"
            mirroring = true
            message_time = os.clock()
            send_packet(get_player_id()..';mirror_interact') -- used to clear a buffer in Silmaril
            log('NPC Interaction Starting for '..npc.name..' [Dialog]')
            packet_log(packet_in, "in")
        else
            log("Blacklisted NPC")
        end
    end

    -- In resposne to a Buy/Sell action 0x03E Packet
    function npc_buy_start()

        -- Clear old action
        clear_npc_data()
        sm_result_hide()

        -- get the environment
        local w = get_world()
        if not w then return end

        local p = get_player()
        if not p then return end

        local p_loc = get_player_location()
        if not p_loc then return end

        mirroring_state = "Starting [Buy]"
	    mirror_target = p
        mirror_target.name = "NPC Buy"
        mirror_target.x = p_loc.x
        mirror_target.y = p_loc.y
        mirror_target.z = p_loc.z
        mirror_target.zone = w.zone

        message_time = os.clock()
        log('NPC Interaction Starting [Buy]')
        send_packet(get_player_id()..';mirror_interact') -- used to clear a buffer
    end

    -- 0x05B
    -- This function sends the menu selection of the player to silmaril to build the menu transactions
    function npc_out_dialog(packet_in)
        if blacklisted then log("Blacklisted NPC") return end
        log('Recording Dialog [0x05B]')
        send_packet(get_player_id()..';mirror_dialog_0x05B,'..
            packet_in['Target']..','..
            packet_in['Option Index']..','..
            packet_in['_unknown1']..','..
            packet_in['Target Index']..','..
            tostring(packet_in['Automated Message'])..','..
            packet_in['_unknown2']..','..
            packet_in['Zone']..','..
            packet_in['Menu ID'])
        packet_log(packet_in, "out")
        message_time = os.clock()
    end

    -- 0x05C
    -- This function is for a warp request to silmaril
    function npc_out_warp(packet_in)
        if blacklisted then log("Blacklisted NPC") return end
        log('Recording Warp [0x05C]')
        send_packet(get_player_id()..';mirror_warp_0x05C,'..
            packet_in['X']..','..
            packet_in['Y']..','..
            packet_in['Z']..','..
            packet_in['Target ID']..','..
            packet_in['_unknown1']..','..
            packet_in['Zone']..','..
            packet_in['Menu ID']..','..
            packet_in['Target Index']..','..
            packet_in['_unknown2']..','..
            packet_in['Rotation'])
        packet_log(packet_in, "out")
        message_time = os.clock()
    end

    -- 0x036
    -- This functin is for trading
    function npc_out_trade(packet_in, formattedString)

        if not packet_in then return end
        if blacklisted then return end

        log('Mirroring Trade [0x036]')
        send_packet(get_player_id()..';mirror_trade_0x036,'..
            packet_in['Target']..','..
            packet_in['Target Index']..
            formattedString)

        message_time = os.clock()
        packet_log(packet_in, 'out')
    end

    -- 0x083
    -- This functin is for buy/sell items
    function npc_out_buy(packet_in)

        if not packet_in then return end
        if blacklisted then return end

        log('Mirroring Buy [0x083]')
        send_packet(get_player_id()..';mirror_buy_0x083,'..
            packet_in['Count']..','..
            packet_in['_unknown2']..','..
            packet_in['Shop Slot']..','..
            packet_in['_unknown3']..','..
            packet_in['_unknown4'])

        message_time = os.clock()
        packet_log(packet_in, 'out')
    end

    -- Once a NPC interaction is completed the server then send a 0x037 packets with the player state change (4 -> 0)
    function npc_mirror_complete()
        if blacklisted then log("Blacklisted NPC") return end
        if not mirror_target then log("No Target Found") return end

        send_packet(get_player_id()..';mirror_send_'..
            tostring(mirror_target.id)..','..
            tostring(mirror_target.index)..','..
            tostring(mirror_target.x)..','..
            tostring(mirror_target.y)..','..
            tostring(mirror_target.z)..','..
            tostring(mirror_target.zone)..','..
            tostring(mirror_target.name))

        log('NPC interaction completed')
        mirroring = false
        if single_mirror then mirror_on = false end
    end


-----------------------------------------------------------------------
------------------------- INJECTOR SECTION ----------------------------
-----------------------------------------------------------------------


    -- Called by Silmaril to start a mirror sequence
    -- Build the message que for when server asks for it.
    -- Only send the action packet here
    function npc_build_message(target, message)

        local w = get_world()
        if not w then return end

        local p = get_player()
        if not p then return end

        mirror_target = target
        mirror_target.zone = w.zone

        -- Builds the messages into a table
        mirror_message = {}
        for item in string.gmatch(message, "([^|]+)") do
            table.insert(mirror_message, item)
        end

        -- Set the message count
        message_count = #mirror_message
        log('Messasge count is ['..message_count..']')

        -- Cancel the dialog you are currently in
        if p.status == 4 then
            if temp_menu_id then
                block_release = true
                log('Sending Menu Cancel')
                windower.packets.inject_incoming(0x052, 'ICHC':pack(0,2,temp_menu_id,0))
                temp_menu_id = nil
                return
            else
                log('Player is already in a menu - Mirroring Failed')
                send_packet(get_player_id()..";mirror_status_failed")
            end
        else
            temp_menu_id = nil
        end

        -- Parse the first message
        local packet_out = {}
        for item in string.gmatch(mirror_message[1], "([^,]+)") do
            table.insert(packet_out, item)
        end

        if packet_out[1] == "0x05B" or packet_out[1] == "0x05C" then -- Dialog

            -- Build the action packet
            action_packet = packets.new('outgoing', 0x01A, {
                ['Target'] = mirror_target.id,
                ['Target Index'] = mirror_target.index,
                ['Category'] = 0x00,
                ['Param'] = 0 })

            -- Start the interation
            log('Initial NPC Poke')

            packets.inject(action_packet)
            poke_time = os.clock()
            packet_log(action_packet, 'out')
            mirroring_state = "Injecting [0x01A]"

        elseif packet_out[1] == "0x036" then
            log("Trade Action")
        else
            log("Unknown Message")
        end

    end

    -- Once a 0x032/0x033/0x034 Packet is recieved from the initial Action always first 0x05B Packet sent
    -- Once a follow up 0x05C is recieved send the next dialog reqest/warp
    function npc_inject()

        if not injecting then return end
        if not mirror_message then return end

        if #mirror_message == 0 then
            mid_inject = false
            mirror_message = nil 
            return 
        end

        local packet_out = {}
		for item in string.gmatch(mirror_message[1], "([^,]+)") do
            table.insert(packet_out, item)
        end

        local message_type = ''
        local packet = {}

        -- Check for correct menu unless it originates from the player
        if packet_out[1] == "0x05B" and menu_id ~= tonumber(packet_out[9]) then
            if tonumber(packet_out[2]) ~= get_player().id then
                reset_player(packet_out[9])
                return
            end
        end

        if packet_out[1] == "0x05B" then
            message_type = '[0x05B]'
            local automated = false
            if packet_out[6] == 'true' then automated = true end
            packet = packets.new('outgoing', 0x05B, {
                ['Target'] = tonumber(packet_out[2]),
                ['Option Index'] = tonumber(packet_out[3]),
                ['_unknown1'] = tonumber(packet_out[4]),
                ['Target Index'] = tonumber(packet_out[5]),
                ['Automated Message'] = automated,
                ['_unknown2'] = packet_out[7],
                ['Zone'] = tonumber(packet_out[8]),
                ['Menu ID'] = tonumber(packet_out[9]),
            })
            -- If a menu ID was not assigned from incoming interact assign it here
            if not menu_id then 
                log('Setting Menu ID from packet - Non standard') 
                menu_id = tonumber(packet_out[9]) 
            end

        elseif packet_out[1] == "0x05C" and menu_id ~= tonumber(packet_out[8]) then
            reset_player(packet_out[8])
            return

        elseif packet_out[1] == "0x05C" then
            message_type = '[0x05C]'
            packet = packets.new('outgoing', 0x05C, 
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

        elseif packet_out[1] == "0x083" then
            message_type = '[0x083]'
            packet = packets.new('outgoing', 0x083, 
            {
                ['Count'] = tonumber(packet_out[2]),
                ['_unknown2'] = tonumber(packet_out[3]),
                ['Shop Slot'] = tonumber(packet_out[4]),
                ['_unknown3'] = tonumber(packet_out[5]),
                ['_unknown4'] = tonumber(packet_out[6]),
            })

        else
            echo("Unknown Packet Detected!!!! - Player ["..get_player_name().."] cannot mirror.")
            send_packet(get_player_id()..";mirror_status_failed")
            return
        end

        mid_inject = true
        packets.inject(packet)
        message_time = os.clock()
        packet_log(packet, 'out')
        table.insert(sent_messages, packet)
        table.remove(mirror_message,1)
        mirroring_state = 'Injecting '..message_type..' ('..#sent_messages..' of '..message_count..')'
        log(mirroring_state)

        -- Go ahead and assume it completed as not all NPC have a Event Release (or packet dropped)
        if #mirror_message == 0 then
            log("Mirroring Completed (End of Packets)")
            send_packet(get_player_id()..";mirror_status_completed")
            mid_inject = false
            mirror_message = nil
        end

    end

    -- Called if an event release is not detected
    function npc_retry()
        if not injecting then return end
        if mid_inject then return end
        local w = get_world()
        if not w then return end

        if not action_packet then injecting = false return end

        -- Try a retry packet injection
        retry_count = retry_count + 1

        -- Turn off injecting if exceeded retry count
        if retry_count > 5 then 
            npc_reset()
            injecting = false
        end

        -- inject the packet
        packets.inject(action_packet)
        poke_time = os.clock()
        packet_log(action_packet, 'out')
        mirroring_state = "Injecting [0x01A] - Retry ["..tostring(retry_count)..']'
    end

    function npc_in_release(packet_in)
        if not injecting then return end

        if packet_in['Type'] == 0x00 then
            log('NPC Release [Standard]')

            -- No messages left to send so consider it done
            if not mirror_message then 
                log('Received [Standard] release was a type ['..interaction_type..']')
                send_packet(get_player_id()..";mirror_status_completed")
                injecting = false
            end

        elseif packet_in['Type'] == 0x01 then
            log('NPC Release [Event]')

            if not mirror_message then 
                -- Sucessful Event release
                log('Received [Event] release was a type ['..interaction_type..']')
                send_packet(get_player_id()..";mirror_status_completed")
                injecting = false
            else
                -- Finish the messages after the release
                npc_inject()
                return
            end

        -- Something prevented the injection
        elseif packet_in['Type'] == 0x02 then
            log('Received [Event Skip] release was a type ['..interaction_type..']')
            send_packet(get_player_id()..";mirror_status_failed")
            injecting = false

        elseif packet_in['Type'] == 0x03 then
            log('Received [String] completed source was a type ['..interaction_type..']')
            send_packet(get_player_id()..";mirror_status_completed")
            injecting = false

        elseif packet_in['Type'] == 0x04 then
            log('Received [Fishing] release was a type ['..interaction_type..']')
            send_packet(get_player_id()..";mirror_status_completed")
            injecting = false

        end

    end


    -----------------------------------------------------------------------
    -------------------------- HELPER SECTION -----------------------------
    -----------------------------------------------------------------------


    function reset_player(value)
        echo("Incorrect Menu Detected!!!! - Player ["..get_player_name().."] cannot mirror (Menu).")
        log("Player Menu ["..tostring(menu_id)..'] and Mirror Menu ['..value..']')
        send_packet(get_player_id()..";mirror_status_failed")
        retry_count = 0
        npc_reset()
    end

    function npc_reset(menu, index)
        injecting = false

        -- Set the menu ID if passed
        if menu then menu_id = menu end

        if not menu_id and temp_menu_id then menu_id = temp_menu_id end

        log('Reset - Menu ID ['..tostring(menu_id)..'] Temp Menu ID ['..tostring(temp_menu_id)..']')

        -- Try to finish the injection
        if mid_inject then log('Mid-Inject so continue') npc_inject() return end

        -- Set the target if sent
        if index then 
            mirror_target = windower.ffxi.get_mob_by_index(index)
            mirror_target.zone = get_world().zone
        end

        if menu_id and mirror_target then
            log('Silmaril Reset - 0x05B Packet (Constructed)')
            local packet = packets.new('outgoing', 0x05B, {
                ['Target'] = mirror_target.id,
                ['Option Index'] = 0,
                ['_unknown1'] = 16384,
                ['Target Index'] = mirror_target.index,
                ['Automated Message'] = false,
                ['_unknown2'] = '0',
                ['Zone'] = mirror_target.zone,
                ['Menu ID'] = menu_id
            })
            packets.inject(packet)
            packet_log(packet, 'out')

            log('Silmaril Reset - 0x052 Packets (Defined)')
            windower.packets.inject_incoming(0x052, 'ICHC':pack(0,2,menu_id,0)) -- Event Skip
            windower.packets.inject_incoming(0x052, string.char(0,0,0,0,0,0,0,0)) -- Standard Release
            windower.packets.inject_incoming(0x052, string.char(0,0,0,0,1,0,0,0)) -- Event Relase

        else
            log('Silmaril Reset - General Release')
            windower.packets.inject_incoming(0x052, string.char(0,0,0,0,0,0,0,0))
            windower.packets.inject_incoming(0x052, string.char(0,0,0,0,1,0,0,0))

        end

    end

    function packet_log(packet, direction)
        if not packet then return end
        for index, item in pairs(packet) do
            if not string.find(tostring(index), "_") then
                log('Packet '..direction..': ['..tostring(index)..'] ['..tostring(item)..']')
            end
        end
    end

    function npc_mirror_state(state)
        if state == "True" then
            single_mirror = true
            log("Mirror State is single use")
        else
            single_mirror = false
            log("Mirror State is multiple use")
        end
    end

    -- Used to reset the mirror states
    function clear_npc_data()
        log("Clearing NPC packet information")
        injecting = false
        retry_count = 0
        menu_id = nil
        sent_messages = {}
        mirroring_state = ""
        message_count = 0
        action_packet = nil
        mirroring = false
        mirror_target = nil
        mirror_message = nil
        interaction_type = ''
        mirror_release = false
        blacklisted = false
        mid_inject = false
        block_release = false
    end

    -- Table of blacklisted NPC from silmaril
    function add_black_list(list)
        black_list = {}
        -- split to each message
        for items in string.gmatch(list, "([^|]+)") do
            -- split each message further
            local list_item = {}
            for item in string.gmatch(items, "([^,]+)") do
                table.insert(list_item, item)
            end
            local parsed = {name = list_item[1], zone = list_item[2], index = list_item[3]}
            table.insert(black_list, parsed)
            --log('Name ['..parsed.Name..'] Zone ['..parsed.Zone..'] Index ['..parsed.Index..']')
        end
    end

    function get_injecting()
        return injecting
    end

    function set_injecting(value)
        injecting = value
    end

    function get_mirror_on()
        return mirror_on
    end

    function set_mirror_on(value)
        mirror_on = value
    end

    function get_mirroring()
        return mirroring
    end

    function set_mirroring(value)
        mirroring = value
    end

    function get_message_time()
        return message_time
    end

    function get_mirror_target()
       return mirror_target
    end

    function set_mirror_target(value)
        mirror_target = value
    end

    function get_blacklisted()
        return blacklisted
    end

    function get_mirroring_state()
        return mirroring_state
    end

    function get_menu_id()
        return menu_id
    end

    function set_temp_menu_id(value)
        temp_menu_id = tonumber(value)
    end

    function set_menu_id(value)
        menu_id = tonumber(value)
    end

    function get_mirror_message()
        return mirror_message
    end

    function get_retry_count()
        return retry_count
    end

    function get_current_menu()
        return current_menu
    end

    function set_current_menu(value)
        log("Updated the current menu")
        current_menu = value
    end

    function set_interaction_type(value)
        interaction_type = value
    end

    function set_mirror_release(value)
        mirror_release = value
    end

    function get_mirror_release()
        return mirror_release
    end

    function get_mid_inject()
        return mid_inject
    end

    function get_block_release()
        return block_release
    end

    function set_block_release(value)
        block_release = value
    end

    function get_poke_time()
        return poke_time
    end

end