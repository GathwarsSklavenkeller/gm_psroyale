PSRNet = PSRNet or {}

if SERVER then
    util.AddNetworkString("PSR_PushDeathLog")
    function PSRNet.PushDeathLog(messsage)
        net.Start("PSR_PushDeathLog")
            net.WriteString(util.TableToJSON(messsage))
        net.Broadcast()
    end


    util.AddNetworkString("PSR_PushEndScreen")
    function PSRNet.PushEndScreen(placements)
        local data = util.TableToJSON(placements)

        net.Start("PSR_PushEndScreen")
            net.WriteString(data)
        net.Broadcast()
    end

    util.AddNetworkString("PSR_NotifyZone")
    function PSRNet.NotifyZone(message)
        net.Start("PSR_NotifyZone")
            net.WriteString(message)
        net.Broadcast()
    end
end

if CLIENT then
    function PSRNet.OnPushDeathLog(cb)
        net.Receive("PSR_PushDeathLog", function()
            local message = util.JSONToTable(net.ReadString())
            cb(message)
        end)
    end

    function PSRNet.OnPushEndScreen(cb)
        net.Receive("PSR_PushEndScreen", function()
            local data = net.ReadString()
            local placements = util.JSONToTable(data)
            cb(placements)
        end)
    end

    function PSRNet.OnNotifyZone(cb)
        net.Receive("PSR_NotifyZone", function()
            local message = net.ReadString()
            cb(message)
        end)
    end
end