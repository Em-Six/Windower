local skillchains = {
	[288] = {id=288,english='Light',elements={'Light','Thunder','Wind','Fire'}},
	[289] = {id=289,english='Darkness',elements={'Dark','Ice','Water','Earth'}},
	[290] = {id=290,english='Gravitation',elements={'Dark','Earth'}},
	[291] = {id=291,english='Fragmentation',elements={'Thunder','Wind'}},
	[292] = {id=292,english='Distortion',elements={'Ice','Water'}},
	[293] = {id=293,english='Fusion',elements={'Light','Fire'}},
	[294] = {id=294,english='Compression',elements={'Dark'}},
	[295] = {id=295,english='Liquefaction',elements={'Fire'}},
	[296] = {id=296,english='Induration',elements={'Ice'}},
	[297] = {id=297,english='Reverberation',elements={'Water'}},
	[298] = {id=298,english='Transfixion', elements={'Light'}},
	[299] = {id=299,english='Scission',elements={'Earth'}},
	[300] = {id=300,english='Detonation',elements={'Wind'}},
	[301] = {id=301,english='Impaction',elements={'Thunder'}},
	[385] = {id=385,english='Light',elements={'Light','Thunder','Wind','Fire'}},
	[386] = {id=386,english='Darkness',elements={'Dark','Ice','Water','Earth'}},
	[387] = {id=387,english='Gravitation',elements={'Dark','Earth'}},
	[388] = {id=388,english='Fragmentation',elements={'Thunder','Wind'}},
	[389] = {id=389,english='Distortion',elements={'Ice','Water'}},
	[390] = {id=390,english='Fusion',elements={'Light','Fire'}},
	[391] = {id=391,english='Compression',elements={'Dark'}},
	[392] = {id=392,english='Liquefaction',elements={'Fire'}},
	[393] = {id=393,english='Induration',elements={'Ice'}},
	[394] = {id=394,english='Reverberation',elements={'Water'}},
	[395] = {id=395,english='Transfixion', elements={'Light'}},
	[396] = {id=396,english='Scission',elements={'Earth'}},
	[397] = {id=397,english='Detonation',elements={'Wind'}},
	[398] = {id=398,english='Impaction',elements={'Thunder'}},
	[767] = {id=767,english='Radiance',elements={'Light','Thunder','Wind','Fire'}},
	[768] = {id=768,english='Umbra',elements={'Dark','Ice','Water','Earth'}},
	[769] = {id=769,english='Radiance',elements={'Light','Thunder','Wind','Fire'}},
	[770] = {id=770,english='Umbra',elements={'Dark','Ice','Water','Earth'}},
}

function run_burst(data)
	local action = data.targets[1].actions[1]
	if	   (action.add_effect_message > 287 and action.add_effect_message < 302) -- Normal SC DMG
		or (action.add_effect_message > 384 and action.add_effect_message < 399) -- SC Heals
		or (action.add_effect_message > 766 and action.add_effect_message < 771) -- Umbra/Radiance
        then
		local party_ids = {}
	    -- Get ids of all current party member
		for index, member in pairs (party) do
			if (type(member) == 'table' and member.mob) then
				party_ids[member.mob.id] = member.mob.name
			end
		end
		local t = windower.ffxi.get_mob_by_id(data.targets[1].id)
		if t and t.spawn_type == 16 and t.distance:sqrt() < 21 and party_ids[t.claim_id] then
			log(t.name.." ready to burst!")
			-- Update the information to track
			last_skillchain = data
			last_skillchain_time = os.clock()
			local skillchain = skillchains[action.add_effect_message]
			local elements = ''
			for index, element in pairs(skillchain.elements) do
				elements = elements..element..','
			end
			elements = elements:sub(1, #elements - 1) -- remove last character
			-- Send the info to continue a skillchain based off property
			skillchain_property(skillchain.english, t.id)
			if skillchain.english == 'Light' then
				info('Skillchain: Light - (Light, Fire, Thunder, Wind)')
			elseif skillchain.english == 'Darkness' then
				info('Skillchain: Dark - (Dark, Earth, Water, Ice)')
			elseif skillchain.english == 'Radiance' then
				info('Skillchain: Radiance - (Light, Fire, Thunder, Wind)')
			elseif skillchain.english == 'Umbra' then
				info('Skillchain: Umbra - (Dark, Earth, Water, Ice)')
			elseif skillchain.english == 'Gravitation' then
				info('Skillchain: Gravitation - (Dark, Earth)')
			elseif skillchain.english == 'Fragmentation' then
				info('Skillchain: Fragmentation - (Thunder, Wind)')
			elseif skillchain.english == 'Distortion' then
				info('Skillchain: Distortion - (Water, Ice)')
			elseif skillchain.english == 'Fusion' then
				info('Skillchain: Fusion - (Light, Fire)')
			elseif skillchain.english == 'Compression' then
				info('Skillchain: Compression	- (Dark)')
			elseif skillchain.english == 'Liquefaction' then
				info('Skillchain: Liquefaction - (Fire)')
			elseif skillchain.english == 'Induration' then
				info('Skillchain: Induration - (Ice)')
			elseif skillchain.english == 'Reverberation' then
				info('Skillchain: Reverberation - (Water)')
			elseif skillchain.english == 'Transfixion' then
				info('Skillchain: Transfixion	- (Light)')
			elseif skillchain.english == 'Scission' then
				info('Skillchain: Scission - (Earth)')
			elseif skillchain.english == 'Detonation' then
				info('Skillchain: Detonation - (Wind)')
			elseif skillchain.english == 'Impaction' then
				info('Skillchain: Impaction - (Thunder)')
			end
			windower.send_command('timers c "Skillchain: '..skillchain.english..'" 5 down')
			local action = 'burst_'..skillchain.english..'_'..elements..'_'..t.id
			table.insert(player_task_data, action)
			log(action)
		end
	elseif data.category == 3 and data.param ~= 0 and last_skillchain and last_skillchain.targets and #last_skillchain.targets > 0 then
		if data.targets[1] and data.targets[1].id == last_skillchain.targets[1].id then
			log('Skillchain is closed for ['..last_skillchain.targets[1].id..']')
			local action = 'burst_closed_none_'..data.targets[1].id
			last_skillchain = {}
			table.insert(player_task_data, action)
			log(action)
		end
	end
end