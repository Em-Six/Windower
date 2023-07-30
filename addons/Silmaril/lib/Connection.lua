function connect()
    log("startup")
    initialize() -- via update.lua
    udp = assert(socket.udp())
    udp:settimeout(0)
    udp:setpeername(ip, port)
end

function request()
    local formattedString = player.name..";request_".._addon.version
    send_packet(formattedString)
    log(formattedString)
end

function disconnect()
    connected = false
    enabled = false
    autoload = true
end

function send_packet (msg)
    if msg and udp then
        assert(udp:send(msg))
    else
        log('Unable to send data')
    end
end

function receive_info()
    repeat
        data, msg = udp:receive()
        if data then
            --log(data)
            local message = data:split('_')
            if message[1] == player.name then
                if message[2] == "accepted" then
                    message = data:split('_')
                    windower.add_to_chat(1, ('\31\200[\31\05Silmaril Addon\31\200]\31\207 '..message[3]))
                    connected = true
                elseif message[2] == "sync" then
                    log('Sync Request')
                    sync_data() -- method called via Sync.lua
                elseif message[2] == "version" then
                    info('Version miss match!')
                    command = 'lua u silmaril'
                    windower.send_command(command)
                elseif message[2] == "reset" then
                    log('Reset Request')
                    disconnect()
                    connect()
                elseif message[2] == "on" then
                    enabled = true
                elseif message[2] == "off" then
                    enabled = false
                elseif message[2] == "input" then
                    input_message(message[3],message[4],message[5],message[6])
                elseif message[2] == "skillchain" then
                    skillchain(message[3],message[4],message[5],message[6])
                elseif message[2] == "skillchain2" then
                    skillchain2(message[3],message[4],message[5],message[6])
                elseif message[2] == "skillchain3" then
                    skillchain3(message[3],message[4],message[5],message[6])
                elseif message[2] == "skillchain4" then
                    skillchain4(message[3],message[4],message[5],message[6])
                elseif message[2] == "config" then
                    local commands = {}
                    for item in string.gmatch(message[3], "([^,]+)") do
                        table.insert(commands, item)
                    end
                    npc_mirror_state(tonumber(commands[1]))     -- Toggles Mode of mirroring
                    update_rate = tonumber(commands[2])         -- Changes the update rate
                    update_inventory = tonumber(commands[3])    -- Changes the update rate
                    update_sync = tonumber(commands[4]) * 60    -- Changes the update rate
                    update_movement = tonumber(commands[5])     -- Changes the update rate
                end
            elseif message[2] then
                log("Wrong Message Recieved ["..message[2]..']')
            end
		elseif msg ~= 'timeout' then 
			--log("Network error: "..tostring(msg))
		end
    until not data and connect
end