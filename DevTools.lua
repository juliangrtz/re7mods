-- Various dev tools that make RE7 mod development easier.
-- by d3sc0le

local re7utils = require("utility/RE7Utils")

re.on_draw_ui(function()
    if imgui.tree_node("Developer Tools") then
        if imgui.button("Log player position") then
            local player = re7utils.get_localplayer()
            if not player then return end
            log.debug(re7utils.vec3tostring(player:get_Transform():get_Position()))
        end

        if imgui.button("Clear debug console") then
            re7utils.clearDebugConsole()
        end

        imgui.tree_pop()
    end
end)
