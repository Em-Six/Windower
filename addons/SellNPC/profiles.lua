-- Add items to existing profiles or create your own to sell groups of items using alias commands
local profiles = {}

-- //sellnpc powder
profiles['powder'] = S{
    'prize powder',
    }

-- //sellnpc ore
profiles['ore'] = S{
    'iron ore',
    'copper ore',
    'tin ore',
    }

-- //sellnpc junk
profiles['junk'] = S{
    'Carrier Crab Carapace',
    'Kazham Peppers',
    'Mhaura Garlic',
    'Vanilla',
    'Sage',
    'Deathball',
    'Voay Sword -1',
    'Black Pepper',
    'Habaneros',
    'Bay Leaves',
    'Akaso',
    'Kapor Log',
    'Bismuth Ore',
    'Fire Fewell',
    'Earth Fewell',
    'Water Fewell',
    'Wind Fewell',
    'Ice Fewell',
    'Lightning Fewell',
    'Dark Fewell',
    'Light Fewell',
    'Wind Crystal', 
    'Ice Crystal', 
    'Dark Crystal', 
    'Light Crystal', 
    'Fire Crystal', 
    'Water Crystal', 
    'Earth Crystal', 
    'Lightng. Crystal', 
    'Potion', 
    'Gugru Tuna', 
    'Cobalt Jellyfish', 
    'Shall Shell', 
    'Dragon Fruit', 
    'Gigant Squid', 
    'Bluetail', 
    'Mackerel', 
    'Moorish Idol', 
    'Grimmonite', 
    'Millioncorn', 
    'Kukuru Bean', 
    'Puffball', 
    'Sunflower Seeds', 
    'Poison Flour', 
    'Blue Peas', 
    'Kopparnickel Ore', 
    'Pugil Scales', 
    'Uragnite Shell', 
    'Ram Horn', 
    'Dragon Bone', 
    'Turtle Shell', 
    'Swamp Ore', 
    'Fish Bones', 
    'Aht Urhgan Brass', 
    'Iron Ore', 
    'Gold Ore', 
    'Pebble', 
    'Platinum Ore', 
    'H.Q. Scp. Shell', 
    'Bone Chip', 
    'Meteorite', 
    'Phrygian Ore', 
    'Zinc Ore', 
    'Elshimo Newt', 
    'Moat Carp', 
    'Copper Frog', 
    'Gavial Fish', 
    'Crescent Fish', 
    'Giant Catfish', 
    'Ca Cuong', 
    'Yorchete', 
    'Pamamas', 
    'Walnut', 
    'Guatambu Log', 
    'Chestnut Log', 
    'Arrowwood Log', 
    'Maple Log', 
    'Grove Cuttings', 
    'Walnut Log', 
    'Elm Log', 
    'Urunday Log', 
    'Dogwood Log', 
    'Mahogany Log', 
    'Felicifruit', 
    'King Locust', 
    'Yagudo Cherry', 
    'Persikos', 
    'Divine Log', 
    'Oak Log', 
    'El. Pachira Fruit', 
    'Flax Flower', 
    'Skull Locust', 
    'Wijnruit', 
    'Red Rose', 
    'Watermelon', 
    'Red Moko Grass', 
    'Dark Bass', 
    'Gold Carp', 
    'Black Eel', 
    'Igneous Rock', 
    'Snapping Mole', 
    'Darksteel Ore', 
    'Khroma Ore', 
    'Tin Ore', 
    'Scorpion Shell', 
    'H.Q. Crab Shell', 
    'Scorpion Claw', 
    'Marguerite', 
    'Ulbukan Lobster', 
    'Yayinbaligi', 
    'Pipira', 
    'Ruddy Seema', 
    'Eggplant', 
    'Saruta Cotton', 
    'Ulbuconut', 
    'Antlion Jaw', 
    'Copper Ore', 
    'Auric Sand', 
    'Dst. Nugget', 
    'Orichalcum Ore', 
    'Vanadium Ore', 
    'Voay Staff -1', 
    'Contortopus', 
    'Adoulinian Kelp', 
    'Black Prawn', 
    'Black Sole', 
    'Dragon Talon', 
    'Mythril Ore', 
    'Beetle Jaw', 
    'Crab Shell', 
    'Brass Loach', 
    'Rusty Bucket', 
    'Tree Cuttings', 
    'Ash Log', 
    'Spider Web', 
    'Fresh Marjoram', 
    'Yagudo Drink', 
    'Three-eyed Fish', 
    'Cone Calamary', 
    'Zebra Eel', 
    'Quus', 
    'Bastore Bream', 
    'Titanictus', 
    'Tarutaru Rice', 
    'Rye Flour', 
    'Adaman Ore', 
    'Crayfish', 
    'Lacquer Tree Log', 
    'Insect Wing', 
    'Rolanberry', 
    'Napa', 
    'Lesser Chigoe', 
    'Bloodblotch', 
    'Bat Fang', 
    'Ebony Log', 
    'Fresh Mugwort', 
    'Pine Nuts', 
    'Crawler Cocoon', 
    'Acorn', 
    'Black Ghost', 
    'Faerie Apple', 
    'Red Terrapin', 
    'Barnacle', 
    'Little Worm', 
    'Vegetable Seeds', 
    'Chestnut', 
    'Coral Fungus', 
    'Bhefhel Marlin', 
    'Dwarf Remora', 
    'Win. Tea Leaves', 
    'Sheep Tooth', 
    'Blk. Tiger Fang', 
    'Wootz Ore', 
    'Bugard Tusk', 
    'Loc. Elutriator', 
    'Senroh Sardine', 
    'Silver Ore', 
    'Green Rock', 
    'Giant Stinger', 
    'Burdock', 
    'La Theine Cbg.', 
    'Grain Seeds', 
    'Pumpkin Pie', 
    'Nopales', 
    'San d\'Or. Flour', 
    'Dryad Root', 
    'Crawler Egg', 
    'Semolina', 
    'Tiny Goldfish', 
    'Woozyshroom', 
    'Matsya', 
    'Dragonfish', 
    'Flint Stone', 
    'Velkk Necklace', 
    'Velkk Mask', 
    'Matamata Shell', 
    'Titanium Ore', 
    'Moko Grass', 
    'Emperor Fish', 
    'Isleracea', 
    'Cactus Stems', 
    'Wivre Maul',
    'Raptor Skin',
    'Peiste Skin',
    'Slime Juice',
    'Infinity Core',
    'Acheron Shield',
	}

return profiles
