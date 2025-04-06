local enabled = true
if not enabled then return end

--local re7 = require("utility/RE7")

sdk.hook(
    sdk.find_type_definition("app.InteractManager"):get_method("isPermitInteract"), --app.InteractEventAction.startInteract(System.String)
    function(args)

    end,
    function(retval) return true end
)

local gameEventActionController
sdk.hook(
    sdk.find_type_definition("app.GameEventActionController"):get_method("doStart"), --app.InteractEventAction.startInteract(System.String)
    function(args)
        gameEventActionController = sdk.to_managed_object(args[2])
    end,
    function(retval) return retval end
)

local createEventActionTask = sdk.find_type_definition("app.EventActionTask"):get_method(
    "create(System.String, app.EventActionTask.PriorityType, via.Behavior, via.GameObject, System.Type, System.Object)")
sdk.hook(
    createEventActionTask,
    function(args)
        -- local name = sdk.to_managed_object(args[3]):call("ToString")
        --log.debug(name)
    end,
    function(retval) return retval end
)

sdk.hook(
    sdk.find_type_definition("app.InteractEventAction"):get_method("startInteract(System.String, via.Transform)"),
    function(args)
        local name = sdk.to_managed_object(args[3]):call("ToString")

        if name == "InteractAction_PhoneStart_Short" then
            --[[ args[3] = sdk.create_managed_string("InteractAction_PhoneEnd_Short") -- Immediately end the call
            gameEventActionController:endContinueAction(true)
            gameEventActionController:endEventActionTask() ]]
        end
    end,
    function(retval) return retval end
)

--[[ via.render.Mesh
via.physics.Colliders
app.WwiseContainerApp
app.ObjectLabel
via.motion.Motion
via.wwise.WwiseMotionSequence
via.fsm.Fsm
via.motion.MotionFsm
app.InteractEventAction
via.wwise.WwisePackageList
via.wwise.WwiseMarkerStateList ]]

local task
sdk.hook(
    sdk.find_type_definition("app.EventActionTask"):get_method("onStarted"),
    function(args)
        task = sdk.to_managed_object(args[3])
        local taskName = task:get_field("<name>k__BackingField")
        local owner = task:get_field("<ownerObj>k__BackingField")

        local components = owner:get_Components()

        for i = 1, #components - 1 do
            print(components[i]:ToString())
        end
        print("-----------------------")
    end,
    function(retval)
        return retval
    end
)

sdk.hook(
    sdk.find_type_definition("app.InteractEventAction"):get_method("findEventSetting(System.String)"),
    function(args)
        local name = sdk.to_managed_object(args[3]):call("ToString")
        print(name)
        if name == "InteractAction_PhoneStart_Short" then
            --args[3] = sdk.create_managed_string("InteractAction_PhoneEnd_Short") -- Immediately end the call
            --[[             gameEventActionController:endContinueAction(true)
            gameEventActionController:endEventActionTask()  ]]
        end
    end,
    function(retval) return retval end
)


local door
sdk.hook(
    sdk.find_type_definition("app.fsm.SetDoorState"):get_method("coreAction"),
    function(args)
        door = sdk.to_managed_object(args[2])
    end,
    function(retval)
        print(door:get_field("TargetDoorObject"):get_Name())
        print(door:get_field("State"))
        return retval
    end
)

--[[ sm0360_DoorBoneOldwingH240W100L01B_Dynamic
2
sm0343_DoorBoneOldwingH240W100L01A_Dynamic
2
sm9070_DoorOldwingBugH240W100_WithBugEvent
2 ]]





re.on_draw_ui(function()
    if imgui.tree_node("Phone Call Skipper") then
        imgui.begin_rect()
        --imgui.text(re7.is_in_cutscene and "In Cutscene" or "Not in cutscene")

        if imgui.button("End phone call") then
            if not gameEventActionController then
                log.debug("WTF")
                return
            end

            gameEventActionController:endCompleteAction(true)
        end

        imgui.end_rect(2)
        imgui.tree_pop()
    end
    imgui.text()
end)
