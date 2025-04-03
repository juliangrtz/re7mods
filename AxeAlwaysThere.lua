-- Adds the axe from the guest house to the item box.
-- v1.1
-- Apr 03, 2025
-- by d3sc0le (Discord: jvl.1an)

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

-- region Jack 2 softlock fix
-- Without this wacky fix, it is not possible to expose Jack's weak spot with the axe
-- during the fight in the basement. If you figure out a better solution that is closer to
-- Jack's original behavior feel free to contact me!

local em8010Core = nil -- Em8010 is Jack's mutated head (weak spot)
sdk.hook(sdk.find_type_definition("app.Em8010.Em8010Core"):get_method("doStart"),
	function(args)
		em8010Core = sdk.to_managed_object(args[2])
		print("Got Em8010Core object pointer.")
	end,
	function(retval) return retval end
)

local axeHits = 0
local requiredAxeHits = 10

sdk.hook(
	sdk.find_type_definition("app.Em8010.Em8010Core"):get_method("calcDamage"),
	function(args)
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
				--[[ namespace app::Em8010::Em8010Core {
					enum Order {
						None = 0,
						Open = 1,
						OpenGrapple = 2,
						Close = 3,
						DeactivateWithDead = 4,
						Damage = 5,
						CuttingFinal = 6,
						NormalFinal = 7,
					};
				} ]]
				em8010Core:tryOrder(1) -- Open
			else
				print("Failed to get Em8010Core!")
			end
		end
	end,
	function(retval)
		return retval
	end
)

-- endregion

local addAxe = true

sdk.hook(
	sdk.find_type_definition("app.InteractManager"):get_method("interactStart"), --app.InteractEventAction.startInteract(System.String)
	function(args)
		local interactObj = sdk.to_managed_object(args[3]):get_field("_InteractType")
		log.debug(interactObj)

		if addAxe then
			local player = get_localplayer()
			local inventory = get_component(player, "app.Inventory")
			if not inventory then return end

			local handAxeItemId = "HandAxe"
			local hasHandAxe = inventory:call("hasItemIncludeItemBox(System.String, System.Boolean)", handAxeItemId, true)

			if not hasHandAxe then
				local itemBoxData = inventory:get_field("<ItemBoxData>k__BackingField")
				itemBoxData:call("addItem(System.String, System.Int32, app.WeaponGun.WeaponGunSaveData)", handAxeItemId,
					1, nil)
			end
		end
	end,
	function(retval) return retval end
)

re.on_draw_ui(function()
	if imgui.tree_node("Axe from guest house mod") then
		imgui.spacing()
		imgui.begin_rect()
		_, addAxe = imgui.checkbox("Add axe to item box", addAxe)
		imgui.new_line()

		imgui.begin_rect()
		imgui.text(" Hits until Jack 2 reveals weak spot")
		local changed, value = imgui.slider_int("hits", requiredAxeHits, 1, 20, nil)

		if imgui.is_item_hovered() then
			imgui.set_tooltip(
				"Normally it is not possible to expose Jack's weak spot with the axe during the fight in the basement.\n" ..
				"Thus, his weak spot is forced to be exposed after a certain number of hits you can define here."
			)
		end
		imgui.end_rect(2)

		if changed then
			requiredAxeHits = value
		end

		imgui.end_rect(2)
		imgui.tree_pop()
	end
	imgui.text()
end)
