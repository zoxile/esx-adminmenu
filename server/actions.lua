local function async(cb, fn)
	cb({ success = true })
	CreateThread(fn)
end

-- TELEPORT

ESX.RegisterServerCallback("esx-adminmenu:server:goto", function(source, cb, data)
	local src = source

	if not Helpers.hasPermission(src) then
		cb({ success = false, err = "Insufficient Permissions", playerOnline = true })
		return
	end

	local targetId = tonumber(data?.id)
	if not Helpers.isOnline(targetId) then
		cb({ success = false, playerOnline = false })
		return
	end

	local admin = ESX.Player(src)
	local target = ESX.Player(targetId)
	if not admin or not target then
		cb({ success = false, playerOnline = target ~= nil })
		return
	end

	admin.setCoords(target.getCoords(true))
	cb({ success = true, playerOnline = true })
end)

ESX.RegisterServerCallback("esx-adminmenu:server:bring", function(source, cb, data)
	local src = source

	if not Helpers.hasPermission(src) then
		cb({ success = false, playerOnline = true })
		return
	end

	local targetId = tonumber(data?.id)
	if not Helpers.isOnline(targetId) then
		cb({ success = false, playerOnline = false })
		return
	end

	local admin = ESX.Player(src)
	local target = ESX.Player(targetId)
	if not admin or not target then
		cb({ success = false, playerOnline = target ~= nil })
		return
	end

	target.setCoords(admin.getCoords(true))
	cb({ success = true, playerOnline = true })
end)

-- SPECTATE

ESX.RegisterServerCallback("esx-adminmenu:server:spectate", function(source, cb, data)
	local src = source

	if not Helpers.hasPermission(src) then
		cb({ success = false, err = "Insufficient Permissions" })
		return
	end

	local targetId = tonumber(data?.id)
	if not Helpers.isOnline(targetId) then
		cb({ success = false, err = "Player Not Online" })
		return
	end

	Helpers.stopSpectate(src)
	Helpers.startSpectate(src, targetId)

	cb({ success = true })
end)

ESX.RegisterServerCallback("esx-adminmenu:server:spectate:stop", function(source, cb)
	Helpers.stopSpectate(source)
	cb({ success = true })
end)

-- KICK

ESX.RegisterServerCallback("esx-adminmenu:server:kick", function(source, cb, data)
	local src = source

	if not Helpers.hasPermission(src) then
		cb({ success = false })
		return
	end

	local targetId = tonumber(data?.id)
	if not Helpers.isOnline(targetId) then
		cb({ success = false, playerOnline = false })
		return
	end

	async(cb, function()
		local identifier = ESX.GetIdentifier(targetId)

		MySQL.insert.await(
			"INSERT INTO kicks (identifier, reason, kicked_by) VALUES (?, ?, ?)",
			{ identifier, data.reason or "Kicked by admin", GetPlayerName(src) }
		)

		DropPlayer(targetId, data.reason or "Kicked by admin")
	end)
end)

-- BAN

ESX.RegisterServerCallback("esx-adminmenu:server:ban", function(source, cb, data)
	local src = source

	if not Helpers.hasPermission(src) then
		cb({ success = false })
		return
	end

	local targetId = tonumber(data?.id)
	if not Helpers.isOnline(targetId) then
		cb({ success = false })
		return
	end

	async(cb, function()
		local expiresAt = data.duration and os.date("!%Y-%m-%d %H:%M:%S", os.time() + data.duration * 60) or nil
		local identifier = ESX.GetIdentifier(targetId)

		MySQL.insert.await(
			"INSERT INTO bans (identifier, reason, banned_by, expires_at) VALUES (?, ?, ?, ?)",
			{ identifier, data.reason or "Banned by admin", GetPlayerName(src), expiresAt }
		)

		BanCache.add({
			identifier = identifier,
			reason = data.reason,
			expires_at = expiresAt,
		})

		DropPlayer(targetId, data.reason or "You are banned")
	end)
end)

-- OFFLINE BAN
ESX.RegisterServerCallback("esx-adminmenu:server:ban:offline", function(source, cb, data)
	if not Helpers.hasPermission(source) or not data?.identifier then
		cb({ success = false })
		return
	end

	async(cb, function()
		local expiresAt = data.duration and os.date("!%Y-%m-%d %H:%M:%S", os.time() + data.duration * 60) or nil

		MySQL.insert.await(
			"INSERT INTO bans (identifier, reason, banned_by, expires_at) VALUES (?, ?, ?, ?)",
			{ data.identifier, data.reason or "Banned by admin", GetPlayerName(source), expiresAt }
		)

		BanCache.add({
			identifier = data.identifier,
			reason = data.reason,
			expires_at = expiresAt,
		})
	end)
end)

-- CHANGE EXPIRY
ESX.RegisterServerCallback("esx-adminmenu:server:ban:changeExpiry", function(source, cb, data)
	if not Helpers.hasPermission(source) or not data?.identifier then
		cb({ success = false })
		return
	end

	async(cb, function()
		local seconds = nil
		if data.newDate then
			seconds = math.floor(tonumber(data.newDate) / 1000)
		end
		local affected = MySQL.update.await(
			"UPDATE bans SET expires_at = FROM_UNIXTIME(?) WHERE identifier = ?",
			{ seconds, data.identifier }
		)

		print("rows affected:", affected)
		BanCache.updateExpiry(data.identifier, expiresAt)
	end)
end)

-- REVOKE (expire now)
ESX.RegisterServerCallback("esx-adminmenu:server:ban:revoke", function(source, cb, data)
	if not Helpers.hasPermission(source) or not data?.identifier then
		cb({ success = false })
		return
	end

	async(cb, function()
		MySQL.update.await("UPDATE bans SET expires_at = NOW() WHERE identifier = ?", { data.identifier })
		BanCache.remove(data.identifier)
	end)
end)

-- VEHICLES

local function vehicleAsync(source, cb, data, query)
	if not Helpers.hasPermission(source) or not data?.plate then
		cb({ success = false })
		return
	end

	async(cb, function()
		MySQL.update.await(query, { data.plate })
	end)
end

ESX.RegisterServerCallback("esx-adminmenu:server:vehicleImpound", function(source, cb, data)
	vehicleAsync(source, cb, data, "UPDATE owned_vehicles SET impounded = 1 WHERE plate = ?")
end)

ESX.RegisterServerCallback("esx-adminmenu:server:vehicleUnimpound", function(source, cb, data)
	vehicleAsync(source, cb, data, "UPDATE owned_vehicles SET impounded = 0 WHERE plate = ?")
end)

ESX.RegisterServerCallback("esx-adminmenu:server:vehicleDelete", function(source, cb, data)
	vehicleAsync(source, cb, data, "DELETE FROM owned_vehicles WHERE plate = ?")
end)
