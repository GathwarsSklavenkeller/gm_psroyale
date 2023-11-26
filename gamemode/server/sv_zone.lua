-- Anfänglicher Radius der Zone; zu Beginn des Spiels ist die Zone so groß.
local INITIAL_ZONE_RADIUS = 21716.56
local INITIAL_INNER_ZONE_RADIUS = 21701.06

-- Minimaler Radius der Zone; die Zone wird nie kleiner als dieser Wert.
local MINIMUM_ZONE_RADIUS = 100

-- Dauer der Gnadenperiode am Anfang und zwischen den Schrumpfphasen in Sekunden.
local GRACE_PERIOD_DURATION = 180

-- Dauer zwischen den Schrumpfphasen nach der anfänglichen Gnadenperiode in Sekunden.
local BETWEEN_ROUNDS_DURATION = 120

-- Zeitdauer in Sekunden, in der die Zone von ihrem aktuellen Radius auf den nächsten schrumpft.
local SHRINK_DURATION = 60

-- Maximale Distanz, um die sich der Mittelpunkt der Zone zufällig verschieben kann.
local ZONE_CENTER_SHIFT_MAX = 3000

-- Faktor, um den die BETWEEN_ROUNDS_DURATION nach jeder Runde reduziert wird (z.B. 0.8 bedeutet 20% Reduktion).
local BETWEEN_ROUNDS_REDUCTION_RATE = 0.8

-- Anfänglicher Mittelpunkt der Zone; setze dies auf den Mittelpunkt deiner Karte.
local INITIAL_ZONE_CENTER = Vector(-6.26, -1.22, -10500)

-- Anfänglicher Schaden, den Spieler erleiden, wenn er sich außerhalb der Zone befinden.
local INITIAL_DAMAGE = 2.5

-- Multiplikator für den Schaden, den der Schaden prozentual wächst, wenn die Zone schrumpft.
local DAMAGE_MULTIPLIER = 2

-- Zeit in Sekunden zwischen Schadensereignissen
local DAMAGE_INTERVAL = 5

-- Ob der Mittelpunkt der nächsten Zone außerhalb der aktuellen Zone liegen kann.
local CAN_NEW_ZONE_CENTER_BE_OUTSIDE_CURRENT_ZONE = false

local zoneRadius = INITIAL_ZONE_RADIUS
local zoneCenter = INITIAL_ZONE_CENTER
local nextZoneCenter = zoneCenter
local nextZoneRadius = zoneRadius
local zoneActive = false
local gracePeriod = true
local shrinkTimer = 0
local graceTimer = GRACE_PERIOD_DURATION
local currentBetweenRoundsDuration = BETWEEN_ROUNDS_DURATION
local isSystemEnabled = false
local currentDamage = INITIAL_DAMAGE
local damageTimer = DAMAGE_INTERVAL
local isInitialShrink = true

local startZoneRadius = nil
local startZoneCenter = nil

local function randomZoneCenterShift(center, maxShift)
    local shiftX = math.random(-maxShift, maxShift)
    local shiftY = math.random(-maxShift, maxShift)
    return Vector(center.x + shiftX, center.y + shiftY, center.z)
end

local function findRandomZoneCenterShiftWithinCurrentZone()
    local shift = randomZoneCenterShift(zoneCenter, ZONE_CENTER_SHIFT_MAX)
    while not CAN_NEW_ZONE_CENTER_BE_OUTSIDE_CURRENT_ZONE and shift:Distance(zoneCenter) > zoneRadius do
        shift = randomZoneCenterShift(zoneCenter, ZONE_CENTER_SHIFT_MAX)
    end
    return shift
end

local function calculateNewZone()
    local rad = zoneRadius
    if isInitialShrink then
        rad = INITIAL_INNER_ZONE_RADIUS
        isInitialShrink = false
    end

    nextZoneRadius = math.max(rad * 0.75, MINIMUM_ZONE_RADIUS)
    nextZoneCenter = findRandomZoneCenterShiftWithinCurrentZone()
    currentDamage = currentDamage * DAMAGE_MULTIPLIER

    SetGlobalVector("NextZoneCenter", nextZoneCenter)
    SetGlobalFloat("NextZoneRadius", nextZoneRadius)
