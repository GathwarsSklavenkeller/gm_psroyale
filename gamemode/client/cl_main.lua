local function createWinningScreen(isWinner, players)
    local screen = vgui.Create("DPanel")
    screen:SetSize(ScrW(), ScrH())
    screen:Center()
    screen:MakePopup()
    screen:SetKeyboardInputEnabled(true)
    screen:SetMouseInputEnabled(true)
    gui.EnableScreenClicker(true)
    screen.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
    end

    local winLoseLabel = vgui.Create("DLabel", screen)
    winLoseLabel:SetFont("DermaLarge")
    winLoseLabel:SetText(isWinner and "GEWONNEN" or "VERLOREN")
    winLoseLabel:SetColor(isWinner and Color(255, 215, 0) or Color(139, 0, 0))
    winLoseLabel:SizeToContents()
    winLoseLabel:SetPos((ScrW() - winLoseLabel:GetWide()) / 2, 100)

    local closeButton = vgui.Create("DButton", screen)
    closeButton:SetText("Schließen")
    closeButton:SetSize(100, 30)
    closeButton:SetPos(ScrW() - 110, ScrH() - 40)
    closeButton.DoClick = function()
        gui.EnableScreenClicker(false)
        screen:SetKeyboardInputEnabled(false)
        screen:SetMouseInputEnabled(false)
        screen:Remove()
    end

    function screen:OnKeyCodePressed(keyCode)
        if keyCode == KEY_ESCAPE then
            gui.EnableScreenClicker(false)
            self:SetKeyboardInputEnabled(false)
            self:SetMouseInputEnabled(false)
            self:Remove()
            return true
        end
    end

    local placementPanel = vgui.Create("DPanel", screen)
    placementPanel:SetSize(400, #players * 30)
    placementPanel:SetPos((ScrW() - placementPanel:GetWide()) / 2, 200)
    placementPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50))
    end

    for i, playerInfo in ipairs(players) do
        local yPos = (i - 1) * 30
        local playerPanel = vgui.Create("DPanel", placementPanel)
        playerPanel:SetSize(400, 30)
        playerPanel:SetPos(0, yPos)
        playerPanel.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50))
        end

        local placementLabel = vgui.Create("DLabel", playerPanel)
        placementLabel:SetFont("DermaDefault")
        placementLabel:SetColor(Color(255, 255, 255))
        placementLabel:SetText(string.format("%d. %s - %d Kills", playerInfo.placement, playerInfo.name, playerInfo.kills))
        placementLabel:SizeToContents()
        placementLabel:SetPos((playerPanel:GetWide() - placementLabel:GetWide()) / 2, (playerPanel:GetTall() - placementLabel:GetTall()) / 2)
    end
end

hook.Add("PostDrawTranslucentRenderables", "DrawBattleRoyaleZone", function()
    if GetGlobalInt("PSR_GameState") ~= RoundState.IN_PROGRESS then
        return
    end

    local showZone = GetGlobalBool("ShowZone", false)
    local zoneCenter = GetGlobalVector("ZoneCenter", nil)
    local zoneRadius = GetGlobalFloat("ZoneRadius", nil)
    local showNextZone = GetGlobalBool("ShowNextZone", false)
    local nextZoneCenter = GetGlobalVector("NextZoneCenter", nil)
    local nextZoneRadius = GetGlobalFloat("NextZoneRadius", nil)

    local zoneColor = Color(0, 0, 255, 100)
    local nextZoneColor = Color(255, 255, 255, 50)
    local segments = 60

    cam.Start3D()
        render.SetColorMaterial()
        
        if zoneCenter and zoneRadius and showZone then
            render.DrawWireframeSphere(zoneCenter, zoneRadius, segments, segments, zoneColor, true)
        end

        if nextZoneCenter and nextZoneRadius and showNextZone then
            render.DrawWireframeSphere(nextZoneCenter, nextZoneRadius, segments, segments, nextZoneColor, true)
        end
    cam.End3D()
end)

hook.Add("HUDShouldDraw", "HideDefaultHUD", function (name)
    local elementsToHide = {
        ["CHudHealth"] = true,
        ["CHudBattery"] = true,
        ["CHudAmmo"] = true,
        ["CHudSecondaryAmmo"] = true
    }

    if elementsToHide[name] then 
        return false 
    end

    return true
end)

