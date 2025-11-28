-- RE7 Randomizer randomizing various aspects of the game.
-- Work in progress.
-- by d3sc0le (Discord: jvl.1an)
-- v1.0

if true then return end

if not reframework:get_game_name() == "re7" then
    re.msg("[RE7 Randomizer] Only compatible with RE7!")
    return
end

local re7utils = require("utility/RE7Utils")
local info

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
        local t = re7utils.to_table(spawnInfo)
        local filename = "spawns/spawnInfo_" .. alias .. "_" .. os.time() .. "_" .. math.random(0, 10000) .. ".json"
        json.dump_file(filename, t)
    else
        log.debug("Spawn info NULL!")
    end
end

local function dumpEnemyPool(args)
    local this = sdk.to_managed_object(args[2])
    local filename = "spawns/enemyPool_" .. os.time() .. "_" .. math.random(0, 10000) .. ".json"
    json.dump_file(filename, re7utils.to_table(this:get_field("<poolInstance>k__BackingField")))
end

sdk.hook(
    sdk.find_type_definition("app.EnemyActionController"):get_method("doAwake"),
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
