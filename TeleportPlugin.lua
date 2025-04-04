--Author: NSA Cloud
local PLUGIN_VERSION = "V3"
if true then return end

--NOTE: There is nothing to configure here. Any teleport points should be added in the plugin menu.

---#CONFIG#---
local LOAD_CONFIG_FILE = true
local config = {
	tpTable = {},
	tpNameTable = {},
}

local tpTable = {}
local tpNameTable = {}
local config_path = "TeleportPlugin/TeleportPoints.json"
local re7utils = require("utility/RE7Utils")

local selectedTPIndex = 1
function loadConfig()
	local config_file = json.load_file(config_path)
	selectedTPIndex = 1
	tpTable = {}
	tpNameTable = {}
	if config_file ~= nil then
		config = config_file
		if config.tpNameTable ~= nil then
			tpNameTable = config.tpNameTable
		end
		tpTable = {}
		if config.tpTable ~= nil then
			for k, v in pairs(config.tpTable) do -- Import tables as vectors
				table.insert(tpTable,
					{
						pos = Vector3f.new(v.pos[1], v.pos[2], v.pos[3]),
						rot = Vector4f.new(v.rot[1], v.rot[2], v.rot[3],
							v.rot[4])
					})
			end
		end
	else
		json.dump_file(config_path, config)
	end
end

if LOAD_CONFIG_FILE then
	loadConfig()
end

local function checkTPNameUsage(name)
	if tpNameTable ~= nil then
		for i, value in pairs(tpNameTable) do
			if value == name then
				return true
			end
		end
	end
	return false
end

local currentTPName = "New Teleport Point"
local currentTPPos = Vector3f.new(0.0, 0.0, 0.0)
local currentTPRot = Vector4f.new(0.0, 0.0, 0.0, 1.0)

local noClipEnabled = false

local previousPos = nil
local previousRot = nil

local noclipStep = 0.15
local noclipPos = Vector3f.new(0.0, 0.0, 0.0)
local noclipRot = nil

local noclipPreviousPos = nil
local noclipPreviousRot = nil

local selectedTPTargetIndex = 1

local sceneManager = sdk.get_native_singleton("via.SceneManager")
if not sceneManager then return end

local function get_player_transform()
	return re7utils.get_localplayer():get_Transform()
end

local function set_player_transform(pos, rot)
	local PlayerBody_Transform = get_player_transform()
	local PlayerBody_CharaController = re7utils.get_component(PlayerBody_Transform, "via.physics.CharacterController")

	if PlayerBody_Transform and PlayerBody_CharaController then
		--log.info("Found player transform")
		PlayerBody_CharaController:call("warp")
		PlayerBody_Transform:call("set_Position", pos)
		PlayerBody_CharaController:call("warp")
		PlayerBody_Transform:call("set_Rotation", rot)
	end
end

re.on_frame(function()
	if noClipEnabled then
		if noclipPos ~= nil and noclipRot ~= nil then
			set_player_transform(noclipPos, noclipRot)
		end
	end
end)

