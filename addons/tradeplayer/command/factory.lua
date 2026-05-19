local NilCommand = require('command/nil')
local OfferCommand = require('command/offer')
local PartyCommand = require('command/party')
local SequentialTradeCommand = require('command/sequential')
local EntityFactory = require('model/entity/factory')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local CommandFactory = {}

--------------------------------------------------------------------------------
local function GetItemResource(name)
    for key, value in pairs(resources.items) do
        if value.en:lower() == name:lower() then
            return value
        end
    end
    return nil
end

--------------------------------------------------------------------------------
local function CalculateMaxTradeable(item_resource, stack_size)
    -- Gil (id 65535) has no slot requirements, can trade up to 999,999,999
    if item_resource and tonumber(item_resource.id) == 65535 then
        return 999999999
    end
    
    -- Max 8 slots per trade
    -- If stack_size is 1 (non-stackable), max is 8
    -- Otherwise, max is 8 * stack_size
    if not stack_size or stack_size == 1 then
        return 8
    end
    return 8 * stack_size
end

--------------------------------------------------------------------------------
local function ResolveCount(count, item_resource)
    -- Check if count is the 'all' keyword (case-insensitive)
    if tostring(count):lower() == 'all' then
        -- Get the player entity and inventory
        local player = EntityFactory.CreatePlayer()
        if player:Type() == 'NilEntity' then
            return nil, 'Unable to get player inventory'
        end
        
        -- Update the inventory to get current item counts
        player:Bag():Update()
        
        -- Get the count of the item in inventory
        local item_count = player:Bag():ItemCount(tonumber(item_resource.id))
        return item_count
    end
    
    -- If not 'all', return the count as-is (will be validated later)
    return count
end

--------------------------------------------------------------------------------
function CommandFactory.CreateCommand(...)
    local args = {...}
    local player = windower.ffxi.get_player()
    if not player then
        log('Not logged in')
        return NilCommand:NilCommand()
    end

    -- Check if the last argument is "party"
    local last_arg = args[#args]
    local is_party_command = last_arg and tostring(last_arg):lower() == 'party'
    
    if is_party_command then
        -- Remove "party" from args
        table.remove(args, #args)
        
        -- Parse items (count/item pairs)
        local items = {}
        while #args > 0 do
            local count = table.remove(args, 1)
            local item = table.remove(args, 1)
            local converted = windower.convert_auto_trans(item)
            local res = GetItemResource(converted and converted or item)

            if item and not res then
                log('Unable to parse items')
                return NilCommand:NilCommand()
            end

            -- Check if 'all' keyword is used with party command (not allowed)
            if res and tostring(count):lower() == 'all' then
                log('Cannot use "all" keyword with party commands. All items would be traded to the first person.')
                return NilCommand:NilCommand()
            end

            -- Resolve 'all' keyword to actual count (shouldn't reach here for party, but keeping for safety)
            if res then
                local resolved_count, error_msg = ResolveCount(count, res)
                if resolved_count == nil then
                    log(error_msg or 'Unable to resolve count')
                    return NilCommand:NilCommand()
                end
                count = resolved_count
            end

            if count and not tonumber(count) then
                log('Unable to parse items')
                return NilCommand:NilCommand()
            end

            table.insert(items, { item = res, count = count })
        end

        return PartyCommand:PartyCommand(items)
    end

    local target = nil
    if #args % 2 == 0 then
        local mob = windower.ffxi.get_mob_by_target('t')
        target = mob
    else
        local mob = windower.ffxi.get_mob_by_name((tostring(table.remove(args, #args)):gsub("^%l", string.upper)))
        target = mob
    end

    if not target or target.is_npc then
        log('Could not determine trade partner')
        return NilCommand:NilCommand()
    end

    local items = {}
    while #args > 0 do
        local count = table.remove(args, 1)
        local item = table.remove(args, 1)
        local converted = windower.convert_auto_trans(item)
        local res = GetItemResource(converted and converted or item)

        if item and not res then
            log('Unable to parse items')
            return NilCommand:NilCommand()
        end

        -- Resolve 'all' keyword to actual count
        if res then
            local resolved_count, error_msg = ResolveCount(count, res)
            if resolved_count == nil then
                log(error_msg or 'Unable to resolve count')
                return NilCommand:NilCommand()
            end
            count = resolved_count
        end

        if count and not tonumber(count) then
            log('Unable to parse items')
            return NilCommand:NilCommand()
        end

        table.insert(items, { item = res, count = count })
    end

    -- Check if we have a single item that exceeds the trade limit
    -- If so, use SequentialTradeCommand
    if #items == 1 then
        local item_data = items[1]
        local stack_size = tonumber(item_data.item.stack) and tonumber(item_data.item.stack) or 1
        local max_tradeable = CalculateMaxTradeable(item_data.item, stack_size)
        local item_count = tonumber(item_data.count)
        
        if item_count > max_tradeable then
            return SequentialTradeCommand:SequentialTradeCommand(target.id, item_data.item, item_count)
        end
    end

    return OfferCommand:OfferCommand(target.id, items)
end

return CommandFactory