--  VEC2
local allowedPermissions = Helpers.getAllowedPermissions()
ESX.RegisterCommand(
	"vec2",
	allowedPermissions,
	function(xPlayer, args, showError)
		if not xPlayer or xPlayer.source == 0 then
			showError("Invalid player.")
			return
		end

		if not Helpers.hasPermission(xPlayer.source) then
			showError("You do not have permission to use this command.")
			return
		end

		local ped = GetPlayerPed(xPlayer.source)
		if ped == 0 then
			showError("Failed to get player ped.")
			return
		end

		local coords = GetEntityCoords(ped)

		local text = string.format("vec2(%.2f, %.2f)", coords.x, coords.y)

		TriggerClientEvent("esx-adminmenu:client:copyToClipboard", xPlayer.source, text)
	end,
	false,
	{
		help = "Copy your current position as vec2(x, y)",
	}
)

--  VEC3

ESX.RegisterCommand(
	"vec3",
	allowedPermissions,
	function(xPlayer, args, showError)
		if not xPlayer or xPlayer.source == 0 then
			showError("Invalid player.")
			return
		end

		if not Helpers.hasPermission(xPlayer.source) then
			showError("You do not have permission to use this command.")
			return
		end

		local ped = GetPlayerPed(xPlayer.source)
		if ped == 0 then
			showError("Failed to get player ped.")
			return
		end

		local coords = GetEntityCoords(ped)

		local text = string.format("vec3(%.2f, %.2f, %.2f)", coords.x, coords.y, coords.z)

		TriggerClientEvent("esx-adminmenu:client:copyToClipboard", xPlayer.source, text)
	end,
	false,
	{
		help = "Copy your current position as vec3(x, y, z)",
	}
)

--  VEC4

ESX.RegisterCommand(
	"vec4",
	allowedPermissions,
	function(xPlayer, args, showError)
		if not xPlayer or xPlayer.source == 0 then
			showError("Invalid player.")
			return
		end

		if not Helpers.hasPermission(xPlayer.source) then
			showError("You do not have permission to use this command.")
			return
		end

		local ped = GetPlayerPed(xPlayer.source)
		if ped == 0 then
			showError("Failed to get player ped.")
			return
		end

		local coords = GetEntityCoords(ped)
		local heading = GetEntityHeading(ped)

		local text = string.format("vec4(%.2f, %.2f, %.2f, %.2f)", coords.x, coords.y, coords.z, heading)

		TriggerClientEvent("esx-adminmenu:client:copyToClipboard", xPlayer.source, text)
	end,
	false,
	{
		help = "Copy your current position as vec4(x, y, z, heading)",
	}
)

ESX.RegisterCommand(
	{ "admin", "adminmenu" },
	allowedPermissions,
	function(xPlayer, args, showError)
		if not xPlayer or xPlayer.source == 0 then
			showError("Invalid player.")
			return
		end

		if not Helpers.hasPermission(xPlayer.source) then
			showError("You do not have permission to open the admin menu.")
			return
		end

		local players = Helpers.getPlayerList() or {}

		if #players == 0 then
			showError("Admin menu cannot be opened. No players found.")
			return
		end

		TriggerClientEvent("esx-adminmenu:client:open", xPlayer.source, players)
	end,
	true,
	{
		help = "Opens the ESX Admin Menu",
	}
)

ESX.RegisterCommand(
	{ "refreshbans", "refreshbancache" },
	allowedPermissions,
	function(xPlayer, args, showError)
		if not xPlayer or xPlayer.source == 0 then
			showError("Invalid player.")
			return
		end

		if not Helpers.hasPermission(xPlayer.source) then
			showError("You do not have permission to open the admin menu.")
			return
		end
		BanCache.load()
	end,
	true,
	{
		help = "Refreshes the ban cache if manual changes were made to the database.",
	}
)
