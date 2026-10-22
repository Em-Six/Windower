_addon.name = 'DomainFarm'
_addon.author = 'OpenAI'
_addon.version = '0.4.0-test'
_addon.commands = {'domainfarm', 'df'}

-- Retail Windower 4. Requires Superwarp, GearSwap, and Silmaril.
-- All characters running this addon share routes.tsv and receive IPC STOP/PAUSE.
-- TEST BUILD: Check one character before using all six. Routes are kept across upgrades.

local Z = {
    zitah     = {id=288, approach=126, key='qufim',     npc_route='zitah',     npc='Affi',     hp='Qufim Island'},
    ruaun     = {id=289, approach=25,  key='misareaux', npc_route='ruaun',     npc='Dremi',    hp='Misareaux Coast'},
    reisenjima= {id=291, approach=108, key='dem',       npc_route='reisenjima',npc='Shiftrix', hp=nil},
}
local order = {'zitah','ruaun','reisenjima'}
local route_zones = {
    qufim=126, zitah=288, misareaux=25, ruaun=289, dem=108, reisenjima=291
}
local arena = { -- Battlefield arrival positions; only used as an additional sanity check.
    [288]={x=-2,y=59.5}, [289]={x=0,y=-238}, [291]={x=640,y=-921}
}
local CFG = {
    tick=1, arrival_delay=5, waypoint_reach=2.25, final_reach=1.8, route_sample=2.0,
    route_start_max=35, route_stuck_seconds=14, movement_retry_max=3,
    teleport_retry_max=3, teleport_timeout=45, ring_timeout=65,
    domain_retry_seconds=22, domain_wait_limit=1500, -- 25 min waiting for NPC to open
    fight_timeout=75*60, -- long fallback to allow for Mireu
    fight_min_seconds=25, boss_absent_seconds=12,
    reward_delay=6, arena_jump=35, silmaril_start_delay=90,
    pass_line_width=3.0, -- how far off a recorded segment counts as passing its waypoint
}

-- Currency2 packet 0x118 contains the real Escha Beads total. Query it with
-- outgoing 0x115; report each character's value to the other Windower clients.
local packets = require('packets')
local texts = require('texts')
local BEADS = {
    request_interval=45, -- seconds between requests for currency2 data
    hello_interval=15,   -- IPC announcements; permits late-loading instances
    stale_after=180,     -- unknown rather than stale value if no refresh
    disconnect_after=90,
    hud_y=16,
    show=true,
}
local bead_peers = {} -- name -> {value, updated_at, last_seen}
local bead_hud
local last_beads_hello, next_beads_request, last_beads_hud_update = 0, 0, 0
local last_beads_hud_text, last_beads_hud_width = nil, nil

local path = windower.addon_path .. 'routes.tsv'
local routes = {}
local record = nil
local running, paused, target, phase = false, false, nil, 'IDLE'
local step = nil
local walk = nil
local movement_active, movement_heading = false, nil
local pending = nil
local started_fight, silmaril_sent = nil, false
local observed_boss, boss_last_seen = false, nil
local completion_at, completion_reason = nil, nil
local domain_wait_start = nil
local last_tick, ready_after = 0, 0
local last_zone = nil
local rings_done = false
local last_completed = nil
local last_failure = ''

local function now() return os.time() end
local function log(s) windower.add_to_chat(207, '[DomainFarm] ' .. tostring(s)) end
local function warn(s) windower.add_to_chat(167, '[DomainFarm] ' .. tostring(s)) end
local function send(cmd)
    log('> ' .. cmd)
    windower.send_command(cmd)
end
local function broadcast(s)
    windower.send_ipc_message('DOMAINFARM|' .. s)
end
local function zone()
    local info = windower.ffxi.get_info()
    return info and info.zone or nil
end
local function self_mob() return windower.ffxi.get_mob_by_target('me') end
local function char_name()
    local p = windower.ffxi.get_player()
    return p and p.name or 'Unknown'
