local ESX = exports.es_extended:getSharedObject()
local Helpers = require('server.helpers')

ESX.RegisterServerCallback('esx-adminmenu:server:getInitData', function(source, cb)
    if not Helpers.hasPermission(source) then
        cb(nil)
        return
    end

    cb({
        translations = {},
        serverData = Helpers.getOnlinePlayerList()
    })
end)
