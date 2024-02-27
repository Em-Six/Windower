do
    local party_buffs = {}
    local all_buffs = res.buffs

    function run_buffs(data)

        -- Clear the table
        party_buffs = {}

        local player_id = get_player_id()

        for k = 0, 5 do
            local formattedString = nil
            local buff_string = ''
            local Uid = data:unpack('I', k * 48 + 5)

            -- Limit packets being sent and dont send self (grabs it from status update)
            if Uid and Uid ~= player_id then
                formattedString = "partybuffs_"..Uid.."_"
                for i = 1, 32 do
                    local current_buff = data:byte(k * 48 + 5 + 16 + i - 1) + 256 * (math.floor(data:byte(k * 48 + 5 + 8 + math.floor((i - 1) / 4)) / 4 ^ ((i - 1) % 4)) % 4)
                    if current_buff ~= 255 and current_buff ~= 0 then
                        buff_string = buff_string..current_buff..","
                    end
                end
                if #buff_string > 1 then
                    buff_string = buff_string:sub(1, #buff_string - 1)
                end
                formattedString = formattedString..buff_string
                party_buffs[Uid] = formattedString
            end

        end
    end

    -- Only called once so don't load the resource in memory
    function get_all_buffs()
        local formattedString = get_player_id()..";buffdata_"
        local all_buff_count = 0
        local index = {
	        [539] ="Geomancy Regen",
	        [540] ="Geomancy Poison",
	        [541] ="Geomancy Refresh",
	        [580] ="Geomancy Haste",
	        [542] ="Geomancy STR Boost",
	        [543] ="Geomancy DEX Boost",
	        [544] ="Geomancy VIT Boost",
	        [545] ="Geomancy AGI Boost",
	        [546] ="Geomancy INT Boost",
	        [547] ="Geomancy MND Boost",
	        [548] ="Geomancy CHR Boost",
	        [549] ="Geomancy Attack Boost",
	        [550] ="Geomancy Defense Boost",
	        [551] ="Geomancy Magic Atk. Boost",
	        [552] ="Geomancy Magic Def. Boost",
	        [553] ="Geomancy Accuracy Boost",
	        [554] ="Geomancy Evasion Boost",
	        [555] ="Geomancy Magic Acc. Boost",
	        [556] ="Geomancy Magic Evasion Boost",
	        [557] ="Geomancy Attack Down",
	        [558] ="Geomancy Defense Down",
	        [559] ="Geomancy Magic Atk. Down",
	        [560] ="Geomancy Magic Def. Down",
	        [561] ="Geomancy Accuracy Down",
	        [562] ="Geomancy Evasion Down",
	        [563] ="Geomancy Magic Acc. Down",
	        [564] ="Geomancy Magic Evasion Down",
	        [565] ="Geomancy Slow",
	        [566] ="Geomancy Paralysis",
	        [567] ="Geomancy Weight",}

        for id, buff in pairs(all_buffs) do
            if index[buff.id] then
                buff.en = index[buff.id]
            end
            formattedString = formattedString..buff.id..'|'..buff.en..','
            if buff.id and buff.id > all_buff_count then
                all_buff_count = buff.id
            end
        end
        formattedString = formattedString:sub(1, #formattedString - 1)
        --log(formattedString)
        return formattedString..'_'..all_buff_count
    end

    function get_party_buffs()
        return party_buffs
    end

    function get_buff(id)
        return all_buffs[id]
    end

end