local Helpers = require('server.helpers')

AddEventHandler('playerConnecting', function(name, _, deferrals)
    deferrals.defer()

    local src = source
    deferrals.update('Checking your identifiers...')

    Wait(100)

    local identifiers = GetPlayerIdentifiers(src)
    deferrals.update('Checking ban status...')

    Wait(100)

    local ban = Helpers.checkBan(identifiers)
    if ban then
        deferrals.done(ban.reason or 'You are banned from this server.')
        return
    end

    deferrals.update('Finalizing connection...')
    Wait(100)

    deferrals.done()
end)
