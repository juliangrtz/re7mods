-- Open the item box anywhere in the game.
-- Not working yet.
-- by d3sc0le
-- v1.0

if reframework:get_game_name() ~= "re7" then
    re.msg("[Item Box Opener] Only compatible with RE7!")
    return
end

local actionArg
local handle
local open_menu_item_box

sdk.hook(
    sdk.find_type_definition("app.fsm.OpenMenuItemBox"):get_method(
        "start(via.fsm.ActionArg)"),
    function(args)
        open_menu_item_box = sdk.to_managed_object(args[2])
        actionArg = args[3]
        handle = open_menu_item_box._ItemBoxMenuHandle
    end,
    function(retval) return retval end
)

re.on_draw_ui(function()
    if imgui.tree_node("Item Box Opener") then
        if imgui.button("Open item box") then
            open_menu_item_box._ItemBoxMenuHandle = handle
            open_menu_item_box:start(actionArg)
        end

        imgui.tree_pop()
    end
end)
