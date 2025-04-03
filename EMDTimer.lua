-- Configurable timer for the Ethan Must Die game mode
-- by desc0le

-- app.PauseManager.PauseObject.onPause()

if not reframework:get_game_name() == "re7" then
    log.error("[Ethan Must Die Timer] Only compatible with RE7, duh.")
    return
end

local enabled = false
local igt = nil
local stopped = false

if not enabled then return end

sdk.hook(
    sdk.find_type_definition("app.InGameTimerForIMD"):get_method("start"),
    function(args)
        stopped = false
        igt = sdk.to_managed_object(args[2])
    end,
    function(r) return r end
)

sdk.hook(
    sdk.find_type_definition("app.InGameTimerForIMD"):get_method("stop"),
    function(_) stopped = true end,
    function(r) return r end
)

function formatTime(hours, minutes, seconds, milliseconds)
    if hours > 0 then
        return string.format("%02d:%02d:%02d:%03d", hours, minutes, seconds, milliseconds)
    else
        return string.format("%02d:%02d:%03d", minutes, seconds, milliseconds)
    end
end

re.on_frame(
    function()
        if igt == nil or stopped then return end
        local hrs = igt and igt:call("getCurrentHours") or 0
        local mins = igt and igt:call("getCurrentMinutes") or 0
        local secs = igt and igt:call("getCurrentSeconds") or 0
        local ms = igt and igt:call("getCurrentMilliseconds") or 0
        --log.debug(formatTime(hrs, mins, secs, ms))
        draw.text(formatTime(hrs, mins, secs, ms), 0, 0, 0xFFFFFFFF)
    end
)
