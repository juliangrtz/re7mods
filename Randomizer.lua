-- RE7 Randomizer randomizing various aspects of the game.
-- by d3sc0le (Discord: jvl.1an)
-- v1.0

if not reframework:get_game_name() == "re7" then
    re.msg("[RE7 Randomizer] Only compatible with RE7!")
    return
end

local re7utils = require("utility/RE7Utils")
local info
local loc

local function to_table(managedObj)
    if not managedObj then return nil end

    local t = {}
    local klass = sdk.find_type_definition(managedObj:get_type_definition():get_full_name())
    if not klass then return t end

    local fields = klass:get_fields()
    for i = 0, #fields - 1 do
        local field = fields[i]
        local ok, value = pcall(function()
            return field:get_data(managedObj)
        end)
        if ok then
            if sdk.is_managed_object(value) then
                t[field:get_name()] = to_table(value)
            else
                t[field:get_name()] = value
            end
        end
    end

    return t
end

local function dumpSpawnInfo(args, spawnInfoPos)
    local spawnInfo = sdk.to_managed_object(args[spawnInfoPos])
    local alias = string.lower(tostring(spawnInfo.UnitAlias))
    local name = re7utils.Enemies[alias]
    if name then
        log.debug(name .. " spawned.")
    else
        log.debug(alias .. " spawned (unknown enemy type).")
    end
    if spawnInfo then
        local t = to_table(spawnInfo)
        local filename = "spawns/spawnInfo_" .. alias .. "_" .. os.time() .. "_" .. math.random(0, 10000) .. ".json"
        json.dump_file(filename, t)
    else
        log.debug("Spawn info NULL!")
    end
end

sdk.hook(
    sdk.find_type_definition("app.EnemyGeneratorManager"):get_method("requestSpawn"),
    function(args)
        dumpSpawnInfo(args, 3)
    end,
    nil
)

sdk.hook(
    sdk.find_type_definition("app.EnemyGenerator"):get_method("addSpawnInfo"),
    function(args)
        dumpSpawnInfo(args, 3)
    end,
    nil
)

sdk.hook(
    sdk.find_type_definition("app.EnemyGenerator"):get_method("spawn"),
    function(args)
        dumpSpawnInfo(args, 3)
    end,
    nil
)

sdk.hook(
    sdk.find_type_definition("app.EnemyGenerator"):get_method("spawnImplement"),
    function(args)
        dumpSpawnInfo(args, 3)
    end,
    nil
)

sdk.hook(
    sdk.find_type_definition("app.EnemyGenerator"):get_method("spawn"),
    function(args)
        dumpSpawnInfo(args, 3)
    end,
    nil
)

--[[
        local g = sdk.to_managed_object(args[3])
        log.debug("New enemy generator: " .. g.Alias)
--]]

-- WIP: Won't work.

local function spawnEnemy(enemyType, quantity)
    info.UnitAlias = "Em3600"
    info:spawnInstance()
end

re.on_draw_ui(function()
    if imgui.tree_node("Randomizer") then
        if imgui.button("Spawn Enemy") then
            spawnEnemy("molded", 2)
        end
        imgui.tree_pop()
    end
end)
