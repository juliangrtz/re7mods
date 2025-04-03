-- WARNING: THIS IS NOT WORKING YET
if true then return end

local re7 = require("utility/RE7")
local scene = sdk.call_native_func(sdk.get_native_singleton("via.SceneManager"),
    sdk.find_type_definition("via.SceneManager"), "get_CurrentScene()")
local enabled = false
local cutscene_speed = 5
local last_state = nil

re.on_draw_ui(function()
    if imgui.tree_node("Cutscene Skip") then
        imgui.begin_rect()

        if imgui.button(enabled and "Disable CSS" or "Enable CSS") then
            enabled = not enabled
        end
        imgui.end_rect(2)
        imgui.tree_pop()
    end
    imgui.text()
end)

re.on_frame(function()
    if not re7.is_in_cutscene then return end
    local new_state = re7.is_in_cutscene and enabled or 1
    if new_state ~= last_state then
        scene:call("set_TimeScale(System.Single)", new_state)
        last_state = new_state
    end
end)
