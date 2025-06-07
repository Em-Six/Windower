do
    local enabled = true
    local tracking_window = texts.new("", {
			text={size=10,font='Consolas',red=255,green=255,blue=255,alpha=255},
			pos={x=0,y=0},
			bg={visible=true,red=0,green=0,blue=0,alpha=102},})
    local location = ""
    local bitzer_position = {}
    local mob_tracking = {}
    local old_zone = 0
    local zone_1 = 133
    local zone_2 = 189
    local zone_3 = 275
    local world = nil
    local p_loc = nil
    local position_time = os.clock()
    local repositioned = false

    function sortie_initialize()
        location = ""

        mob_tracking = 
        {
             [1] = {name = 'Abject Obdella', index = 144, distance = 0},
             [2] = {name = 'Biune Porxie', index = 223, distance = 0},
             [3] = {name = 'Cachaemic Bhoot', index = 285, distance = 0},
             [4] = {name = 'Demisang Deleterious', index = 373, distance = 0},
             [5] = {name = 'Esurient Botulus', index = 427, distance = 0},
             [6] = {name = 'Fetid Ixion', index = 498, distance = 0},
             [7] = {name = 'Gyvewrapped Naraka', index = 552, distance = 0},
             [8] = {name = 'Haughty Tulittia', index = 622, distance = 0},
        }

        bitzer_position = 
        {
            [1] = {name = 'Diaphanous Bitzer (E)', index = 837, x = 0, y = 0, z = 0 },
            [2] = {name = 'Diaphanous Bitzer (F)', index = 838, x = 0, y = 0, z = 0 },
            [3] = {name = 'Diaphanous Bitzer (G)', index = 839, x = 0, y = 0, z = 0 },
            [4] = {name = 'Diaphanous Bitzer (H)', index = 840, x = 0, y = 0, z = 0 },
        }
    end

    function sortie_engine()

        if not enabled then return end

        world = get_world()
        p_loc = get_player_info()

        -- Zone change or just starting addon
        if old_zone ~= world.zone then
            sortie_initialize()
            old_zone = world.zone
            log("Sortie Reset")
            if world.zone == zone_1 or world.zone == zone_2 or world.zone == zone_3 then
                log("Sortie Window Show")
                sortie_command("A")
                tracking_window:show()
            else
                log("Sortie Window Hide")
                tracking_window:hide()
            end
        end

        if world.zone == zone_1 or world.zone == zone_2 or world.zone == zone_3 then
            tracking_update() -- Sortie addon
        end

        -- Wait till you finish moving to check for area
        if repositioned then
            if os.clock() - position_time > 2 then
                repositioned = false
                if world.zone ~= zone_1 and world.zone ~= zone_2 and world.zone ~= zone_3 then return end
                position_update()
            end
        end
    end

    function packet_in_0x0F5(data)
        local packet = parse_packet('incoming', data)
        if not packet['X'] or not packet['Y'] then log("Enemy not found") return end
        if not packet['Index'] then return end

        local enemy_x = packet['X']
        local enemy_y = packet['Y']
        local enemy_index = packet['Index']
        local table_index = 0

        for index, target in pairs(mob_tracking) do
            if target.index == enemy_index then
                table_index = index
            end
        end

        -- Couldn't find the enemy
        if table_index == 0 then return end

        -- Enemy is dead
        if enemy_x == 0 and enemy_y == 0 then mob_tracking[table_index].distance = 'Dead' return end

        -- Update the distance
        if not p_loc or not p_loc.x or not p_loc.y or not p_loc.z then return end
        local distance = round(((p_loc.x - enemy_x)^2 + (p_loc.y - enemy_y)^2):sqrt(),1)
        mob_tracking[table_index].distance = distance
        --log('Track: ['..enemy_index..'] - ['..enemy_x..'], ['..enemy_y..'] and distance of ['..distance..']')
    end

    -- Used to track mobs and objectives
    function tracking_update()
        if not p_loc or not p_loc.x or not p_loc.y or not p_loc.z then return end
        local maxWidth = 41
        local lines = T{}
        local bitzer_status = {}
        local bitzer_distance = 0
        lines:insert("     //sm sortie X to change floors")
        lines:insert("")
        lines:insert("            Current Area ["..location.."]")
        lines:insert("")
        if location == "A" then
            --Top Floor A
            lines:insert(mob_tracking[1].name..string.format('[%s]  ',tostring(mob_tracking[1].distance)):lpad(' ',maxWidth - string.len(mob_tracking[1].name)))
            lines:insert("")
            lines:insert("Casket #A1")
            lines:insert("  Kill 5x enemies")
            lines:insert("Casket #A2")
            lines:insert("  /heal past the #A1 gate")
            lines:insert("Coffer #A")
            lines:insert("  Kill Abject Obdella")
            lines:insert("Shard #A")
            lines:insert("  Single target magic killing blow 3x")
        elseif location == 'B' then
            -- Top Floor B
            lines:insert(mob_tracking[2].name ..string.format('[%s]  ',tostring(mob_tracking[2].distance)):lpad(' ',maxWidth - string.len(mob_tracking[2].name)))
            lines:insert("")
            lines:insert("Casket #B1")
            lines:insert("  Kill 3x Biune < 30 sec")
            lines:insert("Casket #B2")
            lines:insert("  Open a #B locked Gate")
            lines:insert("Coffer #B")
            lines:insert("  Kill Porxie after opening Casket #B1")
            lines:insert("Shard #B")
            lines:insert("  WS before death on 5x Biune")
        elseif location == 'C' then
            -- Top Floor C
            lines:insert(mob_tracking[3].name ..string.format('[%s]  ',tostring(mob_tracking[3].distance)):lpad(' ',maxWidth - string.len(mob_tracking[3].name)))
            lines:insert("")
            lines:insert("Casket #C1")
            lines:insert("  Kill 3x enemies < 15 sec")
            lines:insert("Casket #C2")
            lines:insert("  Kill all enemies")
            lines:insert("Coffer #C")
            lines:insert("  Kill Cachaemic Bhoot < 5 min")
            lines:insert("Chest #C")
            lines:insert("  Do 3x Magic Bursts")
        elseif location == 'D' then
            -- Top Floor D
            lines:insert(mob_tracking[4].name ..string.format('[%s]  ',tostring(mob_tracking[4].distance)):lpad(' ',maxWidth - string.len(mob_tracking[4].name)))
            lines:insert("")
            lines:insert("Casket #D1")
            lines:insert("  Kill 6x Demisang of different jobs")
            lines:insert("Casket #D2")
            lines:insert("  WAR->MNK->WHM->BLM->RDM->THF")
            lines:insert("Coffer #D")
            lines:insert("  Kill 3x enemies after NM")
            lines:insert("Chest #D")
            lines:insert("  Do a 4-step skillchain on 3x enemies")
        elseif location == 'E' then
            -- Basement E
            lines:insert(mob_tracking[5].name ..string.format('[%s]  ',tostring(mob_tracking[5].distance)):lpad(' ',maxWidth - string.len(mob_tracking[5].name)))
            bitzer_distance = round(((p_loc.x - bitzer_position[1].x)^2 + (p_loc.y - bitzer_position[1].y)^2):sqrt(),1)
            lines:insert(bitzer_position[1].name ..string.format('[%s]  ',tostring(bitzer_distance)):lpad(' ',maxWidth - string.len(bitzer_position[1].name)))
            lines:insert("")
            lines:insert("Casket #E1")
            lines:insert("  All foes around bitzer (12x)")
            lines:insert("Casket #E2")
            lines:insert("  All flan (15x)")
            lines:insert("Coffer #E")
            lines:insert("  Kill all Naakuals")
            lines:insert("Chest #E")
            lines:insert("  Kill with WS from behind")
        elseif location == 'F' then
            -- Basement F
            lines:insert(mob_tracking[6].name ..string.format('[%s]  ',tostring(mob_tracking[6].distance)):lpad(' ',maxWidth - string.len(mob_tracking[6].name)))
            bitzer_distance = round(((p_loc.x - bitzer_position[2].x)^2 + (p_loc.y - bitzer_position[2].y)^2):sqrt(),1)
            lines:insert(bitzer_position[2].name ..string.format('[%s]  ',tostring(bitzer_distance)):lpad(' ',maxWidth - string.len(bitzer_position[2].name)))
            lines:insert("")
            lines:insert("Casket #F1")
            lines:insert("  5/5 Empy gear at bitzer")
            lines:insert("Casket #F2")
            lines:insert("  Defeat all Veela")
            lines:insert("Coffer #F")
            lines:insert("  Kill all Naakuals")
            lines:insert("Chest #F")
            lines:insert("  ???")
        elseif location == 'G' then
            -- Basement G
            lines:insert(mob_tracking[7].name ..string.format('[%s]  ',tostring(mob_tracking[7].distance)):lpad(' ',maxWidth - string.len(mob_tracking[7].name)))
            bitzer_distance = round(((p_loc.x - bitzer_position[3].x)^2 + (p_loc.y - bitzer_position[3].y)^2):sqrt(),1)
            lines:insert(bitzer_position[3].name ..string.format('[%s]  ',tostring(bitzer_distance)):lpad(' ',maxWidth - string.len(bitzer_position[3].name)))
            lines:insert("")
            lines:insert("Casket #G1")
            lines:insert("  Target the Bizter for 30 sec ")
            lines:insert("Casket #G2")
            lines:insert("  Kill all Dullahan (19x)")
            lines:insert("Coffer #G")
            lines:insert("  Bee->Shark->T-Rex->Bird->Tree->Lion")
            lines:insert("Chest #G")
            lines:insert("  Kill Gyvewrapped Naraka")
        elseif location == 'H' then
            -- Basement H
            lines:insert(mob_tracking[8].name ..string.format('[%s]  ',tostring(mob_tracking[8].distance)):lpad(' ',maxWidth - string.len(mob_tracking[8].name)))
            bitzer_distance = round(((p_loc.x - bitzer_position[4].x)^2 + (p_loc.y - bitzer_position[4].y)^2):sqrt(),1)
            lines:insert(bitzer_position[4].name ..string.format('[%s]  ',tostring(bitzer_distance)):lpad(' ',maxWidth - string.len(bitzer_position[4].name)))
            lines:insert("")
            lines:insert("Casket #H1")
            lines:insert("  Leave then enter")
            lines:insert("Casket #H2")
            lines:insert("  Kill all of one Job")
            lines:insert("Coffer #H")
            lines:insert("  Bee->Lion->T-Rex->Shark->Bird->Tree")
            lines:insert("Chest #H")
            lines:insert("  Kill the NM next to a defated Formor")
        end

        tracking_box_refresh(lines)
    end

    -- start tracking a NM
    function track_on(index)
        packet = new_packet('outgoing', 0x0F5, {
            ['Index'] = index,
            ['_junk1'] = 0,
        })
        inject_packet(packet)
        log('track request for enemy ['..index..']')
    end

    -- stop tracking a NM
    function track_off()
        packet = new_packet('outgoing', 0x0F6, {
            ['_junk1'] = 0,
        })
        inject_packet(packet)
        log('tracking stopped')
    end

    -- NPC Update called from Packets.lua
    function bitzer_Check(data)
        if not world then return end
        if world.zone ~= zone_1 and world.zone ~= zone_2 and world.zone ~= zone_3 then return end

        local packet = parse_packet('incoming', data)
        local bitzer_index = packet['Index']
        local x = packet['X']
        local y = packet['Y']
        local z = packet['Z']

        if x == 0 and y == 0 and z == 0 then return end

        local position = 1

        if bitzer_index == bitzer_position[1].index then
            position = 1
        elseif bitzer_index == bitzer_position[2].index then
            position = 2
        elseif bitzer_index == bitzer_position[3].index then
            position = 3
        elseif bitzer_index == bitzer_position[4].index then
            position = 4
        else
            return
        end

        bitzer_position[position].x = x
        bitzer_position[position].y = y
        bitzer_position[position].z = z
            
        log('Bitzer Found - '..bitzer_index..' ['..x..'],['..y..'],['..z..']')
        que_packet('sortie_'..bitzer_index..'_'..x..'_'..y..'_'..z)
        repositioned = false
    end

    -- Command by user or update called
    function sortie_command(args)
        if not args[1] then return end
        local area = string.gsub(string.lower(args[1]), "%s+", "")
        local position = 0

        --Top floor
        if area == 'a' and location ~= "A" then
            location = "A"
            position = 1
        elseif area == 'b' and location ~= "B" then
            location = "B"
            position = 2
        elseif area == 'c' and location ~= "C" then
            location = "C"
            position = 3
        elseif area == 'd' and location ~= "D" then
            location = "D"
            position = 4

        -- Basement area
        elseif area == 'e' and location ~= "E" then
            location = "E"
            position = 5
        elseif area == 'f' and location ~= "F" then
            location = "F"
            position = 6
        elseif area == 'g' and location ~= "G" then
            location = "G"
            position = 7
        elseif area == 'h' and location ~= "H" then
            location = "H"
            position = 8
        end

        if position ~= 0 then
            --Set the NM to track
            send_to_chat(8,'The Hunt begins for the ['..mob_tracking[position].name..']....')
            track_on(mob_tracking[position].index)
        end
    end

    -- Repositioning called from Packets.lua
    function position_update()
        if not p_loc or not p_loc.x or not p_loc.y or not p_loc.z then return end
        local zone = 
        {
            [1] = {name = 'Zone A Identified', x = -460, y = 65 },
            [2] = {name = 'Zone B Identified', x = -375, y = -20 },
            [3] = {name = 'Zone C Identified', x = -460, y = -104 },
            [4] = {name = 'Zone D Identified', x = -544, y = -20 },
            [5] = {name = 'Zone E Identified', x = 580, y = 31.5 },
            [6] = {name = 'Zone F Identified', x = 631.5, y = -20 },
            [7] = {name = 'Zone G Identified', x = 580, y = -71.5 },
            [8] = {name = 'Zone H Identified', x = 528.5, y = -20 },
            [9] = {name = 'Enterance Identified', x = -880, y = -20 },
            [10] = {name = 'Zone A Identified', x = -900, y = 416 },
            [11] = {name = 'Zone B Identified', x = -24, y = 420 },
            [12] = {name = 'Zone C Identified', x = -20, y = -456 },
            [13] = {name = 'Zone D Identified', x = -896, y = -460 },
        }

        if ((p_loc.x-zone[1].x)^2 + (p_loc.y-zone[1].y)^2):sqrt() < 50 then -- Zone A
            log(zone[1].name)
            sortie_command('A')

        elseif ((p_loc.x-zone[2].x)^2 + (p_loc.y-zone[2].y)^2):sqrt() < 50 then -- Zone B
            log(zone[2].name)
            sortie_command('B')

        elseif ((p_loc.x-zone[3].x)^2 + (p_loc.y-zone[3].y)^2):sqrt() < 50 then -- Zone C
            log(zone[3].name)
            sortie_command('C')

        elseif ((p_loc.x-zone[4].x)^2 + (p_loc.y-zone[4].y)^2):sqrt() < 50 then -- Zone D
            log(zone[4].name)
            sortie_command('D')

        elseif ((p_loc.x-zone[5].x)^2 + (p_loc.y-zone[5].y)^2):sqrt() < 50 then -- Zone E
            local packet = new_packet('outgoing', 0x016, {['Target Index'] = bitzer_position[1].index })
            inject_packet(packet)
            packet_log(packet, "out")
            log(zone[5].name)
            sortie_command('E')

        elseif ((p_loc.x-zone[6].x)^2 + (p_loc.y-zone[6].y)^2):sqrt() < 50 then -- Zone F
            local packet = new_packet('outgoing', 0x016, {['Target Index'] = bitzer_position[2].index })
            inject_packet(packet)
            packet_log(packet, "out")
            log(zone[6].name)
            sortie_command('F')

        elseif ((p_loc.x-zone[7].x)^2 + (p_loc.y-zone[7].y)^2):sqrt() < 50 then -- Zone G
            local packet = new_packet('outgoing', 0x016, {['Target Index'] = bitzer_position[3].index })
            inject_packet(packet)
            packet_log(packet, "out")
            log(zone[7].name)
            sortie_command('G')

        elseif ((p_loc.x-zone[8].x)^2 + (p_loc.y-zone[8].y)^2):sqrt() < 50 then -- Zone H
            local packet = new_packet('outgoing', 0x016, {['Target Index'] = bitzer_position[4].index })
            inject_packet(packet)
            packet_log(packet, "out")
            log(zone[8].name)
            sortie_command('H')

        elseif ((p_loc.x-zone[9].x)^2 + (p_loc.y-zone[9].y)^2):sqrt() < 75 then -- Enterance
            log(zone[9].name)
            sortie_command('A')

        elseif ((p_loc.x-zone[10].x)^2 + (p_loc.y-zone[10].y)^2):sqrt() < 25 then -- A Boss Exit
            log(zone[10].name)
            sortie_command('A')

        elseif ((p_loc.x-zone[11].x)^2 + (p_loc.y-zone[11].y)^2):sqrt() < 25 then -- B Boss Exit
            log(zone[11].name)
            sortie_command('B')
            
        elseif ((p_loc.x-zone[12].x)^2 + (p_loc.y-zone[12].y)^2):sqrt() < 25 then -- C Boss Exit
            log(zone[11].name)
            sortie_command('C')
                        
        elseif ((p_loc.x-zone[13].x)^2 + (p_loc.y-zone[13].y)^2):sqrt() < 25 then -- C Boss Exit
            log(zone[13].name)
            sortie_command('D')
        end
    end

    function sortie_position()
        if not world then return end
        if world.zone ~= zone_1 and world.zone ~= zone_2 and world.zone ~= zone_3 then return end
        position_time = os.clock()
        repositioned = true
    end

    function get_sortie_enabled()
        return enabled
    end

    function set_sortie_enabled(value)
        enabled = value
    end

    -- Sortie tracking box
	function tracking_box_refresh(lines)
		local maxWidth = 41
        for i,line in ipairs(lines) do lines[i] = lines[i]:rpad(' ', maxWidth) end
        tracking_window:text(lines:concat('\n'))
	end

    function get_sortie_window()
		return tracking_window
	end

	function set_sortie_window(value)
		tracking_window = value
	end

end