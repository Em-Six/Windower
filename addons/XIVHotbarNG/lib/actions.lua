-- FFXI command handling; no GearSwap or job automation is required.
local actions = {}

function actions.label(command)
    if type(command) ~= 'string' then return '' end
    local quoted = command:match('^/%S+%s+"([^"]+)"')
    if quoted then return quoted:sub(1, 28) end
    local unquoted = command:match('^/%S+%s+(%S+)')
    if unquoted then return unquoted:gsub('<.*', ''):sub(1, 28) end
    return (command:match('^//?([%w_]+)') or command):sub(1, 28)
end

function actions.kind(command)
    local verb = (command or ''):match('^/(%w+)')
    if not verb then return 'command' end
    verb = verb:lower()
    if verb == 'ma' or verb == 'magic' or verb == 'song' or verb == 'nin' then return 'magic' end
    if verb == 'ja' or verb == 'pet' then return 'ability' end
    if verb == 'ws' then return 'weapon' end
    if verb == 'item' then return 'item' end
    if verb == 'equip' then return 'equip' end
    return 'command'
end

function actions.execute(record, windower_api)
    if type(record) ~= 'table' then return false end
    local command = record.command
    if type(command) ~= 'string' or not command:match('^/') then return false end
    -- Mirrors the original XIVHotbar's windower.chat.input action dispatch.
    windower_api.chat.input(command)
    return true
end

return actions
