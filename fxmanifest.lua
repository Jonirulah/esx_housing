fx_version 'adamant'
lua54 "yes"
game 'gta5'
description 'ESX Housing'
version 'legacy'
shared_scripts {'@es_extended/imports.lua', 'Shared/Config.lua'}

server_scripts {
	'@es_extended/locale.lua',
	'Server/SMain.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'Client/main.lua'
}

dependencies {
	'es_extended',
	'esx_skin'
}
