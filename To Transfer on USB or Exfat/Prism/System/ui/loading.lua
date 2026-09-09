-- Prism PS2 Launcher - ui/loading.lua
-- Loading screen: origin banner and the boot checklist.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- De donde ha arrancado el lanzador, en dos lineas para la pantalla de carga. -------
--- Solo eso. Aqui se decia ademas donde estaba RetroArch y si los juegos iban a
--- arrancar, y para saberlo habia que llamar a RUTA_LIBRETRO() -- un rastreo de varios
--- segundos, lanzado justo en el momento en que la pantalla ya no se refresca. El
--- diagnostico de RetroArch sigue estando, entero, en Prism.log, que es su sitio.
--- Estas dos lineas se leen de variables ya calculadas: no cuestan nada.
--- En ingles como el resto de la interfaz. SHOW_ORIGIN a false para quitarlo.
SHOW_ORIGIN = true

function origin_text()
	if BOOT_ES_ATA ~= true then
		return "Booted from USB / external media", tostring(BOOT_DEV)
	end
	return "Booted from INTERNAL exFAT drive", tostring(BOOT_DEV)
end

--- Pantalla de carga, repintable. ----------------------------------------------------
--- El texto "Loading lists and settings" esta dentro de LOADING.png, en la banda
--- y=247..282 de una imagen de 480 de alto. Se tapa con negro y se escribe encima el
--- paso en curso, para que un arranque que no llega al menu diga DONDE se ha parado en
--- vez de quedarse en una frase fija. Lo mismo va al journal, con volcado inmediato.
LOAD_BG, LOAD_IMG, LOAD_FONT = nil, nil, nil
LOAD_RES_X, LOAD_RES_Y = 640, 448

--- Las ultimas lineas, no una sola. ---------------------------------------------------
--- Una banda con el paso en curso no dice nada cuando el arranque se para: se ve DONDE
--- se ha quedado pero no por donde habia pasado. Con una lista que se desplaza se lee
--- de un vistazo lo que ya esta hecho, y la ultima linea, marcada con ">", es
--- exactamente aquello que no ha terminado.
LOAD_LINES = {}

--- El texto va en los HUECOS de la imagen, sin taparla. --------------------------------
--- LOADING.png mide 640x480 y se dibuja a 640x448. Midiendo sus pixeles opacos, lo que
--- hay dibujado ocupa, ya en coordenadas de pantalla:
---
---     10..191   x  24..614   el logotipo
---    231..263   x 212..427   la palabra "LOADING"
---    331..440   x  12..628   los creditos: Neutrino, Enceladus, wLaunchELF,
---                            POPStarter, RetroArch y OPL, cada uno con su autor
---
--- De ahi que solo queden DOS franjas enteramente libres, y son estas:
---
---    194..226   entre el logotipo y "LOADING"
---    264..328   entre "LOADING" y los creditos
---
--- El panel negro de antes iba de 8 a 432 y se comia el principio del logotipo y la
--- columna izquierda de los creditos. Ni el titulo ni el nombre de quien ha escrito lo
--- que uno arranca merecen desaparecer detras de una lista de arranque.
---
--- Asi que la lista se reparte en esas dos franjas: el origen arriba y los pasos abajo
--- en dos columnas. Caben diez pasos en vez de veintidos -- el historico entero sigue
--- estando en Prism.log, que es su sitio; esto es solo por donde va.
LOAD_LINE_H = 12

LOAD_ORIGIN_BAND_Y, LOAD_ORIGIN_BAND_H = 194, 32
LOAD_ORIGIN_Y = 198

LOAD_STEPS_BAND_Y, LOAD_STEPS_BAND_H = 264, 64
LOAD_STEPS_Y = 268
LOAD_STEPS_ROWS = 5
LOAD_COLUMNS = {20, 330}
LOAD_COL_W = 290

LOAD_MAX_LINES = LOAD_STEPS_ROWS * #LOAD_COLUMNS

--- El soporte de cada paso, en paralelo con el texto: "exfat", "usb" o nil. ------------
LOAD_KINDS = {}

