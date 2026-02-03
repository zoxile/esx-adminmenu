BanCache = {}
local bans = {}

function BanCache.load()
    local rows = MySQL.query.await('SELECT * FROM bans')
    if not rows then return end

    for i = 1, #rows do
        local ban = rows[i]

        if not bans[ban.identifier] then
            bans[ban.identifier] = {}
        end

        bans[ban.identifier][#bans[ban.identifier] + 1] = ban
    end
end


function BanCache.get(identifier)
    print('Checking Identifier for ban:', identifier)

    local list = bans[identifier]
    if not list then return nil end

    local now = os.time()

    for i = #list, 1, -1 do
        local ban = list[i]

        if ban.expires_at then
            local expires

            if type(ban.expires_at) == 'number' then
                if ban.expires_at > 1e12 then
                    expires = math.floor(ban.expires_at / 1000)
                else
                    expires = ban.expires_at
                end

            elseif type(ban.expires_at) == 'string' then
                expires = os.time({
                    year  = tonumber(ban.expires_at:sub(1,4)),
                    month = tonumber(ban.expires_at:sub(6,7)),
                    day   = tonumber(ban.expires_at:sub(9,10)),
                    hour  = tonumber(ban.expires_at:sub(12,13)),
                    min   = tonumber(ban.expires_at:sub(15,16)),
                    sec   = tonumber(ban.expires_at:sub(18,19))
                })
            end

            if expires and now >= expires then
                table.remove(list, i)
            else
                return ban
            end
        else
            return ban
        end
    end

    if #list == 0 then
        bans[identifier] = nil
    end

    return nil
end


function BanCache.add(ban)
    if not bans[ban.identifier] then
        bans[ban.identifier] = {}
    end

    bans[ban.identifier][#bans[ban.identifier] + 1] = ban
end

return BanCache
