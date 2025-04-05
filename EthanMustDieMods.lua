-- IDA regex: ^app.*IMD.*
-- app_DLCContentSceneManager__addChapter3_IMD_UpLayer318169( red sky???
-- app_DropItemPoolIMD___c__DisplayClass3_0___getTargetInstance_b__0360444 start with knife?
-- app_ItemBoxLotteryManagerIMD__getDropItemInstance184498
-- Enemy spawning: app.EnemyGeneratorManager.requestSpawn()

if not reframework:get_game_name() == "re7" then
    re.msg("[Ethan Must Die Mods] Only compatible with RE7!")
    return
end

local default_settings = {
    showCratePositions = true
}
local settings = json.load_file("EthanMustDieSettings.json") or {}
for k, v in pairs(default_settings) do
    if settings[k] == nil then
        settings[k] = v
    end
end

local re7utils = require("utility/RE7Utils")
local crates = {}
local crateItems = {
    NORMAL = { "ChemicalM", "Gunpowder", "ChemicalM", "Gunpowder", "ChemicalM", "Gunpowder", "ChemicalM", "Gunpowder" },
    RARE = { "Burner", "RemedyL", "HandgunBulletL", "HandgunBulletL" },
    SUPERRARE = { "Handgun_M19", "MachineGun" },
    LEGENDARY = { "Magnum", "HandgunBulletL", "HandgunBulletL" }
}
local crateIndices = { NORMAL = 0, RARE = 0, SUPERRARE = 0, LEGENDARY = 0 }
local showCratePositions = true

local function manipulateCrateRNG(destroyedCrateType)
    local itemBoxLotteryManager = sdk.get_managed_singleton("app.ItemBoxLotteryManagerIMD")

    if not itemBoxLotteryManager then
        log.error("[Ethan Must Die Mods] Cannot manipulate RNG: Not playing Ethan Must Die!")
        return
    end

    log.debug("[Ethan Must Die Mods] Destroyed a " .. destroyedCrateType:lower() .. " crate.")

    local itemDropTableContainer = itemBoxLotteryManager:get_field("ItemDropTableContainer")
    local dropTableList = itemDropTableContainer:get_field("DropTableList")
    local dropItemParams = dropTableList:get_field("mItems")

    local index = crateIndices[destroyedCrateType] % #crateItems[destroyedCrateType] + 1
    local newItem = crateItems[destroyedCrateType][index]
    crateIndices[destroyedCrateType] = crateIndices[destroyedCrateType] + 1
    log.debug("[Ethan Must Die Mods] Forcing item " .. newItem)

    for i = 0, 3 do
        local param = dropItemParams[i]
        --local dropTableName = param:get_field("DropTableName")
        local dropItemList = param:get_field("DropItemList")
        local items = dropItemList:get_field("mItems")

        for j = 0, #items - 1 do
            local item = items[j]
            item.ItemID = newItem
        end
    end

    if destroyedCrateType ~= "NORMAL" then
        log.debug("[Ethan Must Die Mods] Forcing weapon " .. newItem .. "...")

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
                log.debug("[Ethan Must Die Mods] Item " .. newItem .. " not in EMDWeapons table?!")
                item.WeaponID = newItem
                item.ItemID = newItem
            end
        end
    end
end

-- This method gets called every time a crate is destroyed.
sdk.hook(
    sdk.find_type_definition("app.ItemBoxLotteryManagerIMD"):get_method("getDropItemInstance"),
    function(args)
        manipulateCrateRNG(sdk.to_managed_object(args[4]):call("ToString"))
    end,
    function(retval) return retval end --post
)

local function forceItem(id)
    crateItems = {
        NORMAL = { id },
        RARE = { id },
        SUPERRARE = { id },
        LEGENDARY = { id }
    }
end

re.on_draw_ui(function()
    if imgui.tree_node("Ethan Must Die Mods") then
        imgui.begin_rect()

        if imgui.button("DEV: Clear debug console") then
            re7utils.clearDebugConsole()
        end

        if imgui.button("Force Albert") then
            forceItem("Handgun_Albert_Reward")
        end

        --[[ if imgui.button("Force Green house key") then
            forceItem("GreenHouseKey")
        end ]]

        if imgui.button("Reset drop tables") then
            crateItems = {
                NORMAL = { "ChemicalM", "Gunpowder", "ChemicalM", "Gunpowder", "ChemicalM", "Gunpowder", "ChemicalM", "Gunpowder" },
                RARE = { "Burner", "RemedyL", "HandgunBulletL", "HandgunBulletL" },
                SUPERRARE = { "Handgun_M19", "MachineGun" },
                LEGENDARY = { "Magnum", "HandgunBulletL", "HandgunBulletL" }
            }

            crateIndices = { NORMAL = 0, RARE = 0, SUPERRARE = 0, LEGENDARY = 0 }
        end

        imgui.spacing()
        imgui.text("TP")

        if imgui.button("DEV: Log player position") then
            log.debug(re7utils.vec3tostring(re7utils.get_localplayer():get_Transform():get_Position()))
        end

        if imgui.button("Hallway") then
            -- Big lobby: (-0.622532, -0.000000, 11.295543)
            -- Basement: (-19.955242, -5.250000, 12.617932)
            -- Hallway: (22.662031, 0, 12.848048)

            -- TODO Disable collision
            local player = re7utils.get_localplayer()
            local controller = re7utils.get_component(player, "via.physics.CharacterController")
            if not player or not controller then return end
            controller:call("warp")
            player:get_Transform():set_Position(Vector3f.new(-0.622532, -0.000000, 11.295543))
            controller:call("warp")

            --[[ controller:call("warp")
            player:get_Transform():set_Position(Vector3f.new(-19.955242, -5.250000, 12.617932))
            controller:call("warp") ]]
        end

        _, settings.showCratePositions = imgui.checkbox("Show crate positions", settings.showCratePositions)

        imgui.end_rect(2)
        imgui.tree_pop()

        if imgui.button("Dump") then
            json.dump_file("EthanMustDieSettings.json", settings)
        end
    end
end)

--region DRAW CRATE POSITIONS

local function getCrateLabelAndColor(name)
    if name == "sm9133_IMD_NormalBox" then
        return { label = "N", color = re7utils.rgbToInt(1, 0.984, 0, 1):int() }
    elseif name == "sm9133_IMD_RareBox" then
        return { label = "R", color = re7utils.rgbToInt(0, 1, 0, 1):int() }
    elseif name == "sm9133_IMD_SuperRareBox" then
        return { label = "S", color = re7utils.rgbToInt(1, 0, 0.894, 1):int() }
    elseif name == "sm2619_IMD_LegendaryBox" then
        return { label = "L", color = re7utils.rgbToInt(1, 0, 0, 1):int() }
    else
        log.debug(name)
        return { label = "?", color = re7utils.rgbToInt(1, 1, 1, 1):int() }
    end
end

sdk.hook(
    sdk.find_type_definition("app.ItemBoxSetPointIMD"):get_method("overrideIntaractParam"),
    function(args)
        local box = sdk.to_managed_object(args[3])
        table.insert(crates, box)
        log.debug("[Ethan Must Die Mods] Box at " ..
            re7utils.vec3tostring(box:get_Transform():get_Position()) .. " :: " .. box:get_Name())
    end,
    function(retval) return retval end
)

sdk.hook(
    sdk.find_type_definition("app.ItemBoxLotteryManagerIMD"):get_method("onDestroy"),
    function(_)
        crates = {}
        re7utils.clearDebugConsole()
    end,
    function(retval) return retval end
)

re.on_frame(function()
    if not showCratePositions or not next(crates) then return end

    for i = 1, #crates - 1 do
        local crate = crates[i]
        local crateName = crate:get_Name()
        local labelColorPair = getCrateLabelAndColor(crateName)
        draw.world_text(labelColorPair.label, crate:get_Transform():get_Position(), labelColorPair.color)
    end
end)

--endregion
