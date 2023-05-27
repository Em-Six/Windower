-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_job_setup()
	state.OffenseMode:options('Normal','Crit')
	state.HybridMode:options('Normal','DT')
	state.RangedMode:options('Normal','Acc')
	state.WeaponskillMode:options('Match','Normal','SomeAcc','Acc','FullAcc','Fodder','Proc')
	state.CastingMode:options('Normal','Proc','Resistant')
	state.IdleMode:options('Normal','Sphere')
	state.PhysicalDefenseMode:options('PDT')
	state.MagicalDefenseMode:options('MDT')
	state.ResistDefenseMode:options('MEVA')
	state.Weapons:options('Heishi','Savage','Evisceration','Crit','ProcDagger','ProcSword','ProcGreatSword','ProcScythe','ProcPolearm','ProcGreatKatana','ProcKatana','ProcClub','ProcStaff')
	state.ExtraMeleeMode = M{['description']='Extra Melee Mode', 'None','SuppaBrutal','DWEarrings','DWMax'}
	state.Stance:options('None','Yonin','Innin')

	autows = "Blade: Chi"

	gear.str_wsd_jse_back = { name="Andartia's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}}
	gear.stp_jse_back = { name="Andartia's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Damage taken-5%',}}
	gear.fc_jse_back = { name="Andartia's Mantle", augments={'"Fast Cast"+10',}}

	utsusemi_cancel_delay = .3
	utsusemi_ni_cancel_delay = .06

	select_default_macro_book()
end

function job_filtered_action(spell, eventArgs)
	if spell.type == 'WeaponSkill' then
		local available_ws = S(windower.ffxi.get_abilities().weapon_skills)
		-- WS 112 is Double Thrust, meaning a Spear is equipped.
		if available_ws:contains(42) then
            if spell.english == "Blade: Chi" then
				windower.chat.input('/ws "Savage Blade" '..spell.target.raw)
                cancel_spell()
				eventArgs.cancel = true
            end
        end
		if available_ws:contains(17) then -- WS 17 is Viper Bite, meaning a Dagger is Equipped
            if spell.english == "Blade: Chi" then
				windower.chat.input('/ws "Evisciration" '..spell.target.raw)
                cancel_spell()
				eventArgs.cancel = true
            end
        end
	end
end

-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Precast sets
    --------------------------------------

    sets.Enmity = {ammo="Paeapua",
        head="Dampening Tam",neck="Unmoving Collar +1",ear1="Friomisi Earring",ear2="Trux Earring",
        body="Emet Harness +1",hands="Kurys Gloves",ring1="Petrov Ring",ring2="Vengeful Ring",
        back="Moonlight Cape",waist="Goading Belt",legs=gear.herculean_dt_legs,feet="Amm Greaves"}

    -- Precast sets to enhance JAs
    sets.precast.JA['Mijin Gakure'] = {} --legs="Mochizuki Hakama",--main="Nagi"
    sets.precast.JA['Futae'] = {hands="Hattori Tekko +1"}
    sets.precast.JA['Sange'] = {} --legs="Mochizuki Chainmail"
    sets.precast.JA['Provoke'] = sets.Enmity
    sets.precast.JA['Warcry'] = sets.Enmity

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {ammo="Yamarang",
        head="Mummu Bonnet +2",neck="Unmoving Collar +1",ear1="Enchntr. Earring +1",ear2="Handler's Earring +1",
        body=gear.herculean_waltz_body,hands=gear.herculean_waltz_hands,ring1="Defending Ring",ring2="Valseur's Ring",
        back="Moonlight Cape",waist="Chaac Belt",legs="Dashing Subligar",feet=gear.herculean_waltz_feet}

    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz['Healing Waltz'] = {}

    -- Set for acc on steps, since Yonin drops acc a fair bit
    sets.precast.Step = {ammo="Togakushi Shuriken",
        head="Dampening Tam",neck="Moonbeam Nodowa",ear1="Mache Earring +1",ear2="Telos Earring",
        body="Mummu Jacket +2",hands="Adhemar Wrist. +1",ring1="Ramuh Ring +1",ring2="Ramuh Ring +1",
        back="Andartia's Mantle",waist="Olseni Belt",legs="Mummu Kecks +2",feet="Malignance Boots"}

    sets.precast.Flourish1 = {ammo="Togakushi Shuriken",
        head="Dampening Tam",neck="Moonbeam Nodowa",ear1="Gwati Earring",ear2="Digni. Earring",
        body="Mekosu. Harness",hands="Adhemar Wrist. +1",ring1="Ramuh Ring +1",ring2="Ramuh Ring +1",
        back="Andartia's Mantle",waist="Olseni Belt",legs="Hattori Hakama +1",feet="Malignance Boots"}

    -- Fast cast sets for spells

    sets.precast.FC = {    
		ammo="Impatiens",
		head=gear.herculean_fc_head,
		body="Adhemar Jacket +1",
		hands="Leyline Gloves",
		legs="Gyve Trousers",
		feet=gear.herculean_fc_feet,
		neck="Baetyl Pendant",
		waist="Gold Mog. Belt",
		left_ear="Loquac. Earring",
		right_ear="Etiolation Earring",
		left_ring="Lebeche Ring",
		right_ring="Weatherspoon Ring",
		back=gear.fc_jse_back,
	}

    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck="Magoraga bead necklace"})
	sets.precast.FC.Shadows = set_combine(sets.precast.FC.Utsusemi, {})

    -- Snapshot for ranged
    sets.precast.RA = {}
    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
		ammo="Seeth. Bomblet +1",
		head="Nyame Helm",
		neck="Ninja Nodowa +2",
		ear1="Moonshade Earring",
		ear2="Lugra Earring +1",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
		ring1="Gere Ring",
		ring2="Regal Ring",
		back=gear.str_wsd_jse_back,
		waist="Sailfi Belt +1",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets"
	}
	
	sets.precast.WS.Proc = {}

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
	sets.precast.WS['Savage Blade'] = {
	    ammo="Seeth. Bomblet +1",
		head="Nyame Helm",
		neck="Fotia Gorget",
		ear1="Moonshade Earring",
		ear2="Lugra Earring +1",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
		ring1="Gere Ring",
		ring2="Regal Ring",
		back=gear.str_wsd_jse_back,
		waist="Sailfi Belt +1",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets"
	}
	
	sets.precast.WS['Blade: Chi'] = {
		ammo="Seeth. Bomblet +1",
		head="Mochi. Hatsuburi +3",
		neck="Fotia Gorget",
		ear1="Moonshade Earring",
		ear2="Lugra Earring +1",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
		ring1="Gere Ring",
		ring2="Epona's Ring",
		back=gear.str_wsd_jse_back,
		waist="Orpheus's Sash",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets"
	}
	
	sets.precast.WS['Blade: To'] = sets.precast.WS['Blade: Chi']
	sets.precast.WS['Blade: Teki'] = sets.precast.WS['Blade: Chi']
	
    sets.precast.WS['Blade: Jin'] = set_combine(sets.precast.WS, {ammo="Yetshila +1",head="Adhemar Bonnet +1",ammo="Yetshila +1",head="Adhemar Bonnet +1",body="Abnoba Kaftan",hands="Ryuo Tekko",ring1="Begrudging Ring",waist="Grunfeld Rope",legs="Mummu Kecks +2",feet="Mummu Gamash. +2"})

	sets.precast.WS['Blade: Hi'] = {
	    ammo="Yetshila +1",
		head="Nyame Helm",
		neck="Ninja Nodowa +2",
		ear1="Odr Earring",
		ear2="Lugra Earring +1",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
		ring1="Gere Ring",
		ring2="Regal Ring",
		back=gear.str_wsd_jse_back,
		waist="Sailfi Belt +1",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets"
	}
	
	sets.precast.WS['Blade: Kamu'] = {
	    ammo="Crepuscular Pebble",
		head="Nyame helm",
		neck="Ninja Nodowa +2",
		ear1="Brutal Earring",
		ear2="Lugra Earring +1",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
		ring1="Gere Ring",
		ring2="Epona's Ring",
		back=gear.str_wsd_jse_back,
		waist="Sailfi Belt +1",
		legs="Mpaca's Hose",
		feet="Nyame Sollerets"
	}

    sets.precast.WS['Blade: Shun'] = {
	    ammo="Crepuscular Pebble",
		head="Ken. Jinpachi +1",
		neck="Ninja Nodowa +2",
		ear1="Moonshade Earring",
		ear2="Lugra Earring +1",
		body="Malignance Tabard",
		hands="Malignance Gloves",
		ring1="Gere Ring",
		ring2="Regal Ring",
		back=gear.str_wsd_jse_back,
		waist="Fotia Belt",
		legs="Mpaca's Hose",
		feet="Ken. Sune-Ate +1"
	}

	sets.precast.WS['Blade: Ten'] = sets.precast.WS['Savage Blade']
	
	sets.precast.WS['Blade: Ei'] = {
	    ammo="Seeth. Bomblet +1",
		head="Pixie Hairpin +1",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets",
		neck="Baetyl Pendant",
		waist="Orpheus's Sash",
		left_ear="Lugra Earring +1",
		right_ear="Friomisi Earring",
		left_ring="Archon Ring",
		right_ring="Dingir Ring",
		back=gear.str_wsd_jse_back,
	}
	
	sets.precast.WS['Sanguine Blade'] = sets.precast.WS['Blade: Ei']

    sets.precast.WS['Aeolian Edge'] = {    
	    ammo="Seeth. Bomblet +1",
		head="Mochi. Hatsuburi +3",
		neck="Sibyl Scarf",
		ear1="Moonshade Earring",
		ear2="Lugra Earring +1",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
		ring1="Dingir Ring",
		ring2="Shiva Ring +1",
		back=gear.str_wsd_jse_back,
		waist="Orpheus's Sash",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets"
	}

	-- Swap to these on Moonshade using WS if at 3000 TP
	sets.MaxTP = {ear1="Lugra Earring",ear2="Lugra Earring +1",}
	sets.AccMaxTP = {ear1="Mache Earring +1",ear2="Telos Earring"}
	sets.AccDayMaxTPWSEars = {ear1="Mache Earring +1",ear2="Telos Earring"}
	sets.DayMaxTPWSEars = {ear1="Cessance Earring",ear2="Brutal Earring",}
	sets.AccDayWSEars = {ear1="Mache Earring +1",ear2="Telos Earring"}
	sets.DayWSEars = {ear1="Moonshade Earring",ear2="Brutal Earring",}


    --------------------------------------
    -- Midcast sets
    --------------------------------------

    sets.midcast.FastRecast = {    
		ammo="Sapience Orb",
		head=gear.herculean_fc_head,
		body="Adhemar Jacket +1",
		hands="Leyline Gloves",
		legs="Gyve Trousers",
		feet=gear.herculean_fc_feet,
		neck="Baetyl Pendant",
		waist="Sailfi Belt +1",
		left_ear="Loquac. Earring",
		right_ear="Etiolation Earring",
		left_ring="Weather. Ring",
		right_ring="Kishar Ring",
		back=gear.fc_jse_back,
	}

    sets.midcast.ElementalNinjutsu = {    
		ammo="Ghastly Tathlum +1",
		head="Mochi. Hatsuburi +3",
		neck="Warder's Charm +1",
		ear1="Static Earring",
		ear2="Friomisi Earring",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
		ring1="Metamor. Ring +1",
		ring2="Mujin Band",
		back="Andartia's Mantle",
		waist="Orpheus's Sash",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets"
	}

	sets.midcast.ElementalNinjutsu.Proc = sets.midcast.FastRecast

    sets.midcast.ElementalNinjutsu.Resistant = set_combine(sets.midcast.ElementalNinjutsu, {})

	sets.MagicBurst = {ring1="Mujin Band",ring2="Locus Ring"}

    sets.midcast.NinjutsuDebuff = {    
		ammo="Staunch Tathlum", --need Pem Tathlum
		head="Nyame Helm",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets",
		neck="Moonlight Necklace",
		waist="Eschan Stone",
		left_ear="Crep. Earring",
		right_ear="Etiolation Earring", -- Need macc ear
		left_ring="Weather. Ring",
		right_ring="Crepuscular Ring",
		back="Andartia's Mantle", -- Need macc cape
	}

    sets.midcast.NinjutsuBuff = set_combine(sets.midcast.FastRecast, {back="Mujin Mantle"})

    sets.midcast.Utsusemi = set_combine(sets.midcast.NinjutsuBuff, {back=gear.fc_jse_back,feet="Hattori Kyahan +1"})

    sets.midcast.RA = {
        head="Malignance Chapeau",neck="Iskur Gorget",ear1="Enervating Earring",ear2="Telos Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Apate Ring",ring2="Regal Ring",
        back=gear.da_jse_back,waist="Chaac Belt",legs="Malignance Tights",feet="Malignance Boots"}

    sets.midcast.RA.Acc = {
        head="Malignance Chapeau",neck="Iskur Gorget",ear1="Enervating Earring",ear2="Telos Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Apate Ring",ring2="Regal Ring",
        back=gear.da_jse_back,waist="Chaac Belt",legs="Malignance Tights",feet="Malignance Boots"}

    --------------------------------------
    -- Idle/resting/defense/etc sets
    --------------------------------------

    -- Resting sets
    sets.resting = {}

    -- Idle sets
    sets.idle = {    
		ammo="Staunch Tathlum",
		head="Nyame Helm",
		neck="Warder's Charm +1",
		ear1="Odnowa Earring +1",
		ear2="Etiolation Earring",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
		ring1="Defending Ring",
		ring2="Shadow Ring",
		back="Shadow Mantle",
		waist="Gold Mog. Belt",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets"
	}

    sets.idle.Sphere = set_combine(sets.idle, {body="Mekosu. Harness"})

    sets.defense.PDT = {ammo="Togakushi Shuriken",
        head="Dampening Tam",neck="Loricate Torque +1",ear1="Genmei Earring",ear2="Sanare Earring",
        body="Emet Harness +1",hands="Malignance Gloves",ring1="Defending Ring",ring2="Dark Ring",
        back="Moonlight Cape",waist="Flume Belt +1",legs=gear.herculean_dt_legs,feet="Malignance Boots"}

    sets.defense.MDT = {ammo="Togakushi Shuriken",
        head="Dampening Tam",neck="Loricate Torque +1",ear1="Etiolation Earring",ear2="Sanare Earring",
        body="Emet Harness +1",hands="Malignance Gloves",ring1="Defending Ring",ring2="Shadow Ring",
        back="Engulfer Cape +1",waist="Engraved Belt",legs=gear.herculean_dt_legs,feet="Ahosi Leggings"}

	sets.defense.MEVA = {ammo="Yamarang",
		head="Dampening Tam",neck="Warder's Charm +1",ear1="Etiolation Earring",ear2="Sanare Earring",
		body="Mekosu. Harness",hands="Leyline Gloves",ring1="Vengeful Ring",Ring2="Purity Ring",
		back="Toro Cape",waist="Engraved Belt",legs="Samnuha Tights",feet="Ahosi Leggings"}


    sets.Kiting = {feet="Danzo Sune-Ate"}
	sets.DuskKiting = set_combine(sets.idle, {feet="Hachi. Kyahan +1"})
	sets.DuskIdle = sets.idle
	sets.DayIdle = sets.idle
	sets.NightIdle = sets.idle


    --------------------------------------
    -- Engaged sets
    --------------------------------------

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion

    -- Normal melee group
    sets.engaged = {
		ammo="Seki Shuriken",
		head="Malignance Chapeau",
		neck="Ninja Nodowa +2",
		ear1="Brutal Earring",
		ear2="Telos Earring",
		body="Malignance Tabard",
		hands="Adhemar Wrist. +1",
		ring1="Gere Ring",
		ring2="Epona's Ring",
		back=gear.stp_jse_back,
		waist="Sailfi Belt +1",
		legs="Samnuha Tights",
		feet="Malignance Boots"
	}

    sets.engaged.SomeAcc = {ammo="Seki Shuriken",
        head="Dampening Tam",neck="Moonbeam Nodowa",ear1="Cessance Earring",ear2="Brutal Earring",
        body="Ken. Samue",hands="Adhemar Wrist. +1",ring1="Ilabrat Ring",ring2="Epona's Ring",
        back=gear.da_jse_back,waist="Windbuffet Belt +1",legs="Samnuha Tights",feet=gear.herculean_ta_feet}

    sets.engaged.Acc = {ammo="Togakushi Shuriken",
        head="Dampening Tam",neck="Moonbeam Nodowa",ear1="Digni. Earring",ear2="Telos Earring",
        body="Ken. Samue",hands="Adhemar Wrist. +1",ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.da_jse_back,waist="Olseni Belt",legs="Mummu Kecks +2",feet="Malignance Boots"}

    sets.engaged.FullAcc = {ammo="Togakushi Shuriken",
        head="Malignance Chapeau",neck="Moonbeam Nodowa",ear1="Mache Earring +1",ear2="Telos Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Ramuh Ring +1",ring2="Ramuh Ring +1",
        back=gear.da_jse_back,waist="Olseni Belt",legs="Malignance Tights",feet="Malignance Boots"}

    sets.engaged.Fodder = {ammo="Togakushi Shuriken",
        head="Dampening Tam",neck="Moonbeam Nodowa",ear1="Dedition Earring",ear2="Brutal Earring",
        body="Ken. Samue",hands="Adhemar Wrist. +1",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.da_jse_back,waist="Windbuffet Belt +1",legs="Samnuha Tights",feet=gear.herculean_ta_feet}

    sets.engaged.Crit = {   
		ammo="Happo Shuriken +1",
		head="Ken. Jinpachi +1",
		body="Mpaca's Doublet",
		hands="Mpaca's Gloves",
		legs="Mpaca's Hose",
		feet="Ken. Sune-Ate +1",
		neck="Ninja Nodowa +2",
		waist="Sailfi Belt +1",
		left_ear="Odr Earring",
		right_ear="Telos Earring",
		left_ring="Gere Ring",
		right_ring="Epona's Ring",
		back=gear.stp_jse_back,
	}

    sets.engaged.DT = {    
		ammo="Seki Shuriken",
		head="Malignance Chapeau",
		body="Malignance Tabard",
		hands="Malignance Gloves",
		legs="Malignance Tights",
		feet="Malignance Boots",
		neck="Ninja Nodowa +2",
		waist="Sailfi Belt +1",
		left_ear="Brutal Earring",
		right_ear="Telos Earring",
		left_ring="Gere Ring",
		right_ring="Epona's Ring",
		back=gear.stp_jse_back,
	}

	sets.engaged.SomeAcc.DT = {ammo="Togakushi Shuriken",
        head="Malignance Chapeau",neck="Loricate Torque +1",ear1="Cessance Earring",ear2="Telos Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Defending Ring",ring2="Epona's Ring",
        back=gear.da_jse_back,waist="Windbuffet Belt +1",legs="Malignance Tights",feet="Malignance Boots"}

	sets.engaged.Acc.DT = {ammo="Togakushi Shuriken",
        head="Malignance Chapeau",neck="Loricate Torque +1",ear1="Mache Earring +1",ear2="Telos Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Defending Ring",ring2="Epona's Ring",
        back=gear.da_jse_back,waist="Windbuffet Belt +1",legs="Malignance Tights",feet="Malignance Boots"}

	sets.engaged.FullAcc.DT = {ammo="Togakushi Shuriken",
        head="Malignance Chapeau",neck="Loricate Torque +1",ear1="Mache Earring +1",ear2="Odr Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Defending Ring",ring2="Ramuh Ring +1",
        back=gear.da_jse_back,waist="Olseni Belt",legs="Malignance Tights",feet="Malignance Boots"}

	sets.engaged.Fodder.DT = {ammo="Togakushi Shuriken",
        head="Malignance Chapeau",neck="Loricate Torque +1",ear1="Cessance Earring",ear2="Brutal Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Defending Ring",ring2="Epona's Ring",
        back=gear.da_jse_back,waist="Windbuffet Belt +1",legs="Malignance Tights",feet="Malignance Boots"}

    --------------------------------------
    -- Custom buff sets
    --------------------------------------

    sets.buff.Migawari = {} --body="Hattori Ningi +1"
    sets.buff.Doom = set_combine(sets.buff.Doom, {})
	sets.buff.Futae = {}
    sets.buff.Yonin = {} --
    sets.buff.Innin = {} --head="Hattori Zukin +1"
	
	sets.Phalanx_Received = {
		head=gear.taeon_phalanx_head,
		body=gear.taeon_phalanx_body,
		hands=gear.taeon_phalanx_hands,
		legs=gear.taeon_phalanx_legs,
		feet=gear.taeon_phalanx_feet,
	}

    -- Extra Melee sets.  Apply these on top of melee sets.
    sets.Knockback = {}
	sets.SuppaBrutal = {ear1="Suppanomimi", ear2="Brutal Earring"}
	sets.DWEarrings = {ear1="Dudgeon Earring",ear2="Heartseeker Earring"}
	sets.DWMax = {ear1="Dudgeon Earring",ear2="Heartseeker Earring",body="Adhemar Jacket +1",hands="Floral Gauntlets",waist="Shetal Stone"}
	sets.TreasureHunter = set_combine(sets.TreasureHunter, {})
	sets.Skillchain = {legs="Ryuo Hakama"}

	-- Weapons sets
	sets.weapons.Heishi = {main="Heishi Shorinken",sub="Kunimitsu"}
	sets.weapons.Crit = {main="Heishi Shorinken",sub="Gleti's Knife"}
	sets.weapons.Savage = {main="Naegling",sub="Hitaki"}
	sets.weapons.Evisceration = {main="Tauret",sub="Gleti's Knife"}
	sets.weapons.Trial = {main="Sasuke Katana",sub="Kunimitsu"}
	sets.weapons.ProcDagger = {main="Chicken Knife II",sub=empty}
	sets.weapons.ProcSword = {main="Ark Sword",sub=empty}
	sets.weapons.ProcGreatSword = {main="Lament",sub=empty}
	sets.weapons.ProcScythe = {main="Ark Scythe",sub=empty}
	sets.weapons.ProcPolearm = {main="Pitchfork +1",sub=empty}
	sets.weapons.ProcGreatKatana = {main="Hardwood Katana",sub=empty}
	sets.weapons.ProcKatana = {main="Kunimitsu",sub=empty}
	sets.weapons.ProcClub = {main="Dream Bell +1",sub=empty}
	sets.weapons.ProcStaff = {main="Terra's Staff",sub=empty}
	sets.weapons.MagicWeapons = {main="Ochu",sub="Ochu"}
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == 'WAR' then
        set_macro_page(1, 12)
    elseif player.sub_job == 'RNG' then
        set_macro_page(1, 12)
    elseif player.sub_job == 'RDM' then
        set_macro_page(1, 12)
    else
        set_macro_page(1, 12)
    end
end
