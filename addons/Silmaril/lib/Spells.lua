do
    local all_spells = res.spells
    local player_spells = {}

    -- Used once via sync request Sync.lua
    function get_all_spells() 
        local formattedString = get_player_id()..";spelldata_"
        local all_spell_count = 0
        for id, spell in pairs(all_spells) do
            local player_spell = false
            for level, job in pairs(spell.levels) do
                player_spell = true
                break
            end   
            if (not spell.unlearnable and player_spell) or spell.en == "Dispelga" then
                formattedString = formattedString..spell.id..'|'..spell.en..'|'..spell.cast_time..'|'..spell.mp_cost..'|'..spell.range..'|'..spell.type..'|'..targets_table(spell.targets)..','
                if spell.id and tonumber(spell.id) > tonumber(all_spell_count) then
                    all_spell_count = spell.id
                end
            end
        end
        formattedString = formattedString:sub(1, #formattedString - 1)..'_'..all_spell_count
        --log(formattedString)
        return formattedString
    end

    function get_spell_recast() 
        local formattedString = "spells_"

        local spell_recasts = windower.ffxi.get_spell_recasts()
        if not spell_recasts then return formattedString end

        for index, recast in pairs(player_spells) do
            formattedString = formattedString..recast..'|'..round(spell_recasts[recast],2)..','
        end
        formattedString = formattedString:sub(1, #formattedString - 1)
        --log(formattedString)
        return formattedString
    end

     -- Call this on initial load, job change, and periodically (30 sec)
    function get_player_spells()

        -- Clear the old spell list
        player_spells = {}

        -- Load in the player data
        local p = get_player()
        if not p then return end

        -- Try to get the spell data from the game
        local spells_have = nil

        repeat
            spells_have = windower.ffxi.get_spells()
            if not spells_have then
                coroutine.sleep(.1)
            end
        until spells_have
        
        for id, spell in pairs (all_spells) do
            if spells_have[id] == true then
                for job, level in pairs (spell.levels) do
                    if(job == p.main_job_id and level > 99) then -- Merit spell.  You have learned since it appears from the windower.ffxi.get_spells()
                        level = 99
                    end
                    if (job == p.main_job_id and level <= p.main_job_level) or (job == p.sub_job_id and level <= p.sub_job_level) then
                        table.insert(player_spells, id)
                        break
                    end
                end
            end
        end
    end

    function get_spell(id)
        return all_spells[id]
    end
end