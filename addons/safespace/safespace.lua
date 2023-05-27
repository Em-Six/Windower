_addon.name = 'Safe Space'
_addon.version = '0.1.2'
_addon.author = 'Kastra (Lili - original code)'

require('logger')
local packets = require("packets")

local so = {
    player = false,
    partymembers = {},
    zone = false,
}

local blocked = {}


-- Manually created collection of things to block.
-- "r" is the radius within which NO PLAYER CHARACTERS WILL APPEAR
local oboro   = {x = -180.00, y =   86.00, z =   11.00, r =  5, zone = 246}
local odyssey = {x =    0.60, y =  120.00, z =    8.00, r = 10, zone = 247}
local ruspix = {x =    -36.00, y =  0.00, z =    0.00, r = 10, zone = 281}
local sortie = {x =    -250.00, y =  360.00, z =    3.00, r = 5, zone = 267}
local ambu    = {x =  -27.10, y =   52.56, z =  -16.00, r =  8, zone = 249}
local oseem   = {x =   13.89, y =   24.25, z =    0.24, r =  5, zone = 252}
local paparoon   = {x =   0.30, y =   7.50, z =    0.00, r =  10, zone = 53}
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
    so.partymembers = windower.ffxi.get_party()

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
    thing = things[so.zone] or thing
    -- print(thing.zone)
end)

windower.register_event('unload','logout', function()
    so.player = false
    so.zone = false
end)

windower.register_event('incoming chunk', function (id, org, mod, inj)
    if so.zone ~= thing.zone or not so.player or inj then
        return
    end

    if id == 0x00D and string.sub(org, 5,8):unpack("I") ~= so.player.id then

        local p = packets.parse('incoming', org)

        if thing_is_near(p) then -- oboro.r > math.sqrt((oboro.x - p.X)^2 + (oboro.y - p.Y)^2) then
           p.Despawn = true
           return packets.build(p)
        end
    end
end)
