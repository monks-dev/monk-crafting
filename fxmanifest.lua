fx_version 'cerulean'
game 'gta5'

description 'A new crafting system'
author 'Monks'
version '0.0.1'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/shared/locale.lua',
    'shared/config.lua',
}


client_scripts {
    'client/client.lua',
}

server_scripts {
    'server/server.lua',
}

lua54 'yes'
