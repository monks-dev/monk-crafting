-- Define local variable to store the bench object and its model hash
local benchObj = nil
local benchModelHash = `gr_prop_gr_bench_02a`

-- Create a thread to spawn the bench and set up interaction
Citizen.CreateThread(function()
    -- Request the bench model
    RequestModel(benchModelHash)

    -- Create the bench object at the configured location
    benchObj = CreateObject(benchModelHash, Config.BenchLoc.x, Config.BenchLoc.y, Config.BenchLoc.z, false, false, false)
    SetEntityHeading(benchObj, Config.BenchLoc.w) -- Set the orientation

    -- Mark model as no longer needed once created
    if benchObj ~= nil then SetModelAsNoLongerNeeded(benchModelHash) end

    -- Add an interaction target to the bench using ox_target
    exports.ox_target:addLocalEntity(benchObj, {
        {
            distance = 1.5,
            name = 'bench_open',
            icon = 'fa-solid fa-screwdriver-wrench',
            label = 'Open Bench',
            onSelect = function()
                -- Trigger client event to open crafting menu
                TriggerEvent('monk-crafting:client:OpenMenu')
            end
        }
    })
end)

-- Event to open the crafting menu
RegisterNetEvent('monk-crafting:client:OpenMenu', function()
    -- Register a context menu with lib (ox_lib most likely)
    lib.registerContext({
        id = 'general_crafting',
        title = 'Weapon Crafting',
        options = {
            {
                title = 'Crafting Level',
                description = 'This is your level for crafting',
                icon = 'fa-solid fa-hammer',
                progress = 50,
                colorScheme = 'green'
            },
            {
                title = 'Pistol Crafting',
                description = 'Required Level 0',
                icon = 'bars',
                menu = 'pistol-crafting',
                event = 'monk-crafting:client:CraftItem', -- Trigger crafting
            },
            {
                title = 'Shotgun Crafting',
                description = 'Required Level 5',
                icon = 'bars',
                menu = 'shotgun-crafting',
                disabled = true,
            },
            {
                title = 'Rifle Crafting',
                description = 'Required Level 10',
                icon = 'bars',
                menu = 'rifle-crafting',
                disabled = true,
            }
        }
    })

    -- Show the menu
    lib.showContext('general_crafting')
end)

-- Event triggered when player chooses to craft an item
RegisterNetEvent('monk-crafting:client:CraftItem', function(itemToCraft)
    local counter = 0
    local itemRecipe = Config.CraftableItems[itemToCraft.item].recipe -- Get recipe for selected item

    -- Check if the player has all required items
    for i, item in ipairs(itemRecipe) do
        if exports.ox_inventory:GetItemCount(item.itemName) >= item.reqAmount then
            counter = i
        else
            break -- Exit loop early if an item is missing
        end
    end

    -- If all required items are available
    if counter == #itemRecipe then
        local ped = PlayerPedId()

        -- Start crafting animation
        TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)

        -- Show a crafting progress bar
        if lib.progressCircle({
                duration = 5000,
                label = "Crafting a " .. Config.CraftableItems[itemToCraft.item].menuTitle .. "...",
                position = 'bottom',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = true,
                    combat = true,
                    car = true,
                },
            }) then
            -- If crafting completes, remove ingredients and give crafted item
            for i, item in ipairs(itemRecipe) do
                TriggerServerEvent('monk-crafting:server:TakeItem', item.itemName, item.reqAmount)
            end

            TriggerServerEvent('monk-crafting:server:GiveItem', itemToCraft.item, 1)

            -- Notify success
            lib.notify({
                title = "Crafting Finished",
                type = 'success'
            })
        else
            -- Notify crafting was canceled or failed
            lib.notify({
                title = "Crafting Failed.",
                type = 'error'
            })
        end

        -- Stop animation
        ClearPedTasks(ped)
    else
        -- Notify player they are missing items
        lib.notify({
            title = "Missing Required Items.",
            type = 'warning'
        })
    end
end)

-- Clean up bench object if the resource is stopped
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    DeleteObject(benchObj)
end)
