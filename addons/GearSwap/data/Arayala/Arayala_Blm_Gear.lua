function user_job_setup()
	-- Options: Override default values
	state.CastingMode:options('Burst','Normal','Resistant','Fodder','Proc','OccultAcumen')
	state.OffenseMode:options('Normal')
	state.IdleMode:options('Normal','DT')
	state.Weapons:options('Marin','Bunzi','None')

	gear.obi_cure_waist = "Witful Belt"
	gear.obi_low_nuke_waist = "Sekhmet Corset"
	gear.obi_high_nuke_waist = "Refoccilation Stone"
	
	state.RecoverMode = M('15%','Never','35%', '60%', 'Always')
	
	gear.nuke_jse_back = { name="Taranus's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','"Mag.Atk.Bns."+10','Phys. dmg. taken-10%',}}
	gear.FC_jse_back = { name="Taranus's Cape", augments={'MP+60','Eva.+20 /Mag. Eva.+20','"Fast Cast"+10','Phys. dmg. taken-10%',}}

		-- Additional local binds
	send_command('bind ^` gs c cycle ElementalMode') 
	send_command('bind ~^` gs c cycleback ElementalMode') --Robbiewobbie's idea
	send_command('bind ^q gs c weapons Khatvanga;gs c set CastingMode OccultAcumen')
	send_command('bind !q gs c weapons Default;gs c reset CastingMode;gs c reset DeathMode;gs c reset MagicBurstMode')
	send_command('bind !r gs c set DeathMode Single;gs c set MagicBurstMode Single')
	send_command('bind !\\\\ input /ja "Manawell" <me>')
	send_command('bind !` input /ma "Aspir III" <t>')
	send_command('bind @` gs c cycle MagicBurstMode')
	send_command('bind @f10 gs c cycle RecoverMode')
	send_command('bind @f9 gs c cycle DeathMode')
	send_command('bind @^` input /ja "Parsimony" <me>')
	send_command('bind !pause gs c toggle AutoSubMode') --Automatically uses sublimation and Myrkr.
	send_command('bind ^backspace input /ma "Stun" <t>')
	send_command('bind !backspace input /ja "Enmity Douse" <t>')
	send_command('bind @backspace input /ja "Alacrity" <me>')
	send_command('bind != input /ja "Light Arts" <me>')
	send_command('bind @= input /ja "Addendum: White" <me>')
	send_command('bind ^delete input /ja "Dark Arts" <me>')
	send_command('bind !delete input /ja "Addendum: Black" <me>')
	send_command('bind @delete input /ja "Manifestation" <me>')
    
	select_default_macro_book()
end

function init_gear_sets()

    --------------------------------------
    -- Start defining the sets
    --------------------------------------
	
	-- Weapons sets
	sets.weapons.Marin = {main="Marin Staff +1",sub="Enki Strap"}
	sets.weapons.Bunzi = {main="Bunzi's Rod",sub="Ammurapi Shield"}
	--sets.weapons.Khatvanga = {main="Khatvanga",sub="Bloodrain Strap"}
	
    sets.buff.Sublimation = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}	
	
	-- Treasure Hunter
	
	sets.TreasureHunter = set_combine(sets.TreasureHunter, {})
    
    ---- Precast Sets ----
    
    -- Precast sets to enhance JAs
    sets.precast.JA['Mana Wall'] = {back=gear.FC_jse_back,feet="Wicce Sabots +3"}

    sets.precast.JA.Manafont = {} --body="Sorcerer's Coat +2"
    
    -- equip to maximize HP (for Tarus) and minimize MP loss before using convert
    sets.precast.JA.Convert = {}


    -- Fast cast sets for spells

    sets.precast.FC = {    -- Currently 82% - Need Sapience Orb + capped Merlinic Head/Feet augs + 4% FC neck > swap JSE cape for Perimede to cap FC + QC
		head=gear.merlinic_FC_head,
		body=gear.merlinic_FC_body,
		hands=gear.merlinic_FC_hands,
		legs="Agwu's Slops",
		feet=gear.merlinic_FC_feet,
		neck="Nodens Gorget",
		waist="Witful Belt",
		left_ear="Malignance Earring",
		right_ear="Loquac. Earring",
		left_ring="Weather. Ring",
		right_ring="Kishar Ring",
		back=gear.FC_jse_back,
	}
		
    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {})
	
	sets.precast.FC.Stoneskin = set_combine(sets.precast.FC['Enhancing Magic'], {})

    sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, {ammo="Staunch Tathlum", body="Nyame Mail", hands="Nyame Gauntlets", feet="Agwu's Pigaches", right_ring="Defending Ring",back="Perimede Cape",})

	sets.precast.FC.Cure = set_combine(sets.precast.FC, {})

    sets.precast.FC.Curaga = sets.precast.FC.Cure
	
	sets.precast.FC.Impact = set_combine(sets.precast.FC, {head=empty,body="Twilight Cloak"})
	sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {main="Daybreak",sub="Genmei Shield"})

	sets.precast.FC.Death = set_combine(sets.precast.FC, {})

    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {ammo="Dosis Tathlum",
		head="Hagondes Hat +1",neck="Saevus Pendant +1",ear1="Friomisi Earring",ear2="Crematio Earring",
		body="Jhakri Robe +2",hands="Jhakri Cuffs +2",ring1="Freke Ring",ring2="Shiva Ring +1",
		back=gear.nuke_jse_back,waist="Fotia Belt",legs="Jhakri Slops +2",feet="Jhakri Pigaches +2"}

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS['Vidohunir'] = {ammo="Dosis Tathlum",
		head="Hagondes Hat +1",neck="Saevus Pendant +1",ear1="Friomisi Earring",ear2="Crematio Earring",
		body="Zendik Robe",hands="Hagondes Cuffs +1",ring1="Freke Ring",ring2="Shiva Ring +1",
		back=gear.nuke_jse_back,waist="Fotia Belt",legs="Hagondes Pants +1",feet=gear.merlinic_nuke_feet}

    sets.precast.WS['Myrkr'] = {    
		ammo="Ghastly Tathlum +1",
		head={ name="Vanya Hood", augments={'MP+50','"Fast Cast"+10','Haste+2%',}},
		body="Wicce Coat +3",
		hands="Nyame Gauntlets",
		legs="Wicce Chausses +3",
		feet="Nyame Sollerets",
		neck="Nodens Gorget",
		waist="Luminary Sash",
		left_ear="Moonshade Earring",
		right_ear="Etiolation Earring",
		left_ring="Metamor. Ring +1",
		right_ring="Mephitas's Ring",
		back=gear.FC_jse_back,
	}
		
	sets.MaxTPMyrkr = {left_ear="Mendicant's Earring"}
    
    
    ---- Midcast Sets ----

    sets.midcast.FastRecast = set_combine(sets.precast.FC, {})

    sets.midcast.Cure = {main=gear.gada_healing_club,sub="Sors Shield",ammo="Hasty Pinion +1",
        head="Vanya Hood",neck="Incanter's Torque",ear1="Gifted Earring",ear2="Etiolation Earring",
        body="Zendik Robe",hands="Telchine Gloves",ring1="Janniston Ring",ring2="Menelaus's Ring",
        back="Tempered Cape +1",waist="Witful Belt",legs="Psycloth Lappas",feet="Vanya Clogs"}
		
    sets.midcast.LightWeatherCure = {main="Chatoyant Staff",sub="Curatio Grip",ammo="Hasty Pinion +1",
        head="Vanya Hood",neck="Phalaina Locket",ear1="Gifted Earring",ear2="Etiolation Earring",
        body="Heka's Kalasiris",hands="Telchine Gloves",ring1="Janniston Ring",ring2="Menelaus's Ring",
        back="Twilight Cape",waist="Hachirin-no-Obi",legs="Psycloth Lappas",feet="Vanya Clogs"}
		
		--Cureset for if it's not light weather but is light day.
    sets.midcast.LightDayCure = {main="Serenity",sub="Curatio Grip",ammo="Hasty Pinion +1",
        head="Vanya Hood",neck="Phalaina Locket",ear1="Gifted Earring",ear2="Etiolation Earring",
        body="Zendik Robe",hands="Telchine Gloves",ring1="Janniston Ring",ring2="Menelaus's Ring",
        back="Twilight Cape",waist="Hachirin-no-Obi",legs="Psycloth Lappas",feet="Vanya Clogs"}

    sets.midcast.Curaga = sets.midcast.Cure
	
	sets.midcast.Cursna =  set_combine(sets.midcast.Cure, {neck="Debilis Medallion",hands="Hieros Mittens",ring1="Haoma's Ring",ring2="Menelaus's Ring",back="Oretan. Cape +1"})
	
	sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {main=gear.grioavolr_fc_staff,sub="Clemency Grip"})

	sets.midcast['Enhancing Magic'] = {main=gear.gada_enhancing_club,sub="Ammurapi Shield",ammo="Hasty Pinion +1",
		head="Telchine Cap",neck="Incanter's Torque",ear1="Andoaa Earring",ear2="Gifted Earring",
		body="Telchine Chas.",hands="Telchine Gloves",ring1="Stikini Ring +1",ring2="Stikini Ring +1",
		back="Perimede Cape",waist="Embla Sash",legs="Telchine Braconi",feet="Telchine Pigaches"}
    
    sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {neck="Nodens Gorget",ear2="Earthcry Earring",waist="Siegel Sash",legs="Shedir Seraweels"})
	
	sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {head="Amalric Coif +1"})
	
	sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'], {main="Vadose Rod",sub="Genmei Shield",head="Amalric Coif +1",hands="Regal Cuffs",waist="Emphatikos Rope",legs="Shedir Seraweels"})
	
	sets.midcast.BarElement = set_combine(sets.precast.FC['Enhancing Magic'], {legs="Shedir Seraweels"})

    sets.midcast['Enfeebling Magic'] = { -- NEEDS MAJOR WORK DO AT A LATER DATE
		ammo="Ghastly Tathlum +1", --Pemp
		head="Ea Hat +1", --Wicce +3
		body="Spaekona's Coat +2", -- +3
		hands="Spae. Gloves +3", -- +3
		legs="Wicce Chausses +3", -- Relic +3
		feet="Agwu's Pigaches", -- Relic +3
		neck="Src. Stole +2",
		waist="Luminary Sash", -- Acuity +1
		left_ear="Malignance Earring",
		right_ear="Regal Earring",
		left_ring=gear.stikini1,
		right_ring="Metamor. Ring +1",
		back=gear.nuke_jse_back,
	}
		
    sets.midcast['Enfeebling Magic'].Resistant = {main="Bunzi's Rod",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Befouled Crown",neck="Erra Pendant",ear1="Digni. Earring",ear2="Regal Earring",
        body="Vanya Robe",hands="Regal Cuffs",ring1="Stikini Ring +1",ring2="Metamor. Ring +1",
        back=gear.nuke_jse_back,waist="Luminary Sash",legs="Psycloth Lappas",feet="Skaoi Boots"}
	
		-- Elemental Debuffs
    sets.midcast.ElementalEnfeeble = {
	    ammo="Ghastly Tathlum +1", --Pemp
		head="Wicce Petasos +2", 
		body="Spaekona's Coat +3",
		hands="Spae. Gloves +3",
		legs="Archmage's Tonban +3",
		feet="Archmage's Sabots +3",
		neck="Src. Stole +2",
		waist="Acuity Belt +1",
		left_ear="Malignance Earring",
		right_ear="Regal Earring",
		left_ring=gear.stikini1,
		right_ring="Metamor. Ring +1",
		back=gear.nuke_jse_back,
	}
    sets.midcast.ElementalEnfeeble.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {head="Amalric Coif +1",waist="Acuity Belt +1"})
	
	sets.midcast.IntEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {head="Amalric Coif +1",ear1="Malignance Earring",waist="Acuity Belt +1"})
	sets.midcast.IntEnfeebles.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {head="Amalric Coif +1",ear1="Malignance Earring",waist="Acuity Belt +1"})

	sets.midcast.MndEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {})
	sets.midcast.MndEnfeebles.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})
	
	sets.midcast.Dia = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	sets.midcast['Dia II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	
	sets.midcast.Bio = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	sets.midcast['Bio II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	
	sets.midcast['Divine Magic'] = set_combine(sets.midcast['Enfeebling Magic'], {})

    sets.midcast['Dark Magic'] = {main="Rubicundity",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Amalric Coif +1",neck="Erra Pendant",ear1="Malignance Earring",ear2="Regal Earring",
        body=gear.merlinic_nuke_body,hands="Amalric Gages +1",ring1="Stikini Ring +1",ring2="Metamor. Ring +1",
        back=gear.nuke_jse_back,waist="Acuity Belt +1",legs="Merlinic Shalwar",feet=gear.merlinic_aspir_feet}

    sets.midcast.Drain = {main="Rubicundity",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Pixie Hairpin +1",neck="Erra Pendant",ear1="Malignance Earring",ear2="Regal Earring",
        body=gear.merlinic_nuke_body,hands="Amalric Gages +1",ring1="Evanescence Ring",ring2="Archon Ring",
        back=gear.nuke_jse_back,waist="Fucho-no-obi",legs="Merlinic Shalwar",feet=gear.merlinic_aspir_feet}
    
    sets.midcast.Aspir = sets.midcast.Drain
	
	sets.midcast.Aspir.Death = {main=gear.grioavolr_nuke_staff,sub="Enki Strap",ammo="Pemphredo Tathlum",
        head="Pixie Hairpin +1",neck="Erra Pendant",ear1="Malignance Earring",ear2="Regal Earring",
        body=gear.merlinic_nuke_body,hands="Amalric Gages +1",ring1="Evanescence Ring",ring2="Archon Ring",
        back=gear.nuke_jse_back,waist="Fucho-no-obi",legs="Merlinic Shalwar",feet=gear.merlinic_aspir_feet}
	
	sets.midcast.Death = {main=gear.grioavolr_nuke_staff,sub="Enki Strap",ammo="Pemphredo Tathlum",
        head="Pixie Hairpin +1",neck="Mizu. Kubikazari",ear1="Malignance Earring",ear2="Etiolation Earring",
        body=gear.merlinic_nuke_body,hands="Amalric Gages +1",ring1="Mujin Band",ring2="Archon Ring",
        back=gear.nuke_jse_back,waist=gear.ElementalObi,legs="Merlinic Shalwar",feet=gear.merlinic_nuke_feet}

    sets.midcast.Stun = {main=gear.grioavolr_fc_staff,sub="Clerisy Strap +1",ammo="Hasty Pinion +1",
        head="Amalric Coif +1",neck="Voltsurge Torque",ear1="Enchntr. Earring +1",ear2="Malignance Earring",
        body="Zendik Robe",hands="Volte Gloves",ring1="Stikini Ring +1",ring2="Metamor. Ring +1",
        back=gear.nuke_jse_back,waist="Witful Belt",legs="Psycloth Lappas",feet="Regal Pumps +1"}
		
    sets.midcast.Stun.Resistant = {main="Daybreak",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Amalric Coif +1",neck="Erra Pendant",ear1="Malignance Earring",ear2="Regal Earring",
        body="Zendik Robe",hands="Volte Gloves",ring1="Stikini Ring +1",ring2="Metamor. Ring +1",
        back=gear.nuke_jse_back,waist="Witful Belt",legs="Merlinic Shalwar",feet=gear.merlinic_aspir_feet}

    sets.midcast.BardSong = {main="Daybreak",sub="Ammurapi Shield",ammo="Dosis Tathlum",
        head="Amalric Coif +1",neck="Sanctity Necklace",ear1="Digni. Earring",ear2="Regal Earring",
        body="Zendik Robe",hands="Regal Cuffs",ring1="Stikini Ring +1",ring2="Metamor. Ring +1",
        back=gear.nuke_jse_back,waist="Luminary Sash",legs="Merlinic Shalwar",feet="Medium's Sabots"}
		
	sets.midcast.Impact = {main="Daybreak",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
		head=empty,neck="Erra Pendant",ear1="Malignance Earring",ear2="Regal Earring",
		body="Twilight Cloak",hands="Regal Cuffs",ring1="Stikini Ring +1",ring2="Metamor. Ring +1",
		back=gear.nuke_jse_back,waist="Acuity Belt +1",legs="Merlinic Shalwar",feet=gear.merlinic_aspir_feet}
		
    -- Elemental Magic sets
    
    sets.midcast['Elemental Magic'] = {
	    ammo="Ghastly Tathlum +1",
		head="Wicce Petasos +2",
		body="Wicce Coat +3",
		hands="Wicce Gloves +2",
		legs="Wicce Chausses +3",
		feet="Wicce Sabots +3",
		neck="Src. Stole +2",
		waist="Acuity Belt +1",
		left_ear="Malignance Earring",
		right_ear="Regal Earring",
		left_ring="Metamor. Ring +1",
		right_ring="Freke Ring",
		back=gear.nuke_jse_back,
	}
	
	sets.midcast['Elemental Magic'].Burst = set_combine(sets.midcast['Elemental Magic'], {head="Ea hat +1", hands="Agwu's Gages"})
    sets.midcast['Elemental Magic'].Resistant = set_combine(sets.midcast['Elemental Magic'], {})
    sets.midcast['Elemental Magic'].Fodder = set_combine(sets.midcast['Elemental Magic'], {})
	
	-- High Tier Nuke Spells
	sets.midcast['Elemental Magic'].HighTierNuke = set_combine(sets.midcast['Elemental Magic'], {})
	
	sets.midcast['Elemental Magic'].HighTierNuke.Burst = set_combine(sets.midcast['Elemental Magic'].Burst, {})
	sets.midcast['Elemental Magic'].HighTierNuke.Resistant = set_combine(sets.midcast['Elemental Magic'].HighTierNuke, {})
	sets.midcast['Elemental Magic'].HighTierNuke.Fodder = set_combine(sets.midcast['Elemental Magic'].HighTierNuke, {})
	
	
	
	sets.midcast.Helix = sets.midcast['Elemental Magic']
	sets.midcast.Helix.Resistant = sets.midcast['Elemental Magic'].Resistant
		
		-- Minimal damage gear, maximum recast gear for procs.
    sets.midcast['Elemental Magic'].Proc = {}
		
    sets.midcast['Elemental Magic'].OccultAcumen = {}
		
    sets.midcast.Impact.OccultAcumen = set_combine(sets.midcast['Elemental Magic'].OccultAcumen, {head=empty,body="Twilight Cloak"})
	
    -- Sets to return to when not performing an action.  

    -- Idle sets
    
    -- Normal refresh idle set
    sets.idle = {    
		ammo="Staunch Tathlum",
		head="Nyame Helm",
		body="Wicce Coat +3",
		hands="Volte Gloves",
		legs="Nyame Flanchard",
		feet="Mallquis Clogs +2",
		neck="Loricate Torque +1", 		-- Dynamis Swap 
		--neck="Sorcerer's Stole +2", 		-- Dynamis Swap 
		waist="Carrier's Sash",
		left_ear="Lugalbanda Earring",
		right_ear="Etiolation Earring",
		left_ring=gear.stikini1,
		right_ring=gear.stikini2,
		back=gear.FC_jse_back,
	}

    -- Idle mode that keeps PDT gear on, but doesn't prevent normal gear swaps for precast/etc.
    sets.idle.DT = set_combine(sets.idle, {hands="Nyame Gauntlets"})
		
	sets.idle.DTHippo = set_combine(sets.idle.PDT, {feet="Hippo. Socks +1"})

	sets.idle.Death = set_combine(sets.idle, {})

    sets.idle.Weak = set_combine(sets.idle, {})

    -- Resting sets
    sets.resting = set_combine(sets.idle, {})
	
	-- Defense sets

    sets.defense.PDT = {main="Malignance Pole",sub="Umbra Strap",ammo="Staunch Tathlum",
        head="Hagondes Hat +1",neck="Loricate Torque +1",ear1="Genmei Earring",ear2="Etiolation Earring",
        body="Mallquis Saio +2",hands="Hagondes Cuffs +1",ring1="Defending Ring",ring2="Dark Ring",
        back="Shadow Mantle",waist="Flax Sash",legs="Hagondes Pants +1",feet="Mallquis Clogs +2"}

    sets.defense.MDT = {main="Malignance Pole",sub="Umbra Strap",ammo="Staunch Tathlum",
        head="Hagondes Hat +1",neck="Loricate Torque +1",ear1="Genmei Earring",ear2="Etiolation Earring",
        body="Mallquis Saio +2",hands="Hagondes Cuffs +1",ring1="Defending Ring",ring2="Shadow Ring",
        back="Solemnity Cape",waist="Flax Sash",legs="Hagondes Pants +1",feet="Mallquis Clogs +2"}
		
    sets.defense.MEVA = {main="Malignance Pole",sub="Enki Strap",ammo="Staunch Tathlum",
        head=gear.merlinic_nuke_head,neck="Warder's Charm +1",ear1="Sanare Earring",ear2="Etiolation Earring",
		body=gear.merlinic_nuke_body,hands="Amalric Gages +1",ring1="Vengeful Ring",ring2="Purity Ring",
        back=gear.nuke_jse_back,waist="Luminary Sash",legs="Hagondes Pants +1",feet=gear.merlinic_nuke_feet}

	sets.Kiting = {feet="Herald's Gaiters"}
    sets.latent_refresh = {waist="Fucho-no-obi"}
	sets.latent_refresh_grip = {}
	sets.TPEat = {neck="Chrys. Torque"}
	sets.DayIdle = {}
	sets.NightIdle = {}
	
    -- Buff sets: Gear that needs to be worn to actively enhance a current player buff.
	
	sets.HPDown = {head="Pixie Hairpin +1",ear1="Genmei Earring",ear2="Evans Earring",
		body="Jhakri Robe +2",hands="Jhakri Cuffs +2",ring1="Mephitas's Ring +1",ring2="Mephitas's Ring",
		back="Swith Cape +1",legs="Shedir Seraweels",feet="Jhakri Pigaches +2"}
		
	sets.HPCure = {main=gear.gada_healing_club,sub="Sors Shield",ammo="Hasty Pinion +1",
		head="Blistering Sallet +1",neck="Nodens Gorget",ear1="Etiolation Earring",ear2="Ethereal Earring",
		body="Vrikodara Jupon",hands="Telchine Gloves",ring1="Kunaji Ring",ring2="Meridian Ring",
		back="Tempered Cape +1",waist="Witful Belt",legs="Psycloth Lappas",feet="Vanya Clogs"}
	
	sets.buff.Doom = set_combine(sets.buff.Doom, {})
    sets.buff['Mana Wall'] = {back=gear.nuke_jse_back,hands="Nyame Gauntlets",feet="Wicce Sabots +3", right_ring="Defending Ring"}
	
	-- Gear that converts elemental damage done to recover MP.	
	sets.RecoverMP = {body="Spaekona's Coat +3"}
	-- Gear for Magic Burst mode.
    sets.MagicBurst = {main=gear.grioavolr_nuke_staff,sub="Enki Strap",head="Ea Hat",body="Ea Houppelande",hands="Amalric Gages +1",ring1="Mujin Band",legs="Ea Slops",feet="Jhakri Pigaches +2"}
	sets.ResistantMagicBurst = {main=gear.grioavolr_nuke_staff,sub="Enki Strap",head="Ea Hat",body="Ea Houppelande",hands="Amalric Gages +1",ring1="Mujin Band",legs="Ea Slops",feet="Jhakri Pigaches +2"}
	
	-- Gear for specific elemental nukes.
	sets.element.Dark = {head="Pixie Hairpin +1",ring2="Archon Ring"}

    -- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion
    
    -- Normal melee group
    sets.engaged = {ammo="Staunch Tathlum",
        head="Jhakri Coronal +2",neck="Combatant's Torque",ear1="Mache Earring +1",ear2="Telos Earring",
		body="Jhakri Robe +2",hands="Jhakri Cuffs +2",ring1="Ramuh Ring +1",ring2="Ramuh Ring +1",
		back=gear.stp_jse_back,waist="Olseni Belt",legs="Jhakri Slops +2",feet="Jhakri Pigaches +2"}

	--Situational sets: Gear that is equipped on certain targets
	sets.Self_Healing = {neck="Phalaina Locket",ring1="Kunaji Ring",ring2="Asklepian Ring",waist="Gishdubar Sash"}
	sets.Cure_Received = {neck="Phalaina Locket",ring1="Kunaji Ring",ring2="Asklepian Ring",waist="Gishdubar Sash"}
	sets.Self_Refresh = {back="Grapevine Cape",waist="Gishdubar Sash",feet="Inspirited Boots"}
		
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    set_macro_page(1, 7)
end