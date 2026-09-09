-- Prism PS2 Launcher - library/scan.lua
-- Building the game lists: scanning every root, titles, sorting, apps and directories.
-- Split from the original funciones.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Functions are globals; this file only defines them. Loaded by System/system.lua.

--- Explorador y ejecutor de APPS. ------------------------------------------------------
function exporer_apps()
	local cambio_ani, n_ani = true, 45
	local lista_resp, selec_disp, pregunta, device = {TEXT_M_CON[29], TEXT_GEN[7]}, 1, true, salida_texto_dir(System.currentDirectory(), nil)
	while pregunta do
		capturar(JOYSTICK_LIMITE)
		dibujar_fondos()
		local submenu_lista = {"mc0:", "mc1:", device}
		-- Unidades BDM detectadas al arrancar (disco interno exFAT via ata_bd). --------
		if BDM_DEVICES ~= nil then
			for i_bdm = 1, #BDM_DEVICES do
				table.insert(submenu_lista, BDM_DEVICES[i_bdm])
			end
		end
		-- El bandeau tiene altura fija: cada linea ocupa 24 px. Con las unidades BDM
		-- anadidas hay que agrandarlo, si no el contenido desborda y la fila de botones
		-- (calculada desde el borde inferior) queda desplazada.
		local extra_bdm = #submenu_lista - 3
		if extra_bdm < 0 then extra_bdm = 0 end
		submenu_selector(submenu_lista, selec_disp, TEXT_M_PRI[35], 160-(extra_bdm*12), 273+(extra_bdm*12), true, CONTROL.ANCHO//2, lista_resp, false, false, {}, nil)
		if cambio_ani == true then
			cambio_ani, n_ani = intro_menu(cambio_ani, n_ani)
			JOYSTICK_LIMITE = control_FPS(1)-16
		end
		refrescar(false)
		if cambio_ani == false then
		if Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_EJECUTAR, 1, false, nil)
			marcar_directorio(nil, selec_disp, dibujar_fondos)
			JOYSTICK_LIMITE = control_FPS(1)-16
		elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90 or Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90 or Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_MOVER, 1, false, nil)
			if (Pads.check(PAD, PAD_UP) or Left_Y <= -90 or Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
				selec_disp = cambiar_valor(selec_disp, 1, #submenu_lista, 1, false)
			elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90 or Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
				selec_disp = cambiar_valor(selec_disp, 1, #submenu_lista, 1, true)
			end
			JOYSTICK_LIMITE = control_FPS(1)
		elseif Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_CANCELAR, 1, false, nil)
			JOYSTICK_LIMITE = control_FPS(1)
			pregunta = false
		end
		end
	end
	animaciones(nil, false)
end

--- Determina el directorio de la aplicación. -------------------------------------------
function salida_texto_dir(texto, archivo)
	if archivo == true or archivo == false or type(archivo) == "number" then
		local final_dir = string.reverse(texto)
		local borrar, borrar2 = string.find(final_dir, "/", 2, false), 1
		if type(archivo) == "number" then
			borrar2 = string.find(final_dir, "/", borrar+1, false)
			if borrar2 == nil and borrar ~= nil then
				borrar2 = borrar-1
			end
		end
		final_dir = string.reverse(final_dir)
		if type(archivo) == "number" and borrar ~= nil and borrar2 ~= nil then
			final_dir = string.sub(final_dir, -borrar2+1, -borrar)
		elseif type(archivo) == "boolean" and borrar ~= nil and archivo == false then
			final_dir = string.sub(final_dir, 1, -borrar)
		elseif type(archivo) == "boolean" and borrar ~= nil and archivo == true then
			final_dir = string.sub(final_dir, -borrar+1)
		end
		return final_dir
	elseif archivo == nil then
		local final_dir = texto
		local borrar = string.find(final_dir, ":", 1, false)
		if borrar ~= nil then
			final_dir = string.sub(final_dir, 1, borrar)
		end
		return final_dir
	end
end

--- Precargar las listas de cada sistema. -----------------------------------------------
function recargar_todas()
	local crea = {}
	local sistemas_on = {SISTEMAS.MEGADRIVE_ON; SISTEMAS.MASTERSYSTEM_ON; SISTEMAS.GAMEGEAR_ON; SISTEMAS.FAMICOM_ON; SISTEMAS.GAMEBOY_ON;
	SISTEMAS.GAMEBOYCOLOR_ON; SISTEMAS.GAMEBOYADVANCE_ON; SISTEMAS.ATARI2600_ON; SISTEMAS.ATARILYNX_ON; SISTEMAS.SEGASG1000_ON; SISTEMAS.NEOGEOPOCKET_ON;
	SISTEMAS.SUPERFAMICOM_ON; SISTEMAS.APPS_ON; SISTEMAS.PLAYSTATION_ON; SISTEMAS.PLAYSTATION2_ON;};
	for contador = 1, 15, 1 do
		local nueva = {}
		if sistemas_on[contador] == 1 then
			-- Cada sistema rastrea sus carpetas en TODAS las unidades. Es, con
			-- diferencia, lo mas caro del arranque, y hasta ahora la pantalla decia
			-- "Loading lists and settings" durante todo el rato sin distinguirlos.
			local nom = "system ".. tostring(contador)
			if ROMS_DIR ~= nil and ROMS_DIR[contador] ~= nil then nom = ROMS_DIR[contador] end
			-- Sin linea de "empezando": crear_listas ya anuncia "ATA scan <nom>" y
			-- "USB scan <nom>" al abrir cada fuente. Una linea menos por sistema, y
			-- cada linea cuesta una reescritura del journal y dos repintados.
			nueva = crear_listas(contador, nueva)
			load_step(nom .."  ".. tostring(#nueva) .." found  (".. tostring(contador) .."/15)")
		end
		table.insert(crea, nueva)
	end
	PRE_CARGADAS = crea
	LISTAS.IDENTIDAD = 1
end

function recargar_una(identidad)
	PRE_CARGADAS[identidad] = crear_listas(identidad, PRE_CARGADAS[identidad])
	LISTAS.IDENTIDAD = identidad
end

--- Buscar y guardar fuentes de texto. --------------------------------------------------
function buscar_fuentes()
	local actual = System.currentDirectory()
	local buscar_fuentes = System.listDirectory(RUTA_GLOBAL("Font"))
	OPCIONES.FUENTES_ENCONTRADAS = {}
	table.insert(OPCIONES.FUENTES_ENCONTRADAS, actual .."/System/Medias/Font/PublicPixel.ttf")
	if buscar_fuentes ~= nil then
		for contador = 1, #buscar_fuentes do
			if buscar_fuentes[contador].directory == false and (string.lower(string.sub(buscar_fuentes[contador].name, -4)) == ".ttf" or string.lower(string.sub(buscar_fuentes[contador].name, -4)) == ".otf") then
				table.insert(OPCIONES.FUENTES_ENCONTRADAS, RUTA_GLOBAL("Font") .."/".. buscar_fuentes[contador].name)
			end
		end
	end
end

--- Busca y establece los fondos de pantalla. -------------------------------------------
function buscar_fondos(cambio_de_fondo, selec_fondo)
	local actual = System.currentDirectory()
	local buscar_fondos = System.listDirectory(RUTA_GLOBAL("Background"))
	OPCIONES.FONDO_ENCONTRADOS = {}
	table.insert(OPCIONES.FONDO_ENCONTRADOS, actual .."/".. verif_img("System/Medias/Default/FONDO.png"))
	table.insert(OPCIONES.FONDO_ENCONTRADOS, actual .."/".. verif_img("System/Medias/Default/FONDO_2x2_ANI.png"))
	table.insert(OPCIONES.FONDO_ENCONTRADOS, actual .."/".. verif_img("System/Medias/Default/FONDO_X4101101_LAY.png"))
	if buscar_fondos ~= nil then
		for contador = 1, #buscar_fondos do
			if buscar_fondos[contador].directory == false and string.lower(string.sub(buscar_fondos[contador].name, -4)) == ".png" then
				table.insert(OPCIONES.FONDO_ENCONTRADOS, RUTA_GLOBAL("Background") .."/".. buscar_fondos[contador].name)
			end
		end
	end
	if cambio_de_fondo == true and selec_fondo ~= nil then
		if selec_fondo <= #OPCIONES.FONDO_ENCONTRADOS and selec_fondo >= 1 then
			Graphics.freeImage(LISTAS.FONDO)
			LISTAS.FONDO = Graphics.loadImage(OPCIONES.FONDO_ENCONTRADOS[selec_fondo])
			if string.lower(string.sub(OPCIONES.FONDO_ENCONTRADOS[selec_fondo], -8)) == "_ani.png" then
				SPRITES.FONDO_ANI, SPRITES.LAYER = true, false
				if string.match(string.lower(OPCIONES.FONDO_ENCONTRADOS[selec_fondo]), "%d.%d_ani%.png", -11) then
					local col, fil = string.find(OPCIONES.FONDO_ENCONTRADOS[selec_fondo], "%d.%d", -11)
					SPRITES.FONDO_N_COLUMNS = tonumber(string.sub(OPCIONES.FONDO_ENCONTRADOS[selec_fondo], col, col))
					SPRITES.FONDO_N_ROWS = tonumber(string.sub(OPCIONES.FONDO_ENCONTRADOS[selec_fondo], fil, fil))
				else
					SPRITES.FONDO_N_COLUMNS = 4
					SPRITES.FONDO_N_ROWS = 4
				end
				SPRITES.FONDO_WIDTH_X = (Graphics.getImageWidth(LISTAS.FONDO)/SPRITES.FONDO_N_COLUMNS)
				SPRITES.FONDO_HEIGHT_Y = (Graphics.getImageHeight(LISTAS.FONDO)/SPRITES.FONDO_N_ROWS)
			elseif string.lower(string.sub(OPCIONES.FONDO_ENCONTRADOS[selec_fondo], -8)) == "_lay.png" then
				if string.match(string.lower(OPCIONES.FONDO_ENCONTRADOS[selec_fondo]), "_[%w#][%w#][%w#][%w#][%w#][%w#][%w#][%w#]_lay%.png", -17) then
					SPRITES.LAYER_TYPE = cha_res(string.sub(OPCIONES.FONDO_ENCONTRADOS[selec_fondo], -16, -16), 62)
					SPRITES.LAYER_SPEED = cha_res(string.sub(OPCIONES.FONDO_ENCONTRADOS[selec_fondo], -15, -15), 62)
					SPRITES.LAYER_MULTI = cha_res(string.sub(OPCIONES.FONDO_ENCONTRADOS[selec_fondo], -14, -14), 16)
					SPRITES.TRAN_TYPE = cha_res(string.sub(OPCIONES.FONDO_ENCONTRADOS[selec_fondo], -13, -13), 20)
					SPRITES.TRAN_LEVEL = cha_res(string.sub(OPCIONES.FONDO_ENCONTRADOS[selec_fondo], -12, -12), 40)
					SPRITES.TRAN_SPEED = cha_res(string.sub(OPCIONES.FONDO_ENCONTRADOS[selec_fondo], -11, -11), 16)
					SPRITES.SPIN_TYPE = cha_res(string.sub(OPCIONES.FONDO_ENCONTRADOS[selec_fondo], -10, -10), 30)
					SPRITES.SPIN_SPEED = cha_res(string.sub(OPCIONES.FONDO_ENCONTRADOS[selec_fondo], -9, -9), 62)
				else
					SPRITES.LAYER_TYPE, SPRITES.LAYER_SPEED, SPRITES.LAYER_MULTI = cha_res("0", 41), cha_res("1", 40), cha_res("1", 16)
					SPRITES.TRAN_TYPE, SPRITES.TRAN_LEVEL, SPRITES.TRAN_SPEED = cha_res("0", 20), cha_res("0", 40), cha_res("0", 16)
					SPRITES.SPIN_TYPE, SPRITES.SPIN_SPEED = cha_res("0", 30), cha_res("0", 62)
				end
				SPRITES.LAYER_X_1, SPRITES.LAYER_X_2, SPRITES.LAYER_X_3, SPRITES.LAYER_X_4 = 0, 0, 0, 0
				SPRITES.LAYER_Y_1, SPRITES.LAYER_Y_2, SPRITES.LAYER_Y_3, SPRITES.LAYER_Y_4 = 0, 0, 0, 0
				SPRITES.BACK_X, SPRITES.BACK_Y = 0, 0
				SPRITES.TRAN, SPRITES.SPIN = {128, 128, 128, 128}, 0.00
				SPRITES.TRAN_ALT, SPRITES.ZOOM, SPRITES.ANG = {false, false, false, false}, {0, false}, {0.00, 3.14}
				SPRITES.ALTERNATE, SPRITES.ALTERNATE_R, SPRITES.ALTERNATE_T, SPRITES.ACTIVATE_ALTER_T = false, false, false, true
				SPRITES.FONDO_ANI, SPRITES.LAYER = true, true
				SPRITES.FONDO_N_COLUMNS, SPRITES.FONDO_N_ROWS = 2, 2
				SPRITES.FONDO_WIDTH_X = (Graphics.getImageWidth(LISTAS.FONDO)/SPRITES.FONDO_N_COLUMNS)
				SPRITES.FONDO_HEIGHT_Y = (Graphics.getImageHeight(LISTAS.FONDO)/SPRITES.FONDO_N_ROWS)
			else
				SPRITES.FONDO_ANI = false
				SPRITES.LAYER = false
				SPRITES.LAYER_TYPE = 1
			end
			OPCIONES.CAMBIO_FONDO_ON = selec_fondo
		else
			OPCIONES.CAMBIO_FONDO_ON = 1
			OPCIONES.FONDO_ENCONTRADOS = {}
		end
	end
end

--- Buscar y guardar directorios / Buscar y guardar aplicaciones. -----------------------
function buscar_directorio(dir, disp)
	if dir == true and OPCIONES.SALIDA_RETROLANCHER ~= nil then
		local buscar_directorios = System.listDirectory(OPCIONES.SALIDA_RETROLANCHER)
		if buscar_directorios ~= nil then
			OPCIONES.SALIDA_DIR_ACTUALES = {}
			table.insert(OPCIONES.SALIDA_DIR_ANTERIORES, OPCIONES.SALIDA_RETROLANCHER)
			for contador = 1, #buscar_directorios do
				if buscar_directorios[contador].directory == true and string.sub(buscar_directorios[contador].name, -1) ~= "." and string.sub(buscar_directorios[contador].name, -2) ~= ".." then
					table.insert(OPCIONES.SALIDA_DIR_ACTUALES, OPCIONES.SALIDA_DIR_ANTERIORES[#OPCIONES.SALIDA_DIR_ANTERIORES] .. buscar_directorios[contador].name .."/")
				elseif buscar_directorios[contador].directory == false and string.lower(string.sub(buscar_directorios[contador].name, -4)) == ".elf" then
					table.insert(OPCIONES.SALIDA_DIR_ACTUALES, OPCIONES.SALIDA_DIR_ANTERIORES[#OPCIONES.SALIDA_DIR_ANTERIORES] .. buscar_directorios[contador].name)
				end
			end
		end
	elseif dir == false then
		if #OPCIONES.SALIDA_DIR_ANTERIORES >= 2 then
			table.remove(OPCIONES.SALIDA_DIR_ANTERIORES, #OPCIONES.SALIDA_DIR_ANTERIORES)
		end
		local buscar_directorios = System.listDirectory(OPCIONES.SALIDA_DIR_ANTERIORES[#OPCIONES.SALIDA_DIR_ANTERIORES])
		OPCIONES.SALIDA_DIR_ACTUALES = {}
		if buscar_directorios ~= nil then
			for contador = 1, #buscar_directorios do
				if buscar_directorios[contador].directory == true then
					table.insert(OPCIONES.SALIDA_DIR_ACTUALES, OPCIONES.SALIDA_DIR_ANTERIORES[#OPCIONES.SALIDA_DIR_ANTERIORES] .. buscar_directorios[contador].name .."/")
				elseif buscar_directorios[contador].directory == false and string.lower(string.sub(buscar_directorios[contador].name, -4)) == ".elf" then
					table.insert(OPCIONES.SALIDA_DIR_ACTUALES, OPCIONES.SALIDA_DIR_ANTERIORES[#OPCIONES.SALIDA_DIR_ANTERIORES] .. buscar_directorios[contador].name)
				end
			end
		end
	elseif dir == nil then
		local device = salida_texto_dir(System.currentDirectory(), nil)
		if disp == 0 then
			OPCIONES.SALIDA_RETROLANCHER = "PS2 SYSTEM MENU"
			OPCIONES.SALIDA_DIR_ACTUALES, OPCIONES.SALIDA_DIR_ANTERIORES = {}, {}
		elseif disp == 1 then
			OPCIONES.SALIDA_RETROLANCHER = "mc0:/"
			OPCIONES.SALIDA_DIR_ACTUALES, OPCIONES.SALIDA_DIR_ANTERIORES = {}, {}
		elseif disp == 2 then
			OPCIONES.SALIDA_RETROLANCHER = "mc1:/"
			OPCIONES.SALIDA_DIR_ACTUALES, OPCIONES.SALIDA_DIR_ANTERIORES = {}, {}
		elseif disp == 3 then
			OPCIONES.SALIDA_RETROLANCHER = device .."/"
			OPCIONES.SALIDA_DIR_ACTUALES, OPCIONES.SALIDA_DIR_ANTERIORES = {}, {}
		elseif disp >= 4 and BDM_DEVICES ~= nil and BDM_DEVICES[disp-3] ~= nil then
			OPCIONES.SALIDA_RETROLANCHER = BDM_DEVICES[disp-3] .."/"
			OPCIONES.SALIDA_DIR_ACTUALES, OPCIONES.SALIDA_DIR_ANTERIORES = {}, {}
		end
	end
	if #OPCIONES.SALIDA_DIR_ACTUALES >= 1 then
		table.sort(OPCIONES.SALIDA_DIR_ACTUALES, orden_alfabetico)
	end
end

--- Muestra mini explorador de directorios. ---------------------------------------------
function marcar_directorio(tipo, busqueda, fondos)
	Pads.rumble(0, 0, 0)
	local device, scroll_dir, selector, cachucho = salida_texto_dir(System.currentDirectory(), nil), 1, 1, true
	local prev, prev_on, prev_opl = OPCIONES.SALIDA_RETROLANCHER, OPCIONES.SALIDA_RETROLANCHER_ON, OPCIONES.OPL_ELF
	buscar_directorio(nil, busqueda)
	buscar_directorio(true, busqueda)
	JOYSTICK_LIMITE = control_FPS(1)-20
	while cachucho do
		CONTROL.FPS = Screen.getFPS(1)
		capturar(JOYSTICK_LIMITE)
		tiempo_de_scroll()

		-- Mostrar todo en pantalla. ----------------------------------------------------
		fondos()
		Graphics.drawRect(12, 28+CONTROL.Y_FIX_PAL, 615, 375, COLOR.NEGRO_T)
		Graphics.drawRect(-5, 22+CONTROL.Y_FIX_PAL, 650, 25, COLOR.NEGRO)
		if #OPCIONES.SALIDA_DIR_ACTUALES >= 1 then
			if CONTROL.ESPERA_CARGA_SCR == false then
				scroll_dir = scroll_texto(scroll_dir, salida_texto_dir(OPCIONES.SALIDA_DIR_ACTUALES[selector], false), 44)
				if string.len(salida_texto_dir(OPCIONES.SALIDA_DIR_ACTUALES[selector], true)) >= 44 then
					LISTAS.SCROLL_TEX = scroll_texto(LISTAS.SCROLL_TEX, salida_texto_dir(OPCIONES.SALIDA_DIR_ACTUALES[selector], true), 44)
				end
			end
			local mostrar_lista = 0
			for contador = 0, 12, 1 do
				local espacio_linea, valor = 62+((contador)*25)+CONTROL.Y_FIX_PAL, selector
				if contador == 0 then
					Graphics.drawRect(12+3, espacio_linea-3, 608, 25, COLOR.NEGRO_T)
					Font.ftPrint(CONTROL.fontARCA, 36, espacio_linea, 0, 588, 8, string.sub(salida_texto_dir(OPCIONES.SALIDA_DIR_ACTUALES[selector], true), LISTAS.SCROLL_TEX), CAMBIOS_EMUS.COLOR_EMU)
				elseif (selector+contador) <= #OPCIONES.SALIDA_DIR_ACTUALES then
					Font.ftPrint(CONTROL.fontARCA, 36, espacio_linea, 0, 588, 8, salida_texto_dir(OPCIONES.SALIDA_DIR_ACTUALES[selector+contador], true), COLOR.BLANCO_LISTA)
					valor = selector+contador
				else
					valor = nil
				end
				if valor ~= nil then
					Graphics.drawRect(16, espacio_linea+6, 12, 9, Color.new(0, 0, 0))
					if string.lower(string.sub(OPCIONES.SALIDA_DIR_ACTUALES[valor], -4)) == ".elf" then
						Graphics.drawRect(19, espacio_linea+5, 10, 7, Color.new(0, 128, 0))
					else
						Graphics.drawRect(19, espacio_linea+5, 10, 7, Color.new(128, 128, 0))
					end
				end
			end
			Font.ftPrint(CONTROL.fontARCA, 22, 25+CONTROL.Y_FIX_PAL, 0, 601, 8, string.sub(salida_texto_dir(OPCIONES.SALIDA_DIR_ACTUALES[selector], false), scroll_dir), COLOR.BLANCO)
			Graphics.drawRect(12, 422+CONTROL.Y_FIX_PAL, 615, 22, COLOR.NEGRO_T)
			Font.ftPrint(CONTROL.fontARCA, 36, 422+2+CONTROL.Y_FIX_PAL, 0, 588, 8, "/".. string.sub(salida_texto_dir(OPCIONES.SALIDA_DIR_ACTUALES[1], 0), 1, -2) ..": ".. #OPCIONES.SALIDA_DIR_ACTUALES .." ".. TEXT_M_EXP[3], COLOR.GRIS)
		else
			if CONTROL.ESPERA_CARGA_SCR == false then
				LISTAS.SCROLL_TEX = scroll_texto(LISTAS.SCROLL_TEX, TEXT_M_EXP[1], 44)
			end
			Font.ftPrint(CONTROL.fontARCA, 22, 65+CONTROL.Y_FIX_PAL, 0, 598, 8, string.sub(TEXT_M_EXP[1], LISTAS.SCROLL_TEX), CAMBIOS_EMUS.COLOR_EMU)
			Font.ftPrint(CONTROL.fontARCA, 22, 25+CONTROL.Y_FIX_PAL, 0, 601, 8, TEXT_M_EXP[2], COLOR.BLANCO)
		end
		Graphics.drawRect(-5, 392+CONTROL.Y_FIX_PAL, 650, 25, COLOR.NEGRO)
		dibujar_indicador(95, 395, TEXT_GEN[6], PAD_IMG.TRIANGLE, 25, 25, 1, false)
		dibujar_indicador(295, 395, TEXT_GEN[5], PAD_IMG.CROSS, 25, 25, 1, false)
		dibujar_indicador(495, 395, TEXT_GEN[4], PAD_IMG.CIRCLE, 25, 25, 1, false)
		refrescar(false)

		-- Controlar menú explorador. ---------------------------------------------------
		-- Ejecuta o guarda la aplicación. / Cambiar de directorios. --------------------
		if Pads.check(PAD, PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_EJECUTAR, 1, false, nil)
			if #OPCIONES.SALIDA_DIR_ANTERIORES >= 1 then
					OPCIONES.SALIDA_RETROLANCHER = OPCIONES.SALIDA_DIR_ACTUALES[selector]
			elseif #OPCIONES.SALIDA_DIR_ANTERIORES <= 0 then
					buscar_directorio(nil, busqueda)
			end
			buscar_directorio(true, busqueda)
			selector, scroll_dir, LISTAS.SCROLL_TEX = 1, 1, 1
			reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
			if OPCIONES.SALIDA_RETROLANCHER ~= nil and string.lower(string.sub(OPCIONES.SALIDA_RETROLANCHER, -4)) == ".elf" then
				if tipo == true then
					OPCIONES.OPL_ELF = OPCIONES.SALIDA_RETROLANCHER
					OPCIONES.SALIDA_RETROLANCHER = prev
					OPCIONES.SALIDA_RETROLANCHER_ON = prev_on
					guardar_directorio_elf(true)
					cargar_directorio_elf(true)
				elseif tipo == false then
					OPCIONES.OPL_ELF = prev_opl
					OPCIONES.SALIDA_RETROLANCHER_ON = busqueda
				elseif tipo == nil then
					System.loadELF(OPCIONES.SALIDA_RETROLANCHER, 0, salida_texto_dir(OPCIONES.SALIDA_RETROLANCHER, false))
				end
				cachucho = false
			end
			JOYSTICK_LIMITE = control_FPS(1)-5

		-- Regresar al directorio previo. -----------------------------------------------
		elseif Pads.check(PAD, PAD_CIRCLE) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_CANCELAR, 1, false, nil)
			if #OPCIONES.SALIDA_DIR_ANTERIORES >= 1 then
				buscar_directorio(false, busqueda)
			else
				buscar_directorio(nil, busqueda)
				buscar_directorio(true, busqueda)
			end
			JOYSTICK_LIMITE = control_FPS(1)-5
			selector, scroll_dir, LISTAS.SCROLL_TEX = 1, 1, 1
			reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)

		-- Desplazarse por los elementos encontrados. -----------------------------------
		elseif ((Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) or (Pads.check(PAD, PAD_UP) or Left_Y <= -90) or (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90)) and #OPCIONES.SALIDA_DIR_ACTUALES >= 1 and CONTROL.JOYSTICK_ON == false then
			local jump = 1
			if Pads.check(PAD, PAD_R2) or Pads.check(PAD, PAD_L2) or Pads.check(PAD, PAD_R1) or Pads.check(PAD, PAD_L1) then
				jump = 5
			end
			if (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) or (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
				selector = cambiar_valor(selector, 1, #OPCIONES.SALIDA_DIR_ACTUALES, jump, true)
			elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90) or (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
				selector = cambiar_valor(selector, 1, #OPCIONES.SALIDA_DIR_ACTUALES, jump, false)
			end
			local kabal = 1 if Left_Y ~= 1 or Pads.check(PAD, PAD_LEFT) or Pads.check(PAD, PAD_RIGHT) then
				kabal = 2
			end
			if kabal == 1 then
				repro_sfx(S_MOVER, 1, true, nil)
			end
			JOYSTICK_LIMITE = control_FPS(kabal)
			scroll_dir, LISTAS.SCROLL_TEX = 1, 1
			reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)

		-- Cancelar búsqueda y restaurar directorios previamente configurados. ----------
		elseif Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_CANCELAR, 1, false, nil)
			OPCIONES.OPL_ELF = prev_opl
			OPCIONES.SALIDA_RETROLANCHER = prev
			OPCIONES.SALIDA_RETROLANCHER_ON = prev_on
			cachucho = false
		end
	end
	Pads.rumble(0, 0, 0)
end

--- Ordena las listas ignorando mayúsculas. ---------------------------------------------
function orden_alfabetico(a, b)
	return a:lower() < b:lower()
end

--- Ordena las listas para PS1 y PS2. ---------------------------------------------------
function orden_alfabetico_PS(a, b)
	local consiA, consiB = false, false
	if string.match(a, "%a+_%d+%.%d+%.") then
		consiA = true
	end
	if string.match(b, "%a+_%d+%.%d+%.") then
		consiB = true
	end
	if consiA == true and consiB == true then
		return string.lower(a:sub(13)) < string.lower(b:sub(13))
	elseif consiA == true and consiB == false then
		return string.lower(a:sub(13)) < b:lower()
	elseif consiA == false and consiB == true then
		return a:lower() < string.lower(b:sub(13))
	else
		return a:lower() < b:lower()
	end
end

--- Crea las listas de juegos y aplicaciones para cada sistema. -------------------------
function crear_listas(identidad, lista)
	local actual = System.currentDirectory()
	local device = salida_texto_dir(actual, nil)
	local encontrados = {}
	-- Reconstruir una lista es el unico momento en que el contenido de las carpetas
	-- de medios ha podido cambiar: se olvida el indice y se vuelve a construir solo.
	media_indice_olvidar()

	-- Búsquedas para cores de RetroArch. -----------------------------------------------
	if identidad <= 12 then
		-- Lista de sistemas. -----------------------------------------------------------
		local dir_sistemas = {"Sega Megadrive"; "Sega Master System"; "Sega Game Gear"; "Nintendo Famicom"; "Nintendo Game Boy";
		"Nintendo Game Boy Color"; "Nintendo Game Boy Advance"; "Atari 2600"; "Atari Lynx"; "Sega SG-1000"; "Neo Geo Pocket"; "Nintendo Super Famicom";};

		-- Lista de extensiones. --------------------------------------------------------
		local name_exten = {{".zip", ".bin", ".gen", ".smd", ".md"}; {".zip", ".sms"}; {".zip", ".gg"};
		{".zip", ".nes", ".fds", ".unf"}; {".zip", ".gb"}; {".zip", ".gbc"}; {".gba", ".bin"}; {".zip", ".a26", ".bin"};
		{".zip", ".lnx", ".lyx"}; {".zip", ".sg"}; {".zip", ".ngc", ".ngp", ".npc"}; {".zip", ".sfc", ".smc"};};
		local exten = name_exten[identidad]
		local exten_mini = true
		local temp_ext2 = ""
		if identidad ~= 1 and identidad ~= 3 and identidad ~= 5 and identidad ~= 10 then
			exten_mini = false
		end

		-- Realizar búsquedas. ----------------------------------------------------------
		-- Busqueda acumulada. Ademas de la estructura propia de Prism
		-- ("Roms/Roms <sistema>"), se aceptan los nombres al estilo EmulationStation
		-- / Batocera ("roms/snes", "roms/nes"...), tanto dentro de la carpeta del
		-- launcher como en la raiz de cada unidad.
		local dirs = {}
		for i_raiz = 1, #RAICES do
			table.insert(dirs, RAICES[i_raiz] .."/Roms/".. ROMS_DIR[identidad])
		end
		if ES_ALIAS ~= nil and ES_ALIAS[identidad] ~= nil then
			local unidades = {}
			local pos_u = string.find(actual, ":", 1, true)
			if pos_u ~= nil then table.insert(unidades, string.sub(actual, 1, pos_u)) end
			if BDM_DEVICES ~= nil then
				for i_u = 1, #BDM_DEVICES do table.insert(unidades, BDM_DEVICES[i_u]) end
			end
			-- Carpetas contenedoras aceptadas. "Games" es la que usa este fork,
			-- "roms" la de Batocera / Recalbox en la raiz de la unidad.
			local contenedores = {"Games", "roms", "Roms"}
			for a_i = 1, #ES_ALIAS[identidad] do
				local alias = ES_ALIAS[identidad][a_i]
				for c_i = 1, #contenedores do
					for i_raiz = 1, #RAICES do
						table.insert(dirs, RAICES[i_raiz] .."/".. contenedores[c_i] .."/".. alias)
					end
					for i_u = 1, #unidades do
						table.insert(dirs, unidades[i_u] .."/".. contenedores[c_i] .."/".. alias)
					end
				end
			end

			-- "Games/Roms <sistema>": misma carpeta contenedora, nombre largo.
			for i_raiz = 1, #RAICES do
				table.insert(dirs, RAICES[i_raiz] .."/Games/".. ROMS_DIR[identidad])
			end
		end

		local vistos = {}
		-- De donde sale cada juego. Un sistema puede tener ROMs en el disco Y en la
		-- llave, y "scanning snes" a secas no lo distinguia. Pero "dirs" tiene una
		-- treintena de entradas por sistema -- cada alias, cada contenedor, cada
		-- unidad -- y anunciarlas una por una daba quinientas lineas de journal por
		-- arranque, cada una reescribiendo el fichero entero y repintando la pantalla
		-- dos veces. De ahi el arranque interminable. Se anuncia UNA vez por fuente.
		local dicho = {}
		for i_dir = 1, #dirs do
			local fuente = "USB"
			if ES_RAIZ_ATA(dirs[i_dir]) then fuente = "ATA" end
			if dicho[fuente] == nil then
				dicho[fuente] = true
				-- La consola delante y el soporte detras: "SNES - Exfat". Se lee la
				-- columna entera de un vistazo, que es lo que no pasaba con
				-- "ATA scan snes" -- todas las lineas empezaban igual.
				local sistema = string.upper(tostring(ROMS_DIR[identidad]))
				if fuente == "ATA" then
					load_step(sistema .." - Exfat", "exfat")
				else
					load_step(sistema .." - USB", "usb")
				end
			end
			local buscar = System.listDirectory(dirs[i_dir])
			if buscar ~= nil then
				cargar_titulos(dirs[i_dir], identidad)
				-- Los titulos de los juegos del disco exFAT se escriben en la carpeta
				-- canonica del USB, porque el PC no siempre tiene acceso al disco.
				if MEDIA_ALIAS[identidad] ~= nil then
					for i_r = 1, #RAICES do
						cargar_titulos(RAICES[i_r] .."/Roms/".. MEDIA_ALIAS[identidad], identidad)
					end
				end
				local db_juegos = {}
				for contador = 1, #buscar do
					if buscar[contador].directory == false then
						local temp_ext = string.lower(string.sub(buscar[contador].name, -4))
						if exten_mini == true then
							temp_ext2 = string.lower(string.sub(buscar[contador].name, -3))
						end
						for test = 1, #exten do
							local nom = nil
							if temp_ext == exten[test] then
								nom = buscar[contador].name
							elseif exten_mini == true and temp_ext2 == exten[test] then
								nom = buscar[contador].name .." "
							end
							if nom ~= nil and vistos[nom] == nil then
								vistos[nom] = true
								table.insert(encontrados, nom)
								ORIGEN[tostring(identidad) .."|".. nom] = dirs[i_dir]
								ORIGEN_DIR[tostring(identidad) .."|".. nom] = dirs[i_dir] .."/"
								table.insert(db_juegos, {fichero = nom,
									titulo = NOMBRE_VISIBLE(identidad, nom)})
							end
						end
					end
				end
				exfatdb_dir(identidad, dir_sistemas[identidad], dirs[i_dir], db_juegos)
			end
		end
		exfatdb_escribir()
		if encontrados ~= nil and #encontrados >= 1 then
			lista = encontrados
			table.sort(lista, orden_alfabetico)
			return lista
		else
			lista = {}
			return lista
		end

	-- Búsquedas para APPS. -------------------------------------------------------------
	elseif identidad == 13 then
		-- Lista de directorios. --------------------------------------------------------
		local buscar_directorio = {device .."/APPS", "mc0:/APPS", "mc1:/APPS", actual .."/Roms/APPS", "cdfs:", "mc0:", "mc1:", device}
		if BUSCAR_CDVD == false then buscar_directorio[5] = nil end
		-- Los indices 6, 7 y 8 son las RAICES de mc0:, mc1: y del disco, y de cada una
		-- se entra un nivel en toda carpeta que haya. Ver APPS_RAIZ_ON en system.lua.
		if APPS_RAIZ_ON ~= true then
			buscar_directorio[6] = nil
			buscar_directorio[7] = nil
			buscar_directorio[8] = nil
		end
		if OPCIONES.DIR_EXTRAS_ON == 0 then
			buscar_directorio[1] = nil
			buscar_directorio[2] = nil
			buscar_directorio[3] = nil
			buscar_directorio[6] = nil
			buscar_directorio[7] = nil
			buscar_directorio[8] = nil
		end

		-- Realizar búsqueda. -----------------------------------------------------------
		lista = {}
		LISTAS.DIR_FULL_APP = {}
		-- "#" sobre una tabla con agujeros -- y aqui se ponen a nil varios indices -- no
		-- esta definido en Lua: puede devolver 4 y saltarse el resto. Se recorre a 8.
		for buscar_apps = 1, 8 do
			if buscar_directorio[buscar_apps] ~= nil then
				load_step("APPS: listing ".. buscar_directorio[buscar_apps])
				local buscar = System.listDirectory(buscar_directorio[buscar_apps])
				if buscar ~= nil then
					load_step("APPS: listing ".. buscar_directorio[buscar_apps]
					           .."  ".. tostring(#buscar) .." entries")
					for contador = 1, #buscar do
						local recursiva = nil
						if buscar[contador].directory == false and (string.lower(string.sub(buscar[contador].name, -4)) == ".elf" or (buscar_apps == 5 and string.match(buscar[contador].name, "%a+_%d+.%d+") == buscar[contador].name)) then
							if buscar_apps == 5 and string.match(buscar[contador].name, "%a+_%d+.%d+") == buscar[contador].name then
								table.insert(encontrados, obtener_nombre_DVD(buscar[contador].name, false))
								table.insert(LISTAS.DIR_FULL_APP, buscar_directorio[buscar_apps] .."/".. buscar[contador].name)
							else
								table.insert(encontrados, buscar[contador].name)
								table.insert(LISTAS.DIR_FULL_APP, buscar_directorio[buscar_apps] .."/".. buscar[contador].name)
							end
						elseif buscar[contador].directory == true then
							if (buscar_apps == 1 or buscar_apps == 4) and (string.lower(buscar[contador].name) ~= "retrolauncher") then
								recursiva = System.listDirectory(buscar_directorio[buscar_apps] .."/".. buscar[contador].name)
							elseif (buscar_apps == 2 or buscar_apps == 3) and (string.sub(buscar[contador].name, -1) ~= "."
								and string.sub(buscar[contador].name, -2) ~= ".." and string.lower(buscar[contador].name) ~= "retrolauncher") then
								recursiva = System.listDirectory(buscar_directorio[buscar_apps] .."/".. buscar[contador].name)
							elseif (buscar_apps == 6 or buscar_apps == 7) and (string.match(buscar[contador].name, ".+_.+")
								and string.sub(buscar[contador].name, -1) ~= "." and string.sub(buscar[contador].name, -2) ~= ".." ) then
								recursiva = System.listDirectory(buscar_directorio[buscar_apps] .."/".. buscar[contador].name)
							elseif buscar_apps == 8 and string.lower(buscar[contador].name) ~= "retrolauncher"
								and string.lower(buscar[contador].name) ~= "sys-conf" and string.lower(buscar[contador].name) ~= "boot"
									and string.lower(buscar[contador].name) ~= "pops" and string.lower(buscar[contador].name) ~= "apps" then
								recursiva = System.listDirectory(buscar_directorio[buscar_apps] .."/".. buscar[contador].name)
							end
						end
						if recursiva ~= nil then
							load_step("APPS:   into ".. buscar[contador].name
							           .."  ".. tostring(#recursiva) .." entries")
							for contador2 = 1, #recursiva do
								if recursiva[contador2].directory == false and string.lower(string.sub(recursiva[contador2].name, -4)) == ".elf" and string.lower(string.sub(recursiva[contador2].name, 1, 3)) ~= "xx." and string.lower(string.sub(recursiva[contador2].name, 1, 3)) ~= "sb." then
									if doesFileExist(buscar_directorio[buscar_apps] .."/".. buscar[contador].name .."/title.cfg") then
										table.insert(encontrados, obtener_nombre_SAS(buscar_directorio[buscar_apps] .."/".. buscar[contador].name .."/title.cfg", recursiva[contador2].name))
									else
										table.insert(encontrados, recursiva[contador2].name)
									end
									table.insert(LISTAS.DIR_FULL_APP, buscar_directorio[buscar_apps] .."/".. buscar[contador].name .."/".. recursiva[contador2].name)
								end
							end
						end
					end
				end
			end
		end
		if encontrados ~= nil and #encontrados >= 1 then
			if OPCIONES.APPS_MENU_FULL_PATH == 1 then
				lista = LISTAS.DIR_FULL_APP
			else
				lista = encontrados
			end
			return lista
		else
			lista = {}
			LISTAS.DIR_FULL_APP = {}
			return lista
		end

	-- Búsquedas para PlayStation 1. ----------------------------------------------------
	elseif identidad == 14 then
		-- Realizar búsqueda. -----------------------------------------------------------
		-- "POPS/" en la raiz de CADA unidad, no solo en POPS_RAIZ: puede haber juegos
		-- en el POPS de la llave y en el del disco interno a la vez.
		local vistos_vcd = {}
		local unidades_pops = POPS_UNIDADES()
		for i_u = 1, #unidades_pops do
			local buscar = System.listDirectory(unidades_pops[i_u] .."/POPS")
			if buscar ~= nil then
				local db_pops = {}
				for contador = 1, #buscar do
					local nom = buscar[contador].name
					local ps1_name = string.lower(string.sub(nom, -4))
					if buscar[contador].directory == false and ps1_name == ".vcd"
					   and vistos_vcd[string.lower(nom)] == nil then
						vistos_vcd[string.lower(nom)] = true
						table.insert(encontrados, nom)
						ORIGEN["14|".. nom] = unidades_pops[i_u]
						table.insert(db_pops, {fichero = nom,
							titulo = NOMBRE_VISIBLE(14, nom)})
					elseif ps1_name == ".elf" and string.lower(string.sub(nom, 1, 3)) ~= "xx." and string.lower(nom) ~= "popstarter.elf" and string.lower(nom) ~= "pops.elf" and string.lower(nom) ~= "popstarter.kelf"
					   and vistos_vcd[string.lower(nom)] == nil then
						vistos_vcd[string.lower(nom)] = true
						table.insert(encontrados, nom)
						ORIGEN["14|".. nom] = unidades_pops[i_u]
					end
				end
				exfatdb_dir(14, "PlayStation", unidades_pops[i_u] .."/POPS", db_pops,
					"POPS")
			end
		end
		-- Scan Ember Beta 1: "<raiz>/Ember/games/<carpeta>". -------------------------
		--
		-- Un juego de Ember es un DIRECTORIO, no un fichero, asi que se lista con una
		-- extension inventada, ".emb". El resto del programa recorta cuatro caracteres
		-- para quedarse con el nombre visible y para buscar la caratula, de modo que
		-- "Spyro.emb" se ve como "Spyro" y busca "Spyro.png" sin ningun caso especial.
		--
		-- Y NO se lista lo que ya esta como .VCD. El mismo juego puede existir en las
		-- dos formas -- son dos maneras de arrancar una sola cosa -- y verlo dos veces
		-- en la lista no ayuda a nadie. Con que arranca cada uno se elige en su menu,
		-- como Neutrino y OPL en PS2.
		PS1_EMBER = {}
		PS1_WARNING = {}
		-- Un juego que existe en las DOS formas no desaparece: se lista una vez, y la
		-- otra queda apuntada aqui para que el menu del juego pueda ofrecerla. Sin
		-- esto, "no duplicar" acabaria queriendo decir "la version de Ember no se
		-- puede lanzar", que no es lo mismo.
		PS1_ALT_EMBER = {}
		local claves_vcd = {}
		for i_e = 1, #encontrados do
			claves_vcd[ps1_key(encontrados[i_e])] = encontrados[i_e]
		end

		local raices_ember = ember_roots()
		for i_e = 1, #raices_ember do
			local dir_juegos = raices_ember[i_e] .."/games"
			local buscar_emb = System.listDirectory(dir_juegos)
			if buscar_emb ~= nil then
				local db_emb = {}
				for contador = 1, #buscar_emb do
					local nom = buscar_emb[contador].name
					if buscar_emb[contador].directory == true
					   and nom ~= "." and nom ~= ".." then
						local clave = ps1_key(nom)
						local ya = claves_vcd[clave]
						local que = ember_contents(dir_juegos .."/".. nom)
						if ya ~= nil and que ~= nil and que ~= "chd" then
							-- Ya esta en la lista como .VCD: no se repite, se apunta.
							PS1_ALT_EMBER[clave] = nom
							PS1_EMBER["14|".. nom ..".emb"] = dir_juegos .."/".. nom
						elseif ya == nil and que ~= nil then
							local etiqueta = nom ..".emb"
							claves_vcd[clave] = etiqueta
							table.insert(encontrados, etiqueta)
							ORIGEN["14|".. etiqueta] = raices_ember[i_e]
							PS1_EMBER["14|".. etiqueta] = dir_juegos .."/".. nom
							-- Un .chd no le sirve a Ember. Se lista igual, marcado,
							-- porque una carpeta que desaparece sin decir por que es
							-- peor que una carpeta que avisa.
							if que == "chd" then PS1_WARNING["14|".. etiqueta] = "chd" end
							table.insert(db_emb, {fichero = etiqueta,
								titulo = NOMBRE_VISIBLE(14, etiqueta)})
						end
					end
				end
				exfatdb_dir(14, "PlayStation", dir_juegos, db_emb, "Ember")
			end
		end

		-- Titulos reales de PS1: "Roms/psx/titles.txt" en cada raiz, para POPS y Ember.
		for i_raiz = 1, #RAICES do
			cargar_titulos(RAICES[i_raiz] .."/Roms/psx", 14)
		end
		exfatdb_escribir()
		if encontrados ~= nil and #encontrados >= 1 then
			lista = encontrados
			table.sort(lista, orden_alfabetico_PS)
			return lista
		else
			lista = {}
			return lista
		end

	-- Búsquedas para PlayStation 2. ----------------------------------------------------
	elseif identidad == 15 then
		-- Lista de directorios. --------------------------------------------------------
		-- Raices adicionales (disco interno exFAT), antes del bucle principal. --------
		local vistos_ps2 = {}
		-- Directorios extra a explorar: en las unidades ATA, "<unidad>/DVD" y
		-- "<unidad>/CD", como en el USB. Las ISO de PS2 viven SOLO ahi, que es donde
		-- OPL y Neutrino las leen; no hay biblioteca bajo "Roms/".
		local dirs_extra = {}
		if OPCIONES.DIR_EXTRAS_ON ~= 0 then
			for i_u = 1, #BDM_DEVICES do
				if BDM_ATA[BDM_DEVICES[i_u]] == true then
					table.insert(dirs_extra, BDM_DEVICES[i_u] .."/DVD/")
					table.insert(dirs_extra, BDM_DEVICES[i_u] .."/CD/")
				end
			end
		end

		for i_d = 1, #dirs_extra do
			local extra = System.listDirectory(dirs_extra[i_d])
			if extra ~= nil then
				local db_ps2 = {}
				for c = 1, #extra do
					local e = string.lower(string.sub(extra[c].name, -4))
					if extra[c].directory == false and (e == ".iso" or e == ".hdd" or e == ".mx4" or e == ".mmc" or e == ".udp")
					   and vistos_ps2[extra[c].name] == nil then
						vistos_ps2[extra[c].name] = true
						table.insert(encontrados, extra[c].name)
						ORIGEN["15|".. extra[c].name] = dirs_extra[i_d]
						ORIGEN_DIR["15|".. extra[c].name] = dirs_extra[i_d]
						table.insert(db_ps2, {fichero = extra[c].name,
							titulo = NOMBRE_VISIBLE(15, extra[c].name)})
					end
				end
				exfatdb_dir(15, "PlayStation 2", dirs_extra[i_d], db_ps2, "ps2")
			end
		end

		-- [1] era una biblioteca bajo "Roms/"; ya no existe. Se deja el hueco porque
		-- el bucle distingue DVD/CD/cdfs por su indice.
		local buscar_directorio = {nil, device .."/DVD", device .."/CD", "cdfs:"}
		if BUSCAR_CDVD == false then buscar_directorio[4] = nil end
		if OPCIONES.DIR_EXTRAS_ON == 0 then
			buscar_directorio[2] = nil
			buscar_directorio[3] = nil
		end

		-- Realizar búsqueda. -----------------------------------------------------------
		for buscar_ps2 = 1, #buscar_directorio do
			if buscar_directorio[buscar_ps2] ~= nil then
				local buscar = System.listDirectory(buscar_directorio[buscar_ps2])
				if buscar ~= nil then
					local db_ps2b = {}
					for contador = 1, #buscar do
						local ps2_name = string.lower(string.sub(buscar[contador].name, -4))
						if buscar[contador].directory == false and (buscar_ps2 ~= 4 and ps2_name == ".iso") or ((buscar_ps2 == 2 or buscar_ps2 == 3) and ps2_name == ".mx4" or ps2_name == ".hdd" or ps2_name == ".mmc" or ps2_name == ".udp") or (buscar_ps2 == 4 and string.match(buscar[contador].name, "%a+_%d+.%d+") == buscar[contador].name) then
							if buscar_ps2 == 4 then
								table.insert(encontrados, buscar[contador].name ..".".. obtener_nombre_DVD(buscar[contador].name, true))
							else
								if vistos_ps2[buscar[contador].name] == nil then
									vistos_ps2[buscar[contador].name] = true
									table.insert(encontrados, buscar[contador].name)
									ORIGEN_DIR["15|".. buscar[contador].name] = buscar_directorio[buscar_ps2] .."/"
									-- ES_ATA lee ORIGEN, no ORIGEN_DIR: sin esta linea un
									-- ISO del disco interno no llevaba su etiqueta [ATA] en
									-- la lista, y el journal escribia "desde disco interno
									-- (ATA) : false" para un juego que si venia de ahi.
									ORIGEN["15|".. buscar[contador].name] = buscar_directorio[buscar_ps2]
									table.insert(db_ps2b, {fichero = buscar[contador].name,
										titulo = NOMBRE_VISIBLE(15, buscar[contador].name)})
								end
							end
						end
					end
					exfatdb_dir(15, "PlayStation 2", buscar_directorio[buscar_ps2], db_ps2b, "ps2")
				end
			end
		end
		exfatdb_escribir()
		if encontrados ~= nil and #encontrados >= 1 then
			lista = encontrados
			table.sort(lista, orden_alfabetico_PS)
			return lista
		else
			lista = {}
			return lista
		end
	else
		lista = {}
		return lista
	end
end

--- Verifica los juegos y aplicaciones necesarias para cada sistema. --------------------
function existe(identidad, nombre_juego, alternativo)
	local actual = System.currentDirectory()
	local device = salida_texto_dir(actual, nil)

	-- Comprobar la existencia de archivos necesarios. ----------------------------------
	if identidad <= 12 and alternativo ~= nil then
		ERROR_DETALLE = nil
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

		-- Todos los cores estan ya en "LibretroPS2Files/cores": RUTA_CORE los resuelve
		-- sobre cualquier raiz, asi que basta con darle el nombre del fichero. Antes
		-- habia aqui un "directorio especial" por sistema, para TempGBA y SNESticle,
		-- que no eran cores libretro sino ELF autonomos. Ya no estan.
		-- La ROM tiene que estar. Eso no se discute.
		if doesFileExist(RUTA_ROM(identidad, dir_sistemas[identidad], nombre_juego)) == false then
			ERROR_DETALLE = "ROM not found"
			return false
		end
		-- Y tiene que haber AL MENOS UN core que sirva para este sistema en la
		-- instalacion maestra. Aqui se exigia un core concreto, el de la tabla de mas
		-- arriba, y se le buscaba ademas en la instalacion de la llave -- que solo
		-- lleva el core del ultimo juego lanzado. Con lo cual el disco podia tener los
		-- sesenta cores y la respuesta seguia siendo "Games or RetroArch not found".
		-- Si el core previsto no esta pero hay otro que declara la extension, ese vale:
		-- es exactamente lo que pick_core hara dos lineas despues.
		local defecto = name_cores[identidad]
		if alternativo == true then defecto = name_cores_alt[identidad] end
		local rutas = system_cores(identidad, core_master_path(defecto, defecto))
		if #rutas >= 1 then return true end
		ERROR_DETALLE = "No core for ".. dir_sistemas[identidad]
		return false

	-- Comprobar la existencia de archivos necesarios (APPS). ---------------------------
	elseif identidad == 13 and alternativo ~= nil then
		if doesFileExist(LISTAS.DIR_FULL_APP[LISTAS.INDICE]) and RUTA_WLE(false) ~= nil and alternativo == false then
			return true
		elseif doesFileExist(LISTAS.DIR_FULL_APP[LISTAS.INDICE]) then
			return true
		else
			return false
		end

	-- Comprobar la existencia de archivos necesarios (PlayStation 1). ------------------
	elseif identidad == 14 and alternativo ~= nil then
		local exten = string.lower(string.sub(nombre_juego, -4))
		if exten == ".elf" then
			return true
		-- La guia oficial de POPStarter es tajante: en modo USB el emulador es UN
		-- solo fichero, "POPS_IOX.PAK". "IOPRP252.IMG" pertenece al modo HDD, y
		-- exigirlo rechazaba montajes USB perfectamente validos.
		elseif exten == ".vcd" and RUTA_VCD(nombre_juego) ~= nil and doesFileExist(POPS_DE(nombre_juego) .."/POPS/POPS_IOX.PAK") then
			return true
		-- Ember Beta 1: basta con que exista la carpeta del juego y con que el ELF y la
		-- BIOS esten en la carpeta "Ember", que es autocontenida. No se copia nada a
		-- ningun sitio, al reves que en la disposicion antigua.
		elseif exten == ".emb" then
			local raiz_emb = ember_game(string.sub(nombre_juego, 1, -5))
			-- ember_bios copies bios.bin from Bios/ the first time; after that it only
			-- checks. So "missing" here means missing from Bios/ as well.
			if raiz_emb ~= nil and ember_bios(raiz_emb) then
				return true
			end
			local faltan = {}
			if raiz_emb == nil then
				table.insert(faltan, "games/".. string.sub(nombre_juego, 1, -5) .."/")
			elseif doesFileExist(raiz_emb .."/bios.bin") == false then
				table.insert(faltan, "bios.bin  (put a PS1 BIOS in Bios/bios.bin, it is copied from there)")
			end
			ERROR_DETALLE = detalle_falta("Ember",
				(raiz_emb or (RAICES[1] .. EMBER_SUB)) .."/", faltan)
			return false
		else
			-- Detalle del fallo: que falta exactamente y donde se esperaba. -----------
			local faltan = {}
			if exten == ".vcd" then
				local base = POPS_DE(nombre_juego) .."/POPS/"
				local req = {"POPS_IOX.PAK"}
				if RUTA_VCD(nombre_juego) == nil then table.insert(req, 1, nombre_juego) end
				for i = 1, #req do
					if doesFileExist(base .. req[i]) == false then
						table.insert(faltan, req[i])
					end
				end
				ERROR_DETALLE = detalle_falta("POPS", base, faltan)
			end
			return false
		end

	-- Comprobar la existencia de archivos necesarios (PlayStation 2). ------------------
	elseif identidad == 15 and alternativo ~= nil then
		local elf_lauch = actual .."/Neutrino/neutrino.elf"
		if alternativo == true then
			elf_lauch = OPCIONES.OPL_ELF
		end
		-- La ISO puede estar en "<raiz>/Roms/ISOs PlayStation 2" o en el "DVD"/"CD" de
		-- una unidad ATA. El scan memorizo el directorio real en ORIGEN_DIR.
		local ruta_iso = RUTA("/Roms/ps2-isos/".. nombre_juego)
		if ORIGEN_DIR ~= nil and ORIGEN_DIR["15|".. nombre_juego] ~= nil then
			ruta_iso = ORIGEN_DIR["15|".. nombre_juego] .. nombre_juego
		end
		if doesFileExist(ruta_iso) and doesFileExist(elf_lauch) then
			OPCIONES.OPL_DIR = "RETRO"
			return true
		elseif doesFileExist(device .."/DVD/".. nombre_juego) and doesFileExist(elf_lauch) and OPCIONES.DIR_EXTRAS_ON == 1 then
			OPCIONES.OPL_DIR = "DVD"
			return true
		elseif doesFileExist(device .."/CD/".. nombre_juego) and doesFileExist(elf_lauch) and OPCIONES.DIR_EXTRAS_ON == 1 then
			OPCIONES.OPL_DIR = "CD"
			return true
		elseif BUSCAR_CDVD == true and doesFileExist("cdfs:/".. string.sub(nombre_juego, 1, 11)) then
			return true
		else
			return false
		end
	else
		return false
	end
end
