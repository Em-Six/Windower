_addon.name = 'TradePlayer'
_addon.author = 'Tny5989'
--Updated to 0.2.1b by Skynet
--Added "party" target to trade to all party members
--Added "all" keyword to trade full count of desired item in inventory
_addon.version = '0.2.1b'
_addon.commands = {'tradeplayer', 'tp'}

--------------------------------------------------------------------------------
require('logger')
packets = require('util/packets')
settings = require('util/settings')
resources = require('resources')

local CommandFactory = require('command/factory')
local NilCommand = require('command/nil')

--------------------------------------------------------------------------------
local command = NilCommand:NilCommand()

--------------------------------------------------------------------------------
local function OnSuccess()
    if command:Type() == 'SequentialTradeCommand' then
        -- If all trades are complete, don't log "Accepted" again, just reset
        if command._all_trades_complete then
            command = NilCommand:NilCommand()
            return
        end
        -- Otherwise, log "Accepted" for this individual trade and keep going
        log('Accepted')
        return
    end
    
    log('Accepted')
    if command:Type() ~= 'PartyCommand' then
        command = NilCommand:NilCommand()
    elseif command._all_trades_complete then
        -- All party trades completed, reset the command
        command = NilCommand:NilCommand()
    end
end

--------------------------------------------------------------------------------
local function OnFailure()
    log('Rejected')
    if command:Type() ~= 'PartyCommand' then
        command = NilCommand:NilCommand()
    elseif command._all_trades_complete then
        -- All party trades completed, reset the command
        command = NilCommand:NilCommand()
    end
end

--------------------------------------------------------------------------------
local function OnLoad()
    settings.load()
end

--------------------------------------------------------------------------------
local function OnCommand(...)
    local args = {...}
    
    -- Handle timeout command
    if #args >= 2 and tostring(args[1]):lower() == 'timeout' then
        local timeout_value = tonumber(args[2])
        if timeout_value and timeout_value > 0 then
            settings.config.timeout = timeout_value
            settings.save()
            log('Timeout set to ' .. timeout_value .. ' seconds')
        else
            log('Invalid timeout value. Must be a positive number.')
        end
        return
    end
    
    if command:Type() == 'NilCommand' then
        command = CommandFactory.CreateCommand(...)
        command:SetSuccessCallback(OnSuccess)
        command:SetFailureCallback(OnFailure)
        command()
    else
        log('Already running a complex command')
    end
end

--------------------------------------------------------------------------------
local function OnIncomingData(id, _, pkt, b, i)
    if not packets.is_duplicate(id, pkt) then
        return command:OnIncomingData(id, pkt)
    else
        return false
    end
end

--------------------------------------------------------------------------------
local function OnOutgoingData(id, _, pkt, b, i)
    return command:OnOutgoingData(id, pkt)
end

--------------------------------------------------------------------------------
windower.register_event('load', OnLoad)
windower.register_event('addon command', OnCommand)
windower.register_event('incoming chunk', OnIncomingData)
windower.register_event('outgoing chunk', OnOutgoingData)
