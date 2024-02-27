do
    local all_items = res.items -- Store the resource information in a table

    function get_inventory()
        local formattedString = "items_"

        local items = windower.ffxi.get_items(0)
        if not items then return formattedString end

        for b,v in ipairs(items) do
            if v.id > 0 then
                if all_items[v.id] then
                    --log('Item ID ['..tostring(v.id)..'], Count ['..tostring(v.count)..'],Item name ['..tostring(all_items[v.id].name)..']')
                    if v.status == 0 then
                        v.status = ""
                    elseif v.status == 5 then
                        v.status = "Equipped"
                    elseif v.status == 19 then
                        v.status = "Linkshell On"
                    elseif v.status == 25 then
                        v.status = "Bazaar"
                    end
                    local item = all_items[v.id]
                    local food = false
                    if item.flags["Flag03"] and not item.flags["No Auction"] and not item.flags["Rare"] and not item.flags["Exclusive"] then
                        food = true
                    end
                    formattedString = formattedString..tostring(item.name)..'\\'..tostring(v.id)..'\\'..tostring(v.count)..'\\'..tostring(v.slot)..'\\'..tostring(v.status)..'\\'..tostring(food)..'|'
                end
            end
        end
        formattedString = formattedString:sub(1, #formattedString - 1)
        --log(formattedString)
        return formattedString
    end

    function get_item(id)
        return all_items[id]
    end
end