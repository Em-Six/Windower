function log (msg)
    if get_debug_state() then
        if msg == nil then
            windower.add_to_chat(80,'---- Value is Nil ----')
        elseif type(msg) == "table" then
            for index, value in ipairs(msg) do
                windower.add_to_chat(80,'---- '..tostring(value)..' ----')
            end
        elseif type(msg) == "number" then
            windower.add_to_chat(80,'---- '..tostring(msg)..' ----')
        elseif type(msg) == "string" then
            windower.add_to_chat(80,'---- '..msg..' ----')
        elseif type(msg) == "boolean" then
            windower.add_to_chat(80,'---- '..tostring(msg)..' ----')
        else
            windower.add_to_chat(80,'---- Unknown Debug Message ----')
        end
    end
end

function info (msg)
    if get_info_state() then
        if msg == nil then
            windower.add_to_chat(7,'---- Value is Nil ----')
        elseif type(msg) == "table" then
            for index, value in ipairs(msg) do
                windower.add_to_chat(7,'---- '..tostring(value)..' ----')
            end
        elseif type(msg) == "number" then
            windower.add_to_chat(7,'---- '..tostring(msg)..' ----')
        elseif type(msg) == "string" then
            windower.add_to_chat(5,'---- '..msg..' ----')
        elseif type(msg) == "boolean" then
            windower.add_to_chat(7,'---- '..tostring(msg)..' ----')
        else
            windower.add_to_chat(7,'---- Unknown Info Message ----')
        end
    end
end

function echo (msg)
    if msg == nil then
        windower.add_to_chat(7,'---- Value is Nil ----')
    elseif type(msg) == "table" then
        for index, value in ipairs(msg) do
            command = 'input /echo '..value..''
            windower.send_command(command)
            windower.send_ipc_message('message '..value)
        end
    elseif type(msg) == "number" then  
        command = 'input /echo '..tostring(msg)..''
        windower.send_command(command)
        windower.send_ipc_message('message '..tostring(msg))
    elseif type(msg) == "string" then
        command = 'input /echo '..msg..''
        windower.send_command(command)
        windower.send_ipc_message('message '..msg)
    elseif type(msg) == "boolean" then
        command = 'input /echo '..tostring(msg)..''
        windower.send_command(command)
        windower.send_ipc_message('message '..tostring(msg))
    else
        windower.add_to_chat(7,'---- Unknown Echo Message ----')
    end
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- Use for procession targets with advanced tables
function targets_table(targets)
    local formattedString = ''
    for type, target in pairs(targets) do
        formattedString = formattedString..type..'$'
    end    
    formattedString = formattedString:sub(1, #formattedString - 1)
    return formattedString
end