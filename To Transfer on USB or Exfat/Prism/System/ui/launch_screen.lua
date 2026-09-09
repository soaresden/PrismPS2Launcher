-- Prism PS2 Launcher - ui/launch_screen.lua
-- Screens shown around a launch: progress lines, CHD warning, disc-swap help.
-- Split from the original funciones.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Functions are globals; this file only defines them. Loaded by System/system.lua.

--- Un paso del lanzamiento: a la pantalla y al log. ----------------------------------
--- Los pasos previos al arranque de un core -- buscar el core, elegirlo, comprobarlo en
--- la llave, copiarlo -- eran mudos, y cuando uno fallaba lo unico que se veia era
--- "Games or RetroArch not found". Que no dice cual de los cuatro ha fallado.
LANZA_LINEAS = {}
LANZA_VERDE = {}
LANZA_VERDE_COL = nil

--- Repinta la pantalla de lanzamiento, CENTRADA. --------------------------------------
--- Estaba alineada a la izquierda, en x=60 y despues en x=90, y una tele recorta ese
--- borde: se perdia el principio de cada linea. Centrada -- x=320, que es lo que hace
--- LIBRETRO_PANTALLA -- no depende de cuanto recorte la pantalla, y las lineas son
--- cortas de todas formas.
--- Un .chd en una carpeta de Ember: se explica, no se intenta. -------------------------
--- Ember lee ".cue" o ".bin". Un ".chd" lo deja donde estaba y arranca en el shell de la
--- BIOS de PS1, sin decir nada -- el usuario se queda mirando una pantalla azul sin
--- saber que ha pasado.
---
--- Y descomprimirlo aqui no es una alternativa razonable, por mucho que la idea tiente:
--- un CHD v5 lleva el mapa de sectores comprimido en Huffman y cada bloque en zlib,
--- LZMA o FLAC. Escribir esos tres descompresores en Lua, sobre un R5900, para volcar
--- entre 300 y 700 MB a USB, son horas por juego y un fichero a medias si algo falla.
--- Treinta segundos en el PC contra una tarde en la consola.
function chd_warning_screen(carpeta)
    local seguir = true
    JOYSTICK_LIMITE = control_FPS(1)
    while seguir do
        CONTROL.FPS = Screen.getFPS(1)
        capturar(JOYSTICK_LIMITE)
        dibujar_fondos()
        Graphics.drawRect(40, 90 + CONTROL.Y_FIX_PAL, CONTROL.ANCHO - 80, 250, COLOR.NEGRO_T)
        Font.ftPrint(CONTROL.fontARCA, CONTROL.ANCHO // 2, 104 + CONTROL.Y_FIX_PAL, 8,
            520, 25, "-.CHD NOT SUPPORTED BY EMBER-", Color.new(230, 60, 60))
        local lineas = {
            carpeta,
            "",
            "Ember reads .cue or .bin. A .chd is left alone and the",
            "game drops to the PS1 BIOS screen.",
            "",
            "Convert it on the PC - about thirty seconds with chdman -",
            "and put the .cue and .bin in this folder. The .chd can stay,",
            "Ember simply ignores it.",
            "",
            "Doing it on the console would take hours: a CHD packs its",
            "sector map with Huffman and its blocks with zlib, LZMA or",
            "FLAC, and there are hundreds of megabytes to write.",
        }
        for i = 1, #lineas do
            Font.ftPrint(CONTROL.fontARCA, 60, 134 + ((i - 1) * 16) + CONTROL.Y_FIX_PAL,
                0, 500, 18, lineas[i], COLOR.BLANCO_LISTA)
        end
        dibujar_indicador(CONTROL.ANCHO // 2 - 40, 310 + CONTROL.Y_FIX_PAL,
            TEXT_GEN[6], PAD_IMG.CIRCLE, 20, 20, 5, true)
        refrescar(false)
        if (Pads.check(PAD, PAD_CIRCLE) or Pads.check(PAD, PAD_CROSS)
            or Pads.check(PAD, PAD_TRIANGLE)) and CONTROL.JOYSTICK_ON == false then
            repro_sfx(S_CANCELAR, 1, false, nil)
            seguir = false
        end
    end
    JOYSTICK_LIMITE = control_FPS(1)
end

--- Las combinaciones de cambio de disco, antes de ceder la mano a POPStarter. ----------
--- POPStarter no las ensena en ninguna parte, y un juego de varios discos se queda
--- parado al final del primero si no se conocen: no hay menu, se simula la tapa de la
--- consola con el mando. Se muestran cinco segundos justo antes de arrancar, que es el
--- ultimo instante en que este programa dibuja algo -- despues ya no existe.
---
--- Solo cuando hay un DISCS.TXT con dos discos o mas, para no estorbar en el 90% de los
--- juegos. CRUZ o START lo saltan.
---
--- Las flechas van escritas y no dibujadas: PAD_IMG no trae la cruceta, y una flecha
--- inventada con rectangulos se lee peor que la palabra.
DISCS_SECONDS = 5

