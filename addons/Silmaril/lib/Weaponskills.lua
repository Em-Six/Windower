do
    local all_weaponskills = res.weapon_skills

    function get_all_weaponskills()
        local formattedString = get_player_id()..";weaponskilldata_"
        local all_weaponskill_count = 0
        for id, ws in pairs(all_weaponskills) do
            if ws.skill then
                formattedString = formattedString..ws.id..'|'..ws.en..'|'..ws.range..'|'..res.skills[ws.skill].en..','
                if ws.id and tonumber(ws.id) > tonumber(all_weaponskill_count) then
                    all_weaponskill_count = ws.id
                end
            end
        end
        formattedString = formattedString:sub(1, #formattedString - 1) -- remove last character
        --log(formattedString)
        return formattedString..'_'..all_weaponskill_count
    end

    function get_weaponskill(id)
        return all_weaponskills[id]
    end

end
