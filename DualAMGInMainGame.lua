--Dual AMG in Main Game mod
--End of Zoe DLC is required to use this
--v1.0
--Mar 27, 2025
--by desc0le

if not reframework:get_game_name() == "re7" then return end

local known_typeofs = {}
local function get_component(game_object, type_name)
    local t = known_typeofs[type_name] or sdk.typeof(type_name)

    if t == nil then 
        return nil
    end

    known_typeofs[type_name] = t
    return game_object:call("getComponent(System.Type)", t)
end

--[[*
re.on_draw_ui(function()
	if imgui.tree_node("Dual AMG in main game") then
		imgui.begin_rect()
		--imgui.text("Ensure that you have a free slot in your inventory!")
		if imgui.button("Add Dual AMG to Item Box") then
			 -- wp1340_ChrisHandgun_Reward_Item
			 -- wp1620_GauntletW_Item
			 local itemBoxData = get_component(player, "app.Inventory"):get_field("app.ItemBoxData")
			 local success = itemBoxData:call("addItem(System.String, System.Int32, app.WeaponGun.WeaponGunSaveData)", "HandAxe", 1, nil)
			 log.info(success)
			 --imgui.text(success)

			 --local inventory = get_component(player, "app.Inventory")
			 --inventory:call("isAddItem(System.String, System.Int32)", "HandAxe", 1)
		end
		imgui.end_rect(2)
		imgui.tree_pop()
	end
	imgui.text()
end)
*--]]