fx_version 'cerulean'
game 'gta5'
lua54 'yes'

version 'v2.2'

shared_scripts {
	'@ox_lib/init.lua',
	'locales.lua',
	'config.lua',
}

client_scripts {
	'client/functions.lua',
	'client/client.lua',
	'client/framework.lua'
}

server_scripts {
	'server/server.lua',
	'server/framework.lua'
}
