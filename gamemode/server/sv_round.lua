include("sv_loot.lua")
include("sv_player_ext.lua")

local SPAWN_PLAYER = {14000, 12000, 10000, 8000, 6000, 4000, 2000, 0, 1500, 3000, 4500, 5000, 7500, 8000, -14000, -12000, -10000, -8000, -6000, -4000, -2000, 0, -1500, -3000, -4500, -5000, -7500, -8000}
local Z_POINT = 10000

Round = {
    CurrentPlacement = -1,
    Scoreboard = {}
}

function Round.Start()
    if GetGlobalInt("PSR_GameState") ~= RoundState.NOT_STARTED then
        return
    end

    local players = player.GetAll()

    Round.Scoreboard = {}
    Round.CurrentPlacement = #players

    SpawnLoot()

    SetGlobalInt("PSR_GameState", RoundState.IN_PROGRESS)

    for _, ply in pairs(players) do
        local spawnPoint = Vector(table.Random(SPAWN_PLAYER), table.Random(SPAWN_PLAYER), Z_POINT)

        UnmakeSpectator(ply)
        ResetFoods(ply)

        Round.Scoreboard[ply:SteamID()] = {
            name = ply:Nick(),
            kills = 0,
            placement = -1
        }

        ply:ChatPrint("Danke fürs Spielen von PietSmiet Royale! Mit <3 entwickelt für euch! - by DasDarki & Pythagorion")
        ply:StripWeapons()
        ply:RemoveAllAmmo()
        ply:SetArmor(0)
        --ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        ply:SetTeam(TeamID.PLAYER)
        ply:Spawn()
        ply:SetPos(spawnPoint)
	
        CreateDropoutRagdoll(ply)
    end

    timer.Simple(15, function ()
        SetZoneSystemEnabled(true)
    end)
end

function Round.End()
    SetZoneSystemEnabled(false)

    SetGlobalInt("PSR_GameState", RoundState.NOT_STARTED)

    for _, ply in pairs(player.GetAll()) do
        ply:StripWeapons()
        ply:RemoveAllAmmo()
        ply:SetArmor(0)

        ResetFoods(ply)
        MakeSpectator(ply)
    end

    DestroyLoot()
end

function Round.CheckForWin()
    local alive = 0
    local alives = {}
    for _, ply in pairs(player.GetAll()) do
        if ply:Team() == TeamID.PLAYER then
            alive = alive + 1
            table.insert(alives, ply)
        end
    end

    if alive <= 1 then
        for _, ply in pairs(alives) do
            Round.Scoreboard[ply:SteamID()] = Round.Scoreboard[ply:SteamID()] or {name = ply:Nick(), kills = 0, placement = -1}
            Round.Scoreboard[ply:SteamID()].placement = 1
            break
        end

        Round.PushEndScreen()
        Round.End()
    end
end

function Round.HandleLeave(ply)
    if ply:Team() == TeamID.PLAYER then
        Round.HandleDeath(ply, nil, nil)
    end
end

function Round.PushDeathLog(message) 
    PSRNet.PushDeathLog(message)
end

function Round.PushEndScreen()
    local placements = {}

    for _, data in pairs(Round.Scoreboard) do
        placements[data.placement] = data
    end

    PSRNet.PushEndScreen(placements)
end

function Round.HandleDeath(ply, attacker, dmg)
    if ply:Team() ~= TeamID.PLAYER then return end

    Round.PushDeathLog(PrepickDeathMessage(ply, attacker, dmg))

    Round.Scoreboard[ply:SteamID()] = Round.Scoreboard[ply:SteamID()] or {name = ply:Nick(), kills = 0, placement = -1}
    Round.Scoreboard[ply:SteamID()].placement = Round.CurrentPlacement
    Round.CurrentPlacement = Round.CurrentPlacement - 1

    if ply ~= attacker and attacker ~= nil and attacker.Team ~= nil and attacker:Team() == TeamID.PLAYER then
        Round.Scoreboard[attacker:SteamID()] = Round.Scoreboard[attacker:SteamID()] or {name = ply:Nick(), kills = 0, placement = -1}
        Round.Scoreboard[attacker:SteamID()].kills = Round.Scoreboard[attacker:SteamID()].kills + 1
    end

    ply:DropInventory()
    ply:DropKevlar()
    ply:StopSound("low_stamina_breath")
    ply:StopSound("player/suit_sprint.wav")
    DropFoods(ply)
    MakeSpectator(ply, attacker)

    Round.CheckForWin()
end

function MakeSpectator(ply, trgt)
    if ply.is_spectator then return end

    ply:KillSilent()
    ply:SetTeam(TeamID.SPECTATOR)
    --ply:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    
    if target == nil then
        ply:Spectate(OBS_MODE_ROAMING)
    else
        ply:Spectate(OBS_MODE_CHASE)
        ply:SpectateEntity(target)
    end

    ply.is_spectator = true
end

function UnmakeSpectator(ply)
    if not ply.is_spectator then return end

    ply:UnSpectate()
    ply:Spectate(OBS_MODE_NONE)

    ply.is_spectator = false
end

function FixSpectators()
    for k, ply in ipairs(player.GetAll()) do
        if ply:Team() == TeamID.SPECTATOR and ply:GetMoveType() < MOVETYPE_NOCLIP then
            ply:Spectate(OBS_MODE_ROAMING)
        end
    end
end 

function GM:PlayerSpawn(ply)
    ExtendPlayer(ply)

    --ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    if GetGlobalInt("PSR_GameState") == RoundState.NOT_STARTED then
        MakeSpectator(ply)
        return
    end

    self.BaseClass:PlayerSpawn(ply)

    ply:SetModel("models/player/monk.mdl")
    --ply:PhysicsInit(SOLID_VPHYSICS)
    ply:SetMoveType(MOVETYPE_WALK)
    ply:SetGravity(0.75)
	ply:SetMaxHealth(100, true) 
    ply:SetHealth(100)
	ply:SetWalkSpeed(MoveSpeed.WALKING)  
	ply:SetRunSpeed(MoveSpeed.RUNNING)
end

function GM:DoPlayerDeath(ply, attacker, dmg)
    self.BaseClass:DoPlayerDeath(ply, attacker, dmg)

    if ply:Team() == TeamID.PLAYER then
        Round.HandleDeath(ply, attacker, dmg)
    end
end

function GM:Think()
    FixSpectators()
end

hook.Add("PlayerDisconnected", "PSR_PlayerDisconnected", function(ply)
    Round.HandleLeave(ply)
end)