-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_job_setup()
    state.OffenseMode:options('Normal','SubtleBlow','Bumba')
    state.RangedMode:options('Normal')
    state.WeaponskillMode:options('Match','Normal')
    state.CastingMode:options('Normal', 'Resistant')
    state.IdleMode:options('Normal', 'PDT', 'Refresh')
	state.HybridMode:options('Normal','DT')
	state.ExtraMeleeMode = M{['description']='Extra Melee Mode', 'None', 'DWMax'}
	state.Weapons:options('SavageBlade','LeadenMelee','LeadenRanged','LastStandMelee','LastStandRanged','Aeolian','HotShot','Dynamis')
	state.CompensatorMode:options('Always','300','1000','Never')

	autows = "Savage Blade"
	
    gear.RAbullet = "Chrono Bullet"
    gear.WSbullet = "Chrono Bullet"
    gear.MAbullet = "Living Bullet" --For MAB WS, do not put single-use bullets here.
    gear.QDbullet = "Living Bullet"
    options.ammo_warning_limit = 50
	options.shihei_warning_limit = 30
	ammostock = 99

	gear.phantom_role_jse_adoulin_back = { name="Gunslinger's Cape", augments={'Enmity-3','"Phantom Roll" ability delay -5',}}
	gear.tp_ranger_jse_back = {name="Camulus's Mantle",augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','Rng.Acc.+10','"Store TP"+10',}}
	gear.snapshot_jse_back = {name="Camulus's Mantle",augments={'"Snapshot"+10',}}
	gear.tp_dw_jse_back = { name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dual Wield"+10','Damage taken-5%',}}
	gear.tp_da_jse_back = { name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Damage taken-5%',}}
	gear.ranger_wsd_jse_back = { name="Camulus's Mantle", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','Weapon skill damage +10%',}}
	gear.magic_wsd_jse_back = { name="Camulus's Mantle", augments={'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','Weapon skill damage +10%',}}
	gear.str_wsd_jse_back = { name="Camulus's Mantle", augments={'STR+20','Accuracy+20 Attack+20','Weapon skill damage +10%',}}
	
	gear.rostam_a = { name="Lanun Knife", augments={'Path: A',}}
	gear.rostam_b = { name="Lanun Knife", augments={'Path: B',}}
	gear.rostam_c = { name="Rostam", augments={'Path: C',}}

    select_default_macro_book()
end

-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------

	-- Weapons sets

	sets.weapons.SavageBlade = {main="Naegling",sub="Gleti's Knife",range="Anarchy +2"}
	sets.weapons.LeadenMelee = {main=gear.rostam_b,sub="Tauret",range="Death Penalty"}
	sets.weapons.LeadenRanged = {main=gear.rostam_a,sub="Tauret",range="Death Penalty"}
	sets.weapons.LastStandMelee = {main=gear.rostam_b,sub="Gleti's Knife",range="Fomalhaut"}
	sets.weapons.LastStandRanged = {main=gear.rostam_a,sub="Nusku Shield",range="Fomalhaut"}
	sets.weapons.Aeolian = {main=gear.rostam_b,sub="Tauret",range="Anarchy +2"}
	sets.weapons.HotShot = {main=gear.rostam_b,sub="Tauret",range="Fomalhaut"}
	sets.weapons.Dynamis = {main=gear.rostam_b,sub=gear.rostam_a,range="Anarchy +2"}

    -- Precast Sets

    -- Precast sets to enhance JAs

	sets.precast.JA['Triple Shot'] = {body="Chasseur's Frac +2"}
    sets.precast.JA['Snake Eye'] = {legs="Lanun Trews"}
    sets.precast.JA['Wild Card'] = {feet="Lanun Bottes +3"}
    sets.precast.JA['Random Deal'] = {body="Lanun Frac +3"}
    sets.precast.FoldDoubleBust = {hands="Lanun Gants +1"}

	sets.precast.CorsairRoll = set_combine(sets.idle, {main=gear.rostam_c,range="Compensator",head="Lanun Tricorne",neck="Regal Necklace",hands="Chasseur's Gants +3",legs="Desultor Tassets",back=gear.tp_da_jse_back})

    sets.precast.LuzafRing = {ring2="Luzaf's Ring"}
    
    sets.precast.CorsairRoll["Caster's Roll"] = set_combine(sets.precast.CorsairRoll, {legs="Chas. Culottes +1"})
    sets.precast.CorsairRoll["Courser's Roll"] = set_combine(sets.precast.CorsairRoll, {feet="Chass. Bottes +2"})
    sets.precast.CorsairRoll["Blitzer's Roll"] = set_combine(sets.precast.CorsairRoll, {head="Chass. Tricorne +1"})
    sets.precast.CorsairRoll["Tactician's Roll"] = set_combine(sets.precast.CorsairRoll, {body="Chasseur's Frac +2"})
    sets.precast.CorsairRoll["Allies' Roll"] = set_combine(sets.precast.CorsairRoll, {hands="Chasseur's Gants +3"})
    
    sets.precast.CorsairShot = {    
		ammo=gear.QDbullet,
		head="Malignance Chapeau",
		body="Malignance Tabard",
		hands="Malignance Gloves",
		legs="Malignance Tights",
		feet="Chass. Bottes +2",
		neck="Iskur Gorget",
		waist="Goading Belt",
		left_ear="Crepuscular Earring",
		right_ear="Telos Earring",
		left_ring="Ilabrat Ring",
		right_ring="Chirich Ring +1",
		back=gear.magic_wsd_jse_back,
	}
		
	sets.precast.CorsairShot.Damage = {}
	
    sets.precast.CorsairShot.Proc = {}

    sets.precast.CorsairShot['Light Shot'] = {ammo=gear.QDbullet,
        head="Carmine Mask +1",neck="Comm. Charm +2",ear1="Digni. Earring",ear2="Telos Earring",
        body="Mummu Jacket +2",hands="Leyline Gloves",ring1="Metamor. Ring +1",ring2="Stikini Ring +1",
        back=gear.ranger_wsd_jse_back,waist="Eschan Stone",legs="Malignance Tights",feet="Mummu Gamash. +2"}

    sets.precast.CorsairShot['Dark Shot'] = set_combine(sets.precast.CorsairShot['Light Shot'], {feet="Chass. Bottes +2"})

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {}
		
	sets.Self_Waltz = {}
        
    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz['Healing Waltz'] = {}

    -- Fast cast sets for spells
    
    sets.precast.FC = {
        head="Carmine Mask +1",neck="Baetyl Pendant",ear1="Enchntr. Earring +1",ear2="Loquac. Earring",
        body="Adhemar Jacket +1",hands="Leyline Gloves",ring1="Kishar Ring",ring2="Weatherspoon Ring",
        back="Moonlight Cape",waist="Flume Belt +1",legs="Rawhide Trousers",feet="Carmine Greaves +1"}

    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck="Magoraga Beads"})
	
	sets.precast.FC.Cure = set_combine(sets.precast.FC, {ear2="Mendi. Earring"})

    sets.precast.RA = { --50 Snap + 10 Job points = 60 Total (70 cap) -- 30 Rapid + 30 Traits = 60 Total (100 cap)
		head="Chasseur's tricorne +1 ", -- 14 Rapid
		body="Ikenga's Vest", -- 9 Snap
		hands="Carmine Fin. Ga. +1", -- 8 Snap, 11 Rapid
		legs="Adhemar Kecks", -- 9 Snap
		feet="Meg. Jam. +2", -- 10 Snap
		neck="Comm. Charm +2", -- 4 Snap
		waist="Yemaya Belt", --5 Rapid
		--back=gear.snapshot_jse_back, -- 10 Snap
	}
		
	sets.precast.RA.Flurry = set_combine(sets.precast.RA, {body="Laksa. Frac +3"})
	sets.precast.RA.Flurry2 = set_combine(sets.precast.RA, {body="Laksa. Frac +3"})

       
    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
		ammo=gear.WSbullet,
		head="Nyame Helm",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Lanun Bottes +3",
		neck="Comm. Charm +2",
		waist="Sailfi Belt +1",
		left_ear="Moonshade Earring",
		right_ear="Ishvara Earring",
		left_ring="Regal Ring",
		right_ring="Rufescent Ring",
		back=gear.str_wsd_jse_back,}
				
    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.

    sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS, {head="Carmine Mask +1",ring2="Rufescent Ring",legs="Carmine Cuisses +1",feet="Carmine Greaves +1"})

	sets.precast.WS['Savage Blade'] = {
		ammo=gear.WSbullet,
		head="Nyame Helm",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets",
		neck="Comm. Charm +2",
		waist="Sailfi Belt +1",
		left_ear="Moonshade Earring",
		right_ear="Ishvara Earring",
		left_ring="Regal Ring",
		right_ring="Rufescent Ring",
		back=gear.str_wsd_jse_back,
	}

     sets.precast.WS['Last Stand'] = {
		ammo=gear.WSbullet,
		head="Nyame Helm",
		body="Nyame Mail",
		hands="Chasseur's Gants +3",
		legs="Nyame Flanchard",
		feet="Lanun Bottes +3",
		neck="Fotia Gorget",
		waist="Fotia Belt",
		left_ear="Moonshade Earring",
		right_ear="Ishvara Earring",
		left_ring="Dingir Ring",
		right_ring="Regal Ring",
		back=gear.ranger_wsd_jse_back,
	}
		
    sets.precast.WS['Detonator'] = sets.precast.WS['Last Stand']
    sets.precast.WS['Slug Shot'] = sets.precast.WS['Last Stand']
    sets.precast.WS['Numbing Shot'] = sets.precast.WS['Last Stand']
    sets.precast.WS['Sniper Shot'] = sets.precast.WS['Last Stand']
    sets.precast.WS['Split Shot'] = sets.precast.WS['Last Stand']
	
    sets.precast.WS['Leaden Salute'] = {
		ammo=gear.MAbullet,
		head="Pixie Hairpin +1",
		body="Lanun Frac +3",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Lanun Bottes +3",
		neck="Comm. Charm +2",
		waist="Eschan Stone",
		left_ear="Moonshade Earring",
		right_ear="Friomisi Earring",
		left_ring="Dingir Ring",
		right_ring="Archon Ring",
		back=gear.magic_wsd_jse_back,
		}

    sets.precast.WS['Aeolian Edge'] = {
		ammo=gear.MAbullet,
		head="Nyame Helm",
		body="Lanun Frac +3",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Lanun Bottes +3",
		neck="Comm. Charm +2",
		waist="Eschan Stone",
		left_ear="Moonshade Earring",
		right_ear="Friomisi Earring",
		left_ring="Dingir Ring",
		right_ring="Metamorph Ring +1",
		back=gear.magic_wsd_jse_back,
	}

    sets.precast.WS['Wildfire'] = {
		ammo=gear.MAbullet,
        head="Nyame Helm",
		body="Lanun Frac +3",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Lanun Bottes +3",
		neck="Comm. Charm +2",
		waist="Eschan Stone",
		left_ear="Moonshade Earring",
		right_ear="Friomisi Earring",
		left_ring="Dingir Ring",
		right_ring="Ilabrat Ring",
		back=gear.magic_wsd_jse_back,
	}
		
    sets.precast.WS['Hot Shot'] = {
		ammo=gear.WSbullet,
	    head="Nyame Helm",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Lanun Bottes +3",
		neck="Fotia Gorget",
		waist="Fotia Belt",
		left_ear="Moonshade Earring",
		right_ear="Friomisi Earring",
		left_ring="Dingir Ring",
		right_ring="Regal Ring",
		back=gear.ranger_wsd_jse_back,
	}
		
		--Because omen skillchains.
    sets.precast.WS['Burning Blade'] = sets.precast.WS['Savage Blade']

	-- Swap to these on Moonshade using WS if at 3000 TP
	sets.MaxTP = {}
	sets.AccMaxTP = {}
        
    -- Midcast Sets
    sets.midcast.FastRecast = {
        head="Carmine Mask +1",neck="Baetyl Pendant",ear1="Enchntr. Earring +1",ear2="Loquac. Earring",
        body="Dread Jupon",hands="Leyline Gloves",ring1="Kishar Ring",ring2="Lebeche Ring",
        back="Moonlight Cape",waist="Flume Belt +1",legs="Rawhide Trousers",feet="Carmine Greaves +1"}
        
    -- Specific spells

	sets.midcast.Cure = {
        head="Carmine Mask +1",neck="Phalaina Locket",ear1="Enchntr. Earring +1",ear2="Mendi. Earring",
        body="Dread Jupon",hands="Leyline Gloves",ring1="Janniston Ring",ring2="Lebeche Ring",
        back="Solemnity Cape",waist="Flume Belt +1",legs="Carmine Cuisses +1",feet="Carmine Greaves +1"}
	
	sets.Self_Healing = {neck="Phalaina Locket",hands="Buremte Gloves",ring2="Kunaji Ring",waist="Gishdubar Sash"}
	sets.Cure_Received = {hands="Buremte Gloves",waist="Gishdubar Sash"}
	sets.Self_Refresh = {waist="Gishdubar Sash"}
	
    sets.midcast.Utsusemi = sets.midcast.FastRecast

    -- Ranged gear
    sets.midcast.RA = {
		ammo=gear.RAbullet,
		head="Malignance Chapeau",
		body="Malignance Tabard",
		hands="Malignance Gloves",
		legs="Malignance Tights",
		feet="Malignance Boots",
		neck="Iskur Gorget",
		waist="Yemaya Belt",
		left_ear="Crep. Earring",
		right_ear="Telos Earring",
		left_ring="Ilabrat Ring",
		right_ring="Crepuscular Ring",
		back=gear.tp_ranger_jse_back,
	}

	sets.buff['Triple Shot'] = {body="Chasseur's Frac +2"}
    
    -- Sets to return to when not performing an action.
	
	sets.DayIdle = {}
	sets.NightIdle = {}
	
	sets.buff.Doom = set_combine(sets.buff.Doom, {})
    
    -- Resting sets
    sets.resting = {}
    

    -- Idle sets
    sets.idle = {
		ammo=gear.RAbullet,
		head="Nyame Helm",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets",
		neck="Warder's Charm +1",
		waist="Carrier's Sash",
		left_ear="Etiolation Earring",
		right_ear="Odnowa Earring +1",
		left_ring="Defending Ring",
		right_ring="Shadow Ring",
		back="Shadow Mantle",
	}
		
    sets.idle.PDT = sets.idle
		
    sets.idle.Refresh = sets.idle
    
    -- Defense sets
    sets.defense.PDT = sets.idle

    sets.defense.MDT = sets.idle
		
    sets.defense.MEVA = sets.idle

    sets.Kiting = {legs="Carmine Cuisses +1"}
	sets.TreasureHunter = set_combine(sets.TreasureHunter, {})
	sets.DWMax = {ear1="Dudgeon Earring",ear2="Heartseeker Earring",body="Adhemar Jacket +1",hands="Floral Gauntlets",waist="Reiki Yotai"}

    -- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion
    
    -- Normal melee group
    sets.engaged = {
		ammo=gear.RAbullet,
		head="Malignance Chapeau",
		body="Malignance Tabard",
		hands="Malignance Gloves",
		legs="Malignance Tights",
		feet="Malignance Boots",
		neck="Iskur Gorget",
		waist="Windbuffet Belt +1",
		left_ear="Brutal Earring",
		right_ear="Telos Earring",
		left_ring="Epona's Ring",
		right_ring="Chirich Ring +1",
		back=gear.tp_da_jse_back,
	}
    
	sets.engaged.SubtleBlow = set_combine(sets.engaged, {head="Adhemar Bonnet +1"})
	sets.engaged.Bumba = set_combine(sets.engaged, {head="Nyame Helm",body="Nyame Mail",hands="Nyame Gauntlets",legs="Nyame Flanchard",feet="Nyame Sollerets",})
	
    sets.engaged.Fodder = {
		head=gear.adhemar_head_a,
		body=gear.adhemar_body_a,
		hands=gear.adhemar_hands_a,
		legs="Samnuha Tights",
		feet=gear.herculean_ta_feet,
		neck="Iskur Gorget",
		waist="Windbuffet Belt +1",
		left_ear="Brutal Earring",
		right_ear="Telos Earring",
		left_ring="Epona's Ring",
		right_ring="Petrov Ring",
		back=gear.tp_da_jse_back,
	}
		
    sets.engaged.DT = {
		ammo=gear.RAbullet,
		head="Malignance Chapeau",
		body="Malignance Tabard",
		hands="Malignance Gloves",
		legs="Malignance Tights",
		feet="Malignance Boots",
		neck="Iskur Gorget",
		waist="Windbuffet Belt +1",
		left_ear="Brutal Earring",
		right_ear="Telos Earring",
		left_ring="Epona's Ring",
		right_ring="Petrov Ring",
		back=gear.tp_da_jse_back,
	}
    
    sets.engaged.DW = set_combine(sets.engaged, {left_ear="Suppanomimi",})
    sets.engaged.DW.SubtleBlow = set_combine(sets.engaged.SubtleBlow, {left_ear="Suppanomimi",})
    
    sets.engaged.DW.Fodder = {		
		head=gear.adhemar_head_a,
		body=gear.adhemar_body_a,
		hands=gear.adhemar_hands_a,
		legs="Samnuha Tights",
		feet=gear.herculean_ta_feet,
		neck="Iskur Gorget",
		waist="Windbuffet Belt +1",
		left_ear="Suppanomimi",
		right_ear="Telos Earring",
		left_ring="Epona's Ring",
		right_ring="Petrov Ring",
		back=gear.tp_da_jse_back,
	}
		
    sets.engaged.DW.DT = {
		ammo=gear.RAbullet,
		head="Malignance Chapeau",
		body="Malignance Tabard",
		hands="Malignance Gloves",
		legs="Malignance Tights",
		feet="Malignance Boots",
		neck="Iskur Gorget",
		waist="Windbuffet Belt +1",
		left_ear="Suppanomimi",
		right_ear="Telos Earring",
		left_ring="Epona's Ring",
		right_ring="Petrov Ring",
		back=gear.tp_da_jse_back,
	}
    		
	sets.Phalanx_Received = {
		head=gear.taeon_phalanx_head,
		body=gear.taeon_phalanx_body,
		hands=gear.taeon_phalanx_hands,
		legs=gear.taeon_phalanx_legs,
		feet=gear.taeon_phalanx_feet,
	}
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    if player.sub_job == 'NIN' then
        set_macro_page(1, 11)
    elseif player.sub_job == 'DNC' then
		set_macro_page(1, 11)
    elseif player.sub_job == 'RNG' then
        set_macro_page(1, 11)
    elseif player.sub_job == 'DRG' then
        set_macro_page(1, 11)
    else
        set_macro_page(1, 11)
    end