function load_paint()
	if LOAD_BG == nil then return end
	Screen.clear(Color.new(0, 0, 0))
	Graphics.drawScaleImage(LOAD_BG, -5, 0, LOAD_RES_X+5, LOAD_RES_Y, Color.new(0, 80, 120))
	Graphics.drawScaleImage(LOAD_IMG, 0, 0, LOAD_RES_X, LOAD_RES_Y)
	if LOAD_FONT == nil then return end
	pcall(function()
		local blanco = Color.new(255, 255, 255)
		local gris = Color.new(160, 160, 160)
		local negro = Color.new(0, 0, 0)

		-- Un panel estrecho a la izquierda, no la pantalla entera. Empieza en x=30 y
		-- no en 0 porque una tele recorta los bordes: pegado al canto no se lee. Y
		-- Llega hasta x=256. El "LOADING" de LOADING.png empieza en 212, asi que se
		-- le come el principio: es el precio de que las lineas quepan enteras, y una
		-- linea cortada no informa de nada. El cuerpo baja a 9 px por lo mismo.
		-- Amarillo el disco interno, cian la llave USB. Es la misma pareja de colores
		-- en todo el programa, para no tener que leer la palabra: de un vistazo se ve
		-- de donde sale cada sistema.
		local amarillo = Color.new(255, 205, 0)
		local cian = Color.new(0, 200, 255)

		-- Un velo oscuro SOLO sobre las dos franjas libres, para que el texto tenga
		-- contraste sin tapar nada de la imagen.
		local velo = Color.new(0, 0, 0, 150)
		Graphics.drawRect(0, LOAD_ORIGIN_BAND_Y, LOAD_RES_X, LOAD_ORIGIN_BAND_H, velo)
		Graphics.drawRect(0, LOAD_STEPS_BAND_Y, LOAD_RES_X, LOAD_STEPS_BAND_H, velo)

		Font.ftSetPixelSize(LOAD_FONT, 9, 9)

		if SHOW_ORIGIN == true then
			local l1, l2 = origin_text()
			local col = cian
			if BOOT_ES_ATA == true then col = amarillo end
			Font.ftPrint(LOAD_FONT, 20, LOAD_ORIGIN_Y, 6, 600, LOAD_LINE_H, l1, col)
			Font.ftPrint(LOAD_FONT, 20, LOAD_ORIGIN_Y + LOAD_LINE_H, 6, 600,
				LOAD_LINE_H, l2, gris)
		end

		-- Los pasos, por columnas: se llena la primera de arriba abajo y se sigue en la
		-- siguiente.
		for i = 1, #LOAD_LINES do
			local col_n = ((i - 1) // LOAD_STEPS_ROWS) + 1
			local fila = (i - 1) % LOAD_STEPS_ROWS
			local x = LOAD_COLUMNS[col_n]
			if x ~= nil then
				local tipo = LOAD_KINDS[i]
				local marca, col = "  ", gris
				if i == #LOAD_LINES then marca, col = "> ", blanco end
				if tipo == "exfat" then col = amarillo
				elseif tipo == "usb" then col = cian end
				Font.ftPrint(LOAD_FONT, x, LOAD_STEPS_Y + (fila * LOAD_LINE_H), 6,
					LOAD_COL_W, LOAD_LINE_H, marca .. LOAD_LINES[i], col)
			end
		end
		Font.ftSetPixelSize(LOAD_FONT, 14, 14)
	end)
end

--- Un paso del arranque: al log (volcado ya) y a la pantalla. -------------------------
--- "tipo" pinta la linea: "exfat" en amarillo, "usb" en cian, nil en gris. -------------
function load_step(texto, tipo)
	-- Solo durante el arranque. Varias de las funciones instrumentadas -- recargar_todas
	-- sobre todo -- se vuelven a llamar desde el menu, y sin esto el log creceria sin
	-- fin y cada refresco de lista repintaria la pantalla de carga sobre el menu.
	if LOAD_BG == nil then return end
	LOAD_LINES[#LOAD_LINES + 1] = tostring(texto)
	LOAD_KINDS[#LOAD_LINES] = tipo
	while #LOAD_LINES > LOAD_MAX_LINES do
		table.remove(LOAD_LINES, 1)
		table.remove(LOAD_KINDS, 1)
	end
	boot_log("CARGA  ".. tostring(texto))
	boot_flush()
	-- Los dos buffers, para que lo que se ve sea lo mismo tras cualquier flip ajeno.
	pcall(function()
		load_paint()
		Screen.flip()
		load_paint()
	end)
end

function load_end()
	-- Las imagenes se liberan; la FUENTE no. Y no es un descuido.
	--
	-- "Font.ftInit()" se llama dos veces: una aqui arriba, para poder escribir en la
	-- pantalla de carga, y otra dentro de la tabla CONTROL, que es la del programa
	-- original. LOAD_FONT se obtiene ANTES de esa segunda inicializacion, asi que
	-- descargarla aqui destruye una referencia que ya no pertenece al FreeType en
	-- curso -- y con ella se lleva el estado de "fontARCA" y "fontABC".
	--
	-- El sintoma no es un error sino un menu MUDO: el arranque llega hasta el final,
	-- el bucle principal corre, y ningun "Font.ftPrint" dibuja nada. Pantalla negra
	-- con el programa vivo detras. El journal termina en "entrando en el menu" y
	-- parece que todo ha ido bien, que es lo que lo hace dificil de encontrar.
	--
	-- Una cara de fuente sin liberar no cuesta casi nada. Un menu invisible, todo.
	pcall(function()
		if LOAD_BG ~= nil then Graphics.freeImage(LOAD_BG) end
		if LOAD_IMG ~= nil then Graphics.freeImage(LOAD_IMG) end
	end)
	LOAD_FONT, LOAD_BG, LOAD_IMG = nil, nil, nil
end
