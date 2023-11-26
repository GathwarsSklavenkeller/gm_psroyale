local FORCE = 1000
local FORCE_DIV_WHEN_PARA = 3
local UPPER_VELOCITY_TO_DIE = -600

local function isPosOnGround(pos)
    local tr = util.TraceLine({
        start = pos,
        endpos = pos - Vector(0, 0, 100),
        filter = function(ent) if ent:GetClass() == "prop_physics" then return true end end
    })

    return tr.Hit
end

function CreateDropoutRagdoll(ply)
    local phys = ply:GetPhysicsObject()
    local ragdoll = ents.Create("prop_ragdoll")
    ragdoll:SetPos(ply:GetPos())
    ragdoll:SetModel(ply:GetModel())
    ragdoll:SetAngles(Angle(90, ply:GetAngles().y, 0))
    ragdoll:Spawn()
    ragdoll:Activate()
    ply:SetParent(ragdoll)
    ply:StripWeapons()
    ply:Spectate(OBS_MODE_CHASE)
    ply:SpectateEntity(ragdoll)
    ply.dropout_ragdoll = ragdoll
    ply.activated_para = false
end

function ActivateParachute(ply)
    if not ply.dropout_ragdoll then return end

    ply.activated_para = true
    
    local phys = ply:GetPhysicsObject()
    local cvel = phys:GetVelocity()

    ply.dropout_ragdoll:SetGravity(0.1)
    ply.dropout_ragdoll:GetPhysicsObject():ApplyForceCenter(cvel*500000)
end

function MakeLanding(ply)
    local initial_dead = not ply.activated_para

    if ply.dropout_ragdoll then
        local velocity = ply.dropout_ragdoll:GetVelocity()
        if velocity.z < UPPER_VELOCITY_TO_DIE then
            initial_dead = true
        end

        local pos = ply.dropout_ragdoll:GetPos()
		pos.z = pos.z + 10 
		ply:SetParent()

		ply.dropout_ragdoll:Remove()
		
        ply:Spawn()
        timer.Simple(.05, function() 
            ply:SetPos( pos )
        
            if initial_dead then
                ply:Kill()
            else
                --ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
            end
        end)
    end
    
    if not initial_dead then
        ply:Give('weapon_fists')
	    ply:SetupHands()
    end

    ply.dropout_ragdoll = nil

    return initial_dead
end

hook.Add("Think", "Dropout", function()
	for _, v in pairs(player.GetAll()) do
		if v.dropout_ragdoll then
			if v:KeyDown(IN_FORWARD) then
				local angle = v:EyeAngles():Forward()
				local phys = v.dropout_ragdoll:GetPhysicsObject()
				phys:ApplyForceCenter(Vector(angle.x, angle.y, 0) * (FORCE / (v.activated_para and FORCE_DIV_WHEN_PARA or 1)))
			end

            if v.activated_para then
                if v:KeyDown(IN_BACK) then
                    local angle = v:EyeAngles():Forward()
                    local phys = v.dropout_ragdoll:GetPhysicsObject()
                    phys:ApplyForceCenter(Vector(angle.x, angle.y, 0) * (-FORCE / FORCE_DIV_WHEN_PARA))
                end

                local phys = v.dropout_ragdoll:GetPhysicsObject()
                local vel = phys:GetVelocity()
                phys:ApplyForceCenter(Vector(0, 0, -vel.z * 0.1 * 15))
            end

            if isPosOnGround(v.dropout_ragdoll:GetPos()) then
                MakeLanding(v)
            end
		end
	end
end)

hook.Add("KeyPress", "Dropout_ParaActivate", function(ply, key)
    if key == IN_JUMP and ply.dropout_ragdoll and not ply.activated_para then
        ActivateParachute(ply)
    end
end)