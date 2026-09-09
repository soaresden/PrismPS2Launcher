-- Prism PS2 Launcher - menus/game_menu.lua
-- Per-game menu (triangle): launch menu, memory card picker, delete, alternate launch.
-- Split from the original funciones.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Functions are globals; this file only defines them. Loaded by System/system.lua.

--- Busca y guarda "VMC" de PS2. --------------------------------------------------------
function buscar_VMC(tipo)
	local exten = ".bin"
	if tipo == 2 then
		exten = ".mx4"
	elseif tipo == 3 then
		exten = ".hdd"
	elseif tipo == 4 then
		exten = ".mmc"
	elseif tipo == 5 then
		exten = ".udp"
	end
	local actual = System.currentDirectory()
	local device = salida_texto_dir(actual, nil)
	local Device_VMCs = System.listDirectory(device .."/VMC")
	local VMC_encontradas = {}
	if Device_VMCs ~= nil then
		for contador = 1, #Device_VMCs do
			if Device_VMCs[contador].directory == false and string.lower(string.sub(Device_VMCs[contador].name, -4)) == exten then
				table.insert(VMC_encontradas, device .."/VMC/".. Device_VMCs[contador].name)
			end
		end
	end
	return VMC_encontradas
end

--- Recarga un sistema determinado. -----------------------------------------------------
--- Lista de tarjetas para un juego. Se abre con CRUZ desde el menu del juego. --------
--- Se muestran las que EXISTEN, con su ruta entera, y despues una entrada "(NEW)" por
--- unidad para crear una que no existe todavia. Nada se crea al recorrer la lista:
--- solo al pulsar CRUZ sobre una entrada "(NEW)".
--- Devuelve la ruta elegida, o nil si se cancela.
--- Se abre desde el menu de lanzamiento, sobre la linea "VMC file".
---
--- De entrada solo se ven las tarjetas DE ESTE JUEGO, que es lo que se busca el 99%
--- de las veces. Las demas no desaparecen: hay una linea "See all VMC files" que las
--- trae, y siguen saliendo detras de las del juego. Una carpeta con cien partidas de
--- otros juegos no ayuda a encontrar la de Dark Cloud.
---
--- La ultima linea crea una tarjeta nueva. El numero del final se mueve con
--- IZQUIERDA / DERECHA -- no con arriba / abajo, que aqui hacen falta para recorrer
--- la lista, y en el resto del programa izquierda/derecha es siempre "cambiar el
--- valor de esta linea".
function vmc_pick_card(nombre_iso)
	local id = vmc_id(nombre_iso)
	if id == nil then return nil end

	-- Una sola lectura de las carpetas: recorrer la lista no debe volver al disco.
	local cand, propias = vmc_candidates(id)
	local unidades = vmc_drives()
	local ver_todo, num = false, 1
	local rutas, etiquetas = {}, {}

	local function nombre_nuevo()
		return vmc_new_name(nombre_iso, num) or (id .."-".. num ..".bin")
	end

	local function construir()
		rutas, etiquetas = {}, {}
		local tope = propias
		if ver_todo == true then tope = #cand end
		for i = 1, tope do
			rutas[#rutas + 1] = cand[i]
			if i <= propias then etiquetas[#etiquetas + 1] = "* ".. cand[i]
			else etiquetas[#etiquetas + 1] = "  ".. cand[i] end
		end
		if propias == 0 and ver_todo == false then
			rutas[#rutas + 1] = "-"
			etiquetas[#etiquetas + 1] = "  no card found for ".. id
		end
		if #cand > propias then
			rutas[#rutas + 1] = "TOGGLE"
			if ver_todo == true then
				etiquetas[#etiquetas + 1] = "[ Show only cards for ".. id .." ]"
			else
				etiquetas[#etiquetas + 1] = "[ See all VMC files ]  (".. (#cand - propias) .." more)"
			end
		end
		for i = 1, #unidades do
			rutas[#rutas + 1] = "NEW:".. unidades[i]
			etiquetas[#etiquetas + 1] = "[ Create on ".. unidades[i] .." <-> ]  ".. nombre_nuevo()
		end
	end

	local function refrescar_nuevas()
		for i = 1, #rutas do
			if string.sub(rutas[i], 1, 4) == "NEW:" then
				etiquetas[i] = "[ Create on ".. string.sub(rutas[i], 5) .." <-> ]  ".. nombre_nuevo()
			end
		end
	end

	construir()
	if #etiquetas == 0 then return nil end

	local VENTANA = 7
	local sel, abierto, elegida = 1, true, nil
	JOYSTICK_LIMITE = control_FPS(1)
	while abierto do
		CONTROL.FPS = Screen.getFPS(1)
		capturar(JOYSTICK_LIMITE)
		dibujar_fondos()

		local ini = sel - (VENTANA // 2)
		if ini > #etiquetas - VENTANA + 1 then ini = #etiquetas - VENTANA + 1 end
		if ini < 1 then ini = 1 end
		local vista, cursor = {}, 1
		for i = ini, ini + VENTANA - 1 do
			if etiquetas[i] ~= nil then
				vista[#vista + 1] = etiquetas[i]
				if i == sel then cursor = #vista end
			end
		end
		submenu_selector(vista, cursor, "-VMC for ".. id .."   ".. sel .."/".. #etiquetas .."-",
			56, 344, true, CONTROL.ANCHO // 2,
			{TEXT_GEN[5], TEXT_GEN[6]}, true, false, {}, nil)
		refrescar(false)

		local r = rutas[sel]

		if Pads.check(PAD, PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_EJECUTAR, 1, false, nil)
			if r == "TOGGLE" then
				ver_todo = (ver_todo == false)
				construir()
				if sel > #etiquetas then sel = #etiquetas end
				JOYSTICK_LIMITE = control_FPS(1)
			elseif r == "-" then
				JOYSTICK_LIMITE = control_FPS(1)
			elseif string.sub(r, 1, 4) == "NEW:" then
				elegida = vmc_create(string.sub(r, 5), nombre_nuevo())
				log_event("VMC", "created ".. tostring(elegida) .." for ".. tostring(id))
				abierto = false
			else
				elegida = r
				log_event("VMC", "picked ".. tostring(elegida) .." for ".. tostring(id))
				abierto = false
			end
		elseif (Pads.check(PAD, PAD_TRIANGLE) or Pads.check(PAD, PAD_CIRCLE))
		       and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_CANCELAR, 1, false, nil)
			abierto = false
		elseif string.sub(r, 1, 4) == "NEW:" and CONTROL.JOYSTICK_ON == false
		       and (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
			repro_sfx(S_MOVER, 1, false, nil)
			num = cambiar_valor(num, 1, 99, 1, false)
			refrescar_nuevas()
			JOYSTICK_LIMITE = control_FPS(1)
		elseif string.sub(r, 1, 4) == "NEW:" and CONTROL.JOYSTICK_ON == false
		       and (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
			repro_sfx(S_MOVER, 1, false, nil)
			num = cambiar_valor(num, 1, 99, 1, true)
			refrescar_nuevas()
			JOYSTICK_LIMITE = control_FPS(1)
		elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_MOVER, 1, false, nil)
			sel = cambiar_valor(sel, 1, #etiquetas, 1, false)
			JOYSTICK_LIMITE = control_FPS(1)
		elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_MOVER, 1, false, nil)
			sel = cambiar_valor(sel, 1, #etiquetas, 1, true)
			JOYSTICK_LIMITE = control_FPS(1)
		end
	end
	JOYSTICK_LIMITE = control_FPS(1)
	return elegida
end

--- Menu de lanzamiento de un juego de PS2. ---------------------------------------------
--- Se abre SIEMPRE antes de arrancar una ISO, desde CRUZ en la lista o desde el menu
--- del juego. Un juego de PS2 no se lanza a ciegas: aqui se ve, antes de arrancar, en
--- que tarjeta se va a guardar la partida, de que fichero sale, y con que lanzador.
--- Devuelve true si hay que lanzar, false si se ha cancelado.
function launch_menu(nombre_iso)
	if nombre_iso == nil then return false end
	vmc_cfg_load()
	launcher_cfg_load()
	local id = vmc_id(nombre_iso)

	-- Estado de partida, tal y como quedo la ultima vez. VMC.cfg es la memoria del
	-- "last vmc for this game": una linea "<ID>=<ruta>".
	local usar_vmc = true
	if id == nil or VMC_GAMES[id] == "none" then usar_vmc = false end

	local elegida = nil
	if id ~= nil then
		local v = VMC_GAMES[id]
		if v ~= nil and v ~= "none" and doesFileExist(v) then
			elegida = v
		else
			-- Ninguna eleccion guardada: se propone la primera tarjeta DE ESTE JUEGO.
			local cand, propias = vmc_candidates(id)
			if propias >= 1 then elegida = cand[1] end
		end
	end

	local function et_tarjeta()
		if usar_vmc == false then return "Memory card : Real PS2 card" end
		return "Memory card : VMC card"
	end
	local function et_fichero()
		if usar_vmc == false then return "VMC file    : -" end
		if elegida == nil then return "VMC file    : none yet   (X to pick or create)" end
		return "VMC file    : ".. elegida
	end
	local function et_lanzador()
		if launcher_is_opl(nombre_iso) then return "Launch with : OPL" end
		return "Launch with : Neutrino"
	end

	local etiquetas = {et_tarjeta(), et_fichero(), et_lanzador(), "Start game", "Cancel"}
	local I_TARJETA, I_FICHERO, I_LANZADOR, I_START, I_CANCEL = 1, 2, 3, 4, 5

	local function repintar()
		etiquetas[I_TARJETA] = et_tarjeta()
		etiquetas[I_FICHERO] = et_fichero()
		etiquetas[I_LANZADOR] = et_lanzador()
	end

	local function guardar()
		if id == nil then return end
		if usar_vmc == false then
			VMC_GAMES[id] = "none"
		elseif elegida ~= nil then
			VMC_GAMES[id] = elegida
		else
			VMC_GAMES[id] = nil
		end
		vmc_cfg_save()
	end

	local sel, abierto, lanzar = 1, true, false
	log_event("MENU", "launch menu opened for ".. tostring(nombre_iso)
		.."  card=".. (usar_vmc and tostring(elegida) or "real")
		.."  launcher=".. (launcher_is_opl(nombre_iso) and "opl" or "neutrino"))
	JOYSTICK_LIMITE = control_FPS(1)
	while abierto do
		CONTROL.FPS = Screen.getFPS(1)
		capturar(JOYSTICK_LIMITE)
		dibujar_fondos()
		submenu_selector(etiquetas, sel,
			"-Launch ".. NOMBRE_VISIBLE(15, nombre_iso, 1) .."-",
			56, 344, true, CONTROL.ANCHO // 2,
			{TEXT_GEN[5], TEXT_GEN[6]}, true, false, {}, nil)
		refrescar(false)

		if Pads.check(PAD, PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_EJECUTAR, 1, false, nil)
			if sel == I_FICHERO and usar_vmc == true then
				local escogida = vmc_pick_card(nombre_iso)
				if escogida ~= nil then elegida = escogida end
				repintar()
				JOYSTICK_LIMITE = control_FPS(1)
			elseif sel == I_START then
				-- Con "VMC card" pero sin fichero no se arranca: seria una partida
				-- que se pierde al apagar, sin que nada lo hubiera dicho. El cursor
				-- se va a la linea que falta.
				if usar_vmc == true and elegida == nil then
					sel = I_FICHERO
					JOYSTICK_LIMITE = control_FPS(1)
				else
					guardar()
					log_event("LANZA", "start: ".. tostring(nombre_iso)
						.."  card=".. (usar_vmc and tostring(elegida) or "real PS2 card")
						.."  launcher=".. (launcher_is_opl(nombre_iso) and "OPL" or "Neutrino"))
					lanzar = true
					abierto = false
				end
			elseif sel == I_CANCEL then
				log_event("MENU", "launch menu cancelled")
				abierto = false
			else
				JOYSTICK_LIMITE = control_FPS(1)
			end
		elseif (Pads.check(PAD, PAD_TRIANGLE) or Pads.check(PAD, PAD_CIRCLE))
		       and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_CANCELAR, 1, false, nil)
			abierto = false
		elseif sel == I_TARJETA and CONTROL.JOYSTICK_ON == false
		       and (Pads.check(PAD, PAD_LEFT) or Pads.check(PAD, PAD_RIGHT)
		            or Left_X <= -90 or Left_X >= 90) then
			repro_sfx(S_MOVER, 1, false, nil)
			usar_vmc = (usar_vmc == false)
			repintar()
			JOYSTICK_LIMITE = control_FPS(1)
		elseif sel == I_LANZADOR and CONTROL.JOYSTICK_ON == false
		       and (Pads.check(PAD, PAD_LEFT) or Pads.check(PAD, PAD_RIGHT)
		            or Left_X <= -90 or Left_X >= 90) then
			repro_sfx(S_MOVER, 1, false, nil)
			if launcher_is_opl(nombre_iso) then
				LAUNCHER_GAMES[nombre_iso] = nil
			else
				LAUNCHER_GAMES[nombre_iso] = "opl"
			end
			launcher_cfg_save()
			repintar()
			JOYSTICK_LIMITE = control_FPS(1)
		elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_MOVER, 1, false, nil)
			sel = cambiar_valor(sel, 1, #etiquetas, 1, false)
			JOYSTICK_LIMITE = control_FPS(1)
		elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_MOVER, 1, false, nil)
			sel = cambiar_valor(sel, 1, #etiquetas, 1, true)
			JOYSTICK_LIMITE = control_FPS(1)
		end
	end
	JOYSTICK_LIMITE = control_FPS(1)
	return lanzar
end

--- Menu del juego seleccionado. TRIANGULO en la lista. ---------------------------------
--- Antes, TRIANGULO intercambiaba caratula y captura, y era la unica cosa que hacia.
--- Las demas acciones por juego estaban repartidas en combinaciones que nada anunciaba
--- -- CIRCULO+TRIANGULO abria los ajustes de PS1, de PS2 o el explorador de APPS segun
--- el sistema. Nadie las encuentra por casualidad.
--- Ahora TRIANGULO abre esta lista: el intercambio de arte sigue ahi, acompanado de lo
--- que aplique al sistema en curso, y del borrado. Las combinaciones antiguas siguen
--- funcionando para quien las conozca.
function game_menu()
	if LISTAS.ROMS == nil or LISTAS.ROMS[LISTAS.INDICE] == nil then return end
	local etiquetas, acciones = {}, {}

	local function anadir(texto, accion)
		etiquetas[#etiquetas + 1] = texto
		acciones[#acciones + 1] = accion
	end

	if LISTAS.MOSTRAR >= LISTAS.ART_LIMITE then
		local cual = "cover"
		if LISTAS.SCREENSHOT_ON == false then cual = "screenshot" end
		anadir("Show ".. cual, function()
			LISTAS.SCREENSHOT_ON = (LISTAS.SCREENSHOT_ON == false)
		end)
	end

	if LISTAS.IDENTIDAD == 13 then
		anadir("File browser", function() animaciones(nil, true); exporer_apps() end)
	elseif LISTAS.IDENTIDAD == 14 then
		if string.lower(string.sub(LISTAS.ROMS[LISTAS.INDICE], -4)) ~= ".elf" then
			anadir("PS1 settings", function()
				animaciones(nil, true); menu_pops(LISTAS.ROMS[LISTAS.INDICE]) end)
		end
		-- Este juego existe en las dos formas: una linea para elegir con cual arranca.
		-- Solo aparece cuando de verdad hay las dos, para no ofrecer una eleccion que
		-- no lo es.
		local ps1_clave = ps1_key(LISTAS.ROMS[LISTAS.INDICE])
		if PS1_ALT_EMBER ~= nil and PS1_ALT_EMBER[ps1_clave] ~= nil
		   and string.lower(string.sub(LISTAS.ROMS[LISTAS.INDICE], -4)) ~= ".emb" then
			ps1_cfg_load()
			anadir("", function() end)
			local idx_ps1 = #etiquetas
			local function et_ps1()
				if PS1_GAMES[ps1_clave] == "ember" then
					return "Play with: Ember  (".. PS1_ALT_EMBER[ps1_clave] ..")"
				end
				return "Play with: POPStarter"
			end
			etiquetas[idx_ps1] = et_ps1()
			acciones[idx_ps1] = function()
				local antes = PS1_GAMES[ps1_clave] or "pops"
				if PS1_GAMES[ps1_clave] == "ember" then
					PS1_GAMES[ps1_clave] = nil
				else
					PS1_GAMES[ps1_clave] = "ember"
				end
				ps1_cfg_save()
				log_event("SET", "PS1 backend for ".. ps1_clave ..": ".. antes .." -> "
					.. (PS1_GAMES[ps1_clave] or "pops"))
			end
		end
	elseif LISTAS.IDENTIDAD == 15 then
		if string.lower(string.sub(LISTAS.ROMS[LISTAS.INDICE], -4)) ~= ".elf" then
			anadir("PS2 settings", function()
				animaciones(nil, true); menu_neutrino(LISTAS.ROMS[LISTAS.INDICE]) end)
		end
	end

	-- Lanzar. Todo lo que hay que decidir antes de arrancar una ISO de PS2 -- tarjeta
	-- de memoria, fichero VMC y lanzador -- vive en el menu de lanzamiento, que es el
	-- mismo que abre CRUZ desde la lista.
	--
	-- Aqui habia ademas una linea "VMC" y otra "How to launch". Eran la misma decision
	-- dicha en dos sitios, cada uno con su forma de guardarla, y ninguno de los dos
	-- aparecia al lanzar el juego: se elegia a ciegas y se descubria despues.
	if LISTAS.IDENTIDAD == 15
	   and string.lower(string.sub(LISTAS.ROMS[LISTAS.INDICE], -4)) == ".iso" then
		anadir("Launch this game...", function() run_game() end)
	end

	-- El borrado va en ultimo lugar, lejos del cursor al abrir el menu.
	if current_game_path() ~= nil then
		anadir("Delete this game", delete_current_game)
	end

	if #etiquetas == 0 then return end

	local sel, abierto = 1, true
	JOYSTICK_LIMITE = control_FPS(1)
	while abierto do
		CONTROL.FPS = Screen.getFPS(1)
		capturar(JOYSTICK_LIMITE)
		dibujar_fondos()
		-- Panel alto y fijo, no ajustado al numero de entradas.
		--
		-- Antes se calculaba "170 - n*12" arriba y "150 + n*12" abajo, lo que da una
		-- altura de n*24-20 para un contenido que ocupa n*24+12: el texto se salia por
		-- abajo y los botones de respuesta caian encima de la ultima linea. Con un
		-- panel de 56 a 344 todo cabe hasta once entradas, el fondo negro cubre lo que
		-- haya detras, y "select / cancel" quedan abajo y no en medio del texto.
		submenu_selector(etiquetas, sel,
			"-".. NOMBRE_VISIBLE(LISTAS.IDENTIDAD, LISTAS.ROMS[LISTAS.INDICE], 1) .."-",
			56, 344, true, CONTROL.ANCHO // 2,
			{TEXT_GEN[5], TEXT_GEN[6]}, true, false, {}, nil)
		refrescar(false)

		if Pads.check(PAD, PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_EJECUTAR, 1, false, nil)
			abierto = false
			JOYSTICK_LIMITE = control_FPS(1)
			acciones[sel]()
		elseif (Pads.check(PAD, PAD_TRIANGLE) or Pads.check(PAD, PAD_CIRCLE))
		       and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_CANCELAR, 1, false, nil)
			abierto = false
		elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_MOVER, 1, false, nil)
			sel = cambiar_valor(sel, 1, #etiquetas, 1, false)
			JOYSTICK_LIMITE = control_FPS(1)
		elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_MOVER, 1, false, nil)
			sel = cambiar_valor(sel, 1, #etiquetas, 1, true)
			JOYSTICK_LIMITE = control_FPS(1)
		end
	end
	JOYSTICK_LIMITE = control_FPS(1)
end

--- Ruta REAL del fichero del juego seleccionado, para poder borrarlo. ----------------
--- Cada sistema guarda su origen de forma distinta, de ahi el reparto.
--- Devuelve nil cuando no se puede establecer con certeza: mas vale no ofrecer el
--- borrado que borrar el fichero equivocado.
function current_game_path()
    local identidad = LISTAS.IDENTIDAD
    local nombre = LISTAS.ROMS[LISTAS.INDICE]
    if nombre == nil then return nil end

    if identidad == 13 then
        -- APPS: la lista solo guarda el nombre, la ruta esta aparte.
        if LISTAS.DIR_FULL_APP ~= nil then return LISTAS.DIR_FULL_APP[LISTAS.INDICE] end
        return nil
    end

    local clave = tostring(identidad) .."|".. nombre
    if ORIGEN_DIR ~= nil and ORIGEN_DIR[clave] ~= nil then
        return ORIGEN_DIR[clave] .. nombre
    end
    if identidad <= 12 then
        local dir_sistemas = {"Sega Megadrive"; "Sega Master System"; "Sega Game Gear";
        "Nintendo Famicom"; "Nintendo Game Boy"; "Nintendo Game Boy Color";
        "Nintendo Game Boy Advance"; "Atari 2600"; "Atari Lynx"; "Sega SG-1000";
        "Neo Geo Pocket"; "Nintendo Super Famicom";}
        return RUTA_ROM(identidad, dir_sistemas[identidad], nombre)
    end
    return nil
end

--- Borrar el juego seleccionado, con confirmacion. -----------------------------------
--- SELECT + CUADRADO en la lista. Se muestra la ruta COMPLETA antes de preguntar: es
--- la unica forma de que el usuario vea que se va a borrar el fichero que cree, y no
--- otro con el mismo nombre en otra unidad.
--- La respuesta por defecto es NO, y se exige mantener SELECT: un borrado no debe
--- poder ocurrir por un boton pulsado sin querer.
function delete_current_game()
    local nombre = LISTAS.ROMS[LISTAS.INDICE]
    if nombre == nil then return false end
    local ruta = current_game_path()

    local titulo = "Delete this game?"
    local lineas = {}
    if ruta == nil then
        titulo = "Cannot delete"
        lineas = {NOMBRE_VISIBLE(LISTAS.IDENTIDAD, nombre, 1),
                  "the file location is not known for this system"}
    else
        lineas = {NOMBRE_VISIBLE(LISTAS.IDENTIDAD, nombre, 1), salida_texto_dir(ruta, true)}
        local tam = ROM_TAMANO(ruta)
        if tam ~= nil then
            lineas[#lineas + 1] = string.format("%.2f GB - this cannot be undone",
                                                tam / (1024 * 1024 * 1024))
        end
    end

    local confirmar, salir = false, false
    JOYSTICK_LIMITE = control_FPS(1)
    while salir == false do
        CONTROL.FPS = Screen.getFPS(1)
        capturar(JOYSTICK_LIMITE)
        dibujar_fondos()
        local respuestas = {"DELETE", "cancel"}
        if ruta == nil then respuestas = {" ", "cancel"} end
        submenu_selector(lineas, nil, "-".. titulo .."-", 96, 300, true,
                         CONTROL.ANCHO // 2, respuestas, false, false, {}, nil)
        refrescar(false)
        -- CUADRADO para confirmar, no CRUZ: CRUZ es la tecla con la que se ha
        -- llegado hasta aqui desde el menu, y dejarla confirmar convertiria dos
        -- pulsaciones seguidas en un borrado.
        if ruta ~= nil and Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
            confirmar, salir = true, true
        elseif Pads.check(PAD, PAD_TRIANGLE) or Pads.check(PAD, PAD_CIRCLE) then
            salir = true
        end
    end
    JOYSTICK_LIMITE = control_FPS(1)
    if confirmar == false then
        repro_sfx(S_CANCELAR, 1, false, nil)
        return false
    end

    local ok = pcall(System.removeFile, ruta)
    ok = ok and (doesFileExist(ruta) == false)
    boot_log("BORRA  ".. tostring(ruta) .." -> ".. tostring(ok))
    boot_flush()
    if ok == false then
        repro_sfx(S_CANCELAR, 1, false, nil)
        return false
    end
    repro_sfx(S_EJECUTAR, 1, false, nil)

    -- Que el juego desaparezca de la lista sin tener que reiniciar. El indice puede
    -- quedar mas alla del final si era el ultimo.
    media_indice_olvidar()
    CORES_CACHE = {}
    recargar_una(LISTAS.IDENTIDAD)
    LISTAS.ROMS = PRE_CARGADAS[LISTAS.IDENTIDAD]
    if LISTAS.INDICE > #LISTAS.ROMS then LISTAS.INDICE = #LISTAS.ROMS end
    if LISTAS.INDICE < 1 then LISTAS.INDICE = 1 end
    indices_extras()
    return true
end

--- Mostrar selector de aplicaciones alternativas. --------------------------------------
function alt_run(identidad)
	local actual = System.currentDirectory()
	local default_text = {"PicoDrive/RetroArch v1.19.1"; " "; " "; "FCEultra/RetroArch v1.19.1"; "Gambatte/RetroArch v1.20.0"; "Gambatte/RetroArch v1.20.0";
	"gpSP/RetroArch v1.20.0"; " "; " "; " "; " "; "Snes9x 2002/RetroArch v1.20.0"; "wLaunchELF ISR v4.43x"; " "; "Neutrino v1.8.0-55-g7f85091";};
	local alt_text = {"PicoDrive/RetroArch v1.15.0"; " "; " "; "QuickNES/RetroArch v1.21.0"; "TGB Dual/RetroArch v1.19.1"; "TGB Dual/RetroArch v1.19.1";
	" "; " "; " "; " "; " "; " "; "Enceladus"; " "; "OPL";};
	local run, selec_alt, pregunta = nil, 1, true
	JOYSTICK_LIMITE = control_FPS(1)-20
	if (identidad == 15 and string.lower(string.sub(LISTAS.ROMS[LISTAS.INDICE], -4)) ~= ".iso") then
		run, pregunta = false, false
	end
	while pregunta do
		CONTROL.FPS = Screen.getFPS(1)
		capturar(JOYSTICK_LIMITE)
		dibujar_fondos()
		if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true and OPCIONES.SCREENSHOT_BACK_ON == 1 then
			Graphics.drawScaleImage(LISTAS.SCREENSHOT, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F, Color.new(128, 128, 128, OPCIONES.SCREENSHOT_BACK_TR))
		end
		local lista_resp = {TEXT_M_PRI[12], TEXT_GEN[4]}
		local submenu_lista = {default_text[identidad], alt_text[identidad]}
		if identidad == 15 and selec_alt == 1 and Pads.check(PAD, PAD_CIRCLE) then
			submenu_lista[1] = submenu_lista[1] .." ".. TEXT_M_CON[55]
		end
		submenu_selector(submenu_lista, selec_alt, TEXT_M_CON[67], 160, 247, true, CONTROL.ANCHO//2, lista_resp, false, false, {}, nil)
		if Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_EJECUTAR, 1, false, nil)
			if selec_alt == 2 then
				run = true
			else
				run = false
			end
			JOYSTICK_LIMITE = control_FPS(1)
			pregunta = false
		elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90 or Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90 or Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_MOVER, 1, false, nil)
			if (Pads.check(PAD, PAD_UP) or Left_Y <= -90 or Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
				selec_alt = cambiar_valor(selec_alt, 1, 2, 1, false)
			elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90 or Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
				selec_alt = cambiar_valor(selec_alt, 1, 2, 1, true)
			end
			JOYSTICK_LIMITE = control_FPS(1)
		elseif Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_CANCELAR, 1, false, nil)
			JOYSTICK_LIMITE = control_FPS(1)-10
			run = nil
			pregunta = false
		end
		refrescar(false)
	end

	-- Buscar y seleccionar versiones de OPL. -------------------------------------------
	if run == true and identidad == 15 then
		local encontrados, externo = {}, false
		if not string.match(string.lower(OPCIONES.OPL_ELF), "/opl/") and doesFileExist(OPCIONES.OPL_ELF) then
			table.insert(encontrados, salida_texto_dir(OPCIONES.OPL_ELF, true) .." ".. TEXT_M_CON[69])
			externo = true
		end
		local buscar_versiones_opl = System.listDirectory(actual .."/OPL")
		if buscar_versiones_opl ~= nil then
			for contador = 1, #buscar_versiones_opl do
				if buscar_versiones_opl[contador].directory == false and string.lower(string.sub(buscar_versiones_opl[contador].name, -4)) == ".elf" then
					table.insert(encontrados, buscar_versiones_opl[contador].name)
				end
			end
		end
		local selec_opl = 1
		if (#encontrados >= 2) or (externo == false and #encontrados == 1 and not string.match(string.lower(encontrados[1]), "opnps2ld%.elf")) then
			local pregunta = true
			JOYSTICK_LIMITE = control_FPS(1)-20
			while pregunta do
				CONTROL.FPS = Screen.getFPS(1)
				capturar(JOYSTICK_LIMITE)
				dibujar_fondos()
				if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true and OPCIONES.SCREENSHOT_BACK_ON == 1 then
					Graphics.drawScaleImage(LISTAS.SCREENSHOT, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F, Color.new(128, 128, 128, OPCIONES.SCREENSHOT_BACK_TR))
				end
				local lista_resp = {TEXT_M_PRI[12], TEXT_GEN[4]}
				local submenu_lista = {encontrados[selec_opl]}
				submenu_selector(submenu_lista, nil, TEXT_M_CON[68], 160, 223, true, CONTROL.ANCHO//2, lista_resp, true, false, {}, nil)
				refrescar(false)
				if Pads.check(PAD, PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
					repro_sfx(S_EJECUTAR, 1, false, nil)
					if (selec_opl ~= 1 and externo == true) or externo == false then
						OPCIONES.OPL_ELF = actual .."/OPL/".. encontrados[selec_opl]
					end
					pregunta = false
				elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90 or Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90 or Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and CONTROL.JOYSTICK_ON == false then
					repro_sfx(S_MOVER, 1, false, nil)
					if (Pads.check(PAD, PAD_UP) or Left_Y <= -90 or Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
						selec_opl = cambiar_valor(selec_opl, 1, #encontrados, 1, false)
					elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90 or Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
						selec_opl = cambiar_valor(selec_opl, 1, #encontrados, 1, true)
					end
					JOYSTICK_LIMITE = control_FPS(1)
				elseif Pads.check(PAD, PAD_CIRCLE) and CONTROL.JOYSTICK_ON == false then
					repro_sfx(S_CANCELAR, 1, false, nil)
					JOYSTICK_LIMITE = control_FPS(1)-10
					run = nil
					pregunta = false
				end
			end
		elseif #encontrados == 1 and string.match(string.lower(encontrados[1]), "opnps2ld%.elf") and externo == false then
			OPCIONES.OPL_ELF = actual .."/OPL/".. encontrados[1]
		end
	end
	return run
end

--- Crear archivo "LAUNCHELF.CNF" para lanzar aplicaciones con WLE. ---------------------
function app_alt(salida)
	local actual = System.currentDirectory()
	if doesFileExist(actual .."/uLaunchELF/LAUNCHELF.CNF") then
		System.removeFile(actual .."/uLaunchELF/LAUNCHELF.CNF")
	end
	local apps_l = LISTAS.DIR_FULL_APP[LISTAS.INDICE]
	local title_app_l = "Prism"
	if LISTAS.ROMS[LISTAS.INDICE] ~= nil then
		title_app_l = string.sub(LISTAS.ROMS[LISTAS.INDICE], 1, -CONTROL.EXTENSION)
	end
	if OPCIONES.APPS_MENU_FULL_PATH == 1 and LISTAS.ROMS[LISTAS.INDICE] ~= nil then
		title_app_l = salida_texto_dir(string.sub(LISTAS.ROMS[LISTAS.INDICE], 1, -CONTROL.EXTENSION), true)
	end
	if salida == true then
		apps_l = OPCIONES.SALIDA_RETROLANCHER
		title_app_l = string.sub(salida_texto_dir(OPCIONES.SALIDA_RETROLANCHER, true), 1, -CONTROL.EXTENSION)
	elseif salida == nil then
		apps_l = actual .."/Prism.elf"
		title_app_l = "Prism"
	end
	local config_wlc = {"CNF_version = 3"; "LK_auto_E1 = ".. apps_l; "LK_Circle_E1 = ".. actual .."/Prism.elf"; "LK_Cross_E1 = ".. apps_l;
	"LK_Square_E1 = MISC/About uLE"; "LK_Triangle_E1 = MISC/PS2Browser"; "LK_L1_E1 = "; "LK_R1_E1 = "; "LK_L2_E1 = ";
	"LK_R2_E1 = "; "LK_L3_E1 = "; "LK_R3_E1 = "; "LK_Start_E1 = "; "LK_Select_E1 = "; "LK_Left_E1 = "; "LK_Right_E1 = ";
	"Misc = MISC/"; "Misc_PS2Disc = PS2Disc"; "Misc_FileBrowser = FileBrowser"; "Misc_PS2Browser = PS2Browser";
	"Misc_PS2Net = PS2Net"; "Misc_PS2PowerOff = PS2PowerOff"; "Misc_HddManager = HddManager"; "Misc_TextEditor = TextEditor";
	"Misc_JpgViewer = JpgViewer"; "Misc_Configure = Configure"; "Misc_Load_CNFprev = Load CNF--"; "Misc_Load_CNFnext = Load CNF++";
	"Misc_Set_CNF_Path = Set CNF_Path"; "Misc_Load_CNF = Load CNF"; "Misc_ShowFont = ShowFont"; "Misc_Debug_Info = Debug Info";
	"Misc_About_uLE = About uLE"; "Misc_Show_Build_Info = BuildInfo"; "Misc_OSDSYS = OSDSYS"; "GUI_Col_1_ABGR = 00A04000";
	"GUI_Col_2_ABGR = 00FFFFFF"; "GUI_Col_3_ABGR = 00FFFFFF"; "GUI_Col_4_ABGR = 00FFA0A0"; "GUI_Col_5_ABGR = 0000FFFF";
	"GUI_Col_6_ABGR = 0000FF00"; "GUI_Col_7_ABGR = 00404040"; "GUI_Col_8_ABGR = 00808080"; "SKIN_FILE = "; "GUI_SKIN_FILE = ";
	"SKIN_Brightness = 50"; "TV_mode = 0"; "Screen_Offset_X = 0"; "Screen_Offset_Y = 0"; "Popup_Opaque = 1"; "Menu_Frame = 0";
	"Show_Menu = 0"; "LK_auto_Timer = 0"; "Menu_Hide_Paths = 1"; "Menu_Pages = 1"; "GUI_Swap_Keys = 0"; "NET_HOSTwrite = 0";
	"Menu_Title = Prism"; "Init_Delay = 0"; "USBKBD_USED = 0"; "USBKBD_FILE = "; "KBDMAP_FILE = "; "Menu_Show_Titles = 1";
	"PathPad_Lock = 0"; "CNF_Path = "; "LANG_FILE = "; "FONT_FILE = "; "JpgView_Timer = 5"; "JpgView_Trans = 2"; "JpgView_Full = 0";
	"PSU_HugeNames = 0"; "PSU_DateNames = 0"; "PSU_NoOverwrite = 0"; "FB_NoIcons = 0"; "LK_Circle_Title = Prism";
	"LK_Cross_Title = ".. title_app_l; "LK_Square_Title = About uLE"; "PathPad_Lock = 0";};
	local LCHELF_COF = ""
	for crear = 1, #config_wlc do
		LCHELF_COF = LCHELF_COF .. config_wlc[crear] .."\r\n"
	end
	local LCHELF = System.openFile(actual .."/uLaunchELF/LAUNCHELF.CNF", FCREATE)
	System.writeFile(LCHELF, LCHELF_COF, string.len(LCHELF_COF))
	System.closeFile(LCHELF)
end
