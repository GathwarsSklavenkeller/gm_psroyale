function ExtendPlayer(ply)
    if ply.is_extended then return end

    ply.is_extended = true

    function ply:GetWeaponsOfKind(wantedKind)
        local weps = self:GetWeapons()
        local longWeps = {}

        for _, wep in pairs(weps) do
            local class = wep:GetClass()
            local kind = WEAPON_MAPPING[class]

            if kind == wantedKind then
                table.insert(longWeps, wep)
            end
        end

        return longWeps
    end

    function ply:GetLongWeapons()
        return self:GetWeaponsOfKind("LONG_WEAPONS")
    end

    function ply:GetShortWeapons()
        return self:GetWeaponsOfKind("SHORT_WEAPONS")
    end

    function ply:GetGrenades()
        return self:GetWeaponsOfKind("GRENADES")
    end

    function ply:DropInventory()
        local weps = self:GetWeapons()

        for _, wep in pairs(weps) do
            local class = wep:GetClass()
            local kind = WEAPON_MAPPING[class]

            if kind ~= nil then
                ply:DropWeapon(wep)
            end
        end

        self:StripWeapons()
    end

    function ply:DropKevlar()
        if ply.wearing_kevlar == false then
            return
        end

        ply.wearing_kevlar = false

        local armor = ply:Armor()
        ply:SetArmor(0)

        SpawnKevlar(ply:GetPos(), armor)
    end
end