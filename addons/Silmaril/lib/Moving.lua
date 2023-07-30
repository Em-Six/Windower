do
	local autorun = 0
	local autorun_target = 0
	local autorun_distance = 0
	local autorun_tofrom = 0
	local mov = {x=0, y=0, z=0}
	local runtime = .25
	local runsstart = os.clock()
	local face_target_dir = false

	function combat_movement()
		if player.status ~= 0 and player.status ~=1 and player.status ~=5 and player.status ~=85 then
			autorun = 0
		end
		if autorun == 1 and autorun_distance and autorun_tofrom and not injecting then
			local now = os.clock()
			if(now - runsstart > runtime) then
				log('Time running ['..(now - runsstart)..'] now turning off running')
				windower.ffxi.run(false)
				autorun = 0
				return
			end
			-- Update the locations of the target if a IPC message is recieved for that player.index and clear old data
			local t = party_location[autorun_target]
			if t and t.zone == world.zone then
				t.spawn_type = 1
				t.valid_target = true
				t.distance = (player_location.x-t.x)^2 + (player_location.y-t.y)^2 + (player_location.z-t.z)^2
			else
				t = windower.ffxi.get_mob_by_id(autorun_target)
			end
			if t and t.valid_target and (t.status == 0 or t.status == 1 or t.status == 85 or t.status == 5) then
				if t.spawn_type == 16 and t.status > 1 then -- enemy dead
						windower.ffxi.run(false)
						autorun = 0
						log('Stopping because enemy is dead')
				elseif autorun_tofrom == 1 then -- run towards
					if t.distance:sqrt() < autorun_distance then	
						windower.ffxi.run(false)
						autorun = 0
					else 
						local angle = (math.atan2((t.y - player_location.y), (t.x - player_location.x))*180/math.pi)*-1
						windower.ffxi.run((angle):radian())
					end
				elseif autorun_tofrom == 2 then -- run away from
					if t.distance:sqrt() > autorun_distance then	
						windower.ffxi.run(false)
						autorun = 0
					else
						local angle = (math.atan2((t.y - player_location.y), (t.x - player_location.x))*180/math.pi)*-1
						windower.ffxi.run((angle+180):radian())
					end
				elseif autorun_tofrom == 3 then -- follow
					runsstart = os.clock()
					following = true
					if t.distance:sqrt() + .05 < autorun_distance then
						if moving and t.name ~= player.name then
							windower.ffxi.run(false)
						end
						if math.abs(t.heading - player_location.heading) > .05 and not moving and face_target_dir then
							if player.status == 0 or player.status == 5 or player.status == 85 then
								windower.ffxi.turn(t.heading)
							end
						end
					elseif t.zone == world.zone then
						local angle = (math.atan2((t.y - player_location.y), (t.x - player_location.x))*180/math.pi)*-1
						windower.ffxi.run((angle):radian())
					else
						autorun = 0
						windower.ffxi.run(false)
					end
				end
			else
				windower.ffxi.run(false)
				autorun_tofrom = 0
				autorun = 0
			end 
		end
	end

	function runto(target,distance)
		if move_to_exit then
			log("Abort command - Zoning [RunTo]")
			return
		end
		if target and enabled then
			autorun = 1
			autorun_target = target.id
			autorun_distance = tonumber(distance)
			autorun_tofrom = 1	
			runsstart = os.clock()
		end
	end

	function runaway(target, distance) 
		if move_to_exit then
			log("Abort command - Zoning [RunAway]")
			return
		end
		if target and enabled then 
			if player.target_locked then 
				windower.send_command("input /lockon")
			end
			autorun = 1
			autorun_target = target.id
			autorun_distance = tonumber(distance)
			autorun_tofrom = 2
			runsstart = os.clock()
		end
	end

	function runStop()
		if move_to_exit then
			log("Abort command - Zoning [RunStop]")
			return
		end
		windower.ffxi.run(false)
		autorun = 0
		autorun_tofrom = 0
		autorun_target = player.id
		following = false
		runsstart = os.clock()
	end

	function follow (target,distance)
		if move_to_exit then
			log("Abort command - Zoning [Follow]")
			return
		end
		if target then
			autorun = 1
			autorun_target = target.id
			autorun_distance = tonumber(distance)
			autorun_tofrom = 3
			runsstart = os.clock()
		end
	end

	function fastfollow (target,distance,face)
		if move_to_exit then
			log("Abort command - Zoning [FastFollow]")
			return
		end
		if target then
			autorun = 1
			autorun_target = target.id
			autorun_distance = tonumber(distance)
			autorun_tofrom = 3
			runsstart = os.clock()
			if face == "True" then
				face_target_dir = true
			else
				face_target_dir = false
			end
		end
	end

	function facemob(target)
		if move_to_exit then
			log("Abort command - Zoning [FaceMob]")
			return
		end
		if target and enabled then
			local angle = (math.atan2((target.y - player_location.y), (target.x - player_location.x))*180/math.pi)*-1
			windower.ffxi.turn((angle):radian())
		end
	end

	function lockon(target, lock) 
		if target and enabled then 
			if player.target_locked and lock == "0" then 
				windower.send_command("input /lockon")
			elseif not player.target_locked and lock == "1" then
				if player.target_index ~= target.index then
					log("Lock on ["..target.id..']')
					local inject = packets.new("incoming", 0x058, {
						['Player'] = player.id,
						['Target'] = target.id,
						['Player Index'] = player.index,
					})
					packets.inject(inject)
				else
					windower.send_command("input /lockon")
				end
			end
		end
	end

	function IPC_update()
		if player then
			player_location = windower.ffxi.get_mob_by_id(player.id) -- Update the player information
			player_info()
			if player_location then
				local movement = math.sqrt((player_location.x-mov.x)^2 + (player_location.y-mov.y)^2 + (player_location.z-mov.z)^2 ) > 0.05
				local character = { id = player.id, name = player.name, zone = world.zone, x = player_location.x, y = player_location.y, z = player_location.z, heading = player_location.heading, status = player.status, target_index = player.target_index}
				party_location[player.id] = character -- Update the party table with player info also
				if movement and not moving then
					moving = true
				elseif not movement and moving then
					moving = false
				end
				windower.send_ipc_message('update '..player.id..' '..player.name..' '..world.zone..' '..player_location.x..' '..player_location.y..' '..player_location.z..' '..player_location.heading..' '..player.status..' '..player.target_index)
				mov.x = player_location.x
				mov.y = player_location.y
				mov.z = player_location.z
				combat_movement()
			end
		end
	end

	function zone_check(player_id, zone, player_x, player_y, player_z, type, zone_line)
		if autorun_target == player_id and world.zone == zone then
			local distance = (player_location.x-player_x)^2 + (player_location.y-player_y)^2 + (player_location.z-player_z)^2
			if world.mog_house and following then
				runStop()
				log("Mog House zone packet injected")
				local packet = packets.new('outgoing', 0x05E, 
					{
						['Zone Line'] = zone_line, 
						['Type'] = type
					})
				packets.inject(packet)
			else
				log('Zone Detected - turning and running towards zone')
				move_to_exit = true
				local angle = (math.atan2((player_y - player_location.y), (player_x - player_location.x))*180/math.pi)*-1
				autorun = 0
				windower.ffxi.run((angle):radian())
			end
		end
	end
end