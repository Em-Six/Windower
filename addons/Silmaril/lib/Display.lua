do
	config = require 'config'

	local status_time = nil
	local gears = {'|','/','-','\\\\'}
	local gear = 1
	local default_settings = {
		debug = false,
		info = true,
		npc = true,
		display = true,
		Debug_Box = 
		{
			text={size=10,font='Consolas',red=255,green=255,blue=255,alpha=255},
			pos={x=1440,y=732},
			bg={visible=true,red=0,green=0,blue=0,alpha=125},
		},
		Hover_Box = 
		{
			text={size=10,font='Consolas',red=255,green=255,blue=255,alpha=255},
			pos={x=0,y=0},
			bg={visible=true,red=0,green=0,blue=0,alpha=125},
		},
		Update_Box = 
		{
			text={size=10,font='Consolas',red=255,green=255,blue=255,alpha=255},
			pos={x=1615,y=663},
			bg={visible=true,red=0,green=0,blue=0,alpha=125},
		},
		NPC_Box = 
		{
			text={size=14,font='Consolas',red=255,green=255,blue=255,alpha=255},
			pos={x=0,y=0},
			bg={visible=true,red=255,green=0,blue=0,alpha=90},
		},
		NPC_Results = 
		{
			text={size=14,font='Consolas',red=255,green=255,blue=255,alpha=255},
			pos={x=0,y=0},
			bg={visible=true,red=255,green=0,blue=0,alpha=125},
		},
	}

	-- Loads the default settings
	local settings = config.load(default_settings)
	local sm_debug = texts.new("",settings.Debug_Box)
	local sm_hover = texts.new("",settings.Hover_Box)
	local sm_display = texts.new("",settings.Update_Box)
	local sm_npc= texts.new("",settings.NPC_Box)
	local sm_result= texts.new("",settings.NPC_Results)

	function update_display()
		-- used to fade the mirror screen
        mirror_fade() 

        -- Main UI window
        if settings.display and (get_enabled() or get_following() or get_mirror_on()) then
            sm_display:show()
            sm_display:text(display_box_refresh())
        else
            sm_display:hide()
        end

        -- Debug window
        if settings.debug then
            sm_debug:text(debug_box_refresh())
        end

        -- Mirroring Window
        if get_mirroring() or get_injecting() then
            sm_npc:text(npc_box_refresh())
            sm_npc:show()
        else
            sm_npc:hide()
        end

    end

	-- Used to show if Silmaril is running
	function display_box_refresh()
		local pt_loc = get_party_location()
		local p_loc = get_player_location()
		local w = get_world()
		local maxWidth = 23

		gear_update()

		lines = T{}
		lines:insert(' Silmaril...'..string.format('[%s]',tostring(gears[gear])):lpad(' ',maxWidth - 12 + string.len(gears[gear]))..' ')
		if get_mirror_on() and get_following() then
			sm_display:bg_color(255,0,0)
			lines:insert(' [Following] [Mirroring]')
		elseif get_following() then
			lines:insert('       [Following]')
			sm_display:bg_color(0,0,255)
		elseif get_mirror_on() then
			lines:insert('       [Mirroring]')
			sm_display:bg_color(153,0,204)
		else
			lines:insert('')
			sm_display:bg_color(0,0,0)
		end
		for index, member in pairs(pt_loc) do
			if member.zone == w.zone and p_loc and member.id ~= get_player_id() then
				local delta = {x = member.x - p_loc.x, y = member.y - p_loc.y}
				local distance = math.round(math.sqrt(delta.x^2 + delta.y^2),2)
				lines:insert('  '..member.name..string.format('[%s]',tostring(distance)):lpad(' ',maxWidth - string.len(member.name) - 2))
			end
		end
		lines:insert('')
		local maxWidth = math.max(1, table.reduce(lines, function(a, b) return math.max(a, #b) end, '1'))
		for i,line in ipairs(lines) do lines[i] = lines[i]:rpad(' ', maxWidth - string.len(gears[gear])) end
		sm_display:text(lines:concat('\n'))
	end

	-- Used to help debug issues - 20 chacaters long
	function debug_box_refresh()
		local maxWidth = 20
		local target = get_mirror_target()
		local target_index = 'nil'
		if target and target.index then
			target_index = target.index
		end
		lines = T{}
		lines:insert('Enabled' ..string.format('[%s]',tostring(get_enabled())):lpad(' ',13))
		lines:insert('Following' ..string.format('[%s]',tostring(get_following())):lpad(' ',11))
		lines:insert('injecting' ..string.format('[%s]',tostring(get_injecting())):lpad(' ',11))
		lines:insert('mirroring' ..string.format('[%s]',tostring(get_mirror_on())):lpad(' ',11))
		lines:insert('mirror menu' ..string.format('[%s]',tostring(get_menu_id())):lpad(' ',9))
		lines:insert('mirror target' ..string.format('[%s]',tostring(target_index)):lpad(' ',7))
		lines:insert('protection' ..string.format('[%s]',tostring(get_protection())):lpad(' ',10))
		lines:insert('Delay' ..string.format('[%s]',tostring(get_delay_time())):lpad(' ',15))
		for i,line in ipairs(lines) do lines[i] = lines[i]:rpad(' ', maxWidth) end
		sm_debug:text(lines:concat('\n'))
	end

	-- Used to show when a player is begining a Mirror
	function npc_box_refresh()
		local target = get_mirror_target()
		local state = get_mirroring_state()
		if target and target.name then
			lines = T{}
			lines:insert('')
			lines:insert(string.format("%-40s",string.format("Mirroring Actions"):lpad(' ',29)))
			lines:insert(string.format("%-40s",string.format('[%s]',target.name):lpad(' ',21 + #target.name/2)))
			lines:insert(string.format("%-40s",string.format('[%s]',state):lpad(' ',21 + #state/2)))
			lines:insert('')
			lines:insert('')
			sm_npc:text(lines:concat('\n'))
		end

	end

	-- Displays the current status of the mirroring action
	function npc_box_status(mirror_players)
		if mirror_players then
			sm_result:bg_color(255,0,0)
			sm_result:show()
			lines = T{}
			lines:insert('')
			lines:insert(string.format("%-40s",string.format("Mirroring Results"):lpad(' ',29)))
			lines:insert('')
			local completed = 0
			local count = 0
			for index, item in pairs(mirror_players) do
				local result = index..' - '..item
				count = count + 1
				lines:insert(string.format("%-40s",string.format('[%s]',result):lpad(' ',21 + #result/2)))
				if item == "Completed" then
					completed = completed + 1
				end
			end
			if completed == count then
				sm_result:bg_color(0,255,0)
			end
			lines:insert('')
			lines:insert('')
			sm_result:text(lines:concat('\n'))
		else
			sm_npc:hide()
		end
	end

	function gear_update()
		gear = gear +1
		if gear > 4 then
			gear = 1
		end
	end

	function mirror_fade()
		if status_time then
			local opacity = 1
			local fade_duration = 2
			local fade = 6
			local diff = os.clock() - status_time
			local alpha = 110
			if diff < fade then
				opacity = 1
			elseif diff < fade + fade_duration then
				opacity = 1 - (diff-fade) / fade_duration
			else
				opacity = 0
			end
			sm_result:bg_alpha(opacity*alpha)
			sm_result:alpha(opacity*alpha*2)
		end
	end

	function sm_result_hide()
		sm_result:hide()
		status_time = nil
	end

	function get_debug_state()
		return settings.debug
	end

	function get_info_state()
		return settings.info
	end

	function debug_command()
        if settings.debug == true then
            settings.debug = false
            sm_debug:hide()
			windower.add_to_chat(80,'------- Debugging [OFF] -------')
		else
			settings.debug = true
            sm_debug:show()
			windower.add_to_chat(80,'------- Debugging [ON]  -------')
		end
	end

	function info_command()
	    if settings.info == true then
            settings.info = false
			windower.add_to_chat(80,'------- Info [OFF] -------')
		else
			settings.info = true
			windower.add_to_chat(80,'------- Info [ON]  -------')
		end
	end

	function display_command()
		if settings.display == true then
			settings.display = false
			sm_display:hide()
			windower.add_to_chat(80,'------- Display [OFF] -------')
		else
			settings.display = true
			sm_display:show()
			windower.add_to_chat(80,'------- Display [ON]  -------')
		end
	end

	function save_command()
        coroutine.sleep(math.random(100,200)/1000)
		config.save(settings, get_player_name():lower())
		windower.add_to_chat(80,'Silmaril Settings Saved')
	end

	function set_status_time()
		if not status_time then
			log('Status Time set for NPC Results')
			status_time = os.clock()
		end
	end

end