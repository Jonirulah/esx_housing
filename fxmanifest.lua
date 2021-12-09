fx_version 'adamant'
lua54 "yes"
game 'gta5'
description 'ESX Housing'
version 'legacy'
author 'Jonirulah'
version '1.0.2'
shared_scripts {'@es_extended/imports.lua', 'Shared/Config.lua'}

ui_page 'Client/Assets/Sound.html'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'Shared/Locale.lua',
	'Server/Classes/House.lua',
	'Server/SMain.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'Client/Classes/House.lua',
	'Shared/Locale.lua',
	'Client/CMain.lua',
	'Client/Menus.lua',
}

files {
	'Client/Assets/Sound.js',
	'Client/Assets/ring.mp3',
	'Client/Assets/Sound.html'
}

dependencies {
	'es_extended',
	'esx_skin'
}
