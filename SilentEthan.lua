local silent_ethan = false
if not silent_ethan then return end

local function get_localplayer()
    local object_man = sdk.get_managed_singleton("app.ObjectManager")

    if not object_man then
        return nil
    end

    return object_man:get_field("PlayerObj")
end

local function print_components(game_object)
    local transform = game_object:get_Transform()
    if not transform then return end

    log.debug(game_object:get_Name())

    local components = game_object:get_Components()
    for i = 1, #components do
        local name = components[i]:get_type_definition():get_full_name()

        if string.find(name, "wwise") ~= nil or string.find(name, "Wwise") ~= nil then
            log.debug("Component " .. i .. ": " .. name)
        end
    end
end

sdk.hook(
    sdk.find_type_definition("via.wwise.WwiseContainer"):get_method("trigger"),
    function(args)
        -- local g = sdk.to_managed_object(args[2])
        -- log.debug(g == get_localplayer())
        return sdk.PreHookResult.SKIP_ORIGINAL
    end,
    nil
)

re.on_draw_ui(function()
    if imgui.tree_node("Silent Ethan") then
        _, silent_ethan = imgui.checkbox("Active", silent_ethan)

        if imgui.button("Log Player components") then
            local p = get_localplayer()
            print_components(p)
        end

        imgui.tree_pop()
    end
end)
