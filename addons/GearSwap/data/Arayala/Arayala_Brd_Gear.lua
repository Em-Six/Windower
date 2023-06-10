function user_job_setup()
	-- Options: Override default values
    state.OffenseMode:options('Normal','Acc')
    state.CastingMode:options('Normal','Resistant','Ody')
    state.IdleMode:options('Normal','Ody')
	state.Weapons:options('DualCentovente','DualNaegling','Carnwenhan','Naegling','Evisceration','Aeolian','Xoanon')
	
	autows = "Mordant Rime"
	autowstp = 1000
	
	-- Whether to use Carn (or song daggers in general) under a certain threshhold even when weapons are locked.
	state.CarnMode = M{'Always','300','1000','Never'}

	-- Adjust this if using the Terpander (new +song instrument)
    info.ExtraSongInstrument = 'Daurdabla'
	-- How many extra songs we can keep from Daurdabla/Terpander
    info.ExtraSongs = 2
	
	-- Set this to false if you don't want to use custom timers.
    state.UseCustomTimers = M(false, 'Use Custom Timers')
	
	gear.dt_jse_back = { name="Intarabus's Cape", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Evasion+10','Enmity-10','Evasion+15',}}
	gear.fc_macc_jse_back = { name="Intarabus's Cape", augments={'CHR+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Fast Cast"+10',}}
	gear.tp_jse_back =  { name="Intarabus's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Phys. dmg. taken-10%',}}
	gear.str_wsd_jse_back = { name="Intarabus's Cape", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}}
	gear.chr_wsd_jse_back = { name="Intarabus's Cape", augments={'CHR+20','Accuracy+20 Attack+20','Weapon skill damage +10%',}} -- Need Dye Augment
	gear.aeolain_jse_back = { name="Intarabus's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','Weapon skill damage +10%','Phys. dmg. taken-10%',}}
	gear.dex_crit_jse_back = { name="Intarabus's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Crit.hit rate+10',}} -- Need Dye + Resin Augments
	
	
	gear.Kali_Refresh = { name="Kali", augments={'MP+60','Mag. Acc.+20','"Refresh"+1',}}
	gear.Kali_Skill = { name="Kali", augments={'Mag. Acc.+15','String instrument skill +10','Wind instrument skill +10',}}
	
	gear.Linos_TP = { name="Linos", augments={'Accuracy+15 Attack+15','"Dbl.Atk."+3','Quadruple Attack +3',}}
	gear.Linos_STR_WSD = { name="Linos", augments={'Accuracy+14 Attack+14','Weapon skill damage +3%','STR+8',}}
	gear.Linos_Eva_Idle = { name="Linos", augments={'Evasion+14','Phys. dmg. taken -4%',}}
	
	
	
	select_default_macro_book()
end

function job_filtered_action(spell, eventArgs)
	if spell.type == 'WeaponSkill' then
		local available_ws = S(windower.ffxi.get_abilities().weapon_skills)
		-- WS 112 is Double Thrust, meaning a Spear is equipped.
		if available_ws:contains(32) then
            if spell.english == "Mordant Rime" then
				windower.chat.input('/ws "Savage Blade" '..spell.target.raw)
                cancel_spell()
				eventArgs.cancel = true
            end
        end
		if available_ws:contains(189) then
            if spell.english == "Mordant Rime" then
				windower.chat.input('/ws "Retribution" '..spell.target.raw)
                cancel_spell()
				eventArgs.cancel = true
            end
        end
	end
end

function init_gear_sets()

	--------------------------------------
	-- Start defining the sets
	--------------------------------------

	-- Weapons sets
	sets.weapons.DualCentovente = {main="Naegling",sub="Centovente"}
	sets.weapons.DualNaegling = {main="Naegling",sub="Gleti's Knife"}
	sets.weapons.Carnwenhan = {main="Carnwenhan",sub="Gleti's Knife"}
	sets.weapons.Naegling = {main="Naegling",sub="Genmei Shield"}
	sets.weapons.Ody = {main="Nibiru Knife",sub="Genmei Shield"}
	sets.weapons.Evisceration = {main="Tauret",sub="Gleti's Knife"}
	sets.weapons.Aeolian = {main="Tauret",sub="Centovente"}
	sets.weapons.Domain = {main="Voluspa Knife",sub="Gleti's Knife"}
	sets.weapons.Xoanon = {main="Xoanon",sub="Rigorous Grip +1"}

    sets.buff.Sublimation = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}
	
	-- Precast Sets

	-- Fast cast sets for spells
	sets.precast.FC = {main=gear.Kali_Refresh,sub=gear.Kali_Skill,ammo="Impatiens",
		head="Vanya Hood",neck="Voltsurge Torque",ear1="Loquac. Earring",ear2="Etiolation Earring",
		body="Inyanga Jubbah +2",hands="Gende. Gages +1",ring1="Kishar Ring",ring2="Weatherspoon Ring",
		back=gear.fc_macc_jse_back,waist="Embla Sash",legs="Aya. Cosciales +2",feet="Fili Cothurnes +2"}

	sets.precast.FC.Cure = sets.precast.FC

	sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {main="Daybreak",sub="Genmei Shield"})
	
	sets.precast.FC.BardSong = sets.precast.FC

	sets.precast.FC.SongDebuff = set_combine(sets.precast.FC.BardSong,{range="Marsyas"})
	sets.precast.FC.SongDebuff.Resistant = set_combine(sets.precast.FC.BardSong,{range="Gjallarhorn"})
	sets.precast.FC.Lullaby = {range="Blurred Harp +1"}
	sets.precast.FC.Lullaby.Resistant = {range="Blurred Harp +1"}
	sets.precast.FC['Horde Lullaby'] = {range="Blurred Harp +1"}
	sets.precast.FC['Horde Lullaby'].Resistant = {range="Blurred Harp +1"}
	sets.precast.FC['Horde Lullaby'].AoE = {range="Blurred Harp +1"}
	sets.precast.FC['Horde Lullaby II'] = {range="Blurred Harp +1"}
	sets.precast.FC['Horde Lullaby II'].Resistant = {range="Blurred Harp +1"}
	sets.precast.FC['Horde Lullaby II'].AoE = {range="Blurred Harp +1"}
		
	sets.precast.FC.Mazurka = set_combine(sets.precast.FC.BardSong,{range="Marsyas"})
	sets.precast.FC['Honor March'] = set_combine(sets.precast.FC.BardSong,{range="Marsyas"})
	sets.precast.FC['Magic Finale'] = set_combine(sets.precast.FC.BardSong,{range="Gjallarhorn"})

	sets.precast.FC.Daurdabla = set_combine(sets.precast.FC.BardSong, {range=info.ExtraSongInstrument})
	sets.precast.DaurdablaDummy = sets.precast.FC.Daurdabla
		
	
	-- Precast sets to enhance JAs
	
	sets.precast.JA.Nightingale = {feet="Bihu Slippers +3"}
	sets.precast.JA.Troubadour = {body="Bihu Justaucorps +3"}
	sets.precast.JA['Soul Voice'] = {legs="Bihu Cannions +3"}

	-- Waltz set (chr and vit)
	sets.precast.Waltz = {}

	-- Weaponskill sets
	-- Default set for any weaponskill that isn't any more specifically defined
	sets.precast.WS = {		
		range=gear.Linos_STR_WSD,
		head="Nyame Helm",
		body="Bihu Justaucorps +3",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets",
		neck="Bard's Charm +2",
		waist="Sailfi Belt +1",
		left_ear="Moonshade Earring",
		right_ear="Ishvara Earring",
		left_ring="Cornelia's Ring",
		right_ring="Sroda Ring",
		back=gear.str_wsd_jse_back,
	}
				
	-- Swap to these on Moonshade using WS if at 3000 TP
	sets.MaxTP = {ear1="Telos Earring", ear2="Ishvara Earring",}
	sets.AccMaxTP = {ear1="Mache Earring +1",ear2="Telos Earring"}

	-- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.

	sets.precast.WS['Savage Blade'] = {
		range=gear.Linos_STR_WSD,
		head="Nyame Helm",
		body="Bihu Justaucorps +3",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets",
		neck="Republican platinum medal",
		waist="Sailfi Belt +1",
		left_ear="Moonshade Earring",
		right_ear="Ishvara Earring",
		left_ring="Sroda Ring",
		right_ring="Cornelia's Ring",
		back=gear.str_wsd_jse_back,
	}
	
	sets.precast.WS['Aeolian Edge'] = {
		range=gear.Linos_STR_WSD,
		head="Nyame Helm",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets",
		neck="Sibyl Scarf",
		waist="Eschan Stone",
		left_ear="Moonshade Earring",
		right_ear="Friomisi Earring",
		left_ring=gear.shiva1,
		right_ring="Cornelia's Ring",
		back=gear.aeolain_jse_back, 
	}

	sets.precast.WS['Evisceration'] = {
	    range=gear.Linos_TP,
		head="Blistering Sallet +1",
		body="Ayanmo Corazza +2",
		hands="Bunzi's Gloves",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets",
		neck="Soil Gorget",
		waist="Flume Belt",
		left_ear="Telos Earring",
		right_ear="Brutal Earring",
		left_ring="Moonlight Ring", -- Need Illabrat Ring
		right_ring="Cornelia's Ring", -- Need Begrudging ring or a DEX ring
		back=gear.dex_crit_jse_back,
	}
	
	sets.precast.WS['Mordant Rime'] = {
	    range=gear.Linos_STR_WSD, -- Need CHR Linos
		head="Nyame Helm",
		body="Bihu Justaucorps +3",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets",
		neck="Bard's Charm +2",
		waist="Sailfi Belt +1", 
		left_ear="Regal Earring", 
		right_ear="Ishvara Earring",
		left_ring="Metamorph Ring +1",
		right_ring="Cornelia's Ring", 
		back=gear.chr_wsd_jse_back, -- Needs augmenting
	}
	
	-- Midcast Sets

	-- General set for recast times.
	sets.midcast.FastRecast = {main=gear.grioavolr_fc_staff,sub="Clerisy Strap +1",ammo="Hasty Pinion +1",
		head="Nahtirah Hat",neck="Voltsurge Torque",ear1="Enchntr. Earring +1",ear2="Loquac. Earring",
		body="Inyanga Jubbah +2",hands="Leyline Gloves",ring1="Kishar Ring",ring2="Lebeche Ring",
		back=gear.fc_macc_jse_back,waist="Witful Belt",legs="Aya. Cosciales +2",feet="Gende. Galosh. +1"}

	-- Gear to enhance certain classes of songs
	sets.midcast.Ballad = {legs="Fili Rhingrave +2"}
	--sets.midcast.Ballad = {}
	sets.midcast.Lullaby = {range="Blurred Harp +1"}
	sets.midcast.Lullaby.Resistant = {range="Blurred Harp +1"}
	sets.midcast['Horde Lullaby'] = {range="Blurred Harp +1"}
	sets.midcast['Horde Lullaby'].Resistant = {range="Blurred Harp +1"}
	sets.midcast['Horde Lullaby'].AoE = {range="Blurred Harp +1"}
	sets.midcast['Horde Lullaby II'] = {range="Blurred Harp +1"}
	sets.midcast['Horde Lullaby II'].Resistant = {range="Blurred Harp +1"}
	sets.midcast['Horde Lullaby II'].AoE = {range="Blurred Harp +1"}
	sets.midcast.Madrigal = {head="Fili Calot +2"}
	sets.midcast.Paeon = {}
	sets.midcast.March = {hands="Fili Manchettes +2"}
	sets.midcast['Honor March'] = set_combine(sets.midcast.March,{range="Marsyas"})
	sets.midcast.Minuet = {body="Fili Hongreline +2"}
	sets.midcast.Minne = {}
	sets.midcast.Carol = {}
	sets.midcast.Mambo = {feet="Mousai Crackows +1"}
	sets.midcast.Etude = {head="Mousai Turban +1"}
	sets.midcast["Sentinel's Scherzo"] = {feet="Fili Cothurnes +2"}
	sets.midcast['Magic Finale'] = {range="Gjallarhorn"}
	sets.midcast['Shining Fantasia'] = set_combine(sets.precast.FC,{range="Daurdabla"})
	sets.midcast['Fowl Aubade'] = set_combine(sets.precast.FC,{range="Daurdabla"})
	sets.midcast['Scop\'s Operetta'] = {range="Daurdabla"}
	sets.midcast.Mazurka = {range="Marsyas"}
	

	-- For song buffs (duration and AF3 set bonus)
	sets.midcast.SongEffect = {
		main="Carnwenhan",
		sub="Genmei Shield",
		range="Gjallarhorn",
		ammo=empty,
		head="Fili Calot +2",
		neck="Mnbw. Whistle +1",
		ear1="Enchntr. Earring +1",
		ear2="Bragi Earring",
		body="Fili Hongreline +2",
		hands="Fili Manchettes +2",
		ring1=gear.stikini1,
		ring2=gear.stikini2,
		back=gear.fc_macc_jse_back,
		waist="Corvax Sash",
		legs="Inyanga Shalwar +2",
		feet="Brioso Slippers +3"
	}
		
	sets.midcast.SongEffect.DW = {main="Carnwenhan",sub=gear.Kali_Skill}

	-- For song defbuffs (duration primary, accuracy secondary)
	sets.midcast.SongDebuff = {    
		main="Carnwenhan",
		sub="Genmei Shield",
		range="Gjallarhorn",
		head="Brioso Roundlet +3",
		body="Brioso Justau. +3",
		hands="Inyan. Dastanas +2",
		legs="Inyanga Shalwar +2",
		feet="Brioso Slippers +3",
		neck="Mnbw. Whistle +1",
		waist="Luminary Sash",
		left_ear="Crep. Earring",
		right_ear="Bragi Earring",
		left_ring=gear.stikini1,
		right_ring=gear.stikini2,
		back=gear.fc_macc_jse_back,
	}
		
	sets.midcast.SongDebuff.DW = {main="Carnwenhan",sub=gear.Kali_Skill}

	-- For song defbuffs (accuracy primary, duration secondary)
	sets.midcast.SongDebuff.Resistant = {    
		main="Carnwenhan",
		sub="Genmei Shield",
		range="Gjallarhorn",
		head="Brioso Roundlet +3",
		body="Brioso Justau. +3",
		hands="Inyan. Dastanas +2",
		legs="Brioso Cannions +3",
		feet="Brioso Slippers +3",
		neck="Mnbw. Whistle +1",
		waist="Luminary Sash",
		left_ear="Gwati Earring",
		right_ear="Hermetic Earring",
		left_ring=gear.stikini1,
		right_ring=gear.stikini2,
		back=gear.fc_macc_jse_back,
	}

	sets.midcast.SongDebuff.Ody = set_combine(sets.midcast.SongDebuff, {head="Nyame Helm", body="Nyame Mail", hands="Nyame Gauntlets", legs="Nyame Flanchard", feet="Nyame Sollerets"})
	
	-- Song-specific recast reduction
	sets.midcast.SongRecast = {main=gear.grioavolr_fc_staff,sub="Clerisy Strap +1",range="Blurred Harp +1",ammo=empty,
		head="Nahtirah Hat",neck="Voltsurge Torque",ear1="Enchntr. Earring +1",ear2="Loquac. Earring",
		body="Inyanga Jubbah +2",hands="Gendewitha Gages +1",ring1="Kishar Ring",ring2="Prolix Ring",
		back=gear.fc_macc_jse_back,waist="Witful Belt",legs="Fili Rhingrave +2",feet="Aya. Gambieras +2"}
		
	sets.midcast.SongDebuff.DW = {main="Carnwenhan",sub=gear.Kali_Skill}

	-- Cast spell with normal gear, except using Daurdabla instead
    sets.midcast.Daurdabla = {range=info.ExtraSongInstrument}

	-- Dummy song with Daurdabla; minimize duration to make it easy to overwrite.
    sets.midcast.DaurdablaDummy = set_combine(sets.midcast.SongRecast, {range=info.ExtraSongInstrument})

	-- Other general spells and classes.
	sets.midcast.Cure = {main="Serenity",sub="Curatio Grip",ammo="Pemphredo Tathlum",
        head="Vanya Hood",neck="Incanter's Torque",ear1="Gifted Earring",ear2="Mendi. Earring",
        body="Kaykaus Bliaut",hands="Kaykaus Cuffs",ring1="Janniston Ring",ring2="Menelaus's Ring",
        back="Tempered Cape +1",waist="Luminary Sash",legs="Carmine Cuisses +1",feet="Vanya Clogs"}
		
	sets.midcast.Curaga = sets.midcast.Cure
		
	sets.Self_Healing = {neck="Phalaina Locket",hands="Buremte Gloves",ring2="Kunaji Ring",waist="Gishdubar Sash"}
	sets.Cure_Received = {neck="Phalaina Locket",hands="Buremte Gloves",ring2="Kunaji Ring",waist="Gishdubar Sash"}
	sets.Self_Refresh = {back="Grapevine Cape",waist="Gishdubar Sash"}
		
	sets.midcast['Enhancing Magic'] = {main="Serenity",sub="Fulcio Grip",ammo="Hasty Pinion +1",
		head=gear.telchine_enhancing_head,neck="Voltsurge Torque",ear1="Andoaa Earring",ear2="Gifted Earring",
		body=gear.telchine_enhancing_body,hands=gear.telchine_enhancing_hands,ring1=gear.stikini1,ring2=gear.stikini2,
		back="Intarabus's Cape",waist="Embla Sash",legs=gear.telchine_enhancing_legs,feet=gear.telchine_enhancing_feet}
		
	sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {neck="Nodens Gorget",ear2="Earthcry Earring",waist="Siegel Sash",legs="Shedir Seraweels"})
		
	sets.midcast['Elemental Magic'] = {main="Daybreak",sub="Ammurapi Shield",ammo="Dosis Tathlum",
		head="C. Palug Crown",neck="Sanctity Necklace",ear1="Friomisi Earring",ear2="Crematio Earring",
		body="Chironic Doublet",hands="Volte Gloves",ring1="Shiva Ring +1",ring2="Shiva Ring +1",
		back="Toro Cape",waist="Sekhmet Corset",legs="Gyve Trousers",feet=gear.chironic_nuke_feet}
		
	sets.midcast['Elemental Magic'].Resistant = {main="Daybreak",sub="Ammurapi Shield",ammo="Dosis Tathlum",
		head="C. Palug Crown",neck="Sanctity Necklace",ear1="Friomisi Earring",ear2="Crematio Earring",
		body="Chironic Doublet",hands="Volte Gloves",ring1="Shiva Ring +1",ring2="Shiva Ring +1",
		back="Toro Cape",waist="Yamabuki-no-Obi",legs="Gyve Trousers",feet=gear.chironic_nuke_feet}
		
	sets.midcast.Cursna =  set_combine(sets.midcast.Cure, {main="Yagrush", neck="Debilis Medallion",hands="Hieros Mittens",
		back="Oretan. Cape +1",ring1="Haoma's Ring",ring2="Menelaus's Ring",waist="Witful Belt",feet="Vanya Clogs"})
		
	sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {main=gear.grioavolr_fc_staff,sub="Clemency Grip"})
	
	sets.midcast.Dispelga = {
	    main="Daybreak",
		sub="Genmei Shield",
		range=gear.Linos_Eva_Idle,
		head="Brioso Roundlet +3",
		body="Brioso Justau. +3",
		hands="Brioso Cuffs +3",
		legs="Brioso Cannions +3",
		feet="Brioso Slippers +3",
		neck="Mnbw. Whistle +1",
		waist="Luminary Sash",
		left_ear="Crep. Earring",
		right_ear="Gwati Earring",
		left_ring=gear.stikini1,
		right_ring=gear.stikini2,
		back=gear.fc_macc_jse_back,
	}

	-- Resting sets
	sets.resting = set_combine(sets.idle, {})
	
	sets.idle = {
		--main="Carnwenhan", --Trial Swap
		range=gear.Linos_Eva_Idle,
		head="Nyame Helm",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets",
		neck="Warder's Charm +1",
		waist="Carrier's Sash",
		left_ear="Hearty Earring",
		right_ear="Etiolation Earring",
		left_ring=gear.moonlight1,
		right_ring=gear.moonlight2,
		back=gear.dt_jse_back,
	}
	
	--sets.idle.Town = set_combine(sets.idle, sets.Kiting, {body="Fili Hongreline +2"})
	
	--sets.idle.DW = set_combine(sets.idle, {main="Carnwenhan",sub="Bronze Dagger",}) --Trial Swap
	sets.idle.Single = set_combine(sets.idle, {main=gear.Kali_Refresh,sub="Genmei Shield",})
		
	sets.idle.NoRefresh = set_combine(sets.idle, {})

	sets.idle.DT = set_combine(sets.idle, {})
	
	sets.idle.Ody = {
	    range=gear.Linos_Eva_Idle,
		head="Nyame Helm",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets",
		neck="Bathy Choker +1",
		waist="Svelt. Gouriz +1",
		left_ear="Infused Earring",
		right_ear="Eabani Earring",
		left_ring="Moonlight Ring",
		right_ring="Moonlight Ring",
		back=gear.dt_jse_back,
	}
	
	-- Defense sets

	sets.defense.PDT = sets.idle

	sets.defense.MDT = sets.idle

	sets.Kiting = {feet="Fili Cothurnes +2"}
	sets.Kiting.Ody = {feet="Fili Cothurnes +2"}
	sets.latent_refresh = {}
	sets.latent_refresh_grip = {sub="Oneiros Grip"}
	sets.TPEat = {neck="Chrys. Torque"}

	-- Engaged sets

	-- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
	-- sets if more refined versions aren't defined.
	-- If you create a set with both offense and defense modes, the offense mode should be first.
	-- EG: sets.engaged.Dagger.Accuracy.Evasion
	
	sets.engaged = {
		range=gear.Linos_TP,
		head="Aya. Zucchetto +2",
		body="Ashera Harness",
		hands="Bunzi's Gloves",
		legs="Fili Rhingrave +2",
		feet="Nyame Sollerets",
		neck="Bard's Charm +2",
		waist="Sailfi Belt +1",
		left_ear="Telos Earring",
		right_ear="Brutal Earring",
		left_ring=gear.moonlight1,
		right_ring=gear.moonlight2,
		back=gear.tp_jse_back,
	}
	
	sets.engaged.DW = set_combine(sets.engaged, {})
	sets.engaged.DualCentovente = set_combine(sets.engaged, {right_ear="Eabani Earring", waist="Reiki Yotai", hands="Gazu Bracelets +1"})
	sets.engaged.Aeolian = sets.engaged.DualCentovente
	
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
	set_macro_page(1, 10)
end

function user_job_lockstyle()
	windower.chat.input('/lockstyleset 002')
end