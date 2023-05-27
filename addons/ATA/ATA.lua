_addon.name = 'AutoTargetAssist'
_addon.author = 'Toast'
_addon.version = '0.1.2'
_addon.commands = {'ata', 'ATA'}

require('luau')
require('chat')
logger = require('logger')
packets = require('packets')

defaults = {}
defaults.minDist = 21
defaults.mobHPFilter = 'highest'
defaults.petFilter = true

settings = config.load(defaults)

local targetingOn = true
local engaged = false
local myTarget = nil
local player = windower.ffxi.get_player()
local partyMembers = T{}
local totalPartyMembers
local partyMemebersInZone
local partyPets = T{}
local enmityList = T{}
local actionCategories = S{1, 2, 3, 4, 6, 11, 13, 15}
local ignoreIdlePacket = false

windower.register_event('addon command', function (...)
	local args	= T{...}:map(string.lower)
	if args[1] == "on" then
		targetingOn = true
		windower.add_to_chat(2, "ATA targeting: on")
	elseif args[1] == "off" then
		targetingOn = false
		windower.add_to_chat(2, "ATA targeting: off")
	elseif args[1] == "d" or args[1] == "distance" then
		local distNum = tonumber(args[2])
		if distNum then 
			settings.minDist = distNum
			windower.add_to_chat(207, "ATA minimum distance: " .. tostring(settings.minDist))
		end
	elseif args[1] == "hpf" or args[1] == "hpfilter" then
		local filterValue = args[2]
		if filterValue == "h" or filterValue == "high" or filterValue == "highest" then
			settings.mobHPFilter = 'highest'
			windower.add_to_chat(207, "ATA mobHPFilter: " .. settings.mobHPFilter)
		elseif filterValue == "l" or filterValue == "low" or filterValue == "lowest" then
			settings.mobHPFilter = 'lowest'
			windower.add_to_chat(207, "ATA mobHPFilter: " .. settings.mobHPFilter)
		elseif filterValue == "n" or filterValue == "none" then
			settings.mobHPFilter = 'none'
			windower.add_to_chat(207, "ATA mobHPFilter: " .. settings.mobHPFilter)
		end
	elseif args[1] == "pf" or args[1] == "pet" or args[1] == "petfilter" then
		local filterValue = args[2]
		if filterValue == "t" or filterValue == "true" then
			settings.petFilter = true
			windower.add_to_chat(207, "ATA petFilter: " .. tostring(settings.petFilter))
		elseif filterValue == "f" or filterValue == "false" then
			settings.petFilter = false
			windower.add_to_chat(207, "ATA petFilter: " .. tostring(settings.petFilter))
		end
	elseif args[1] == "save" then
		config.save(settings, player.name)
		windower.add_to_chat(207, "ATA settings saved")
	elseif args[1] == "settings" then
		windower.add_to_chat(207, "ATA settings --------------")
		windower.add_to_chat(207, "Minimum distance: " .. tostring(settings.minDist))
		windower.add_to_chat(207, "Mob HP filter: " .. settings.mobHPFilter)
		windower.add_to_chat(207, "Pet filter: " .. tostring(settings.petFilter))
	elseif args[1] == "help" or args[1] == nil then
		local helptext = [[Auto Target Assist - command list
		1. on | off -- Turns targeting on or off. Default is on.
		2. d | distance <number> -- Sets the minimum targeting distance.
		     Monsters outside of this range will not be auto-targeted.
		3. hpf | hpfilter <h | high | highest, l | low | lowest, n | none> --
		     Sets hp filter value. Highest will auto target monsters
		     with the highest remaining hp first. Lowest will target 
		     monsters with the lowest remaining hp first. None will
		     target monsters purely on distance from you.
		4. pf | pet | petfilter <t | true, f | false> -- Sets pet filter value.
		     If true, enemy pets will be filtered out of the auto-target list. 
		     If false, enemy pets will be included in the auto-target list
		5. save -- Saves the above settings for this character
		6. settings -- Displays your current settings
		7. help -- Displays this help text.]]
		for _, line in ipairs(helptext:split('\n')) do
			windower.add_to_chat(207, line)
        end
	end
end)

