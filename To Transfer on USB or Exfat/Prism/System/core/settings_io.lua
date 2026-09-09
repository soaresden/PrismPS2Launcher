-- Prism PS2 Launcher - core/settings_io.lua
-- Reading and writing the launcher configuration files.
-- Split from the original funciones.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Functions are globals; this file only defines them. Loaded by System/system.lua.

--- Determina el volumen de los sonidos y la música. ------------------------------------
function set_volume()
	sfx_volume(OPCIONES.SOUND_VOLUME)
	Sound.setADPCMVolume(3, OPCIONES.SOUND_VOLUME)
	if OPCIONES.SOUND_VOLUME >= 10 then
		Sound.setADPCMVolume(2, OPCIONES.SOUND_VOLUME-9)
	else
		Sound.setADPCMVolume(2, 0)
	end
end

--- Guardar último juego y sistema usado. -----------------------------------------------
function guardar()
	local actual = System.currentDirectory()
	local config = ("".. LISTAS.IDENTIDAD .." ".. LISTAS.INDICE .." ".. LAST_MOVE[1] .." ".. LAST_MOVE[2] .." ".. LAST_MOVE[3] .." ".. LAST_MOVE[4] ..
	" ".. LAST_MOVE[5] .." ".. LAST_MOVE[6] .." ".. LAST_MOVE[7] .." ".. LAST_MOVE[8] .." ".. LAST_MOVE[9] .." ".. LAST_MOVE[10] .." ".. LAST_MOVE[11] ..
	" ".. LAST_MOVE[12] .." ".. LAST_MOVE[13] .." ".. LAST_MOVE[14] .." ".. LAST_MOVE[15] ..
	"                                                                                                    ")
	if doesFileExist(actual .."/System/Config/Config.cfg") then
		local carga_de_config = System.openFile("System/Config/Config.cfg", FRDWR)
		System.writeFile(carga_de_config, config .." ", string.len(config))
		System.closeFile(carga_de_config)
	else
		if doesFileExist(actual .."/System/Defaults/Config.cfg") then
			System.copyFile(actual .."/System/Defaults/Config.cfg", "System/Config/Config.cfg")
			guardar()
		else
			error("No found ".. actual .."/System/Defaults/Config.cfg")
		end
	end
end

--- Carga el directorio de salida seleccionado. -----------------------------------------
function cargar_directorio_elf(tipo)
	local actual = System.currentDirectory()
	if doesFileExist(actual .."/System/Config/Path_OPL.cfg") and tipo == true then
		local carga_de_dir = System.openFile(actual .."/System/Config/Path_OPL.cfg", FREAD)
		System.seekFile(carga_de_dir, 0, SET)
		local size = System.sizeFile(carga_de_dir)
		local temp_dir = System.readFile(carga_de_dir, size)
		System.closeFile(carga_de_dir)
		if doesFileExist(temp_dir) then
			OPCIONES.OPL_ELF = temp_dir
			return true
		else
			OPCIONES.OPL_ELF = actual .."/OPL/OPNPS2LD.ELF"
			return false
		end
	elseif doesFileExist(actual .."/System/Config/Path_file.cfg") and tipo == false then
		local carga_de_dir = System.openFile(actual .."/System/Config/Path_file.cfg", FREAD)
		System.seekFile(carga_de_dir, 0, SET)
		local size = System.sizeFile(carga_de_dir)
		local temp_dir = System.readFile(carga_de_dir, size)
		System.closeFile(carga_de_dir)
		if temp_dir ~= "PS2 SYSTEM MENU" and doesFileExist(temp_dir) then
			OPCIONES.SALIDA_RETROLANCHER = temp_dir
			OPCIONES.SALIDA_DIR_ACTUALES, OPCIONES.SALIDA_DIR_ANTERIORES = {}, {}
			return true
		else
			OPCIONES.SALIDA_RETROLANCHER = "PS2 SYSTEM MENU"
			OPCIONES.SALIDA_DIR_ACTUALES, OPCIONES.SALIDA_DIR_ANTERIORES = {}, {}
			return false
		end
	elseif tipo ~= nil then
		guardar_directorio_elf(tipo)
		cargar_directorio_elf(tipo)
	end
