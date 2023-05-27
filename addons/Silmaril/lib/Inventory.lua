function get_inventory()
    local items = windower.ffxi.get_items(0)
    local formattedString = "items_"
    for b,v in ipairs(items) do
        if v.id > 0 then
            if all_items[v.id] then
                --log('Item ID ['..tostring(v.id)..'], Count ['..tostring(v.count)..'],Item name ['..tostring(all_items[v.id].name)..']')
                formattedString = formattedString..tostring(all_items[v.id].name)..','..tostring(v.id)..','..tostring(v.count)..'|'
            end
        end
    end
    player_item_data = formattedString:sub(1, #formattedString - 1) -- remove last character
end