local spectatedPlayers = {}
local spectatorsListRefs = {}

local function getPlayersTableIndexOf(players, entIndex)
    if entIndex == -1 then return -1 end

    for i, ply in ipairs(players) do
        if ply:EntIndex() == entIndex then
            return i
        end
    end

    return -1
end

local function spectatePlayer(spectator, ply)
    spectator:SetNWInt("SpectatingPlayerIndex", ply:EntIndex())
    spectator:Spectate(OBS_MODE_CHASE)
    spectator:SpectateEntity(ply)
    spectator:SetObserverMode(OBS_MODE_IN_EYE)

    if not spectatedPlayers[ply] then
        spectatedPlayers[ply] = {}
    end

    table.insert(spectatedPlayers[ply], spectator)

    spectatorsListRefs[spectator] = ply
end

local function unspectatePlayer(ply)
    ply:Spectate(OBS_MODE_ROAMING)
    ply:SpectateEntity(nil)

    spectatorsListRefs[ply] = nil
end

local function getSpectatablePlayers()
    local players = {}

    for _, ply in ipairs(player.GetAll()) do
        if ply:Team() ~= TeamID.SPECTATOR and ply:Alive() then
            table.insert(players, ply)
        end
    end

    return players
end

local function determineNextPlayer(ply, players, dir)
    local spectatingPlayerIndex = ply:GetNWInt("SpectatingPlayerIndex", -1)

    if spectatingPlayerIndex ~= -1 then
        unspectatePlayer(ply)
    end

    local realIndex = getPlayersTableIndexOf(players, spectatingPlayerIndex)
    if realIndex == -1 then
        realIndex = 1
    end

    local nextIndex = realIndex + dir
    if nextIndex > #players then
        nextIndex = 1
    elseif nextIndex < 1 then
        nextIndex = #players
    end

    return players[nextIndex]
end

local function spectateNextPlayer(ply)
    local players = getSpectatablePlayers()
    if #players == 0 then return end

    local nextPlayer = determineNextPlayer(ply, players, 1)

    spectatePlayer(ply, nextPlayer)
end

local function spectatePreviousPlayer(ply)
    local players = getSpectatablePlayers()
    if #players == 0 then return end

    local nextPlayer = determineNextPlayer(ply, players, -1)

    spectatePlayer(ply, nextPlayer)
end

hook.Add("PlayerButtonDown", "Spectator_Controls", function (ply, button)
    if ply:Team() ~= TeamID.SPECTATOR then return end

    if button == MOUSE_LEFT then
        spectatePreviousPlayer(ply)
    elseif button == MOUSE_RIGHT then
        spectateNextPlayer(ply)
    elseif button == KEY_ESCAPE then
        unspectatePlayer(ply)
    end
end)

hook.Add("PlayerDeath", "Spectator_Death", function (ply)
    if spectatedPlayers[ply] then
        local spectators = spectatedPlayers[ply]
        for _, spectator in ipairs(spectators) do
            spectator:SetNWInt("SpectatingPlayerIndex", -1)
            
            unspectatePlayer(spectator)
        end

        spectatedPlayers[ply] = nil
    end
end)