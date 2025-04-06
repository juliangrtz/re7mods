--[[ sdk.hook(
    sdk.find_type_definition("app.CardGameMaster"):get_method("calcSum"),
    function(args)

    end,
    function(retval)
        return 21
    end
)
 ]]