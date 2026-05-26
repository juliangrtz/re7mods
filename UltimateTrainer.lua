-- Ultimate Trainer for Resident Evil 7
-- by d3sc0le (Discord: jvl.1an)
local version = "1.3"

--[[
TODO

[X] Player X/Z/Y axis setting
[X] Player scale
[X] Invincibility
[X] Infinite Ammo
[X] Player speed
[X] Unlock All Items
[X] Inventory case size modifier
[X] Stats
[X] Enemy one hit kill
[X] Enemy speed
[X] NoClip/Wallhack
[X] Game difficulty modifier

Bindable hotkeys
Inventory editor (Adding/Removing weapons/key items/treasures/ammo)
Enemy scale
Enemy ignore player
Damage modifier
No recoil
Manual flashlight
Camera FOV modifier
]]

if reframework:get_game_name() ~= "re7" then
    re.msg("[RE7 Ultimate Trainer] Only compatible with Resident Evil 7!")
    return
end

local default_settings = {
    godmode = false,
    infinite_ammo = false,
    move_speed_multiplier = 1.0,
    player_scale = 1.0,
    enemy_scale = 1.0,
    change_enemy_speed = false,
    enemy_speed_multiplier = 1.0,
    enemy_insta_kill = false,
    freeze_itembox_count = false,
    noclip = false,
    noclip_speed = 0.4,
    selected_rank = 0,
    play_time_text = "00:00:00",
}
local settingsFile = "UltimateRE7Trainer.json"
local settings = json.load_file(settingsFile) or {}

for k, v in pairs(default_settings) do
    if settings[k] == nil then
        settings[k] = v
    end
end

local rank_ui_initialized = false
local play_time_ui_initialized = false
local stats_message = ""

--region Data

local AchievementTag = {
    CountOfKilledByKnife = 0,
    CountOfKilledByAttachBomb = 1,
    CountOfOpenItemBox = 2,
    CountOfUsedCure = 3,
    CountOfRepulsedInTheAir = 4,
    CountOfRepulsedMother = 5,
    CountOfSucceededGuards = 6,
    CountOfCloseDoor = 7,
    CountOfBrokenInsectDoorsByKnife = 8,
    CountOfTwoKilledAtOneShot = 9,
    CountOfAvoidBySquat = 10,
    CountOfGetItemByDetailSearch = 11,
    CountOfUsedEyedLotion = 12,
    CountOfSetupMissShadowPuzzle = 13,
    CountOfCoins = 14,
    CountOfCoinsForHard = 15,
    CountOfFiles = 16,
    CountOfPicking = 17,
    CountOfStabilizers = 18,
    CountOfSteroids = 19,
    CollectOffFormulated = 20,
    CollectOffClearedFF = 21,
    StatsGetFuseCHP1 = 22,
    StatsGetFuseCHP4 = 23,
    StatsGetFuseFF = 24,
    StatsGetShotgunDummy = 25,
    StatsGetShotgunWp1039 = 26,
    StatsGetShotgunWp1030 = 27,
    StatsGetShotgunWp1230 = 28,
    StatsGetShotgunWp1280 = 29,
    StatsGetCandle = 30,
    StatsGetCandleFire = 31,
}

local AchievementVariableNames = {
    [AchievementTag.CountOfUsedCure] = "CountOfUsedCure",
    [AchievementTag.CountOfCoins] = "CountOfCoins",
    [AchievementTag.CountOfCoinsForHard] = "CountOfCoinsForHard",
    [AchievementTag.CountOfFiles] = "CountOfFiles",
    [AchievementTag.CountOfStabilizers] = "CountOfStabilizers",
    [AchievementTag.CountOfSteroids] = "CountOfSteroids",
}

