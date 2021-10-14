fx_version 'adamant'
lua54 "yes"
game 'gta5'
description 'ESX Housing'
version 'legacy'
shared_script '@es_extended/imports.lua'

server_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'client/main.lua'
}

dependencies {
	'es_extended',
	'esx_skin'
}
