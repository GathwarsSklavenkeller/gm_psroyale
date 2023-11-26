local LONG_WEAPONS_PER_PLAYER = 2
local SHORT_WEAPONS_PER_PLAYER = 1
local GRENADES_PER_PLAYER = 3

local function getLimitForKind(kind)
    if kind == "LONG_WEAPONS" then
        return LONG_WEAPONS_PER_PLAYER
    elseif kind == "SHORT_WEAPONS" then
        return SHORT_WEAPONS_PER_PLAYER
    elseif kind == "GRENADES" then
        return GRENADES_PER_PLAYER
    end

    return -1
end

function CanPickUpWeaponKind(ply, wepKind)
    local kinds = ply:GetWeaponsOfKind(wepKind)
    local amount = #kinds
    local limit = getLimitForKind(wepKind)

    if limit == -1 then return true end

    if amount >= limit then
        return false
    end

    return true
end

hook.Add("PlayerCanPickupWeapon", "Weapon_Limit", function (ply, wep)
    if wep.pickup_ply ~= nil then 
        if wep.pickup_ply == ply then
            wep.pickup_ply = nil
            return true
        end

        return false
    end

    local wepKind = WEAPON_MAPPING[wep:GetClass()]
    if wepKind == nil then return true end

    return false
end)

hook.Add("PlayerCanPickupItem", "Weapon_Limit", function (ply, item)
    if item.pickup_ply ~= nil then 
        if item.pickup_ply == ply then
            item.pickup_ply = nil
            return true
        end

        return false
    end

    local wepKind = WEAPON_MAPPING[item:GetClass()]
    if wepKind == nil then return true end

    return false
end)

hook.Add("Think", "Weapon_System", function ()
    for _, ply in pairs(player.GetAll()) do

        local wep = ply:GetActiveWeapon()
        if wep ~= nil and IsValid(wep) then
            local class = wep:GetClass()
            if class ~= nil then
                local wepKind = WEAPON_MAPPING[class]

                -- Component: When grenade is empty, remove it
                if wepKind == "GRENADES" then
                    if wep:Clip1() == 0 then
                        ply:StripWeapon(wep:GetClass())
                    end
                end
            end
        end
    end
end)

hook.Add("KeyPress", "Weapon_ManualPickUp", function (ply, key)
    if ply:Team() ~= TeamID.PLAYER then return end

    if key == IN_USE then
        local ent = ply:GetEyeTrace().Entity
        if ent ~= nil and IsValid(ent) then
            local wepKind = WEAPON_MAPPING[ent:GetClass()]
            if wepKind ~= nil then
                if CanPickUpWeaponKind(ply, wepKind) then
                    ent.pickingup_ply = ply
                    ply:PickupWeapon(ent)
                end
            elseif ent:GetClass() == "kevlar_br" then
                ent:WearKevlar(ply)
            elseif ent.isfood == true then
                PickupFood(ent, ply)
            end
        end
    end
end)

hook.Add("PlayerButtonDown", "Weapon_Drop", function (ply, button)
    if button == KEY_G then
        local wep = ply:GetActiveWeapon()
        if wep ~= nil and IsValid(wep) then
            local class = wep:GetClass()
            if class ~= nil then
                local wepKind = WEAPON_MAPPING[class]
                if wepKind ~= nil then
                    ply:DropWeapon(wep)
                end
            end
        end
    elseif button == KEY_B then
        ActivateFood(ply, "burgers")
    elseif button == KEY_V then
        ActivateFood(ply, "hotdogs")
    end
end)