local enabled = true
if not enabled then return end

--local re7 = require("utility/RE7")

--[[ sdk.hook(
    sdk.find_type_definition("app.InteractManager"):get_method("interactStart"), --app.InteractEventAction.startInteract(System.String)
    function(args)
        local interactObj = sdk.to_managed_object(args[3]):get_field("_InteractType")
        log.debug(interactObj)
    end,
    function(retval) return retval end
) ]]

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

sdk.hook(
    sdk.find_type_definition("app.GameManager"):get_method(
        "setFsmGlobalBoolValueId(System.Guid, System.Boolean, via.userdata.UserVariablesHub)"
    ),
    function(args)
        local m_obj = sdk.to_managed_object(args[3])
        local guidStr = string.format("%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x", m_obj.mData1, m_obj.mData2,
            m_obj.mData3, m_obj.mData4_0, m_obj.mData4_1, m_obj.mData4_2, m_obj.mData4_3, m_obj.mData4_4, m_obj.mData4_5,
            m_obj.mData4_6, m_obj.mData4_7)
        print(guidStr)
    end,
    function(retval)
        return retval
    end
)






local task
sdk.hook(
    sdk.find_type_definition("app.EventActionTask"):get_method("onStarted"),
    function(args)
        task = sdk.to_managed_object(args[3])
        local taskName = task:get_field("<name>k__BackingField")
        --print(taskName)

        if taskName == "InteractAction_PhoneStart_Short" then
            --args[3] = sdk.create_managed_string("InteractAction_PhoneEnd_Short")
            task:set_field("<name>k__BackingField", "InteractAction_PhoneEnd_Short")
        end
    end,
    function(retval)
        return retval
    end
)


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
