--Adds the starting axe to the item box
--v1.0
--Mar 28, 2025
--by desc0le

if not reframework:get_game_name() == "re7" then return end

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

-- ###################################################
--region 		Jack 2 softlock fix
-- ###################################################

-- Em8010 is Jack's mutated head during the saw fight.
local em8010Core = nil
sdk.hook(sdk.find_type_definition("app.Em8010.Em8010Core"):get_method("doStart"),
	function(args)
		em8010Core = sdk.to_managed_object(args[2])
		print("Got Em8010Core object pointer.")
	end,
	function(retval) return retval end
)

local axeHits = 0
local requiredAxeHits = 9
sdk.hook(
	sdk.find_type_definition("app.Em8010.Em8010Core"):get_method("calcDamage"),
	function(args) --pre
		local dmgInfo = sdk.to_managed_object(args[3])
		local dmg = { "Damage", "DamageMax", "Stun", "StunMax" }
		for i = 1, #dmg do log.debug(dmg[i] .. ": " .. dmgInfo:get_field(dmg[i])) end

		local attackGameObject = dmgInfo:get_field("AttackGameObjectList")[0]
		local attackWeapon = attackGameObject:call("get_Name")

		if string.find(attackWeapon, "Axe") then
			axeHits = axeHits + 1
			print(axeHits .. " hits with the axe")
		end

		print("-----------------------------------------------")

		if axeHits > 0 and axeHits % requiredAxeHits == 0 then
			if em8010Core then
				print("SHOWING JACK'S CORE!")
				em8010Core:tryOrder(1)
			else
				print("Failed to get Em8010Core!")
			end
		end
	end,
	function(retval)
		return retval
	end
)

-- ###################################################
--endregion
-- ###################################################

re.on_draw_ui(function()
	if imgui.tree_node("Starting Axe Mod") then
		imgui.begin_rect()
		imgui.text("Clicking this button when you already have the axe has no effect.")
		if imgui.button("Add axe to item box") then
			local player = get_localplayer()
			local inventory = get_component(player, "app.Inventory")
			if not inventory then return end

			-- itemDataId, includeItemBox
			local hasHandAxe = inventory:call("hasItemIncludeItemBox(System.String, System.Boolean)", "HandAxe", true)

			if not hasHandAxe then
				local itemBoxData = inventory:get_field("<ItemBoxData>k__BackingField")
				-- itemDataId, amount, gunSaveData
				itemBoxData:call("addItem(System.String, System.Int32, app.WeaponGun.WeaponGunSaveData)", "HandAxe", 1,
					nil)
			end
		end

		imgui.end_rect(2)
		imgui.tree_pop()
	end
	imgui.text()
end)
