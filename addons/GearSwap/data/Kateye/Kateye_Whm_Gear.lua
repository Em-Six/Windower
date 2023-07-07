-- Setup vars that are user-dependent.  Can override this in a sidecar file.
function user_job_setup()
    state.OffenseMode:options('Normal')
    state.CastingMode:options('Normal','Resistant')
    state.IdleMode:options('Normal','DT')
	state.PhysicalDefenseMode:options('DT')
	state.MagicalDefenseMode:options('DT')
	state.ResistDefenseMode:options('EVA')
	state.HybridMode:options('Normal','DT')
	state.Weapons:options('None','DualWeapons','MeleeWeapons')
	state.AutoCaress = M(false, 'Auto Caress Mode')
	state.PWUnlock = M(true, 'PWUnlock')
	--sets.IdleWakeUp = {main="Prime Staff",}
	
	autows = "Black Halo"
	
	gear.cure_jse_cape = { name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','"Cure" potency +10%','Phys. dmg. taken-10%',}}
	gear.FC_jse_cape = { name="Alaunus's Cape", augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Fast Cast"+10',}}
	gear.TP_jse_cape = { name="Alaunus's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Phys. dmg. taken-10%',}}
	gear.MNDWS_jse_cape = { name="Alaunus's Cape", augments={'MND+20','Accuracy+20 Attack+20','MND+10','Weapon skill damage +10%','Phys. dmg. taken-10%',}}
	
    select_default_macro_book()
end

-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------

	-- Weapons sets
	sets.weapons.MeleeWeapons = {main="Maxentius",sub="Genmei Shield"}
	sets.weapons.DualWeapons = {main="Maxentius",sub="Sindri"}
	
    sets.buff.Sublimation = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}
	
    -- Precast Sets

    -- Fast cast sets for spells
    sets.precast.FC = { -- 84% Fast Cast & 11% Quick Cast
		main=gear.grioavolr_fc_staff, --11% FC
		sub="Clerisy Strap +1", -- 3% FC
		ammo="Impatiens", -- 2% QC
		head="Bunzi's Hat", -- 10% FC
		body="Inyanga Jubbah +2", -- 14% FC
		hands="Gende. Gages +1", -- 7% FC
		legs="Aya. Cosciales +2", -- 6% FC
		feet="Regal Pumps +1", -- 5~7% FC
		neck="Cleric's Torque +2", -- 10% FC
		waist="Witful Belt", -- 3% FC + 3% QC
		left_ear="Loquac. Earring", -- 2% FC
		right_ear="Malignance Earring", -- 4% FC
		left_ring="Kishar Ring", -- 4% FC
		right_ring="Weatherspoon Ring", -- 5% FC & 3% QC
		back="Perimede Cape", -- 4% QC
	}

    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {})
	
    sets.precast.FC.Stoneskin = set_combine(sets.precast.FC['Enhancing Magic'], {})

    sets.precast.FC['Healing Magic'] = set_combine(sets.precast.FC, {legs="Ebers Pant. +3"})

    sets.precast.FC.StatusRemoval = sets.precast.FC['Healing Magic']
	
    sets.precast.FC.Cure = set_combine(sets.precast.FC['Healing Magic'], {})

    sets.precast.FC.Curaga = sets.precast.FC.Cure

	sets.precast.FC.CureSolace = sets.precast.FC.Cure

	sets.precast.FC.Impact =  set_combine(sets.precast.FC, {head=empty,body="Twilight Cloak"})
	
	sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {main="Daybreak",sub="Genmei Shield"})

    -- Precast sets to enhance JAs
    sets.precast.JA.Benediction = {body="Piety Bliaut +3"}
    sets.precast.JA.Devotion = {body="Piety Cap +3"}

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {}

    -- Weaponskill sets

    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
	    ammo="Floestone",
		head="Nyame Helm",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets",
		neck="Clr. Torque +2",
		waist="Luminary Sash",
		left_ear="Moonshade Earring",
		right_ear="Regal Earring",
		left_ring="Metamorph Ring +1",
		right_ring="Rufescent Ring",
		back=gear.MNDWS_jse_cape,
	}
		
    sets.precast.WS.Dagan = {}
		
	sets.MaxTP = {ear1="Cessance Earring",ear2="Brutal Earring"}
	sets.MaxTP.Dagan = {ear1="Etiolation Earring",ear2="Evans Earring"}

    sets.precast.WS['Black Halo'] = sets.precast.WS

    --sets.precast.WS['Mystic Boon'] = {}

    -- Midcast Sets

    sets.Kiting = {feet="Herald's Gaiters"}
    sets.latent_refresh = {waist="Fucho-no-obi"}
	sets.latent_refresh_grip = {sub="Oneiros Grip"}
	sets.TPEat = {neck="Chrys. Torque"}
	sets.DayIdle = {}
	sets.NightIdle = {}
	sets.TreasureHunter = set_combine(sets.TreasureHunter, {})
	
	--Situational sets: Gear that is equipped on certain targets
	sets.Self_Healing = {}
	sets.Cure_Received = {}
	sets.Self_Refresh = {}

	-- Conserve Mp set for spells that don't need anything else, for set_combine.
	
	sets.ConserveMP = {main=gear.grioavolr_fc_staff,sub="Umbra Strap",ammo="Hasty Pinion +1",
		head=gear.vanya_head_pathb,neck="Incanter's Torque",ear1="Gifted Earring",ear2="Gwati Earring",
		body="Vedic Coat",hands="Fanatic Gloves",ring1="Kishar Ring",ring2="Prolix Ring",
		back="Solemnity Cape",waist="Austerity Belt +1",legs="Vanya Slops",feet="Medium's Sabots"}
		
	sets.midcast.Teleport = sets.ConserveMP
	
	-- Gear for Magic Burst mode.
    sets.MagicBurst = {main=gear.grioavolr_nuke_staff,sub="Enki Strap",neck="Mizu. Kubikazari",ring1="Mujin Band",ring2="Locus Ring"}
	
    sets.midcast.FastRecast = set_combine(sets.precast.FC, {ammo="Hasty Pinion +1"})
		
    -- Cure sets

	sets.midcast['Full Cure'] = sets.midcast.FastRecast
	
	-- Sets to define Solace/Weather Gear - Purely used as set combines
	sets.Solace = {body="Ebers Bliaut +3",back=gear.cure_jse_cape}
	sets.CureWeatherDay = {main="Chatoyant Staff", sub="Enki Strap", waist="Hachirin-no-Obi"}
	
	-- Normal Cure Sets
	sets.midcast.Cure = {
		main="Queller Rod",
		sub="Thuellaic Ecu +1",
		ammo="Pemphredo Tathlum",
		head="Kaykaus Mitra +1",
		body="Kaykaus Bliaut +1",
		hands="Theophany Mitts +3",
		legs="Ebers Pant. +3",
		feet="Kaykaus Boots +1",
		neck="Clr. Torque +2",
		waist="Austerity Belt +1",
		left_ear="Glorious Earring",
		right_ear="Mendicant's Earring", 
		left_ring="Naji's Loop",
		right_ring="Mephitas's ring +1",
		back=gear.cure_jse_cape, -- Need Fi Follet Cape
	}
	
	sets.midcast.LightWeatherCure = set_combine(sets.midcast.Cure, sets.CureWeatherDay, {})
	sets.midcast.LightDayCure = set_combine(sets.midcast.Cure, sets.CureWeatherDay, {})
	
	sets.midcast.CureSolace = set_combine(sets.midcast.Cure, sets.Solace, {})
	sets.midcast.LightWeatherCureSolace = set_combine(sets.midcast.CureSolace, sets.CureWeatherDay, {})
	sets.midcast.LightDayCureSolace = set_combine(sets.midcast.CureSolace, sets.CureWeatherDay, {})
	
	sets.midcast.Curaga = set_combine(sets.midcast.Cure, {})
	sets.midcast.LightWeatherCuraga = set_combine(sets.midcast.Curaga, sets.CureWeatherDay, {})
	sets.midcast.LightDayCuraga = set_combine(sets.midcast.Curaga, sets.CureWeatherDay, {})

	--DT Cure sets
	sets.midcast.Cure.DT = set_combine(sets.midcast.Cure, {})
	sets.midcast.LightWeatherCure.DT = set_combine(sets.midcast.Cure.DT, sets.CureWeatherDay, {})
	sets.midcast.LightDayCure.DT = set_combine(sets.midcast.Cure.DT, sets.CureWeatherDay, {})
	
	sets.midcast.CureSolace.DT = set_combine(sets.midcast.Cure.DT, sets.Solace, {})
	sets.midcast.LightWeatherCureSolace.DT = set_combine(sets.midcast.CureSolace.DT, sets.CureWeatherDay, {})
	sets.midcast.LightDayCureSolace.DT = set_combine(sets.midcast.CureSolace.DT, sets.CureWeatherDay, {})
	
	sets.midcast.Curaga.DT = set_combine(sets.midcast.Cure.DT, {})
	sets.midcast.LightWeatherCuraga.DT = set_combine(sets.midcast.Cure.DT, sets.CureWeatherDay, {})
	sets.midcast.LightDayCuraga.DT = set_combine(sets.midcast.Cure.DT, sets.CureWeatherDay, {})
	

	--Melee Curesets are used whenever your Weapons state is set to anything but None.
	sets.midcast.MeleeCure = sets.midcast.Cure
	sets.midcast.MeleeLightWeatherCure = set_combine(sets.midcast.MeleeCure, sets.CureWeatherDay, {})
	sets.midcast.MeleeLightDayCure = set_combine(sets.midcast.MeleeCure, sets.CureWeatherDay, {})
	
	sets.midcast.MeleeCureSolace = set_combine(sets.midcast.MeleeCure, sets.Solace, {})
	sets.midcast.MeleeLightWeatherCureSolace = set_combine(sets.midcast.MeleeCureSolace, sets.CureWeatherDay, {})
	sets.midcast.MeleeLightDayCureSolace = set_combine(sets.midcast.MeleeCureSolace, sets.CureWeatherDay, {})
	
	sets.midcast.MeleeCuraga = set_combine(sets.midcast.Curaga, {})
	sets.midcast.MeleeLightWeatherCuraga = set_combine(sets.midcast.MeleeCuraga, sets.CureWeatherDay, {})
	sets.midcast.MeleeLightDayCuraga = set_combine(sets.midcast.MeleeCuraga, sets.CureWeatherDay, {})
	
	-- Melee DT sets
	sets.midcast.MeleeCure.DT = set_combine(sets.midcast.Cure.DT, {})
	sets.midcast.MeleeLightWeatherCure.DT = set_combine(sets.midcast.MeleeCure.DT, sets.CureWeatherDay, {})
	sets.midcast.MeleeLightDayCure.DT = set_combine(sets.midcast.MeleeCure.DT, sets.CureWeatherDay, {})
	
	sets.midcast.MeleeCureSolace.DT = set_combine(sets.midcast.MeleeCure.DT, sets.Solace, {})
	sets.midcast.MeleeLightWeatherCureSolace.DT = set_combine(sets.midcast.MeleeCureSolace.DT, sets.CureWeatherDay, {})
	sets.midcast.MeleeLightDayCureSolace.DT = set_combine(sets.midcast.MeleeCureSolace.DT, sets.CureWeatherDay, {})
	
	sets.midcast.MeleeCuraga.DT = set_combine(sets.midcast.Cure.DT, {})
	sets.midcast.MeleeLightWeatherCuraga.DT = set_combine(sets.midcast.MeleeCuraga.DT, sets.CureWeatherDay, {})
	sets.midcast.MeleeLightDayCuraga.DT = set_combine(sets.midcast.MeleeCuraga.DT, sets.CureWeatherDay, {})

	sets.midcast.Cursna = {    
		main="Yagrush",
		sub="Thuellaic Ecu +1",
		ammo="Hasty Pinion +1",
		head=gear.vanya_head_pathb, 
		body="Ebers Bliaut +3",
		hands="Fanatic Gloves", -- Need perfect augments
		legs="Th. Pantaloons +2", -- Need +3
		feet=gear.vanya_feet_pathb, 
		neck="Debilis Medallion", 
		waist="Witful Belt", -- Need Bishop's Sash
		left_ear="Meili Earring",
		right_ear="Healing Earring", 
		left_ring="Menelaus's Ring",
		right_ring="Haoma's Ring",
		back=gear.FC_jse_cape,
	}

	sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {main="Yagrush",sub="Thuellaic Ecu +1"})
		
	sets.midcast.Erase = set_combine(sets.midcast.StatusRemoval, {neck="Cleric's Torque +2"})

    -- 110 total Enhancing Magic Skill; caps even without Light Arts
	sets.midcast['Enhancing Magic'] = {main=gear.gada_enhancing_club,sub="Ammurapi Shield",ammo="Hasty Pinion +1",
		head=gear.telchine_enhancing_head,neck="Incanter's Torque",ear1="Andoaa Earring",ear2="Mimir Earring",
		body=gear.telchine_enhancing_body,hands=gear.telchine_enhancing_hands,ring1="Stikini Ring +1",ring2="Stikini Ring +1",
		back="Perimede Cape",waist="Embla Sash",legs=gear.telchine_enhancing_legs,feet=gear.telchine_enhancing_feet}

	sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {neck="Nodens Gorget",ear2="Earthcry Earring",waist="Siegel Sash",legs="Shedir Seraweels"})

	sets.midcast.Auspice = set_combine(sets.midcast['Enhancing Magic'], {feet="Ebers Duckbills +1"})

	sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'], {hands="Regal Cuffs",waist="Emphatikos Rope"})

	sets.midcast.Regen = set_combine(sets.midcast['Enhancing Magic'], {main="Bolelabunga",head="Inyanga Tiara +2",body="Piety Bliaut +3",hands="Ebers Mitts +1",legs="Th. Pantaloons +2"})
	
	sets.midcast.Protect = set_combine(sets.midcast['Enhancing Magic'], {})
	sets.midcast.Protectra = set_combine(sets.midcast['Enhancing Magic'], {})
	sets.midcast.Shell = set_combine(sets.midcast['Enhancing Magic'], {})
	sets.midcast.Shellra = set_combine(sets.midcast['Enhancing Magic'], {})
	
	sets.midcast.BarElement = {main="Beneficus",sub="Ammurapi Shield",ammo="Staunch Tathlum +1",
		head="Ebers Cap +1",neck="Incanter's Torque",ear1="Andoaa Earring",ear2="Gifted Earring",
		body="Ebers Bliaut +3",hands="Ebers Mitts +1",ring1="Stikini Ring +1",ring2="Stikini Ring +1",
		back="Alaunus's Cape",waist="Olympus Sash",legs="Piety Pantaln. +3",feet="Ebers Duckbills +1"}


