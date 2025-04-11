if true then return end

sdk.hook(
    sdk.find_type_definition("app.WeaponGun"):get_method("get_isLoadNumInfinity"),
    function(args)

    end,
    function(r) return true end
)

sdk.hook(
    sdk.find_type_definition("app.WeaponGun"):get_method("get_isBulletStackNumInfinity"),
    function(args)

    end,
    function(r) return true end
)

--
