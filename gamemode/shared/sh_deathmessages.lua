local resetColor = Color(255, 255, 255)
local attackerColor = Color(235, 64, 52)
local victimColor = Color(52, 235, 82)

local SUICIDE_MESSAGES = {
    function(victim, attacker)
        return {resetColor, "Spieler ", victimColor, victim, resetColor, " hat sich aus dem Spiel genommen... buchstäblich!"}
    end,
    function(victim, attacker)
        return {victimColor, victim, resetColor, " hat gerade bewiesen, dass Unfälle tödlich sein können. Tschüss!"}
    end,
    function(victim, attacker)
        return {resetColor, "Selbstzerstörung erfolgreich! ", victimColor, victim, resetColor, " hat sich selbst aus dem Wettbewerb genommen."}
    end,
    function(victim, attacker)
        return {victimColor, victim, resetColor, " hat gerade einen Crashkurs in Schwerkraft absolviert."}
    end,
    function(victim, attacker)
        return {resetColor, "Es war kein Gegner nötig! ", victimColor, victim, resetColor, " hat das Spiel alleine verlassen."}
    end,
    function(victim, attacker)
        return {resetColor, "Und der Darwin-Preis geht an... ", victimColor, victim, resetColor, "!"}
    end,
    function(victim, attacker)
        return {victimColor, victim, resetColor, " hat sich entschieden, eine Solo-Performance hinzulegen. Leider war es seine letzte."}
    end,
    function(victim, attacker)
        return {resetColor, "Einmalige Selbsteliminierung von ", victimColor, victim, resetColor, " – beeindruckend, aber nicht empfehlenswert!"}
    end
}

local VEHICLE_MESSAGES = {
    function(victim, attacker)
        return {attackerColor, attacker, resetColor, " hat ", victimColor, victim, resetColor, " überrollt. Wer hat hier den Führerschein gemacht?"}
    end,
    function(victim, attacker)
        return {victimColor, victim, resetColor, " wurde von ", attackerColor, attacker, resetColor, "'s Fahrkünsten überrascht – und überfahren."}
    end,
    function(victim, attacker)
        return {resetColor, "Ein Crashkurs in Sachen Verkehrssicherheit: ", attackerColor, attacker, resetColor, " > ", victimColor, victim, resetColor, "."}
    end,
    function(victim, attacker)
        return {attackerColor, attacker, resetColor, " hat ", victimColor, victim, resetColor, " eine unvergessliche Fahrt beschert. Direkt ins Aus."}
    end,
    function(victim, attacker)
        return {resetColor, "Vorsicht, ", victimColor, victim, resetColor, "! ", attackerColor, attacker, resetColor, " am Steuer bedeutet Game Over."}
    end
}

local WEAPON_MESSAGES = {
    function(victim, attacker)
        return {victimColor, victim, resetColor, " hat in ", attackerColor, attacker, resetColor, "'s Schießübungen unfreiwillig mitgewirkt."}
    end,
    function(victim, attacker)
        return {attackerColor, attacker, resetColor, " hat ", victimColor, victim, resetColor, " mit einem gezielten Schuss ins digitale Jenseits befördert."}
    end,
    function(victim, attacker)
        return {victimColor, victim, resetColor, " traf auf ", attackerColor, attacker, resetColor, " und dessen treue Waffe. Es war keine Liebe auf den ersten Blick."}
    end,
    function(victim, attacker)
        return {resetColor, "Mit einer Kugel hat ", attackerColor, attacker, resetColor, " ", victimColor, victim, resetColor, "s Abenteuer beendet. Zielsicher!"}
    end,
    function(victim, attacker)
        return {attackerColor, attacker, resetColor, " hat ", victimColor, victim, resetColor, " gezeigt, dass im Kampf nur einer die Oberhand behalten kann."}
    end
}

local function randomMessageIndex(messages)
    return math.random(1, #messages)
end

local function getMessageFunc(set, messageIndex)
    if set == 1 then
        return SUICIDE_MESSAGES[messageIndex]
    elseif set == 2 then
        return VEHICLE_MESSAGES[messageIndex]
    elseif set == 3 then
        return WEAPON_MESSAGES[messageIndex]
    end
    return nil
end

function PrepickDeathMessage(ply, attacker, dmginfo)
    if attacker == nil or ply == attacker or dmginfo == nil or dmginfo.GetInflictor == nil then
        return {randomMessageIndex(SUICIDE_MESSAGES), 1, ply:Nick(), nil}
    end

    local inflictor = dmginfo:GetInflictor()
    if inflictor ~= nil and inflictor:IsVehicle() then
        return {randomMessageIndex(VEHICLE_MESSAGES), 2, ply:Nick(), attacker:GetName()}
    end

    return {randomMessageIndex(WEAPON_MAPPING), 3, ply:Nick(), attacker:GetName()}
end

function FormatDeathMessage(data)
    local create = getMessageFunc(data[2], data[1])
    if create == nil then return nil end

    return create(data[3], data[4])
end