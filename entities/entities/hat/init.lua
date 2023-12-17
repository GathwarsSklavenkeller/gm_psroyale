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
end

function ENT:WearKevlar( entity )
	local armor = entity.override_armor or 100

	entity.wearing_kevlar = true
	entity:SetArmor(armor)
	entity:EmitSound("npc/combine_soldier/zipline_clip2.wav")
	self:Remove()
end