default = 
{
	debug = false,
	info = true,
	npc = true,
	display = true,
	Debug_Box = 
	{
		text={size=10,font='Consolas',red=255,green=255,blue=255,alpha=255},
		pos={x=1473,y=763},
		bg={visible=true,red=0,green=0,blue=0,alpha=70},
	},
	Update_Box = 
	{
		text={size=10,font='Consolas',red=255,green=255,blue=255,alpha=255},
		pos={x=1635,y=782},
		bg={visible=true,red=0,green=0,blue=0,alpha=70},
	},
	NPC_Box = 
	{
		text={size=16,font='Consolas',red=255,green=255,blue=255,alpha=255},
		pos={x=700,y=30},
		bg={visible=true,red=255,green=0,blue=0,alpha=30},
	},
}

settings = config.load(default) -- Loads the default settings (Display.lua)

gears = {'|','/','-','\\\\'}
gear = 1

sm_debug = {}
sm_debug = texts.new("",settings.Debug_Box)

sm_display = {}
sm_display = texts.new("",settings.Update_Box)

sm_npc = {}
sm_npc= texts.new("",settings.NPC_Box)

--Variable to monitor during debug mode
debug_value = 0

if settings.debug then
	sm_debug:show()
else
	sm_debug:hide()
end

if settings.display then
	sm_display:show()
else
	sm_display:hide()
end

if player_mirror then
	sm_npc:show()
else
	sm_npc:hide()
end

-- Used to help debug issues - 20 chacaters long
function debug_box_refresh()
	local maxWidth = 20
	lines = T{}
	lines:insert('Enabled' ..string.format('[%s]',tostring(enabled)):lpad(' ',13))
	lines:insert('Following' ..string.format('[%s]',tostring(following)):lpad(' ',11))
	lines:insert('Connected' ..string.format('[%s]',tostring(connected)):lpad(' ',11))
	lines:insert('Update (s)' ..string.format('[%s]',tostring(update_time)):lpad(' ',10))
	lines:insert('Delay' ..string.format('[%s]',tostring(delay_time)):lpad(' ',15))
	lines:insert('Moving' ..string.format('[%s]',tostring(moving)):lpad(' ',14))
	lines:insert('Claim ID' ..string.format('[%s]',tostring(claim_id)):lpad(' ',12))
	lines:insert('injecting' ..string.format('[%s]',tostring(injecting)):lpad(' ',10))
	lines:insert('mirroring' ..string.format('[%s]',tostring(player_mirror)):lpad(' ',10))
	for i,line in ipairs(lines) do lines[i] = lines[i]:rpad(' ', maxWidth) end
    sm_debug:text(lines:concat('\n'))
end

-- Used to show if Silmaril is running
function display_box_refresh()
	local maxWidth = 22
	gear_update()
	sm_display:bg_color(0,0,0)
	lines = T{}
	lines:insert(' Silmaril...'..string.format('[%s]',tostring(gears[gear])):lpad(' ',maxWidth - 12 + string.len(gears[gear]))..' ')
	if player_mirror then
		sm_display:bg_color(255,0,0)
		lines:insert('      [Mirroring]')
	else
		lines:insert('')
	end
	for index, member in pairs(party_location) do
		if member.zone == world.zone and player_location and member.name ~= player.name then
			local delta = {x = member.x - player_location.x, y = member.y - player_location.y}
			local distance = math.round(math.sqrt(delta.x^2 + delta.y^2),2)
			lines:insert('  '..member.name..string.format('[%s]',tostring(distance)):lpad(' ',maxWidth - string.len(member.name) - 2))
		end
	end
	lines:insert('')
	local maxWidth = math.max(1, table.reduce(lines, function(a, b) return math.max(a, #b) end, '1'))
	for i,line in ipairs(lines) do lines[i] = lines[i]:rpad(' ', maxWidth - string.len(gears[gear])) end
    sm_display:text(lines:concat('\n'))
end

function npc_box_refresh()
	if mirror_target and mirror_target.name then
		lines = T{}
		lines:insert('')
		lines:insert(string.format("%-40s",string.format("Mirroring Actions"):lpad(' ',29)))
		lines:insert(string.format("%-40s",string.format('[%s]',mirror_target.name):lpad(' ',21 + #mirror_target.name/2)))
		lines:insert(string.format("%-40s",string.format('[%s]',mirroring_state):lpad(' ',21 + #mirroring_state/2)))
		lines:insert('')
		lines:insert('')
		sm_npc:text(lines:concat('\n'))
	end
end

function gear_update()
	gear = gear +1
	if gear > 4 then
		gear = 1
	end
end
