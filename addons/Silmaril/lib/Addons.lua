do
    -- List of supported addons
    function check_addons()
        -- Sortie Addon
        sortie_engine()
        -- TP Party Addon
        insight_engine()
    end

    function addon_commands(message)

        if message[3] == "silmaril" then
            local sm_display = get_sm_window()

             -- Display window
            if message[4] == 'True' then
                display_command(true)
            else
                display_command(false)
            end

            sm_display:pos_x(tonumber(message[5]))
            sm_display:pos_y(tonumber(message[6]))

            -- In game info
            if message[7] == 'True' then
                info_command(true)
            else
                info_command(false)
            end

            set_sm_window(sm_display)

            local npc_display = get_npc_window()
            npc_display:pos_x(tonumber(message[8]))
            npc_display:pos_y(tonumber(message[9]))
            set_npc_window(npc_display)

            local result_display = get_result_window()
            result_display:pos_x(tonumber(message[8]))
            result_display:pos_y(tonumber(message[9]))
            set_result_window(result_display)


        elseif message[3] == "sortie" then
            local tracking_window = get_sortie_window()

             -- Display window
            if message[4] == 'True' then
                set_sortie_enabled(true)
            else
                set_sortie_enabled(false)
            end

            tracking_window:pos_x(tonumber(message[5]))
            tracking_window:pos_y(tonumber(message[6]))

            set_sortie_window(tracking_window)

        elseif message[3] == "insight" then

             -- Display window
            if message[4] == 'True' then
                set_insight_enabled(true)
            else
                set_insight_enabled(false)
            end

        end

    end

end
