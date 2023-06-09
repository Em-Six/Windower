function user_job_setup()
	-- Options: Override default values
    state.OffenseMode:options('Normal','SubtleBlow')
    state.WeaponskillMode:options('Match','AttackCapped')
	state.HybridMode:options('Normal','DT')
    state.PhysicalDefenseMode:options('PDT', 'PDTReraise')
    state.MagicalDefenseMode:options('MDT', 'MDTReraise')
	state.ResistDefenseMode:options('MEVA')
	state.IdleMode:options('Normal', 'PDT','Refresh','Reraise')
    --state.ExtraMeleeMode = M{['description']='Extra Melee Mode','None'}
	state.ExtraMeleeMode = M{['description']='Extra Melee Mode','None','KatanaSkill','GreatKatanaSkill'}
	state.Passive = M{['description'] = 'Passive Mode','None','Twilight'}
	state.Weapons:options('Naegling','Loxotic','ShiningOne','Chango','Xoanon','ProcDagger','ProcSword','ProcGreatSword','ProcScythe','ProcPolearm','ProcKatana','ProcGreatKatana','ProcClub','ProcStaff')
	state.Stance:options('None','Hasso','Seigan')
	
	autows = "Upheaval"

	gear.da_jse_back = { name="Cichol's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','"Dbl.Atk."+10','Phys. dmg. taken-10%',}}
	gear.wsd_vit_jse_back = { name="Cichol's Mantle", augments={'VIT+20','Accuracy+20 Attack+20','VIT+10','Weapon skill damage +10%',}}
	gear.wsd_str_jse_back = { name="Cichol's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}}
	gear.wsd_mab_jse_back = { name="Cichol's Mantle", augments={'STR+20','Mag. Acc+20 /Mag. Dmg.+20','Magic Damage +10','Weapon skill damage +10%','Phys. dmg. taken-10%',}}
	
	select_default_macro_book()
end

--Abyssea Proc Extra Equips 
function user_job_state_change(stateField, newValue, oldValue)
    if stateField == "Weapons" then
        if newValue:startswith('Proc') then
            local procSkill = string.sub(newValue,5).."Skill"

            if sets[procSkill] then
                state.ExtraMeleeMode:set(procSkill)
            else
                state.ExtraMeleeMode:reset()
            end
        else
            state.ExtraMeleeMode:reset()
        end
    end
end

function user_job_post_precast(spell, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' and state.ExtraMeleeMode.value:endswith('Skill') then
        equip(sets[state.ExtraMeleeMode.value])
    end
end

-- WS Changes
function job_filtered_action(spell, eventArgs)
	if spell.type == 'WeaponSkill' then
		local available_ws = S(windower.ffxi.get_abilities().weapon_skills)
		-- WS 112 is Double Thrust, meaning a Spear is equipped.
		if available_ws:contains(42) then
            if spell.english == "Upheaval" then
				windower.chat.input('/ws "Savage Blade" '..spell.target.raw)
                cancel_spell()
				eventArgs.cancel = true
            end
        end
		if available_ws:contains(42) then
            if spell.english == "Fell Cleave" then
				windower.chat.input('/ws "Circle Blade" '..spell.target.raw)
                cancel_spell()
				eventArgs.cancel = true
            end
        end
		if available_ws:contains(189) then
            if spell.english == "Fell Cleave" then
				windower.chat.input('/ws "Cataclysm" '..spell.target.raw)
                cancel_spell()
				eventArgs.cancel = true
            end
        end
		if available_ws:contains(48) then
            if spell.english == "Upheaval" then
				windower.chat.input('/ws "Resolution" '..spell.target.raw)
                cancel_spell()
				eventArgs.cancel = true
            end
        end
		if available_ws:contains(112) then
            if spell.english == "Upheaval" then
				windower.chat.input('/ws "Impulse Drive" '..spell.target.raw)
                cancel_spell()
				eventArgs.cancel = true
            end
        end
		if available_ws:contains(167) then
            if spell.english == "Upheaval" then
				windower.chat.input('/ws "Judgment" '..spell.target.raw)
                cancel_spell()
				eventArgs.cancel = true
            end
        end
	end
end

-- Define sets and vars used by this job file.
function init_gear_sets()
	--------------------------------------
	-- Start defining the sets
	--------------------------------------
	-- Precast Sets
	
    sets.Enmity = {
		ammo="Charitoni Sling",
		head="Souv. Schaller +1",
		body="Souv. Cuirass +1",
		hands="Souv. Handsch. +1",
		legs="Souv. Diechlings +1",
		feet="Eschite Greaves",
		neck="Unmoving Collar +1",
		waist="Goading Belt",
		left_ear="Trux Earring",
		right_ear="Cryptic Earring",
		left_ring="Apeile Ring +1",
		right_ring="Apeile Ring",
	}
	sets.Knockback = {}
	sets.passive.Twilight = {head="Twilight Helm",body="Twilight Mail"}
	
	-- Precast sets to enhance JAs
	sets.precast.JA['Berserk'] = {body="Pummeler's Lorica +3",feet="Agoge Calligae +1",back=gear.da_jse_back}
	sets.precast.JA['Warcry'] = {head="Agoge Mask +3",}
	sets.precast.JA['Defender'] = {}
	sets.precast.JA['Aggressor'] = {}
	sets.precast.JA['Mighty Strikes'] = {hands="Agoge Mufflers"}
	sets.precast.JA["Warrior's Charge"] = {}
	sets.precast.JA['Tomahawk'] = {ammo="Thr. Tomahawk",feet="Agoge Calligae +1"}
	sets.precast.JA['Retaliation'] = {}
	sets.precast.JA['Restraint'] = {}
	sets.precast.JA['Blood Rage'] = {body="Boii Lorica +3"}
	sets.precast.JA['Brazen Rush'] = {}
	sets.precast.JA['Provoke'] = set_combine(sets.Enmity,{})
                   
	-- Waltz set (chr and vit)
	sets.precast.Waltz = {}
                   
	-- Don't need any special gear for Healing Waltz.
	sets.precast.Waltz['Healing Waltz'] = {}
           
	sets.precast.Step = {}
	
	sets.precast.Flourish1 = {}
		   
	-- Fast cast sets for spells

	sets.precast.FC = {ammo="Impatiens",
		head="Carmine Mask +1",neck="Voltsurge Torque",ear1="Enchntr. Earring +1",ear2="Loquac. Earring",
		body="Sacro breastplate",hands="Leyline Gloves",ring1="Lebeche Ring",ring2="Weather. Ring",
		back="Moonlight Cape",waist="Flume Belt +1",legs=gear.odyssean_fc_legs,feet="Odyssean Greaves"}
	
	sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {})

	-- Midcast Sets
	sets.midcast.FastRecast = {ammo="Crepuscular Pebble +1",
		head="Carmine Mask +1",neck="Voltsurge Torque",ear1="Enchntr. Earring +1",ear2="Loquac. Earring",
		body="Odyss. Chestplate",hands="Leyline Gloves",ring1="Lebeche Ring",ring2="Prolix Ring",
		back="Moonlight Cape",waist="Tempus Fugit",legs=gear.odyssean_fc_legs,feet="Odyssean Greaves"}
	
	sets.midcast.Utsusemi = set_combine(sets.midcast.FastRecast, {back="Mujin Mantle"})
                   
	sets.midcast.Cure = {}
	
	sets.Self_Healing = {neck="Phalaina Locket",hands="Buremte Gloves",ring2="Kunaji Ring",waist="Gishdubar Sash"}
	sets.Cure_Received = {neck="Phalaina Locket",hands="Buremte Gloves",ring2="Kunaji Ring",waist="Gishdubar Sash"}
						                   
	-- Weaponskill sets
	-- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
		ammo="Knobkierrie",
		head="Agoge Mask +3",
		body="Nyame Mail",
		hands="Boii Mufflers +3",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets",
		neck="Warrior's Bead Necklace +2",
		waist="Sailfi Belt +1",
		left_ear="Moonshade Earring",
		right_ear="Thrud Earring",
		left_ring="Epaminondas's Ring",
		right_ring="Sroda Ring",
		back=gear.wsd_str_jse_back,
	}
	
	sets.precast.WS.Mighty = set_combine(sets.precast.WS, {ammo="Yetshila +1", legs="Boii Cuisses +3", feet="Boii Calligae +3"})

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.	
    sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {})
    sets.precast.WS['Savage Blade'].Mighty = set_combine(sets.precast.WS, {ammo="Yetshila +1", legs="Boii Cuisses +3", feet="Boii Calligae +3"})


    sets.precast.WS['Upheaval'] = set_combine(sets.precast.WS, {legs="Boii Cuisses +3", left_ring="Niqmaddu Ring", right_ring="Regal Ring", back=gear.wsd_vit_jse_back,})
	
	sets.precast.WS['Armor Break'] = {
	    ammo="Crepuscular Pebble", -- Need Pemphredo Tathlum
		head="Sakpata's Helm",
		body="Sakpata's Plate",
		hands="Sakpata's Gauntlets",
		legs="Sakpata's Cuisses",
		feet="Sakpata's Leggings",
		neck="Moonlight Necklace",
		waist="Eschan Stone",
		left_ear="Crep. Earring",
		right_ear="Odnowa Earring", -- Need Dignitary's Earring
		left_ring="Crepuscular Ring",
		right_ring="Weather. Ring",
		back=gear.wsd_str_jse_back, -- Need Macc Cape
	}
    
	sets.precast.WS['Full Break'] = sets.precast.WS['Armor Break']
	
    sets.precast.WS['Resolution'] = set_combine(sets.precast.WS, {neck="Fotia Gorget",waist="Fotia Belt"})
	
    sets.precast.WS["Ukko's Fury"] = set_combine(sets.precast.WS, {ammo="Yetshila +1", head="Boii mask +3", body="Hjarrandi Breast.", feet="Boii Calligae +3", right_ring="Lehko's Ring"}) 

    sets.precast.WS["King's Justice"] = set_combine(sets.precast.WS, {left_ring="Niqmaddu Ring", right_ring="Regal Ring"})
	
	sets.precast.WS["Fell Cleave"] = set_combine(sets.precast.WS, {left_ear="Lugra Earring +1",})
	
	sets.precast.WS['Impulse Drive'] = sets.precast.WS["Ukko's Fury"]
	
	sets.precast.WS["Aeolian Edge"] = {
	    ammo="Seeth. Bomblet +1",
		head="Nyame Helm",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets",
		neck="Sibyl Scarf",
		waist="Eschan Stone",
		left_ear="Moonshade Earring",
		right_ear="Friomisi Earring",
		left_ring="Epaminondas's Ring",
		right_ring="Metamor. Ring +1",
		back=gear.wsd_mab_jse_back,
	}
	
	sets.precast.WS["Cataclysm"] = set_combine(sets.precast.WS["Aeolian Edge"], {head="Pixie Hairpin +1", left_ring="Archon Ring"})
	sets.precast.WS["Earth Crusher"] = set_combine(sets.precast.WS["Aeolian Edge"], {})
	
	sets.precast.WS["Sanguine Blade"] = sets.precast.WS["Cataclysm"]
	
	-- Swap to these on Moonshade using WS if at 3000 TP
	sets.MaxTP = {ear1="Lugra Earring +1",ear2="Thrud Earring",}
	sets.AccMaxTP = {ear1="Mache Earring +1",ear2="Telos Earring"}
	sets.AccDayMaxTPWSEars = {ear1="Mache Earring +1",ear2="Telos Earring"}
	sets.DayMaxTPWSEars = {ear1="Lugra Earring +1",ear2="Thrud Earring",}
	sets.DayMaxTPWSEars = {ear1="Lugra Earring +1",ear2="Thrud Earring",}
	sets.AccDayWSEars = {ear1="Mache Earring +1",ear2="Telos Earring"}
	sets.DayWSEars = {ear1="Lugra Earring +1",ear2="Thrud Earring"}
	
	--Specialty WS set overwrites.
	sets.AccWSMightyCharge = {}
	sets.AccWSCharge = {}
	sets.AccWSMightyCharge = {}
	sets.WSMightyCharge = {}
	sets.WSCharge = {}
	sets.WSMighty = {}

     -- Sets to return to when not performing an action.
           
     -- Resting sets
     sets.resting = {}
           
	-- Idle sets
	sets.idle = {		
		ammo="Staunch Tathlum",
		head="Sakpata's Helm",
		body="Sakpata's Plate",
		hands="Sakpata's Gauntlets",
		legs="Sakpata's Cuisses",
		feet="Sakpata's Leggings",
		neck="Warder's Charm +1", -- Dynamis RP SWAP
		--neck="Warrior's Bead Necklace +2",
		waist="Platinum Moogle Belt",
		left_ear="Odnowa Earring +1",
		right_ear="Odnowa Earring",
		left_ring=gear.moonlight1,
		right_ring="Shadow Ring",
		back="Shadow Mantle",
	}
		
	sets.idle.Weak = set_combine(sets.idle, {})
		
	sets.idle.Reraise = set_combine(sets.idle, {head="Twilight Helm",body="Twilight Mail"})
	
	-- Defense sets
	sets.defense.PDT = {ammo="Crepuscular Pebble +1",
		head="Genmei Kabuto",neck="Loricate Torque +1",ear1="Genmei Earring",ear2="Ethereal Earring",
		body="Tartarus Platemail",hands="Sulev. Gauntlets +2",ring1="Moonbeam Ring",ring2="Moonlight Ring",
		back="Shadow Mantle",waist="Flume Belt +1",legs="Sulev. Cuisses +2",feet="Amm Greaves"}
		
	sets.defense.PDTReraise = set_combine(sets.defense.PDT, {head="Twilight Helm",body="Twilight Mail"})

	sets.defense.MDT = {ammo="Crepuscular Pebble +1",
		head="Genmei Kabuto",neck="Warder's Charm +1",ear1="Genmei Earring",ear2="Ethereal Earring",
		body="Tartarus Platemail",hands="Sulev. Gauntlets +2",ring1="Moonbeam Ring",ring2="Moonlight Ring",
		back="Moonlight Cape",waist="Flume Belt +1",legs="Sulev. Cuisses +2",feet="Amm Greaves"}
		
	sets.defense.MDTReraise = set_combine(sets.defense.MDT, {head="Twilight Helm",body="Twilight Mail"})
		
	sets.defense.MEVA = {ammo="Crepuscular Pebble +1",
		head="Genmei Kabuto",neck="Warder's Charm +1",ear1="Genmei Earring",ear2="Ethereal Earring",
		body="Tartarus Platemail",hands="Sulev. Gauntlets +2",ring1="Moonbeam Ring",ring2="Moonlight Ring",
		back="Moonlight Cape",waist="Flume Belt +1",legs="Sulev. Cuisses +2",feet="Amm Greaves"}

	sets.Kiting = {feet="Hermes' Sandals"}
	sets.idle.Town = set_combine(sets.idle, sets.Kiting, {body="Sacro Breastplate"})
	sets.Reraise = {head="Twilight Helm",body="Twilight Mail"}
	sets.buff.Doom = set_combine(sets.buff.Doom, {})
	sets.buff.Sleep = {head="Frenzy Sallet"}
     
            -- Engaged sets
	sets.engaged = { 
		-- 97% DA 2% TA 3% QA 46 Store TP, 1446 Accuracy (Naegling) 1494 Accuracy (Chango)
		ammo="Coiste Bodhar", 
		head="Hjarrandi Helm", 
		body="Boii Lorica +3", 
		hands="Sakpata's Gauntlets", 
		legs="Pummeler's Cuisses +3", 
		feet="Pummeler's Calligae +3", 
		neck="Warrior's Bead Necklace +2", 
		waist="Windbuffet Belt +1", 
		left_ear="Telos Earring", 
		right_ear="Schere Earring", 
		left_ring="Niqmaddu Ring", 
		right_ring="Lehko's Ring", 
		back=gear.da_jse_back, 
	}
	
		sets.engaged.DT = { 
		-- 55% DA + 28% DA from Traits = 83% DA
		ammo="Coiste Bodhar",
		head="Sakpata's Helm",
		body="Boii Lorica +3", 
		hands="Sakpata's Gauntlets",
		legs="Sakpata's Cuisses",
		feet="Sakpata's Leggings",
		neck="Warrior's Bead Necklace +2",
		waist="Ioskeha Belt +1",
		left_ear="Telos Earring",
		right_ear="Schere Earring",
		left_ring=gear.moonlight1,
		right_ring="Lehko's Ring", 
		back=gear.da_jse_back,
	}
	
	sets.engaged.SubtleBlow = { -- 25 SB1 + 15 SB2
	    ammo="Seeth. Bomblet +1",
		head="Sakpata's Helm",
		body="Dagon Breast.", -- 10 SB2
		hands="Sakpata's Gauntlets", -- 8 SB1
		legs="Sakpata's Cuisses",
		feet="Sakpata's Leggings", -- 7 SB1 (13 when capped)
		neck="War. Beads +2",
		waist="Ioskeha Belt +1",
		left_ear="Telos Earring",
		right_ear="Cessance Earring",
		left_ring="Niqmaddu Ring", 
		right_ring=gear.moonlight2, 
		back=gear.da_jse_back,
	}
	
    sets.engaged.SomeAcc = {ammo="Coiste Bodhar",
		head="Flam. Zucchetto +2",neck="Combatant's Torque",ear1="Schere Earring",ear2="Cessance Earring",
		body=gear.valorous_wsd_body,hands=gear.valorous_acc_hands,ring1="Flamma Ring",ring2="Niqmaddu Ring",
		back="Cichol's Mantle",waist="Ioskeha Belt",legs="Sulev. Cuisses +2",feet="Flam. Gambieras +2"}
	sets.engaged.Acc = {ammo="Coiste Bodhar",
		head="Flam. Zucchetto +2",neck="Combatant's Torque",ear1="Digni. Earring",ear2="Telos Earring",
		body=gear.valorous_wsd_body,hands=gear.valorous_acc_hands,ring1="Flamma Ring",ring2="Niqmaddu Ring",
		back="Cichol's Mantle",waist="Ioskeha Belt",legs="Sulev. Cuisses +2",feet="Flam. Gambieras +2"}
    sets.engaged.FullAcc = {ammo="Coiste Bodhar",
		head="Flam. Zucchetto +2",neck="Combatant's Torque",ear1="Mache Earring +1",ear2="Telos Earring",
		body=gear.valorous_wsd_body,hands=gear.valorous_acc_hands,ring1="Flamma Ring",ring2="Ramuh Ring +1",
		back="Cichol's Mantle",waist="Ioskeha Belt",legs="Sulev. Cuisses +2",feet="Flam. Gambieras +2"}
    sets.engaged.Fodder = {ammo="Coiste Bodhar",
		head="Flam. Zucchetto +2",neck="Asperity Necklace",ear1="Schere Earring",ear2="Cessance Earring",
		body=gear.valorous_wsd_body,hands=gear.valorous_acc_hands,ring1="Petrov Ring",ring2="Niqmaddu Ring",
		back="Cichol's Mantle",waist="Ioskeha Belt",legs="Sulev. Cuisses +2",feet="Flam. Gambieras +2"}


	--Extra Special Sets
	
	sets.buff.Doom = set_combine(sets.buff.Doom, {})
	sets.buff.Retaliation = {}
	sets.buff.Restraint = {}
	sets.TreasureHunter = set_combine(sets.TreasureHunter, {})
	sets.Cure_Received = {waist="Gishdubar Sash"}
	
	sets.Phalanx_Received = {
		head=gear.yorium_phalanx_head,
		body=gear.odyssean_phalanx_body,
		hands="Souv. Handsch. +1",
		legs="Sakpata's Cuisses",
		feet="Souveran Schuhs +1"
	}
	
	-- Weapons sets
	sets.weapons.Chango = {main="Chango",sub="Utu Grip"}
	sets.weapons.Naegling = {main="Naegling",sub="Blurred Shield +1"}
	sets.weapons.Loxotic = {main="Loxotic Mace +1",sub="Blurred Shield +1"}
	sets.weapons.Montante = {main="Montante +1",sub="Utu Grip"}
	sets.weapons.ShiningOne = {main="Shining One",sub="Utu Grip"}
	sets.weapons.Xoanon = {main="Xoanon",sub="Utu Grip"}
	sets.weapons.ProcDagger = {main="Aern Dagger",sub=empty}
	sets.weapons.ProcSword = {main="Firetongue",sub=empty}
	sets.weapons.ProcGreatSword = {main="Claymore",sub=empty}
	sets.weapons.ProcScythe = {main="Bronze Zaghnal",sub=empty}
	sets.weapons.ProcPolearm = {main="Quint Spear",sub=empty}
	sets.weapons.ProcKatana = {main="Debahocho",sub=empty}
	sets.weapons.ProcGreatKatana = {main="Mutsunokami",sub=empty}
	sets.weapons.ProcClub = {main="Nomad Moogle Rod",sub=empty}
	sets.weapons.ProcStaff = {main="Sophistry",sub=empty}
	sets.weapons.Trial = {main="Sword of Trials", sub="Utu Grip"}
	
	-- Sets for Abyssea
	sets.KatanaSkill = {neck="Yarak Torque"}
	sets.GreatKatanaSkill = {head="Kengo Hachimaki",neck="Agelast Torque"}

end
	
-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == 'SAM' then
        set_macro_page(1, 3)
    elseif player.sub_job == 'DRG' then
        set_macro_page(2, 3)
    elseif player.sub_job == 'THF' then
        set_macro_page(1, 3)
    else
        set_macro_page(1, 3)
    end
end

function user_job_lockstyle()
	windower.chat.input('/lockstyleset 002')
end