local ItemId = {
    "Bar", "ChainSaw", "CircularSaw", "HandAxe", "Knife", "MiaKnife", "Burner", "GrenadeLauncher", "Handgun_Albert",
    "Handgun_Albert_Reward", "Handgun_G17", "Handgun_M19", "Handgun_MPM", "MachineGun", "Magnum", "Shotgun_DB",
    "Shotgun_M37", "BlueBlaster", "HyperBlaster", "RedBlaster", "LiquidBomb", "UnlimitedAmmo", "AcidBulletS",
    "BurnerBullet", "FlameBulletS", "HandgunBullet", "HandgunBulletL", "MachineGunBullet", "MagnumBullet",
    "ShotgunBullet", "EyeDrops", "Herb", "RemedyL", "RemedyM", "AlphaGrass", "BookDefence01", "BookDefence02",
    "Depressant", "Stimulant", "EasyBoots", "Coin", "GoodLuckCoinA", "GoodLuckCoinB", "GoodLuckCoinC",
    "GoodLuckCoinD", "GoodLuckCoinE", "PowerUpCoin01A", "PowerUpCoin01B", "Alcohol", "AlloyClay", "ChemicalL",
    "ChemicalM", "ChemicalS", "Flower", "Gunpowder", "Magnesium", "RepairKit", "MailMia", "MiaDriversLicense",
    "ProposalBookFf", "3CrestKeyA", "3CrestKeyB", "3CrestKeyC", "CabinKey", "CylinderKey", "EntranceHallKey",
    "EthanCarKey", "FloorDoorKey", "LucasCardKey", "LucasCardKey2", "MasterKey", "MorgueKey", "SpareKey",
    "TalismanKey", "WorkroomKey", "TreasureMap01", "TreasureMap02", "TreasureMap03", "Battery", "BrokenHandgun_M19",
    "BrokenShotgun_DB", "BurnerPartsA", "BurnerPartsB", "ChainCutter", "Crank", "DummyAxe", "EvCable", "EvelynRadar1",
    "EvelynRadar2", "EvelynRadar3", "EvelynRadar4", "EvOpener", "Fuse", "FuseCh4", "Lantern", "PendulumClock",
    "SerumComplete", "SerumMaterialA", "SerumMaterialB", "SerumTypeE", "SilhouettePazzlePiece",
    "SilhouettePazzlePieceOldHouse", "Timebomb", "ToyShotgun", "EthanLeg", "HandCutOff", "Balloonbomb", "Candle",
    "Glasses", "ScrewFinger", "Quill", "Valve", "SpringCoil", "SaveTape", "SupplyBoxA", "SupplyBoxOpenedA",
    "SupplyBoxB", "SupplyBoxOpenedB", "SupplyBoxC", "SupplyBoxOpenedC", "FoundFootage000", "FoundFootage010",
    "FoundFootage020", "FoundFootage030", "FoundFootage040", "FoundFootage050"
}

local GameDifficultyOptions = {
    { label = "Easy", value = 0 },
    { label = "Normal", value = 1 },
    { label = "Madhouse", value = 2 },
}

local GameDifficultyLabels = {
    [0] = "Easy",
    [1] = "Normal",
    [2] = "Madhouse",
}

--endregion

local has_warned = false
local function get_singleton(name)
    local s = sdk.get_managed_singleton(name)
    if not s and not has_warned then
        re.msg("[RE7 Ultimate Trainer] Did not find singleton " .. name .. ", are you inside a Nightmare game?")
        has_warned = true
    end
    return s
end

local function getLocalPlayer()
    local object_man = sdk.get_managed_singleton("app.ObjectManager")

    if not object_man then
        return nil
    end

    return object_man:get_field("PlayerObj")
end

local known_typeofs = {}
local function getComponent(game_object, type_name)
    local t = known_typeofs[type_name] or sdk.typeof(type_name)

    if t == nil then
        return nil
    end

    known_typeofs[type_name] = t
    return game_object:call("getComponent(System.Type)", t)
end

local function setExtendLv(lv)
    local inventory = getComponent(getLocalPlayer(), "app.Inventory")
    if not inventory then return end
    local lvl = inventory:get_field("_ExtendLv")
    if lvl ~= 2 then
        inventory:setExtendLv(lv)
    end
end

local function getItemBoxData()
    local inventory = getComponent(getLocalPlayer(), "app.Inventory")
    if not inventory then return end
    return inventory:get_field("<ItemBoxData>k__BackingField")
end

local function addAllItemsToItemBox()
    for _, itemId in ipairs(ItemId) do
        local signature = "addItem(System.String, System.Int32, app.WeaponGun.WeaponGunSaveData)"
        local itemBoxData = getItemBoxData()
        if not itemBoxData then return end
        itemBoxData:call(signature, itemId, 100, nil)
    end
end

local function teleportPlayer(x, y, z)
    local player = getLocalPlayer()
    local controller = getComponent(player, "via.physics.CharacterController")
    if not player or not controller then return end
    controller:call("warp")
    player:get_Transform():set_Position(Vector3f.new(x, y, z))
    controller:call("warp")
end

local function changePlayerScale(scale)
    local player = getLocalPlayer()
    if not player then return end
    player:get_Transform():set_LocalScale(Vector3f.new(scale, scale, scale))
end

local function addCount(stat, count)
    local achvm = get_singleton("app.Achievement")
    local signature = "addCount(app.Achievement.VariablesTagID)"

    for _ = 1, count do
        achvm:call(signature, stat)
    end
end

local function managedValueToNumber(value)
    if value == nil then return nil end

    local number = tonumber(value)
    if number ~= nil then return number end

    local text = tostring(value)
    if text == nil then return nil end

    if string.find(text, "Easy") then return 0 end
    if string.find(text, "Normal") then return 1 end
    if string.find(text, "Hard") or string.find(text, "Madhouse") then return 2 end

    local parsed = string.match(text, "(-?%d+)")
    if parsed ~= nil then return tonumber(parsed) end

    return nil
end

local function getManagedValue(obj, name)
    if not obj then return nil end

    local ok, result = pcall(function()
        return obj:get_field(name)
    end)

    if ok and result ~= nil then return result end

    ok, result = pcall(function()
        return obj[name]
    end)

    if ok and result ~= nil then return result end

    ok, result = pcall(function()
        return obj:call("get_" .. name)
    end)

    if ok and result ~= nil then return result end

    return nil
end

