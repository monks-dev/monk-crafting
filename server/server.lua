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

RegisterNetEvent('monk-crafting:server:AddCraftingXP', function(xpAmount)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local currentXP = player.Functions.GetMetaData("craftingXP") or 0
    local currentLevel = player.Functions.GetMetaData("craftingLevel") or 0

    local newXP = currentXP + xpAmount
    local newLevel = currentLevel

    if newXP >= (100 + (100 * currentLevel)) then
        newLevel = currentLevel + 1
        newXP = 0

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Crafting',
            description = 'You Leveled Up! New Level: ' .. newLevel,
            type = 'success'
        })
    end

    player.Functions.SetMetaData("craftingXP", newXP)
    player.Functions.SetMetaData("craftingLevel", newLevel)

    TriggerClientEvent('monk-crafting:client:UpdateCraftingLevel', src, newLevel, newXP)

    player:Save()
end)

RegisterNetEvent('monk-crafting:server:RequestCraftingData', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local meta = player.PlayerData.metadata or {}
    local level = meta.craftingLevel or 0
    local xp = meta.craftingXP or 0

    TriggerClientEvent('monk-crafting:client:SetCraftingData', src, level, xp)
end)

-- Command to reset player's crafting XP and level
RegisterCommand('resetCraftingLevel', function(source, args, rawCommand)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)

    if player then
        -- Reset crafting XP and level metadata
        player.Functions.SetMetaData("craftingXP", 0)
        player.Functions.SetMetaData("craftingLevel", 0)

        -- Optionally, notify the player
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Crafting Reset',
            description = 'Your crafting XP and level have been reset.',
            type = 'success'
        })
    else
        -- Optionally log if player is not found
        print("Player not found for reset.")
    end
end, false) -- false means it’s not restricted to admins
