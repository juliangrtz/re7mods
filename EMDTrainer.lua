-- IDA regex: ^app.*IMD.*

if not reframework:get_game_name() == "re7" then
    log.error("[Ethan Must Die Trainer] Only compatible with RE7.")
    return
end

local re7utils = require("utility/RE7Utils")
--local re7 = require("utility/RE7")
local logOriginalLootTable = false

-- This method gets called every time a crate is destroyed.
sdk.hook(
    sdk.find_type_definition("app.ItemBoxLotteryManagerIMD"):get_method("getDropItemInstance"),
    function(args) --pre
        ManipulateCrateRNG(sdk.to_managed_object(args[4]):call("ToString"))
    end,
    function(retval) return retval end --post
)

local crateItems = {
    NORMAL = { "ChemicalM", "Gunpowder", "ChemicalM", "Gunpowder", "RemedyL" },
    RARE = { "Burner", "Shotgun_DB", "ShotgunBullet", "ShotgunBullet" },
    SUPERRARE = { "MachineGun", "Handgun_M19" },
    LEGENDARY = { "Handgun_Albert", "Magnum", "MagnumBullet" }
}
local crateIndices = { NORMAL = 0, RARE = 0, SUPERRARE = 0, LEGENDARY = 0 }

function ManipulateCrateRNG(destroyedCrateType)
    local itemBoxLotteryManager = sdk.get_managed_singleton("app.ItemBoxLotteryManagerIMD")

    if not itemBoxLotteryManager then
        log.error("[Ethan Must Die Trainer] Cannot manipulate RNG: Not playing Ethan Must Die!")
        return
    end

    log.debug("[Ethan Must Die Trainer] Destroyed a " .. destroyedCrateType:lower() .. " crate.")

    local itemDropTableContainer = itemBoxLotteryManager:get_field("ItemDropTableContainer")
    local dropTableList = itemDropTableContainer:get_field("DropTableList")
    local dropItemParams = dropTableList:get_field("mItems")

    local index = crateIndices[destroyedCrateType] % #crateItems[destroyedCrateType] + 1
    local newItem = crateItems[destroyedCrateType][index]
    crateIndices[destroyedCrateType] = crateIndices[destroyedCrateType] + 1
    log.debug("[Ethan Must Die Trainer] Forcing item " .. newItem)

    for i = 0, 3 do
        local param = dropItemParams[i]
        local dropTableName = param:get_field("DropTableName")
        local dropItemList = param:get_field("DropItemList")
        local items = dropItemList:get_field("mItems")

        for j = 0, #items - 1 do
            local item = items[j]

            if logOriginalLootTable then
                local itemId = item:get_field("ItemID")
                local dropRate = item:get_field("DropRate")
                log.debug("(" .. dropTableName .. ") " .. itemId .. ": " .. dropRate * 100 .. "%")
            end

            item.ItemID = newItem
        end
    end

    if destroyedCrateType ~= "NORMAL" then
        log.debug("[Ethan Must Die Trainer] Forcing weapon " .. newItem .. "...")

        local substituteDropTableList = itemDropTableContainer:get_field("SubstituteDropTableList")
        local substituteDropItemParams = substituteDropTableList:get_field("mItems")
        local table = substituteDropItemParams[0]
        local dropItemList = table:get_field("DropItemList")
        local items = dropItemList:get_field("mItems")

        for j = 0, #items - 1 do
            local item = items[j]

            if logOriginalLootTable then
                local itemId = item:get_field("ItemID")
                local weaponID = item:get_field("WeaponID")
                local stackNum = item:get_field("StackNum")
                log.debug("(SUBSTITUTE) " ..
                    re7utils.ItemFriendlyNames[weaponID] .. " (" .. stackNum .. " " .. itemId .. ")")
            end

            if re7utils.EMDWeapons[newItem] then
                item.WeaponID = re7utils.EMDWeapons[newItem].id
                item.ItemID = re7utils.EMDWeapons[newItem].itemID
            else
                item.WeaponID = newItem
                item.ItemID = newItem
            end

            -- TODO StackNum???
        end
    end
end

re.on_draw_ui(function()
    if imgui.tree_node("Ethan Must Die Trainer") then
        imgui.begin_rect()
        --imgui.text("Manipulated: " .. (changeRNG and "Yes" or "No"))
        --if imgui.button("Toggle RNG manipulation") then
        --
        --end
        if imgui.button("Clear debug console") then
            re7utils.clearDebugConsole()
        end

        if imgui.button("Reset forced items") then
            crateIndices = { NORMAL = 0, RARE = 0, SUPERRARE = 0, LEGENDARY = 0 }
        end
        imgui.end_rect(2)
        imgui.tree_pop()
    end
    imgui.text()
end)
