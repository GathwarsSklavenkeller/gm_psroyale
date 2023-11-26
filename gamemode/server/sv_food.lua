local BURGER = {model = "food_burger", cat = "burgers", activate = function (ply)
    local health = ply:Health()
    health = health + 75
    if health > 100 then
        health = 100
    end

    ply:SetHealth(health)
end}

local HOTDOG = {model = "food_hotdog", cat = "hotdogs", activate = function (ply)
    RefillStamina(ply)
end}

local function spawnFoodInternally(food, pos)
    local FOOD = ents.Create(food.model)
    if IsValid(FOOD) then
        FOOD.isfood = true
        FOOD.food = food
        FOOD:SetPos(pos)
        FOOD:Spawn()
        FOOD:Activate()

        print("Spawned food " .. food.model .. " at " .. tostring(pos))

        return FOOD
    end

    return nil
end

local function updateFoodStatus(ply)
    local burgers = #(ply.burgers or {})
    local hotdogs = #(ply.hotdogs or {})

    ply:SetNWInt("psr_burgers", burgers)
    ply:SetNWInt("psr_hotdogs", hotdogs)
end

function SpawnFood(pos)
    local percent = math.random(1, 100)

    if percent <= 50 then
        return spawnFoodInternally(BURGER, pos)
    else
        return spawnFoodInternally(HOTDOG, pos)
    end
end

function PickupFood(ent, ply)
    if ent.isfood then
        ply[ent.food.cat] = ply[ent.food.cat] or {}
        if #ply[ent.food.cat] >= 2 then
            return
        end

        table.insert(ply[ent.food.cat], ent.food)
        ent:Remove()

        updateFoodStatus(ply)
    end
end

function ActivateFood(ply, cat)
    if ply[cat] and #ply[cat] > 0 then
        local food = ply[cat][1]
        table.remove(ply[cat], 1)
        food.activate(ply)

        updateFoodStatus(ply)
    end
end

function DropFoods(ply)
    for k, v in pairs(ply.burgers or {}) do
        spawnFoodInternally(v, ply:GetPos() + Vector(0, 0, 10))
    end

    for k, v in pairs(ply.hotdogs or {}) do
        spawnFoodInternally(v, ply:GetPos() + Vector(0, 0, 10))
    end

    ResetFoods(ply)
end

function ResetFoods(ply)
    ply.burgers = {}
    ply.hotdogs = {}

    updateFoodStatus(ply)
end