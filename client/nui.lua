AdminOpen = false

local function toggleNUI(bool)
    SetNuiFocus(bool, bool)
    AdminOpen = bool
end

RegisterNUICallback('goto', function(data, cb)
    ESX.TriggerServerCallback('esx-adminmenu:server:goto', function(res, data)
        if res.err then
            print('[esx-adminmenu]', data.err)
        end
        
        cb({ success = res.success, playerOnline = res.playerOnline })
    end) 
end)

RegisterNUICallback('bring', function(data, cb)
    ESX.TriggerServerCallback('esx-adminmenu:server:bring', function(res, data)
        if res.err then
            print('[esx-adminmenu]', data.err)
        end
        
        cb({ success = res.success, playerOnline = res.playerOnline })
    end) 
end)

RegisterNUICallback('spectate', function(data, cb)
    ESX.TriggerServerCallback('esx-adminmenu:server:spectate', function(res, data)
        if res.err then
            print('[esx-adminmenu]', data.err)
        end
        if not res or not res.isAdmin then
            cb({ success = res.success, playerOnline = res.playerOnline })
            return
        end
        Spectate(data.id)
        cb({ success = true, playerOnline = res.playerOnline })
    end)
end)

RegisterNUICallback('spectate:stop', function(_, cb)
    ESX.TriggerServerCallback('esx-adminmenu:server:spectate:stop', function(res, data)
        if res.err then
            print('[esx-adminmenu]', data.err)
        end
        if not res then
            cb({ success = res.success, playerOnline = res.playerOnline })
            return
        end
        StopSpectate()
        cb({ success = true, playerOnline = res.playerOnline })
    end)
end)

RegisterNUICallback('kick', function(data, cb)
    ESX.TriggerServerCallback('esx-adminmenu:server:kick', function(res, data)
        if res.err then
            print('[esx-adminmenu]', data.err)
        end
        
        cb({ success = res.success, playerOnline = res.playerOnline })
    end) 
end)

RegisterNUICallback('ban', function(data, cb)
    ESX.TriggerServerCallback('esx-adminmenu:server:ban', function(res, data)
        if res.err then
            print('[esx-adminmenu]', data.err)
        end
        
        cb({ success = res.success, playerOnline = res.playerOnline })
    end) 
end)

RegisterNUICallback('releaseFocus', function(data, cb)
    toggleNUI(false)
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