end

local function isPlayerInZone(ply)
    return ply:GetPos():Distance(zoneCenter) <= zoneRadius
end

local function applyZoneDamage()
    for _, ply in ipairs(player.GetAll()) do
        if not isPlayerInZone(ply) and ply:Alive() then
            ply:TakeDamage(currentDamage)
        end
    end
end

local function updateZone()
    if gracePeriod then
        if graceTimer > 0 then
            graceTimer = graceTimer - 1

            if graceTimer <= 10 and graceTimer > 0 then
                PSRNet.NotifyZone("Die Zone fängt in " .. tostring(math.floor(graceTimer)) .. " Sekunden an zu schrumpfen!")
            end
        else
            gracePeriod = false
            zoneActive = true
            shrinkTimer = SHRINK_DURATION
            startZoneRadius = zoneRadius
            startZoneCenter = zoneCenter
            PSRNet.NotifyZone("Die Zone bewegt sich!")
        end
    elseif zoneActive then
        if shrinkTimer > 0 then
            local lerpFactor = 1 - (shrinkTimer / SHRINK_DURATION)
            zoneRadius = Lerp(lerpFactor, startZoneRadius, nextZoneRadius)
            zoneCenter = LerpVector(lerpFactor, startZoneCenter, nextZoneCenter)
            shrinkTimer = shrinkTimer - 1
        else
            zoneActive = false
            gracePeriod = true
            graceTimer = currentBetweenRoundsDuration
            currentBetweenRoundsDuration = currentBetweenRoundsDuration * BETWEEN_ROUNDS_REDUCTION_RATE
            zoneRadius = nextZoneRadius
            zoneCenter = nextZoneCenter
            calculateNewZone()

            PSRNet.NotifyZone("Die Zone fängt in " .. tostring(math.floor(graceTimer)) .. " Sekunden an zu schrumpfen!")
        end
    end

    SetGlobalVector("ZoneCenter", zoneCenter)
    SetGlobalFloat("ZoneRadius", zoneRadius)

    if damageTimer > 0 then
        damageTimer = damageTimer - 1
    else
        applyZoneDamage()
        damageTimer = DAMAGE_INTERVAL
    end

    --print("Grace: " .. tostring(gracePeriod) .. "; Timer: " .. tostring(graceTimer) .. " | Shrinking: " .. tostring(zoneActive) .. "; Timer: " .. tostring(shrinkTimer) .. " | Radius: " .. tostring(zoneRadius) .. " | Center: " .. tostring(zoneCenter))
end

local function resetZoneSystem()
    zoneRadius = INITIAL_ZONE_RADIUS
    zoneCenter = INITIAL_ZONE_CENTER
    nextZoneCenter = zoneCenter
    nextZoneRadius = zoneRadius
    zoneActive = false
    gracePeriod = true
    shrinkTimer = 0
    graceTimer = GRACE_PERIOD_DURATION
    currentBetweenRoundsDuration = BETWEEN_ROUNDS_DURATION
    isSystemEnabled = false
    currentDamage = INITIAL_DAMAGE
    damageTimer = DAMAGE_INTERVAL
    lastCalled = nil
    isInitialShrink = true
end

function ShortenNextShrink()
    if gracePeriod then
        graceTimer = 0
    else
        shrinkTimer = 0
    end
end

function SetZoneSystemEnabled(enabled)
    isSystemEnabled = enabled

    if enabled then
        SetGlobalVector("ZoneCenter", zoneCenter)
        SetGlobalFloat("ZoneRadius", zoneRadius)
        SetGlobalVector("NextZoneCenter", nextZoneCenter)
        SetGlobalFloat("NextZoneRadius", nextZoneRadius)

        timer.Create("ZoneSystem", 1, 0, updateZone)

        calculateNewZone()
    else
        timer.Remove("ZoneSystem")

        SetGlobalVector("ZoneCenter", nil)
        SetGlobalFloat("ZoneRadius", nil)
        SetGlobalVector("NextZoneCenter", nil)
        SetGlobalFloat("NextZoneRadius", nil)

        timer.Simple(.5, function()
            resetZoneSystem()
        end)
    end
end