-- IDA regex: ^app.*IMD.*
-- app_DLCContentSceneManager__addChapter3_IMD_UpLayer318169( red sky???
-- app_DropItemPoolIMD___c__DisplayClass3_0___getTargetInstance_b__0360444 start with knife?
-- app_ItemBoxLotteryManagerIMD__getDropItemInstance184498

if not reframework:get_game_name() == "re7" then
    log.error("[Ethan Must Die Trainer] Only compatible with RE7.")
    return
end

local re7utils = require("utility/RE7Utils")

-- This method gets called every time a crate is destroyed.
sdk.hook(
    sdk.find_type_definition("app.ItemBoxLotteryManagerIMD"):get_method("getDropItemInstance"),
    function(args)
        ManipulateCrateRNG(sdk.to_managed_object(args[4]):call("ToString"))
    end,
    function(retval) return retval end --post
)

-- This method gets called for every instantiated crate.
local crateTransforms = {}
sdk.hook(
    sdk.find_type_definition("app.ItemBoxSetPointIMD"):get_method("overrideIntaractParam"),
    function(args)
        local box = sdk.to_managed_object(args[3])
        local transform = box:call("get_Transform") --:call("get_Position")
        log.debug("[Ethan Must Die Trainer] Box at " .. vec3tostring(transform:get_Position()))
        table.insert(crateTransforms, transform)
        --draw.sphere(pos, 10, 0xffffffff, true) -- Not working?!?
    end,
    function(retval) return retval end
)

sdk.hook(
    sdk.find_type_definition("app.ItemBoxLotteryManagerIMD"):get_method("doStart"),
    function(args)
        crateTransforms = {}
        log.debug("[Ethan Must Die Trainer] Reset crate positions.")
    end,
    function(retval) return retval end
)

local crateItems = {
    NORMAL = { "ChemicalM", "Gunpowder", "ChemicalM", "Gunpowder", "ChemicalM", "Gunpowder", "ChemicalM", "Gunpowder" },
    RARE = { "Burner", "RemedyL", "HandgunBulletL", "HandgunBulletL" },
    SUPERRARE = { "Handgun_M19", "MachineGun" },
    LEGENDARY = { "Magnum", "HandgunBulletL", "HandgunBulletL" }
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

            if re7utils.EMDWeapons[newItem] then
                local wp = re7utils.EMDWeapons[newItem]
                item.WeaponID = wp.id
                item.ItemID = wp.itemID
                item.StackNum = wp.stackNum
            else
                log.debug("[Ethan Must Die Trainer] Item " .. newItem .. " not in EMDWeapons table?!")
                item.WeaponID = newItem
                item.ItemID = newItem
            end
        end
    end
end

re.on_draw_ui(function()
    if imgui.tree_node("Ethan Must Die Trainer") then
        imgui.begin_rect()

        if imgui.button("DEV: Clear debug console") then
            re7utils.clearDebugConsole()
        end

        if imgui.button("Force Albert") then
            crateItems = {
                NORMAL = { "Handgun_Albert_Reward" },
                RARE = { "Handgun_Albert_Reward" },
                SUPERRARE = { "Handgun_Albert_Reward" },
                LEGENDARY = { "Handgun_Albert_Reward" }
            }
        end

        if imgui.button("Reset drop tables") then
            crateItems = {
                NORMAL = { "ChemicalM", "Gunpowder", "ChemicalM", "Gunpowder", "ChemicalM", "Gunpowder", "ChemicalM", "Gunpowder" },
                RARE = { "Burner", "RemedyL", "HandgunBulletL", "HandgunBulletL" },
                SUPERRARE = { "Handgun_M19", "MachineGun" },
                LEGENDARY = { "Magnum", "HandgunBulletL", "HandgunBulletL" }
            }

            crateIndices = { NORMAL = 0, RARE = 0, SUPERRARE = 0, LEGENDARY = 0 }
        end

        imgui.end_rect(2)
        imgui.tree_pop()
    end
    imgui.text()
end)