end

function user_job_lockstyle()
	if player.equipment.main == nil or player.equipment.main == 'empty' then
		windower.chat.input('/lockstyleset 001')
	elseif res.items[item_name_to_id(player.equipment.main)].skill == 3 then --Sword in main hand.
		if player.equipment.sub == nil or player.equipment.sub == 'empty' then --Sword/Nothing.
				windower.chat.input('/lockstyleset 001')
		elseif res.items[item_name_to_id(player.equipment.sub)].shield_size then --Sword/Shield
				windower.chat.input('/lockstyleset 001')
		elseif res.items[item_name_to_id(player.equipment.sub)].skill == 3 then --Sword/Sword.
			windower.chat.input('/lockstyleset 001')
		elseif res.items[item_name_to_id(player.equipment.sub)].skill == 2 then --Sword/Dagger.
			windower.chat.input('/lockstyleset 001')
		else
			windower.chat.input('/lockstyleset 001') --Catchall just in case something's weird.
		end
	elseif res.items[item_name_to_id(player.equipment.main)].skill == 2 then --Dagger in main hand.
		if player.equipment.sub == nil or player.equipment.sub == 'empty' then --Dagger/Nothing.
			windower.chat.input('/lockstyleset 001')
		elseif res.items[item_name_to_id(player.equipment.sub)].shield_size then --Dagger/Shield
			windower.chat.input('/lockstyleset 001')
		elseif res.items[item_name_to_id(player.equipment.sub)].skill == 3 then --Dagger/Sword.
			windower.chat.input('/lockstyleset 001')
		elseif res.items[item_name_to_id(player.equipment.sub)].skill == 2 then --Dagger/Dagger.
			windower.chat.input('/lockstyleset 001')
		else
			windower.chat.input('/lockstyleset 001') --Catchall just in case something's weird.
		end
	end
end