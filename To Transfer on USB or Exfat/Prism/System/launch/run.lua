-- Prism PS2 Launcher - launch/run.lua
-- Launching a game: core choice, RetroArch preparation on the shuttle, PS1, PS2, apps.
-- Split from the original funciones.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Functions are globals; this file only defines them. Loaded by System/system.lua.

--- Ejecuta las ISO de PlayStation 2. ---------------------------------------------------
function ejecutar_iso(nombre)
	local actual = System.currentDirectory()
	local device = salida_texto_dir(actual, nil)
	-- Cargar configuraciones de PS2. ---------------------------------------------------
	local ps2_config = load_ps2_cfg(nombre)
	local vmc, modos, GSM, soporte = nil, nil, nil, nil

	-- Cargar configuraciones de "VMC". -------------------------------------------------
	if ps2_config[1] ~= nil and string.match(ps2_config[1], "-mc%d=.+") then
		-- El ".vmcd" de este menu ya no se lee: la tarjeta sale de VMC.cfg, que es el
		-- unico sitio donde se decide. Un fichero que sobrevive de antes no debe poder
		-- imponer una tarjeta que el menu del juego no muestra.
		vmc = nil
	else
		vmc = nil
	end

	-- Cargar modos de compatibilidad. --------------------------------------------------
	if ps2_config[2] ~= nil and string.match(ps2_config[2], "-gc=%d+") then
		modos = ps2_config[2]
	else
		modos = nil
	end

	-- Cargar configuraciones de "GSM". -------------------------------------------------
	if ps2_config[3] ~= nil and string.match(ps2_config[3], "-gsm=.+") then
		GSM = ps2_config[3]
	else
		GSM = nil
	end

	-- Cargar soporte de medios. --------------------------------------------------------
	if ps2_config[4] ~= nil and string.match(ps2_config[4], "1") then
		soporte = "-net"
	elseif ps2_config[4] ~= nil and string.match(ps2_config[4], "2") then
		soporte = "-hdd"
	else
		soporte = nil
	end

	-- Preparar comandos para ejecutar el juego. ----------------------------------------
	if OPCIONES.PREGUNTAR_PS2 == false then
		-- Verificar GSM. ---------------------------------------------------------------
		if GSM == nil then
			GSM = "-gsm="
		end

		-- Definir el directorio donde se encuentra el juego. ---------------------------
		local selector_device = 1
		-- La ISO puede estar en el USB o en el disco interno: resolver la raiz real. --
		local raiz_iso = RAIZ("/Roms/ps2-isos/".. nombre)
		local name_device = {raiz_iso, device, "mmce:"}
		local selector_dir = 1
		local dir_iso = {"/Roms/ps2-isos/", "/DVD/", "/CD/"}
		if doesFileExist(raiz_iso .."/Roms/ps2-isos/".. nombre) then
			selector_dir = 1
			selector_device = 1
		elseif doesFileExist(device .."/DVD/".. nombre) then
			selector_dir = 2
			selector_device = 2
		elseif doesFileExist(device .."/CD/".. nombre) then
			selector_dir = 3
			selector_device = 2
		end

		-- Definir el medio desde donde se lanzará el juego. ----------------------------
		local nombre_final = nombre
		local selector_bsd = 1
		local name_bsd = {"usb", "mx4sio", "ata", "mmce", "udpbd"}
		if string.lower(string.sub(nombre, -4)) == ".mx4" then
			nombre_final = string.sub(nombre, 1, -5) ..".iso"
			selector_bsd = 2
		elseif string.lower(string.sub(nombre, -4)) == ".hdd" then
			nombre_final = string.sub(nombre, 1, -5) ..".iso"
			selector_bsd = 3
		elseif string.lower(string.sub(nombre, -4)) == ".mmc" then
			nombre_final = string.sub(nombre, 1, -5) ..".iso"
			selector_bsd = 4
			selector_device = 3
		elseif string.lower(string.sub(nombre, -4)) == ".udp" then
			nombre_final = string.sub(nombre, 1, -5) ..".iso"
			selector_bsd = 5
		end
		if selector_bsd ~= 1 and vmc ~= nil then
			vmc = string.sub(vmc, 1, -5) .. ".bin"
		end
		if (soporte == "-net" and selector_bsd == 3) or (soporte == "-hdd" and selector_bsd == 5) then
			name_bsd[selector_bsd] = name_bsd[selector_bsd] .. soporte
		end

		-- Si la ISO esta en el disco interno exFAT, forzar el driver ATA. -------------
		if selector_device == 1 and ES_RAIZ_ATA(raiz_iso) then
			selector_bsd = 3
			if string.lower(string.sub(nombre_final, -4)) ~= ".iso" then
				nombre_final = string.sub(nombre_final, 1, -5) ..".iso"
			end
		end

		-- Lanzar el juego. -------------------------------------------------------------
		local directorio_iso = name_device[selector_device] .. dir_iso[selector_dir]
		-- Si el scan memorizo el directorio real (DVD/CD de una unidad ATA, etc.),
		-- tiene prioridad sobre la deduccion por device.
		if ORIGEN_DIR ~= nil and ORIGEN_DIR["15|".. nombre] ~= nil then
			directorio_iso = ORIGEN_DIR["15|".. nombre]
			if ES_RAIZ_ATA(directorio_iso) then selector_bsd = 3 end
		end
		-- El nombre REAL de la unidad, del lado de Enceladus, ANTES de reescribirlo.
		-- Todo lo que este programa cree o copie tiene que usar este; solo los
		-- argumentos que se le pasan a Neutrino llevan el nombre reescrito.
		local unidad_real = "mass:"
		local pfx_real = string.find(directorio_iso, ":", 1, true)
		if pfx_real ~= nil then unidad_real = string.sub(directorio_iso, 1, pfx_real) end

		-- Con "-bsd=ata" Neutrino solo carga ata_bd: el disco interno es la UNICA
		-- unidad de bloque y se monta como "mass:". Hay que reescribir el prefijo.
		if selector_bsd == 3 then
			local pfx = string.find(directorio_iso, ":", 1, true)
			if pfx ~= nil then directorio_iso = "mass:".. string.sub(directorio_iso, pfx+1) end
		end

		-- VMC automatica por juego, salvo que ya haya una tarjeta manual fijada.
		--
		-- Aqui estaba el fallo que devolvia al menu de la PS2. La tarjeta se creaba
		-- con el prefijo YA reescrito, "mass:", pero quien la crea es este programa,
		-- bajo Enceladus, donde "mass:" es el PRIMER dispositivo BDM -- la llave USB.
		-- Resultado: los 8 MB de la tarjeta se escribian en la llave (de ahi que
		-- parpadeara), y a Neutrino se le pasaba "-mc0=mass:/VMC/..." que con
		-- -bsd=ata apunta al disco interno, donde el fichero no existe. Neutrino no
		-- podia abrir la tarjeta y salia.
		-- Se crea en la unidad real y solo despues se reescribe el prefijo.
		local vmc_auto = nil
		if vmc == nil then
			vmc = vmc_auto(nombre, unidad_real)
			if vmc ~= nil and selector_bsd == 3 then
				local pv = string.find(vmc, ":", 1, true)
				if pv ~= nil then vmc = "-mc0=mass:".. string.sub(vmc, pv+1) end
			end
			vmc_auto = vmc
		end
		log_lanzamiento("PS2  Neutrino", {
			"juego        : ".. tostring(nombre),
			"iso final    : ".. tostring(nombre_final),
			"directorio   : ".. tostring(directorio_iso),
			"-bsd=        : ".. tostring(name_bsd[selector_bsd]),
			"desde disco interno (ATA) : ".. tostring(ES_ATA(15, nombre)),
			"",
			log_existe("neutrino.elf", actual .."/Neutrino/neutrino.elf"),
			"",
			"argumento -dvd= : ".. tostring(directorio_iso) .. tostring(nombre_final),
			"VMC por juego   : ".. tostring(vmc_auto) .."  (ID: ".. tostring(vmc_id(nombre)) ..")",
			"NOTA: con -bsd=ata el disco interno es la unica unidad y Neutrino la ve",
			"como mass:, de ahi la reescritura del prefijo.",
		})
		if modos == nil and vmc == nil then
			if Pads.check(PAD, PAD_CIRCLE) == false then
				System.loadELF(actual .."/Neutrino/neutrino.elf", 0, GSM, "-bsd=".. name_bsd[selector_bsd], "-dvd=".. directorio_iso .. nombre_final)
			else
				System.loadELF(actual .."/Neutrino/neutrino.elf", 0, "-dbc", GSM, "-bsd=".. name_bsd[selector_bsd], "-dvd=".. directorio_iso .. nombre_final)
			end
		elseif modos == nil and vmc ~= nil then
			if Pads.check(PAD, PAD_CIRCLE) == false then
				System.loadELF(actual .."/Neutrino/neutrino.elf", 0, vmc, GSM, "-bsd=".. name_bsd[selector_bsd], "-dvd=".. directorio_iso .. nombre_final)
			else
				System.loadELF(actual .."/Neutrino/neutrino.elf", 0, "-dbc", vmc, GSM, "-bsd=".. name_bsd[selector_bsd], "-dvd=".. directorio_iso .. nombre_final)
			end
		elseif modos ~= nil and vmc == nil then
			if Pads.check(PAD, PAD_CIRCLE) == false then
				System.loadELF(actual .."/Neutrino/neutrino.elf", 0, modos, GSM, "-bsd=".. name_bsd[selector_bsd], "-dvd=".. directorio_iso .. nombre_final)
			else
				System.loadELF(actual .."/Neutrino/neutrino.elf", 0, "-dbc", modos, GSM, "-bsd=".. name_bsd[selector_bsd], "-dvd=".. directorio_iso .. nombre_final)
			end
		elseif modos ~= nil and vmc ~= nil then
			if Pads.check(PAD, PAD_CIRCLE) == false then
				System.loadELF(actual .."/Neutrino/neutrino.elf", 0, vmc, modos, GSM, "-bsd=".. name_bsd[selector_bsd], "-dvd=".. directorio_iso .. nombre_final)
			else
				System.loadELF(actual .."/Neutrino/neutrino.elf", 0, "-dbc", vmc, modos, GSM, "-bsd=".. name_bsd[selector_bsd], "-dvd=".. directorio_iso .. nombre_final)
			end
		end

	-- Devuelve las configuraciones encontradas al menú de configuración de PS2. --------
	elseif OPCIONES.PREGUNTAR_PS2 == true then
		return vmc, modos, GSM, soporte
	end