----------------------- Nuking Sets
	sets.midcast.Impact = {main="Daybreak",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
		head=empty,neck="Erra Pendant",ear1="Regal Earring",ear2="Digni. Earring",
		body="Twilight Cloak",hands=gear.chironic_enfeeble_hands,ring1="Metamor. Ring +1",ring2="Stikini Ring +1",
		back="Toro Cape",waist="Acuity Belt +1",legs="Chironic Hose",feet=gear.chironic_nuke_feet}
		
	sets.midcast['Elemental Magic'] = {main="Daybreak",sub="Ammurapi Shield",ammo="Dosis Tathlum",
		head="C. Palug Crown",neck="Baetyl Pendant",ear1="Regal Earring",ear2="Friomisi Earring",
		body="Witching Robe",hands=gear.chironic_enfeeble_hands,ring1="Shiva Ring +1",ring2="Freke Ring",
		back="Toro Cape",waist=gear.ElementalObi,legs="Chironic Hose",feet=gear.chironic_nuke_feet}

	sets.midcast['Elemental Magic'].Resistant = {main="Daybreak",sub="Ammurapi Shield",ammo="Dosis Tathlum",
		head="C. Palug Crown",neck="Sanctity Necklace",ear1="Regal Earring",ear2="Crematio Earring",
		body="Witching Robe",hands=gear.chironic_enfeeble_hands,ring1="Metamor. Ring +1",ring2="Freke Ring",
		back="Toro Cape",waist="Yamabuki-no-Obi",legs="Chironic Hose",feet=gear.chironic_nuke_feet}

	sets.midcast['Divine Magic'] = {    
		main="Daybreak",
		sub="Ammurapi Shield",
		ammo="Ghastly Tathlum +1",
		head="Bunzi's Hat",
		body="Bunzi's Robe",
		hands="Bunzi's Gloves",
		legs="Bunzi's Pants",
		feet="Bunzi's Sabots",
		neck="Sibyl Scarf",
		waist="Skrymir Cord +1",
		left_ear="Regal Earring",
		right_ear="Malignance Earring",
		left_ring="Weather. Ring",
		right_ring="Metamorph Ring +1",
		back=gear.FC_jse_cape,
	}
		
	sets.midcast.Holy = sets.midcast['Divine Magic']
	
	sets.midcast['Dark Magic'] = {main="Daybreak",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
		head="Befouled Crown",neck="Erra Pendant",ear1="Regal Earring",ear2="Digni. Earring",
		body="Inyanga Jubbah +2",hands=gear.chironic_enfeeble_hands,ring1="Stikini Ring +1",ring2="Stikini Ring +1",
		back="Aurist's Cape +1",waist="Acuity Belt +1",legs="Chironic Hose",feet=gear.chironic_nuke_feet}

    sets.midcast.Drain = {main="Rubicundity",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Pixie Hairpin +1",neck="Erra Pendant",ear1="Regal Earring",ear2="Digni. Earring",
        body="Inyanga Jubbah +2",hands=gear.chironic_enfeeble_hands,ring1="Evanescence Ring",ring2="Archon Ring",
        back="Aurist's Cape +1",waist="Fucho-no-obi",legs="Chironic Hose",feet=gear.chironic_nuke_feet}

    sets.midcast.Drain.Resistant = {main="Rubicundity",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Befouled Crown",neck="Erra Pendant",ear1="Regal Earring",ear2="Digni. Earring",
        body="Chironic Doublet",hands=gear.chironic_enfeeble_hands,ring1="Stikini Ring +1",ring2="Stikini Ring +1",
        back="Aurist's Cape +1",waist="Fucho-no-obi",legs="Chironic Hose",feet=gear.chironic_nuke_feet}

    sets.midcast.Aspir = sets.midcast.Drain
	sets.midcast.Aspir.Resistant = sets.midcast.Drain.Resistant


	sets.midcast['Enfeebling Magic'] = {    
		main="Bunzi's Rod",
		sub="Ammurapi Shield",
		ammo="Pemphredo Tathlum",
		head="Theophany Cap +2",
		body="Theo. Bliaut +2",
		hands="Regal Cuffs",
		legs=gear.chironic_enfeebling_legs,
		feet="Theo. Duckbills +2",
		neck="Erra Pendant",
		waist="Luminary Sash",
		left_ear="Malignance Earring",
		right_ear="Regal Earring",
		left_ring="Kishar Ring",
		right_ring=gear.stikini2,
		back=gear.FC_jse_cape,
	}

	sets.midcast['Enfeebling Magic'].Resistant = set_combine(sets.midcast['Enfeebling Magic'], {hands="Theophany Mitts +3",left_ring=gear.stikini2,})
		
	sets.midcast.Stun = sets.midcast['Enfeebling Magic']

	sets.midcast.Stun.Resistant = sets.midcast['Enfeebling Magic'].Resistant
		
	sets.midcast.Dispel = sets.midcast['Enfeebling Magic'].Resistant
		
	sets.midcast.Dispelga = set_combine(sets.midcast.Dispel, {main="Daybreak",sub="Ammurapi Shield"})	
	
	sets.midcast.Dia = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	sets.midcast.Diaga = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	sets.midcast['Dia II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	sets.midcast.Bio = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	sets.midcast['Bio II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)

    sets.midcast.ElementalEnfeeble = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.ElementalEnfeeble.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})

	sets.midcast.IntEnfeebles = set_combine(sets.midcast['Enfeebling Magic'])
	sets.midcast.IntEnfeebles.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant)

	sets.midcast.MndEnfeebles = set_combine(sets.midcast['Enfeebling Magic'])
	sets.midcast.MndEnfeebles.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant)

    -- Sets to return to when not performing an action.

    -- Resting sets
	sets.resting = sets.idle

    -- Idle sets (default idle set not needed since the other three are defined, but leaving for testing purposes)
	sets.idle = {
		main="Malignance Pole",
		sub="Oneiros Grip",
		ammo="Staunch Tathlum",
		head="Inyanga Tiara +2",
		body="Shamash Robe",
		hands="Inyan. Dastanas +2",
		legs="Inyanga Shalwar +2",
		feet="Inyan. Crackows +2",
		neck="Loricate Torque +1",
		waist="Carrier's Sash",
		left_ear="Hearty Earring",
		right_ear="Etiolation Earring",
		left_ring=gear.stikini1,
		right_ring=gear.stikini2,
		back=gear.cure_jse_cape,
	}

	sets.idle.DT = {
		main="Malignance Pole",
		sub="Oneiros Grip",
		ammo="Staunch Tathlum",
		head="Nyame Helm",
		body="Shamash Robe",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets",
		neck="Loricate Torque +1",
		waist="Carrier's Sash",
		left_ear="Hearty Earring",
		right_ear="Etiolation Earring",
		left_ring="Stikini Ring +1",
		right_ring="Stikini Ring +1",
		back=gear.cure_jse_cape,
	}
		
	sets.idle.MDT = set_combine(sets.idle, {})
		
	sets.idle.Weak = set_combine(sets.idle, {})

    -- Defense sets

	sets.defense.PDT = {		
		main="Malignance Pole",
		sub="Oneiros Grip",
		ammo="Staunch Tathlum",
		head="Nyame Helm",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets",
		neck="Loricate Torque +1",
		waist="Carrier's Sash",
		left_ear="Hearty Earring",
		right_ear="Etiolation Earring",
		left_ring=gear.stikini1,
		right_ring=gear.stikini2,
		back=gear.cure_jse_cape,}

	sets.defense.MDT = {main="Mafic Cudgel",sub="Genmei Shield",ammo="Staunch Tathlum +1",
		head="Gende. Caubeen +1",neck="Loricate Torque +1",ear1="Etiolation Earring",ear2="Sanare Earring",
		body="Inyanga Jubbah +2",hands=gear.chironic_refresh_hands,ring1="Defending Ring",ring2="Shadow Ring",
		back="Moonlight Cape",waist="Flax Sash",legs="Th. Pant. +3",feet="Gende. Galosh. +1"}

    sets.defense.MEVA = {ammo="Staunch Tathlum +1",
        head="Telchine Cap",neck="Warder's Charm +1",ear1="Etiolation Earring",ear2="Sanare Earring",
		body="Inyanga Jubbah +2",hands="Telchine Gloves",ring1="Vengeful Ring",Ring2="Purity Ring",
        back="Aurist's Cape +1",waist="Luminary Sash",legs="Telchine Braconi",feet="Telchine Pigaches"}
		
		-- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion

    -- Basic set for if no TP weapon is defined.
    sets.engaged = {
		main="Maxentius",
		sub="Genmei Shield",
	    ammo="Amar Cluster",
		head="Aya. Zucchetto +2",
		body="Ayanmo Corazza +2",
		hands="Bunzi's Gloves",
		legs="Aya. Cosciales +2",
		feet="Nyame Sollerets",
		neck="Lissome Necklace",
		waist="Windbuffet Belt +1",
		left_ear="Crep. Earring",
		right_ear="Brutal Earring",
		left_ring="Chirich Ring +1",
		right_ring="Chirich Ring +1",
		back=gear.TP_jse_cape,
	}

	sets.engaged.DW = set_combine(sets.engaged, {sub="Sindri",left_ear="Suppanomimi"})

		-- Buff sets: Gear that needs to be worn to actively enhance a current player buff.
    sets.buff['Divine Caress'] = {hands="Ebers Mitts +1",back="Mending Cape"}

	sets.HPDown = {head="Pixie Hairpin +1",ear1="Mendicant's Earring",ear2="Evans Earring",
		body="Zendik Robe",hands="Hieros Mittens",ring1="Mephitas's Ring +1",ring2="Mephitas's Ring",
		back="Swith Cape +1",waist="Flax Sash",legs="Shedir Seraweels",feet=""}

	sets.HPCure = {main="Queller Rod",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
		head="Blistering Sallet +1",neck="Nodens Gorget",ear1="Etiolation Earring",ear2="Ethereal Earring",
		body="Kaykaus Bliaut",hands="Kaykaus Cuffs",ring1="Kunaji Ring",ring2="Meridian Ring",
		back="Alaunus's Cape",waist="Eschan Stone",legs="Ebers Pant. +3",feet="Kaykaus Boots"}

	sets.buff.Doom = set_combine(sets.buff.Doom, {})
	sets.buff.Sleep = set_combine(sets.idle.DT, {main="Prime Maul", sub="Genmei Shield"})
	sets.IdleWakeUp = sets.buff.Sleep

