-- XIVHotbar NG v0.2.0 (Windower 4)
-- Independent, from-scratch addon inspired by XIVHotbar and XIUI hotbars.
-- No Ashita code is included. This is an early in-game test build.
_addon.name = 'XIVHotbarNG'
_addon.author = 'Community prototype'
_addon.version = '0.2.0'
_addon.language = 'english'
_addon.commands = {'htbng', 'xivhotbarng'}

local images = require('images')
local texts = require('texts')
local res = require('resources')
local model = require('lib/model')
local storage = require('lib/storage')
local actions = require('lib/actions')
local View = require('lib/view')
local GUI = require('lib/gui')

local saved, view, editor, save_path
local current_job = 'UNK'
local current_character = nil
local moving = nil
local editing = false
local bound = {}
local frames = 0
local last_warning = false

local function message(text)
    windower.add_to_chat(207, '[XIVHotbar NG] ' .. tostring(text))
end

local function number_between(value, lower, upper)
    local n = tonumber(value)
    if n and n == math.floor(n) and n >= lower and n <= upper then return n end
    return nil
end

local function current_player()
    local success, player = pcall(windower.ffxi.get_player)
    if success then return player end
    return nil
end

local function player_job(player)
    if not player then return 'UNK' end
    if type(player.main_job) == 'string' and #player.main_job == 3 then
        return player.main_job:upper()
    end
    if player.main_job_id and res.jobs and res.jobs[player.main_job_id] then
        local job = res.jobs[player.main_job_id]
        local name = job.ens or job.english_short or job.en
        if type(name) == 'string' and #name == 3 then return name:upper() end
    end
    return 'UNK'
end

local function identity(player)
    local server_id = 'server0'
    local ok, info = pcall(windower.ffxi.get_info)
    if ok and type(info) == 'table' and info.server then
        server_id = 'server' .. tostring(info.server)
    end
    return server_id, player.name
end

local function write_save()
    if not saved or not save_path then return end
    local ok, err = storage.save(save_path, saved)
    if not ok then message('Could not save: ' .. tostring(err)) end
end

local function clear_binds()
    for _, key in ipairs(bound) do
        windower.send_command('unbind ' .. key)
    end
    bound = {}
end

