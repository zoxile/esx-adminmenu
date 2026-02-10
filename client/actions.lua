local spectating = false

function Spectate(targetId)
    if spectating then
        StopSpectate()
        Wait(1000)
    end
    local targetPlayer = GetPlayerFromServerId(targetId)
    if targetPlayer == -1 then return end

    spectating = true
    NetworkSetInSpectatorMode(true, GetPlayerPed(targetPlayer))
end

function StopSpectate()
    if not spectating then return end
    local ped = GetPlayerPed(-1)
    NetworkSetInSpectatorMode(true, ped)
    NetworkSetInSpectatorMode(false, ped)

    spectating = false
end
