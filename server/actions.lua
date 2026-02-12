--  TELEPORT
ESX.RegisterServerCallback('esx-adminmenu:server:goto', function(source, cb)
    local src = source
    if not Helpers.hasPermission(src) then 
        print('[esx-adminmenu] Malicious use by user', src, 'has been detected! (Goto without permissions)')
        cb({err = 'Insufficient Permissions', success = false, playerOnline = true})
        return     
    end

    local targetId = tonumber(data.id)
    if not Helpers.isOnline(targetId) then 
        cb({err = 'Target offline', success = false, playerOnline = false})
        return 
    end

    local admin = ESX.Player(src)
    local target = ESX.Player(targetId)
    if not admin or not target then
        local targetExists = target ~= nil
        cb({err = 'Admin or target not found', success = false, playerOnline = targetExists})
        return 
    end
    admin.setCoords(target.getCoords(true))
    cb({success = true, playerOnline = true})
end)

ESX.RegisterServerCallback('esx-adminmenu:server:bring', function(source, cb)
    local src = source
    if not Helpers.hasPermission(src) then 
        print('[esx-adminmenu] Malicious use by user', src, 'has been detected! (Bring without permissions)')
        cb({err = 'Insufficient Permissions', success = false, playerOnline = true})
        return     
    end

    local targetId = tonumber(data.id)
    if not Helpers.isOnline(targetId) then 
        cb({err = 'Target offline', success = false, playerOnline = false})
        return 
    end

    local admin = ESX.Player(src)
    local target = ESX.Player(targetId)
    if not admin or not target then
        local targetExists = target ~= nil
        cb({err = 'Admin or target not found', success = false, playerOnline = targetExists})
        return 
    end
    target.setCoords(target.getCoords(true))
    cb({success = true, playerOnline = true})
end)

--  SPECTATE

ESX.RegisterServerCallback('esx-adminmenu:server:spectate', function(source, cb)
    local src = source
    local isAdmin = Helpers.hasPermission(src)
    if not isAdmin then
        print('[esx-adminmenu] Malicious use by user', src, 'has been detected! (Spectating without permissions)')
        cb({ src = src, isAdmin = isAdmin, err = 'Insufficient Permissions' })
        return 
    end

    local targetId = tonumber(data.id)
    if not Helpers.isOnline(targetId) then
        cb({ src = src, isAdmin = isAdmin, err = 'Player Not Online' })
        return     
    end

    Helpers.stopSpectate(src)
    Helpers.startSpectate(src, targetId)
    cb({ src = src, isAdmin = isAdmin, err = nil })
end)

ESX.RegisterServerCallback('esx-adminmenu:server:spectate:stop', function(source, cb)
    local src = source
    local isAdmin = Helpers.hasPermission(src)
    local err = nil
    if not isAdmin then
        print('[esx-adminmenu] Malicious use by user', src, 'has been detected! (Spectating without permissions)')
        err = 'Insufficient Permissions, the usage of this action will be notified.'
    end
    Helpers.stopSpectate(src)
    cb({ src = src, isAdmin = isAdmin, err = err })
end)

--  KICK
ESX.RegisterServerCallback('esx-adminmenu:server:kick', function(source, cb)
    local src = source
    if not Helpers.hasPermission(src) then 
        print('[esx-adminmenu] Malicious use by user', src, 'has been detected! (Kick without permissions)')
        cb({err = 'Insufficient Permissions', success = false, playerOnline = true})
        return     
    end

    local targetId = tonumber(data.id)
    if not Helpers.isOnline(targetId) then 
        cb({err = 'Target offline', success = false, playerOnline = false})
        return 
    end

    local admin = ESX.Player(src)
    local target = ESX.Player(targetId)
    if not admin or not target then
        local targetExists = target ~= nil
        cb({err = 'Admin or target not found', success = false, playerOnline = targetExists})
        return 
    end
    MySQL.insert.await('INSERT INTO kicks (identifier, reason, kicked_by) VALUES (?, ?, ?)', {
            ESX.GetIdentifier(xTarget.src),
            data.reason or 'Kicked by admin',
            GetPlayerName(src)
        }
    )
    DropPlayer(target, data.reason or 'Kicked by admin')
    cb({success = true, playerOnline = false})
end)

--  BAN
ESX.RegisterServerCallback('esx-adminmenu:server:ban', function(source, cb)
    local src = source
    if not Helpers.hasPermission(src) then 
        print('[esx-adminmenu] Malicious use by user', src, 'has been detected! (Ban without permissions)')
        cb({err = 'Insufficient Permissions', success = false, playerOnline = true})
        return     
    end

    local targetId = tonumber(data.id)
    if not Helpers.isOnline(targetId) then 
        cb({err = 'Target offline', success = false, playerOnline = false})
        return 
    end

    local admin = ESX.Player(src)
    local target = ESX.Player(targetId)
    if not admin or not target then
        local targetExists = target ~= nil
        cb({err = 'Admin or target not found', success = false, playerOnline = targetExists})
        return 
    end

    local expiresAt = data.duration and os.date('!%Y-%m-%d %H:%M:%S', os.time() + (data.duration * 60)) or nil

    local identifier = ESX.GetIdentifier(xTarget.src)

    MySQL.insert.await('INSERT INTO bans (identifier, reason, banned_by, expires_at) VALUES (?, ?, ?, ?)', {
            identifier,
            data.reason or 'Banned by admin',
            GetPlayerName(src),
            expiresAt
        }
    )

    BanCache.add({
        identifier = identifier,
        reason = data.reason,
        expires_at = expiresAt
    })

    DropPlayer(target, data.reason or 'You are banned')
    cb({success = true, playerOnline = false})
end)

