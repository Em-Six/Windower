-- XIVHotbar NG - portable hotbar/palette model (no Windower dependencies).
-- Written from scratch; informed by XIVHotbar's slot model and XIUI's palette design.
local M = {}
M.MAX_BARS = 10
M.MAX_SLOTS = 12

local function clone(src)
    if type(src) ~= 'table' then return src end
    local dst = {}
    for k, v in pairs(src) do dst[k] = clone(v) end
    return dst
end
M.clone = clone

local function clamp(value, lower, upper, fallback)
    value = tonumber(value)
    if not value then return fallback end
    return math.max(lower, math.min(upper, math.floor(value)))
end
M.clamp = clamp

local function valid_palette(name)
    return type(name) == 'string' and #name >= 1 and #name <= 24
        and name:match('^[%w_%-]+$') ~= nil
end
M.valid_palette = valid_palette

local function default_bar(i)
    return {
        x = 65,
        y = 240 + (i - 1) * 79,
        size = 40,
        gap = 3,
        visible = (i <= 2),
        vertical = false,
        scope = (i == 1) and 'global' or 'job',
        alpha = 220,
        name = 'Bar ' .. i,
    }
end

function M.new()
    local state = {
        version = 1,
        active_palette = 'default',
        palettes = {default = true},
        bars = {},
        actions = {global = {default = {}}, jobs = {}},
        binds = {},
        settings = {keyboard_layout = 'UK'},
    }
    for i = 1, M.MAX_BARS do state.bars[i] = default_bar(i) end
    return state
end

local function sanitize_slot(v)
    if type(v) ~= 'table' or type(v.command) ~= 'string' then return nil end
    if v.command == '' or #v.command > 512 then return nil end
    return {
        command = v.command,
        label = type(v.label) == 'string' and v.label:sub(1, 32) or '',
        icon = type(v.icon) == 'string' and v.icon:sub(1, 160) or '',
    }
end

local function normalize_pages(pages, allowed)
    local result = {}
    if type(pages) ~= 'table' then return result end
    for palette, bars in pairs(pages) do
        if allowed[palette] and type(bars) == 'table' then
            result[palette] = {}
            for bar, slots in pairs(bars) do
                if type(bar) == 'number' and bar >= 1 and bar <= M.MAX_BARS
                    and bar % 1 == 0 and type(slots) == 'table' then
                    result[palette][bar] = {}
                    for slot, record in pairs(slots) do
                        if type(slot) == 'number' and slot >= 1 and slot <= M.MAX_SLOTS
                            and slot % 1 == 0 then
                            result[palette][bar][slot] = sanitize_slot(record)
                        end
                    end
                end
            end
        end
    end
    return result
end

function M.normalize(saved)
    local result = M.new()
    if type(saved) ~= 'table' then return result end
    if type(saved.palettes) == 'table' then
        for name, flag in pairs(saved.palettes) do
            if valid_palette(name) and flag then result.palettes[name] = true end
        end
    end
    if result.palettes[saved.active_palette] then result.active_palette = saved.active_palette end
    if type(saved.bars) == 'table' then
        for i = 1, M.MAX_BARS do
            local value = saved.bars[i]
            if type(value) == 'table' then
                local bar = result.bars[i]
                bar.x = clamp(value.x, -2000, 10000, bar.x)
                bar.y = clamp(value.y, -2000, 10000, bar.y)
                bar.size = clamp(value.size, 22, 80, bar.size)
                bar.gap = clamp(value.gap, 0, 20, bar.gap)
                bar.alpha = clamp(value.alpha, 40, 255, bar.alpha)
                if type(value.visible) == 'boolean' then bar.visible = value.visible end
                if type(value.vertical) == 'boolean' then bar.vertical = value.vertical end
                if value.scope == 'global' or value.scope == 'job' then bar.scope = value.scope end
                if type(value.name) == 'string' and #value.name <= 24 and #value.name > 0 then
                    bar.name = value.name
                end
            end
        end
    end
    if type(saved.actions) == 'table' then
        result.actions.global = normalize_pages(saved.actions.global, result.palettes)
        result.actions.global.default = result.actions.global.default or {}
        if type(saved.actions.jobs) == 'table' then
            for job, pages in pairs(saved.actions.jobs) do
                if type(job) == 'string' and job:match('^[A-Z][A-Z][A-Z]$') then
                    result.actions.jobs[job] = normalize_pages(pages, result.palettes)
                end
            end
        end
    end
    if type(saved.settings) == 'table' and saved.settings.keyboard_layout == 'US' then
        result.settings.keyboard_layout = 'US'
    end
    if type(saved.binds) == 'table' then
        for bar, slots in pairs(saved.binds) do
            if type(bar) == 'number' and bar >= 1 and bar <= M.MAX_BARS and bar % 1 == 0
                and type(slots) == 'table' then
                result.binds[bar] = {}
                for slot, key in pairs(slots) do
                    if type(slot) == 'number' and slot >= 1 and slot <= M.MAX_SLOTS
                        and slot % 1 == 0 and type(key) == 'string' and #key <= 36
                        and key:match('^[%%%^!~%w%[%]%-]+$') then
                        result.binds[bar][slot] = key
                    end
                end
            end
        end
    end
    return result
