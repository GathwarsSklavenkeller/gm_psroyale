if (SERVER) then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )
end

include('shared.lua')

ENT.Size = 0

function ENT:Initialize()

	self:SetModel("models/player/items/humans/top_hat.mdl")
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_BBOX )
	
	local w=10  //Width
    local l=10  //Length
    local h=40  //Height
 
    //Vectors
    local min=Vector(0-(w/2),0-(l/2),0-(h/2))
    local max=Vector(w/2,l/2,h/2)
 
    //Set bounding box
    self:SetCollisionBounds(min,max)
	
	self:SetCollisionGroup( COLLISION_GROUP_NONE )
	self:SetNetworkedString("Owner", "World")
end

function ENT:WearKevlar( entity )
	local armor = entity.override_armor or 100

	entity.wearing_kevlar = true
	entity:SetArmor(armor)
	entity:EmitSound("npc/combine_soldier/zipline_clip2.wav")
	self:Remove()
end