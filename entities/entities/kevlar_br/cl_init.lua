include('shared.lua')

function ENT:Initialize()
self:SetModelScale(1)
end

/*---------------------------------------------------------
Draw
---------------------------------------------------------*/
function ENT:Draw()
	self:DrawModel()
end


/*---------------------------------------------------------
IsTranslucent
---------------------------------------------------------*/
function ENT:IsTranslucent()
	return true
end


