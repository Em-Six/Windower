do
    local enabled = false
    local connected = false
    local old_status = 0
    local auto_load = true

    function main_engine()

        local engine_speed = 1/60
        local now = os.clock()
        local last_request = now
        local last_sync = now
        local last_send = now
        local last_display = now

	    while true do

            now = os.clock() -- used to determine the elapsed time
            receive_info() --check the UDP port for incoming traffic

            if not connected then
                -- Send a requst to client every second
                if now - last_request > 1 then
                    request() -- Send the request to connect to silmaril via Connection.lua
                    last_request = now
                end
            else

                -- Update the player location, player info, and the world
                update_player_info()

                -- Process player movement
                movement()

                -- updates the player environment Via Update.lua
                if now - last_send > 1/30 then
                    send_silmaril()
                    last_send = now
                end

                -- Update the in game display
                if now - last_display > .25 then
                    update_display()
                    last_display = now
                end

                -- Update the spells the player has every 30 seconds
                if now - last_sync > 30 then 
                    get_player_spells() -- Spells.lua
                    log("Updated Sync")
                    last_sync = now
                end

                -- Player was mirroring and recieved a release packet.  Now just wait till status ~= 4
                if get_mirror_on() and get_mirroring() then
                    local p = get_player()
                    if old_status == 4 and p.status == 0 and get_mirror_release() then
                        -- Player is released via status change (non standard)
                        log("Mirror sequence completed via status change")
                        npc_mirror_complete()
                        clear_npc_data()
                    end
                    old_status = p.status
                end

                -- Mirroring 
                if get_injecting() then 

                    -- Try to get a Menu ID with a poke
                    local retry_count = get_retry_count()
                    if now - get_poke_time() > (retry_count + 1)/2 and not get_menu_id() then
                        if retry_count < 5 then
                            retry_count = retry_count +1
                            log("Retry Menu ["..retry_count..'/5] - Time Out')
                            send_packet(get_player_id()..";mirror_status_retry_"..tostring(retry_count))
                            npc_retry()
                        else
                            info("Timed out - Unable to Poke NPC.")
                            send_packet(get_player_id()..";mirror_status_failed")
                            npc_reset()
                        end
                    end

                    -- Mid injection and no response so follow up with injection
                    if get_mid_inject() and now - get_message_time() > 2 and get_menu_id() then
                        local p = get_player()
                        if p and p.status == 4 then
                            if not get_mirror_message() then
                                info("Timed out and all message are sent - Consider complete and reseting.")
                                send_packet(get_player_id()..";mirror_status_failed")
                                npc_reset()
                            else
                                log("Continue the injection.")
                                npc_inject()
                            end
                        end
                    end

                end

                -- load the initial settings
                if auto_load then 
                    load_command("")
                    auto_load = false;
                end
            end
            coroutine.sleep(engine_speed)
        end
    end

    function get_enabled()
        return enabled
    end

    function set_enabled(value)
        enabled = value
    end

    function set_connected(value)
        log("Connected ["..tostring(value)..']')
        sync = false
        connected = value
    end

    function get_connected()
        return connected
    end

    function set_auto_load(value)
        auto_load = value
    end

end