local function setManagedValue(obj, name, value)
    if not obj then return false end

    local ok = pcall(function()
        obj:set_field(name, value)
    end)

    if ok then return true end

    ok = pcall(function()
        obj[name] = value
    end)

    if ok then return true end

    ok = pcall(function()
        obj:call("set_" .. name, value)
    end)

    return ok
end

local function setManagedEnumValue(obj, name, value)
    return setManagedValue(obj, name, value) or setManagedValue(obj, name, sdk.create_int32(value))
end

local function callKnownMethod(obj, methodName, ...)
    if not obj then return false, nil end

    local args = { ... }
    local unpackArgs = table.unpack or unpack
    local typeDef = obj:get_type_definition()

    if typeDef then
        local method = typeDef:get_method(methodName)
        if method then
            local ok, result = pcall(function()
                return method:call(obj, unpackArgs(args))
            end)

            if ok then return true, result end
        end
    end

    local ok, result = pcall(function()
        return obj:call(methodName, unpackArgs(args))
    end)

    if ok then return true, result end

    local methodBaseName = string.match(methodName, "^([^%(]+)")
    if methodBaseName and methodBaseName ~= methodName then
        ok, result = pcall(function()
            return obj:call(methodBaseName, unpackArgs(args))
        end)

        if ok then return true, result end
    end

    return false, nil
end

local function setKnownValue(obj, name, value, typeName)
    if not obj then return false end

    local typeDef = obj:get_type_definition()
    if not typeDef then return false end

    local setter = nil
    if typeName ~= nil then
        setter = typeDef:get_method("set_" .. name .. "(" .. typeName .. ")")
    end
    setter = setter or typeDef:get_method("set_" .. name)

    if setter then
        local ok = pcall(function()
            setter:call(obj, value)
        end)

        if ok then return true end
    end

    local field = typeDef:get_field(name)
    if not field then return false end

    local ok = pcall(function()
        obj:set_field(name, value)
    end)

    return ok
end

local function getStaticField(typeName, fieldName)
    local typeDef = sdk.find_type_definition(typeName)
    if not typeDef then return nil end

    local field = typeDef:get_field(fieldName)
    if not field then return nil end

    local ok, result = pcall(function()
        return field:get_data(nil)
    end)

    if ok then return result end
    return nil
end

local function murmurHash32(text)
    local typeDef = sdk.find_type_definition("via.murmur_hash")
    if not typeDef then return nil end

    local method = typeDef:get_method("calc32")
    if not method then return nil end

    local ok, result = pcall(function()
        return method:call(nil, text)
    end)

    if ok and result ~= nil then return managedValueToNumber(result) end
    return nil
end

local function getAchievementVariable(tag, dictName)
    local achvm = get_singleton("app.Achievement")
    if not achvm then return nil end

    local variables = getManagedValue(achvm, "variables")
    if not variables then return nil end

    local dict = getStaticField("app.Achievement", dictName or "DictCount")
    if dict then
        local ok, variableId = callKnownMethod(dict, "get_Item(app.Achievement.VariablesTagID)", tag)
        if not ok or variableId == nil then
            ok, variableId = callKnownMethod(dict, "get_Item", tag)
        end

        variableId = managedValueToNumber(variableId)
        if variableId ~= nil then
            local found, variable = callKnownMethod(variables, "findVariable(System.UInt32)", variableId)
            if not found or not variable then
                found, variable = callKnownMethod(variables, "findVariable(System.UInt32)", sdk.create_uint32(variableId))
            end
            if found and variable then return variable end
        end
    end

    local variableName = AchievementVariableNames[tag]
    if not variableName then return nil end

    local found, variable = callKnownMethod(variables, "findVariable(System.String)", variableName)
    if not found or not variable then
        found, variable = callKnownMethod(variables, "findVariable(System.String)", sdk.create_managed_string(variableName))
    end
    if found and variable then return variable end

    local variableId = murmurHash32(variableName)
    if variableId == nil then return nil end

    found, variable = callKnownMethod(variables, "findVariable(System.UInt32)", variableId)
    if not found or not variable then
        found, variable = callKnownMethod(variables, "findVariable(System.UInt32)", sdk.create_uint32(variableId))
    end
    if found and variable then return variable end

    return nil
end

local function setAchievementCount(tag, count)
    count = math.floor(tonumber(count) or 0)
    if count < 0 then count = 0 end

    local variable = getAchievementVariable(tag, "DictCount")
    if not variable then return false end

    local ok = callKnownMethod(variable, "set_U32(System.UInt32)", count)
    if not ok then
        ok = callKnownMethod(variable, "set_U32(System.UInt32)", sdk.create_uint32(count))
    end
    if not ok then
        ok = setKnownValue(variable, "U32", count, "System.UInt32")
    end
    if not ok and count == 0 then
        ok = callKnownMethod(variable, "setZero()")
    end

    if ok and count > 0 then
        local achvm = get_singleton("app.Achievement")
        callKnownMethod(achvm, "tryUnlock(app.Achievement.VariablesTagID)", tag)
    end

    return ok
end

local function getGameManager()
    return sdk.get_managed_singleton("app.GameManager")
end

local function getCurrentSaveData()
    local saveDataManager = sdk.get_managed_singleton("app.SaveDataManager")
    if not saveDataManager then return nil end
    return getManagedValue(saveDataManager, "_MySaveData")
