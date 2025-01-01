fx_version 'cerulean'
game 'gta5'

author 'Mo7amed'
description 'Safe Zone Management Script made by Mo7amed'
version '1.0.0'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_script {
    'client.lua',
    'client_open.lua'
}

server_script 'server.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependency 'ox_lib'

escrow_ignore {
    'config.lua',
    'client_open.lua'
}
