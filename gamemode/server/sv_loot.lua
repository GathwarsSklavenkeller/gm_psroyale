local SPAWNS = {
    Vector( 13826, 12370, -7000 ),
    Vector( 4284, 3704, -7300 ),
    Vector( 11396, -9762, -6150 ),
    Vector( -15172, 3113, -10000),
    Vector( -7361, 13382, -10300 ),
    Vector( -5089, -6334, -9000 ),
    Vector( -9061, 7659, -9600 ),
    Vector( -6502, 4995, -10400 ),
    Vector( 6895, 6235, -9840 ),
    Vector( 10970, 5150, -7340 ),
    Vector( 3424, -9789, -8542 ),
    Vector( -5729, 13381, -10145 ),
    Vector( -6034, 6716, -9800 ),
    Vector( -8091, -265, -10400 ),
    Vector( -10163, 7202, -10049 ),
    Vector( -6321, 6705, -9900 ),
    Vector( -7050, 6450, -9874 ),
    Vector( -10049, 9856, -9906 ),
    Vector( -11500, 9161, -9962 ),
    Vector( -12716, 12400, -9858 ),
    Vector( -46, 6230, -9847 ),
    Vector( 11394, -4829, -7841 ),
    Vector( -2690, -14591, -7800 ),
    Vector( -13978, 11429, -10327 ),
    Vector( 6144, 1601, -7200 ),
    Vector( 5422, 10138, -10400 ),
    Vector( 10534, -1729, -7840 ),
    Vector( -504, -4781, -8900 ),
    Vector( -1381, -13455, -7500 ),
    Vector( -14213, -1970, -9900 ),
    Vector( -13150, -1626, -10200 ),
    Vector( -13533, 13326, -9890 ),
    Vector( -10414, 7888, -9962 ),
    Vector( -13024, 4610, -9901 ),
    Vector( -14684, 9511, -9961 ),
    Vector( 9216, -3789, -7591 ),
    Vector( -7360, -12617, -8907 ),
    Vector( 3921, -10168, -8650 ),
    Vector( -1193, -8116, -9000 ),
    Vector( -9661, -12610, -9345 ),
    Vector( -10445, -1208, -10141 ),
    Vector( -8499, 6945, -10049 ),
    Vector( 7050, 5966, -9869 ),
    Vector( -623, -10169, -7800 ),
    Vector( -13454, -11152, -10300 ),
    Vector( -9925, 76, -10200 ),
    Vector( -7350, 6681, -9549 ),
    Vector( -2642, 3199, -10000 ),
    Vector( -6573, -2714, -10360 ),
    Vector( -6735, 7989, -9904 ),
    Vector( -8541, -12670, -9100 ),
    Vector( -11876, -7013, -10023 ),
    Vector( -9709, 11591, -10039 ),
    Vector( -10144, 7519, -10035 ),
    Vector( -10286, 4115, -9935 ),
    Vector( -8799, 4973, -10337 ),
    Vector( -6839, -13999, -10000 ),
    Vector( -7974, 7366, -10049 ),
    Vector( -12500, 14580, -9901 ),
    Vector( -13004, -11045, -10305 ),
    Vector( -13908, -2369, -9990 ),
    Vector( -12913, 11290, -10049 ),
    Vector( -4507, 8778, -9741 ),
    Vector( -11279, 11514, -10041 ),
    Vector( -5306, 1420, -10200 ),
    Vector( -6940, -7648, -9658 ),
    Vector( 3762, -4119, -8576 ),
    Vector( -8223, -14436, -9860 ),
    Vector( -6711, -2937, -10380 ),  
    Vector(-12714, -15082, -10400),
    Vector(-3603, 9249, -9551),
    Vector( 10310, 15319, -8851 ),
    Vector( 12508, -3991, -6059 ),
    Vector( 347, -295, -8760 ),
    Vector( 14208, -13772, -4785 ),
    Vector( -15324, 2870, -10000 )
}