hook.Add("HUDDrawTargetID", "HideDefaultHUDID", function ()
    if LocalPlayer():Team() == TeamID.SPECTATOR then
        return true
    end

    return false
end)

hook.Add("HUDPaint", "DrawCustomHUD", function ()
    local ply = LocalPlayer()

    if not IsValid(ply) or not ply:Alive() or ply:Team() ~= TeamID.PLAYER then return end

    local health = ply:Health()
    local armor = ply:Armor()
    local stamina = ply:GetNWFloat("CurrStamina")

    local hudX, hudY = 30, ScrH() - 60
    local hudWidth, hudHeight = 200, 15
    local padding = 5

    draw.RoundedBox(5, hudX, hudY, hudWidth, hudHeight, Color(75, 75, 75, 200))
    draw.RoundedBox(5, hudX, hudY, math.Clamp(health, 0, 100) / 100 * hudWidth, hudHeight, Color(255, 0, 0, 200))

    if armor > 0 then
        draw.RoundedBox(5, hudX, hudY - (hudHeight + padding), hudWidth, hudHeight, Color(75, 75, 75, 200))
        draw.RoundedBox(5, hudX, hudY - (hudHeight + padding), math.Clamp(armor, 0, 100) / 100 * hudWidth, hudHeight, Color(0, 0, 255, 200))
    end

    if stamina < 200 then
        draw.RoundedBox(5, hudX, hudY - ((armor > 0 and 2 or 1) * (hudHeight + padding)), hudWidth, hudHeight, Color(75, 75, 75, 200))
        draw.RoundedBox(5, hudX, hudY - ((armor > 0 and 2 or 1) * (hudHeight + padding)), stamina / 200 * hudWidth, hudHeight, Color(0, 255, 0, 200))
    end

    local wep = ply:GetActiveWeapon()
    if IsValid(wep) and wep:Clip1() ~= -1 then
        local ammoInClip = wep:Clip1()
        local ammoInReserve = ply:GetAmmoCount(wep:GetPrimaryAmmoType())
        local ammoX, ammoY = hudX, hudY - ((armor > 0 and 3 or 2) * (hudHeight + padding)) - (stamina < 200 and (hudHeight + padding) or 0)
        local ammoWidth, ammoHeight = hudWidth, hudHeight

        draw.RoundedBox(5, ammoX, ammoY, ammoWidth, ammoHeight, Color(75, 75, 75, 200))
        local maxClip = wep:GetMaxClip1()
        if maxClip > 0 then
            draw.RoundedBox(5, ammoX, ammoY, math.Clamp(ammoInClip, 0, maxClip) / maxClip * ammoWidth, ammoHeight, Color(255, 255, 0, 200))
        end

        draw.SimpleText(ammoInClip .. " / " .. ammoInReserve, "DermaDefault", ammoX + padding, ammoY + padding, Color(0, 0, 0), TEXT_ALIGN_LEFT)
    end

    local burgerCount = ply:GetNWInt("psr_burgers")
    local hotdogCount = ply:GetNWInt("psr_hotdogs")
    local iconSize = 20
    local iconY = hudY - ((armor > 0 and 3 or 2) * (hudHeight + padding)) - (stamina < 200 and (hudHeight + padding) or 0) - iconSize - padding

    if burgerCount > 0 then
        draw.SimpleText("Burger: " .. burgerCount, "DermaDefault", hudX, iconY, Color(255, 255, 255), TEXT_ALIGN_LEFT)
        iconY = iconY - iconSize - padding
    end

    if hotdogCount > 0 then
        draw.SimpleText("Hotdogs: " .. hotdogCount, "DermaDefault", hudX, iconY, Color(255, 255, 255), TEXT_ALIGN_LEFT)
    end
end)

PSRNet.OnPushDeathLog(function (messageData)
    local message = FormatDeathMessage(messageData)

    chat.AddText(unpack(message))
end)

PSRNet.OnPushEndScreen(function (placements)
    if not placements or #placements <= 0 then return end

    local localPlayer = LocalPlayer()
    local localPlayerPlacement = nil

    for i, placement in ipairs(placements) do
        if placement.name == localPlayer:Nick() then
            localPlayerPlacement = i
            break
        end
    end

    createWinningScreen(localPlayerPlacement == 1, placements)
end)

PSRNet.OnNotifyZone(function (msg)
    chat.AddText(Color(77, 82, 209), msg)
end)