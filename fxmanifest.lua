fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_script '@es_extended/imports.lua'

client_scripts {
	'client/client.lua'
}

server_scripts {
	'config.lua',
	'@oxmysql/lib/MySQL.lua',
	'server/server.lua'
}
