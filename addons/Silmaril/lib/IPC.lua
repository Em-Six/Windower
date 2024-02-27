function IPC_Action(msg)
    local args = msg:split(' ')
    local command = args:remove(1)
    if command == 'zone' then
        IPC_zone(args)
    elseif command == 'update' then
        IPC_update(args)
    elseif command == 'message' then
        IPC_message(args)
    elseif command then
        IPC_command(command, args)
    end
end

function IPC_zone(args)
    log('received IPC message of zone')
    -- Have the player go to zone line if following via Moving.lua
    zone_check(tonumber(args[1]),tonumber(args[2]),tonumber(args[3]),tonumber(args[4]),tonumber(args[5]),tonumber(args[6]),tonumber(args[7]))
end

function IPC_update(args)
    -- Update the player information via Party.lua
    local character = { 
        id = tonumber(args[1]), 
        name = args[2], 
        zone = tonumber(args[3]), 
        x = tonumber(args[4]), 
        y = tonumber(args[5]), 
        z = tonumber(args[6]), 
        heading = tonumber(args[7]), 
        status = tonumber(args[8]), 
        target_index = tonumber(args[9])}
    set_party_location(character)
end

function IPC_message(args)
    -- Send a message to game console
    local message = ""
	for index, item in ipairs(args) do
        if index ~= 0 then
            message = message..item..' '
        end
    end
    message = message:sub(1, #message - 1)
    command = 'input /echo '..message..''
    windower.send_command(command)
    log('Message recieved ['..message.."]")
end

function IPC_command(command, args)
    -- Command to execute from another player
    log("IPC received: ["..command.."]")
    commands(command, args)
end