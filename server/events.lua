AddEventHandler('playerConnecting', function(name, _, deferrals)
    deferrals.defer()

    local src = source
    deferrals.update('Checking your identifiers...')

    Wait(1000)
    local identifier = ESX.GetIdentifier(src)
    deferrals.update('Checking ban status...')
    Wait(3000)
    local ban = Helpers.isBanned(identifier)
    Wait(1000)
    if ban then
        deferrals.done(ban.reason or 'You are banned from this server')
        return
    end

    deferrals.update('Finalizing connection...')
    Wait(100)

    deferrals.done()
end)
