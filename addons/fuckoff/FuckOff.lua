_addon.name = 'FuckOff'
_addon.version = '0.10'
_addon.author = 'Chiaia (Asura)'
_addon.commands = {'fuckoff','fo'} --Won't do anything atm.

packets = require('packets')

local blackListedUsers = T{'Chrisanthe','Ochaking','Sonsuken','Bushin','Xiaobx','Zirow','Cpttn','Charmghost','Ouzo','Goldmansachs','Moggyy'} -- Want to block all messages from X user then added their name(s) here.

-- I could do a general digit check on JP instead of set 500/2100 values but atm I feel it's not needed. Will see if they change thier tactics.
-- If you want to learn more about "Magical Characters" or Patterns in Lua: <a href="https://riptutorial.com/lua/example/20315/lua-pattern-matching" rel="nofollow">https://riptutorial.com/lua/example/20315/lua-pattern-matching</a>
local blackListedWords = T{string.char(0x81,0x99),string.char(0x81,0x9A),'UC119','Escha Beads 10k','Buy?','Mercenary','T1-T4 V0-25','Voltsurge Torque','Weapon Shop','Ngai Kalunga Mboze','NM T1 V25 T2','Wanted UNM135 Escha','T1 T2-V20','Shulmanu Collar','Weapon 3 zone', '3zone', 'Bumba, Xevioso, Arebati','T1 T2 V20','Herculean Valorous','t3 Xecioso Ngai v20','V20 Unlock','King Ranp','Bibiki Bay','10M 20-30','T3 Kalunga-V20','ReisenjimaFull or HelmT4 x7','3zoneClear','M/run','Unlock Relic','Unlock-Aug','Fermion Sword','WoC Kirin','T1 T2-V20','VD/Lilith VD','HTMB VD','9999','1\-55','500JP','500p','CP500','T1T2T3','local gamers ffxi','2100','3zones Full','1\-60','50\-99','60\-99','Ballista','T1234'} -- First two are '☆' and '★' symbols.

windower.register_event('incoming chunk', function(id,data)
    if id == 0x017 then -- 0x017 Is incoming chat.
        local chat = packets.parse('incoming', data)
        local cleaned = windower.convert_auto_trans(chat['Message']):lower()
        -- print(cleaned)
        if blackListedUsers:contains(chat['Sender Name']) then -- Blocks any message from X user in any chat mode.
            return true
        -- elseif (chat['Mode'] == 3 or chat['Mode'] == 1 or chat['Mode'] == 26) then -- RMT checks in tell, shouts, and yells. Years ago they use to use tells to be more stealthy about gil selling.
        elseif (chat['Mode'] == 1 or chat['Mode'] == 26) then -- RMT checks in tell, shouts, and yells. Years ago they use to use tells to be more stealthy about gil selling.
            for k,v in ipairs(blackListedWords) do
                if cleaned:match(v:lower()) then
                    return true
                end
            end
        end
    end
    if id == 0x029 then
      local packet = packets.parse('incoming', data)
      --print(packet['Message'])
    end
end)
