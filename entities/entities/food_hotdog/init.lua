if (SERVER) then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )
end

include('shared.lua')

ENT.Size = 0

function ENT:Initialize()
	self:SetModel("models/food/hotdog.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
    end

    self:SetCollisionGroup(COLLISION_GROUP_NONE)
    self:SetNetworkedString("Owner", "World")
end