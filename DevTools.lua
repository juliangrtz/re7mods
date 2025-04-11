-- Various dev tools that make RE7 mod development easier.
-- by d3sc0le

local re7utils = require("utility/RE7Utils")
local freezeAmmo = false

sdk.hook(
    sdk.find_type_definition("app.WeaponGun"):get_method("set_loadNum(System.Int32)"),
    function(_) if freezeAmmo then return sdk.PreHookResult.SKIP_ORIGINAL end end,
    function(r) return r end
)

re.on_draw_ui(function()
    if imgui.tree_node("Developer Tools") then
        _, freezeAmmo = imgui.checkbox("Freeze ammo", freezeAmmo)
        
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