end

--- Guardar el directorio de salida seleccionado. ---------------------------------------
function guardar_directorio_elf(tipo)
	local actual = System.currentDirectory()
	local dir = OPCIONES.SALIDA_RETROLANCHER
	local archivo = actual .."/System/Config/Path_file.cfg"
	if tipo == true then
		dir = OPCIONES.OPL_ELF
		archivo = actual .."/System/Config/Path_OPL.cfg"
	end
	if doesFileExist(archivo) then
		System.removeFile(archivo)
	end
	local guarda_dir = System.openFile(archivo, FCREATE)
	System.writeFile(guarda_dir, dir, string.len(dir))
	System.closeFile(guarda_dir)
end

--- Guardar opciones. -------------------------------------------------------------------
function guardar_opciones()
	local actual = System.currentDirectory()
	local config = ("".. OPCIONES.RGB_ON .." ".. OPCIONES.FONDO_RGB_ON .." ".. OPCIONES.FONDO_RGB_FIJO_ON .." ".. OPCIONES.R .." ".. OPCIONES.G ..
	" ".. OPCIONES.B .." ".. CONTROL.ESTILO .." ".. SISTEMAS.MEGADRIVE_ON .." ".. SISTEMAS.MASTERSYSTEM_ON .." ".. SISTEMAS.GAMEGEAR_ON ..
	" ".. SISTEMAS.FAMICOM_ON .." ".. SISTEMAS.GAMEBOY_ON .." ".. SISTEMAS.GAMEBOYCOLOR_ON .." ".. SISTEMAS.GAMEBOYADVANCE_ON ..
	" ".. SISTEMAS.ATARI2600_ON .." ".. SISTEMAS.ATARILYNX_ON .." ".. SISTEMAS.SEGASG1000_ON .." ".. SISTEMAS.NEOGEOPOCKET_ON ..
	" ".. SISTEMAS.SUPERFAMICOM_ON .." ".. SISTEMAS.APPS_ON .." ".. SISTEMAS.PLAYSTATION_ON .." ".. OPCIONES.CAMBIO_FUENTE_ON ..
	" ".. OPCIONES.CAMBIO_FONDO_ON .." ".. OPCIONES.GUI_LIMPIA_ON .." ".. OPCIONES.LIMITADOR_RAM_ON .." ".. OPCIONES.SALIDA_RETROLANCHER_ON ..
	" ".. OPCIONES.APPS_MENU_FULL_PATH .." ".. OPCIONES.SOUND_ON .." ".. OPCIONES.SOUND_VOLUME .." ".. OPCIONES.SCREENSHOT_BACK_ON ..
	" ".. OPCIONES.VIDEO_MODE .." ".. OPCIONES.VIBRATION_ON .." ".. SISTEMAS.PLAYSTATION2_ON .." ".. OPCIONES.DIR_EXTRAS_ON .." ".. CAMBIOS_EMUS.TRAS ..
	" ".. OPCIONES.LIBERAR_LISTAS .." ".. OPCIONES.FONT_PIXEL_X .." ".. OPCIONES.FONT_PIXEL_Y .." ".. OPCIONES.FONT_SHADOW .." ".. OPCIONES.SCROLL_MIN ..
	" ".. OPCIONES.SPRITE_ON .." ".. OPCIONES.SEE_INDEX .." ".. OPCIONES.COLOR_LISTA_B .." ".. OPCIONES.SCREENSHOT_BACK_TR .." ".. OPCIONES.RUN_DEFAULT ..
	" ".. COLOR.CC_BACK[1] .." ".. COLOR.CC_BACK[2] .." ".. COLOR.CC_BACK[3] .." ".. COLOR.CC_BACK[4] ..
	"                                                                                                    ")
	if doesFileExist(actual .."/System/Config/System.cfg") then
		local carga_de_opciones = System.openFile("System/Config/System.cfg", FRDWR)
		System.writeFile(carga_de_opciones, config, string.len(config))
		System.closeFile(carga_de_opciones)
	else
		if doesFileExist(actual .."/System/Defaults/System.cfg") then
			System.copyFile(actual .."/System/Defaults/System.cfg", "System/Config/System.cfg")
			guardar_opciones()
		else
			error("No found ".. actual .."/System/Defaults/System.cfg")
		end
	end
