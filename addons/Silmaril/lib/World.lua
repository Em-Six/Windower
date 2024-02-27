do
    local player_enemy_data = "enemy_"
    local player_npc_data = "npc_"
    local world = {}

    function get_world_data()
        local formattedString = "world_"

        if not world then return formattedString end

        get_mob_data() -- refresh the Enemy and NPC lists
        formattedString = formattedString..tostring(world.menu_open)..','..world.zone..','..world.day..','..world.weather
        --log(formattedString)
        return formattedString
    end

    function get_mob_data()
        local formattedString = "enemy_"
        local formattedString2 = "npc_"
        player_enemy_data = "enemy_"
        player_npc_data = "npc_"

        mob_array = windower.ffxi.get_mob_array()
        if not mob_array then return end

        for id, enemy in pairs(mob_array) do
            if not enemy.target_index then
                enemy.target_index = 0
            end
            if enemy and enemy.is_npc and enemy.valid_target and not enemy.in_party and not enemy.charmed and enemy.spawn_type == 16 then
                    formattedString = formattedString..enemy.name..'|'..round(enemy.distance:sqrt(),2)..'|'..enemy.hpp..'|'..enemy.id..'|'..enemy.index..'|'..enemy.status..'|'
                ..round(enemy.x,3)..'|'..round(enemy.y,3)..'|'..round(enemy.z,3)..'|'..enemy.spawn_type..'|'..enemy.claim_id..'|'..world.zone..'|'..round(enemy.model_size,1)..','
            elseif enemy and enemy.valid_target and not enemy.in_party and enemy.spawn_type == 1 then
                formattedString2 = formattedString2..enemy.name..'|'..round(enemy.distance:sqrt(),2)..'|'..enemy.hpp..'|'..enemy.id..'|'..enemy.index..'|'..enemy.status..'|'
                ..round(enemy.x,3)..'|'..round(enemy.y,3)..'|'..round(enemy.z,3)..'|'..enemy.spawn_type..'|'..enemy.claim_id..'|'..world.zone..'|'..round(enemy.model_size,1)..'|'
                ..enemy.target_index..'|'..tostring(enemy.in_party)..'|'..tostring(enemy.in_alliance)..'|'..tostring(enemy.is_npc)..','
            end
        end
        if(#formattedString > 6) then
            player_enemy_data = formattedString:sub(1, #formattedString - 1)
        end
        if(#formattedString2 > 4) then
            player_npc_data = formattedString2:sub(1, #formattedString2 - 1)
        end
    end

    function get_enemy_data()
        formattedString = player_enemy_data
        player_enemy_data = "enemy_"
        return formattedString
    end

    function get_npc_data()
        formattedString = player_npc_data
        player_npc_data = "npc_"
        return formattedString
    end

    function get_world()
        return world
    end

    function set_world(w)
        world = w
    end
end