function discs_screen(fichero_discs, titulo)
	if fichero_discs == nil or doesFileExist(fichero_discs) == false then return end

	local discos = {}
	pcall(function()
		local h = System.openFile(fichero_discs, FREAD)
		System.seekFile(h, 0, SET)
		local t = System.readFile(h, System.sizeFile(h))
		System.closeFile(h)
		if t == nil then return end
		-- La variable de un "for" generico es constante en Lua 5.4, de ahi la copia.
		for linea in string.gmatch(t .."\n", "([^\r\n]*)[\r\n]") do
			local limpia = string.gsub(linea, "%s+$", "")
			if string.len(limpia) > 0 then discos[#discos + 1] = limpia end
		end
	end)
	if #discos < 2 then return end

	local filas = {{"Open the lid", PAD_IMG.TRIANGLE, nil}}
	local flechas = {"UP", "RIGHT", "DOWN", "LEFT"}
	for i = 1, #discos do
		if i > 4 then break end
		filas[#filas + 1] = {"Insert Disc ".. i, nil, flechas[i]}
	end
	filas[#filas + 1] = {"Close the lid", PAD_IMG.SQUARE, nil}

	local alto = 34
	local y0 = (CONTROL.ALTO_F // 2) - ((#filas * alto) // 2) + 10
	local total = DISCS_SECONDS * 60
	if CONTROL.Y_FIX_PAL ~= nil and CONTROL.Y_FIX_PAL > 0 then
		total = DISCS_SECONDS * 50
	end

	local n = 0
	while n < total do
		n = n + 1
		local mando = Pads.get(0)
		if Pads.check(mando, PAD_CROSS) or Pads.check(mando, PAD_START) then break end

		Screen.clear(Color.new(0, 0, 0))
		Font.ftPrint(CONTROL.fontARCA, CONTROL.ANCHO // 2, 24 + CONTROL.Y_FIX_PAL, 8,
			600, 25, "-".. tostring(#discos) .." DISCS-", CAMBIOS_EMUS.COLOR_EMU)
		Font.ftPrint(CONTROL.fontARCA, CONTROL.ANCHO // 2, 50 + CONTROL.Y_FIX_PAL, 8,
			600, 25, tostring(titulo), COLOR.BLANCO)

		for i = 1, #filas do
			local y = y0 + ((i - 1) * alto)
			Font.ftPrint(CONTROL.fontARCA, 40, y, 0, 260, 25, filas[i][1], COLOR.BLANCO_LISTA)
			local x = 300
			Graphics.drawScaleImage(PAD_IMG.SELECT_S, x, y - 2, 40, 24); x = x + 44
			Font.ftPrint(CONTROL.fontARCA, x, y, 0, 20, 25, "+", COLOR.BLANCO_LISTA); x = x + 16
			Graphics.drawScaleImage(PAD_IMG.L2, x, y - 3, 32, 26); x = x + 36
			Font.ftPrint(CONTROL.fontARCA, x, y, 0, 20, 25, "+", COLOR.BLANCO_LISTA); x = x + 16
			Graphics.drawScaleImage(PAD_IMG.R2, x, y - 3, 32, 26); x = x + 36
			Font.ftPrint(CONTROL.fontARCA, x, y, 0, 20, 25, "+", COLOR.BLANCO_LISTA); x = x + 16
			if filas[i][2] ~= nil then
				Graphics.drawScaleImage(filas[i][2], x, y - 2, 26, 26)
			else
				Font.ftPrint(CONTROL.fontARCA, x, y, 0, 90, 25, filas[i][3], CAMBIOS_EMUS.COLOR_EMU)
			end
		end

		Font.ftPrint(CONTROL.fontARCA, CONTROL.ANCHO // 2,
			CONTROL.ALTO_F - 34 + CONTROL.Y_FIX_PAL, 8, 600, 25,
			"POPStarter has no disc menu: you open and close the lid yourself.",
			COLOR.GRIS)
		Screen.flip()
	end
end

function launch_paint()
	if LANZA_VERDE_COL == nil then LANZA_VERDE_COL = Color.new(0, 128, 45) end
	pcall(function()
		for pasada = 1, 2 do
			Screen.clear(COLOR.NEGRO)
			local y = 120 + CONTROL.Y_FIX_PAL
			for i = 1, #LANZA_LINEAS do
				local col = COLOR.BLANCO
				if LANZA_VERDE[i] == true then col = LANZA_VERDE_COL end
				Font.ftPrint(CONTROL.fontARCA, 320, y, 8, 600, 22, LANZA_LINEAS[i], col)
				y = y + 26
			end
			if pasada == 1 then Screen.flip() end
		end
	end)
end

--- Un paso. "verde" para lo que ya estaba en su sitio y no hay que copiar. ------------
function launch_step(texto, verde)
	LANZA_LINEAS[#LANZA_LINEAS + 1] = tostring(texto)
	LANZA_VERDE[#LANZA_LINEAS] = (verde == true)
	while #LANZA_LINEAS > 8 do
		table.remove(LANZA_LINEAS, 1)
		table.remove(LANZA_VERDE, 1)
	end
	boot_log("LANZA  ".. tostring(texto))
	boot_flush()
	launch_paint()
end

--- Sustituye la ultima linea en vez de anadir una. Para el progreso de una copia, que
--- si no llenaria la pantalla y el journal con una linea por cada 256 KB.
function launch_replace(texto)
	if #LANZA_LINEAS == 0 then return launch_step(texto) end
	LANZA_LINEAS[#LANZA_LINEAS] = tostring(texto)
	LANZA_VERDE[#LANZA_LINEAS] = false
	launch_paint()
end

--- El gancho que llama copy_with_progress entre trozo y trozo. -----------------------
function copy_progress(etiqueta, hechos, total)
	launch_replace("Copying ".. tostring(etiqueta) .."  "
		.. tostring(hechos // 1024) .." / ".. tostring(total // 1024) .." KB")
end