end

buff_spell_lists = {
	Auto = {--Options for When are: Always, Engaged, Idle, OutOfCombat, Combat
		{Name='Reraise IV',		Buff='Reraise',		SpellID=848,	When='Always'},
		{Name='Haste',			Buff='Haste',		SpellID=57,		When='Always'},
		{Name='Aurorastorm',	Buff='Aurorastorm',	SpellID=119,	When='Always'},
		{Name='Refresh',		Buff='Refresh',		SpellID=109,	When='Always'},
	},
	Default = {
		{Name='Reraise IV',		Buff='Reraise',		SpellID=848,	Reapply=false},
		{Name='Haste',			Buff='Haste',		SpellID=57,		Reapply=false},
		{Name='Aquaveil',		Buff='Aquaveil',	SpellID=55,		Reapply=false},
		{Name='Stoneskin',		Buff='Stoneskin',	SpellID=54,		Reapply=false},
		{Name='Blink',			Buff='Blink',		SpellID=53,		Reapply=false},
		{Name='Regen IV',		Buff='Regen',		SpellID=477,	Reapply=false},
		{Name='Phalanx',		Buff='Phalanx',		SpellID=106,	Reapply=false},
		{Name='Boost-MND',		Buff='MND Boost',	SpellID=484,	Reapply=false},
		{Name='Shellra V',		Buff='Shell',		SpellID=134,	Reapply=false},
		{Name='Protectra V',	Buff='Protect',		SpellID=129,	Reapply=false},
		{Name='Barthundra',		Buff='Barthunder',	SpellID=70,		Reapply=false},
		{Name='Barparalyzra',	Buff='Barparalyze',	SpellID=88,		Reapply=false},
	},
	Melee = {
		{Name='Reraise IV',		Buff='Reraise',		SpellID=848,	Reapply=false},
		{Name='Haste',			Buff='Haste',		SpellID=57,		Reapply=false},
		{Name='Boost-STR',		Buff='STR Boost',	SpellID=479,	Reapply=false},
		{Name='Shellra V',		Buff='Shell',		SpellID=134,	Reapply=false},
		{Name='Protectra V',	Buff='Protect',		SpellID=129,	Reapply=false},
		{Name='Auspice',		Buff='Auspice',		SpellID=96,		Reapply=false},
	},
}

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
	set_macro_page(1, 2)
end

function user_job_lockstyle()
	windower.chat.input('/lockstyleset 004')
end