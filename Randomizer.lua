-- RE7 Randomizer randomizing various aspects of the game.
-- by d3sc0le (Discord: jvl.1an)
-- v1.0

if not reframework:get_game_name() == "re7" then
    re.msg("[RE7 Randomizer] Only compatible with RE7!")
    return
end

local function spawnEnemy(enemyType, quantity)
    -- EnemyGenerator.spawn
    -- app.EnemySpawnInfo
end

re.on_draw_ui(function()
    if imgui.tree_node("Randomizer") then
        if imgui.button("Spawn Molded") then
            spawnEnemy("molded", 2)
        end
        imgui.tree_pop()
    end
end)
