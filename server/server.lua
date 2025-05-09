-- Event to give the player a crafted item
RegisterNetEvent('monk-crafting:server:GiveItem', function(itemName, amount)
    local src = source                           -- Get the player who triggered the event

    local item = Config.CraftableItems[itemName] -- Verify the item exists in the crafting config

    if item then
        -- Give the item to the player using ox_inventory
        exports.ox_inventory:AddItem(src, itemName, amount)
    else
        -- Log suspicious activity (invalid item) to server console
        print("Whoah Cheater")
    end
end)

-- Event to remove required materials from the player's inventory
RegisterNetEvent('monk-crafting:server:TakeItem', function(itemName, amount)
    local src = source -- Get the player who triggered the event

    -- Remove the specified item and amount from their inventory
    exports.ox_inventory:RemoveItem(src, itemName, amount)
end)
