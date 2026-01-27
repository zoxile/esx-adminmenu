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

        CreateThread(function()
            while isOpen do
                Wait(Config.PlayerUpdateInterval)

                ESX.TriggerServerCallback('esx-adminmenu:server:getInitData', function(update)
                    if update then
                        SendNUIMessage({
                            action = 'updatePlayers',
                            data = update.serverData
                        })
                    end
                end)
            end
        end)
    end)
end)

RegisterNUICallback('close', function(_, cb)
    isOpen = false
    SetNuiFocus(false, false)

    SendNUIMessage({ action = 'closeAdmin' })
    cb(true)
end)
