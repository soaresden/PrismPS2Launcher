--[[------------------SPAGHETTICODE-------------------]]--
--[[█▀█ ██▀ ▀█▀ █▀█ █▀█ █    ▄▄ ▄ ▄ ▄▄▄ ▄▄▄ █▄▄ ▄▄  ▄▄]]--
--[[█▀▄ █▄▄  █  █▀▄ █▄█ █▄▄ ▀▄█ █▄█ █ █ █▄▄ █ █ ██▄ █ ]]--
--[[--------------------------------------------------]]--

-- Mostrar imagen antes de la carga de variables
if true then
	local FONDO_LOAD = Graphics.loadImage("System/Medios/Default/FONDO.png")
	local LOADING_LOAD = Graphics.loadImage("System/Medios/Default/LOADING.png")
	Screen.clear(Color.new(0,0,0))
	Graphics.drawScaleImage(FONDO_LOAD,-5,0,640+5,480,Color.new(0,80,120))
	Graphics.drawScaleImage(LOADING_LOAD,0,0,640,480)
	Screen.flip()
	Graphics.freeImage(FONDO_LOAD)
	Graphics.freeImage(LOADING_LOAD)
end

-- Cargar todas las variables y configuraciones
require("System/menu")
require("System/funciones")
puerto_usb()
recargar_todas()
cargar_config()

-- Ejecutar RETROLauncher
while true do
	Dibujar()
	Generar_Listas()
	refrescar()
	CONTROL.FPS = Screen.getFPS(1)
end
--[[------------------SPAGHETTICODE-------------------]]--