end

local function getCurrentGameDifficulty(gameMngr)
    gameMngr = gameMngr or getGameManager()
    if not gameMngr then return nil end

    local difficulty = managedValueToNumber(getManagedValue(gameMngr, "GameDifficulty"))
    if difficulty ~= nil then return difficulty end

    local ok, result = pcall(function()
        return gameMngr:call("get_gameDifficulty")
    end)

    if ok and result ~= nil then
        return managedValueToNumber(result)
    end

    return nil
end

local function getGameDifficultyLabel(difficulty)
    difficulty = managedValueToNumber(difficulty)
    if difficulty == nil then return "Unknown" end
    return GameDifficultyLabels[difficulty] or tostring(difficulty)
end

local function setCurrentGameDifficulty(value)
    local changed = false
    local gameMngr = getGameManager()

    if gameMngr then
        changed = setManagedEnumValue(gameMngr, "GameDifficulty", value) or changed
    end

    local saveData = getCurrentSaveData()
    if saveData then
        changed = setManagedEnumValue(saveData, "GameDifficulty", value) or changed
    end

    return changed
end

local function getCurrentGameRank(gameMngr)
    if not gameMngr then return nil end

    local ok, result = pcall(function()
        return gameMngr:getGameRank()
    end)

    if ok then return result end

    return nil
end

local function setCurrentAdaptiveRank(rank)
    rank = math.floor(tonumber(rank) or 0)
    if rank < 0 then rank = 0 end
    if rank > 9 then rank = 9 end

    local rankPoint = (rank * 1000.0) + 500.0
    local changed = false
    local gameMngr = getGameManager()

    if gameMngr then
        changed = setManagedValue(gameMngr, "RankPoint", rankPoint) or changed
        changed = setManagedValue(gameMngr, "RankPoint_030", rankPoint) or changed
    end

    local saveData = getCurrentSaveData()
    if saveData then
        changed = setManagedValue(saveData, "RankPoint", rankPoint) or changed
        changed = setManagedValue(saveData, "RankPoint_030", rankPoint) or changed
    end

    return changed
end

local function getSaveDataManager()
    return sdk.get_managed_singleton("app.SaveDataManager")
end

local function secondsToTimeText(seconds)
    seconds = math.floor(tonumber(seconds) or 0)
    if seconds < 0 then seconds = 0 end

    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

local function timeTextToSeconds(text)
    if not text then return nil end

    local hours, minutes, seconds = string.match(text, "^%s*(%d+):(%d%d):(%d%d)%s*$")
    if not hours then return nil end

    hours = tonumber(hours)
    minutes = tonumber(minutes)
    seconds = tonumber(seconds)

    if not hours or not minutes or not seconds then return nil end
    if minutes > 59 or seconds > 59 then return nil end

    return (hours * 3600) + (minutes * 60) + seconds
end

local function getCurrentPlayTimeSeconds()
    local saveDataManager = getSaveDataManager()
    if saveDataManager then
        local ok, result = callKnownMethod(saveDataManager, "getNowPlayTime()")
        if ok and result ~= nil then
            return managedValueToNumber(result)
        end

        ok, result = callKnownMethod(saveDataManager, "getPlayTime()")
        if ok and result ~= nil then
            return managedValueToNumber(result)
        end
    end

    local saveData = getCurrentSaveData()
    local playTime = managedValueToNumber(getManagedValue(saveData, "PlayTime"))
    if playTime ~= nil then return playTime end

    local gameMngr = getGameManager()
    return managedValueToNumber(getManagedValue(gameMngr, "LastSavePlayTime"))
end

local function setCurrentPlayTimeSeconds(seconds)
    seconds = math.floor(tonumber(seconds) or 0)
    if seconds < 0 then seconds = 0 end

    local changed = false
    local saveDataManager = getSaveDataManager()
    local gameMngr = getGameManager()

    callKnownMethod(saveDataManager, "playTimeStop()")

    if gameMngr then
        changed = callKnownMethod(gameMngr, "setLastSavePlayTime(System.Single)", seconds) or changed
        changed = setKnownValue(gameMngr, "LastSavePlayTime", seconds, "System.Single") or changed
        callKnownMethod(gameMngr, "setLastSaveUpTimeSecond()")
        changed = setKnownValue(gameMngr, "FixPlayTime", false, "System.Boolean") or changed
    end

    local saveData = getCurrentSaveData()
    if saveData then
        changed = setKnownValue(saveData, "PlayTime", seconds, "System.Int32") or changed
    end

    callKnownMethod(saveDataManager, "playTimeRestart()")
    return changed
end

local function getMrEverywhereCount()
    local saveDataManager = getSaveDataManager()
    if not saveDataManager then return nil end

    local ok, result = callKnownMethod(saveDataManager, "getEasterEgg()")
    if ok and result ~= nil then
        return managedValueToNumber(result)
    end

    return nil
end

local function newGuid()
    local guidType = sdk.find_type_definition("System.Guid")
    if not guidType or not ValueType then return nil end

    local ok, guid = pcall(function()
        return ValueType.new(guidType):call("NewGuid()")
    end)

    if ok then return guid end
    return nil
