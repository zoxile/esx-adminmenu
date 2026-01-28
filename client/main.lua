local isOpen = false

RegisterCommand('admin', function()
    if isOpen then return end

    ESX.TriggerServerCallback('esx-adminmenu:server:getInitData', function(data)
        if not data then return end

        isOpen = true
        SetNuiFocus(true, true)

        SendNUIMessage({
            action = 'initResource',
            data = data
        })

        SendNUIMessage({
            action = 'openAdmin',
            data = data.serverData
        })
    end)
end)

RegisterNUICallback('close', function(_, cb)
    isOpen = false
    SetNuiFocus(false, false)

    SendNUIMessage({ action = 'closeAdmin' })
    cb(true)
end)
