fx_version 'cerulean'
game 'gta5'

author 'Covex Studios'
description 'CS VLT M1-O - Free UI-only tint meter'
version '1.2.0'

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    'config.lua',
    'server.lua'
}

ui_page 'ui/html/index.html'

files {
    'ui/html/index.html',
    'ui/css/style.css',
    'ui/js/script.js',
    'ui/img/device.png',
    'ui/font/digital7.ttf'
}

dependency 'Badger_Discord_API'