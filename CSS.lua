local enabled = false
if not enabled then return end

local re7 = require("utility/RE7")
--local scene = sdk.call_native_func(sdk.get_native_singleton("via.SceneManager"), sdk.find_type_definition("via.SceneManager"), "get_CurrentScene()")

re.on_draw_ui(function()
    --scene:call("set_TimeScale(System.Single)", inCutscene and 100.1 or 1)

    if imgui.tree_node("Cutscene Skip") then
        imgui.begin_rect()
        imgui.text(re7.is_in_cutscene and "In Cutscene" or "Not in cutscene")
        imgui.end_rect(2)
        imgui.tree_pop()
    end
    imgui.text()
end)
