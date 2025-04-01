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

		imgui.text("Use this when the axe does not damage enemies.")
		if imgui.button(not useKnifeCollision and "Make axe behave like knife" or "Reset default axe collision") then
			local itemList = sdk.get_managed_singleton("app.InventorySystem"):get_field("ActivePlayerInventory")
				:get_field("_ItemList")
			local items = itemList:get_field("mItems")
			local n = itemList:get_field("mSize")

			local knife = nil
			local axe = nil

			for i = 0, n - 1 do
				local item = items[i]:get_field("Item")
				local id = item:get_field("ItemDataID")

				if id == "Knife" then
					knife = item
				elseif id == "HandAxe" then
					axe = item
				end
			end

			if knife == nil or axe == nil then
				log.debug("Need both axe and knife in inventory.")
				return
			end

			useKnifeCollision = not useKnifeCollision

			local knifeWeap = knife:get_field("<weapon>k__BackingField")
			local axeWeap = axe:get_field("<weapon>k__BackingField")

			if tmpAxeWeap == nil then tmpAxeWeap = axeWeap end

			if useKnifeCollision then
				local axeHitController = axeWeap:get_field("HitController")
				local knifeHitController = knifeWeap:get_field("HitController")
				local fieldsToReplace = {
					"_Damage",
					"AttackManager",
					"DamageManager",
					"PressManager",
					"CalculateAttack",
					"CalculatePress",
					"Colliders"
				}

				for i = 1, #fieldsToReplace do
					axeHitController:set_field(fieldsToReplace[i], knifeHitController:get_field(fieldsToReplace[i]))
					log.debug("Replaced " .. fieldsToReplace[i])
				end

				axeWeap.HitController = axeHitController
			else
				axe:set_field("<weapon>k__BackingField", tmpAxeWeap)
			end
		end

		imgui.end_rect(2)
		imgui.tree_pop()
	end
	imgui.text()
end)
