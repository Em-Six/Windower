function user_job_setup()
	-- Options: Override default values
    state.OffenseMode:options('Normal')
    state.HybridMode:options('Normal','DT')
	state.WeaponskillMode:options('Match','Proc')
	state.AutoBuffMode:options('Off','Auto','AutoMelee')
	state.CastingMode:options('Normal','Resistant', 'Fodder', 'Proc')
    state.IdleMode:options('Normal','PDT','MDT','DTHippo')
    state.PhysicalDefenseMode:options('PDT','NukeLock')
	state.MagicalDefenseMode:options('MDT')
	state.ResistDefenseMode:options('MEVA')
	state.Weapons:options('None','Naegling','Crocea','EnspellOnly','Aeolian','BlackHalo','Dyna')
	
	gear.obi_cure_back = "Tempered Cape +1"
	gear.obi_cure_waist = "Witful Belt"

	gear.obi_low_nuke_back = "Toro Cape"
	gear.obi_low_nuke_waist = "Sekhmet Corset"

	gear.obi_high_nuke_back = "Toro Cape"
	gear.obi_high_nuke_waist = "Refoccilation Stone"

	gear.stp_jse_back = { name="Sucellos's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Phys. dmg. taken-10%',}}
	gear.mnd_macc_jse_back = { name="Sucellos's Cape", augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','MND+10','"Fast Cast"+10','Spell interruption rate down-10%',}}
	gear.wsd_jse_back = { name="Sucellos's Cape", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}}
	gear.intwsd_jse_back = { name="Sucellos's Cape", augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','MND+10','"Fast Cast"+10','Spell interruption rate down-10%',}}

		-- Additional local binds
	
	select_default_macro_book()
end

function job_filtered_action(spell, eventArgs)
	if spell.type == 'WeaponSkill' then
		local available_ws = S(windower.ffxi.get_abilities().weapon_skills)
		if available_ws:contains(16) then
            if spell.english == "Savage Blade" then
				windower.chat.input('/ws "Evisceration" '..spell.target.raw)
                cancel_spell()
				eventArgs.cancel = true
            elseif spell.english == "Circle Blade" then
                windower.chat.input('/ws "Aeolian Edge" '..spell.target.raw)
                cancel_spell()
				eventArgs.cancel = true
			end
        end
		if available_ws:contains(160) then
            if spell.english == "Savage Blade" then
				windower.chat.input('/ws "Black Halo" '..spell.target.raw)
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
	
	-- Precast Sets
	
	-- Precast sets to enhance JAs
	sets.precast.JA['Chainspell'] = {body="Viti. Tabard +3"}
	

	-- Waltz set (chr and vit)
	sets.precast.Waltz = {}
		
	-- Don't need any special gear for Healing Waltz.
	sets.precast.Waltz['Healing Waltz'] = {}

	-- Fast cast sets for spells
	
	sets.precast.FC = { -- 38% Fast Cast from JP/Traits, Need 42% FC + 10% QC to Cap
	    ammo="Impatiens", -- 2 QC
		head="Atro. Chapeau +2", -- 16 FC
		body="Viti. Tabard +3", -- 15 FC
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets",
		neck="Unmoving Collar +1",
		waist="Witful Belt", -- 3 FC 3 QC
		left_ear="Odnowa Earring +1",
		right_ear="Etiolation Earring", -- 1 FC
		left_ring="Lebeche Ring", -- 2 QC
		right_ring="Weather. Ring", -- 5 FC 3 QC
		back=gear.mnd_macc_jse_back, -- 10 FC
	}
		
	sets.precast.FC.Impact = set_combine(sets.precast.FC, {head=empty,body="Twilight Cloak"})
	sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {main="Daybreak",sub="Sacro Bulwark"})
       
	-- Weaponskill sets
	-- Default set for any weaponskill that isn't any more specifically defined
	sets.precast.WS = {range=empty,ammo="Voluspa Tathlum",
		head="Viti. Chapeau +3",neck="Asperity Necklace",ear1="Cessance Earring",ear2="Sherida Earring",
		body="Ayanmo Corazza +2",hands="Aya. Manopolas +2",ring1="Petrov Ring",ring2="Ilabrat Ring",
		back=gear.wsd_jse_back,waist="Windbuffet Belt +1",legs="Carmine Cuisses +1",feet="Carmine Greaves +1"}
		
	sets.precast.WS.Proc = 	{range=empty,ammo="Hasty Pinion +1",
		head="Malignance Chapeau",neck="Combatant's Torque",ear1="Mache Earring +1",ear2="Telos Earring",
		body="Malignance Tabard",hands="Malignance Gloves",ring1="Ramuh Ring +1",ring2="Ramuh Ring +1",
		back=gear.wsd_jse_back,waist="Olseni Belt",legs="Malignance Tights",feet="Malignance Boots"}
	
	-- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
		
	sets.precast.WS['Evisceration'] = sets.precast.WS['Chant Du Cygne']

	sets.precast.WS['Savage Blade'] = {    
		ammo="Coiste Bodhar",
		head="Nyame Helm",
		body="Nyame Mail",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets",
		neck="Republican platinum medal", 
		waist="Sailfi Belt +1",
		left_ear="Moonshade Earring",
		right_ear="Ishvara Earring", -- Regal Earring beats this apparently
		left_ring="Metamorph Ring +1", 
		right_ring="Rufescent Ring",
		back=gear.wsd_jse_back,
	}
		
	sets.precast.WS['Black Halo'] = sets.precast.WS['Savage Blade']
		
	sets.precast.WS['Aeolian Edge'] = {
	    ammo="Ghastly Tathlum +1", 
		head="Nyame Helm",
		body="Nyame Mail",
		hands="Jhakri Cuffs +2",
		legs="Nyame Flanchard", -- Need Almaric +1
		feet="Leth. Houseaux +2",
		neck="Sibyl Scarf",
		waist="Eschan Stone",
		left_ear="Moonshade Earring",
		right_ear="Malignance Earring",
		left_ring="Metamor. Ring +1",
		right_ring="Shiva Ring +1", -- Need Freke
		back=gear.mnd_macc_jse_back, -- Need INT/WSD Back
	}	
		
	sets.precast.WS['Sanguine Blade'] = set_combine(sets.precast.WS['Aeolian Edge'], {head="Pixie Hairpin +1",right_ring="Archon Ring",})
		
	sets.precast.WS['Seraph Blade'] = set_combine(sets.precast.WS['Aeolian Edge'], {neck="Dls. Torque +2",right_ring="Weather. Ring",})
	
	-- Midcast Sets

	sets.TreasureHunter = set_combine(sets.TreasureHunter, {})
	
	-- Gear that converts elemental damage done to recover MP.	
	sets.RecoverMP = {body="Seidr Cotehardie"}
	
	-- Gear for Magic Burst mode.
    sets.MagicBurst = {main=gear.grioavolr_nuke_staff,sub="Alber Strap",head="Ea Hat",neck="Mizu. Kubikazari",body="Ea Houppelande",hands="Amalric Gages +1",ring1="Mujin Band",legs="Ea Slops",feet="Jhakri Pigaches +2"}
	
	sets.midcast.FastRecast = {main=gear.grioavolr_fc_staff,sub="Clerisy Strap +1",range=empty,ammo="Hasty Pinion +1",
		head="Atrophy Chapeau +3",neck="Voltsurge Torque",ear1="Enchntr. Earring +1",ear2="Malignance Earring",
		body="Zendik Robe",hands="Gende. Gages +1",ring1="Kishar Ring",ring2="Prolix Ring",
		back="Swith Cape +1",waist="Witful Belt",legs="Psycloth Lappas",feet="Medium's Sabots"}

    sets.midcast.Cure = {main="Daybreak",sub="Sors Shield",range=empty,ammo="Hasty Pinion +1",
        head="Kaykaus Mitra +1",neck="Incanter's Torque",ear1="Meili Earring",ear2="Mendi. Earring",
        body="Kaykaus Bliaut +1",hands="Kaykaus Cuffs +1",ring1=gear.stikini1,ring2="Naji's Loop",
        back="Tempered Cape +1",waist="Luminary Sash",legs="Kaykaus Tights +1",feet="Kaykaus Boots +1"}
		
    sets.midcast.LightWeatherCure = set_combine(sets.midcast.Cure, {})
		
		--Cureset for if it's not light weather but is light day.
    sets.midcast.LightDayCure = set_combine(sets.midcast.Cure, {})
		
	sets.midcast.Cursna =  set_combine(sets.midcast.Cure, {neck="Debilis Medallion",hands="Hieros Mittens",
		back="Oretan. Cape +1",ring1="Haoma's Ring",ring2="Menelaus's Ring",waist="Witful Belt",feet="Vanya Clogs"})
		
	sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {main=gear.grioavolr_fc_staff,sub="Clemency Grip"})
		
	sets.midcast.Curaga = sets.midcast.Cure
	sets.Self_Healing = {waist="Gishdubar Sash"}
	sets.Cure_Received = {waist="Gishdubar Sash"}
	sets.Self_Refresh = {waist="Gishdubar Sash"}
	sets.Self_Phalanx= {
		main="Sakpata's Sword",
		head=gear.taeon_phalanx_head,
		body=gear.taeon_phalanx_body,
		hands=gear.taeon_phalanx_hands,
		legs=gear.taeon_phalanx_legs,
		feet=gear.taeon_phalanx_feet,
	}

	sets.midcast['Enhancing Magic'] = {main="Colada",sub="Ammurapi Shield",range=empty,ammo="Staunch Tathlum",
		head=gear.telchine_enhancing_head,neck="Dls. Torque +2",ear1="Odnowa Earring +1",ear2="Etiolation Earring",
		body="Viti. Tabard +3",hands="Atrophy Gloves +3",ring1=gear.stikini1,ring2=gear.stikini2,
		back="Ghostfyre Cape",waist="Embla Sash",legs=gear.telchine_enhancing_legs,feet="Leth. Houseaux +2"}

	--Atrophy Gloves are better than Lethargy for me despite the set bonus for duration on others.		
	sets.buff.ComposureOther = {head="Leth. Chappel +2",body="Lethargy Sayon +2",legs="Leth. Fuseau +2",feet="Leth. Houseaux +2"}
		
	--Red Mage enhancing sets are handled in a different way from most, layered on due to the way Composure works
	--Don't set combine a full set with these spells, they should layer on Enhancing Set > Composure (If Applicable) > Spell
	sets.EnhancingSkill = {main="Pukulatmuj +1",head="Umuthi Hat",hands="Viti. Gloves +3",legs="Atrophy Tights +1",neck="Enhancing Torque",waist="Olympus Sash"}
	sets.midcast.Refresh = {head="Amalric Coif +1",body="Atrophy Tabard +3",legs="Leth. Fuseau +2"}
	sets.midcast.Aquaveil = {head="Amalric Coif +1",waist="Emphatikos Rope"}
	sets.midcast.BarElement = {legs="Shedir Seraweels"}
	sets.midcast.Temper = sets.EnhancingSkill
	sets.midcast.Temper.DW = set_combine(sets.midcast.Temper, {sub="Pukulatmuj"})
	sets.midcast.Enspell = sets.midcast.Temper
	sets.midcast.Enspell.DW = set_combine(sets.midcast.Enspell, {sub="Pukulatmuj"})
	sets.midcast.BoostStat = {hands="Viti. Gloves +3"}
	sets.midcast.Stoneskin = {neck="Nodens Gorget",ear2="Earthcry Earring",waist="Siegel Sash",legs="Shedir Seraweels"}
	sets.midcast.Protect = {}
	sets.midcast.Shell = {}
	
	sets.midcast['Enfeebling Magic'] = {    
		main="Crocea Mors",
		sub="Ammurapi Shield",
		ammo="Regal Gem",
		head="Vitiation Chapeau +3", -- AF+3
		body="Lethargy Sayon +2",
		hands="Leth. Gantherots +2",
		legs=gear.chironic_enfeeb_legs,
		feet="Vitiation Boots +3", 
		neck="Dls. Torque +2",
		waist="Luminary Sash", -- Need Acuity +1 + RP
		left_ear="Malignance Earring", -- Need Regal
		right_ear="Snotra Earring", 
		left_ring=gear.stikini1,
		right_ring=gear.stikini2,
		back=gear.mnd_macc_jse_back,
	}
		
	sets.midcast['Enfeebling Magic'].Resistant = set_combine(sets.midcast['Enfeebling Magic'], {})
		
	sets.midcast.DurationOnlyEnfeebling = set_combine(sets.midcast['Enfeebling Magic'], {range="Ullr",ammo=empty,body="AtrophyTabard +3",left_ring="Kishar Ring"}) -- Bind, Sleep, Silence
		
	sets.midcast.Silence = sets.midcast.DurationOnlyEnfeebling
	sets.midcast.Silence.Resistant = sets.midcast['Enfeebling Magic'].Resistant
	sets.midcast.Sleep = set_combine(sets.midcast.DurationOnlyEnfeebling,{})
	sets.midcast.Sleep.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant,{})	
	sets.midcast['Sleep II'] = set_combine(sets.midcast.DurationOnlyEnfeebling,{})
	sets.midcast['Sleep II'].Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant,{})
	sets.midcast.Bind = set_combine(sets.midcast.DurationOnlyEnfeebling,{})
	sets.midcast.Bind.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant,{})
	sets.midcast.Break = set_combine(sets.midcast.DurationOnlyEnfeebling,{})
	sets.midcast.Break.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant,{})
	
	sets.midcast.Dispel = sets.midcast['Enfeebling Magic'].Resistant
	
	sets.midcast.SkillBasedEnfeebling = set_combine(sets.midcast['Enfeebling Magic'], {main="Contemplator +1",sub="Enki Strap",})
	
	sets.midcast['Frazzle II'] = sets.midcast['Enfeebling Magic'].Resistant
	sets.midcast['Frazzle III'] = sets.midcast.SkillBasedEnfeebling -- Frazzle III caps at 625 Enfeeblinf Magic Skill
	sets.midcast['Frazzle III'].Resistant = sets.midcast['Enfeebling Magic'].Resistant
	
	sets.midcast['Distract III'] = sets.midcast.SkillBasedEnfeebling
	sets.midcast['Distract III'].Resistant = sets.midcast['Enfeebling Magic'].Resistant
	
	sets.midcast['Divine Magic'] = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})

	sets.midcast.Dia = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	sets.midcast.Diaga = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	sets.midcast['Dia II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	sets.midcast['Dia III'] = set_combine(sets.midcast['Enfeebling Magic'], {waist="Chaac Belt"})
	
	sets.midcast.Bio = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	sets.midcast['Bio II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	sets.midcast['Bio III'] = set_combine(sets.midcast['Enfeebling Magic'], {head="Viti. Chapeau +3",waist="Chaac Belt",feet=gear.chironic_treasure_feet})

    sets.midcast['Elemental Magic'] = {
	    main="Bunzi's Rod",
		sub="Ammurapi Shield",
		ammo="Ghastly Tathlum +1",
		head="Leth. Chappel +2",
		body="Lethargy Sayon +2",
		hands="Leth. Ganth. +2",
		legs="Leth. Fuseau +2",
		feet="Leth. Houseaux +2",
		neck="Sibyl Scarf",
		waist="Eschan Stone",
		left_ear="Malignance Earring",
		right_ear="Friomisi Earring",
		left_ring="Metamor. Ring +1",
		right_ring="Shiva Ring +1",
		back=gear.intwsd_jse_back,
	}
						
	sets.midcast['Elemental Magic'].HighTierNuke = set_combine(sets.midcast['Elemental Magic'], {}) --ammo="Pemphredo Tathlum"
		
	sets.midcast.Impact = {main="Daybreak",sub="Ammurapi Shield",range="Ullr",ammo=empty,
		head=empty,neck="Erra Pendant",ear1="Regal Earring",ear2="Malignance Earring",
		body="Twilight Cloak",hands="Leth. Gantherots +2",ring1="Metamor. Ring +1",ring2="Stikini Ring +1",
		back=gear.nuke_jse_back,waist="Luminary Sash",legs="Merlinic Shalwar",feet=gear.merlinic_nuke_feet}

	sets.midcast['Dark Magic'] = {main="Rubicundity",sub="Ammurapi Shield",range="Ullr",ammo=empty,
		head="Amalric Coif +1",neck="Erra Pendant",ear1="Regal Earring",ear2="Malignance Earring",
		body="Atrophy Tabard +3",hands="Leth. Gantherots +2",ring1="Metamor. Ring +1",ring2="Stikini Ring +1",
		back=gear.nuke_jse_back,waist="Luminary Sash",legs="Psycloth Lappas",feet=gear.merlinic_nuke_feet}

    sets.midcast.Drain = set_combine(sets.midcast['Elemental Magic'], {head="Pixie Hairpin +1", right_ring="Archon Ring"})

	sets.midcast.Aspir = sets.midcast.Drain
		
	sets.midcast.Stun = {main="Daybreak",sub="Ammurapi Shield",range="Ullr",ammo=empty,
		head="Atrophy Chapeau +3",neck="Dls. Torque +2",ear1="Regal Earring",ear2="Malignance Earring",
		body="Zendik Robe",hands="Volte Gloves",ring1="Metamor. Ring +1",ring2="Stikini Ring +1",
		back=gear.nuke_jse_back,waist="Sailfi Belt +1",legs="Chironic Hose",feet=gear.merlinic_aspir_feet}
		
	sets.midcast.Stun.Resistant = {main="Daybreak",sub="Ammurapi Shield",range="Ullr",ammo=empty,
		head="Atrophy Chapeau +3",neck="Dls. Torque +2",ear1="Regal Earring",ear2="Malignance Earring",
		body="Atrophy Tabard +3",hands="Volte Gloves",ring1="Metamor. Ring +1",ring2="Stikini Ring +1",
		back=gear.nuke_jse_back,waist="Acuity Belt +1",legs="Chironic Hose",feet=gear.merlinic_aspir_feet}

	-- Sets for special buff conditions on spells.
		
	sets.buff.Saboteur = {hands="Leth. Gantherots +2"}
	
	sets.HPDown = {head="Pixie Hairpin +1",ear1=empty,ear2=empty,
		body="Jhakri Robe +2",hands="Jhakri Cuffs +2",ring1="Mephitas's Ring +1",ring2="Mephitas's Ring",
		back="Shadow Mantle",legs="Jhakri Slops +2",feet="Jhakri Pigaches +2"}
		
    sets.HPCure = sets.idle
	
	sets.buff.Doom = set_combine(sets.buff.Doom, {})

	-- Sets to return to when not performing an action.
	
	-- Resting sets
	sets.resting = sets.idle
	

	-- Idle sets
	sets.idle = {
		main="Daybreak",
		sub="Sacro Bulwark",
	    ammo="Homiliary",
		head="Vitiation Chapeau +3",
		body="Lethargy Sayon +2",
		hands="Bunzi's Gloves",
		legs="Bunzi's Pants",
		feet="Bunzi's Sabots",
		--neck="Duelist's Torque +2", -- DYnamis RP Swap
		neck="Warder's Charm +1",
		waist="Carrier's Sash",
		left_ear="Odnowa Earring +1",
		right_ear="Etiolation Earring",
		left_ring=gear.stikini1,
		right_ring=gear.stikini2,
		back=gear.stp_jse_back, -- Need PDT JSE Cape
	}
			
	sets.idle.PDT = sets.idle
		
	sets.idle.MDT = sets.idle
		
	sets.idle.Weak = sets.idle
	
	sets.idle.DTHippo = set_combine(sets.idle.PDT, {})
	
	-- Defense sets
	sets.defense.PDT = sets.idle

	sets.defense.NukeLock = sets.midcast['Elemental Magic']
		
	sets.defense.MDT = sets.idle
		
    sets.defense.MEVA = sets.idle
		
	sets.Kiting = {legs="Carmine Cuisses +1"}
	sets.latent_refresh = {waist="Fucho-no-obi"}
	sets.latent_refresh_grip = {sub="Oneiros Grip"}
	sets.TPEat = {neck="Chrys. Torque"}
	sets.DayIdle = {}
	sets.NightIdle = {}
	
	-- Weapons sets
	sets.weapons.Naegling = {main="Naegling",sub="Machaera +2"}
	sets.weapons.Aeolian = {main="Tauret",sub="Bunzi's Rod"}
	sets.weapons.EnspellOnly = {main="Aern Dagger II",sub="Aern Dagger"}
	sets.weapons.BlackHalo = {main="Maxentius",sub="Machaera +2"}
	sets.weapons.Crocea = {main="Crocea Mors",sub="Daybreak"}
	sets.weapons.Trial = {main="Machaera +1", sub="Gleti's Knife"}
	sets.weapons.Dyna = {main="Naegling", sub="Crocea Mors"}

    sets.buff.Sublimation = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}

	-- Engaged sets

	-- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
	-- sets if more refined versions aren't defined.
	-- If you create a set with both offense and defense modes, the offense mode should be first.
	-- EG: sets.Dagger.Accuracy.Evasion
	
	-- Normal melee group

	sets.engaged = {    
		main="Crocea Mors",
		sub="Daybreak",
		ammo="Coiste Bodhar",
		head="Malignance Chapeau",
		body="Malignance Tabard",
		hands="Malignance Gloves",
		legs="Malignance Tights",
		feet="Malignance Boots",
		--neck="Duelist's Torque +2", -- DYnamis RP Swap
		neck="Anu Torque",
		waist="Windbuffet Belt +1",
		left_ear="Telos Earring",
		right_ear="Sherida Earring",
		left_ring="Petrov Ring",
		right_ring="Chirich Ring +1",
		back=gear.stp_jse_back,
	}
		
	sets.engaged.DW = set_combine(sets.engaged, {waist="Reiki Yotai",left_ear="Suppanomimi",})
	
	sets.engaged.EnspellOnly = {
		ammo="Coiste Bodhar",
		head="Umuthi Hat",
		body="Ayanmo Corazza +2",
		hands="Aya. Manopolas +2",
		legs="Carmine Cuisses +1",
		feet="Malignance Boots",
		neck="Maskirova Torque",
		waist="Orpheus's Sash",
		left_ear="Suppanomimi",
		right_ear="Telos Earring",
		left_ring="Petrov Ring",
		right_ring="Chirich Ring +1",
		back=gear.stp_jse_back,
	}
	


end


-- Select default macro book on initial load or subjob change.
-- Default macro set/book
function select_default_macro_book()
	if player.sub_job == 'DNC' then
		set_macro_page(4, 8)
	elseif player.sub_job == 'NIN' then
		set_macro_page(4, 8)
	elseif player.sub_job == 'BLM' then
		set_macro_page(2, 8)
	else
		set_macro_page(3, 8)
	end
end

--Job Specific Trust Overwrite
function check_trust()
	if not moving then
		if state.AutoTrustMode.value and not data.areas.cities:contains(world.area) and (buffactive['Elvorseal'] or buffactive['Reive Mark'] or not player.in_combat) then
			local party = windower.ffxi.get_party()
			if party.p5 == nil then
				local spell_recasts = windower.ffxi.get_spell_recasts()

				if spell_recasts[980] < spell_latency and not have_trust("Yoran-Oran") then
					windower.chat.input('/ma "Yoran-Oran (UC)" <me>')
					tickdelay = os.clock() + 3
					return true
				elseif spell_recasts[984] < spell_latency and not have_trust("August") then
					windower.chat.input('/ma "August" <me>')
					tickdelay = os.clock() + 3
					return true
				elseif spell_recasts[967] < spell_latency and not have_trust("Qultada") then
					windower.chat.input('/ma "Qultada" <me>')
					tickdelay = os.clock() + 3
					return true
				elseif spell_recasts[914] < spell_latency and not have_trust("Ulmia") then
					windower.chat.input('/ma "Ulmia" <me>')
					tickdelay = os.clock() + 3
					return true
				elseif spell_recasts[979] < spell_latency and not have_trust("Selh'teus") then
					windower.chat.input('/ma "Selh\'teus" <me>')
					tickdelay = os.clock() + 3
					return true
				else
					return false
				end
			end
		end
	end
	return false
end

function user_job_buff_change(buff, gain)
	if buff:startswith('Addendum: ') or buff:endswith(' Arts') then
		style_lock = true
	end
end

function user_job_lockstyle()
	if player.sub_job == 'NIN' or player.sub_job == 'DNC' then
		if player.equipment.main == nil or player.equipment.main == 'empty' then
			windower.chat.input('/lockstyleset 011')
		elseif res.items[item_name_to_id(player.equipment.main)].skill == 3 then --Sword in main hand.
			if res.items[item_name_to_id(player.equipment.sub)].skill == 3 then --Sword/Sword.
				windower.chat.input('/lockstyleset 011')
			elseif res.items[item_name_to_id(player.equipment.sub)].skill == 2 then --Sword/Dagger.
				windower.chat.input('/lockstyleset 011')
			elseif res.items[item_name_to_id(player.equipment.sub)].skill == 11 then --Sword/Club.
				windower.chat.input('/lockstyleset 011')
			else
				windower.chat.input('/lockstyleset 011') --Catchall
			end
		elseif res.items[item_name_to_id(player.equipment.main)].skill == 2 then --Dagger in main hand.
			if res.items[item_name_to_id(player.equipment.sub)].skill == 3 then --Dagger/Sword.
				windower.chat.input('/lockstyleset 011')
			elseif res.items[item_name_to_id(player.equipment.sub)].skill == 2 then --Dagger/Dagger.
				windower.chat.input('/lockstyleset 011')
			elseif res.items[item_name_to_id(player.equipment.sub)].skill == 11 then --Dagger/Club.
				windower.chat.input('/lockstyleset 011')
			else
				windower.chat.input('/lockstyleset 011') --Catchall
			end
		elseif res.items[item_name_to_id(player.equipment.main)].skill == 11 then --Club in main hand.
			if res.items[item_name_to_id(player.equipment.sub)].skill == 3 then --Club/Sword.
				windower.chat.input('/lockstyleset 011')
			elseif res.items[item_name_to_id(player.equipment.sub)].skill == 2 then --Club/Dagger.
				windower.chat.input('/lockstyleset 011')
			elseif res.items[item_name_to_id(player.equipment.sub)].skill == 11 then --Club/Club.
				windower.chat.input('/lockstyleset 011')
			else
				windower.chat.input('/lockstyleset 011') --Catchall
			end
		end
	elseif player.sub_job == 'WHM' or state.Buff['Light Arts'] or state.Buff['Addendum: White'] then
		windower.chat.input('/lockstyleset 011')
	elseif player.sub_job == 'BLM' or state.Buff['Dark Arts'] or state.Buff['Addendum: Black'] then
		windower.chat.input('/lockstyleset 011')
	else
		windower.chat.input('/lockstyleset 011')
	end
end