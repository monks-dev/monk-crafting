-- Create a table to store all configuration settings
Config = {}

-- Define the location and heading (rotation) of the crafting bench
-- vec4(x, y, z - 1, heading)
-- The Z value is reduced by 1 to properly align the bench with the ground
Config.BenchLoc = vec4(13.12, -1101.54, 29.8 - 1, 336.45)

-- Define craftable items and their crafting recipes
Config.CraftableItems = {
    ["weapon_pistol"] = {
        menuTitle = 'Lock Pick', -- Display name in the crafting menu
        recipe = {
            -- Each item in the recipe requires an item name and how many are needed
            { itemName = 'iron', reqAmount = 5 },
        }
    }
}
