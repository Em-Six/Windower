function player_info()
    player = windower.ffxi.get_player() -- Update the player information
    local jp_spent = tostring(player.job_points[player.main_job:lower()].jp_spent)
    local locked_on = false
    --name
    --main_job_id
    --main_job_level
    --sub_job_id
    --sub_job_level
    --superior_level
    --jp_spent

    --target_locked
    if player.target_locked then
        locked_on = true
    end

    --target_locked
    if not player.target_index then
        player.target_index = 0
    end

    -- No sub job unlocked or Oddy
    if not player.sub_job_id then
        player.sub_job_id = "0"
        player.sub_job_level = "0"
    end

    -- Update character status
    player_status = "player_"..tostring(player.main_job_id)..','..tostring(player.main_job_level)..','..tostring(player.sub_job_id)..','
    ..tostring(player.sub_job_level)..','..tostring(jp_spent)..','..tostring(locked_on)..','..tostring(moving)..','..tostring(following)..','..tostring(player.status)
end