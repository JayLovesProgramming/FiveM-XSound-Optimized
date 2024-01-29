fx_version 'cerulean'
game 'gta5'
lua54 "yes"

client_scripts {
  '@ox_lib/init.lua',
	"config.lua",
	"client/**.lua",
}

server_scripts {
	"server/**.lua",
}

ui_page "html/index.html"

files {
	"html/index.html",
	"html/scripts/listener.js",
	"html/scripts/SoundPlayer.js",
	"html/scripts/functions.js",
	"html/sounds/*.ogg",
	"html/sounds/*.mp3",
}