local function apply_binds()
    clear_binds()
    if not saved then return end
    local seen = {}
    for bar = 1, model.MAX_BARS do
        for slot = 1, model.MAX_SLOTS do
            local key = saved.binds[bar] and saved.binds[bar][slot]
            if key and not seen[key] then
                windower.send_command('bind ' .. key .. ' htbng execute '
                    .. bar .. ' ' .. slot)
                bound[#bound + 1] = key
                seen[key] = true
            end
        end
    end
end

local function assign_gui_binding(bar, slot, key)
    saved.binds[bar] = saved.binds[bar] or {}
    if key and key ~= '' then
        if #key > 32 or not key:match('^[!%^~%w%[%]%-]+$') then
            message('Invalid Windower key combination.')
            return false
        end
        local full = '%' .. key
        for b = 1, model.MAX_BARS do
            for s = 1, model.MAX_SLOTS do
                if saved.binds[b] and saved.binds[b][s] == full then
                    saved.binds[b][s] = nil
                end
            end
        end
        saved.binds[bar][slot] = full
    else
        saved.binds[bar][slot] = nil
    end
    write_save()
    if not (editor and editor.visible) then apply_binds() end
    if view then view:set_data(saved, current_job) end
    return true
end

local function close_editor()
    if not editor or not editor.visible then return end
    editor:close()
    apply_binds()
    message('GUI editor closed. Hotbar shortcuts restored.')
end

local function toggle_editor()
    if editor and editor.visible then close_editor() return end
    if not saved then return end
    moving = nil
    clear_binds() -- prevent spells/abilities activating while typing into the GUI
    editor:open(saved, current_job)
    message('GUI editor opened. Click a hotbar slot to select it; //htbng gui closes.')
end

local function update_view()
    if view then view:set_data(saved, current_job) end
    if editor and editor.visible then editor:render() end
end

local function start(player)
    if not player or not player.name then return end
    local server, name = identity(player)
    local key = server .. ':' .. name
    if current_character == key and saved then
        local job = player_job(player)
        if job ~= current_job then
            current_job = job
            if editor then editor:sync(saved, current_job) end
            update_view()
        end
        return
    end
    if editor then editor:close() end
    clear_binds()
    if view then view:hide() end
    current_character = key
    current_job = player_job(player)
    save_path = storage.filename(windower.addon_path, server, name)
    local loaded = storage.load(save_path)
    saved = model.normalize(loaded)
    if not view then view = View.new(windower.addon_path, images, texts, actions) end
    if not editor then
        editor = GUI.new(windower.addon_path, images, texts, res, {
            changed = function() update_view(); write_save() end,
            binding = assign_gui_binding,
            close = close_editor,
            notice = message,
        })
    end
    editor:sync(saved, current_job)
    update_view()
    apply_binds()
    if not loaded then write_save() end
    message('Loaded for ' .. name .. ' (' .. current_job
        .. '). Right-click a slot to edit, or use //htbng gui.')
end

local function stop()
    if editor then editor:close() end
    clear_binds()
    if view then view:hide() end
    current_character = nil
    current_job = 'UNK'
    saved = nil
    save_path = nil
    editing = false
    moving = nil
end

local function require_loaded()
    if saved then return true end
    start(current_player())
    if saved then return true end
    if not last_warning then
        message('Please log into a character before configuring hotbars.')
        last_warning = true
    end
    return false
end

local function redraw_and_save()
    update_view()
    write_save()
end

local function perform(bar, slot)
    if not saved then return end
    local action = model.get_slot(saved, bar, slot, current_job)
    if action then actions.execute(action, windower) end
end

local function help()
    message('set BAR SLOT /ma "Cure IV" <stpc>  |  clear BAR SLOT')
    message('label BAR SLOT LABEL  |  icon BAR SLOT file.png  |  execute BAR SLOT')
    message('palette new NAME [copy]  |  palette select NAME  |  palette delete NAME')
    message('palette next  |  palette list  |  bars NUMBER (1-10)')
    message('bar N scope global|job  |  bar N visible on|off  |  bar N vertical on|off')
    message('bar N size 22-80  |  bar N gap 0-20  |  bar N alpha 40-255')
    message('bar N position X Y  |  bar N name TEXT  |  edit  |  gui  |  bind BAR SLOT KEY')
    message('unbind BAR SLOT  |  gui  |  status  |  reload  |  help')
end

local function truthy(word)
    if word == 'on' or word == 'true' or word == 'yes' then return true end
    if word == 'off' or word == 'false' or word == 'no' then return false end
    return nil
end

local function joined(args, first)
    local result = {}
    for i = first, #args do result[#result + 1] = args[i] end
    return table.concat(result, ' ')
end

local function set_action(args)
    local bar = number_between(args[2], 1, 10)
    local slot = number_between(args[3], 1, 12)
    local command = joined(args, 4)
    if not bar or not slot or not command:match('^/') or #command > 512 then
        message('Usage: //htbng set BAR SLOT /ma "Cure IV" <stpc>')
        return
    end
    -- Preserve label/icon if the same slot is being edited.
    local original = model.get_slot(saved, bar, slot, current_job)
    local label = original and original.label or ''
    local icon = original and original.icon or ''
    model.set_slot(saved, bar, slot, current_job,
        {command = command, label = label, icon = icon})
    redraw_and_save()
    message(('Set %d:%d in %s [%s].'):format(bar, slot,
        saved.bars[bar].scope, saved.active_palette))
end

local function manage_palette(args)
    local operation, name = args[2], args[3]
    if operation == 'list' then
        message('Palettes: ' .. table.concat(model.palette_names(saved), ', ')
            .. ' (active: ' .. saved.active_palette .. ')')
        return
    end
    if operation == 'next' then
        local names = model.palette_names(saved)
        local next_name = names[1]
        for i, value in ipairs(names) do
            if value == saved.active_palette then
                next_name = names[(i % #names) + 1]
                break
            end
        end
        model.select_palette(saved, next_name)
    elseif operation == 'new' then
        if not model.create_palette(saved, name, args[4] == 'copy') then
            message('Could not create palette. Use a new name (letters, digits, - or _).')
            return
        end
    elseif operation == 'select' or operation == 'switch' then
        if not model.select_palette(saved, name) then
            message('Unknown palette: ' .. tostring(name))
            return
        end
    elseif operation == 'delete' then
        if not model.delete_palette(saved, name) then
            message('Could not delete palette (default cannot be deleted).')
            return
        end
    else
        message('Usage: palette new NAME [copy] | select NAME | next | list | delete NAME')
        return
    end
    redraw_and_save()
    message('Active palette: ' .. saved.active_palette)
end

local function manage_bar(args)
    local index = number_between(args[2], 1, 10)
    local property, value = args[3], args[4]
    if not index or not property then
        message('Usage: //htbng bar N scope|visible|vertical|size|gap|alpha|position|name VALUE')
        return
    end
    local bar = saved.bars[index]
    if property == 'scope' then
        if value ~= 'global' and value ~= 'job' then message('Use global or job.') return end
        bar.scope = value
    elseif property == 'visible' or property == 'vertical' then
        local enabled = truthy(value)
        if enabled == nil then message('Use on or off.') return end
        bar[property] = enabled
    elseif property == 'size' then
        local size = number_between(value, 22, 80)
        if not size then message('Size: 22 to 80.') return end
        bar.size = size
    elseif property == 'gap' then
        local gap = number_between(value, 0, 20)
        if not gap then message('Gap: 0 to 20.') return end
        bar.gap = gap
    elseif property == 'alpha' then
        local alpha = number_between(value, 40, 255)
        if not alpha then message('Alpha: 40 to 255.') return end
        bar.alpha = alpha
    elseif property == 'position' then
        local x, y = number_between(value, 0, 10000), number_between(args[5], 0, 10000)
        if not x or not y then message('Usage: bar N position X Y') return end
        bar.x, bar.y = x, y
    elseif property == 'name' then
        local name = joined(args, 4)
        if #name < 1 or #name > 24 then message('Name must be 1-24 characters.') return end
        bar.name = name
    else
        message('Unknown bar setting: ' .. property)
        return
    end
    redraw_and_save()
end

local function manage_bind(args, remove)
    local bar, slot = number_between(args[2], 1, 10), number_between(args[3], 1, 12)
    if not bar or not slot then message('Usage: bind BAR SLOT ^1 (or unbind BAR SLOT)') return end
    saved.binds[bar] = saved.binds[bar] or {}
    if remove then
        saved.binds[bar][slot] = nil
    else
        local key = args[4]
        if not key or #key > 32 or not key:match('^[!%^~%w%[%]%-]+$') then
            message('Invalid key: use Windower bind syntax, e.g. ^1, !2, ~F1.')
            return
        end
        -- % limits the bind to when the chat entry field is closed.
        key = '%' .. key
        for b = 1, 10 do
            for s = 1, 12 do
                if saved.binds[b] and saved.binds[b][s] == key then
                    saved.binds[b][s] = nil
                end
            end
        end
        saved.binds[bar][slot] = key
    end
    write_save()
    if not (editor and editor.visible) then apply_binds() end
    update_view()
end

windower.register_event('addon command', function(command, ...)
    command = (command or 'help'):lower()
    if command == 'help' then help() return end
    if not require_loaded() then return end
    local args = {command, ...}
    if command == 'gui' or command == 'editor' then
        toggle_editor()
    elseif command == 'set' then
        set_action(args)
    elseif command == 'clear' or command == 'remove' then
        local bar, slot = number_between(args[2], 1, 10), number_between(args[3], 1, 12)
        if not bar or not slot then message('Usage: clear BAR SLOT') return end
        model.set_slot(saved, bar, slot, current_job, nil)
        redraw_and_save()
    elseif command == 'label' or command == 'icon' then
        local bar, slot = number_between(args[2], 1, 10), number_between(args[3], 1, 12)
        if not bar or not slot then message('Usage: ' .. command .. ' BAR SLOT VALUE') return end
        local record = model.get_slot(saved, bar, slot, current_job)
        if not record then message('That slot is empty.') return end
        local value = joined(args, 4)
        if command == 'label' then
            if #value > 32 then message('Label too long (32 max).') return end
            record.label = value
        else
            if value ~= '' and not value:match('^[%w_%-]+%.png$') then
                message('Icon should be a PNG filename in assets/custom/ (or empty).')
                return
            end
            record.icon = value
        end
        redraw_and_save()
    elseif command == 'execute' then
        local bar, slot = number_between(args[2], 1, 10), number_between(args[3], 1, 12)
        if bar and slot then perform(bar, slot) end
    elseif command == 'palette' then
        manage_palette(args)
    elseif command == 'bar' then
        manage_bar(args)
    elseif command == 'bars' then
        local count = number_between(args[2], 1, 10)
        if not count then message('Usage: bars NUMBER (1-10)') return end
        for i = 1, 10 do saved.bars[i].visible = i <= count end
        redraw_and_save()
    elseif command == 'bind' or command == 'unbind' then
        manage_bind(args, command == 'unbind')
    elseif command == 'edit' or command == 'move' then
        editing = not editing
        moving = nil
        message('Edit mode ' .. (editing and 'ON. Drag headers or swap slots.' or 'OFF.'))
    elseif command == 'reload' then
        local reload = storage.load(save_path)
        if not reload then message('Unable to read current saved file.') return end
        saved = model.normalize(reload)
        if editor then editor:sync(saved, current_job) end
        if not (editor and editor.visible) then apply_binds() end
        update_view()
        message('Configuration reloaded.')
    elseif command == 'status' then
        message('Character: ' .. tostring(current_character) .. ', job: ' .. current_job
            .. ', palette: ' .. saved.active_palette)
        message('Saved data: ' .. save_path)
    else
        message('Unknown command. Use //htbng help')
    end
end)

windower.register_event('mouse', function(kind, x, y, delta, blocked)
    if blocked or not saved or not view or not current_character then return false end
    if editor and editor.visible then
        if editor:mouse(kind, x, y) then return true end
        local hit = view:hit_test(x, y)
        if hit and hit.kind == 'slot' and kind == 1 then
            editor:select_slot(hit.bar, hit.slot)
            return true
        end
        if hit and (kind == 2 or kind == 4 or kind == 5) then return true end
        return false
    end
    if kind == 4 then -- right-click a hotbar slot/header to open GUI
        local hit = view:hit_test(x, y)
        if hit then
            toggle_editor()
            if hit.kind == 'slot' then
                editor.tab='Actions'
                editor:select_slot(hit.bar,hit.slot)
            else
                editor.tab='Bars'
                editor:select_slot(hit.bar,editor.slot)
            end
            editor:render()
            return true
        end
    elseif kind == 5 then
        if view:hit_test(x, y) then return true end
    end
    if kind == 1 then -- left press
        local hit = view:hit_test(x, y)
        if not hit then return false end
        if editing and hit.kind == 'header' then
            local cfg = saved.bars[hit.bar]
            moving = {kind = 'header', bar = hit.bar, dx = x - cfg.x, dy = y - cfg.y}
        elseif hit.kind == 'slot' then
            moving = {kind = 'slot', bar = hit.bar, slot = hit.slot}
        end
        return true
    elseif kind == 0 then -- mouse move
        if editing and moving and moving.kind == 'header' then
            local cfg = saved.bars[moving.bar]
            cfg.x = math.max(0, math.floor(x - moving.dx))
            cfg.y = math.max(0, math.floor(y - moving.dy))
            update_view()
            return true
        end
    elseif kind == 2 then -- left release
        if not moving then return false end
        local old = moving
        moving = nil
        local hit = view:hit_test(x, y)
        if old.kind == 'header' then
            write_save()
        elseif old.kind == 'slot' and hit and hit.kind == 'slot' then
            if editing then
                model.swap_slots(saved, old.bar, old.slot, hit.bar, hit.slot, current_job)
                redraw_and_save()
            elseif hit.bar == old.bar and hit.slot == old.slot then
                perform(old.bar, old.slot)
            end
        end
        return true
    end
    return false
end)

windower.register_event('keyboard', function(dik, pressed, flags, blocked)
    if editor and editor.visible then
        return editor:keyboard(dik, pressed, flags, blocked)
    end
    return false
end)

windower.register_event('login', 'load', function()
    start(current_player())
end)

windower.register_event('logout', 'unload', function()
    stop()
end)

windower.register_event('job change', function()
    start(current_player())
end)

windower.register_event('prerender', function()
    frames = frames + 1
    if frames % 120 ~= 0 then return end
    local p = current_player()
    if p and p.name then start(p)
    elseif current_character then stop() end
end)

-- Some clients load addons after the load event fires; avoid requiring a reload.
start(current_player())
