function sync_data() -- uses resource files to send to Silmaril
    get_all_spells()
    get_all_abilities()
    get_all_buffs()
    get_all_weaponskills()
    get_all_jobs()
    get_all_traits()
    get_all_status()
    get_all_zone_data()
    get_all_city_data()
    get_all_weather_data()
    get_all_day_data()
    send_packet(player.name..";globalsync_true")
    log(player.name..";globalsync_true")
end

function get_all_spells() -- used via sync request and the function call "sync_data"
    local formattedString = nil
    formattedString = player.name..";spelldata_"
    for id, spell in pairs(all_spells) do
        formattedString = formattedString..spell.id..'|'..spell.en..'|'..spell.cast_time..'|'..spell.mp_cost..'|'..spell.range..'|'..spell.type..'|'..targets_table(spell.targets)..','
    end
    formattedString = formattedString:sub(1, #formattedString - 1) -- remove last character
    --log(formattedString)
    send_packet(formattedString)
end

function get_all_abilities() -- used via sync request and the function call "sync_data"
    local formattedString = nil
    formattedString = player.name..";abilitydata_"
    for id, ability in pairs(all_job_abilities) do
        formattedString = formattedString..ability.id..'|'..ability.en..'|'..ability.mp_cost..'|'..ability.tp_cost..'|'..ability.range..'|'..targets_table(ability.targets)..','
    end
    formattedString = formattedString:sub(1, #formattedString - 1) -- remove last character
    --log(formattedString)
    send_packet(formattedString)
end

function get_all_buffs()
    local formattedString = nil
    formattedString = player.name..";buffdata_"
    for id, buff in pairs(all_buffs) do
        formattedString = formattedString..buff.id..'|'..buff.en..','
    end
    formattedString = formattedString:sub(1, #formattedString - 1) -- remove last character
    --log(formattedString)
    send_packet(formattedString)
end

function get_all_weaponskills()
    local formattedString = nil
    formattedString = player.name..";weaponskilldata_"
    for id, ws in pairs(all_weapon_skills) do
        if ws.skill then
            formattedString = formattedString..ws.id..'|'..ws.en..'|'..ws.range..'|'..res.skills[ws.skill].en..','
        end
    end
    formattedString = formattedString:sub(1, #formattedString - 1) -- remove last character
    --log(formattedString)
    send_packet(formattedString)
end

function get_all_jobs()
    local formattedString = nil
    formattedString = player.name..";jobdata_"
    for id, job in pairs(res.jobs) do
        formattedString = formattedString..job.id..'|'..job.en..'|'..job.ens..','
    end
    formattedString = formattedString:sub(1, #formattedString - 1) -- remove last character
    --log(formattedString)
    send_packet(formattedString)
end

function get_all_traits()
    local formattedString = nil
    formattedString = player.name..";traitdata_"
    for id, trait in pairs(res.job_traits) do
        formattedString = formattedString..trait.id..'|'..trait.en..','
    end
    formattedString = formattedString:sub(1, #formattedString - 1) -- remove last character
    --log(formattedString)
    send_packet(formattedString)
end

function get_all_status()
    local formattedString = nil
    formattedString = player.name..";statusdata_"
    for id, status in pairs(res.statuses) do
        formattedString = formattedString..status.id..'|'..status.en..','
    end
    formattedString = formattedString:sub(1, #formattedString - 1) -- remove last character
    --log(formattedString)
    send_packet(formattedString)
end

function targets_table(targets)
    local formattedString = ''
    for type, target in pairs(targets) do
        formattedString = formattedString..type..'$'
    end    
    formattedString = formattedString:sub(1, #formattedString - 1) -- remove last character
    return formattedString
end