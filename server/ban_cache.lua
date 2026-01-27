local BanCache = {}

local bans = {}

function BanCache.load()
    local rows = MySQL.query.await('SELECT * FROM bans')
    for _, ban in ipairs(rows or {}) do
        bans[ban.identifier] = ban
    end
end

function BanCache.get(identifier)
    local ban = bans[identifier]
    if not ban then return nil end

    -- Expired ban → remove from cache
    if ban.expires_at and os.time() >= os.time({
        year = ban.expires_at:sub(1,4),
        month = ban.expires_at:sub(6,7),
        day = ban.expires_at:sub(9,10),
        hour = ban.expires_at:sub(12,13),
        min = ban.expires_at:sub(15,16),
        sec = ban.expires_at:sub(18,19)
    }) then
        bans[identifier] = nil
        return nil
    end

    return ban
end

function BanCache.add(ban)
    bans[ban.identifier] = ban
end

return BanCache
