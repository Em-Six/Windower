function run_buffs(id, data)
    for k = 0, 5 do
        local Character = nil
        local formattedString = nil
        local userIndex = nil
        local buff_string = ''
        local Uid = data:unpack('I', k * 48 + 5)
        if Uid then
            userIndex = Uid
        else
            userIndex = nil
        end
        if userIndex then
            Character = windower.ffxi.get_mob_by_id(userIndex)
        end
        -- Limit packets being sent
        if Character and player and Character.name and player.name then
            formattedString = player.name..";buffs_"..Character.name.."_"
            for i = 1, 32 do
                local current_buff = data:byte(k * 48 + 5 + 16 + i - 1) + 256 * (math.floor(data:byte(k * 48 + 5 + 8 + math.floor((i - 1) / 4)) / 4 ^ ((i - 1) % 4)) % 4)
                if current_buff ~= 255 and current_buff ~= 0 then
                    buff_string = buff_string..current_buff..","
                end
            end
            if #buff_string > 1 then
                buff_string = buff_string:sub(1, #buff_string - 1) -- remove last character
            end
            formattedString = formattedString..buff_string
            party_buffs[Character.name] = formattedString
            --log(formattedString)
        end
    end
end