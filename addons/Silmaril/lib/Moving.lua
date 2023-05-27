do
	local autorun = 0
	local autorun_target = 0
	local autorun_distance = 0
	local autorun_tofrom = 0
	local mov = {x=0, y=0, z=0}
	local runtime = 1
	local runsstart = os.clock()
	local zone_time = 0

	function combat_movement()
		if autorun == 1 and autorun_distance and autorun_tofrom then
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
				t.status = 0
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
					if t.distance:sqrt() < autorun_distance then
						if moving and t.name ~= player.name then
							windower.ffxi.run(false)
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
		if target and enabled and os.clock() - zone_time > 2 then
			autorun = 1
			autorun_target = target.id
			autorun_distance = tonumber(distance)
			autorun_tofrom = 1	
			runsstart = os.clock()
		end
	end

	function runaway(target, distance) 
		-- if not targeting self and has a valid targets
		if target and enabled and os.clock() - zone_time > 2 then 
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
		if os.clock() - zone_time > 2 then
			windower.ffxi.run(false)
			autorun = 0
			autorun_tofrom = 0
			autorun_target = player.id
			following = false
			runsstart = os.clock()
		end
	end

	function follow (target,distance)
		if target then
			autorun = 1
			autorun_target = target.id
			autorun_distance = tonumber(distance)
			autorun_tofrom = 3	
			runsstart = os.clock()
		end
	end

	function facemob(target)
		if target and enabled then
			local angle = (math.atan2((target.y - player_location.y), (target.x - player_location.x))*180/math.pi)*-1
			windower.ffxi.turn((angle):radian())
		end
	end

	function moving_check()
		if player.status == 0 or player.status == 1 or player.status == 85 or player.status == 5 then
			player_location = windower.ffxi.get_mob_by_id(player.id) -- Update the player information
			if player_location then
				local movement = math.sqrt((player_location.x-mov.x)^2 + (player_location.y-mov.y)^2 + (player_location.z-mov.z)^2 ) > 0.05
				if movement then
					windower.send_ipc_message('update '..player.id..' '..player.name..' '..world.zone..' '..player_location.x..' '..player_location.y..' '..player_location.z)
				end
				if movement and not moving then
					moving = true
				elseif not movement and moving then
					moving = false
				end
				mov.x = player_location.x
				mov.y = player_location.y
				mov.z = player_location.z
				combat_movement()
			end
		end
	end

	function zone_check(player_id, player_x, player_y)
		if os.clock() - runsstart < 8 and autorun_target == player_id then
			log('Zone Detected - turning and running towards zone')
			autorun = 0
			zone_time = os.clock()
			local angle = (math.atan2((player_y - player_location.y), (player_x - player_location.x))*180/math.pi)*-1
			windower.ffxi.run((angle):radian())
		end
	end
end