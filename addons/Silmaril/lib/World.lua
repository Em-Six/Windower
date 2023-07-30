function get_world_data()
    world = windower.ffxi.get_info() -- Update the info
    local formattedString = "world_"
    player_world_data = formattedString..tostring(world.menu_open)..','..world.zone..','..world.day..','..world.weather
    --log(player_world_data)
end

function get_enemy_data()
    mob_array = windower.ffxi.get_mob_array()
    local formattedString = "enemy_"
    local formattedString2 = "npc_"
    for id, enemy in pairs(mob_array) do
        if not enemy.target_index then
            enemy.target_index = 0
        end
        if enemy and enemy.is_npc and enemy.valid_target and not enemy.in_party and not enemy.charmed and enemy.spawn_type == 16 and enemy.distance:sqrt() < 50 then
            formattedString = formattedString..enemy.name..'|'..enemy.distance:sqrt()..'|'..enemy.hpp..'|'..enemy.id..'|'..enemy.index..'|'..enemy.status..'|'..enemy.x..'|'..enemy.y..'|'..enemy.z..'|'..enemy.spawn_type..'|'..enemy.claim_id..'|'..enemy.target_index..','
        elseif enemy and enemy.valid_target and not enemy.in_party and enemy.spawn_type == 1 and enemy.distance:sqrt() < 50 then
            formattedString2 = formattedString2..enemy.name..'|'..enemy.distance:sqrt()..'|'..enemy.hpp..'|'..enemy.id..'|'..enemy.index..'|'..enemy.status..'|'..enemy.x..'|'..enemy.y..'|'..enemy.z..'|'..enemy.spawn_type..'|'..enemy.claim_id..'|'..enemy.target_index..'|'
            ..tostring(enemy.in_party)..'|'..tostring(enemy.in_alliance)..'|'..tostring(enemy.is_npc)..'|'..tostring(enemy.target_index)..','
        end
    end
    if(#formattedString > 6) then
        player_enemy_data = formattedString:sub(1, #formattedString - 1) -- remove last character
    else
        player_enemy_data = nil
    end
    if(#formattedString2 > 4) then
        player_npc_data = formattedString2:sub(1, #formattedString2 - 1) -- remove last character
    else
        player_npc_data = nil
    end
end

function get_all_zone_data()
    local formattedString = player.name..";zonedata_"
    for id, zone in pairs(res.zones) do
        local can_pet = false
        if zone.can_pet then
            can_pet = true
        end
        formattedString = formattedString..zone.id..'|'..zone.en..'|'..tostring(can_pet)..','
    end
    player_zone_data = formattedString:sub(1, #formattedString - 1) -- remove last character
    --log(player_zone_data)
    send_packet(player_zone_data)
end

function get_all_city_data()
    -- City areas for town gear and behavior.
    local Cities = {"Ru'Lude Gardens","Upper Jeuno","Lower Jeuno","Port Jeuno","Port Windurst","Windurst Waters","Windurst Woods","Windurst Walls","Heavens Tower","Port San d'Oria","Northern San d'Oria",
	"Southern San d'Oria","Chateau d'Oraguille","Port Bastok","Bastok Markets","Bastok Mines","Metalworks","Aht Urhgan Whitegate","The Colosseum","Tavnazian Safehold","Nashmau","Selbina",
	"Mhaura","Rabao","Norg","Kazham","Eastern Adoulin","Western Adoulin","Celennia Memorial Library","Mog Garden","Leafallia"}
    local formattedString = player.name..";citydata_"
    for id, city in pairs(Cities) do
        formattedString = formattedString..city..','
    end
    player_city_data = formattedString:sub(1, #formattedString - 1) -- remove last character
    --log(player_city_data)
    send_packet(player_city_data)
end

function get_all_weather_data()
    local formattedString = player.name..";weatherdata_"
    for id, weather in pairs(res.weather) do
        formattedString = formattedString..tostring(weather.id)..'|'..weather.en..'|'..res.elements[weather.element].en..'|'..tostring(weather.intensity)..','
    end
    player_weather_data = formattedString:sub(1, #formattedString - 1) -- remove last character
    --log(player_zone_data)
    send_packet(player_weather_data)
end

function get_all_day_data()
    local formattedString = player.name..";daydata_"
    for id, day in pairs(res.days) do
        formattedString = formattedString..tostring(day.id)..'|'..day.en..'|'..res.elements[day.element].en..','
    end
    player_day_data = formattedString:sub(1, #formattedString - 1) -- remove last character
    --log(player_zone_data)
    send_packet(player_day_data)
end