end

local function valid_name(name)
    return type(name)=='string' and name~='Unknown' and #name>=2 and #name<=16
        and name:match('^%a+$') ~= nil
end

local function comma(value)
    local s=tostring(math.floor(value))
    return s:reverse():gsub('(%d%d%d)', '%1,'):reverse():gsub('^,','')
end

local function remember_beads(name, value, age)
    if not valid_name(name) then return end
    local t=now()
    age=math.max(0,math.min(999999,tonumber(age) or 0))
    local peer=bead_peers[name] or {}
    peer.last_seen=t
    if value~=nil and value>=0 and value<=65535 then
        -- Do not let an older delayed heartbeat overwrite a newer reading.
        local stamp=t-age
        if not peer.updated_at or stamp>=peer.updated_at then
            peer.value=value
            peer.updated_at=stamp
        end
    end
    bead_peers[name]=peer
end

local function say_beads()
    local name=char_name()
    if not valid_name(name) then return end
    local own=bead_peers[name]
    local value=(own and own.value and own.updated_at and now()-own.updated_at<=BEADS.stale_after)
        and tostring(own.value) or '-'
    local age=(own and own.updated_at) and math.max(0,now()-own.updated_at) or 999999
    broadcast('BEADS|'..name..'|'..value..'|'..age)
end

local function new_bead_hud()
    -- Center the complete text block in the actual UI width, even across
    -- differently sized game windows.
    bead_hud=texts.new('', {
        pos={x=0,y=BEADS.hud_y},
        text={size=11,font='Consolas',red=245,green=245,blue=245,alpha=255},
        bg={visible=true,red=0,green=0,blue=0,alpha=155},
        padding=7,
        flags={draggable=false,right=false,bottom=false},
    })
    bead_hud:stroke_width(1)
    bead_hud:stroke_color(0,0,0)
    bead_hud:show()
end

