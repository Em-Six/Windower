local NilCommand = require('command/nil')
local OfferCommand = require('command/offer')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local SequentialTradeCommand = NilCommand:NilCommand()
SequentialTradeCommand.__index = SequentialTradeCommand

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
function SequentialTradeCommand:SequentialTradeCommand(target_id, item_resource, total_count)
    local o = NilCommand:NilCommand()
    setmetatable(o, self)
    o._target_id = target_id
    o._item_resource = item_resource
    o._total_count = total_count
    o._type = 'SequentialTradeCommand'
    o._current_command = nil
    o._remaining_count = total_count
    o._stack_size = tonumber(item_resource.stack) and tonumber(item_resource.stack) or 1
    o._max_per_trade = CalculateMaxTradeable(item_resource, o._stack_size)
    o._waiting_for_completion = false
    o._delay_timer = nil
    o._all_trades_complete = false
    return o
end

--------------------------------------------------------------------------------
function SequentialTradeCommand:StartNextTrade()
    -- Check if we're done
    if self._remaining_count <= 0 then
        log('All items traded')
        self._all_trades_complete = true
        self._on_success()
        return
    end
    
    -- Calculate how many to trade in this batch
    local count_to_trade = math.min(self._remaining_count, self._max_per_trade)
    
    -- Create items array for this trade
    local items = { { item = self._item_resource, count = count_to_trade } }
    
    -- Create an OfferCommand for this batch
    self._current_command = OfferCommand:OfferCommand(self._target_id, items)
    self._waiting_for_completion = true
    
    -- Set callbacks
    self._current_command:SetSuccessCallback(function()
        -- Call parent success callback to log "Accepted" for this trade
        self._on_success()
        self:OnTradeCompleted()
    end)
    self._current_command:SetFailureCallback(function()
        self:OnTradeFailed()
    end)
    
    log('Trading ' .. count_to_trade .. ' of ' .. self._item_resource.en .. ' (' .. self._remaining_count .. ' remaining)')
    self._current_command()
end

--------------------------------------------------------------------------------
function SequentialTradeCommand:OnTradeCompleted()
    if not self._waiting_for_completion then
        return
    end
    
    self._waiting_for_completion = false
    self._current_command = nil
    
    -- Update remaining count
    local count_traded = math.min(self._remaining_count, self._max_per_trade)
    self._remaining_count = self._remaining_count - count_traded
    
    -- Check if we're done before setting delay timer
    if self._remaining_count <= 0 then
        log('All items traded')
        self._all_trades_complete = true
        -- Call _on_success() one more time so the handler can reset the command
        -- This will log "Accepted" again, but we need it to trigger the reset logic
        self._on_success()
        return
    end
    
    -- Wait before next trade (using configured timeout)
    local timeout = settings.config.timeout or 2.0
    self._delay_timer = os.clock()
    log('Waiting ' .. timeout .. ' seconds before next trade...')
end

--------------------------------------------------------------------------------
function SequentialTradeCommand:OnTradeFailed()
    if not self._waiting_for_completion then
        return
    end
    
    self._waiting_for_completion = false
    self._current_command = nil
    log('Trade failed, stopping sequential trades')
    self._on_failure()
end

--------------------------------------------------------------------------------
function SequentialTradeCommand:OnIncomingData(id, pkt)
    -- Check if we need to start the next trade after delay
    if self._delay_timer and not self._waiting_for_completion and self._remaining_count > 0 then
        local timeout = settings.config.timeout or 2.0
        local elapsed = os.clock() - self._delay_timer
        if elapsed >= timeout then
            self._delay_timer = nil
            self:StartNextTrade()
        end
    end
    
    if self._current_command then
        return self._current_command:OnIncomingData(id, pkt)
    end
    return false
end

--------------------------------------------------------------------------------
function SequentialTradeCommand:OnOutgoingData(id, pkt)
    -- Check if we need to start the next trade after delay
    if self._delay_timer and not self._waiting_for_completion and self._remaining_count > 0 then
        local timeout = settings.config.timeout or 2.0
        local elapsed = os.clock() - self._delay_timer
        if elapsed >= timeout then
            self._delay_timer = nil
            self:StartNextTrade()
        end
    end
    
    if self._current_command then
        return self._current_command:OnOutgoingData(id, pkt)
    end
    return false
end

--------------------------------------------------------------------------------
function SequentialTradeCommand:__call()
    -- Start the first trade
    self:StartNextTrade()
end


return SequentialTradeCommand

