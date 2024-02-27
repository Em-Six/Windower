_addon.name = 'Silmaril'
_addon.author = 'Mirdain'
_addon.version = '3.4 Beta'
_addon.description = 'A multi-boxer tool'
_addon.commands = {'silmaril','sm'}

os.setlocale ("en")

extdata = require 'extdata'
packets = require 'packets'
res = require 'resources'
texts = require 'texts'

require 'tables'
require 'strings'
require 'coroutine'
require 'pack'

require 'lib./Abilities' --Gets information about the player abilities
require 'lib./Buffs' --Used to process incoming buff packets for other party members
require 'lib./Burst' --Selects and returns the spell to burst
require 'lib./Commands' --Handles addon commands
require 'lib./Connection' --Send and Receive information
require 'lib./Engine' -- Core of the program is ran from this
require 'lib./Display' --Send and Receive information
require 'lib./Helpers' --Common libraries
require 'lib./Input' --Receive commands to execute
require 'lib./Inventory' --Build the inventory information
require 'lib./IPC' --Handles any IPC messages that are being sent
require 'lib./Mirror' -- Allows all members to mirror the main players actions
require 'lib./Moving' --Controls moving of charater
require 'lib./Packets' --Handles packet messages
require 'lib./Party' --Gets information about the current party and alliance
require 'lib./Player' --Gets information about the player
require 'lib./Skillchain' --Monitors action packets to build skillchains with
require 'lib./Spells' --Gets information about the player spells
require 'lib./Sync' --Gets information about ffxi and sends to the Silmaril
require 'lib./Update' --Sets pace and updates globals form windower
require 'lib./Weaponskills' --Gets information about weaponskills
require 'lib./World' --Gets information about the world
require 'lib./Protection' -- Credit goes to witnessprotection - 'Lili'

--Commands recieved and sent to addon
windower.register_event('addon command', function(input, ...)
    local args = L{...}
    commands(input,args)
end)

-- Used to track incoming information
windower.register_event('incoming chunk', function (id, data, modified, injected, blocked)
    
    -- process the packets via Packets.lua
    message_in(id, data)

    -- block the menu if you are injecting
    if get_injecting() then
        if id == 0x032 then 
            log("Blocking on the 0x032 Packet [Type 1]")
            return true
        elseif id == 0x033 then 
            log("Blocking on the 0x033 Packet [String]")
            return true
        elseif id == 0x034 then 
            log("Blocking on the 0x034 Packet [Type 2]")
            return true
        end
    end

    return protection_in(id, modified)
end)

-- Used to track outgoing information
windower.register_event('outgoing chunk', function (id, data, modified, injected, blocked)

    -- process the packets via Packets.lua
    message_out(id, data)

    -- Used with automatic dialogs like warps/doors
    if get_block_release() and id == 0x05B then
        local packet = packets.parse('incoming', data)
        set_block_release(false)
        log('Calling npc_inject from the blocked outoing 0x05B')
        set_injecting(true)
        set_menu_id(packet['Menu ID'])
        npc_inject()
        return true
    end

    -- Process Tells via Protection.lua
    return protection_out(id, modified)

end)

--IPC messaging between characters for fast data transfer
windower.register_event('ipc message', function(msg)
    IPC_Action(msg)
end)

windower.register_event('load', function()
    connect() -- Start process of connecting via the Connection.lua
end)

windower.register_event('logout', function()
    send_packet(player.name..";reset")
    set_connected(false)
    log("logging out")
end)

windower.register_event('job change', function()
    coroutine.sleep(5)
    get_player_info()
    get_player_spells()
    load_command("")
end)

windower.register_event('unload', function()
    local p = windower.ffxi.get_player()
    send_packet(p.name..";reset")
    set_connected(false)
    log("unloaded")
end)