end

local function page(state, bar_index, job, create)
    local bar = state.bars[bar_index]
    if not bar then return nil end
    local pages
    if bar.scope == 'global' then
        pages = state.actions.global
    else
        job = type(job) == 'string' and job:upper() or 'UNK'
        if not state.actions.jobs[job] then
            if not create then return nil end
            state.actions.jobs[job] = {}
        end
        pages = state.actions.jobs[job]
    end
    local palette = state.active_palette
    if not pages[palette] then
        if not create then return nil end
        pages[palette] = {}
    end
    if not pages[palette][bar_index] then
        if not create then return nil end
        pages[palette][bar_index] = {}
    end
    return pages[palette][bar_index]
end

function M.get_slot(state, bar, slot, job)
    local p = page(state, bar, job, false)
    return p and p[slot] or nil
end

function M.set_slot(state, bar, slot, job, record)
    if type(bar) ~= 'number' or bar < 1 or bar > M.MAX_BARS
        or type(slot) ~= 'number' or slot < 1 or slot > M.MAX_SLOTS then return false end
    local clean = record and sanitize_slot(record) or nil
    if record and not clean then return false end
    local p = page(state, bar, job, true)
    p[slot] = clean
    return true
end

function M.swap_slots(state, b1, s1, b2, s2, job)
    if not state.bars[b1] or not state.bars[b2] or s1 < 1 or s1 > M.MAX_SLOTS
        or s2 < 1 or s2 > M.MAX_SLOTS then return false end
    local a = M.get_slot(state, b1, s1, job)
    local b = M.get_slot(state, b2, s2, job)
    M.set_slot(state, b1, s1, job, b)
    M.set_slot(state, b2, s2, job, a)
    return true
end

function M.create_palette(state, name, copy_existing)
    if not valid_palette(name) or state.palettes[name] then return false end
    local previous = state.active_palette
    state.palettes[name] = true
    if copy_existing then
        state.actions.global[name] = clone(state.actions.global[previous] or {})
        for _, jobs in pairs(state.actions.jobs) do
            jobs[name] = clone(jobs[previous] or {})
        end
    else
        state.actions.global[name] = {}
    end
    state.active_palette = name
    return true
end

function M.select_palette(state, name)
    if not state.palettes[name] then return false end
    state.active_palette = name
    return true
end

function M.delete_palette(state, name)
    if name == 'default' or not state.palettes[name] then return false end
    state.palettes[name] = nil
    state.actions.global[name] = nil
    for _, jobs in pairs(state.actions.jobs) do jobs[name] = nil end
    if state.active_palette == name then state.active_palette = 'default' end
    return true
end

function M.palette_names(state)
    local names = {}
    for name in pairs(state.palettes) do names[#names + 1] = name end
    table.sort(names)
    return names
end

return M
