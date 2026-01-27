fx_version 'cerulean'
game 'gta5'

description 'ESX Admin Menu'
author 'ESX (Zox)'
version '0.1.0'

lua54 'yes'

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
    'server/*.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/**/*'
}

dependencies {
  'es_extended',
  'oxmysql'
}
