_addon.name = 'hidepc'
_addon.version = '0.1.2'
_addon.author = 'Kastra & Memento UwU'

require('logger')
local packets = require("packets")

local so = {
    player = false,
    partymembers = {},
    zone = false,
}

local blocked = {}

local thing1 = {x = -180, y = 86, z = 11, r = 10, zone = 246} -- Oboro (Port Jeuno REMA Augments)
local thing2 = {x = -28.101, y = 52.134, z = -16.000, r = 10, zone = 47} -- Gorpa-Masorpa (Mhaura Ambuscade Director)
local thing3 = {x = -1, y = 120, z = 8, r = 10, zone = 247} -- Rabao Verdical Conflux (Odyssey)
local thing4 = {x = -180, y = 86, z = 11, r = 10, zone = 246}
local thing5 = {x = -180, y = 86, z = 11, r = 10, zone = 246}

function thing_is_near(t,thing)
    local t = t or windower.ffxi.get_mob_by_target('me')
    if t.x then t.X = t.x t.Y = t.y end
    
    local dist = math.sqrt((thing.x - t.X)^2 + (thing.y - t.Y)^2)
    return thing.r > dist and dist
end

windower.register_event('load','login',function()
    so.player = windower.ffxi.get_player()
    so.zone = windower.ffxi.get_info().zone
    so.partymembers = windower.ffxi.get_party()
end)

windower.register_event('zone change',function(id)
    so.zone = id
end)

windower.register_event('unload','logout', function()
    so.player = false
    so.zone = false
end)

windower.register_event('incoming chunk', function (id, org, mod, inj)
    if so.zone ~= thing1.zone or so.zone ~= thing2.zone or so.zone ~= thing3.zone or so.zone ~= thing4.zone or so.zone ~= thing5.zone or not so.player or inj then -- Port Jeuno
        return
    end
    
    if id == 0x00D and string.sub(org, 5,8):unpack("I") ~= so.player.id then
        
        local p = packets.parse('incoming', org)
       
        if thing_is_near(p,thing1) then -- oboro.r > math.sqrt((oboro.x - p.X)^2 + (oboro.y - p.Y)^2) then
           p.Despawn = true
           return packets.build(p) 
        end
        if thing_is_near(p,thing2) then -- oboro.r > math.sqrt((oboro.x - p.X)^2 + (oboro.y - p.Y)^2) then
           p.Despawn = true
           return packets.build(p) 
        end
        if thing_is_near(p,thing3) then -- oboro.r > math.sqrt((oboro.x - p.X)^2 + (oboro.y - p.Y)^2) then
           p.Despawn = true
           return packets.build(p) 
        end
        if thing_is_near(p,thing4) then -- oboro.r > math.sqrt((oboro.x - p.X)^2 + (oboro.y - p.Y)^2) then
           p.Despawn = true
           return packets.build(p) 
        end
        if thing_is_near(p,thing5) then -- oboro.r > math.sqrt((oboro.x - p.X)^2 + (oboro.y - p.Y)^2) then
           p.Despawn = true
           return packets.build(p) 
        end
        
    end
end)