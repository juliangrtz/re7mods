local enabled = true
if not enabled then return end

local re7 = require("utility/RE7")
local scene = sdk.call_native_func(sdk.get_native_singleton("via.SceneManager"),
    sdk.find_type_definition("via.SceneManager"), "get_CurrentScene()")

local function setTimescale(scale)
    pcall(scene.call, scene, "set_TimeScale(System.Single)", scale)
end

re.on_draw_ui(function()
    if imgui.tree_node("Cutscene Skip") then
        imgui.begin_rect()
        imgui.text(re7.is_in_cutscene and "In Cutscene" or "Not in cutscene")

        if imgui.button("Set timescale to 1") then
            setTimescale(1.0)
        end

        if imgui.button("Set timescale to 5") then
            setTimescale(5.0)
        end

        imgui.end_rect(2)
        imgui.tree_pop()
    end
    imgui.text()
end)
