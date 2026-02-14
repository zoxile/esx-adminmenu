local ESX = exports.es_extended:getSharedObject()

Helpers = {}
local translations = nil
local allowedGroups = {}
local Spectators = {}

for group, allowed in pairs(Config.AllowedGroups) do
    if allowed then
        allowedGroups[#allowedGroups + 1] = group
    end
end

local function getFormattedPlayTime(playtime)
    if playtime == 0 or playtime < 0 then return 0 end
    local days = math.floor(playtime / 86400)
    local hours = math.floor((playtime % 86400) / 3600)
    local minutes = math.floor((playtime % 3600) / 60)
    return { days = days, hours = hours, minutes = minutes }
end

function Helpers.isOnline(source)
    return GetPlayerName(source) ~= nil
end

function Helpers.getLastSeen(identifier)
    local result = MySQL.single.await('SELECT last_seen FROM users WHERE identifier = ?', { identifier })

    if not result?.last_seen then
        return nil
    end

    return result.last_seen
end

function Helpers.isBanned(identifier)
    local ban = BanCache.get(identifier)
    if ban then
        return ban
    end
    return nil
end

function Helpers.getAllowedPermissions()
    return allowedGroups
end

function Helpers.hasPermission(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    return Config.AllowedGroups[xPlayer.getGroup()] == true
end

function Helpers.getPlayerList()
    local players = {}
    local xPlayers = ESX.GetExtendedPlayers()

    for i = 1, #xPlayers do
        local xPlayer = xPlayers[i]
        local src = xPlayer.source

        local ped = GetPlayerPed(src)
        local coords = xPlayer.getCoords(true)
        local playtime = getFormattedPlayTime(xPlayer.getPlayTime() or 0)

        players[#players + 1] = {
            status = 'online', -- At the moment only online.
            id = src,
            name = xPlayer.getName(),

            cash = xPlayer.getMoney(),
            bank = xPlayer.getAccount('bank').money,
            alt_money = (xPlayer.getAccount('black_money') and xPlayer.getAccount('black_money').money) or 0,

            health = math.floor((GetEntityHealth(ped) - 100) / 100 * 100),
            armor = GetPedArmour(ped),

            last_join = Helpers.getLastSeen(xPlayer.identifier),

            identifier = xPlayer.identifier,
            license = xPlayer.getIdentifier(),

            job = xPlayer.job?.name,
            job_grade = xPlayer.job?.grade_label,

            gender = xPlayer.sex == 0 and 'm' or 'f',

            play_time = playtime,
            position = {
                x = coords.x,
                y = coords.y,
                z = coords.z
            }
        }
    end

    return players
end

function Helpers.startSpectate(adminSrc, targetSrc)
    Spectators[adminSrc] = targetSrc
end

function Helpers.stopSpectate(adminSrc)
    Spectators[adminSrc] = nil
end

function Helpers.getSpectateTarget(adminSrc)
    return Spectators[adminSrc]
end

function Helpers.getSpectators()
    return Spectators
end

function Helpers.getTranslations()
    if not translations then
        local keys = {
            'admin_menu',
            'admin_menu_desc',
            'search_anything',
            'server_online',
            'players',
            'search_player',
            'player_management',
            'players_list',
            'id',
            'name',
            'money',
            'bank_money',
            'black_money',
            'health',
            'armor',
            'last_visited',
            'gender',
            'male',
            'female',
            'job',
            'job_grade',
            'license',
            'identifier',
            'play_time',
            'position',
            'player_information',
            'information',
            'teleport',
            'bring',
            'spectate',
            'kick',
            'ban',
            'never',
            'copied_to_clipboard',
            'online',
            'offline',
            'player',
            'reason',
            'kick_reason_placeholder',
            'ban_reason_placeholder',
            'duration',
            'minutes',
            'hours',
            'days',
            'months',
            'years',
            'permanent',
            'duration_desc',
            'cancel',
            'confirm',
            'escape_spectate',
            'default_ban'
        }

        translations = {}

        for i = 1, #keys do
            local key = keys[i]
            translations[key] = Translate(key)
        end 
    end

    return translations
end

function Helpers.getTranslation(key)
    if translations == nil then return 'Error, translations not found!' end
    return translations[key]
end

return Helpers