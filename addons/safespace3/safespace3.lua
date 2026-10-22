_addon.name = 'Safe Space'
_addon.version = '0.1.4'
_addon.author = 'Kastra (Lili - original code)'

require('logger')
local packets = require("packets")

-- Characters listed here remain visible even when they are NOT in your party.
-- Remove the -- from an example line and replace the name with a real character.
-- Names are matched case-insensitively. Reload the addon after editing.
local always_visible_names = {
     'Sensarity',
     'Arayala',
     'Katye',
     'Merako',
     'Ysara',
     'Luicia',
}

local always_visible_lookup = {}
for _, name in ipairs(always_visible_names) do
    if type(name) == 'string' and name ~= '' then
        always_visible_lookup[name:lower()] = true
    end
end

-- Remember character IDs so movement updates that omit names still work.
local whitelisted_character_ids = {}

local so = {
    player = false,
    zone = false,
}

-- Manually created collection of things to block.
-- "r" is the radius within which players outside your party and whitelist are hidden
local oboro   = {x = -180.00, y =   86.00, z =   11.00, r =  5, zone = 246}
local odyssey = {x =    0.60, y =  120.00, z =    8.00, r = 10, zone = 247}
local ruspix = {x =    -36.00, y =  0.00, z =    0.00, r = 10, zone = 281}
local sortie = {x =    -250.00, y =  360.00, z =    3.00, r = 5, zone = 267}
local ambu    = {x =  -27.10, y =   52.56, z =  -16.00, r =  8, zone = 249}
local oseem   = {x =   13.89, y =   24.25, z =    0.24, r =  5, zone = 252}
local paparoon   = {x =   0.30, y =   7.50, z =    0.00, r =  5, zone = 53}
local dragonA = {x =   -1.47, y =   39.04, z =    0.00, r = 30, zone = 288} -- Zi'tah dragon
local dragonB = {x =   -0.17, y = -210.26, z =  -43.60, r = 30, zone = 289} -- Ru'aun dragon
local dragonC = {x =  623.53, y = -934.87, z = -371.58, r = 30, zone = 291} -- Reisenjima dragon

-- List of those things to block. Used to automatically detech which one to block based on player current zone.
local things = {}
things[246] = oboro
things[247] = odyssey
things[281] = ruspix
things[267] = sortie
things[249] = ambu
things[252] = oseem
things[53] = paparoon
things[288] = dragonA
things[289] = dragonB
things[291] = dragonC

windower.register_event('load','login',function()
    so.player = windower.ffxi.get_player()
    so.zone = windower.ffxi.get_info().zone

    thing = things[so.zone] or oboro  -- When the add-on is loaded, thing == oboro by default
end)

function thing_is_near(t)
    local t = t or windower.ffxi.get_mob_by_target('me')
    if t.x then t.X = t.x t.Y = t.y end

    local dist = math.sqrt((thing.x - t.X)^2 + (thing.y - t.Y)^2)
    return thing.r > dist and dist
end


windower.register_event('zone change',function(id)
    -- If zoning, change the thing to block based on which zone
    -- Keeps old value if zoning into an area without something to block.
    so.zone = id
    whitelisted_character_ids = {}
    thing = things[so.zone] or thing
    -- print(thing.zone)
end)

windower.register_event('unload','logout', function()
    so.player = false
    so.zone = false
    whitelisted_character_ids = {}
end)

-- Keep the current party visible. Check live party data instead of caching it
-- on load, because members can join or leave without reloading the addon.
local function is_party_member(packet)
    local party = windower.ffxi.get_party()
    if not party then
        return false
    end

    -- The first PC update for a character can arrive before Windower has
    -- populated member.mob. Use the packet's character name as a fallback.
    local character_name = packet['Character Name']

    for i = 0, 5 do
        local member = party['p' .. i]
        if member then
            if member.mob and member.mob.id == packet.Player then
                return true
            end

            -- Some party sources also expose the member's server-side ID.
            if member.id and member.id == packet.Player then
                return true
            end

            if type(character_name) == 'string' and character_name ~= ''
                and member.name == character_name then
                return true
            end
        end
    end

    return false
end

-- Match a whitelisted character by name, then remember their server-side ID.
-- The name is not necessarily present on every 0x00D packet.
local function is_whitelisted(packet)
    local character_name = packet['Character Name']

    if type(character_name) ~= 'string' or character_name == '' then
        local mob = windower.ffxi.get_mob_by_id(packet.Player)
        character_name = mob and mob.name or nil
    end

    if type(character_name) == 'string' and character_name ~= '' then
        -- Packet strings can contain a trailing NUL terminator.
        character_name = character_name:match('^[^%z]+')
        whitelisted_character_ids[packet.Player] =
            character_name and always_visible_lookup[character_name:lower()] or nil
    end

    local visible = whitelisted_character_ids[packet.Player] == true
    if packet.Despawn then
        whitelisted_character_ids[packet.Player] = nil
    end

    return visible
end

windower.register_event('incoming chunk', function (id, org, mod, inj)
    if so.zone ~= thing.zone or not so.player or inj then
        return
    end

    if id == 0x00D and string.sub(org, 5,8):unpack("I") ~= so.player.id then

        local p = packets.parse('incoming', org)

        -- Evaluate whitelist on every PC update to remember names before a
        -- character enters a crowded area. Party members remain exempt too.
        local whitelisted = is_whitelisted(p)
        if thing_is_near(p) and not is_party_member(p) and not whitelisted then
           p.Despawn = true
           return packets.build(p)
        end
    end
end)
