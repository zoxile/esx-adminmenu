--  TELEPORT
RegisterNetEvent('esx-adminmenu:server:goto', function(data)
    local src = source
    if not Helpers.hasPermission(src) then return end

    local targetId = tonumber(data.id)
    if not Helpers.isOnline(targetId) then return end

    local admin = ESX.Player(src)
    local target = ESX.Player(targetId)
    if not admin or not target then return end

    admin.setCoords(target.getCoords(true))
end)

RegisterNetEvent('esx-adminmenu:server:bring', function(data)
    local src = source
    if not Helpers.hasPermission(src) then return end

    local targetId = tonumber(data.id)
    if not Helpers.isOnline(targetId) then return end

    local admin = ESX.Player(src)
    local target = ESX.Player(targetId)
    if not admin or not target then return end

    target.setCoords(admin.getCoords(true))
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

RegisterNetEvent('esx-adminmenu:server:kick', function(data)
    local src = source
    if not Helpers.hasPermission(src) then return end
    local target = tonumber(data.id)
    if not Helpers.isOnline(target) then return end

    local xTarget = ESX.Player(target)
    if not xTarget then return end
    MySQL.insert.await('INSERT INTO kicks (identifier, reason, kicked_by) VALUES (?, ?, ?)', {
            ESX.GetIdentifier(xTarget.src),
            data.reason or 'Kicked by admin',
            GetPlayerName(src)
        }
    )
    DropPlayer(target, data.reason or 'Kicked by admin')
end)

--  BAN

RegisterNetEvent('esx-adminmenu:server:ban', function(data)
    local src = source
    if not Helpers.hasPermission(src) then return end

    local target = tonumber(data.id)
    if not Helpers.isOnline(target) then return end

    local xTarget = ESX.Player(target)
    if not xTarget then return end

    local expiresAt = data.duration and os.date('!%Y-%m-%d %H:%M:%S', os.time() + (data.duration * 60)) or nil

    local identifier = ESX.GetIdentifier(xTarget.src)

    MySQL.insert.await(
        'INSERT INTO bans (identifier, reason, banned_by, expires_at) VALUES (?, ?, ?, ?)',
        {
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
end)