---#UI#---
re.on_draw_ui(function()
	local changed = false

	if imgui.tree_node("Teleport Plugin") then
		if imgui.tree_node("Add New Teleport Point") then
			changed, currentTPName = imgui.input_text("Teleport Point Name", currentTPName)
			imgui.spacing()
			if imgui.button("Get Teleport Target Coordinates") then
				local transforms = get_player_transform()
				if transforms ~= nil then
					currentTPPos = transforms.pos
					currentTPRot = transforms.rot
				end
			end
			imgui.spacing()
			changed, currentTPPos = imgui.drag_float3("Position", currentTPPos, 1.0, -100000000.0, 100000000.0)
			changed, currentTPRot = imgui.drag_float4("Rotation", currentTPRot, 0.05, -1.0, 1.0)
			imgui.spacing()
			if imgui.button("Add Teleport Point") then
				local tpEntry = {
					pos = currentTPPos,
					rot = currentTPRot,
				}
				local newTPName = currentTPName
				if checkTPNameUsage(currentTPName) then
					local currentIndex = 1
					newTPName = currentTPName .. " (" .. currentIndex .. ")"
					while (checkTPNameUsage(newTPName)) do
						currentIndex = currentIndex + 1
						newTPName = currentTPName .. " (" .. currentIndex .. ")"
					end
				end


				table.insert(tpNameTable, newTPName)
				table.insert(tpTable, tpEntry)
			end
			imgui.spacing()
			imgui.tree_pop()
		end

		if imgui.tree_node("Teleport List") then
			if imgui.button("Save Teleport Config") then
				if json.load_file(config_path) ~= config then
					config.tpNameTable = tpNameTable
					--config.tpTable = tpTable
					--Vectors become null, so convert them into a table when saving
					config.tpTable = {}
					for k, v in pairs(tpTable) do
						table.insert(config.tpTable,
							{ pos = { v.pos.x, v.pos.y, v.pos.z }, rot = { v.rot.x, v.rot.y, v.rot.z, v.rot.w } })
					end
					json.dump_file(config_path, config)
				end
			end
			imgui.same_line()
			if imgui.button("Reload Teleport Config") then
				loadConfig()
			end
			imgui.spacing()
			if imgui.button("Delete Selected Teleport Point") then
				if next(tpNameTable) ~= nil then
					table.remove(tpNameTable, selectedTPIndex)
					table.remove(tpTable, selectedTPIndex)
					selectedTPIndex = selectedTPIndex - 1
				end
			end
			if tpNameTable ~= nil and tpTable ~= nil and next(tpNameTable) ~= nil and next(tpTable) ~= nil and selectedTPIndex > 0 then
				imgui.spacing()
				imgui.text(string.format("Position X: %.3f, Y: %.3f, Z: %.3f", tpTable[selectedTPIndex].pos.x,
					tpTable[selectedTPIndex].pos.y, tpTable[selectedTPIndex].pos.z))
				imgui.spacing()
			else
				imgui.spacing()
				imgui.text("No teleport points set.") --Keep text field there so UI doesn't shift when all points are deleted
				imgui.spacing()
			end
			changed, selectedTPIndex = imgui.combo("Teleport Point", selectedTPIndex, tpNameTable)
			imgui.spacing()
			if imgui.button("Teleport") then
				if next(tpNameTable) ~= nil then
					--previousPos,previousRot = get_player_transform()
					local transforms = get_player_transform()
					if transforms ~= nil then
						previousPos = transforms.pos
						previousRot = transforms.rot
					end
					set_player_transform(tpTable[selectedTPIndex].pos, tpTable[selectedTPIndex].rot)
				end
			end
			imgui.same_line()
			if imgui.button("Undo Teleport") then
				if previousPos ~= nil then
					set_player_transform(previousPos, previousRot)
				end
			end
			imgui.tree_pop()
		end
		if imgui.tree_node("No Clip") then
			changed, noClipEnabled = imgui.checkbox("Enable No Clip (Fly)", noClipEnabled)
			if changed then
				local transform = get_player_transform()
				if transform ~= nil then
					noclipPos = transform.pos
					noclipRot = transform.rot
				end
			end

			imgui.text("Use the No Clip Position sliders to set the player position after enabling No Clip.")
			imgui.spacing()
			changed, noclipStep = imgui.drag_float("Increment (Speed)", noclipStep, 0.01, 0.001, 100.0)
			changed, noclipPos = imgui.drag_float3("No Clip Position", noclipPos, noclipStep, -100000000.0, 100000000.0)
			imgui.spacing()

			imgui.spacing()
		end
		imgui.tree_pop()
		imgui.spacing()
		imgui.spacing()
		imgui.text("Teleport Plugin " .. PLUGIN_VERSION .. " by NSA Cloud")
		imgui.spacing()
		imgui.spacing()
		imgui.tree_pop()
	end
end)
