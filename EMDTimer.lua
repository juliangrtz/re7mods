-- Timer for the Ethan Must Die game mode. It's displayed in the top left corner of the screen.
-- by d3sc0le (Discord: jvl.1an)
-- v1.1

if not reframework:get_game_name() == "re7" then
    re.msg("[Ethan Must Die Timer] Only compatible with RE7!")
    return
end

local igt
local hrs, mins, secs, ms
local stopped
local timerPositions = {
    "Top left",
    "Top center",
    "Top right",
    "Bottom left",
    "Bottom center",
    "Bottom right"
}

-- region Settings
local settingsJson = "EthanMustDieTimer.json"
local default_settings = {
    timerPosIndex = 1,
    enabled = true,
    color = 0xffffffff
}
local settings = json.load_file(settingsJson) or {}
for k, v in pairs(default_settings) do
    if settings[k] == nil then
        settings[k] = v
    end
end
--endregion

sdk.hook(
    sdk.find_type_definition("app.InGameTimerForIMD"):get_method("tStart"),
    function(args)
        stopped = false
        igt = sdk.to_managed_object(args[2])
    end,
    function(r) return r end
)

sdk.hook(
    sdk.find_type_definition("app.Chapter3_IMD_Result"):get_method("onOpen"),
    function(_) stopped = true end,
    function(r) return r end
)

sdk.hook(
    sdk.find_type_definition("app.PlayerDamageController"):get_method("doDie"),
    function(_) stopped = true end,
    function(r) return r end
)

sdk.hook(
    sdk.find_type_definition("app.InGameTimerForIMD"):get_method("onDestroy"),
    function(_) igt = nil end,
    function(r) return r end
)

local function formatTime(hours, minutes, seconds, milliseconds)
    if hours > 0 then
        return string.format("%02d:%02d:%02d:%03d", hours, minutes, seconds, milliseconds)
    else
        return string.format("%02d:%02d:%03d", minutes, seconds, milliseconds)
    end
end

local function getCoordinates()
    local pos = timerPositions[settings.timerPosIndex]
    local scene_manager = sdk.get_native_singleton("via.SceneManager")
    local scene_manager_type = sdk.find_type_definition("via.SceneManager")
    local view = sdk.call_native_func(scene_manager, scene_manager_type, "get_MainView")
    if not view then return 0, 0 end

    local size = view:call("get_Size")
    local w, h = size.w, size.h
    local padding = 20
    local textWidth = 50  -- estimate
    local textHeight = 25 -- estimate

    if pos == "Top left" then
        return padding, padding
    elseif pos == "Top center" then
        return (w / 2) - (textWidth / 2), padding
    elseif pos == "Top right" then
        return w - textWidth - padding, padding
    elseif pos == "Bottom left" then
        return padding, h - textHeight - padding
    elseif pos == "Bottom center" then
        return (w / 2) - (textWidth / 2), h - textHeight - padding
    elseif pos == "Bottom right" then
        return w - textWidth - padding, h - textHeight - padding
    end

    return 0, 0
end

re.on_frame(function()
    if not igt then return end

    if not stopped then
        hrs = igt:call("getCurrentHours") or 0
        mins = igt:call("getCurrentMinutes") or 0
        secs = igt:call("getCurrentSeconds") or 0
        ms = igt:call("getCurrentMilliseconds") or 0
    end

    local x, y = getCoordinates()
    draw.text(formatTime(hrs, mins, secs, ms), x, y, settings.color)
end)

re.on_draw_ui(function()
    if imgui.tree_node("Ethan Must Die Timer") then
        local changedEnabled, changedTimerPos, changedColor
        changedEnabled, settings.enabled = imgui.checkbox("Enabled", settings.enabled)
        changedTimerPos, settings.timerPosIndex = imgui.combo("Position", settings.timerPosIndex, timerPositions)
        changedColor, settings.color = imgui.color_picker("Color", settings.color, 0)

        local changed = changedEnabled or changedTimerPos or changedColor
        if changed then json.dump_file(settingsJson, settings) end
        imgui.tree_pop()
    end
end)
