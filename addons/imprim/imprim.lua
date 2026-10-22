_addon.name = 'ImprimaturHUD'
_addon.author = 'OpenAI'
_addon.version = '1.1.0'
_addon.commands = {'imps', 'imprimaturhud'}

-- Windower 4 / retail FFXI. No external dependencies beyond Windower's libraries.
local packets = require('packets')
local texts = require('texts')
local res = require('resources')

local TOP_MARGIN = 8
local cap_override = nil   -- nil = detect cap automatically (15, 16 or 18).

local count = nil
local max_count = 15
local warned = false

local hud = texts.new({
    pos = {x = 0, y = TOP_MARGIN},
    text = {
        font = 'Consolas',
        size = 12,
        red = 235, green = 235, blue = 235,
        stroke = {width = 2, alpha = 255, red = 0, green = 0, blue = 0},
    },
    padding = 4,
    bg = {visible = true, alpha = 110, red = 0, green = 0, blue = 0},
    flags = {bold = true, draggable = false},
})

local function detect_max()
    if cap_override then
        return cap_override
    end

    local cap = 15
    local held = windower.ffxi.get_key_items() or {}
    for _, id in pairs(held) do
        local info = res.key_items[id]
        local name = info and (info.en or info.english or info.name)
        if type(name) == 'string' then
            name = name:lower()
            if name == 'silver mattock cordon' then
                return 18
            elseif name == 'bronze mattock cordon' then
                cap = 16
            end
        end
    end
    return cap
end

local function redraw()
    max_count = detect_max()
    local capped = count ~= nil and count >= max_count
    local shown = count ~= nil and tostring(count) or '--'
    hud:text(('Imprimaturs: %s/%d%s'):format(shown, max_count, capped and '  MAX' or ''))

    if capped then
        hud:color(255, 85, 85)  -- Red when at the character's cap.
    else
        hud:color(235, 235, 235)
    end

    -- Centre the counter at the top of the game window.
    hud:show()
    local settings = windower.get_windower_settings()
    local width = select(1, hud:extents()) or 0
    local screen_width = settings and settings.x_res or 1280
    hud:pos(math.max(0, math.floor((screen_width - width) / 2)), TOP_MARGIN)
end

local function request_count()
    local info = windower.ffxi.get_info()
    if info and info.logged_in then
        -- The game's standard request for Currency 2 (incoming response 0x118).
        packets.inject(packets.new('outgoing', 0x115))
    end
end

windower.register_event('incoming chunk', function(id, data)
    if id ~= 0x118 then return end

    local success, p = pcall(packets.parse, 'incoming', data)
    if not success or type(p) ~= 'table' then return end

    -- Look up the field by name, so small capitalization/label changes don't matter.
    local new_count
    for field, value in pairs(p) do
        if type(field) == 'string' and field:lower():find('imprim', 1, true) then
            new_count = tonumber(value)
            if new_count then break end
        end
    end

    if new_count then
        count = new_count
        warned = false
        redraw()
    elseif not warned then
        warned = true
        windower.add_to_chat(123, '[ImprimaturHUD] Could not find the imprimatur field in Currency 2 (0x118). Check Windower packet libraries.')
    end
end)

windower.register_event('load', function()
    redraw()
    -- A refresh is needed if the addon was loaded after the login packets arrived.
    coroutine.schedule(request_count, 2)
end)

windower.register_event('login', function()
    count = nil
    redraw()
    coroutine.schedule(request_count, 3)
end)

windower.register_event('zone change', function()
    coroutine.schedule(request_count, 3)
end)

windower.register_event('logout', function()
    count = nil
    redraw()
end)

windower.register_event('addon command', function(command, value)
    command = (command or 'help'):lower()
    if command == 'refresh' then
        request_count()
    elseif command == 'cap' then
        if not value or value:lower() == 'auto' then
            cap_override = nil
        else
            local n = tonumber(value)
            if n ~= 15 and n ~= 16 and n ~= 18 then
                windower.add_to_chat(123, '[ImprimaturHUD] Valid caps: 15, 16, 18 or auto.')
                return
            end
            cap_override = n
        end
        redraw()
    else
        windower.add_to_chat(207, '[ImprimaturHUD] //imps refresh | //imps cap auto|15|16|18')
    end
end)

windower.register_event('unload', function()
    hud:destroy()
end)