end

local function getEasterEggSaveDataList()
    local saveDataManager = getSaveDataManager()
    if not saveDataManager then return nil end

    local systemSaveData = getManagedValue(saveDataManager, "_SystemSaveData")
    if not systemSaveData then return nil end

    return getManagedValue(systemSaveData, "EasterEggSaveDataList")
end

local function getManagedListCount(list)
    local ok, result = callKnownMethod(list, "get_Count()")
    if ok and result ~= nil then
        return managedValueToNumber(result)
    end

    return nil
end

local function setMrEverywheresToMax()
    local saveDataManager = getSaveDataManager()
    local easterEggList = getEasterEggSaveDataList()

    if not saveDataManager or not easterEggList then return false end

    local currentCount = getManagedListCount(easterEggList) or getMrEverywhereCount() or 0

    while currentCount > 20 do
        local removed = callKnownMethod(easterEggList, "RemoveAt(System.Int32)", currentCount - 1)
        if not removed then return false end
        currentCount = currentCount - 1
    end

    if currentCount == 20 then return true end

    local changed = false
    for _ = currentCount + 1, 20 do
        local guid = newGuid()
        if not guid then return changed end

        local ok, added = callKnownMethod(saveDataManager, "addEasterEgg(System.Guid, System.Int32)", guid, 1)
        if not ok then
            ok, added = callKnownMethod(saveDataManager, "addEasterEgg(System.Guid, System.Int32)", guid, sdk.create_int32(1))
        end
        if not ok or not added then
            ok = callKnownMethod(easterEggList, "Add(System.Guid)", guid)
        end

        changed = changed or ok
    end

    return changed
end

local function getWeaponLoadNum(gun)
    local ok, result = pcall(function()
        return gun:call("get_loadNum")
    end)

    if ok then
        return result
    end

    return nil
end

local function setWeaponLoadNum(gun, loadNum)
    pcall(function()
        gun:call("set_loadNum", loadNum)
    end)
end

local weapon_gun_holder_components = {
    "app.PlayerGun",
    "app.PlayerGunAfterJointFixed",
    "app.WeaponHandgunAppend",
    "app.WeaponHandgunAlbertAppend",
    "app.WeaponBurnerAppend",
    "app.WeaponGrenadeLauncherAppend",
    "app.WeaponShotgunAppend",
    "app.WeaponShotgunDBAppend",
    "app.CartridgeRequester",
    "app.Gunturret",
    "app.Item",
}

local function ensureWeaponHasAmmo(gun)
    if not gun then return end

    local loadNum = getWeaponLoadNum(gun)
    if loadNum ~= nil and loadNum <= 0 then
        setWeaponLoadNum(gun, 1)
    end
end

local function getWeaponGunFromHolder(holder)
    if not holder then return nil end

    local ok, gun = pcall(function()
        return holder:call("get_WeaponGun")
    end)

    if ok and gun then
        return gun
    end

    ok, gun = pcall(function()
        return holder:get_field("WeaponGun")
    end)

    if ok and gun then
        return gun
    end

    return nil
end

local function getGameObjectFromComponent(component)
    if not component then return nil end

    local ok, gameObject = pcall(function()
        return component:call("get_GameObject")
    end)

    if ok then
        return gameObject
    end

    return nil
end

local function ensureWeaponGunsOnGameObject(gameObject)
    if not gameObject then return end

    ensureWeaponHasAmmo(getComponent(gameObject, "app.WeaponGun"))

    for _, componentName in ipairs(weapon_gun_holder_components) do
        ensureWeaponHasAmmo(getWeaponGunFromHolder(getComponent(gameObject, componentName)))
    end
end

local function ensureWeaponObjectHasAmmo(weaponObject)
    if not weaponObject then return end

    ensureWeaponHasAmmo(weaponObject)
    ensureWeaponHasAmmo(getWeaponGunFromHolder(weaponObject))
    ensureWeaponGunsOnGameObject(getGameObjectFromComponent(weaponObject))
end

local function getCurrentWeapon(player)
    local motionController = getComponent(player, "app.PlayerMotionController")
    if not motionController then return nil end

    local ok, currentWeapon = pcall(function()
        return motionController:call("get_CurrentWeapon")
    end)

    if ok and currentWeapon then
        return currentWeapon
    end

    ok, currentWeapon = pcall(function()
        return motionController:get_field("CurrentWeapon")
    end)

    if ok and currentWeapon then
        return currentWeapon
    end

    return nil
end

local function ensureCurrentWeaponHasAmmo(player)
    if not settings.infinite_ammo then return end

    ensureWeaponObjectHasAmmo(getCurrentWeapon(player))
    ensureWeaponGunsOnGameObject(player)
end

local pending_infinite_ammo_gun = nil
local pending_infinite_ammo_load_num = 0
local pending_infinite_ammo_active = false

--region Hooks
sdk.hook(
    sdk.find_type_definition("app.PlayerMovement"):get_method("getMoveSpeed"),
    nil,
    function(retval)
        local original = sdk.to_float(retval)
        return sdk.float_to_ptr(original * settings.move_speed_multiplier)
    end
)

