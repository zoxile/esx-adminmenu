AdminOpen = false

local function toggleNUI(bool)
    SetNuiFocus(bool, bool)
    AdminOpen = bool
end

RegisterNUICallback('goto', function(data, cb)
    TriggerServerEvent('esx-adminmenu:server:goto', data)
    cb({ success = true })
end)

RegisterNUICallback('bring', function(data, cb)
    TriggerServerEvent('esx-adminmenu:server:bring', data)
    cb({ success = true })
end)

RegisterNUICallback('spectate', function(data, cb)
    ESX.TriggerServerCallback('esx-adminmenu:server:spectate', function(res, data)
        if data.err then
            print('[esx-adminmenu]', data.err)
        end
        if not res or not res.isAdmin then
            cb({ success = false })
            return
        end
        Spectate(data.id)
        cb({ success = true })
    end)
end)

RegisterNUICallback('spectate:stop', function(_, cb)
    ESX.TriggerServerCallback('esx-adminmenu:server:spectate:stop', function(res, data)
        if data.err then
            print('[esx-adminmenu]', data.err)
        end
        if not res then
            cb({ success = false })
            return
        end
        StopSpectate()
        cb({ success = true })
    end)
end)

RegisterNUICallback('kick', function(data, cb)
    TriggerServerEvent('esx-adminmenu:server:kick', data)
    cb({ success = true })
end)

RegisterNUICallback('ban', function(data, cb)
    TriggerServerEvent('esx-adminmenu:server:ban', data)
    cb({ success = true })
end)

RegisterNetEvent('esx-adminmenu:client:copyToClipboard', function(text)
    SendNUIMessage({
        action = 'copyToClipboard',
        data = text
    })
end)

RegisterNetEvent('esx-adminmenu:client:open', function(data)
    toggleNUI(true)
    SendNUIMessage({
        action = 'openAdmin',
        data = data
    })
end)

RegisterNUICallback('releaseFocus', function(data, cb)
    toggleNUI(false)
    cb({ success = true })
end)