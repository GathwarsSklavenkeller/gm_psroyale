local MAX_STAMINA = 200
local STAMINA_REGEN_STANDING = 0.4  -- Schnellere Regeneration im Stehen
local STAMINA_REGEN_WALKING = 0.2   -- Langsamere Regeneration beim Gehen
local STAMINA_DRAIN_SPRINTING = 0.25 -- Weniger Ausdauerverlust beim Sprinten
local STAMINA_DRAIN_SWIMMING = 0.2  -- Weniger Ausdauerverlust beim Schwimmen
local VELO_FOR_REGEN = MoveSpeed.WALKING -- Geschwindigkeitsgrenze für Regeneration

function RefillStamina(ply)
    ply:SetNWFloat("CurrStamina", MAX_STAMINA)
end

sound.Add({ 
    name = "low_stamina_breath",
    channel = CHAN_STATIC,
    volume = 1,
    level = 60,
    pitch = { 80, 120 },
    sound = "player/breathe1.wav"
})

hook.Add("PlayerTick", "DoStamina", function(ply)
    if not ply:Alive() then return end
    if ply.dropout_ragdoll ~= nil then return end

    local velocityLength = ply:GetVelocity():Length()
    local isStanding = velocityLength < 5  -- Fast keine Bewegung, steht wahrscheinlich
    local canRegen = velocityLength < VELO_FOR_REGEN -- Geringe Bewegung, geht wahrscheinlich

    -- Regeneration der Ausdauer
    if ply:OnGround() then
        local regenRate = isStanding and STAMINA_REGEN_STANDING or (canRegen and STAMINA_REGEN_WALKING or 0)
        ply:SetNWFloat("CurrStamina", math.Clamp(ply:GetNWFloat("CurrStamina", ply:GetNWInt("staminacap", MAX_STAMINA)) + regenRate, 0, MAX_STAMINA))
    end

    -- Ausdauerverlust
    if ply:IsSprinting() and ply:GetRunSpeed() == MoveSpeed.RUNNING and ply:GetVelocity():Length() >= MoveSpeed.WALKING and ply:OnGround() then
        ply:SetNWFloat("CurrStamina", math.Clamp(ply:GetNWFloat("CurrStamina") - STAMINA_DRAIN_SPRINTING, 0, MAX_STAMINA))
    elseif ply:WaterLevel() >= 2 then
        local drainRate = ply:IsSprinting() and STAMINA_DRAIN_SWIMMING * 1.5 or STAMINA_DRAIN_SWIMMING
        ply:SetNWFloat("CurrStamina", math.Clamp(ply:GetNWFloat("CurrStamina") - drainRate, 0, MAX_STAMINA))
    end

    -- Erschöpfung und Bewegungseinschränkungen
    if ply:GetNWFloat("CurrStamina") <= 25 then
        if not ply:IsSprinting() or ply:GetNWFloat("CurrStamina") == 0 then
            ply:SetWalkSpeed(MoveSpeed.WALKING * 0.625)
            ply:SetRunSpeed(MoveSpeed.WALKING * 0.625)
        end
        ply:SetJumpPower(MoveSpeed.JUMPING / 2)
        if not ply.soundisplaying then
            ply:EmitSound("low_stamina_breath")
            ply.soundisplaying = true
        end
    else
        ply:SetWalkSpeed(MoveSpeed.WALKING)
        ply:SetRunSpeed(MoveSpeed.RUNNING)
        ply:SetJumpPower(MoveSpeed.JUMPING)
        if ply.soundisplaying then
            ply:StopSound("low_stamina_breath")
            ply.soundisplaying = false
            ply:EmitSound("player/suit_sprint.wav")
        end
    end
end)

-- Stamina for Under Water: --
local MAX_AIR_TIME = 10     -- Maximale Zeit in Sekunden, die man unter Wasser Luft anhalten kann
local START_RECOVER_TIME = 5 -- Zeit in Sekunden, die benötigt wird, um mit der Erholung zu beginnen
local FULL_RECOVER_TIME = 5  -- Zeit in Sekunden, die benötigt wird, um nach Beginn der Erholung vollständig Luft zu holen
local DAMAGE_INTERVAL = 1   -- Zeitintervall in Sekunden, in dem Schaden verursacht wird, wenn die Luft ausgeht
local UNDERWATER_DAMAGE = 10 -- Schaden pro Schadensintervall

timer.Create("UnderWater_Air", 1, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        if not ply:IsValid() or not ply:Alive() or ply:Team() ~= TeamID.PLAYER then return end

        local underwaterTime = ply:GetNWFloat("UnderwaterTime", 0)
        local startRecoverTime = ply:GetNWFloat("UW_StartRecoverTime", START_RECOVER_TIME)
        local fullRecoverTime = ply:GetNWFloat("UW_FullRecoverTime", FULL_RECOVER_TIME)

        if ply:WaterLevel() >= 3 then
            if underwaterTime < MAX_AIR_TIME then
                ply:SetNWFloat("UnderwaterTime", underwaterTime + 1)
            else
                if underwaterTime % DAMAGE_INTERVAL == 0 then
                    ply:TakeDamage(UNDERWATER_DAMAGE)
                end
                ply:SetNWFloat("UnderwaterTime", underwaterTime + 1)
            end
            ply:SetNWFloat("UW_StartRecoverTime", START_RECOVER_TIME)
            ply:SetNWFloat("UW_FullRecoverTime", FULL_RECOVER_TIME)
        else
            if startRecoverTime > 0 then
                ply:SetNWFloat("UW_StartRecoverTime", startRecoverTime - 1)
            elseif fullRecoverTime > 0 then
                ply:SetNWFloat("UW_FullRecoverTime", fullRecoverTime - 1)
            else
                ply:SetNWFloat("UW_UnderwaterTime", 0)
            end
        end
    end
end)