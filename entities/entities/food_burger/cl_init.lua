include('shared.lua')

function ENT:Initialize()
	self:SetModelScale(1)
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:IsTranslucent()
	return true
end


