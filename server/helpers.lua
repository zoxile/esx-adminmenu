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
	if playtime == 0 or playtime < 0 then
		return 0
	end
	local days = math.floor(playtime / 86400)
	local hours = math.floor((playtime % 86400) / 3600)
	local minutes = math.floor((playtime % 3600) / 60)
	return { days = days, hours = hours, minutes = minutes }
end

function Helpers.isOnline(source)
	return GetPlayerName(source) ~= nil
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
	if not xPlayer then
		return false
	end

	return Config.AllowedGroups[xPlayer.getGroup()] == true
end

local function loadLastSeenFor(identifiers)
	if #identifiers == 0 then
		return {}
	end

	local placeholders = {}
	for i = 1, #identifiers do
		placeholders[i] = "?"
	end

	local rows = MySQL.query.await(
		("SELECT identifier, last_seen FROM users WHERE identifier IN (%s)"):format(table.concat(placeholders, ",")),
		identifiers
	)

	local map = {}
	for i = 1, #(rows or {}) do
		map[rows[i].identifier] = rows[i].last_seen
	end

	return map
end

function Helpers.getPlayerList()
	local players = {}
	local identifiers = {}

	local xPlayers = ESX.ExtendedPlayers()

	-- One heavy numeric loop
	for i = 1, #xPlayers do
		local xPlayer = xPlayers[i]
		local src = xPlayer.src
		local full = ESX.GetPlayerFromId(src)

		local charIdentifier = full and full.identifier
		if charIdentifier then
			identifiers[#identifiers + 1] = charIdentifier
		end

		local ped = GetPlayerPed(src)
		local coords = xPlayer.getCoords(true)
		local playtime = getFormattedPlayTime(xPlayer.getPlayTime() or 0)

		local job = full and full.getJob()
		local bank = full and full.getAccount("bank")
		local black = full and full.getAccount("black_money")
		players[#players + 1] = {
			status = "online",
			id = src,
			name = xPlayer.getName(),

			cash = xPlayer.getMoney(),
			bank = bank and bank.money or 0,
			alt_money = black and black.money or 0,

			health = ped ~= 0 and math.floor(GetEntityHealth(ped) - 100) or 0,
			armor = ped ~= 0 and GetPedArmour(ped) or 0,

			char_identifier = charIdentifier,
			identifier = full.license,

			job = job and job.name or "unemployed",
			job_grade = job and job.grade_label or "",

			gender = full and full.variables.sex or "m",

			play_time = playtime,
			position = coords and { x = coords.x, y = coords.y, z = coords.z } or nil,
		}
	end

	-- Single DB query
	local lastSeenMap = loadLastSeenFor(identifiers)

	-- One light numeric loop for adding the last_seen's after getting all the current xPlayer identifiers.
	for i = 1, #players do
		local id = players[i].char_identifier
		players[i].last_join = id and lastSeenMap[id] or nil
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
			"admin_menu",
			"admin_menu_desc",
			"search_anything",
			"server_online",
			"players",
			"search_player",
			"search_vehicle",
			"search_banned_identifier",
			"player_management",
			"players_list",
			"vehicles_list",
			"player_search",
			"no_players_found",
			"bans_list",

			"id",
			"name",
			"money",
			"bank_money",
			"black_money",
			"health",
			"armor",
			"last_visited",
			"gender",
			"male",
			"female",
			"job",
			"job_grade",
			"identifier",
			"char_identifier",
			"play_time",
			"position",

			"player_information",
			"information",
			"teleport",
			"bring",
			"spectate",
			"kick",
			"ban",
			"never",
			"copied_to_clipboard",
			"online",
			"offline",
			"player",
			"reason",
			"kick_reason_placeholder",
			"ban_reason_placeholder",
			"duration",
			"minutes",
			"hours",
			"days",
			"months",
			"years",
			"permanent",
			"duration_desc",
			"cancel",
			"confirm",
			"escape_spectate",
			"default_ban",
			"finalizing_connection",

			"banned_by",
			"banned_at",
			"expires_at",
			"change_expiry",
			"revoke",
			"new_expiry_date",

			"plate",
			"owner",
			"vehicle_name",
			"vehicle_type",
			"mileage",
			"impounded",
			"copy_plate",
			"copy_owner",
			"impound",
			"unimpound",
			"delete_vehicle",
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
	if not key then
		print("^1[ESX-ADMINMENU] NIL TRANSLATION KEY CALLED^0")
		print(debug.traceback())
		return "missing_key"
	end
	if translations == nil then
		return "Error, translations not found!"
	end
	return translations[key]
end

function Helpers.getAllVehicles()
	local rows = MySQL.query.await("SELECT owner, plate, vehicle, stored, pound FROM owned_vehicles")
	if not rows then
		return {}
	end

	local vehicles = {}

	for i = 1, #rows do
		local v = rows[i]

		vehicles[#vehicles + 1] = {
			owner = v.owner,
			plate = v.plate,
			stored = v.stored == 1,
			impounded = v.impounded == 1,

			vehicle = v.vehicle and json.decode(v.vehicle) or nil,
		}
	end

	return vehicles
end

local function normalizeExpiry(expires_at)
	if not expires_at then
		return nil
	end

	if type(expires_at) == "number" then
		if expires_at > 1e12 then
			return math.floor(expires_at / 1000)
		end
		return expires_at
	end

	if type(expires_at) == "string" then
		return os.time({
			year = tonumber(expires_at:sub(1, 4)),
			month = tonumber(expires_at:sub(6, 7)),
			day = tonumber(expires_at:sub(9, 10)),
			hour = tonumber(expires_at:sub(12, 13)),
			min = tonumber(expires_at:sub(15, 16)),
			sec = tonumber(expires_at:sub(18, 19)),
		})
	end

	return nil
end

function Helpers.formatRemainingTime(seconds)
	local yearSeconds = 60 * 60 * 24 * 365
	local weekSeconds = 60 * 60 * 24 * 7
	local daySeconds = 60 * 60 * 24
	local hourSeconds = 60 * 60
	local minuteSeconds = 60

	local years = math.floor(seconds / yearSeconds)
	seconds = seconds % yearSeconds

	local weeks = math.floor(seconds / weekSeconds)
	seconds = seconds % weekSeconds

	local days = math.floor(seconds / daySeconds)
	seconds = seconds % daySeconds

	local hours = math.floor(seconds / hourSeconds)
	seconds = seconds % hourSeconds

	local minutes = math.floor(seconds / minuteSeconds)

	local parts = {}

	if years > 0 then
		table.insert(parts, years .. "y")
	end
	if weeks > 0 then
		table.insert(parts, weeks .. "w")
	end
	if days > 0 then
		table.insert(parts, days .. "d")
	end
	if hours > 0 then
		table.insert(parts, hours .. "h")
	end
	if minutes > 0 then
		table.insert(parts, minutes .. "m")
	end
	if #parts == 0 then
		table.insert(parts, "<1m")
	end

	return table.concat(parts, ", ")
end

function Helpers.getActiveBans()
	local all = BanCache.getAll()
	if not all then
		return {}
	end

	local now = os.time()
	local result = {}

	for identifier, list in pairs(all) do
		for i = #list, 1, -1 do
			local ban = list[i]

			local expires = normalizeExpiry(ban.expires_at)

			if expires and now >= expires then
				table.remove(list, i)
			else
				if expires then
					local remaining = expires - now
					ban.remaining_seconds = remaining
					ban.remaining_formatted = Helpers.formatRemainingTime(remaining)
				end

				result[#result + 1] = ban
			end
		end

		if #list == 0 then
			all[identifier] = nil
		end
	end

	return result
end

return Helpers
