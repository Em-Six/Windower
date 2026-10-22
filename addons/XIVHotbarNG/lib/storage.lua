-- Persists each server/character separately. Uses only Lua standard IO.
local storage = {}

local function encode(value, level)
    level = level or 0
    if level > 16 then error('Nested save data too deep') end
    local typ = type(value)
    if typ == 'string' then return string.format('%q', value) end
    if typ == 'number' then
        if value ~= value or value == math.huge or value == -math.huge then return '0' end
        return tostring(value)
    end
    if typ == 'boolean' then return tostring(value) end
    if typ ~= 'table' then return 'nil' end
    local parts = {'{\n'}
    local pad = string.rep(' ', (level + 1) * 2)
    local keys = {}
    for k in pairs(value) do
        if type(k) == 'number' or type(k) == 'string' then keys[#keys + 1] = k end
    end
    table.sort(keys, function(a, b)
        if type(a) == type(b) then return a < b end
        return type(a) < type(b)
    end)
    for _, key in ipairs(keys) do
        parts[#parts + 1] = pad .. '[' .. encode(key, level + 1) .. '] = '
            .. encode(value[key], level + 1) .. ',\n'
    end
    parts[#parts + 1] = string.rep(' ', level * 2) .. '}'
    return table.concat(parts)
end

function storage.filename(addon_path, server, character)
    local function safe(name)
        return tostring(name or 'unknown'):gsub('[^%w_%-]', '_'):sub(1, 48)
    end
    local root = addon_path:gsub('[\\/]+$', '')
    return root .. '/data/' .. safe(server) .. '_' .. safe(character) .. '.lua'
end

function storage.load(path)
    local loader = loadfile(path)
    if not loader then return nil end
    local ok, result = pcall(loader)
    if ok and type(result) == 'table' then return result end
    return nil
end

function storage.save(path, value)
    local encoded = 'return ' .. encode(value) .. '\n'
    -- Write a staging copy before replacing data; never truncate original if staging fails.
    local temp = path .. '.tmp'
    local stream, err = io.open(temp, 'wb')
    if not stream then return false, err end
    local ok, write_error = stream:write(encoded)
    if not ok then stream:close() return false, write_error end
    stream:close()
    -- Windows os.rename will not reliably replace an existing file; preserve a backup.
    local backup = path .. '.bak'
    os.remove(backup)
    local original = io.open(path, 'rb')
    if original then
        original:close()
        local renamed, rename_err = os.rename(path, backup)
        if not renamed then return false, rename_err end
    end
    local renamed, rename_err = os.rename(temp, path)
    if not renamed then
        os.rename(backup, path)
        return false, rename_err
    end
    return true
end

return storage
