local Helpers = require('server.helpers')
local BanCache = require('server.ban_cache')
-- ========================
--  TELEPORT (SERVER SIDE)
-- ========================

RegisterNetEvent('esx-adminmenu:server:goto', function(data)
    local src = source
    if not Helpers.hasPermission(src) then return end

    local targetId = tonumber(data.id)
    if not Helpers.isOnline(targetId) then return end

    Helpers.getXPlayer(src).setCoords(
        Helpers.getXPlayer(targetId).getCoords(true)
    )
end)

RegisterNetEvent('esx-adminmenu:server:bring', function(data)
    local src = source
    if not Helpers.hasPermission(src) then return end

    local targetId = tonumber(data.id)
    if not Helpers.isOnline(targetId) then return end

    Helpers.getXPlayer(targetId).setCoords(
        Helpers.getXPlayer(src).getCoords(true)
    )
end)

-- ========================
--  SPECTATE
-- ========================

RegisterNetEvent('esx-adminmenu:server:spectate', function(data)
    local src = source
    if not Helpers.hasPermission(src) then return end

    local targetId = tonumber(data.id)
    if not Helpers.isOnline(targetId) then return end

    Helpers.startSpectate(src, targetId)
    TriggerClientEvent('esx-adminmenu:client:startSpectate', src, targetId)
end)

RegisterNetEvent('esx-adminmenu:server:spectate:stop', function()
    local src = source

    Helpers.stopSpectate(src)
    TriggerClientEvent('esx-adminmenu:client:stopSpectate', src)
end)

-- ========================
--  KICK
-- ========================

RegisterNetEvent('esx-adminmenu:server:kick', function(data)
    local src = source
    if not Helpers.hasPermission(src) then return end

    local target = tonumber(data.id)
    if not Helpers.isOnline(target) then return end

    local xTarget = Helpers.getXPlayer(target)

    MySQL.insert.await(
        'INSERT INTO kicks (identifier, license, reason, kicked_by) VALUES (?, ?, ?, ?)',
        {
            xTarget.identifier,
            xTarget.getIdentifier('license'),
            data.reason or 'Kicked by admin',
            GetPlayerName(src)
        }
    )

    DropPlayer(target, data.reason or 'Kicked by admin')
end)

-- ========================
--  BAN
-- ========================

RegisterNetEvent('esx-adminmenu:server:ban', function(data)
    local src = source
    if not Helpers.hasPermission(src) then return end

    local target = tonumber(data.id)
    if not Helpers.isOnline(target) then return end

    local xTarget = Helpers.getXPlayer(target)

    local expiresAt = data.duration
        and os.date('%Y-%m-%d %H:%M:%S', os.time() + data.duration)
        or nil

    MySQL.insert.await(
        'INSERT INTO bans (identifier, license, reason, banned_by, expires_at) VALUES (?, ?, ?, ?, ?)',
        {
            xTarget.identifier,
            xTarget.getIdentifier('license'),
            data.reason or 'Banned by admin',
            GetPlayerName(src),
            expiresAt
        }
    )

    BanCache.add({
        identifier = xTarget.identifier,
        reason = data.reason,
        expires_at = expiresAt
    })

    DropPlayer(target, data.reason or 'You are banned')
end)

