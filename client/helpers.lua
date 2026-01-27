local Helpers = {}

function Helpers.getPlayerPedFromServerId(serverId)
    local player = GetPlayerFromServerId(serverId)
    if player == -1 then return nil end
    return GetPlayerPed(player)
end

return Helpers
