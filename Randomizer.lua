-- RE7 Randomizer randomizing various aspects of the game.
-- by d3sc0le (Discord: jvl.1an)
-- v1.0

if not reframework:get_game_name() == "re7" then
    re.msg("[RE7 Randomizer] Only compatible with RE7!")
    return
end

--[[ em2000: Mia
em3000: Jack
em3100: Marguerite
em3200: Lucas
em3300: Old Eveline
em3400: Zoe
em3550: Young Eveline
em3600: Marguerite Fight Boss
em4000: Molded
em4100: 4-Legged Molded
em4200: Fat Molded
em5200: Crow
em5400: Insects
em5500: Darker Insects
em5600: Cockroach
em6000: Alan
em6100: Police David
em6200: Andre
em6500: Molded David
em8000: Jack Saw Fight
em8100: Jack Eyes Boss
em8900: Evie Final Form
em9200: Pete
em9600: ??
em9700: Dead Andre
em9900: "Worker David" ]]

local info
local loc
sdk.hook(
    sdk.find_type_definition("app.EnemyGeneratorManager"):get_method("requestSpawn"),
    function(args)
        local spawnInfo = sdk.to_managed_object(args[3])
        info = spawnInfo
        local externalLocation = args[4]
        loc = externalLocation
        log.debug(spawnInfo.UnitAlias)
    end,
    nil
)

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
