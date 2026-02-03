fx_version 'cerulean'
game 'gta5'

description 'ESX Admin Menu'
author 'ESX (Zox)'
version '0.1.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@es_extended/locale.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/ban_cache.lua',
    'server/helpers.lua',
    'server/actions.lua',
    'server/commands.lua',
    'server/events.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/**/*',
}

dependencies {
  'es_extended',
  'oxmysql'
}
