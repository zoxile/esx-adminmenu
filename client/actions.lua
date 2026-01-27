RegisterNUICallback('goto', function(data, cb)
    TriggerServerEvent('esx-adminmenu:server:goto', data)
    cb({ success = true })
end)

RegisterNUICallback('bring', function(data, cb)
    TriggerServerEvent('esx-adminmenu:server:bring', data)
    cb({ success = true })
end)

RegisterNUICallback('spectate', function(data, cb)
    TriggerServerEvent('esx-adminmenu:server:spectate', data)
    cb({ success = true })
end)

RegisterNUICallback('spectate:stop', function(_, cb)
    TriggerServerEvent('esx-adminmenu:server:spectate:stop')
    cb({ success = true })
end)

RegisterNUICallback('kick', function(data, cb)
    TriggerServerEvent('esx-adminmenu:server:kick', data)
    cb({ success = true })
end)

RegisterNUICallback('ban', function(data, cb)
    TriggerServerEvent('esx-adminmenu:server:ban', data)
    cb({ success = true })
end)
