local spectating = false

RegisterNetEvent('esx-adminmenu:client:startSpectate', function(targetId)
    local targetPlayer = GetPlayerFromServerId(targetId)
    if targetPlayer == -1 then return end

    spectating = true
    NetworkSetInSpectatorMode(true, GetPlayerPed(targetPlayer))
end)

RegisterNetEvent('esx-adminmenu:client:stopSpectate', function()
    if not spectating then return end
    local ped = GetPlayerPed(-1)
    NetworkSetInSpectatorMode(true, ped)
    NetworkSetInSpectatorMode(false, ped)

    spectating = false
end)
