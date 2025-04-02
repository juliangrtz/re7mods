--Adds the starting axe to the item box
--v1.0
--Mar 28, 2025
--by desc0le

if not reframework:get_game_name() == "re7" then return end

local useKnifeCollision = false

local function get_localplayer()
	local object_man = sdk.get_managed_singleton("app.ObjectManager")

	if not object_man then
		return nil
	end

	return object_man:get_field("PlayerObj")
end

local known_typeofs = {}
local function get_component(game_object, type_name)
	local t = known_typeofs[type_name] or sdk.typeof(type_name)

	if t == nil then
		return nil
	end

	known_typeofs[type_name] = t
	return game_object:call("getComponent(System.Type)", t)
end

local tmpAxeWeap = nil

sdk.hook(
	sdk.find_type_definition("app.Em3000.Em3000DamageController"):get_method("calcDamage"),
	function(args) --pre
		local dmg = { "Damage", "DamageMax", "Stun", "StunMax" }
		local dmgInfo = sdk.to_managed_object(args[3])

		for i = 1, #dmg do
			log.debug(dmg[i] .. ": " .. dmgInfo:get_field(dmg[i]))
		end

		log.debug("")
	end,
	function(retval)

	end
)

--[[ sdk.hook(
	sdk.find_type_definition("app.Em8000.Em8000DamageDecider"):get_method("getSmallDamageId"),
	function(args) --pre

	end,
	function(retval)
		log.debug("getSmallDamageId() = " .. retval)
		return retval
	end --post
) ]]

re.on_draw_ui(function()
	if imgui.tree_node("Starting Axe Mod") then
		imgui.begin_rect()
		imgui.text("Clicking this button when you already have the axe has no effect.")
		if imgui.button("Add axe to item box") then
			local player = get_localplayer()
			local inventory = get_component(player, "app.Inventory")
			local hasHandAxe = inventory:call("hasItemIncludeItemBox(System.String, System.Boolean)", "HandAxe", true) -- itemDataId, includeItemBox

			if not hasHandAxe then
				local itemBoxData = inventory:get_field("<ItemBoxData>k__BackingField")
				itemBoxData:call("addItem(System.String, System.Int32, app.WeaponGun.WeaponGunSaveData)", "HandAxe", 1,
					nil) -- itemDataId, amount, gunSaveData
				-- CH9_WP006 (Dual AMG)
				-- Handgun_Albert (wp1340_ChrisHandgun_Item)
			end
		end

		imgui.end_rect(2)
		imgui.tree_pop()
	end
	imgui.text()
end)