local function update_bead_hud(force)
    if not bead_hud then return end
    if not BEADS.show then
        bead_hud:hide()
        return
    end
    local t=now()
    local names={}
    for name in pairs(bead_peers) do names[#names+1]=name end
    table.sort(names, function(a,b) return a:lower()<b:lower() end)
    -- Only six characters are expected; omit any extra Windower clients.
    while #names>6 do table.remove(names) end
    local ready_count=0
    local cells={}
    for i=1,6 do
        local name=names[i]
        local label,value
        if not name then
            label,value='Waiting...', '--'
        else
            label=name
            local peer=bead_peers[name]
            if peer and peer.value and peer.updated_at
                and t-peer.updated_at<=BEADS.stale_after
                and t-peer.last_seen<=BEADS.disconnect_after then
                value=comma(peer.value)
                ready_count=ready_count+1
            else
                value='--'
            end
        end
        cells[i]=string.format('%-12s %7s',label,value)
    end
    local lines={'ESCHA BEADS  ('..ready_count..'/6 reporting)'}
    for i=1,3 do
        lines[#lines+1]=cells[i]..'    '..cells[i+3]
    end
    local display=table.concat(lines,'\n')
    if force or display~=last_beads_hud_text then
        bead_hud:text(display)
        last_beads_hud_text=display
    end
    local settings=windower.get_windower_settings()
    local width=settings and (settings.ui_x_res or settings.x_res) or 1280
    local extent=bead_hud:extents()
    local x=math.max(0,math.floor((width-(extent or 0))/2))
    if force or x~=last_beads_hud_width then
        bead_hud:pos(x,BEADS.hud_y)
        last_beads_hud_width=x
    end
    bead_hud:show()
end

local function request_beads()
    local info=windower.ffxi.get_info()
    if not info or not info.logged_in or not valid_name(char_name()) then return end
    -- This is the request the client uses to open Currencies 2, but it does
    -- not open any menu. The actual balance comes back in incoming 0x118.
    local ok,err=pcall(function()
        packets.inject(packets.new('outgoing',0x115))
    end)
    if not ok then warn('Bead currency request failed: '..tostring(err)) end
end

local function beads_tick(t)
    local info=windower.ffxi.get_info()
    if info and info.logged_in and valid_name(char_name()) then
        local name=char_name()
        if not bead_peers[name] then
            remember_beads(name,nil,0)
            say_beads() -- announce ourselves promptly to the other clients
        end
        if t>=next_beads_request then
            next_beads_request=t+BEADS.request_interval
            request_beads()
        end
        if t-last_beads_hello>=BEADS.hello_interval then
            last_beads_hello=t
            remember_beads(name,nil,0)
            say_beads()
        end
    end
    if t~=last_beads_hud_update then
        last_beads_hud_update=t
        update_bead_hud(false)
    end
end
local function distance(a,b)
    if not a or not b then return math.huge end
    return math.sqrt((a.x-b.x)^2 + (a.y-b.y)^2)
end
local function distance_to(x,y)
    return distance(self_mob(), {x=x,y=y})
end
-- Windower's run() is persistent; stopping only movement we started avoids
-- toggling manual movement on some older LuaCore builds.
local function stop_moving()
    if movement_active then windower.ffxi.run(false) end
    movement_active, movement_heading = false, nil
end

-- Use the single-angle overload to avoid the historic run(x,y) position-vector
-- bug. Windower angles: east 0, south +pi/2, north -pi/2.
local function atan2(y, x)
    if math.atan2 then return math.atan2(y, x) end
    if x > 0 then return math.atan(y/x) end
    if x < 0 and y >= 0 then return math.atan(y/x) + math.pi end
    if x < 0 then return math.atan(y/x) - math.pi end
    if y > 0 then return math.pi/2 end
    if y < 0 then return -math.pi/2 end
    return 0
end
local function steer_towards(dx, dy)
    local angle = -atan2(dy, dx)
    local delta = movement_heading and math.abs(atan2(math.sin(angle - movement_heading), math.cos(angle - movement_heading))) or math.huge
    -- Update heading when it changes meaningfully, not on every render frame.
    if not movement_active or delta > 0.028 then
        windower.ffxi.run(angle)
        movement_active, movement_heading = true, angle
    end
end

local function enter_phase(p)
    phase=p
    ready_after=math.max(ready_after, now()+1)
    log('State: '..p..' ['..tostring(target)..']')
end
local function stop(local_only)
    running, paused, phase = false, false, 'IDLE'
    pending, walk, step = nil, nil, nil
    record = nil
    stop_moving()
    if not local_only then broadcast('STOP') end
    log('Stopped. Silmaril stops automatically at confirmed Domain Invasion completion.')
end
local function pause(reason, local_only)
    last_failure=reason or 'Unspecified error'
    paused=true
    pending=nil
    stop_moving()
    warn('PAUSED: '..last_failure)
    if not local_only then broadcast('PAUSE|'..char_name()..'|'..last_failure:gsub('|','/')) end
end

local function load_routes()
    routes={}
    local f=io.open(path,'r')
    if not f then return false end
    for line in f:lines() do
        local name, x, y=line:match('^(%a+)%s+([%d%.%-]+)%s+([%d%.%-]+)$')
        if name and route_zones[name] and tonumber(x) and tonumber(y) then
            routes[name]=routes[name] or {}
            routes[name][#routes[name]+1]={x=tonumber(x), y=tonumber(y)}
        end
    end
    f:close()
    return true
end
local function save_routes()
    local f, err=io.open(path,'w')
    if not f then warn('Cannot write '..path..': '..tostring(err)); return false end
    for _,key in ipairs({'qufim','zitah','misareaux','ruaun','dem','reisenjima'}) do
        for _,p in ipairs(routes[key] or {}) do
            f:write(string.format('%s\t%.3f\t%.3f\n',key,p.x,p.y))
        end
    end
    f:close()
    return true
end
local function record_sample(force)
    if not record then return end
    if zone() ~= route_zones[record.key] then
        warn('Route recording cancelled: changed zone.')
        record=nil
        return
    end
    local m=self_mob()
    if not m then return end
    local pts=record.points
    -- Sample every rendering frame, rather than every second: this preserves
    -- corners and the final point even during fast or laggy movement.
    if #pts==0 or (distance(m,pts[#pts])>0.15 and
        (force or distance(m,pts[#pts])>=CFG.route_sample)) then
        pts[#pts+1]={x=m.x,y=m.y}
    end
end
local function recording_command(arg)
    if arg=='stop' then
        if not record then warn('Not recording.'); return end
        record_sample(true)
        local key=record.key
        routes[key]=record.points
        record=nil
        if save_routes() then log('Saved route '..key..' ('..#routes[key]..' points). Use //df reload on other characters.') end
        return
    end
    if arg=='cancel' then record=nil; log('Recording cancelled.'); return end
    if running then warn('Stop farming before recording routes.'); return end
    if not route_zones[arg] then
        warn('Usage: //df record qufim|zitah|misareaux|ruaun|dem|reisenjima|stop|cancel')
        return
    end
    if zone() ~= route_zones[arg] then
        warn('Route '..arg..' must be recorded in zone '..route_zones[arg]..'.')
        return
    end
    record={key=arg,points={}}
    record_sample(true)
    log('Recording '..arg..': walk normally to the entrance/NPC, then //df record stop.')
end

local function has_routes()
    local missing={}
    for _,name in ipairs({'qufim','zitah','misareaux','ruaun','dem','reisenjima'}) do
        if not routes[name] or #routes[name]==0 then missing[#missing+1]=name end
    end
    return #missing==0, table.concat(missing,', ')
end
local function name_for_zone(z)
    for n,s in pairs(Z) do
        if z==s.id or z==s.approach then return n end
    end
    return nil
end
local function near_arena(z)
    local a=arena[z]
    return a and distance_to(a.x,a.y) < 45 or false
end
local function select_target(name)
    if not Z[name] then return false end
    target=name
    return true
end
local function init_start(preferred)
    load_routes()
    local ok, missing=has_routes()
    if not ok then warn('Record the six routes before starting. Missing: '..missing); return end
    local which=preferred
    if not which or which=='auto' then which=name_for_zone(zone()) end
    if not Z[which] then
        warn('Cannot infer the ACTIVE Domain Invasion from an unrelated zone. Use //df start zitah|ruaun|reisenjima.')
        return
    end
    if record then warn('Stop recording first.'); return end
    running,paused=true,false
    last_completed=nil
    rings_done=false
    pending,walk,step=nil,nil,nil
    completion_at,completion_reason=nil,nil
    domain_wait_start=nil
    started_fight,silmaril_sent=nil,false
    observed_boss,boss_last_seen=false,nil
    select_target(which)
    enter_phase('PLAN')
    log('Started as '..char_name()..' from '..which..'.')
end

local function issue_action(state, command, timeout, origin)
    pending={state=state, cmd=command, attempts=0, wait=timeout, from=origin or zone(), from_pos=self_mob()}
    enter_phase(state)
end
local function begin_walk(key, next_phase)
    local pts=routes[key]
    if not pts or #pts==0 then pause('No coordinates for '..key); return end
    local me=self_mob()
    if not me then return end
    -- Joining at an intermediate waypoint is allowed, but only if close to the saved path.
    local nearest, best=1,math.huge
    for i,p in ipairs(pts) do
        local d=distance(me,p)
        if d<best then nearest,best=i,d end
    end
    if best>CFG.route_start_max then
        pause('Too far from recorded '..key..' route ('..math.floor(best)..' yalms).')
        return
    end
    stop_moving()
    walk={key=key, points=pts, index=nearest, next_phase=next_phase,
        last_progress=now(), last_dist=math.huge, retries=0}
    enter_phase('WALK')
end
-- Detect passage through an intermediate waypoint. A fast-moving character
-- can pass its coordinates between render frames, especially at low FPS.
-- Skip it only if the player is also close to the recorded path segment.
local function passed_waypoint(pos, previous, point)
    if not previous then return false end
    local sx, sy = point.x-previous.x, point.y-previous.y
    local len2 = sx*sx+sy*sy
    if len2 < 0.01 then return false end
    local along = ((pos.x-previous.x)*sx+(pos.y-previous.y)*sy)/len2
    if along < 1 then return false end
    local off = math.abs((pos.x-previous.x)*sy-(pos.y-previous.y)*sx)/math.sqrt(len2)
    return off <= CFG.pass_line_width
end

local function step_walk()
    if not walk then return end
    local m=self_mob()
    if not m then stop_moving(); return end
    if zone() ~= route_zones[walk.key] then
        stop_moving()
        walk=nil
        enter_phase('PLAN')
        return
    end
    local pts = walk.points
    -- Consume already reached/passed intermediate waypoints in one tick.
    -- This prevents returning to points behind the character and zigzagging.
    for _=1,#pts do
        local p=pts[walk.index]
        if not p then break end
        local final=(walk.index==#pts)
        local reach=final and CFG.final_reach or CFG.waypoint_reach
        local arrived=distance(m,p)<=reach
        local crossed=passed_waypoint(m,pts[walk.index-1],p)
        if not arrived and not crossed then break end
        -- Even if a final waypoint was crossed, require proximity to it;
        -- a big coordinate error must not trigger an NPC interaction.
        if final and not arrived and distance(m,p)>CFG.final_reach+1.2 then break end
        walk.index=walk.index+1
        walk.last_progress=now()
        walk.last_dist=math.huge
        walk.retries=0
    end
    local p=pts[walk.index]
    if not p then
        stop_moving()
        local next_phase=walk.next_phase
        walk=nil
        if next_phase=='ENTER_ZONE' then
            issue_action('ENTER_ZONE','sw ew enter',CFG.teleport_timeout,zone())
        elseif next_phase=='ENTER_DOMAIN' then
            domain_wait_start=now()
            issue_action('ENTER_DOMAIN','sw ew domain',CFG.domain_retry_seconds,zone())
        end
        return
    end
    local d=distance(m,p)
    if d<walk.last_dist-0.35 then
        walk.last_progress=now()
        walk.last_dist=d
        walk.retries=0
    elseif now()-walk.last_progress>CFG.route_stuck_seconds then
        walk.retries=walk.retries+1
        if walk.retries>CFG.movement_retry_max then
            pause('Stuck on route '..walk.key..', point '..walk.index)
            return
        end
        warn('Retrying movement: '..walk.key..', point '..walk.index)
        stop_moving()
        walk.last_progress=now()
        walk.last_dist=math.huge
    end
    steer_towards(p.x-m.x,p.y-m.y)
end

local function plan()
    local z=zone()
    if not z then return end
    local s=Z[target]
    if z==s.id then
        if near_arena(z) then
            started_fight=now()
            silmaril_sent=false
            observed_boss=false
            boss_last_seen=nil
            enter_phase('FIGHT')
            log('Inside Domain Invasion. Silmaril starts in '..CFG.silmaril_start_delay..' seconds.')
        else
            begin_walk(s.npc_route,'ENTER_DOMAIN')
        end
    elseif z==s.approach then
        begin_walk(s.key,'ENTER_ZONE')
    elseif target=='reisenjima' then
        issue_action('DEM_RING','gs c useitem ring2 Dim. Ring (Dem)',CFG.ring_timeout,z)
    elseif (z==288 or z==289 or z==291) and not rings_done then
        issue_action('WARP_RING','gs c useitem ring2 Warp Ring',CFG.ring_timeout,z)
    else
        issue_action('HP_WARP','sw hp '..s.hp,CFG.teleport_timeout,z)
    end
end
local function action_succeeded(p, z)
    if p.state=='WARP_RING' then
        return z ~= p.from and z~=nil
    elseif p.state=='DEM_RING' then
        return z==108
    elseif p.state=='HP_WARP' then
        return z==Z[target].approach
    elseif p.state=='ENTER_ZONE' then
        return z==Z[target].id
    elseif p.state=='ENTER_DOMAIN' then
        if z~=Z[target].id then return false end
        return (p.from_pos and distance(self_mob(), p.from_pos)>=CFG.arena_jump)
            or near_arena(z)
    end
    return false
end
local function progress_action()
    local p=pending
    if not p then enter_phase('PLAN'); return end
    local z=zone()
    if action_succeeded(p,z) then
        local succeeded=p.state
        pending=nil
        ready_after=now()+CFG.arrival_delay
        if succeeded=='WARP_RING' then rings_done=true end
        if succeeded=='ENTER_DOMAIN' then
            started_fight=now()
            silmaril_sent=false
            observed_boss=false
            boss_last_seen=nil
            completion_at,completion_reason=nil,nil
            enter_phase('FIGHT')
            log('Inside Domain Invasion. Silmaril starts in '..CFG.silmaril_start_delay..' seconds.')
        else
            enter_phase('PLAN')
        end
        return
    end
    if p.state=='ENTER_DOMAIN' and domain_wait_start and now()-domain_wait_start>CFG.domain_wait_limit then
        pause('Domain NPC did not become available within 25 minutes.')
        return
    end
    if not p.sent_at or now()-p.sent_at>=p.wait then
        if p.attempts>=CFG.teleport_retry_max and p.state~='ENTER_DOMAIN' then
            pause('Failed '..p.state..' after '..p.attempts..' attempts ('..p.cmd..')')
            return
        end
        p.attempts=p.attempts+1
        p.sent_at=now()
        p.from_pos=self_mob()
        send(p.cmd)
    end
end

local bosses={
    zitah={'Azi Dahaka','Mireu'},
    ruaun={'Naga Raja','Mireu'},
    reisenjima={'Quetzalcoatl','Mireu'}
}
local function find_boss()
    if not target then return nil end
    for _,name in ipairs(bosses[target]) do
        local m=windower.ffxi.get_mob_by_name(name)
        if m and m.hpp and m.hpp>0 and m.valid_target then return m end
    end
    return nil
end
local function complete(reason)
    if phase~='FIGHT' or completion_at then return end
    completion_at=now()
    completion_reason=reason
    -- Stop Silmaril immediately on completion, before travelling to the next
    -- zone. This is sent once per fight (guarded by completion_at above).
    send('sm stop')
    log('Invasion complete ('..reason..'); stopped Silmaril; allowing rewards to settle.')
end
local function advance()
    local idx=1
    for i,n in ipairs(order) do if n==target then idx=i; break end end
    last_completed=target
    target=order[idx%#order+1]
    rings_done=false
    completion_at,completion_reason=nil,nil
    started_fight,silmaril_sent=nil,false
    observed_boss,boss_last_seen=false,nil
    domain_wait_start=nil
    ready_after=now()+CFG.reward_delay
    enter_phase('PLAN')
    log('Next: '..target)
end
local function fight_tick()
    if completion_at then
        if now()-completion_at>=CFG.reward_delay then advance() end
        return
    end
    if not started_fight then started_fight=now() end
    -- Allow all six clients time to arrive and apply party buffs before combat.
    if not silmaril_sent and now()-started_fight>=CFG.silmaril_start_delay then
        send('sm start')
        silmaril_sent=true
    end
    local mob=find_boss()
    if mob then
        observed_boss=true
        boss_last_seen=now()
    elseif observed_boss and boss_last_seen and now()-boss_last_seen>=CFG.boss_absent_seconds then
        -- Boss disappearing can indicate a kill, but could also be distance or entity loading.
        -- We only accept it if it has been seen while in the arena and enough time passed.
        if now()-started_fight>=CFG.fight_min_seconds and near_arena(zone()) then
            complete('boss disappeared')
        end
    end
    if now()-started_fight>=CFG.fight_timeout then
        warn('Fight exceeded 75 minutes without confirmation. Advancing as a TIMEOUT fallback; reward is unverified.')
        complete('timeout (unverified)')
    end
end

local function tick()
    local t=now()
    beads_tick(t) -- the HUD works even when farming is stopped or paused
    if record then record_sample(false) end
    if not running or paused then return end
    local info=windower.ffxi.get_info()
    local p=windower.ffxi.get_player()
    if not info or not p or not info.logged_in or not self_mob() then return end
    if (p.vitals and p.vitals.hp==0) then
        pause('Character is KO; cannot continue.')
        return
    end
    local z=zone()
    if last_zone~=z then
        last_zone=z
        stop_moving()
        ready_after=t+CFG.arrival_delay
    end
    if t<ready_after then return end
    -- Navigation MUST be checked at frame rate, not the once-per-second
    -- state-machine cadence. The former 1 Hz check caused NPC overshooting.
    if phase=='WALK' then step_walk(); return end
    if t==last_tick then return end
    last_tick=t
    if phase=='PLAN' then plan()
    elseif phase=='FIGHT' then fight_tick()
    elseif pending then progress_action()
    else warn('Unexpected phase: '..phase); pause('Unexpected state') end
end

windower.register_event('prerender',tick)
windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)
    if id~=0x118 or blocked or type(data)~='string' then return end
    local value
    local ok,decoded=pcall(packets.parse,'incoming',data)
    if ok and decoded then value=tonumber(decoded['Escha Beads']) end
    -- Fallback for Windower installations with an outdated packet fields file.
    -- The unsigned 16-bit little-endian value is at packet offset 0x4A.
    if not value and #data>=0x4C then
        local low,high=data:byte(0x4B,0x4C)
        if low and high then value=low+high*256 end
    end
    if not value or value<0 or value>65535 then return end
    local name=char_name()
    if not valid_name(name) then return end
    remember_beads(name,value,0)
    say_beads()
    update_bead_hud(true)
end)
windower.register_event('unload',function()
    if bead_hud then bead_hud:destroy(); bead_hud=nil end
end)
windower.register_event('zone change',function()
    stop_moving()
    ready_after=now()+CFG.arrival_delay
    -- Refresh on zoning, without hammering the server during the zone load.
    next_beads_request=now()+10
end)
windower.register_event('incoming text',function(original,modified)
    if not running or paused or phase~='FIGHT' or not started_fight then return end
    if now()-started_fight<CFG.fight_min_seconds then return end
    local text=(original or modified or ''):lower()
    -- The English reward message is the preferred success signal. Patterns may
    -- require adjustment if using filters/another client language.
    if (text:find('domain points',1,true) and
        (text:find('obtain',1,true) or text:find('earn',1,true) or text:find('receive',1,true)))
        or (text:find('escha bead',1,true) and
        (text:find('obtain',1,true) or text:find('earn',1,true) or text:find('receive',1,true))) then
        complete('reward chat')
    end
end)
windower.register_event('ipc message',function(msg)
    if type(msg)~='string' or msg:sub(1,11)~='DOMAINFARM|' then return end
    local data=msg:sub(12)
    if data:sub(1,6)=='BEADS|' then
        local name,amount,age=data:match('^BEADS|([^|]+)|([^|]+)|(%d+)$')
        if name and (amount=='-' or tonumber(amount)) then
            local n=amount=='-' and nil or tonumber(amount)
            remember_beads(name,n,age)
            update_bead_hud(true)
        end
        return
    end
    if data=='STOP' then
        if running then stop(true) end
    elseif data:sub(1,6)=='PAUSE|' then
        if running and not paused then
            local who,why=data:match('^PAUSE|([^|]+)|(.+)$')
            pause('Group pause from '..tostring(who)..': '..tostring(why),true)
        end
    elseif data=='RESUME' then
        if running and paused then
            paused=false; pending=nil; walk=nil; enter_phase('PLAN')
            log('Resumed by another character.')
        end
    elseif data:sub(1,6)=='START|' then
        local value=data:sub(7)
        if not running then init_start(value) end
    end
end)

windower.register_event('addon command',function(cmd,...)
    cmd=(cmd or ''):lower()
    local args={...}
    local a=(args[1] or ''):lower()
    local b=(args[2] or ''):lower()
    if cmd=='record' then recording_command(a)
    elseif cmd=='reload' then
        load_routes()
        log('Reloaded shared routes.tsv.')
    elseif cmd=='routes' then
        load_routes()
        for _,n in ipairs({'qufim','zitah','misareaux','ruaun','dem','reisenjima'}) do
            log(n..': '..#(routes[n] or {})..' points')
        end
    elseif cmd=='start' then
        if a=='all' then
            broadcast('START|'..(b~='' and b or 'auto'))
            init_start(b~='' and b or 'auto')
        else init_start(a~='' and a or 'auto') end
    elseif cmd=='stop' then stop(a~='all')
    elseif cmd=='pause' then if running then pause('Manual pause',a~='all') end
    elseif cmd=='resume' then
        if running then
            paused=false; pending=nil; walk=nil; enter_phase('PLAN')
            log('Resumed.')
            if a=='all' then broadcast('RESUME') end
        end
    elseif cmd=='done' then
        if running and phase=='FIGHT' then complete('manual override') end
    elseif cmd=='set' then
        if Z[a] then
            target=a
            rings_done=false
            pending=nil; walk=nil
            completion_at=nil
            enter_phase('PLAN')
            log('Target overridden: '..a)
        else warn('Usage: //df set zitah|ruaun|reisenjima') end
    elseif cmd=='beads' then
        if a=='hide' then
            BEADS.show=false
            update_bead_hud(true)
            log('Escha Beads HUD hidden on this client.')
        elseif a=='show' then
            BEADS.show=true
            update_bead_hud(true)
            say_beads()
            log('Escha Beads HUD shown on this client.')
        elseif a=='refresh' or a=='' then
            next_beads_request=now()+BEADS.request_interval
            request_beads()
            say_beads()
            update_bead_hud(true)
            log('Requested a fresh Escha Beads total from the server.')
        else
            log('Usage: //df beads [show|hide|refresh]')
        end
    elseif cmd=='status' then
        log(string.format('running=%s paused=%s phase=%s target=%s last=%s',
            tostring(running),tostring(paused),phase,tostring(target),tostring(last_completed)))
        if walk then log('Route '..walk.key..': '..walk.index..'/'..#walk.points) end
        if phase=='FIGHT' and not silmaril_sent and started_fight and not completion_at then
            log('Silmaril start in '..math.max(0, CFG.silmaril_start_delay - (now()-started_fight))..'s')
        end
        if pending then log('Pending '..pending.state..' attempt '..pending.attempts) end
        if paused then log('Reason: '..last_failure) end
    else
        log('Commands: start [all] [auto|zitah|ruaun|reisenjima], stop [all], pause [all], resume [all],')
        log('  record <route|stop|cancel>, routes, reload, set <zone>, status, done, beads [show|hide|refresh]')
    end
end)

load_routes()
new_bead_hud()
update_bead_hud(true)
log('Loaded. Inactive until //df start. Bead HUD enabled; see README.')
