fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

version '1.0.0'

-- UI
ui_page 'html/ui.html'

-- Client Scripts
client_scripts {
    'client.lua'
}

-- Server Scripts
server_scripts {
    'server.lua'
}

-- Shared Scripts
shared_scripts {
    'config.lua'
}

-- Files
files {
    'html/ui.html',
    'html/crad.png',
    'html/app.js',


}

