do
	local p = get_player()
	if not p then return end

    local protection = false -- State of protection
    local anon_names = false -- State of anon
    local dressup = false -- Determines if dressup should be reloaded
    local dressup_enable = false

    local name_cache = {} -- Real-to-Fake name cache
    local reverse_name_cache = {} -- Fake-to-Real name cache
    
    local ls_cache = {} -- Real-to-Fake LS cache
    local reverse_ls_cache = {} -- Fake-to-Real LS cache

    local anon_cache = {} -- Real-to-Fake other players cache
    local reverse_anon_cache = {} -- Fake-to-Real other players cache

    local all_filtered_packets = {
        [0x00A] = {['name_field'] = 'Player Name',      ['id_field'] = 'Player',        }, -- Zone update
        [0x0DD] = {['name_field'] = 'Name',             ['id_field'] = 'ID',            }, -- Party Member Udpate
        [0x00D] = {['name_field'] = 'Character Name',   ['id_field'] = 'Player',        }, -- PC Update
        [0x0E2] = {['name_field'] = 'Name',             ['id_field'] = 'ID',            }, -- Char Info
        [0x009] = {['name_field'] = 'Name',             ['id_field'] = false,           }, -- Check notifications and a lots other things.
        [0x027] = {['name_field'] = 'Player Name',      ['id_field'] = 'Player',        }, -- String Message
        [0x017] = {['name_field'] = 'Sender Name',      ['id_field'] = false,           }, -- Incoming Chat
        [0x070] = {['name_field'] = 'Player Name',      ['id_field'] = false,           }, -- Others Synth Result
        [0x078] = {['name_field'] = 'Proposer Name',    ['id_field'] = 'Proposer ID',   }, -- Proposal
        [0x079] = {['name_field'] = 'Proposer Name',    ['id_field'] = false,           }, -- Proposal Update
        [0x0B6] = {['name_field'] = 'Target Name',      ['id_field'] = false,           }, -- Tell    
        [0x0CA] = {['name_field'] = 'Player Name',      ['id_field'] = false,           }, -- Bazaar Message
        [0x0CC] = {['name_field'] = 'Player Name',      ['id_field'] = false,           }, -- LS Message
        [0x0DC] = {['name_field'] = 'Inviter Name',     ['id_field'] = false,           }, -- Party Invite
        [0x106] = {['name_field'] = 'Name',             ['id_field'] = false,           }, -- Bazaar Seller Info Packet
        [0x107] = {['name_field'] = 'Name',             ['id_field'] = false,           }, -- Bazaar closed
        [0x108] = {['name_field'] = 'Name',             ['id_field'] = 'ID',            }, -- Bazaar visitor
        [0x109] = {['name_field'] = 'Buyer Name',       ['id_field'] = 'Buyer ID',      }, -- Bazaar Purchase Info Packet
        [0x10A] = {['name_field'] = 'Buyer Name',       ['id_field'] = false,           }, -- Bazaar Buyer Info Packet
    }


    local ls_enc = {
        charset = T('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ':split()):update({
            [0] = '`',
            [60] = 0:char(),
            [63] = 0:char(),
        }),
        bits = 6,
        terminator = function(str)
            return (#str % 4 == 2 and 60 or 63):binary()
        end
    }

    syllabize = function()
        local     vowels = { 'a', 'e', 'i', 'o', 'u'}
        local consonants = { 'b', 'd', 'g', 'h', 'j', 'k', 'm', 'n', 'r', 's', 't', 'w', 'z' }
        local cypher = {}    
        local s = S{}
        local i = 0
        repeat
            local k = consonants[math.random(1,#consonants)] .. vowels[math.random(1,#vowels)]
            if not s[k] then 
                s:add(k)
                cypher['%X':format(i)] = k
                i = i+1
            end
        until i > 15
        return function (number)
            local number = '%X':format(number)
            local r = ''
            for i = #number,1,-1 do
                r = r..cypher[number:sub(i,i)]
            end
            return r
        end
    end()

    -- Processes the incoming packets
    function protection_in(id, data)
        
        -- Protection is off so return unchanged packet
        if not protection then return end

        -- The packet is part of the filtered so change it
        if all_filtered_packets[id] then return process_filtered(id, data) end

        -- /check results.
        if id == 0x0C9 then 
            local packet = packets.parse('incoming', data)
            if packet['Linkshell'] then
                packet['Linkshell'] = ls_names(packet['Linkshell'])
            end
            return packets.build(packet)
        end

        -- Item Updates
        if id == 0x020 then 
            local packet = packets.parse('incoming', data)
            -- linkshell/pearlsack/linkpearl
            if packet.Item >= 513 and packet.Item <= 528 then
                packet.extdata = packet.ExtData
                packet.id = packet.Item
                local raw_data = extdata.decode(packet)
                if raw_data.status_id ~= 0 then
                    local name = ls_names(raw_data.name)
                    local encoded_name = name:encode(ls_enc)
                    packet.ExtData = packet.extdata:sub(0,6)..'b4b4b4b4':pack(raw_data.r, raw_data.g, raw_data.b, packet.extdata:unpack('b8', 8, 4))..packet.extdata:sub(9,9)..encoded_name
                    return packets.build(packet)
                end
            end
        end

    end

    function protection_out(id, data)

        -- Protection is not enabled
        if not protection then return end

        -- No need to modify this packet as it is a Tell
        if id ~= 0x0B6 then return end

        local packet = packets.parse('incoming', data)

        -- Check if the name has been randomized
        if reverse_anon_cache[packet['Target Name']] then
            packet['Target Name'] = reverse_anon_cache[packet['Target Name']]
            return packets.build(packet)
        end

        -- Check if its from a defined list
        if reverse_name_cache[packet['Target Name']] then
            packet['Target Name'] = reverse_name_cache[packet['Target Name']]
            return packets.build(packet)
        end

    end

    function names(name, id, packet)
        -- Not a name
        if type(name) == "boolean" then return name end

        --Pre-defined
        if name_cache[name] then return name_cache[name] end

        -- Dont randomize the names if not enabled
        if not anon then return name end

        -- randomized already built
        if anon_cache[name] then return anon_cache[name] end

        -- See if you can construct a new packet based name
        local id_value = packet[all_filtered_packets[id].id_field]

        -- Make a new random name
        if id_value then return random_name(name, id_value) end

        -- Create a basic new name
        local new_name = 'Anon'
        repeat
            for i = 1,#name-4 do
                new_name = new_name .. string.char(math.random(97,122))
            end
        until not reverse_anon_cache[new_name]
        anon_cache[name] = new_name
        reverse_anon_cache[new_name] = name
        return new_name
    end

    function random_name(name, id)
        local l = #name
        local max_len = l+3-(l-1)%4
        local new_name = syllabize(id):sub(1,max_len):gsub("^%l", string.upper)
        anon_cache[name] = new_name
        reverse_anon_cache[new_name] = name
        log("New Name ["..new_name.."] created from ["..name..'] constraint of ['..max_len..']')
        return new_name
    end

    -- Returns the real LS name
    function ls_names(name)

        -- Normalize the string
        name = name:gsub('%W','')

        -- Returns the fake LS name
        if ls_cache[name] then return ls_cache[name] end

        -- Returns the real LS name
        if reverse_ls_cache[name] then return reverse_ls_cache[name] end

        -- Creates a anon LS name
        reverse_ls_cache[name] = random_ls_name()
        return reverse_ls_cache[name]

    end

    function random_ls_name()
        local ls_name = ""
        local    colors = { 'Yellow', 'Green', 'Purple', 'Rose', 'Azure', 'Red', 'Violet', 'Blue', 
                            'Alabaster', 'Amber', 'Black', 'Bronze', 'Carmine', 'Charcoal', 'Copper', 'Crimson', 'Desert', 
                            'Emerald', 'Iron', 'Heliotrope', 'Honeydew', 'Iceberg', 'Indigo', 'Ivory', 
                            'Lemon', 'Liberty', 'Lilac', 'Mauve', 'Mint', 'Peachy', 'Platinum', 'Saffron', 'Shamrock',
                            'Snow', 'Teal', 'Tomato', 'Vanilla', 'Xanthic', 'PolkaDot', 'Rainbow', 
                            'Lime', 'Golden', 'Cerise', 'Pink', 'Bicolor', 'Scarlet', 'Blonde', 'Evergreen', }
        local   animals = { 'Rats', 'Oxen', 'Tigers', 'Rabbits', 'Dragons', 'Snakes', 'Horses', 'Goats', 'Monkeys', 'Roosters', 'Dogs', 'Pigs',
                            'Antelopes', 'Deer', 'Salmons', 'Cats', 'Spiders', 'Bats', 'Bugbears', }
        -- Create a random LS name
        repeat
            ls_name = colors[math.random(1,#colors)] .. animals[math.random(1,#animals)]
        until not reverse_ls_cache[ls_name]
        log("New LS ["..ls_name.."] created")
        return ls_name
    end

    function process_filtered(id, data)

        local packet = packets.parse('incoming',data)
        local name_field = all_filtered_packets[id].name_field
        local original_name = packet[name_field]

        -- The original name couldn't be found so return normal
        if not original_name then return data end

        -- Character update
        if id == 0x0E2 then 
            if p.id ~= packet['ID'] then return true end -- Wrong player so throw away
        end

        -- Incoming Unity Chat Message
        if id == 0x017 and original_name == '' then return data end

        -- PC Update
        if id == 0x00D then
            if packet['Update Name'] and packet['Update Name'] ~= "" then
                packet['Update Name'] = names(packet['Update Name'],id, packet)
            end
        end

        -- LS update
        if id == 0x0CC then 
            packet['Message'] = 'Nothing to see here. Move along!'
            packet['Linkshell'] = ls_names(packet['Linkshell'])
        end

        -- Default swaps
        packet[name_field] = names(original_name, id, packet)
        return packets.build(packet)
    end

    function get_name_cache()
        return name_cache
    end

    function set_name_cache(value)
        name_cache = value
    end

    function set_reverse_name_cache(value)
        reverse_name_cache = value
    end

    function get_reverse_name_cache()
        return reverse_name_cache
    end

    function set_ls_cache(value)
        ls_cache = value
    end

    function set_reverse_ls_cache(value)
        reverse_ls_cache = value
    end

    function set_protection(value)
        if value == 'True' then
            if not protection then
                protection = true
                windower.add_to_chat(1, ('\31\200[\31\05Silmaril\31\200]\31\207'..' Protection: \31\06[ON]'))
                if dressup_enable then dressup = true end
                info("Please zone to finish protection.")
            end
        else
            if protection then
                protection = false
                windower.add_to_chat(1, ('\31\200[\31\05Silmaril\31\200]\31\207'..' Following: \31\03[OFF]'))
                if dressup_enable then dressup = true end
                info("Please zone to finish protection.")
            end
        end
    end

    function get_protection()
        return protection
    end

    function get_dressup()
        return dressup
    end

    function set_dressup(value)
        dressup = value
    end

    function set_dressup_enable(value)
        if value == "True" then
            dressup_enable = true
        else
            dressup_enable = false
        end
    end

    function set_anon(value)
        if value == "True" then
            anon = true
        else
            anon = false
        end
    end

end