local AMMO_KIT = "cw_ammo_kit_small"

local ATTACHMENTS = {
    "cw_attpack_ak74_barrels",
    "cw_attpack_ar15_barrels",
    "cw_attpack_ar15_barrels_large",
    "cw_attpack_deagle_barrels",
    "cw_attpack_mp5_barrels",
    "cw_attpack_mr96_barrels",
    "cw_attpack_sights_cqb",
    "cw_attpack_sights_longrange",
    "cw_attpack_sights_midrange",
    "cw_attpack_sights_sniper",
    "cw_attpack_suppressors"
}

local KEVLARS = {
    "kevlar_br"
}


local ATTACHMENT_PERCENT = 25
local AMMO_PERCENT = 70
local FOOD_PERCENT = 50

local MIN_LOOT_PER_SPAWN = 1
local MAX_LOOT_PER_SPAWN = 3
local MAX_KEVLARS = 8

local spawnedEntities = {}

function SpawnKevlar(v, armor)
    local KEVLAR = ents.Create(KEVLARS[math.random(1, #KEVLARS)])
    if (IsValid(KEVLAR)) then
        if armor ~= nil then
            KEVLAR.override_armor = armor
        end

        KEVLAR:SetPos(v)
        KEVLAR:Spawn()
        KEVLAR:Activate()

        print("Spawned kevlar at " .. tostring(v))

        table.insert(spawnedEntities, KEVLAR)
    end
end

function SpawnWeapon(v, weaponModel, spawned)
    local WEAPON = ents.Create(weaponModel)
    if (IsValid(WEAPON)) then
        if spawned ~= nil then
            table.insert(spawned, weaponModel)
        end
        WEAPON:SetPos(v)
        WEAPON:Spawn()

        table.insert(spawnedEntities, WEAPON)
    end
end

function SpawnLoot()
    local WEAPONS = {}
    for k,_ in pairs(WEAPON_MAPPING) do
        table.insert(WEAPONS, k)
    end

    local allKevlars = 0

    for _, v in pairs(SPAWNS) do
        local count = math.random(MIN_LOOT_PER_SPAWN, MAX_LOOT_PER_SPAWN + 1)
        local spawned = {}

        if allKevlars < MAX_KEVLARS and math.random(1, 100) <= 40 then
            allKevlars = allKevlars + 1

            SpawnKevlar(v)
        end

        for i = 1, count do
            local weaponModel = WEAPONS[math.random(1, #WEAPONS)]
            while table.HasValue(spawned, weaponModel) do
                weaponModel = WEAPONS[math.random(1, #WEAPONS)]
            end

            SpawnWeapon(v, weaponModel, spawned)
        end

        if math.random(1, 100) <= AMMO_PERCENT then
            local AMMO = ents.Create(AMMO_KIT)
            if (IsValid(AMMO)) then
                AMMO:SetPos(v)
                AMMO:Spawn()
                AMMO:Activate()

                table.insert(spawnedEntities, AMMO)
            end
        end

        if math.random(1, 100) <= ATTACHMENT_PERCENT then
            local ATTACHMENT = ents.Create(ATTACHMENTS[math.random(1, #ATTACHMENTS)])
            if (IsValid(ATTACHMENT)) then
                ATTACHMENT:SetPos(v)
                ATTACHMENT:Spawn()
                ATTACHMENT:Activate()

                table.insert(spawnedEntities, ATTACHMENT)
            end
        end

        if math.random(1, 100) <= FOOD_PERCENT then
            local FOOD = SpawnFood(v)
            if FOOD ~= nil then
                table.insert(spawnedEntities, FOOD)
            end
        end
    end

    if math.random(1, 100) <= 50 then
        local BOAT = ents.Create("prop_vehicle_airboat") 
        BOAT:SetModel("models/airboat.mdl") 
        BOAT:SetKeyValue("vehiclescript","scripts/vehicles/airboat.txt")
        BOAT:SetPos( Vector( 8698, 8815, -9893 ) )
        BOAT:SetName("AIRBOAT")
        BOAT:Spawn()
        BOAT:Activate()

        table.insert(spawnedEntities, BOAT)
    end
	
    if math.random(1, 100) <= 50 then
        local BOAT_2 = ents.Create("prop_vehicle_airboat") 
        BOAT_2:SetModel("models/airboat.mdl") 
        BOAT_2:SetKeyValue("vehiclescript","scripts/vehicles/airboat.txt")
        BOAT_2:SetPos( Vector( -660, 8153, -10200 ) )
        BOAT_2:SetName("AIRBOAT")
        BOAT_2:Spawn()
        BOAT_2:Activate()

        table.insert(spawnedEntities, BOAT_2)
	end

    if math.random(1, 100) <= 50 then
        local BOAT_3 = ents.Create("prop_vehicle_airboat") 
        BOAT_3:SetModel("models/airboat.mdl") 
        BOAT_3:SetKeyValue("vehiclescript","scripts/vehicles/airboat.txt")
        BOAT_3:SetPos( Vector( -5250, 13492, -10100 ) )
        BOAT_3:SetName("AIRBOAT")
        BOAT_3:Spawn()
        BOAT_3:Activate()

        table.insert(spawnedEntities, BOAT_3)
    end
	
    if math.random(1, 100) <= 50 then
        local BOAT_4 = ents.Create("prop_vehicle_airboat") 
        BOAT_4:SetModel("models/airboat.mdl") 
        BOAT_4:SetKeyValue("vehiclescript","scripts/vehicles/airboat.txt")
        BOAT_4:SetPos( Vector( -12084, -11675, -10100 ) )
        BOAT_4:SetName("AIRBOAT")
        BOAT_4:Spawn()
        BOAT_4:Activate()

        table.insert(spawnedEntities, BOAT_4)
    end
	
    if math.random(1, 100) <= 50 then
        local BOAT_5 = ents.Create("prop_vehicle_airboat") 
        BOAT_5:SetModel("models/airboat.mdl") 
        BOAT_5:SetKeyValue("vehiclescript","scripts/vehicles/airboat.txt")
        BOAT_5:SetPos( Vector( -9881, 6448, -10100 ) )
        BOAT_5:SetName("AIRBOAT")
        BOAT_5:Spawn()
        BOAT_5:Activate()

        table.insert(spawnedEntities, BOAT_5)
    end

    if math.random(1, 100) <= 50 then
        local CAR = ents.Create("prop_vehicle_jeep") 
        CAR:SetModel("models/vehicle.mdl") 
        CAR:SetKeyValue("vehiclescript","scripts/vehicles/jalopy.txt")
        CAR:SetPos( Vector( 6895, 6235, -9872 ) ) 
        CAR:SetName("CAR")
        CAR:Spawn()

        table.insert(spawnedEntities, CAR)
    end

    for k,v in pairs (player.GetAll()) do						
        v:GiveAmmo(30, "5.56x45MM", true)
        v:GiveAmmo(30, "9x19MM", true)
        v:GiveAmmo(5, ".338 Lapua", true)
        v:GiveAmmo(6, ".44 Magnum", true)
        v:GiveAmmo(7, ".50 AE", true)
        v:GiveAmmo(30, "7.62x51MM", true)
        v:GiveAmmo(30, "5.45x39MM", true)
    end
end

function DestroyLoot()
    for _, v in pairs(spawnedEntities) do
        if IsValid(v) then
            v:Remove()
        end
    end

    spawnedEntities = {}
end

hook.Add("EntityFireBullets", "RemoveGrenadesIfEmpty", function(ent, data)
    if ent:GetClass() == "cw_grenade_thrown" then
        if ent:GetOwner():GetAmmoCount(ent:GetPrimaryAmmoType()) <= 0 then
            ent:Remove()
        end
    end
end)