windower.register_event('status change', function(new, old)
    if new == 1 then
		engaged = true
		myTarget = windower.ffxi.get_mob_by_target('t')
	else 
		engaged = false
		myTarget = nil
	end
end)

windower.register_event('incoming chunk', function(id, data, modified, injected, blocked)
	if id == 0x029 then -- Action Message
		actionMessageHandler(packets.parse('incoming', data))
	elseif id == 0x0DD then -- Party information message
		partyMessageHandler(packets.parse('incoming', data))
	elseif id == 0x067 then -- Pet information message
		petInfoMessageHandler(packets.parse('incoming', data))
	elseif id == 0x037 then -- Update Char message
		local charPacket = packets.parse('incoming', data)
		if charPacket.Status == 0 and ignoreIdlePacket == true then
			return true
		end
	end
end)

windower.register_event('outgoing chunk', function(id, data)
	local outPacket = packets.parse('outgoing', data)
	if id == 0x01A and outPacket.Category == 4 then -- Action / Disengage
		ignoreIdlePacket = false
	end
end)

windower.register_event('action', function(act)
	if actionCategories:contains(act.category) then
		local actorID = act.actor_id
		local targetID = nil
		local pc = nil
		local mob = nil
		for i,v in ipairs(act.targets) do
			targetID = v.id
			pc = nil
			mob = nil
			if isAlly(actorID) then
				pc = actorID
			elseif isNPC(actorID) then
				mob = actorID
			end
			if isAlly(targetID) then
				pc = targetID
			elseif isNPC(targetID) then
				mob = targetID
			end
			if pc and mob then
				-- There's PC and Mob interaction, so there must be enmity
				if not enmityList[mob] then
					local mobData = windower.ffxi.get_mob_by_id(mob)
					if mobData.name:contains("'s ") then
						if settings.petFilter == false then
							enmityList[mob] = {name = mobData.name, id = mobData.id}
							-- windower.add_to_chat(2, tostring(mobData.name .. " | " .. mob .. " Added to enmity list"))
						end
					else
						enmityList[mob] = {name = mobData.name, id = mobData.id}
						-- windower.add_to_chat(2, tostring(mobData.name .. " | " .. mob .. " Added to enmity list"))
					end
				end
			end
		end
	end
end)

windower.register_event('zone change', function(new_id, old_id)
	enmityList = T{}
end)

function determineNextBestTarget()
	local mob
	local mobsInRange = T{}
	local mobsFullHP = T{}
	local mobsMissingHp = T{}
	local selectedMobID
	local selectedMobIndex
	for i,v in pairs(enmityList) do
		mob = windower.ffxi.get_mob_by_id(v.id)
		if mob.valid_target and mob.distance:sqrt() <= settings.minDist and not (mob.id == myTarget.id) then
			mobsInRange:append(mob)
			if mob.hpp == 100 then
				mobsFullHP:append(mob)
			else
				mobsMissingHp:append(mob)
			end
		end
	end
	if mobsInRange:length() > 0 then
		ignoreIdlePacket = true
		local distance_sort = function(low, high)
			return low.distance < high.distance
		end
		local hp_sort_high = function(low, high)
			return high.hpp < low.hpp
		end
		local hp_sort_low = function(low, high)
			return low.hpp < high.hpp
		end
		mobsInRange = mobsInRange:sort(distance_sort)
		mobsFullHP = mobsFullHP:sort(distance_sort)
		if settings.mobHPFilter == 'highest' then
			mobsMissingHp = mobsMissingHp:sort(hp_sort_high)
		elseif settings.mobHPFilter == 'lowest' then
			mobsMissingHp = mobsMissingHp:sort(hp_sort_low)
		end
		
		if settings.mobHPFilter == 'highest' and mobsFullHP:length() > 0 then
			selectedMobID = mobsFullHP:first().id
			selectedMobIndex = mobsFullHP:first().index
		end
		if settings.mobHPFilter == 'lowest' or mobsFullHP:length() == 0 then
			selectedMobID = mobsMissingHp:first().id
			selectedMobIndex = mobsMissingHp:first().index
		end
		if settings.mobHPFilter == 'none' then
			selectedMobID = mobsInRange:first().id
			selectedMobIndex = mobsInRange:first().index
		end
		-- Inject packets for switching target both outgoing and incoming
		packets.inject(packets.new('outgoing', 0x01A, {
			['Target'] = selectedMobID,
			['Target Index'] = selectedMobIndex,
			['Category'] = 15,
			['Param'] = 0,
			['_unknown1'] = 0,
			['X Offset'] = 0,
			['Z Offset'] = 0,
			['Y Offset'] = 0
		}))
		packets.inject(packets.new('incoming', 0x058, {
			['Player'] = player.id,
			['Target'] = selectedMobID,
			['Player Index'] = player.index,
		}))
		myTarget = windower.ffxi.get_mob_by_id(selectedMobID)
	else
		ignoreIdlePacket = false
		disengageMe()
	end
