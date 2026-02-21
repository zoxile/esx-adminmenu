fx_version("cerulean")
game("gta5")
lua54("yes")

author("ESX (Zox)")
description("ESX Admin Menu")
version("0.2.0")

shared_scripts({
	"@es_extended/imports.lua",
	"@es_extended/locale.lua",
	"locales/*.lua",
	"shared/*.lua",
})

client_scripts({
	"client/*.lua",
})

server_scripts({
	"@oxmysql/lib/MySQL.lua",
	"server/ban_cache.lua",
	"server/database.lua",
	"server/helpers.lua",
	"server/actions.lua",
	"server/commands.lua",
	"server/events.lua",
	"server/main.lua",
})

ui_page("html/index.html")

files({
	"html/index.html",
	"html/**/*",
})

dependencies({
	"es_extended",
	"oxmysql",
})