end

--- Cores compatibles con un sistema, en cache: leer decenas de ".info" en cada
--- lanzamiento seria lento, y su contenido no cambia mientras el programa corre.
CORES_CACHE = {}

--- Selector de core de RetroArch. ------------------------------------------------------
--- Se muestra al lanzar, con el core previsto para el sistema ya seleccionado, y SOLO
--- si hay mas de un candidato: si el sistema no tiene alternativa no estorba a nadie.
--- La lista se filtra por plataforma cruzando las extensiones reales del sistema con
--- las que cada core declara en "LibretroPS2Files/info/<core>.info".
--- Devuelve la ruta elegida, o nil si se cancela.
--- Los cores que sirven para un sistema, en la instalacion MAESTRA. -------------------
--- Maestra y no la de la llave: la llave solo lleva el core del juego en curso, asi que
--- preguntarle que hay disponible responde siempre "uno". Aqui se responde con los
--- sesenta del disco, filtrados por las extensiones que cada uno declara en su ".info".
--- Devuelve dos tablas paralelas: rutas y nombres para mostrar.
function system_cores(identidad, ruta_defecto)
	local cache = CORES_CACHE[identidad]
	if cache ~= nil then return cache.rutas, cache.nombres end

	local rutas, nombres, vistos = {}, {}, {}
	local function anadir(ruta)
		local n = nombre_fichero(ruta)
		if n == "" or n == " " then return end
		if vistos[string.lower(n)] ~= nil then return end
		if doesFileExist(ruta) == false then return end
		vistos[string.lower(n)] = true
		table.insert(rutas, ruta)
		table.insert(nombres, string.sub(n, 1, -5))
	end

	anadir(ruta_defecto)
	local dir_ra = libretro_master_path()
	if dir_ra ~= nil then
		local dir = dir_ra .."/cores"
		local c = System.listDirectory(dir)
		if c ~= nil then
			for j = 1, #c do
				if c[j].directory == false and string.lower(string.sub(c[j].name, -4)) == ".elf"
				   and CORE_SIRVE(dir .."/".. c[j].name, identidad) then
					anadir(dir .."/".. c[j].name)
				end
			end
		end
	end
	CORES_CACHE[identidad] = {rutas = rutas, nombres = nombres}
	return rutas, nombres
end