end

function disengageMe()
	local player = windower.ffxi.get_player()
	if player.status == 1 then
		packets.inject(packets.new('outgoing', 0x01A, {
			['Target'] = player.id,
			['Target Index'] = player.index,
			['Category'] = 4,
			['Param'] = 0,
			['_unknown1'] = 0,
			['X Offset'] = 0,
			['Z Offset'] = 0,
			['Y Offset'] = 0
		}))
	end
end

function isAlly(id)
	if id == player.id then return true end
	if isNPC(id) then return false end
	if partyPets[id] and partyMembers[partyPets[id].owner] then return true end
	if partyMembers[id] == nil then return false end
	return partyMembers[id]
end

function isNPC(id)
	local entity = windower.ffxi.get_mob_by_id(id)
	if not entity then return nil end
	return entity.is_npc and not entity.charmed
end

function playerInZone(playerZone)
	local myZone = windower.ffxi.get_info().zone
	if myZone == playerZone then return true end
	return false
end

function recordPartyMembers(p, pNum)
	if p and playerInZone(p.zone) then partyMemebersInZone = partyMemebersInZone + 1 end
	if p and p.mob and not partyMembers[p.mob.id] then
		partyMembers[p.mob.id] = {name = p.name, party = pNum}
	end
end

function scanForPartyMembers()
	partyMembers = T{}
	local party = windower.ffxi.get_party()
	if not party then return end
	partyMemebersInZone = 0
	local member
	for i=0, (party.party1_count or 0) -1 do
		member = party['p'..tostring(i)]
		recordPartyMembers(member, 1)
	end
	for i=0, (party.party2_count or 0) -1 do
		member = party['a1'..tostring(i)]
		recordPartyMembers(member, 2)
	end
	for i=0, (party.party3_count) -1 do
		member = party['a2'..tostring(i)]
		recordPartyMembers(member, 3)
	end
	if partyMembers:length() < partyMemebersInZone then -- Not everyone was in range to get mob data from get_party() 
		coroutine.schedule(scanForPartyMembers, 5)
	end
end

function actionMessageHandler(amPacket)
	-- If enemy defeated or falls to the ground message
	if amPacket.Message == 6 or amPacket.Message == 20 then
		if enmityList[amPacket.Target] then -- Remove the enemy that just died from the enmity list
			enmityList[amPacket.Target] = nil
		end
		-- If enemy that died is the one you have targeted and you are engaged
		if engaged and myTarget.id == amPacket.Target then
			if enmityList:length() > 0 and targetingOn then
				determineNextBestTarget()
			else
				ignoreIdlePacket = false
				disengageMe()
			end
		end
	end
end

function partyMessageHandler(pmPacket)
	coroutine.schedule(function()
		local party = windower.ffxi.get_party()
		if not party then return end
		local members = 0
		if party.party1_count then
			members = members + party.party1_count
		end
		if party.party2_count then
			members = members + party.party2_count
		end
		if party.party3_count then
			members = members + party.party3_count
		end
		totalPartyMembers = members
		scanForPartyMembers()
	end, 1)
end

function petInfoMessageHandler(petPacket)
	if petPacket['Owner Index'] > 0 then
		local owner = windower.ffxi.get_mob_by_index(petPacket['Owner Index'])
		if owner then
			if isAlly(owner.id) and not partyPets[petPacket['Pet ID']] then
				partyPets[petPacket['Pet ID']] = {owner = owner.id}
			elseif not isAlly(owner.id) and partyPets[petPacket['Pet ID']] then
				partyPets[petPacket['Pet ID']] = nil
			end
		end
	end
end

scanForPartyMembers()