sdk.hook(
    sdk.find_type_definition("app.PlayerStatus"):get_method("get_passiveDamageRate"),
    nil,
    function(retval)
        if settings.godmode then
            return sdk.float_to_ptr(0.0)
        end

        return retval
    end
)

sdk.hook(
    sdk.find_type_definition("app.WeaponGun"):get_method("set_loadNum"),
    function(args)
        if not settings.infinite_ammo or not args[2] or not args[3] then
            return
        end

        local gun = sdk.to_managed_object(args[2])
        if not gun then
            return
        end

        local currentLoadNum = getWeaponLoadNum(gun)
        if currentLoadNum == nil then
            return
        end

        local requestedLoadNum = sdk.to_int64(args[3])
        if requestedLoadNum < currentLoadNum then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end,
    nil
)

sdk.hook(
    sdk.find_type_definition("app.WeaponGun"):get_method("update"),
    function(args)
        if settings.infinite_ammo and args[2] then
            ensureWeaponHasAmmo(sdk.to_managed_object(args[2]))
        end
    end,
    nil
)

sdk.hook(
    sdk.find_type_definition("app.WeaponGun"):get_method("expendBullet"),
    function(args)
        pending_infinite_ammo_gun = nil
        pending_infinite_ammo_load_num = 0
        pending_infinite_ammo_active = false

        if not settings.infinite_ammo or not args[2] then
            return
        end

        local gun = sdk.to_managed_object(args[2])
        if not gun then
            return
        end

        local loadNum = getWeaponLoadNum(gun)
        if loadNum == nil then
            return
        end

        pending_infinite_ammo_gun = gun
        pending_infinite_ammo_load_num = loadNum
        pending_infinite_ammo_active = true

        if loadNum <= 0 then
            setWeaponLoadNum(gun, 1)
        end
    end,
    function(retval)
        local gun = pending_infinite_ammo_gun
        local loadNum = pending_infinite_ammo_load_num
        local wasActive = pending_infinite_ammo_active
        pending_infinite_ammo_gun = nil
        pending_infinite_ammo_load_num = 0
        pending_infinite_ammo_active = false

        if not wasActive or not gun then
            return retval
        end

        setWeaponLoadNum(gun, math.max(1, loadNum))
        return sdk.to_ptr(1)
    end
)

sdk.hook(
    sdk.find_type_definition("app.Achievement"):get_method("addCount(app.Achievement.VariablesTagID)"),
    function(args)
        if settings.freeze_itembox_count and sdk.to_int64(args[3]) == AchievementTag.CountOfOpenItemBox then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end,
    nil
)

sdk.hook(
    sdk.find_type_definition("app.EnemyActionController"):get_method("calcDamageRate"),
    nil,
    function(retval)
        if settings.enemy_insta_kill then
            local original = sdk.to_float(retval)
            return sdk.float_to_ptr(original * 100000)
        else
            return retval
        end
    end
)

sdk.hook(
    sdk.find_type_definition("app.EnemyActionController"):get_method("get_latestAnimationSpeedRateForRank"),
    nil,
    function(retval)
        if settings.change_enemy_speed then
            local original = sdk.to_float(retval)
            return sdk.float_to_ptr(original * settings.enemy_speed_multiplier)
        else
            return retval
        end
    end
)

--endregion

-- region Noclip
local _noclip_cc_was_disabled = false
re.on_frame(function()
    local player = getLocalPlayer()
    if not player then
        return
    end

    ensureCurrentWeaponHasAmmo(player)

    local cc = getComponent(player, "via.physics.CharacterController")

    if not settings.noclip then
        if _noclip_cc_was_disabled and cc then
            pcall(function() cc:call("set_Enabled", true) end)
            _noclip_cc_was_disabled = false
        end
        return
    end

    pcall(function()
        if cc then
            pcall(function() cc:call("set_Enabled", false) end)
            _noclip_cc_was_disabled = true
        end

        local xf  = player:get_Transform()
        local pos = xf:get_Position()
        local spd = settings.noclip_speed
        local fwd = xf:call("get_Forward")
        local rgt = xf:call("get_Right")
        if reframework:is_key_down(0x57) then -- W: forward
            pos.x = pos.x + fwd.x * spd; pos.z = pos.z + fwd.z * spd
        end
        if reframework:is_key_down(0x53) then -- S: backward
            pos.x = pos.x - fwd.x * spd; pos.z = pos.z - fwd.z * spd
        end
        if reframework:is_key_down(0x44) then -- D: right
            pos.x = pos.x + rgt.x * spd; pos.z = pos.z + rgt.z * spd
        end
        if reframework:is_key_down(0x41) then -- A: left
            pos.x = pos.x - rgt.x * spd; pos.z = pos.z - rgt.z * spd
        end
        if reframework:is_key_down(0x20) then pos.y = pos.y + spd end -- Space: up
        if reframework:is_key_down(0x10) then pos.y = pos.y - spd end -- Shift: down
        xf:set_Position(pos)
    end)
end)
--endregion