function pick_core(ruta_defecto, identidad)
	local rutas, nombres = system_cores(identidad, ruta_defecto)
	-- Sin alternativas reales no hay nada que preguntar. Pero "el unico que hay" y "el
	-- que venia por defecto" no son lo mismo: "ruta_defecto" es un nombre de fichero a
	-- secas cuando RUTA_CORE no ha sabido resolverlo, y devolverlo entonces era mandar
	-- a lanzar un ELF que no existe. Si hay exactamente uno, se usa ESE.
	if #rutas == 1 then return rutas[1] end
	if #rutas == 0 then return ruta_defecto end

	-- La lista puede tener decenas de entradas y el bandeau no se desplaza solo:
	-- se muestra una ventana de siete alrededor del cursor.
	local VENTANA = 7
	local sel, elegir = 1, true
	JOYSTICK_LIMITE = control_FPS(1)-30
	while elegir do
		CONTROL.FPS = Screen.getFPS(1)
		capturar(JOYSTICK_LIMITE)
		dibujar_fondos()

		local ini = sel - (VENTANA // 2)
		if ini < 1 then ini = 1 end
		if ini > #rutas - VENTANA + 1 then ini = #rutas - VENTANA + 1 end
		if ini < 1 then ini = 1 end
		-- Verde = ese core ya esta en la llave, elegirlo no copia nada. Blanco = habra
		-- que copiarlo, y en USB 1.1 un core son varios segundos.
		-- El cursor se marca con una flecha y no solo con el color: desde que un core
		-- ya presente en la llave se pinta en verde, el color ya no dice donde estas.
		local vista, cursor, colores = {}, 1, {}
		for i = ini, ini + VENTANA - 1 do
			if nombres[i] ~= nil then
				local marca = "   "
				if i == sel then marca = ">  " end
				table.insert(vista, marca .. nombres[i])
				if core_on_usb(nombre_fichero(rutas[i])) then
					if COLOR.VERDE_LISTA == nil then COLOR.VERDE_LISTA = Color.new(0, 128, 45) end
					colores[#vista] = COLOR.VERDE_LISTA
				end
				if i == sel then cursor = #vista end
			end
		end
		local extra = #vista - 3
		if extra < 0 then extra = 0 end
		submenu_selector(vista, cursor, "CORE  ".. sel .."/".. #rutas,
			160-(extra*12), 273+(extra*12), true, CONTROL.ANCHO//2,
			{TEXT_GEN[5], TEXT_GEN[6]}, false, false, {}, nil, colores)
		refrescar(false)

		if Pads.check(PAD, PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_EJECUTAR, 1, false, nil)
			return rutas[sel]
		elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90 or Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90 or Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_MOVER, 1, false, nil)
			if (Pads.check(PAD, PAD_UP) or Left_Y <= -90 or Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
				sel = cambiar_valor(sel, 1, #rutas, 1, false)
			else
				sel = cambiar_valor(sel, 1, #rutas, 1, true)
			end
			JOYSTICK_LIMITE = control_FPS(1)
		elseif Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_CANCELAR, 1, false, nil)
			elegir = false
		end
	end
	return nil
end

--- Ejecuta cada juego con su respectiva aplicación. ------------------------------------
function ejecutar_juego(identidad, nombre_juego, alternativo)
	local actual = System.currentDirectory()
	local device = salida_texto_dir(actual, nil)

	-- Ejecutar los sistemas de RetroArch. ----------------------------------------------
	if identidad <= 12 then
		-- Lista de sistemas. -----------------------------------------------------------
		local dir_sistemas = {"Sega Megadrive"; "Sega Master System"; "Sega Game Gear"; "Nintendo Famicom"; "Nintendo Game Boy"; "Nintendo Game Boy Color";
		"Nintendo Game Boy Advance"; "Atari 2600"; "Atari Lynx"; "Sega SG-1000"; "Neo Geo Pocket"; "Nintendo Super Famicom";};

		-- Lista de aplicaciones. -------------------------------------------------------
		local name_cores = {"picodrive_libretro_ps2.elf"; "picodrive_libretro_ps2.elf"; "picodrive_libretro_ps2.elf"; "fceumm_libretro_ps2.elf";
		"gambatte_libretro_ps2.elf"; "gambatte_libretro_ps2.elf"; "gpsp_libretro_ps2.elf"; "stella2014_libretro_ps2.elf"; "handy_libretro_ps2.elf";
		"picodrive_libretro_ps2.elf"; "race_libretro_ps2.elf"; "snes9x2002_libretro_ps2.elf";};

		-- Lista de aplicaciones alternativas. ------------------------------------------
		local name_cores_alt = {"picodrive_libretro_ps2_alt.elf"; " "; " "; "quicknes_libretro_ps2.elf"; "tgbdual_libretro_ps2.elf";
		"tgbdual_libretro_ps2.elf"; " "; " "; " "; " "; " "; " ";};

		-- Ejecutar juego. --------------------------------------------------------------
		-- El orden importa y cada paso se anuncia, porque cuando algo falla aqui lo
		-- unico que se veia era "Games or RetroArch not found", que no dice nada:
		--   1. que cores sirven para este sistema
		--   2. cual se usa
		--   3. esta ya en la llave?
		--   4. si no, se copia
		--   5. se lanza
		guardar()
		local nucleo = name_cores[identidad]
		if alternativo == true then nucleo = name_cores_alt[identidad] end

		-- 1 y 2. Los cores del sistema, y el que se usa. -------------------------------
		launch_step("Checking cores for ".. dir_sistemas[identidad])
		-- En la MAESTRA: es la que tiene todos los cores. La de la llave se consulta
		-- despues, cuando ya se sabe cual hace falta.
		local ruta_core = core_master_path(nucleo, nucleo)
		-- Eleccion de core al lanzar, solo para la ejecucion normal.
		if alternativo ~= true then
			local elegido = pick_core(ruta_core, identidad)
			if elegido == nil then return end
			ruta_core = elegido
		end
		if doesFileExist(ruta_core) == false then
			-- Ni el core por defecto ni ninguna alternativa existen en la instalacion.
			boot_log("LANZA  ningun core para ".. dir_sistemas[identidad] .." (buscado: ".. tostring(nucleo) ..")")
			boot_flush()
			launch_step("No core for ".. dir_sistemas[identidad])
			System.sleep(3)
			return
		end
		launch_step("Core: ".. nombre_fichero(ruta_core))
		black_blur()
		local ruta_rom  = RUTA_ROM(identidad, dir_sistemas[identidad], nombre_juego)
		-- Reglas que el lanzador impone a RetroArch: carpetas de partidas y modo de
		-- video. Se reescriben en cada arranque, asi que no hay forma de que se
		-- queden desfasadas.
		-- Si la instalacion de RetroArch esta en el disco interno, el core no sabra
		-- leerla: se pone en la llave lo que ESTE juego necesita, y nada mas.
		-- 3 y 4. En la llave: comprobar, y copiar solo lo que falte. -------------------
		launch_step("Checking ".. nombre_fichero(ruta_core) .." on USB")
		local base_ra = LIBRETRO_PREPARAR_PARA(nombre_fichero(ruta_core))
		if base_ra ~= nil then ruta_core = RUTA_CORE(nombre_fichero(ruta_core), ruta_core) end
		if doesFileExist(ruta_core) == false then
			boot_log("LANZA  el core no ha llegado a su destino: ".. tostring(ruta_core))
			boot_flush()
			launch_step("Core not ready: ".. nombre_fichero(ruta_core))
			System.sleep(3)
			return
		end
		local lee_ata_core = CORE_LEE_ATA(ruta_core)
		FORZAR_CONF_RETROARCH(OPCIONES.VIDEO_MODE ~= 0, lee_ata_core)
		-- "Bios/" es "system_directory": no hay copia que hacer salvo si el core no
		-- puede leer el disco donde esta.
		BIOS_LIBRETRO(lee_ata_core)
		-- Los cores montan su propia pila de dispositivos, SIN ata_bd: una ROM en el
		-- disco interno exFAT les es invisible. Se transborda a un soporte legible.
		local transbordo = "no hace falta"
		local lee_ata = CORE_LEE_ATA(ruta_core)
		local saves_ida = 0
		if ES_RAIZ_ATA(ruta_rom) and lee_ata == false then
			local consola = CARPETA_DE_RUTA(ruta_rom)
			launch_step("Copying ROM")
			local nueva, donde = ROM_TRANSBORDO(ruta_rom, nombre_juego)
			transbordo = tostring(donde)
			if string.find(tostring(donde), "cache", 1, true) ~= nil then
				launch_replace("ROM already on USB")
				LANZA_VERDE[#LANZA_LINEAS] = true
				launch_paint()
			end
			if nueva ~= nil then
				-- La partida de este juego viaja con la ROM. Sin esto el juego
				-- arrancaria en blanco y machacaria lo guardado en el disco. Son dos
				-- listados -- "Saves/<consola>" y "SaveStates/<consola>" -- y solo se
				-- copian los ficheros que empiezan por el nombre de ESTE juego.
				saves_ida = SAVES_DESPLEGAR(DEV_DE_RUTA(nueva), consola, SIN_EXTENSION(nombre_juego))
				if saves_ida > 0 then
					launch_step("Saves: ".. tostring(saves_ida) .." file(s)")
				end
				ruta_rom = nueva
			end
		elseif ES_RAIZ_ATA(ruta_rom) then
			transbordo = "innecesario: este core lee el disco interno"
		end
		-- El core recibe el juego en argv[1]: Enceladus pone la ruta del ELF en argv[0]
		-- y encadena los argumentos variadicos a partir de argv[1], que es exactamente
		-- lo que lee "frontend_ps2_get_env" para fijar "content_path". Lo que hay que
		-- traducir es el NOMBRE DE LA UNIDAD, porque RetroArch reinicia el IOP y monta
		-- su propia pila, donde los nombres no son los de Enceladus:
		--   ROM en un USB ............ Enceladus "mass0:"  ->  core "mass:"
		--   ROM en el disco interno .. Enceladus "mass0:"  ->  core "ata0:"
		--   ROM en la Memory Card .... "mc0:" en los dos lados, no se toca
		-- El caso del disco interno solo vale si el core lleva el parche ata_bd; si no,
		-- la ROM ya se ha transbordado mas arriba y esta en otra unidad.
		local rom_arg = ruta_rom
		if ES_RAIZ_ATA(ruta_rom) and lee_ata == true then
			rom_arg = RUTA_ATA_CORE(ruta_rom)
		else
			local pos_dev = string.find(ruta_rom, ":", 1, true)
			if pos_dev ~= nil then
				local dev = string.sub(ruta_rom, 1, pos_dev-1)
				-- SOLO para "massN:". Aplicarlo a "mc0:" daria "mc:", y la ROM
				-- transbordada a la Memory Card seria imposible de abrir.
				if string.lower(string.sub(dev, 1, 4)) == "mass" then
					while string.len(dev) > 0 and string.match(string.sub(dev, -1), "%d") ~= nil do
						dev = string.sub(dev, 1, -2)
					end
					rom_arg = dev ..":".. string.sub(ruta_rom, pos_dev+1)
				end
			end
		end
		log_lanzamiento("RETROARCH  ".. dir_sistemas[identidad], {
			"identidad   : ".. tostring(identidad),
			"juego       : ".. tostring(nombre_juego),
			"alternativo : ".. tostring(alternativo),
			"desde disco interno (ATA) : ".. tostring(ES_ATA(identidad, nombre_juego)),
			"",
			log_existe("core", ruta_core),
			log_existe("rom ", ruta_rom),
			"argv[1]     : ".. tostring(rom_arg),
			"",
			"IOP_REBOOT_CORES : ".. tostring(IOP_REBOOT_CORES),
			"core lee ATA    : ".. tostring(lee_ata) .."  (lista CORES_ATA en system.lua)",
			"transbordo      : ".. tostring(transbordo),
			"partidas llevadas : ".. tostring(saves_ida) .."  (vuelven solas al arrancar el lanzador)",
		})
		launch_step("Launching ".. tostring(nombre_juego))
		-- Preferir "raboot.elf" cuando esta disponible: es el bootstrap oficial de
		-- las nightlies, y funciona donde la llamada directa al core falla.
		local raboot = RUTA_RABOOT()
		if raboot ~= nil and PREPARAR_RABOOT(raboot, ruta_core) then
			log_lanzamiento("RETROARCH via raboot  ".. dir_sistemas[identidad], {
				"juego : ".. tostring(nombre_juego),
				"",
				log_existe("raboot", raboot),
				log_existe("core  ", ruta_core),
				log_existe("rom   ", ruta_rom),
				"",
				log_existe("salamander", RUTA_SALAMANDER(raboot)),
				"Verificado por relectura: contiene el core de arriba.",
				"Poner RABOOT_ON a false para volver a la llamada directa.",
			})
			System.loadELF(raboot, IOP_REBOOT_CORES, rom_arg)
		end
		System.loadELF(ruta_core, IOP_REBOOT_CORES, rom_arg)

	-- Ejecutar APPS. -------------------------------------------------------------------
	elseif identidad == 13 then
		guardar()
		black_blur()
		local wle = RUTA_WLE(false)
		if wle ~= nil and alternativo == false then
			app_alt(false)
			log_lanzamiento("APPS  wLaunchELF", {log_existe("elf", wle)})
			System.loadELF(wle, 0, actual .."/uLaunchELF/")
		else
			log_lanzamiento("APPS  ELF externo", {log_existe("elf", LISTAS.DIR_FULL_APP[LISTAS.INDICE])})
			System.loadELF(LISTAS.DIR_FULL_APP[LISTAS.INDICE], 0, salida_texto_dir(LISTAS.DIR_FULL_APP[LISTAS.INDICE], false))
		end

	-- Ejecutar sistema de PlayStation 1. -----------------------------------------------
	elseif identidad == 14 then
		guardar()
		-- Si este juego existe tambien como carpeta de Ember y el usuario lo ha pedido
		-- asi en el menu del juego, se cambia aqui y todo lo de abajo se comporta como
		-- si se hubiera elegido la entrada de Ember. Una sola linea en la lista, dos
		-- maneras de arrancarla.
		if PS1_ALT_EMBER ~= nil and string.lower(string.sub(nombre_juego, -4)) ~= ".emb" then
			ps1_cfg_load()
			local clave = ps1_key(nombre_juego)
			if PS1_GAMES[clave] == "ember" and PS1_ALT_EMBER[clave] ~= nil then
				nombre_juego = PS1_ALT_EMBER[clave] ..".emb"
			end
		end
		local nombre_temp = string.sub(nombre_juego, 1, -5)
		local nombre_temp_2 = nombre_temp
		if string.len(nombre_temp_2) >= 13 and string.match(string.sub(nombre_temp_2, 1, 12), "%a+_%d+%.%d+%.") then
			nombre_temp_2 = string.sub(nombre_temp_2, 13)
		end
		-- Unidad de trabajo de POPStarter: la que tenga el juego en su "POPS/", que no
		-- es forzosamente POPS_RAIZ. El ELF, el .VCD y la tarjeta de memoria deben
		-- compartir unidad, de ahi que todo lo de abajo pase por aqui.
		local pops_u = POPS_DE(nombre_juego)
		-- Misma cautela que con Ember: reiniciar el IOP descarga "ata_bd".
		local reboot_pops = IOP_REBOOT_POPS
		if ES_RAIZ_ATA(pops_u) then reboot_pops = 0 end
		if string.lower(string.sub(nombre_juego, -4)) == ".emb" then
			-- Ember Beta 1. El argumento es el NOMBRE DE LA CARPETA dentro de "games",
			-- no un fichero, y todo lo demas lo resuelve Ember relativo a su propio
			-- ELF. De ahi que no haya que copiar ni ember.elf ni bios.bin a ninguna
			-- parte: la carpeta "Ember" es autocontenida y portatil.
			local carpeta = string.sub(nombre_juego, 1, -5)
			local raiz_emb, dir_juego = ember_game(carpeta)
			if raiz_emb == nil then
				ERROR_DETALLE = detalle_falta("Ember", RAICES[1] .. EMBER_SUB .."/games/",
					{carpeta .."/"})
				return
			end
			-- Reiniciar el IOP se lleva por delante "ata_bd" y con el el disco interno.
			-- Si Ember vive ahi, no se reinicia: dejaria de ver su propia carpeta.
			local reboot_emb = IOP_REBOOT_EMBER
			if ES_RAIZ_ATA(raiz_emb) then reboot_emb = 0 end
			local que = ember_contents(dir_juego)
			log_lanzamiento("PS1  Ember Beta 1", {
				"juego     : ".. tostring(carpeta),
				"carpeta   : ".. tostring(dir_juego),
				"contenido : ".. tostring(que),
				"desde disco interno (ATA) : ".. tostring(ES_RAIZ_ATA(raiz_emb)),
				"",
				log_existe("ember.elf   ", raiz_emb .."/ember.elf"),
				log_existe("bios.bin    ", raiz_emb .."/bios.bin"),
				log_existe("settings.txt", raiz_emb .."/settings.txt"),
				"",
				"argumento : ".. tostring(carpeta) .."  (nombre de la carpeta, no un fichero)",
				"reinicio del IOP : ".. tostring(reboot_emb) .."  (ajuste: ".. tostring(IOP_REBOOT_EMBER) ..")",
			})
			if que == "chd" then
				-- Ember no abre un .chd, y sin aviso el usuario aterriza en el shell de
				-- la BIOS sin saber por que. Descomprimirlo aqui no es una opcion: el
				-- formato v5 lleva el mapa de sectores comprimido en Huffman y los
				-- bloques en zlib/LZMA/FLAC, y son cientos de megas a escribir.
				chd_warning_screen(carpeta)
				return
			end
			black_blur()
			if doesFileExist(actual .."/System/Intros/PS1/intro_ps1.lua") then
				require("System/Intros/PS1/intro_ps1")
				ps1_startup()
			end
			System.loadELF(raiz_emb .."/ember.elf", reboot_emb, raiz_emb .."/", carpeta)
		elseif string.lower(string.sub(nombre_juego, -4)) == ".elf" then
			log_lanzamiento("PS1  ELF en POPS", {log_existe("elf", pops_u .."/POPS/".. nombre_juego)})
			System.loadELF(pops_u .."/POPS/".. nombre_juego, 0, pops_u .."/POPS/")
		elseif VCD_A_POPS(nombre_juego) and doesFileExist(pops_u .."/APPS/".. nombre_temp_2 .."/XX.".. nombre_temp ..".ELF") then
			PARCHE_USB_DELAY(pops_u .."/APPS/".. nombre_temp_2 .."/XX.".. nombre_temp ..".ELF")
			log_lanzamiento("PS1  POPStarter (atajo en APPS)", {
				"juego     : ".. tostring(nombre_juego),
				"unidad    : ".. tostring(pops_u),
				"desde disco interno (ATA) : ".. tostring(ES_ATA(14, nombre_juego)),
				"",
				log_existe("atajo ", pops_u .."/APPS/".. nombre_temp_2 .."/XX.".. nombre_temp ..".ELF"),
				log_existe("vcd   ", pops_u .."/POPS/".. nombre_juego),
				log_existe("iox   ", pops_u .."/POPS/POPS_IOX.PAK"),
				log_existe("ioprp ", pops_u .."/POPS/IOPRP252.IMG"),
				log_existe("POPS.ELF", pops_u .."/POPS/POPS.ELF"),
				log_existe("POPS.PAK", pops_u .."/POPS/POPS.PAK"),
				"",
				POPSTARTER_DRIVERS_MC(),
				"",
				"delay USB en el atajo (byte 0x413, tras el parche) : ".. tostring(LEE_USB_DELAY(pops_u .."/APPS/".. nombre_temp_2 .."/XX.".. nombre_temp ..".ELF")) .."  (ajuste: ".. tostring(POPS_USB_DELAY) ..")",
				"",
				"POPStarter necesita el atajo, el .VCD y su tarjeta de memoria en la",
				"MISMA unidad. En exFAT hacen falta ademas los drivers BDMAssault en",
				"la Memory Card, y no hay constancia de que soporte un disco ATA.",
			})
			black_blur()
			if doesFileExist(actual .."/System/Intros/PS1/intro_ps1.lua") then
				require("System/Intros/PS1/intro_ps1")
				ps1_startup()
			end
				discs_screen(pops_u .."/APPS/".. nombre_temp_2 .."/DISCS.TXT",
					NOMBRE_VISIBLE(14, nombre_juego, 1))
				System.loadELF(pops_u .."/APPS/".. nombre_temp_2 .."/XX.".. nombre_temp ..".ELF", reboot_pops, pops_u .."/APPS/".. nombre_temp_2 .."/", "--nr")
		elseif doesFileExist(pops_u .."/POPS/XX.".. nombre_temp ..".ELF") then
			PARCHE_USB_DELAY(pops_u .."/POPS/XX.".. nombre_temp ..".ELF")
			log_lanzamiento("PS1  POPStarter (atajo en POPS)", {
				"juego     : ".. tostring(nombre_juego),
				"unidad    : ".. tostring(pops_u),
				"desde disco interno (ATA) : ".. tostring(ES_ATA(14, nombre_juego)),
				"",
				log_existe("atajo ", pops_u .."/POPS/XX.".. nombre_temp ..".ELF"),
				log_existe("vcd   ", pops_u .."/POPS/".. nombre_juego),
				log_existe("iox   ", pops_u .."/POPS/POPS_IOX.PAK"),
				log_existe("ioprp ", pops_u .."/POPS/IOPRP252.IMG"),
				log_existe("POPS.ELF", pops_u .."/POPS/POPS.ELF"),
				log_existe("POPS.PAK", pops_u .."/POPS/POPS.PAK"),
				"",
				POPSTARTER_DRIVERS_MC(),
				"",
				"reinicio del IOP : ".. tostring(reboot_pops) .."  (ajuste: ".. tostring(IOP_REBOOT_POPS) ..")",
				"delay USB en el atajo (byte 0x413, tras el parche) : ".. tostring(LEE_USB_DELAY(pops_u .."/POPS/XX.".. nombre_temp ..".ELF")) .."  (ajuste: ".. tostring(POPS_USB_DELAY) ..")",
			})
			black_blur()
			if doesFileExist(actual .."/System/Intros/PS1/intro_ps1.lua") then
				require("System/Intros/PS1/intro_ps1")
				ps1_startup()
			end
				discs_screen(pops_u .."/POPS/".. nombre_temp .."/DISCS.TXT",
					NOMBRE_VISIBLE(14, nombre_juego, 1))
				System.loadELF(pops_u .."/POPS/XX.".. nombre_temp ..".ELF", reboot_pops, pops_u .."/POPS/", "--nr")
		else
			JOYSTICK_LIMITE = control_FPS(1)-30
			local pregunta, selector_dir = true, 1
			while pregunta do
				CONTROL.FPS = Screen.getFPS(1)
				capturar(JOYSTICK_LIMITE)
				dibujar_fondos()
				local submenu_lista = {TEXT_M_PRI[29], TEXT_M_PRI[30]}
				local lista_resp = {TEXT_GEN[5], TEXT_GEN[6]}
				submenu_selector(submenu_lista, selector_dir, "-".. TEXT_M_PRI[28] .."-", 160, 247, true, CONTROL.ANCHO//2, lista_resp, false, false, {}, nil)
				if Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
					repro_sfx(S_EJECUTAR, 1, false, nil)
					submenu_selector({}, nil, TEXT_M_CON[46], 160, 247, true, CONTROL.ANCHO//2, {}, false, true, {}, nil)
					if selector_dir == 1 then
						if doesFileExist(actual .."/POPStarter/POPSTARTER.ELF") then
							System.copyFile(actual .."/POPStarter/POPSTARTER.ELF", pops_u .."/POPS/XX.".. nombre_temp ..".ELF")
						else
							error("No found \"".. actual .."/POPStarter/POPSTARTER.ELF\"")
						end
						ejecutar_juego(14, nombre_juego, false)
					elseif selector_dir == 2 then
						if doesFileExist(actual .."/POPStarter/POPSTARTER.ELF") then
							if System.listDirectory(pops_u .."/APPS") == nil then
								System.createDirectory(pops_u .."/APPS")
							end
							if System.listDirectory(pops_u .."/APPS/".. nombre_temp_2) == nil then
								System.createDirectory(pops_u .."/APPS/".. nombre_temp_2)
							end
							System.copyFile(actual .."/POPStarter/POPSTARTER.ELF", pops_u .."/APPS/".. nombre_temp_2 .."/XX.".. nombre_temp ..".ELF")
							local data_pops = "title=".. nombre_temp_2 .."\r\nboot=XX.".. nombre_temp ..".ELF\r\n"
							local title_create = System.openFile(pops_u .."/APPS/".. nombre_temp_2 .."/title.cfg", FCREATE)
							System.writeFile(title_create, data_pops, string.len(data_pops))
							System.closeFile(title_create)
						else
							error("No found \"".. actual .."/POPStarter/POPSTARTER.ELF\"")
						end
						ejecutar_juego(14, nombre_juego, false)
					end
				elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90 or Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90 or Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and CONTROL.JOYSTICK_ON == false then
					repro_sfx(S_MOVER, 1, false, nil)
					if (Pads.check(PAD, PAD_UP) or Left_Y <= -90 or Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
						selector_dir = cambiar_valor(selector_dir, 1, 2, 1, false)
					elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90 or Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
						selector_dir = cambiar_valor(selector_dir, 1, 2, 1, true)
					end
					JOYSTICK_LIMITE = control_FPS(1)
				elseif Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
					pregunta = false
				end
				refrescar(false)
			end
		end

	-- Ejecutar sistema de PlayStation 2. -----------------------------------------------
	elseif identidad == 15 then
		guardar()
		if OPCIONES.OPL_DIR ~= "RETRO" and alternativo == true then
			local nombre_iso, id_name = id_opl(device .."/".. OPCIONES.OPL_DIR .."/", nombre_juego, true)
			if id_name ~= nil then
				black_blur()
				if doesFileExist(actual .."/System/Intros/PS2/intro_ps2.lua") then
					require("System/Intros/PS2/intro_ps2")
					ps2_startup()
				end
				System.loadELF(OPCIONES.OPL_ELF, 0, nombre_iso, id_name, OPCIONES.OPL_DIR, "bdm")
			else
				ejecutar_juego(15, nombre_juego, false)
			end
		else
			black_blur()
			if string.lower(string.sub(nombre_juego, -4)) == ".elf" then
				log_lanzamiento("PS2  ELF en el lector CD/DVD", {log_existe("elf", "cdfs:/".. string.sub(nombre_juego, 1, 11))})
				System.loadELF("cdfs:/".. string.sub(nombre_juego, 1, 11), 0, "cdfs:/")
			else
				if doesFileExist(actual .."/System/Intros/PS2/intro_ps2.lua") then
					require("System/Intros/PS2/intro_ps2")
					ps2_startup()
				end
				ejecutar_iso(nombre_juego)
			end
		end
	end
end

--- Identidad de cada sistema a partir de su nombre. ------------------------------------
--- Sirve para llegar a ES_ALIAS, que lista TODOS los nombres de carpeta aceptados para
--- ese sistema: "megadrive", pero tambien "genesis" y "md". RetroArch agrupa las
--- partidas por la carpeta del contenido, asi que un juego que este en "Roms/genesis"
--- guarda en "Saves/genesis": hay que barrer todos los alias, no solo el canonico.
--- Antes se agrupaba por core, y limpiar la Megadrive borraba tambien Master System,
--- Game Gear y SG-1000, que comparten PicoDrive. Por carpeta el reparto es exacto.
IDENTIDAD_DE_SISTEMA = {
	["Sega Megadrive"] = 1,  ["Sega Master System"] = 2,  ["Sega Game Gear"] = 3,
	["Nintendo Famicom"] = 4, ["Nintendo Game Boy"] = 5,  ["Nintendo Game Boy Color"] = 6,
	["Nintendo Game Boy Advance"] = 7, ["Atari 2600"] = 8, ["Atari Lynx"] = 9,
	["Sega SG-1000"] = 10,   ["Neo Geo Pocket"] = 11,     ["Nintendo Super Famicom"] = 12,
}

--- Borra los ficheros de un directorio, sin tocar los subdirectorios. -----------------
function BORRAR_FICHEROS(ruta)
	local lista = System.listDirectory(ruta)
	if lista == nil then return end
	for i = 1, #lista do
		if lista[i].directory == false then
			System.removeFile(ruta .."/".. lista[i].name)
		end
	end
end

--- Elimina "Save states" y "Save RAM" (SRM) creados por RetroArch. --------------------
--- Viven en "Saves/<consola>/" y "SaveStates/<consola>/", en la raiz del lanzador.
--- Con "emulador" a nil se barre todo, incluida la raiz de cada uno, que es donde caen
--- las partidas si el usuario desactiva la ordenacion.
function limpiar_retroarch(emulador)
	local actual = System.currentDirectory()
	local carpetas = {"Saves", "SaveStates"}
	local consolas = nil
	if emulador ~= nil then
		local id = IDENTIDAD_DE_SISTEMA[emulador]
		if id ~= nil and ES_ALIAS ~= nil then consolas = ES_ALIAS[id] end
	end
	for c = 1, #carpetas do
		local raiz = actual .."/".. carpetas[c]
		if consolas ~= nil then
			for n = 1, #consolas do
				BORRAR_FICHEROS(raiz .."/".. consolas[n])
			end
		else
			BORRAR_FICHEROS(raiz)
			local lista = System.listDirectory(raiz)
			if lista ~= nil then
				for i = 1, #lista do
					local nom = lista[i].name
					if lista[i].directory == true and nom ~= "." and nom ~= ".." then
						BORRAR_FICHEROS(raiz .."/".. nom)
					end
				end
			end
		end
	end
end

--- Crea los directorios que RetroArch espera encontrar. -------------------------------
--- Todo cuelga de "LibretroPS2Files/retroarch/". "emulador" ya no interviene: la
--- configuracion es unica y RetroArch separa por core, no por sistema.
--- "System.createDirectory" no crea los padres, de ahi el orden de la lista.
function directorios_faltantes(emulador, core)
	local base = RUTA_LIBRETRO()
	if base == nil then return end
	local necesarios = {
		"/retroarch",
		"/retroarch/config",
		"/retroarch/config/remaps",
		"/retroarch/savefiles",
		"/retroarch/savestates",
		"/retroarch/system",
		"/retroarch/logs",
		"/retroarch/temp",
	}
	if core ~= nil and core ~= " " and core ~= "" then
		necesarios[#necesarios + 1] = "/retroarch/config/".. core
		necesarios[#necesarios + 1] = "/retroarch/config/remaps/".. core
	end
	for i = 1, #necesarios do
		if System.listDirectory(base .. necesarios[i]) == nil then
			System.createDirectory(base .. necesarios[i])
		end
	end
end

--- Reinicia la configuracion de RetroArch. -------------------------------------------
--- No hay copia de fabrica que restaurar, y es deliberado: la unica configuracion es
--- "retroarch/retroarch.cfg". Reiniciar es entonces BORRARLO, junto con los ajustes por
--- core. RetroArch se reescribe uno entero con sus propios valores la primera vez que
--- guarda, y FORZAR_CONF_RETROARCH vuelve a imponer encima las claves del lanzador --
--- carpetas, tri de partidas, modo de video -- al lanzar el siguiente juego.
---
--- Lo que se pierde son los ajustes por core que traia el proyecto (relacion de
--- aspecto de la Game Gear, configuracion vertical de la Lynx...). Es el precio de no
--- mantener dos ficheros con el mismo papel, que acaban siempre por no coincidir.
--- "pal" se conserva en la firma por compatibilidad con las llamadas existentes.
function restaurar_conf_retroarch(pal)
	local base = RUTA_LIBRETRO()
	if base == nil then
		boot_log("CONF   LibretroPS2Files no encontrado, nada que reiniciar")
		return false
	end

	local cfg = base .."/retroarch/retroarch.cfg"
	if doesFileExist(cfg) then
		pcall(System.removeFile, cfg)
		boot_log("CONF   borrado ".. cfg .." : RetroArch lo rehara")
	end
	BORRAR_ARBOL(base .."/retroarch/config")

	-- Las carpetas si se recrean: RetroArch no crea las que le faltan, se limita a no
	-- escribir en ellas.
	directorios_faltantes(nil, nil)
	boot_flush()
	return true
end

--- Preparacion de RetroArch en la llave, EN EL MOMENTO DE LANZAR. --------------------
--- Un core oficial no sabe leer el disco interno: al arrancar hace SifIopReset, el IOP
--- se vacia y ese disco deja de existir para el. Su instalacion tiene que estar en un
--- soporte que sobreviva al reset.
---
--- Copiarla entera al arrancar el lanzador era mala idea: 75 MB, y aunque se hiciera
--- de fondo el menu se arrastraba. Y sobre todo era trabajo hecho por adelantado para
--- juegos que quiza no se lanzan nunca.
---
--- Aqui se hace al pulsar sobre un juego, y solo lo que ESE juego necesita: su core,
--- su ".info", y la configuracion. Un megabyte y medio, una vez por core. La segunda
--- vez que se lanza un juego de esa consola ya no hay nada que copiar.
LIBRETRO_AUTO_USB = true
COPIA_TITULO = "Preparing RetroArch on the USB stick"
COPIA_HECHOS = 0
COPIA_TOTAL = 0

--- "fceumm_libretro_ps2.elf" -> "fceumm_libretro.info" -------------------------------
--- El ".info" declara las extensiones que acepta el core, que es lo que decide si se
--- ofrece para un sistema. Sin el, el selector de core se queda vacio.
function CORE_A_INFO(nombre)
	if nombre == nil then return nil end
	if string.len(nombre) < 9 or string.sub(nombre, -8) ~= "_ps2.elf" then return nil end
	return string.sub(nombre, 1, -9) ..".info"
end

--- Pantalla de progreso: fondo negro, letras blancas. -------------------------------
function LIBRETRO_PANTALLA(titulo, linea, hechos, total)
	Screen.clear(COLOR.NEGRO)
	Font.ftPrint(CONTROL.fontARCA, 320, 170 + CONTROL.Y_FIX_PAL, 8, 600, 25, titulo, COLOR.BLANCO)
	Font.ftPrint(CONTROL.fontARCA, 320, 210 + CONTROL.Y_FIX_PAL, 8, 600, 25, linea, COLOR.BLANCO)
	if total ~= nil and total > 0 then
		Font.ftPrint(CONTROL.fontARCA, 320, 260 + CONTROL.Y_FIX_PAL, 8, 600, 25,
			tostring((hechos * 100) // total) .." %    ".. tostring(hechos) .." / ".. tostring(total), COLOR.BLANCO)
	end
	Screen.flip()
end

--- Copia un fichero si falta o si no coincide el tamano. Devuelve true si copio. -----
function COPIA_SI_HACE_FALTA(origen, destino, etiqueta)
	if doesFileExist(origen) == false then return false end
	local a = ROM_TAMANO(origen)
	if doesFileExist(destino) then
		local b = ROM_TAMANO(destino)
		if a ~= nil and a == b then return false end
	end
	COPIA_HECHOS = COPIA_HECHOS + 1
	LIBRETRO_PANTALLA(COPIA_TITULO, etiqueta, COPIA_HECHOS, COPIA_TOTAL)
	pcall(System.copyFile, origen, destino)
	return true
end

--- Deja listo en la llave lo que hace falta para lanzar ESTE core. -------------------
--- Devuelve la carpeta que hay que usar, o nil si no se ha podido preparar nada.
function LIBRETRO_PREPARAR_PARA(nombre_core)
	LIBRETRO_FORZADO = nil
	if LIBRETRO_AUTO_USB ~= true then return RUTA_LIBRETRO() end
	-- El ORIGEN de la copia es la maestra: es la unica que tiene el core que se pide.
	-- Con RUTA_LIBRETRO aqui, en cuanto existia una copia en la llave se copiaba desde
	-- ella hacia ella misma, y el core que faltaba seguia faltando.
	local casa = libretro_master_path()
	if casa == nil then return nil end
	-- Ya esta donde el core sabra leerla: nada que preparar.
	if ES_RAIZ_ATA(casa) == false then return casa end

	-- Destino: una llave USB. La tarjeta de memoria no sirve, son 8 MB.
	local destinos = ROM_DESTINOS()
	local dev = nil
	for i = 1, #destinos do
		if dev == nil and string.lower(string.sub(destinos[i], 1, 4)) == "mass" then
			dev = destinos[i]
		end
	end
	if dev == nil then
		boot_log("RETROARCH  sin llave USB: este juego no puede arrancar.")
		boot_flush()
		LIBRETRO_PANTALLA(COPIA_TITULO, "No USB stick: this game cannot start", 0, nil)
		System.sleep(3)
		return nil
	end

	-- En "<llave>/Prism/LibretroPS2Files", el mismo sitio que en el disco.
	-- Estuvo bajo "TempUSB/" para que RUTA_LIBRETRO no la eligiera como instalacion
	-- maestra -- solo lleva un core -- pero eso ya lo resuelve libretro_master_path,
	-- que reconoce la maestra por estar junto al lanzador.
	local destino = dev .."/".. CARPETA_LANZADOR .."/LibretroPS2Files"

	COPIA_HECHOS = 0
	COPIA_TOTAL = 0

	CREAR_CADENA(dev, CARPETA_LANZADOR .."/LibretroPS2Files")
	CREAR_CADENA(destino, "cores")
	CREAR_CADENA(destino, "info")

	-- TODAS las carpetas que la configuracion nombra. Se crean SIEMPRE y ANTES que
	-- nada, y se comprueba que existan de verdad.
	--
	-- Aqui estuvo la pantalla negra, y es culpa mia. Al quitar la copia del arbol de
	-- "retroarch/" deje la llave con "retroarch.cfg" y "config/" y nada mas. RetroArch
	-- ABRE los ficheros de sus carpetas pero NO crea las carpetas: sin "temp/" -- que
	-- es "cache_directory" -- no puede descomprimir el .zip de la ROM, y muere sin
	-- dibujar. Sin "logs/" tampoco escribe su propio log, que es exactamente por lo
	-- que la carpeta de logs estaba vacia y no habia nada que leer.
	-- Crear un directorio es gratis; no crearlo cuesta un arranque entero.
	local esqueleto = {"retroarch", "retroarch/config", "retroarch/config/remaps",
		"retroarch/system", "retroarch/logs", "retroarch/temp",
		"retroarch/savefiles", "retroarch/savestates", "retroarch/assets",
		"retroarch/cheats", "retroarch/database", "retroarch/database/rdb",
		"retroarch/downloads", "retroarch/overlays", "retroarch/thumbnails",
		"retroarch/playlists", "retroarch/playlists/builtin"}
	local faltan = ""
	for i = 1, #esqueleto do
		CREAR_CADENA(destino, esqueleto[i])
		if System.listDirectory(destino .."/".. esqueleto[i]) == nil then
			faltan = faltan .." ".. esqueleto[i]
		end
	end
	if faltan ~= "" then
		boot_log("RETROARCH  NO se han podido crear:".. faltan)
		boot_flush()
		launch_step("Cannot create folders on USB")
	end

	-- "retroarch.cfg" se MACHACA, sin mirar si coincide. RetroArch reescribe el suyo
	-- cada vez que sale, en la llave: sin esto la copia de la llave se aleja del
	-- fichero del proyecto en cuanto se toca un ajuste desde el menu del core, y lo
	-- que se edita en el PC no llega nunca. El disco manda.
	launch_step("Writing retroarch.cfg")
	if doesFileExist(casa .."/retroarch/retroarch.cfg") then
		pcall(System.copyFile, casa .."/retroarch/retroarch.cfg",
		      destino .."/retroarch/retroarch.cfg")
	end
	-- Los ajustes por core, por la misma razon. Son una docena de ficheros de texto.
	COPIAR_ARBOL(casa .."/retroarch/config", destino .."/retroarch/config", 0)

	-- "raboot.elf" tambien. El lanzador no lo usa -- llama al core directamente -- pero
	-- con el en la llave, RetroArch se puede abrir desde uLaunchELF sin pasar por
	-- Prism, que es como se comprueba una instalacion cuando algo va mal.
	-- Son 300 KB y se copia una sola vez.
	if doesFileExist(casa .."/raboot.elf") and doesFileExist(destino .."/raboot.elf") == false then
		copy_with_progress(casa .."/raboot.elf", destino .."/raboot.elf", "raboot.elf")
	end

	-- El core del juego y su ".info", nada mas.
	COPIA_TOTAL = 2
	local core_origen = casa .."/cores/".. nombre_core
	local core_destino = destino .."/cores/".. nombre_core
	local ya_esta = (doesFileExist(core_destino)
		and ROM_TAMANO(core_destino) ~= nil
		and ROM_TAMANO(core_destino) == ROM_TAMANO(core_origen))
	if ya_esta == true then
		launch_step("Core already on USB", true)
	else
		launch_step("Copying core")
		copy_with_progress(core_origen, core_destino, "core")
	end
	local info = CORE_A_INFO(nombre_core)
	if info ~= nil then
		COPIA_SI_HACE_FALTA(casa .."/info/".. info, destino .."/info/".. info, info)
	end

	if doesFileExist(destino .."/cores/".. nombre_core) == false then
		boot_log("RETROARCH  no se ha podido poner ".. nombre_core .." en ".. destino)
		boot_flush()
		LIBRETRO_PANTALLA(COPIA_TITULO, "Could not copy ".. nombre_core, 0, nil)
		System.sleep(3)
		return nil
	end

	if COPIA_HECHOS > 0 then
		boot_log("RETROARCH  ".. tostring(COPIA_HECHOS) .." fichero(s) preparados en ".. destino)
		boot_flush()
	end
	-- A partir de aqui, TODO -- config, BIOS, partidas -- apunta a la llave.
	LIBRETRO_FORZADO = destino
	return destino
end
