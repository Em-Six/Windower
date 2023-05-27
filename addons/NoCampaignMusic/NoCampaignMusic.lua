--[[
Copyright © 2020, Dean James (Xurion of Bismarck)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of No Campaign Music nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 'AS IS' AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Dean James (Xurion of Bismarck) BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'No Campaign Music'
_addon.author = 'Dean James (Xurion of Bismarck)'
_addon.version = '2.0.1'
_addon.commands = {'nocampaignmusic', 'ncm'}

packets = require('packets')
config = require('config')

defaults = {
    Notifications = false,
}

settings = config.load(defaults)

campaign_id = 247
solo_id = 101
party_id = 215
solo_dungeon_id = 115
party_dungeon_id = 216

zone_music_map = {}
zone_music_map[80] = { 254, 254, solo_id, party_id } --Southern San d'Oria [S]
zone_music_map[81] = { 251, 251, solo_id, party_id } --East Ronfaure [S]
zone_music_map[82] = { 0, 0, solo_id, party_id } --Jugner Forest [S]
zone_music_map[83] = { 0, 0, solo_id, party_id } --Vunkerl Inlet [S]
zone_music_map[84] = { 252, 252, solo_id, party_id } --Batallia Downs [S]
zone_music_map[85] = { 44, 44, solo_dungeon_id, party_dungeon_id } --La Vaule [S]
zone_music_map[87] = { 180, 180, solo_id, party_id } --Bastok Markets [S]
zone_music_map[88] = { 253, 253, solo_id, party_id } --North Gustaberg [S]
zone_music_map[89] = { 0, 0, solo_id, party_id } --Grauberg [S]
zone_music_map[90] = { 0, 0, solo_id, party_id } --Pashhow Marshlands [S]
zone_music_map[91] = { 252, 252, solo_id, party_id } --Rolanberry Fields [S]
zone_music_map[92] = { 44, 44, solo_dungeon_id, party_dungeon_id } --Beadeaux [S]
zone_music_map[94] = { 182, 182, solo_id, party_id } --Windurst Waters [S]
zone_music_map[95] = { 141, 141, solo_id, party_id } --West Sarutabaruta [S]
zone_music_map[96] = { 0, 0, solo_id, party_id } --Fort Karugo-Narugo [S]
zone_music_map[97] = { 0, 0, solo_id, party_id } --Meriphataud Mountains [S]
zone_music_map[98] = { 252, 252, solo_id, party_id } --Sauromugue Champaign [S]
zone_music_map[99] = { 44, 44, solo_dungeon_id, party_dungeon_id } --Castle Oztroja [S]
zone_music_map[136] = { 0, 0, solo_id, party_id } --Beaucedine Glacier [S]
zone_music_map[137] = { 42, 42, solo_id, party_id } --Xarcabard [S]
zone_music_map[138] = { 43, 43, solo_dungeon_id, party_dungeon_id } --Castle Zvahl Baileys [S]
zone_music_map[155] = { 43, 43, solo_dungeon_id, party_dungeon_id } --Castle Zvahl Keep [S]
zone_music_map[164] = { 0, 0, solo_dungeon_id, party_dungeon_id } --Garlaige Citadel [S]
zone_music_map[171] = { 0, 0, solo_dungeon_id, party_dungeon_id } --Crawlers' Nest [S]
zone_music_map[175] = { 0, 0, solo_dungeon_id, party_dungeon_id } --The Eldieme Necropolis [S]

windower.register_event('incoming chunk', function(id, data)
    if id ~= 0x00A and id ~= 0x05F then return end

    local parsed = packets.parse('incoming', data)
    local zone_music = zone_music_map[parsed['Zone'] or windower.ffxi.get_info().zone]

    if not zone_music then return end

    if id == 0x00A then  --Zone update (zoned in)
        if parsed['Day Music'] == campaign_id and zone_music then
            parsed['Day Music'] = zone_music[1]
            parsed['Night Music'] = zone_music[2]
            parsed['Solo Combat Music'] = zone_music[3]
            parsed['Party Combat Music'] = zone_music[4]

            return packets.build(parsed)
        end
    else --Music update (campaign possibly started/finished)
        local info = windower.ffxi.get_info()
        if parsed['Song ID'] == campaign_id then

            if settings.Notifications and parsed['BGM Type'] == 0 then --only log to the chat once
                windower.add_to_chat(8, 'Prevented campaign music.')
            end

            parsed['Song ID'] = zone_music[parsed['BGM Type'] + 1]
            return packets.build(parsed)
        end
    end
end)

commands = {}

commands.notify = function()
    settings.Notifications = not settings.Notifications
    settings:save()
    windower.add_to_chat(8, 'Campaign notifications: ' .. tostring(settings.Notifications))
end

commands.help = function()
    windower.add_to_chat(8, 'No Campaign Music:')
    windower.add_to_chat(8, '  //ncm notify - toggles campaign notifications (default false)')
    windower.add_to_chat(8, '  //ncm help - shows this help')
end

windower.register_event('addon command', function(command)
    command = command and command:lower() or 'help'

    if commands[command] then
        commands[command]()
    else
        commands.help()
    end
end)