end

--- Cargar último juego y sistema usado / Cargar opciones guardadas. --------------------
function cargar_config()
	-- Define y guarda las opciones por defecto. ----------------------------------------
	local function default_config()
		pantalla_reiniciar_conf(LISTAS.FONDO, 34, false, 21)
		OPCIONES.RGB_ON = 1
		OPCIONES.FONDO_RGB_ON = 1
		OPCIONES.FONDO_RGB_FIJO_ON = 0
		OPCIONES.R = 0
		OPCIONES.G = 80
		OPCIONES.B = 120
		CONTROL.ESTILO = 1
		definir_estilos()
		SISTEMAS.MEGADRIVE_ON = 1
		SISTEMAS.MASTERSYSTEM_ON = 1
		SISTEMAS.GAMEGEAR_ON = 1
		SISTEMAS.FAMICOM_ON = 1
		SISTEMAS.GAMEBOY_ON = 1
		SISTEMAS.GAMEBOYCOLOR_ON = 1
		SISTEMAS.GAMEBOYADVANCE_ON = 1
		SISTEMAS.ATARI2600_ON = 1
		SISTEMAS.ATARILYNX_ON = 1
		SISTEMAS.SEGASG1000_ON = 1
		SISTEMAS.NEOGEOPOCKET_ON = 1
		SISTEMAS.SUPERFAMICOM_ON = 0
		SISTEMAS.APPS_ON = 1
		SISTEMAS.PLAYSTATION_ON = 1
		OPCIONES.CAMBIO_FUENTE_ON = 1
		OPCIONES.CAMBIO_FONDO_ON = 1
		OPCIONES.GUI_LIMPIA_ON = 0
		OPCIONES.LIMITADOR_RAM_ON = 0
		OPCIONES.SALIDA_RETROLANCHER_ON = 0
		OPCIONES.APPS_MENU_FULL_PATH = 0
		OPCIONES.SOUND_ON = 0
		OPCIONES.SOUND_VOLUME = 65
		set_volume()
		OPCIONES.SCREENSHOT_BACK_ON = 0
		OPCIONES.SCREENSHOT_BACK_TR = 128
		if doesFileExist("System/Defaults/PAL") then
			OPCIONES.VIDEO_MODE = 1
		else
			OPCIONES.VIDEO_MODE = 0
		end
		OPCIONES.VIBRATION_ON = 0
		OPCIONES.VIBRATION = false
		OPCIONES.VIBRATION_MODE = nil
		SISTEMAS.PLAYSTATION2_ON = 1
		OPCIONES.DIR_EXTRAS_ON = 1
		CAMBIOS_EMUS.TRAS = 74
		OPCIONES.LIBERAR_LISTAS = 0
		OPCIONES.FONT_PIXEL_X = 16
		OPCIONES.FONT_PIXEL_Y = 16
		OPCIONES.FONT_SHADOW = 5
		OPCIONES.SCROLL_MIN = 24
		OPCIONES.SPRITE_ON = 0
		OPCIONES.SEE_INDEX = 0
		OPCIONES.COLOR_LISTA_B = 74
		SPRITES.FONDO_N_COLUMNS = 4
		SPRITES.FONDO_N_ROWS = 4
		OPCIONES.RUN_DEFAULT = 0
		COLOR.CC_BACK = {0, 0, 0, 85}
		COLOR.NEGRO_T = Color.new(COLOR.CC_BACK[1], COLOR.CC_BACK[2], COLOR.CC_BACK[3], COLOR.CC_BACK[4])
		guardar_opciones()
	end
	local function list_default_config()
		LISTAS.IDENTIDAD = 1
		if OPCIONES.LIBERAR_LISTAS == 1 then
			PRE_CARGADAS = {{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}}
			recargar_una(LISTAS.IDENTIDAD)
		end
		LISTAS.ROMS = nil
		LISTAS.ROMS = PRE_CARGADAS[LISTAS.IDENTIDAD]
		LISTAS.INDICE = 1
		indices_extras()
		LAST_MOVE = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
		guardar()
	end
	local function activ_opt(resultado, valor, maxi, mini)
		if valor <= maxi and valor >= mini then
			resultado = valor
		end
		return resultado
	end

	-- Cargar opciones guardadas. -------------------------------------------------------
	local actual = System.currentDirectory()
	load_step("reading System/Config/System.cfg")
	pantalla_reiniciar_conf(LISTAS.FONDO, 20, false, 21)
	if doesFileExist(actual .."/System/Config/System.cfg") then
		local carga_de_config2 = System.openFile(actual .."/System/Config/System.cfg", FREAD)
		System.seekFile(carga_de_config2, 0, SET)
		local size_config2 = System.sizeFile(carga_de_config2)
		local temp2 = System.readFile(carga_de_config2, size_config2)
		System.closeFile(carga_de_config2)
		local lista_config2 = {}
		lista_config2 = sub_string(temp2, "%d+", lista_config2, true)
		if #lista_config2 == 43 then
			table.insert(lista_config2, 128)
			table.insert(lista_config2, 0)
			table.insert(lista_config2, 0)
			table.insert(lista_config2, 0)
			table.insert(lista_config2, 0)
			table.insert(lista_config2, 85)
		end
		if lista_config2 ~= nil and #lista_config2 == 49 then
			pantalla_reiniciar_conf(LISTAS.FONDO, 34, false, 21)
			OPCIONES.RGB_ON = activ_opt(OPCIONES.RGB_ON, lista_config2[1], 1, 0)
			OPCIONES.FONDO_RGB_ON = activ_opt(OPCIONES.FONDO_RGB_ON, lista_config2[2], 1, 0)
			OPCIONES.FONDO_RGB_FIJO_ON = activ_opt(OPCIONES.FONDO_RGB_FIJO_ON, lista_config2[3], 1, 0)
			OPCIONES.R = activ_opt(OPCIONES.R, lista_config2[4], 128, 0)
			OPCIONES.G = activ_opt(OPCIONES.G, lista_config2[5], 128, 0)
			OPCIONES.B = activ_opt(OPCIONES.B, lista_config2[6], 128, 0)
			CONTROL.ESTILO = activ_opt(CONTROL.ESTILO, lista_config2[7], 7, 1)
			definir_estilos()
			SISTEMAS.MEGADRIVE_ON = activ_opt(SISTEMAS.MEGADRIVE_ON, lista_config2[8], 1, 0)
			SISTEMAS.MASTERSYSTEM_ON = activ_opt(SISTEMAS.MASTERSYSTEM_ON, lista_config2[9], 1, 0)
			SISTEMAS.GAMEGEAR_ON = activ_opt(SISTEMAS.GAMEGEAR_ON, lista_config2[10], 1, 0)
			SISTEMAS.FAMICOM_ON = activ_opt(SISTEMAS.FAMICOM_ON, lista_config2[11], 1, 0)
			SISTEMAS.GAMEBOY_ON = activ_opt(SISTEMAS.GAMEBOY_ON, lista_config2[12], 1, 0)
			SISTEMAS.GAMEBOYCOLOR_ON = activ_opt(SISTEMAS.GAMEBOYCOLOR_ON, lista_config2[13], 1, 0)
			SISTEMAS.GAMEBOYADVANCE_ON = activ_opt(SISTEMAS.GAMEBOYADVANCE_ON, lista_config2[14], 1, 0)
			SISTEMAS.ATARI2600_ON = activ_opt(SISTEMAS.ATARI2600_ON, lista_config2[15], 1, 0)
			SISTEMAS.ATARILYNX_ON = activ_opt(SISTEMAS.ATARILYNX_ON, lista_config2[16], 1, 0)
			SISTEMAS.SEGASG1000_ON = activ_opt(SISTEMAS.SEGASG1000_ON, lista_config2[17], 1, 0)
			SISTEMAS.NEOGEOPOCKET_ON = activ_opt(SISTEMAS.NEOGEOPOCKET_ON, lista_config2[18], 1, 0)
			SISTEMAS.SUPERFAMICOM_ON = activ_opt(SISTEMAS.SUPERFAMICOM_ON, lista_config2[19], 1, 0)
			SISTEMAS.APPS_ON = activ_opt(SISTEMAS.APPS_ON, lista_config2[20], 1, 0)
			SISTEMAS.PLAYSTATION_ON = activ_opt(SISTEMAS.PLAYSTATION_ON, lista_config2[21], 1, 0)
			if lista_config2[22] ~= 1 and lista_config2[22] >= 2 then
				buscar_fuentes()
				if lista_config2[22] <= #OPCIONES.FUENTES_ENCONTRADAS then
					Font.ftUnload(CONTROL.fontARCA)
					Font.ftUnload(CONTROL.fontABC)
					CONTROL.fontARCA = Font.ftLoad(OPCIONES.FUENTES_ENCONTRADAS[lista_config2[22]])
					CONTROL.fontABC = Font.ftLoad(OPCIONES.FUENTES_ENCONTRADAS[lista_config2[22]])
					OPCIONES.CAMBIO_FUENTE_ON = lista_config2[22]
				else
					OPCIONES.CAMBIO_FUENTE_ON = 1
					OPCIONES.FUENTES_ENCONTRADAS = {}
				end
			end
			if lista_config2[23] ~= 1 and lista_config2[23] >= 2 then
				buscar_fondos(true, lista_config2[23])
			end
			OPCIONES.GUI_LIMPIA_ON = activ_opt(OPCIONES.GUI_LIMPIA_ON, lista_config2[24], 1, 0)
			OPCIONES.LIMITADOR_RAM_ON = activ_opt(OPCIONES.LIMITADOR_RAM_ON, lista_config2[25], 1, 0)
			if lista_config2[26] <= 3 and lista_config2[26] >= 0 then
				if lista_config2[26] >= 1 and cargar_directorio_elf(false) == true then
					OPCIONES.SALIDA_RETROLANCHER_ON = lista_config2[26]
				else
					OPCIONES.SALIDA_RETROLANCHER_ON = 0
				end
			end
			OPCIONES.APPS_MENU_FULL_PATH = activ_opt(OPCIONES.APPS_MENU_FULL_PATH, lista_config2[27], 1, 0)
			OPCIONES.SOUND_ON = activ_opt(OPCIONES.SOUND_ON, lista_config2[28], 1, 0)
			OPCIONES.SOUND_VOLUME = activ_opt(OPCIONES.SOUND_VOLUME, lista_config2[29], 100, 0)
			set_volume()
			OPCIONES.SCREENSHOT_BACK_ON = activ_opt(OPCIONES.SCREENSHOT_BACK_ON, lista_config2[30], 1, 0)
			if lista_config2[31] <= 1 and lista_config2[31] >= 0 then
				OPCIONES.VIDEO_MODE = lista_config2[31]
				if OPCIONES.VIDEO_MODE == 0 and doesFileExist("System/Defaults/PAL") then
					Screen.setMode(NTSC, 640, 448, CT24, INTERLACED, FIELD)
					System.rename("System/Defaults/PAL", "System/Defaults/NTSC")
				elseif OPCIONES.VIDEO_MODE == 1 and doesFileExist("System/Defaults/NTSC") then
					Screen.setMode(PAL, 640, 512, CT24, INTERLACED, FIELD)
					System.rename("System/Defaults/NTSC", "System/Defaults/PAL")
					CONTROL.ALTO_F = 512
					CONTROL.ALTO = 544
					CONTROL.Y_FIX_PAL = 32
				elseif OPCIONES.VIDEO_MODE == 1 then
					CONTROL.ALTO_F = 512
					CONTROL.ALTO = 544
					CONTROL.Y_FIX_PAL = 32
				else
					CONTROL.ALTO_F = 448
					CONTROL.Y_FIX_PAL = 0
				end
				CONTROL.LISTA_ALTO = CONTROL.LISTA_ALTO + CONTROL.Y_FIX_PAL
				CONTROL.IMG_ALTO = CONTROL.IMG_ALTO + CONTROL.Y_FIX_PAL
				CONTROL.LOGO_ALTO = CONTROL.LOGO_ALTO + CONTROL.Y_FIX_PAL
				CONTROL.IMG_ALTO_2 = CONTROL.IMG_ALTO_2 + CONTROL.Y_FIX_PAL
				CONTROL.FLOW_ALTO = CONTROL.FLOW_ALTO + CONTROL.Y_FIX_PAL
				CONTROL.FLOW_ALTO_2 = CONTROL.FLOW_ALTO_2 + CONTROL.Y_FIX_PAL
				CONTROL.SPRITE_ALTO = CONTROL.SPRITE_ALTO + CONTROL.Y_FIX_PAL
			end
			OPCIONES.VIBRATION_ON = activ_opt(OPCIONES.VIBRATION_ON, lista_config2[32], 1, 0)
			OPCIONES.VIBRATION = false
			OPCIONES.VIBRATION_MODE = nil
			SISTEMAS.PLAYSTATION2_ON = activ_opt(SISTEMAS.PLAYSTATION2_ON, lista_config2[33], 1, 0)
			OPCIONES.DIR_EXTRAS_ON = activ_opt(OPCIONES.DIR_EXTRAS_ON, lista_config2[34], 1, 0)
			CAMBIOS_EMUS.TRAS = activ_opt(CAMBIOS_EMUS.TRAS, lista_config2[35], 128, 0)
			OPCIONES.LIBERAR_LISTAS = activ_opt(OPCIONES.LIBERAR_LISTAS, lista_config2[36], 1, 0)
			OPCIONES.FONT_PIXEL_X = activ_opt(OPCIONES.FONT_PIXEL_X, lista_config2[37], 32, 1)
			OPCIONES.FONT_PIXEL_Y = activ_opt(OPCIONES.FONT_PIXEL_Y, lista_config2[38], 32, 1)
			OPCIONES.FONT_SHADOW = activ_opt(OPCIONES.FONT_SHADOW, lista_config2[39], 32, 0)
			OPCIONES.SCROLL_MIN = activ_opt(OPCIONES.SCROLL_MIN, lista_config2[40], 100, 10)
			if lista_config2[41] <= 1 and lista_config2[41] >= 0 then
				OPCIONES.SPRITE_ON = lista_config2[41]
				if OPCIONES.SPRITE_ON == 1 and CONTROL.ESTILO ~= 7 then
					CONTROL.CUSTOM_SPRITE = true
				end
			end
			OPCIONES.SEE_INDEX = activ_opt(OPCIONES.SEE_INDEX, lista_config2[42], 1, 0)
			OPCIONES.COLOR_LISTA_B = activ_opt(OPCIONES.COLOR_LISTA_B, lista_config2[43], 128, 50)
			if OPCIONES.SCREENSHOT_BACK_ON == 1 then
				OPCIONES.SCREENSHOT_BACK_TR = activ_opt(OPCIONES.SCREENSHOT_BACK_TR, lista_config2[44], 128, 1)
			elseif OPCIONES.SCREENSHOT_BACK_ON == 0 then
				OPCIONES.SCREENSHOT_BACK_TR = 128
			end
			OPCIONES.RUN_DEFAULT = activ_opt(OPCIONES.RUN_DEFAULT, lista_config2[45], 1, 0)
			COLOR.CC_BACK[1] = activ_opt(COLOR.CC_BACK[1], lista_config2[46], 128, 0)
			COLOR.CC_BACK[2] = activ_opt(COLOR.CC_BACK[2], lista_config2[47], 128, 0)
			COLOR.CC_BACK[3] = activ_opt(COLOR.CC_BACK[3], lista_config2[48], 128, 0)
			COLOR.CC_BACK[4] = activ_opt(COLOR.CC_BACK[4], lista_config2[49], 128, 0)
			COLOR.NEGRO_T = Color.new(COLOR.CC_BACK[1], COLOR.CC_BACK[2], COLOR.CC_BACK[3], COLOR.CC_BACK[4])
		else
			default_config()
		end
	else
		default_config()
	end
	load_step("locating OPL")
	cargar_directorio_elf(true)
	pantalla_reiniciar_conf(LISTAS.FONDO, 44, false, 21)
	load_step("checking RetroArch availability")
	-- Antes de recargar_todas, que es quien recorre los quince sistemas: si no hay
	-- forma de arrancar un core, los doce libretro se apagan y ni se rastrean.
	LIBRETRO_APAGAR_SI_IMPOSIBLE()
	if LIBRETRO_SISTEMAS_OFF == true then
		load_step("libretro OFF: ".. tostring(LIBRETRO_SISTEMAS_MOTIVO))
	end
	load_step("building game lists")
	recargar_todas()
	load_step("game lists built")
	pantalla_reiniciar_conf(LISTAS.FONDO, 64, false, 21)

	-- Cargar último juego y sistema usado. ---------------------------------------------
	if doesFileExist(actual .."/System/Config/Config.cfg") then
		local carga_de_config = System.openFile(actual .."/System/Config/Config.cfg", FREAD)
		System.seekFile(carga_de_config, 0, SET)
		local size_config = System.sizeFile(carga_de_config)
		local temp = System.readFile(carga_de_config, size_config)
		System.closeFile(carga_de_config)
		local lista_config = {}
		lista_config = sub_string(temp, "%d+", lista_config, true)
		if lista_config ~= nil and #lista_config == 17 then
			LISTAS.IDENTIDAD = lista_config[1]
			if OPCIONES.LIBERAR_LISTAS == 1 then
				PRE_CARGADAS = {{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}}
				recargar_una(LISTAS.IDENTIDAD)
			end
			LISTAS.ROMS = nil
			LISTAS.ROMS = PRE_CARGADAS[LISTAS.IDENTIDAD]
			if lista_config[2] <= #LISTAS.ROMS then
				LISTAS.INDICE = lista_config[2]
				indices_extras()
			else
				LISTAS.INDICE = 1
				indices_extras()
			end
			LAST_MOVE = {lista_config[3]; lista_config[4]; lista_config[5]; lista_config[6]; lista_config[7]; lista_config[8]; lista_config[9];
			lista_config[10]; lista_config[11]; lista_config[12]; lista_config[13]; lista_config[14]; lista_config[15]; lista_config[16]; lista_config[17];};
		else
			list_default_config()
		end
	else
		list_default_config()
	end
	pantalla_reiniciar_conf(LISTAS.FONDO, 74, false, 21)
	load_step("applying settings")
	-- El interruptor del numero de orden manda sobre lo que diga System.cfg.
	local si = see_index_load()
	if si ~= nil then OPCIONES.SEE_INDEX = si end
	desactivados(nil)
	indices_extras()
	color_emu(LISTAS.IDENTIDAD, OPCIONES.FONDO_RGB_ON, OPCIONES.FONDO_RGB_FIJO_ON)
	Font.ftSetPixelSize(CONTROL.fontARCA, OPCIONES.FONT_PIXEL_X, OPCIONES.FONT_PIXEL_Y)
	Font.ftSetPixelSize(CONTROL.fontABC, 70, 70)
	load_step("loading animations")
	animaciones(nil, false)
	load_step("configuration loaded")
end
