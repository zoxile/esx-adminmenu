AdminOpen = false

local function toggleNUI(bool)
	SetNuiFocus(bool, bool)
	AdminOpen = bool
end

RegisterNUICallback("goto", function(data, cb)
	ESX.TriggerServerCallback("esx-adminmenu:server:goto", function(res)
		if not res or res.err then
			print("[esx-adminmenu]", res and res.err)
			cb({ success = false })
			return
		end

		cb({ success = res.success, playerOnline = res.playerOnline })
	end, data)
end)

RegisterNUICallback("bring", function(data, cb)
	ESX.TriggerServerCallback("esx-adminmenu:server:bring", function(res)
		if not res or res.err then
			print("[esx-adminmenu]", res and res.err)
			cb({ success = false })
			return
		end

		cb({ success = res.success, playerOnline = res.playerOnline })
	end, data)
end)

RegisterNUICallback("spectate", function(data, cb)
	ESX.TriggerServerCallback("esx-adminmenu:server:spectate", function(res)
		if not res or res.err then
			print("[esx-adminmenu]", res and res.err)
			cb({ success = false })
			return
		end

		if not res.isAdmin then
			cb({ success = false, playerOnline = res.playerOnline })
			return
		end

		Spectate(data.id)
		cb({ success = true, playerOnline = res.playerOnline })
	end, data)
end)

RegisterNUICallback("spectate:stop", function(_, cb)
	ESX.TriggerServerCallback("esx-adminmenu:server:spectate:stop", function(res)
		if not res or res.err then
			print("[esx-adminmenu]", res and res.err)
			cb({ success = false })
			return
		end

		StopSpectate()
		cb({ success = true, playerOnline = res.playerOnline })
	end)
end)

RegisterNUICallback("kick", function(data, cb)
	ESX.TriggerServerCallback("esx-adminmenu:server:kick", function(res)
		if not res or res.err then
			print("[esx-adminmenu]", res and res.err)
			cb({ success = false })
			return
		end

		cb({ success = res.success, playerOnline = res.playerOnline })
	end, data)
end)

RegisterNUICallback("ban", function(data, cb)
	ESX.TriggerServerCallback("esx-adminmenu:server:ban", function(res)
		if not res or res.err then
			print("[esx-adminmenu]", res and res.err)
			cb({ success = false })
			return
		end

		cb({ success = res.success, playerOnline = res.playerOnline })
	end, data)
end)

RegisterNUICallback("ban:offline", function(data, cb)
	ESX.TriggerServerCallback("esx-adminmenu:server:ban:offline", function(res)
		if not res or res.err then
			print("[esx-adminmenu:banOffline]", res and res.err)
			cb({ success = false })
			return
		end

		cb({ success = res.success })
	end, data)
end)

RegisterNUICallback("ban:changeExpiry", function(data, cb)
	ESX.TriggerServerCallback("esx-adminmenu:server:ban:changeExpiry", function(res)
		if not res or res.err then
			print("[esx-adminmenu:changeExpiry]", res and res.err)
			cb({ success = false })
			return
		end

		cb({ success = res.success })
	end, data)
end)

RegisterNUICallback("ban:revoke", function(data, cb)
	ESX.TriggerServerCallback("esx-adminmenu:server:ban:revoke", function(res)
		if not res or res.err then
			print("[esx-adminmenu:revokeBan]", res and res.err)
			cb({ success = false })
			return
		end

		cb({ success = res.success })
	end, data)
end)

RegisterNUICallback("releaseFocus", function(data, cb)
	toggleNUI(false)
	cb({ success = true })
end)

RegisterNUICallback("getVehicles", function(data, cb)
	ESX.TriggerServerCallback("esx-adminmenu:server:getVehicles", function(res)
		if not res or res.error then
			print("[esx-adminmenu:getVehicles]", res and res.error)
			cb(nil)
			return
		end

		cb(res.vehicles or {})
	end)
end)

RegisterNUICallback("getBans", function(data, cb)
	ESX.TriggerServerCallback("esx-adminmenu:server:getBans", function(res)
		if not res or res.error then
			print("[esx-adminmenu:getBans]", res and res.error)
			cb(nil)
			return
		end

		cb(res.bans or {})
	end)
end)

RegisterNUICallback("player:searchOffline", function(data, cb)
	ESX.TriggerServerCallback("esx-adminmenu:server:searchOfflinePlayer", function(res)
		if not res or res.err then
			print("[esx-adminmenu:searchOffline]", res and res.err)
			cb(nil)
			return
		end

		cb(res.players or {})
	end, data)
end)

RegisterNUICallback("vehicle:impound", function(data, cb)
	ESX.TriggerServerCallback("esx-adminmenu:server:vehicleImpound", function(res)
		if not res or res.err then
			print("[esx-adminmenu:vehicleImpound]", res and res.err)
			cb({ success = false })
			return
		end

		cb({ success = res.success })
	end, data)
end)

RegisterNUICallback("vehicle:unimpound", function(data, cb)
	ESX.TriggerServerCallback("esx-adminmenu:server:vehicleUnimpound", function(res)
		if not res or res.err then
			print("[esx-adminmenu:vehicleUnimpound]", res and res.err)
			cb({ success = false })
			return
		end

		cb({ success = res.success })
	end, data)
end)

RegisterNUICallback("vehicle:delete", function(data, cb)
	ESX.TriggerServerCallback("esx-adminmenu:server:vehicleDelete", function(res)
		if not res or res.err then
			print("[esx-adminmenu:vehicleDelete]", res and res.err)
			cb({ success = false })
			return
		end

		cb({ success = res.success })
	end, data)
end)

RegisterNetEvent("esx-adminmenu:client:copyToClipboard", function(text)
	SendNUIMessage({
		action = "copyToClipboard",
		data = text,
	})
end)

RegisterNetEvent("esx-adminmenu:client:open", function(data)
	toggleNUI(true)
	SendNUIMessage({
		action = "openAdmin",
		data = data,
	})
end)
