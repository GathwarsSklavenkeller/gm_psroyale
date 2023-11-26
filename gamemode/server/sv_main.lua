util.AddNetworkString("psr_wepsys_dropweapon")

include("sv_zone.lua")
include("sv_round.lua")
include("sv_dropout.lua")
include("sv_stamina.lua")
include("sv_weapon.lua")
include("sv_food.lua")

concommand.Add("psr_start", function(ply, cmd, args)
    print("Starting round...")
    Round.Start()
end)

concommand.Add("psr_end", function(ply, cmd, args)
    print("Ending round...")
    Round.End()
end)

concommand.Add("tppos", function(ply, cmd, args)
    ply:SetPos(Vector(args[1], args[2], args[3]))
end)

concommand.Add("pos", function(ply, cmd, args)
    local pos = ply:GetPos()
    print(pos.x, pos.y, pos.z)
end)

function GM:EntityTakeDamage(target, dmg)
    print(target:GetName(), dmg:GetDamage(), dmg:GetAttacker():GetName())
end

function GM:PlayerCanSeePlayersChat(text, teamOnly, listener, speaker)
    if speaker:Team() == TeamID.PLAYER then
        return false
    end

    return true
end

function GM:PlayerFootstep(ply, pos, foot, sound, volume, filter)
    if !ply:Alive() or ply:Crouching() then
        return false
    end

    return true
end

function GM:GetFallDamage( ply, speed )
	return math.max( 0, math.ceil( 0.2418*speed - 141.75 ) )
end