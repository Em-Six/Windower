do

	local last_skillchain_id = 0

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

		if (action.add_effect_message > 287 and action.add_effect_message < 302) -- Normal SC DMG
		or (action.add_effect_message > 384 and action.add_effect_message < 399) -- SC Heals
		or (action.add_effect_message > 766 and action.add_effect_message < 771) -- Umbra/Radiance
		then

			-- Get the party id's to validate the target from Party.lua
			local pt_ids = get_party_ids()

			local t = windower.ffxi.get_mob_by_id(data.targets[1].id)

			-- valid party target and within range
			if t and t.spawn_type == 16 and t.distance:sqrt() < 21 then

				-- Update the enemy to track
				last_skillchain_id = t.id

				-- get the type of skillchain
				local skillchain = skillchains[action.add_effect_message]

				-- Find the elements
				local elements = ''
				for index, element in pairs(skillchain.elements) do
					elements = elements..element..','
				end
				elements = elements:sub(1, #elements - 1)

				-- Send the info to continue a skillchain based off property via Skillchains.lua
				run_property_skillchain(skillchain.english, t.id)

				-- Display the info to the user
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

				-- Create a count down timer
				windower.send_command('timers c "Skillchain: '..skillchain.english..'" 5 down')

				-- Send the information
				send_packet(get_player_id()..';burst_'..skillchain.english..'_'..elements..'_'..t.id)
			end
		elseif data.category == 3 and data.param ~= 0 then
			local t = windower.ffxi.get_mob_by_id(data.targets[1].id)
			-- This is used to stop bursting if a ws happened to close the window
			if t and t.id == last_skillchain_id then
				log('Skillchain is closed for ['..last_skillchain_id..']')
				local action = get_player_id()..';burst_closed_none_'..last_skillchain_id
				last_skillchain_id = 0
				send_packet(action)
			end
		end
	end

	function corsair_shot(data)
		-- Used for COR shot
		local spell = get_spell(data.param)
		local t = windower.ffxi.get_mob_by_id(data.targets[1].id)
		-- valid party target and within range
		if t and t.spawn_type == 16 and t.distance:sqrt() < 21 and spell then
			if spell.name == 'Dia' or spell.name == 'Dia II' or spell.name == 'Dia III' or spell.name == 'Diaga' then
				log("Light Shot Detected")
				send_packet(get_player_id()..';burst_Enfeeble_Light_'..t.id)
			elseif spell.name == 'Bio' or 
					spell.name == 'Bio II' or 
					spell.name == 'Bio III' or 
					spell.name == 'Blind' or 
					spell.name == 'Blind II' or 
					spell.name == 'Kurayami: Ichi' or 
					spell.name == 'Kurayami: Ni' then
				log("Dark Shot Detected")
				send_packet(get_player_id()..';burst_Enfeeble_Dark_'..t.id)
			elseif spell.name == 'Burn' then
				log("Fire Shot Detected")
				send_packet(get_player_id()..';burst_Enfeeble_Fire_'..t.id)
			elseif spell.name == 'Poison' or spell.name == 'Poison II' or spell.name == 'Drown' then
				log("Water Shot Detected")
				send_packet(get_player_id()..';burst_Enfeeble_Water_'..t.id)
			elseif spell.name == 'Shock' then
				log("Thunder Shot Detected")
				send_packet(get_player_id()..';burst_Enfeeble_Thunder_'..t.id)
			elseif spell.name == 'Slow' or spell.name == 'Hojo: Ichi' or spell.name == 'Hojo: Ni' or spell.name == 'Rasp' then
				log("Earth Shot Detected")
				send_packet(get_player_id()..';burst_Enfeeble_Earth_'..t.id)
			elseif spell.name == 'Choke' then
				log("Wind Shot Detected")
				send_packet(get_player_id()..';burst_Enfeeble_Thunder_'..t.id)
			elseif spell.name == 'Paralyze' or spell.name == 'Paralyze II' or spell.name == 'Frost' then
				log("Ice Shot Detected")
				send_packet(get_player_id()..';burst_Enfeeble_Ice_'..t.id)
			end
		end
	end

end