ESX.RegisterServerCallback("esx-adminmenu:server:getInitData", function(source, cb)
	if not Helpers.hasPermission(source) then
		cb({ error = "Insufficient Permissions." })
		return
	end

	local currentPlayers = #GetPlayers()
	local maxPlayers = GetConvarInt("sv_maxclients", 32)
	local translations = Helpers.getTranslations()

	cb({
		translations = translations, -- can be empty safely
		serverData = {
			currentPlayers = currentPlayers,
			maxPlayers = maxPlayers,
		},
	})
end)

ESX.RegisterServerCallback("esx-adminmenu:server:getVehicles", function(source, cb)
	if not Helpers.hasPermission(source) then
		cb({ error = "Insufficient Permissions." })
		return
	end

	local vehicles = Helpers.getAllVehicles()

	cb({
		vehicles = vehicles,
	})
end)

ESX.RegisterServerCallback("esx-adminmenu:server:getBans", function(source, cb)
	if not Helpers.hasPermission(source) then
		cb({ error = "Insufficient Permissions." })
		return
	end

	local bans = Helpers.getActiveBans()
	cb({
		bans = bans,
	})
end)

ESX.RegisterServerCallback("esx-adminmenu:server:searchOfflinePlayer", function(source, cb, data)
	-- TODO: Find a way to find all characters of a user just by their main identifier.
	local src = source

	if not Helpers.hasPermission(src) then
		cb({ err = "Insufficient Permissions" })
		return
	end

	if not data or not data.identifier then
		cb({ players = {} })
		return
	end

	local identifier = data.identifier

	local rows = MySQL.query.await(
		"SELECT identifier, firstname, lastname, sex, job, job_grade, accounts, last_seen FROM users WHERE identifier LIKE ?",
		{ "%" .. identifier .. "%" }
	)

	if not rows or #rows == 0 then
		cb({ players = {} })
		return
	end

	local players = {}

	for i = 1, #rows do
		local r = rows[i]

		local accounts = r.accounts and json.decode(r.accounts) or {}

		players[#players + 1] = {
			status = "offline",
			name = (r.firstname or "") .. " " .. (r.lastname or ""),

			cash = accounts.money or 0,
			bank = accounts.bank or 0,
			alt_money = accounts.black_money or 0,

			char_identifier = r.identifier,
			identifier = r.identifier,

			gender = r.sex == "m" and "m" or "f",

			job = r.job,
			job_grade = r.job_grade,

			last_join = r.last_seen,
		}
	end

	cb({ players = players })
end)
