function user_job_setup()

    -- Options: Override default values	
	state.OffenseMode:options('Normal','Offense')
    state.HybridMode:options('Tank','DDTank','BreathTank','Dawn','NoShellTank','Normal')
    state.WeaponskillMode:options('Match','Normal', 'Acc')
    state.CastingMode:options('Normal','SIRD')
	state.Passive:options('None','AbsorbMP')
    state.PhysicalDefenseMode:options('PDT','PDT_HP','Tank')
    state.MagicalDefenseMode:options('BDT','MDT_HP','AegisMDT','AegisNoShellMDT','OchainMDT','OchainNoShellMDT','MDT_Reraise')
	state.ResistDefenseMode:options('MEVA','MEVA_HP','Death','Charm')
	state.IdleMode:options('Normal','Tank','KiteTank','PDT','MDT','Refresh','Reraise')
	state.Weapons:options('Srivatsa','Duban','Aegis','Aeolian')
	
    state.ExtraDefenseMode = M{['description']='Extra Defense Mode','None','MP','Twilight'}
	
	gear.fastcast_jse_back = { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','"Fast Cast"+10',}}
	gear.phalanx_jse_back = { name="Weard Mantle", augments={'VIT+2','DEX+3','Enmity+6','Phalanx +5',}}
	gear.enmity_PDT_back = { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Enmity+10','Phys. dmg. taken-10%',}}
	
    select_default_macro_book()
    update_defense_mode()
end

function init_gear_sets()
	
	--------------------------------------
	-- Precast sets
	--------------------------------------
	
    sets.Enmity = {
		ammo="Sapience Orb",
		head="Loess Barbuta +1",
		body="Souv. Cuirass +1",
		hands="Souv. Handsch. +1",
		legs="Souv. Diechlings +1",
		feet="Eschite Greaves",
		neck="Moonlight Necklace",
		waist="Creed Baudrier",
		left_ear="Odnowa Earring +1",
		right_ear="Cryptic Earring",
		left_ring="Apeile Ring +1",
		right_ring="Eihwaz Ring",
		back=gear.enmity_PDT_back,
		}
		
    sets.Enmity.SIRD = {ammo="Sapience Orb",
		head="Loess Barbuta +1",neck="Loricate Torque +1",ear1="Friomisi Earring",ear2="Trux Earring",
		body="Souv. Cuirass +1",hands="Macabre Gaunt. +1",ring1="Defending Ring",ring2="Moonlight Ring",
		back=gear.enmity_PDT_back,waist="Rumination Sash",legs="Founder's Hose",feet=gear.odyssean_enmity_feet,}
		
    sets.Enmity.DT = {ammo="Sapience Orb",
        head="Souv. Schaller +1",neck="Loricate Torque +1",ear1="Odnowa Earring +1",ear2="Tuisto Earring",
        body="Rev. Surcoat +3",hands="Souv. Handsch. +1",ring1="Gelatinous Ring +1",ring2="Moonlight Ring",
        back="Moonlight Cape",waist="Creed Baudrier",legs="Souv. Diechlings +1",feet="Souveran Schuhs +1"}
		
    -- Precast sets to enhance JAs
    sets.precast.JA['Invincible'] = set_combine(sets.Enmity,{legs="Cab. Breeches +1"})
    sets.precast.JA['Holy Circle'] = set_combine(sets.Enmity,{feet="Rev. Leggings +3"})
    sets.precast.JA['Sentinel'] = set_combine(sets.Enmity,{feet="Cab. Leggings +1"})
    sets.precast.JA['Rampart'] = set_combine(sets.Enmity,{}) --head="Valor Coronet" (Also Vit?)
    sets.precast.JA['Fealty'] = set_combine(sets.Enmity,{body="Cab. Surcoat +1"})
    sets.precast.JA['Divine Emblem'] = set_combine(sets.Enmity,{feet="Chev. Sabatons +1"})
    sets.precast.JA['Cover'] = set_combine(sets.Enmity, {body="Cab. Surcoat +1"}) --head="Rev. Coronet +1",
	
    sets.precast.JA['Invincible'].DT = set_combine(sets.Enmity.DT,{legs="Cab. Breeches +1"})
    sets.precast.JA['Holy Circle'].DT = set_combine(sets.Enmity.DT,{feet="Rev. Leggings +3"})
    sets.precast.JA['Sentinel'].DT = set_combine(sets.Enmity.DT,{feet="Cab. Leggings +1"})
    sets.precast.JA['Rampart'].DT = set_combine(sets.Enmity.DT,{}) --head="Valor Coronet" (Also Vit?)
    sets.precast.JA['Fealty'].DT = set_combine(sets.Enmity.DT,{body="Cab. Surcoat +1"})
    sets.precast.JA['Divine Emblem'].DT = set_combine(sets.Enmity.DT,{feet="Chev. Sabatons +1"})
    sets.precast.JA['Cover'].DT = set_combine(sets.Enmity.DT, {body="Cab. Surcoat +1"}) --head="Rev. Coronet +1",
	
    -- add mnd for Chivalry
    sets.precast.JA['Chivalry'] = {
		head="Sulevia's Mask +2",neck="Phalaina Locket",ear1="Nourish. Earring",ear2="Nourish. Earring +1",
		body="Rev. Surcoat +3",hands="Cab. Gauntlets +1",ring1="Stikini Ring +1",ring2="Rufescent Ring",
		back=gear.enmity_PDT_back,waist="Luminary Sash",legs="Carmine Cuisses +1",feet="Carmine Greaves +1"}

	sets.precast.JA['Shield Bash'] = set_combine(sets.Enmity, {hands="Cab. Gauntlets +1"})		
    sets.precast.JA['Provoke'] = set_combine(sets.Enmity, {})
	sets.precast.JA['Warcry'] = set_combine(sets.Enmity, {})
	sets.precast.JA['Palisade'] = set_combine(sets.Enmity, {})
	sets.precast.JA['Intervene'] = set_combine(sets.Enmity, {})
	sets.precast.JA['Defender'] = set_combine(sets.Enmity, {})
	sets.precast.JA['Berserk'] = set_combine(sets.Enmity, {})
	sets.precast.JA['Aggressor'] = set_combine(sets.Enmity, {})
	
	sets.precast.JA['Shield Bash'].DT = set_combine(sets.Enmity.DT, {hands="Cab. Gauntlets +1"})		
    sets.precast.JA['Provoke'].DT = set_combine(sets.Enmity.DT, {})
	sets.precast.JA['Warcry'].DT = set_combine(sets.Enmity.DT, {})
	sets.precast.JA['Palisade'].DT = set_combine(sets.Enmity.DT, {})
	sets.precast.JA['Intervene'].DT = set_combine(sets.Enmity.DT, {})
	sets.precast.JA['Defender'].DT = set_combine(sets.Enmity.DT, {})
	sets.precast.JA['Berserk'].DT = set_combine(sets.Enmity.DT, {})
	sets.precast.JA['Aggressor'].DT = set_combine(sets.Enmity.DT, {})

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {
		head="Carmine Mask +1",
		body="Rev. Surcoat +3",ring1="Asklepian Ring",ring2="Valseur's Ring",
		waist="Chaac Belt",legs="Sulev. Cuisses +2"}
        
    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz['Healing Waltz'] = {}
    
    sets.precast.Step = {ammo="Aurgelmir Orb +1",
        head="Founder's Corona",neck="Combatant's Torque",ear1="Mache Earring +1",ear2="Telos Earring",
        body="Tartarus Platemail",hands="Leyline Gloves",ring1="Ramuh Ring +1",ring2="Patricius Ring",
        back="Ground. Mantle +1",waist="Olseni Belt",legs="Carmine Cuisses +1",feet="Founder's Greaves"}
		
	sets.precast.JA['Violent Flourish'] = {ammo="Aurgelmir Orb +1",
        head="Founder's Corona",neck="Erra Pendant",ear1="Gwati Earring",ear2="Digni. Earring",
        body="Found. Breastplate",hands="Leyline Gloves",ring1="Defending Ring",ring2="Stikini Ring +1",
        back="Ground. Mantle +1",waist="Olseni Belt",legs="Carmine Cuisses +1",feet="Founder's Greaves"}
		
	sets.precast.JA['Animated Flourish'] = set_combine(sets.Enmity, {})

    -- Fast cast sets for spells
    
    sets.precast.FC = {    
		ammo="Sapience Orb",
		head="Carmine Mask +1",
		body={name="Rev. Surcoat +3", priority=10},
		hands="Leyline Gloves",
		legs=gear.odyssean_fc_legs,
		feet="Carmine Greaves +1",
		neck="Unmoving Collar +1",
		waist="Platinum Moogle Belt",
		left_ear="Odnowa Earring +1",
		right_ear="Etiolation Earring",
		left_ring="Moonlight Ring",
		right_ring="Kishar Ring",
		back=gear.fastcast_jse_back,
	}
		
    sets.precast.FC.DT = sets.precast.FC
		
    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {})
	
	sets.precast.FC.Cure = set_combine(sets.precast.FC, {})
  
    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
		ammo="Crepuscular Pebble",
		head="Nyame Helm",
		body="Nyame mail",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Sakpata's Leggings",
		neck="Breeze Gorget",
		waist="Sailfi Belt +1",
		left_ear="Moonshade Earring",
		right_ear="Thrud Earring",
		left_ring="Rufescent Ring",
		right_ring="Regal Ring",
		back=gear.enmity_PDT_back,
	}
		
    sets.precast.WS.DT = sets.precast.WS

    sets.precast.WS.Acc = {ammo="Hasty Pinion +1",
        head="Ynglinga Sallet",neck="Combatant's Torque",ear1="Mache Earring +1",ear2="Telos Earring",
        body=gear.valorous_wsd_body,hands="Sulev. Gauntlets +2",ring1="Ramuh Ring +1",ring2="Ramuh Ring +1",
        back="Ground. Mantle +1",waist="Olseni Belt",legs="Carmine Cuisses +1",feet="Sulev. Leggings +2"}

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS, {neck="Fotia Gorget",ear1="Brutal Earring",ear2="Moonshade Earring"})
    sets.precast.WS['Requiescat'].Acc = set_combine(sets.precast.WS.Acc, {neck="Fotia Gorget",ear1="Mache Earring +1",ear2="Moonshade Earring"})

	sets.precast.WS['Chant du Cygne'] = set_combine(sets.precast.WS, {neck="Fotia Gorget",ear1="Brutal Earring",ear2="Moonshade Earring"})
    sets.precast.WS['Chant du Cygne'].Acc = set_combine(sets.precast.WS.Acc, {neck="Fotia Gorget",ear1="Mache Earring +1",ear2="Moonshade Earring"})

	sets.precast.WS['Savage Blade'] = {
		ammo="Crepuscular Pebble",
		head="Nyame Helm",
		body="Sakpata's Plate",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Sakpata's Leggings",
		neck="Breeze Gorget",
		waist="Sailfi Belt +1",
		left_ear="Moonshade Earring",
		right_ear="Thrud Earring",
		left_ring="Rufescent Ring",
		right_ring="Regal Ring",
		back=gear.enmity_PDT_back,
	}
	
    sets.precast.WS['Savage Blade'].Acc = set_combine(sets.precast.WS.Acc, {ear1="Mache Earring +1",ear2="Telos Earring"})
	
	sets.precast.WS['Flat Blade'] = {ammo="Aurgelmir Orb +1",
        head="Founder's Corona",neck="Voltsurge Torque",ear1="Gwati Earring",ear2="Digni. Earring",
        body="Flamma Korazin +2",hands="Leyline Gloves",ring1="Defending Ring",ring2="Stikini Ring +1",
        back="Ground. Mantle +1",waist="Olseni Belt",legs="Carmine Cuisses +1",feet="Founder's Greaves"}

	sets.precast.WS['Flat Blade'].Acc = {ammo="Aurgelmir Orb +1",
        head="Flam. Zucchetto +2",neck="Sanctity Necklace",ear1="Gwati Earring",ear2="Digni. Earring",
        body="Flamma Korazin +2",hands="Flam. Manopolas +2",ring1="Ramuh Ring +1",ring2="Ramuh Ring +1",
        back="Ground. Mantle +1",waist="Eschan Stone",legs="Flamma Dirs +2",feet="Flam. Gambieras +2"}

    sets.precast.WS['Sanguine Blade'] = {ammo="Dosis Tathlum",
        head="Jumalik Helm",neck="Sanctity Necklace",ear1="Friomisi Earring",ear2="Crematio Earring",
        body="Jumalik Mail",hands="Founder's Gauntlets",ring1="Metamor. Ring +1",ring2="Archon Ring",
        back="Toro Cape",waist="Fotia Belt",legs="Flamma Dirs +2",feet="Founder's Greaves"}

	sets.precast.WS['Sanguine Blade'].Acc = sets.precast.WS['Sanguine Blade']

    sets.precast.WS['Atonement'] = {ammo="Paeapua",
		head="Loess Barbuta +1",neck="Fotia Gorget",ear1="Moonshade Earring",ear2="Ishvara Earring",
		body=gear.valorous_wsd_body,hands=gear.odyssean_wsd_hands,ring1="Defending Ring",ring2="Moonlight Ring",
		back=gear.enmity_PDT_back,waist="Fotia Belt",legs="Flamma Dirs +2",feet="Eschite Greaves"}

    sets.precast.WS['Atonement'].Acc = sets.precast.WS['Atonement']
    sets.precast.WS['Spirits Within'] = sets.precast.WS['Atonement']
    sets.precast.WS['Spirits Within'].Acc = sets.precast.WS['Atonement']
	
	sets.precast.WS['Aeolian Edge'] = {
	    ammo="Ghastly Tathlum +1",
		head="Nyame Helm",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
			legs="Nyame Flanchard",
		feet="Nyame Sollerets",
		neck="Sibyl Scarf",
		waist="Orpheus's Sash",
		left_ear="Moonshade Earring",
		right_ear="Friomisi Earring",
		left_ring="Metamor. Ring +1",
		right_ring="Shiva Ring +1",
		back=gear.enmity_PDT_back, -- Need WSD Cape
	}

	-- Swap to these on Moonshade using WS if at 3000 TP
	sets.MaxTP = {ear1="Cessance Earring",ear2="Brutal Earring",}
	sets.AccMaxTP = {ear1="Mache Earring +1",ear2="Telos Earring"}


	--------------------------------------
	-- Midcast sets
	--------------------------------------

    sets.midcast.FastRecast = {
		ammo="Sapience Orb",
		head="Carmine Mask +1",
		body="Rev. Surcoat +3",
		hands="Leyline Gloves",
		legs=gear.odyssean_fc_legs,
		feet="Carmine Greaves +1",
		neck="Unmoving Collar +1",
		waist="Goading Belt",
		left_ear="Odnowa Earring +1",
		right_ear="Etiolation Earring",
		left_ring="Moonlight Ring",
		right_ring="Kishar Ring",
		back=gear.fastcast_jse_back,
	}
		
	sets.midcast.FastRecast.DT = {
		ammo="Sapience Orb",
		head="Carmine Mask +1",
		body="Rev. Surcoat +3",
		hands="Leyline Gloves",
		legs=gear.odyssean_fc_legs,
		feet="Carmine Greaves +1",
		neck="Unmoving Collar +1",
		waist="Goading Belt",
		left_ear="Odnowa Earring +1",
		right_ear="Etiolation Earring",
		left_ring="Moonlight Ring",
		right_ring="Kishar Ring",
		back=gear.fastcast_jse_back,
	}

    sets.midcast.Flash = {    
		ammo="Sapience Orb",
		head="Loess Barbuta +1",
		body="Rev. Surcoat +3",
		hands="Souv. Handsch. +1",
		legs="Souv. Diechlings +1",
		feet="Eschite Greaves",
		neck="Moonlight Necklace",
		waist="Creed Baudrier",
		left_ear="Odnowa Earring +1",
		right_ear="Cryptic Earring",
		left_ring="Apeile Ring +1",
		right_ring="Eihwaz Ring",
		back=gear.fastcast_jse_back,
	}
	
	sets.midcast.Flash.SIRD = {    -- Merits 10% SIRD - Total 105% SIRD
		ammo="Staunch Tathlum", -- 10% SIRD
		head="Souv. Schaller +1", -- 20% SIRD
		body="Rev. Surcoat +3",
		hands="Souv. Handsch. +1",
		legs="Founder's Hose", -- 30% SIRD
		feet=gear.odyssean_enmity_feet, -- 20% SIRD
		neck="Moonlight Necklace", -- 15% SIRD
		waist="Creed Baudrier",
		left_ear="Odnowa Earring +1",
		right_ear="Cryptic Earring",
		left_ring="Apeile Ring +1",
		right_ring="Eihwaz Ring",
		back=gear.fastcast_jse_back,
	}
	
    sets.midcast.Stun = sets.midcast.Flash
	sets.midcast.Stun.SIRD = sets.midcast.Flash.SIRD
	sets.midcast['Blue Magic'] = sets.midcast.Flash
	sets.midcast['Blue Magic'].SIRD = sets.midcast.Flash.SIRD
	sets.midcast.Cocoon = set_combine(sets.Enmity.SIRD, {})

    sets.midcast.Cure = {	
		ammo="Sapience Orb",
		head="Loess Barbuta +1",
		body="Souv. Cuirass +1",
		hands="Macabre Gaunt. +1",
		legs="Souv. Diechlings +1",
		feet="Eschite Greaves",
		neck="Sacro Gorget",
		waist="Creed Baudrier",
		left_ear="Odnowa Earring +1",
		right_ear="Cryptic Earring",
		left_ring="Vexer Ring +1",
		right_ring="Eihwaz Ring",
		back=gear.enmity_PDT_back,
	}
		
    sets.midcast.Cure.SIRD = set_combine(sets.midcast.Cure, {ammo="Staunch Tathlum", head="Souv. Schaller +1", legs="Founder's Hose", feet=gear.odyssean_enmity_feet, neck="Moonlight Necklace", waist="Audumbla Sash",})
		
    sets.midcast.Cure.DT = {
		ammo="Sapience Orb",
		head="Souv. Schaller +1",
		body="Souv. Cuirass +1",
		hands="Souv. Handsch. +1",
		legs="Souv. Diechlings +1",
		feet="Souveran Schuhs +1",
		neck="Loricate Torque +1",
		waist="Goading Belt",
		left_ear="Odnowa Earring +1",
		right_ear="Odnowa Earring",
		left_ring="Apeile Ring +1",
		right_ring="Eihwaz Ring",
		back=gear.enmity_PDT_back,
	}
		
    sets.midcast.Reprisal = {
		ammo="Sapience Orb",
		head="Carmine Mask +1",
		body="Shab. Cuirass +1",
		hands="Regal Gauntlets",
		legs=gear.odyssean_fc_legs,
		feet="Carmine Greaves +1",
		neck="Unmoving Collar +1",
		waist="Platinum Moogle Belt",
		left_ear="Odnowa Earring +1",
		right_ear="Etiolation Earring",
		left_ring="Moonlight Ring",
		right_ring="Kishar Ring",
		back=gear.fastcast_jse_back ,
	}
	
	sets.midcast.Reprisal.SIRD = set_combine(sets.midcast.Reprisal, {ammo="Staunch Tathlum", head="Souv. Schaller +1", legs="Founder's Hose", feet=gear.odyssean_enmity_feet, neck="Moonlight Necklace", waist="Audumbla Sash",})

	sets.Self_Healing = sets.midcast.Cure
		
	sets.Self_Healing.SIRD = set_combine(sets.Self_Healing, {ammo="Staunch Tathlum", head="Souv. Schaller +1", legs="Founder's Hose", feet=gear.odyssean_enmity_feet, neck="Moonlight Necklace", waist="Audumbla Sash",})
		
	sets.Self_Healing.DT = {   
		ammo="Sapience Orb",
		head="Souv. Schaller +1",
		body="Souv. Cuirass +1",
		hands="Souv. Handsch. +1",
		legs="Souv. Diechlings +1",
		feet="Souveran Schuhs +1",
		neck="Unmoving Collar +1",
		waist="Goading Belt",
		left_ear="Odnowa Earring +1",
		right_ear="Odnowa Earring",
		left_ring="Apeile Ring +1",
		right_ring="Eihwaz Ring",
		back=gear.enmity_PDT_back,
	}

	sets.Cure_Received = {}
	sets.Self_Refresh = {waist="Gishdubar Sash"}

    sets.midcast['Enhancing Magic'] = set_combine(sets.midcast.FastRecast, {body="Shab. Cuirass +1",hands="Regal Gauntlets"})
		
    sets.midcast['Enhancing Magic'].SIRD = set_combine(sets.midcast['Enhancing Magic'], {ammo="Staunch Tathlum", head="Souv. Schaller +1", legs="Founder's Hose", feet=gear.odyssean_enmity_feet, neck="Moonlight Necklace", waist="Audumbla Sash",})

	sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {waist="Siegel Sash"})

    sets.midcast.Protect = set_combine(sets.midcast['Enhancing Magic'], {ring2="Sheltered Ring"})
    sets.midcast.Shell = set_combine(sets.midcast['Enhancing Magic'], {ring2="Sheltered Ring"})
	
	sets.midcast.Phalanx = {
	    ammo="Staunch Tathlum",
		head=gear.yorium_phalanx_head,
		body=gear.odyssean_phalanx_body,
		hands="Souv. Handsch. +1",
		legs="Sakpata's Cuisses",
		feet="Souveran Schuhs +1",
		neck="Unmoving Collar +1",
		waist="Platinum Moogle Belt",
		left_ear="Odnowa Earring +1",
		right_ear="Odnowa Earring",
		left_ring="Moonlight Ring",
		right_ring="Moonlight Ring",
		back=gear.phalanx_jse_back,
	}
	sets.midcast.Phalanx.SIRD = set_combine(sets.midcast.Phalanx, {legs="Founder's Hose", feet=gear.odyssean_phalanx_feet, neck="Moonlight Necklace", waist="Audumbla Sash",})
	sets.midcast.Phalanx.DT = set_combine(sets.midcast.Phalanx.SIRD, {})	

	--------------------------------------
	-- Idle/resting/defense/etc sets
	--------------------------------------

    sets.resting = {ammo="Homiliary",
		head="Jumalik Helm",neck="Coatl Gorget +1",ear1="Etiolation Earring",ear2="Ethereal Earring",
		body="Jumalik Mail",hands="Souv. Handsch. +1",ring1="Defending Ring",ring2="Dark Ring",
		back="Moonlight Cape",waist="Fucho-no-obi",legs="Sulev. Cuisses +2",feet="Cab. Leggings +1"}

    -- Idle sets
    sets.idle = {
		ammo="Staunch Tathlum",
		head="Sakpata's Helm",
		body="Sakpata's Plate",
		hands="Sakpata's Gauntlets",
		legs="Sakpata's Cuisses",
		feet="Sakpata's Leggings",
		neck={name="Unmoving Collar +1", priority=15},
		waist="Flume Belt",
		left_ear={name="Odnowa Earring +1", priority=14},
		right_ear={name="Odnowa Earring", priority=13},
		left_ring=gear.moonlight1,
		right_ring=gear.moonlight2,
		back=gear.enmity_PDT_back,
		}
		
    sets.idle.PDT = sets.idle
		
    sets.idle.MDT = sets.idle
	
	sets.idle.Town = set_combine(sets.idle, sets,Kiting, {ammo="Homiliary",hands="Regal Gauntlets",waist="Platinum Moogle Belt",left_ring=gear.stikini1,right_ring=gear.stikini2,})
		
	sets.idle.Refresh = {main="Mafic Cudgel",sub="Ochain",ammo="Homiliary",
		head="Jumalik Helm",neck="Coatl Gorget +1",ear1="Etiolation Earring",ear2="Ethereal Earring",
		body="Jumalik Mail",hands="Souv. Handsch. +1",ring1="Defending Ring",ring2="Dark Ring",
		back="Moonlight Cape",waist="Flume Belt +1",legs="Souv. Diechlings +1",feet="Cab. Leggings +1"}

	sets.idle.Tank = sets.idle
		
	sets.idle.KiteTank = sets.idle
		
    sets.idle.Reraise = {main="Mafic Cudgel",sub="Ochain",ammo="Staunch Tathlum +1",
		head="Twilight Helm",neck="Loricate Torque +1",ear1="Etiolation Earring",ear2="Thureous Earring",
		body="Twilight Mail",hands="Souv. Handsch. +1",ring1="Defending Ring",ring2="Dark Ring",
		back="Moonlight Cape",waist="Flume Belt +1",legs="Carmine Cuisses +1",feet="Cab. Leggings +1"}
		
    sets.idle.Weak = sets.idle
		
	sets.Kiting = {legs="Carmine Cuisses +1"}

	sets.latent_refresh = {ammo="Homiliary",}
	sets.idle.Refresh = {}
	sets.latent_refresh_grip = {sub="Oneiros Grip"}
	sets.latent_regen = {}
	sets.DayIdle = {}
	sets.NightIdle = {}

	--------------------------------------
    -- Defense sets
    --------------------------------------
    
    -- Extra defense sets.  Apply these on top of melee or defense sets.
	sets.Knockback = {}
    sets.MP = {head="Chev. Armet +1",neck="Coatl Gorget +1",ear2="Ethereal Earring",waist="Flume Belt +1",feet="Rev. Leggings +3"}
	sets.passive.AbsorbMP = {head="Chev. Armet +1",neck="Coatl Gorget +1",ear2="Ethereal Earring",waist="Flume Belt +1",feet="Rev. Leggings +3"}
    sets.MP_Knockback = {}
    sets.Twilight = {head="Twilight Helm", body="Twilight Mail"}
	sets.TreasureHunter = set_combine(sets.TreasureHunter, {})
	
	-- Weapons sets
	sets.weapons.Aegis = {main="Sakpata's Sword",sub="Aegis"}
	sets.weapons.Duban = {main="Sakpata's Sword",sub="Duban"}
	sets.weapons.Aeolian = {main="Kustawi +1",sub="Duban"}
	sets.weapons.Srivatsa = {main="Sakpata's Sword",sub="Srivatsa"}
	sets.weapons.Trial = {main="Sunblade",sub="Utu Grip"}
    
    sets.defense.PDT = set_combine(sets.engaged.Tank, {})
		
    sets.defense.PDT_HP = set_combine(sets.engaged.Tank, {})
		
    sets.defense.MDT_HP = set_combine(sets.engaged.Tank, {})
		
    sets.defense.MEVA_HP = set_combine(sets.engaged.Tank, {})
		
    sets.defense.PDT_Reraise = set_combine(sets.engaged.Tank, {})
		
    sets.defense.MDT_Reraise = set_combine(sets.engaged.Tank, {})

	sets.defense.BDT = set_combine(sets.engaged.Tank, {})
		
	sets.defense.Tank = set_combine(sets.engaged.Tank, {})
		
	sets.defense.MEVA = set_combine(sets.engaged.Tank, {})
		
	sets.defense.Death = set_combine(sets.engaged.Tank, {})
		
	sets.defense.Charm = set_combine(sets.engaged.Tank, {})
		
		-- To cap MDT with Shell IV (52/256), need 76/256 in gear.
    -- Shellra V can provide 75/256, which would need another 53/256 in gear.
    sets.defense.OchainMDT = {sub="Aegis",ammo="Staunch Tathlum +1",
		head="Founder's Corona",neck="Warder's Charm +1",ear1="Odnowa Earring +1",ear2="Sanare Earring",
		body="Tartarus Platemail",hands="Souv. Handsch. +1",ring1="Defending Ring",ring2="Shadow Ring",
		back="Engulfer Cape +1",waist="Creed Baudrier",legs="Chev. Cuisses +1",feet="Chev. Sabatons +1"}
		
    sets.defense.OchainNoShellMDT = {sub="Ochain",ammo="Staunch Tathlum +1",
		head="Founder's Corona",neck="Warder's Charm +1",ear1="Odnowa Earring +1",ear2="Sanare Earring",
		body="Tartarus Platemail",hands="Souv. Handsch. +1",ring1="Defending Ring",ring2="Shadow Ring",
		back="Engulfer Cape +1",waist="Flax Sash",legs="Sulev. Cuisses +2",feet="Chev. Sabatons +1"}
		
    sets.defense.AegisMDT = set_combine(sets.engaged.Tank, {})
		
    sets.defense.AegisNoShellMDT = {sub="Aegis",ammo="Staunch Tathlum +1",
		head="Founder's Corona",neck="Warder's Charm +1",ear1="Odnowa Earring +1",ear2="Sanare Earring",
		body="Tartarus Platemail",hands="Souv. Handsch. +1",ring1="Defending Ring",ring2="Shadow Ring",
		back=gear.fastcast_jse_back,waist="Asklepian Belt",legs="Sulev. Cuisses +2",feet="Amm Greaves"}		

	--------------------------------------
	-- Engaged sets
	--------------------------------------
    
	sets.engaged = {    
		ammo="Staunch Tathlum",
		head="Sakpata's Helm",
		body="Sakpata's Plate",
		hands="Sakpata's Gauntlets",
		legs="Sakpata's Cuisses",
		feet="Sakpata's Leggings",
		neck="Unmoving Collar +1",
		waist="Flume Belt",
		left_ear="Odnowa Earring +1",
		right_ear="Odnowa Earring",
		left_ring=gear.moonlight1,
		right_ring=gear.moonlight2,
		back=gear.enmity_PDT_back,
		}
		
	sets.engaged.Offense = {
	    ammo="Coiste Bodhar",
		head="Sakpata's Helm",
		body="Sakpata's Plate",
		hands="Sakpata's Gauntlets",
		legs="Sakpata's Cuisses",
		feet="Sakpata's Leggings",
		neck="Asperity Necklace",
		waist="Sailfi Belt +1",
		left_ear="Telos Earring",
		right_ear="Brutal Earring",
		left_ring="Petrov Ring",
		right_ring="Chirich Ring +1",
		back=gear.enmity_PDT_back,
	}

    sets.engaged.Acc = {main="Mafic Cudgel",sub="Ochain",ammo="Hasty Pinion +1",
        head="Flam. Zucchetto +2",neck="Combatant's Torque",ear1="Mache Earring +1",ear2="Telos Earring",
        body=gear.valorous_wsd_body,hands="Sulev. Gauntlets +2",ring1="Ramuh Ring +1",ring2="Ramuh Ring +1",
        back="Ground. Mantle +1",waist="Tempus Fugit",legs="Carmine Cuisses +1",feet="Sulev. Leggings +2"}

    sets.engaged.DW = {ammo="Paeapua",
		head="Flam. Zucchetto +2",neck="Asperity Necklace",ear1="Dudgeon Earring",ear2="Heartseeker Earring",
		body=gear.valorous_wsd_body,hands="Sulev. Gauntlets +2",ring1="Flamma Ring",ring2="Petrov Ring",
		back="Bleating Mantle",waist="Windbuffet Belt +1",legs="Sulev. Cuisses +2",feet="Founder's Greaves"}

    sets.engaged.DW.Acc = {ammo="Aurgelmir Orb +1",
		head="Flam. Zucchetto +2",neck="Asperity Necklace",ear1="Dudgeon Earring",ear2="Heartseeker Earring",
		body=gear.valorous_wsd_body,hands="Sulev. Gauntlets +2",ring1="Flamma Ring",ring2="Ramuh Ring +1",
		back="Letalis Mantle",waist="Olseni Belt",legs="Sulev. Cuisses +2",feet="Founder's Greaves"}

	sets.engaged.Tank = {    
		ammo="Staunch Tathlum",
		head="Sakpata's Helm",
		body="Sakpata's Plate",
		hands="Sakpata's Gauntlets",
		legs="Sakpata's Cuisses",
		feet="Sakpata's Leggings",
		neck="Unmoving Collar +1",
		waist="Flume Belt",
		left_ear="Odnowa Earring +1",
		right_ear="Odnowa Earring",
		left_ring=gear.moonlight1,
		right_ring=gear.moonlight2,
		back=gear.enmity_PDT_back,
		}
		
	sets.engaged.Dawn = {main="Mafic Cudgel",sub="Ochain",ammo="Staunch Tathlum +1",
		head="Jumalik Helm",neck="Loricate Torque +1",ear1="Telos Earring",ear2="Ethereal Earring",
		body="Jumalik Mail",hands="Souv. Handsch. +1",ring1="Defending Ring",ring2="Shadow Ring",
		back="Moonlight Cape",waist="Tempus Fugit",legs="Arke Cosc. +1",feet="Rev. Leggings +3"}
		
	sets.engaged.BreathTank = {main="Mafic Cudgel",sub="Ochain",ammo="Staunch Tathlum +1",
		head="Loess Barbuta +1",neck="Loricate Torque +1",ear1="Thureous Earring",ear2="Etiolation Earring",
		body="Tartarus Platemail",hands="Sulev. Gauntlets +2",ring1="Defending Ring",ring2="Shadow Ring",
		back="Engulfer Cape +1",waist="Creed Baudrier",legs="Sulev. Cuisses +2",feet="Amm Greaves"}
		
	sets.engaged.DDTank = {ammo="Hasty Pinion +1",
		head="Sulevia's Mask +2",neck="Loricate Torque +1",ear1="Brutal Earring",ear2="Cessance Earring",
		body="Tartarus Platemail",hands="Sulev. Gauntlets +2",ring1="Defending Ring",ring2="Patricius Ring",
		back="Weard Mantle",waist="Tempus Fugit",legs="Sulev. Cuisses +2",feet="Sulev. Leggings +2"}
		
	sets.engaged.Acc.DDTank = {ammo="Hasty Pinion +1",
		head="Sulevia's Mask +2",neck="Loricate Torque +1",ear1="Mache Earring +1",ear2="Telos Earring",
		body="Tartarus Platemail",hands="Sulev. Gauntlets +2",ring1="Defending Ring",ring2="Patricius Ring",
		back="Weard Mantle",waist="Tempus Fugit",legs="Sulev. Cuisses +2",feet="Sulev. Leggings +2"}
		
	sets.engaged.NoShellTank = {main="Mafic Cudgel",sub="Ochain",ammo="Staunch Tathlum +1",
        head="Jumalik Helm",neck="Loricate Torque +1",ear1="Thureous Earring",ear2="Etiolation Earring",
        body="Rev. Surcoat +3",hands="Sulev. Gauntlets +2",ring1="Defending Ring",ring2="Moonlight Ring",
        back="Moonlight Cape",waist="Flume Belt +1",legs=gear.odyssean_fc_legs,feet="Cab. Leggings +1"}
		
    sets.engaged.Reraise = set_combine(sets.engaged.Tank, sets.Reraise)
    sets.engaged.Acc.Reraise = set_combine(sets.engaged.Acc.Tank, sets.Reraise)
		
	--------------------------------------
	-- Custom buff sets
	--------------------------------------
	sets.buff.Doom = set_combine(sets.buff.Doom, {})
	sets.buff.Sleep = {neck="Vim Torque +1"}
    sets.buff.Cover = {body="Cab. Surcoat +1"}
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == 'NIN' then
        set_macro_page(2, 4)
    elseif player.sub_job == 'RUN' then
        set_macro_page(9, 4)
    elseif player.sub_job == 'RDM' then
        set_macro_page(6, 4)
    elseif player.sub_job == 'BLU' then
        set_macro_page(1, 4)
    elseif player.sub_job == 'DNC' then
        set_macro_page(1, 4)
    else
        set_macro_page(1, 4) --War/Etc
    end
end

function user_job_lockstyle()
		windower.chat.input('/lockstyleset 010')
end