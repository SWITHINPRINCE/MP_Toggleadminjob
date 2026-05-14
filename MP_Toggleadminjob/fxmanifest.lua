fx_version 'cerulean'
game 'gta5'

author 'Prince'
description 'Toggle Admin Job - Switch to unemployed and back (QBox)'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'ox_lib',
    'oxmysql',
    'qbx_core'
}
