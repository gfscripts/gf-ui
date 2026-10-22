fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'gf-ui'
author 'GF Scripts'
description 'Avisos, barra de progreso y texto de ayuda con diseño propio. Compatible con ESX y QBCore.'
version '1.0.0'

shared_script 'config.lua'
client_script 'client/main.lua'
server_script 'server/main.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/fonts/*.woff2',
}