--region UI
re.on_draw_ui(function()
    if imgui.tree_node("RE7 Ultimate Trainer") then
        imgui.text("Version " .. version)
        imgui.spacing()

        if imgui.tree_node("Player") then
            imgui.text("You'll no longer take damage with this.")
            local changedGodmode
            changedGodmode, settings.godmode = imgui.checkbox("God mode", settings.godmode)
            if changedGodmode then json.dump_file(settingsFile, settings) end

            local changedNoclip
            imgui.text("Move wherever you want.")
            changedNoclip, settings.noclip = imgui.checkbox("Noclip", settings.noclip)
            if changedNoclip then json.dump_file(settingsFile, settings) end

            local changedNoclipSpeed
            imgui.text("Noclip speed")
            changedNoclipSpeed, settings.noclip_speed = imgui.slider_float("delta x,y,z",
                settings.noclip_speed, 0.1, 1.0, nil)
            if changedNoclipSpeed then json.dump_file(settingsFile, settings) end

            local changedMovementSpeed
            imgui.text("Movement speed multiplier")
            changedMovementSpeed, settings.move_speed_multiplier = imgui.slider_float("x speed (player)",
                settings.move_speed_multiplier, 0.1, 100.0, nil)
            if changedMovementSpeed then json.dump_file(settingsFile, settings) end

            if imgui.button("Reset movement speed") then
                settings.move_speed_multiplier = 1.0
                json.dump_file(settingsFile, settings)
            end

            imgui.spacing()

            imgui.text("Position")
            imgui.set_next_item_width(50)
            local changedX, x = imgui.input_text("X", x, 1 << 0)
            imgui.same_line()
            imgui.set_next_item_width(50)
            local changedY, y = imgui.input_text("Y", y, 1 << 0)
            imgui.same_line()
            imgui.set_next_item_width(50)
            local changedZ, z = imgui.input_text("Z", z, 1 << 0)
            imgui.same_line()

            if changedX or changedY or changedZ then
                teleportPlayer(x, y, z)
            end

            imgui.spacing()

            imgui.text("Scale")
            local changedPlayerScale
            changedPlayerScale, settings.player_scale = imgui.slider_float("x scale (player)", settings.player_scale, 0.1,
                100.0, nil)

            if changedPlayerScale then
                changePlayerScale(settings.player_scale)
                json.dump_file(settingsFile, settings)
            end

            if imgui.button("Reset scale") then
                settings.player_scale = 1.0
                changePlayerScale(1.0)
                json.dump_file(settingsFile, settings)
            end

            imgui.tree_pop()
        end

        if imgui.tree_node("Weapons") then
            local changedInfAmmo
            imgui.text("Ammo count never decreases.")
            changedInfAmmo, settings.infinite_ammo = imgui.checkbox("Infinite ammo", settings.infinite_ammo)
            if changedInfAmmo then json.dump_file(settingsFile, settings) end

            imgui.tree_pop()
        end

        if imgui.tree_node("Items") then
            if imgui.button("Unlock all items in the item box") then
                addAllItemsToItemBox()
            end

            if imgui.button("Set maximum inventory size") then
                setExtendLv(2)
            end

            imgui.tree_pop()
        end

        if imgui.tree_node("Enemies") then
            imgui.text("Instantly kill enemies when damaging them.")
            local changedEnemyInstaKill
            changedEnemyInstaKill, settings.enemy_insta_kill = imgui.checkbox("Insta kill", settings.enemy_insta_kill)
            if changedEnemyInstaKill then json.dump_file(settingsFile, settings) end

            imgui.text("Whether to change the speed of enemies.")
            imgui.text("This won't work for all enemies and bosses!")
            local toggleEnemySpeed
            toggleEnemySpeed, settings.change_enemy_speed = imgui.checkbox("Change speed", settings.change_enemy_speed)
            if toggleEnemySpeed then json.dump_file(settingsFile, settings) end

            imgui.text("Movement speed multiplier")
            local changedMovementSpeed
            changedMovementSpeed, settings.enemy_speed_multiplier = imgui.slider_float("x speed (enemy)",
                settings.enemy_speed_multiplier, 0.1, 10.0, nil)
            if changedMovementSpeed then json.dump_file(settingsFile, settings) end

            if imgui.button("Reset movement speed") then
                settings.enemy_speed_multiplier = 1.0
                json.dump_file(settingsFile, settings)
            end

            imgui.tree_pop()
        end

        if imgui.tree_node("Stats") then
            local gameMngr = getGameManager()
            if gameMngr then
                local currentDifficulty = getCurrentGameDifficulty(gameMngr)
                imgui.text("Game difficulty: " .. getGameDifficultyLabel(currentDifficulty))

                for _, option in ipairs(GameDifficultyOptions) do
                    if imgui.button(option.label) then
                        setCurrentGameDifficulty(option.value)
                    end

                    if option.value < 2 then
                        imgui.same_line()
                    end
                end

                local currentRank = getCurrentGameRank(gameMngr)
                if currentRank ~= nil then
                    imgui.text("Current rank: " .. currentRank .. "/9")

                    if not rank_ui_initialized then
                        settings.selected_rank = currentRank
                        rank_ui_initialized = true
                    end
                end

                local changedRank
                changedRank, settings.selected_rank = imgui.slider_int("Target adaptive rank", settings.selected_rank, 0, 9)
                if changedRank then
                    json.dump_file(settingsFile, settings)
                end

                if imgui.button("Apply adaptive rank") then
                    setCurrentAdaptiveRank(settings.selected_rank)
                end
            end

            local currentPlayTime = getCurrentPlayTimeSeconds()
            if currentPlayTime ~= nil then
                imgui.text("Play time: " .. secondsToTimeText(currentPlayTime))

                if not play_time_ui_initialized then
                    settings.play_time_text = secondsToTimeText(currentPlayTime)
                    play_time_ui_initialized = true
                end
            end

            local changedPlayTime
            changedPlayTime, settings.play_time_text = imgui.input_text("Play time (hh:mm:ss)",
                settings.play_time_text)
            if changedPlayTime then
                json.dump_file(settingsFile, settings)
            end

            if imgui.button("Refresh play time") then
                settings.play_time_text = secondsToTimeText(getCurrentPlayTimeSeconds() or 0)
                json.dump_file(settingsFile, settings)
            end

            imgui.same_line()
            if imgui.button("Apply play time") then
                local seconds = timeTextToSeconds(settings.play_time_text)
                if seconds == nil then
                    stats_message = "Use play time format hh:mm:ss."
                elseif setCurrentPlayTimeSeconds(seconds) then
                    stats_message = "Play time set to " .. secondsToTimeText(seconds) .. "."
                else
                    stats_message = "Could not set play time."
                end
            end

            local changedItemBoxCount
            changedItemBoxCount, settings.freeze_itembox_count = imgui.checkbox("Freeze item box open count",
                settings.freeze_itembox_count)
            if changedItemBoxCount then
                json.dump_file(settingsFile, settings)
            end

            if imgui.button("Set restart count to 0") then
                local gameMngr = get_singleton("app.GameManager")
                gameMngr.RestartCount = sdk.create_int32(0)
            end

            if imgui.button("Set antique coins to max") then
                local normalCoins = setAchievementCount(AchievementTag.CountOfCoins, 18)
                local madhouseCoins = setAchievementCount(AchievementTag.CountOfCoinsForHard, 33)
                stats_message = normalCoins and madhouseCoins
                    and "Antique coins set to 18/18 and Madhouse coins to 33/33."
                    or "Could not set antique coins."
            end

            local mrEverywhereCount = getMrEverywhereCount()
            if mrEverywhereCount ~= nil then
                imgui.text("Mr Everywheres: " .. mrEverywhereCount .. "/20")
            end

            if imgui.button("Set 20/20 Mr Everywheres") then
                stats_message = setMrEverywheresToMax()
                    and "Mr Everywheres set to 20/20."
                    or "Could not set Mr Everywheres."
            end

            if imgui.button("Set healing/stabilizers/steroids used to 0") then
                local healing = setAchievementCount(AchievementTag.CountOfUsedCure, 0)
                local stabilizers = setAchievementCount(AchievementTag.CountOfStabilizers, 0)
                local steroids = setAchievementCount(AchievementTag.CountOfSteroids, 0)
                stats_message = healing and stabilizers and steroids
                    and "Healing, stabilizers, and steroids used set to 0."
                    or "Could not reset all used-item stats."
            end

            if imgui.button("Set 32/32 files") then
                stats_message = setAchievementCount(AchievementTag.CountOfFiles, 32)
                    and "Files set to 32/32."
                    or "Could not set files."
            end

            if stats_message ~= "" then
                imgui.text(stats_message)
            end

            imgui.tree_pop()
        end

        if imgui.tree_node("Miscellaneous") then
            if imgui.button("Set default settings") then
                settings = default_settings
            end

            if imgui.button("Print achievement stats") then
                local achvm = get_singleton("app.Achievement")

                for i, t in ipairs(AchievementTag) do
                    local ok, result = pcall(function()
                        return achvm:getCount(i)
                    end)

                    if ok then
                        log.debug(t .. " = " .. result)
                    end
                end
            end

            if imgui.button("Log data for troubleshooting") then
                log.debug("--------------------------------------------------")
                log.debug("RE7 Ultimate Trainer v" .. version)
                if getLocalPlayer() ~= nil then
                    log.debug("Is in game.")
                else
                    log.debug("Is not in game.")
                end
                log.debug("Game: " .. reframework:get_game_name())
                log.debug("REFramework commit count: " .. reframework:get_commit_count())
                log.debug("REFramework branch: " .. reframework:get_branch())
                log.debug("REFramework commit hash: " .. reframework:get_commit_hash())
                log.debug("REFramework tag: " .. reframework:get_tag())
                log.debug("REFramework build time: " ..
                    reframework:get_build_date() .. " - " .. reframework:get_build_time())
                log.debug("--------------------------------------------------")

                re.msg(
                    "Data logged. Please spawn the debug console and provide the output when describing your issue. You can spawn it in the menu above (ScriptRunner).")
            end

            imgui.tree_pop()
        end

        imgui.spacing()

        imgui.tree_pop()
    end
end)
--endregion
