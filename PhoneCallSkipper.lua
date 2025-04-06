local enabled = true
if not enabled then return end

local re7 = require("utility/RE7")

sdk.hook(
    sdk.find_type_definition("app.InteractManager"):get_method("interactStart"), --app.InteractEventAction.startInteract(System.String)
    function(args)
        local interactObj = sdk.to_managed_object(args[3]):get_field("_InteractType")
        log.debug(interactObj)
    end,
    function(retval) return retval end
)

re.on_draw_ui(function()
    if imgui.tree_node("Phone Call Skipper") then
        imgui.begin_rect()
        imgui.text(re7.is_in_cutscene and "In Cutscene" or "Not in cutscene")

        if imgui.button("Set timescale to 1") then setTimescale(1.0) end
        if imgui.button("Set timescale to 5") then setTimescale(5.0) end
        if imgui.button("Set timescale to 100") then setTimescale(100.1) end

        imgui.end_rect(2)
        imgui.tree_pop()
    end
    imgui.text()
end)
