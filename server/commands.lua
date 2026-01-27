local Helpers = require('server.helpers')

ESX.RegisterCommand('vec2', 'admin', function(xPlayer, args, showError)
    if not xPlayer or xPlayer.source == 0 then return end
    print('test')
end, false, {
    help = 'Get vec2' 
})

ESX.RegisterCommand({'admin', 'adminmenu'}, 'group', function(xPlayer, args, showError)
    if not xPlayer or xPlayer.source == 0 then return end
    if not Helpers.hasPermission(xPlayer.source) then return end

    TriggerClientEvent('esx-adminmenu:client:open', xPlayer.source)
end, true, {
    help = 'Opens the ESX Admin Menu'
})