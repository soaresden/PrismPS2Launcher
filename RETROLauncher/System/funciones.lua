--[[------------------SPAGHETTICODE-------------------]]--
--[[█▀█ ██▀ ▀█▀ █▀█ █▀█ █    ▄▄ ▄ ▄ ▄▄▄ ▄▄▄ █▄▄ ▄▄  ▄▄]]--
--[[█▀▄ █▄▄  █  █▀▄ █▄█ █▄▄ ▀▄█ █▄█ █ █ █▄▄ █ █ ██▄ █ ]]--
--[[----------------------v1.0------------------------]]--

--[[Líneas para las funciones de RETROLauncher.]]--
--- Refrescar pantalla. -----------------------------------------------------------------
function refrescar(solo_audio)
	if solo_audio == false then
		Screen.flip()
	end
	if OPCIONES.LIMITADOR_RAM_ON == 1 then
		collectgarbage("collect")
	end
	if OPCIONES.SOUND_ON == 1 and S_MUSICA ~= nil then
		Sound.playADPCM(2, S_MUSICA)
	end
end

--- Dibuja los fondos de pantalla. ------------------------------------------------------
function dibujar_fondos()
	if OPCIONES.FONDO_RGB_ON == 1 and (OPCIONES.FONDO_RGB_FIJO_ON == 0 or (OPCIONES.FONDO_RGB_FIJO_ON == 1 and CAMBIOS_EMUS.TRAS == 0)) then
		Graphics.drawRect(0, 0, CONTROL.ANCHO, CONTROL.ALTO_F, CAMBIOS_EMUS.COLOR_EMU_BACK)
		Graphics.drawScaleImage(LISTAS.FONDO, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F, CAMBIOS_EMUS.COLOR_EMU_BACK)
	elseif OPCIONES.FONDO_RGB_ON == 1 and OPCIONES.FONDO_RGB_FIJO_ON == 1 then
		Graphics.drawScaleImage(LISTAS.FONDO, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F)
		Graphics.drawRect(0, 0, CONTROL.ANCHO, CONTROL.ALTO_F, CAMBIOS_EMUS.COLOR_EMU_BACK)
	else
		Graphics.drawScaleImage(LISTAS.FONDO, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F)
	end
end

--- Controla los tiempos de captura y pausa para los controles. -------------------------
function capturar(limite)
	if CONTROL.JOYSTICK_ON == false or limite >= CONTROL.FPS//3 then
		PAD = Pads.get(0)
		Left_X, Left_Y = Pads.getLeftStick(0)
		JOYSTICK_LIMITE = 0
		CONTROL.JOYSTICK_ON = false
		if CONTROL.ACT_FONTABC == true then CONTROL.ACT_FONTABC = false end
	end
	if CONTROL.JOYSTICK_ON == true then
		PAD = 0
		Left_X, Left_Y = 1, 1
		JOYSTICK_LIMITE = JOYSTICK_LIMITE+1
		Pads.rumble(0, 0, 0)
	end
end

--- Cambia los tiempos de captura de los controles, de acuerdo a los FPS. ---------------
function control_FPS(vel)
	if vel == 1 then
		return 0-CONTROL.FPS//3
	elseif vel == 2 then
		if CONTROL.FPS <= 3 then
			return CONTROL.FPS
		elseif CONTROL.FPS <= 8 then
			return 0+CONTROL.FPS//3
		elseif CONTROL.FPS >= 9 then
			return CONTROL.FPS//4
		end
	end
end

--- Controla el zoom sobre el arte. -----------------------------------------------------
function zoom(multiplicador, ratio_x, ratio_y)
	local Right_X, Right_Y = Pads.getRightStick(0)
	if Right_Y <= -1 then
		Right_Y = Right_Y*(-1)
	elseif Right_Y == 1 then
		Right_Y = 0
	end
	if Right_X == 1 then
		Right_X = 0
	end
	local Right_XY = (Right_Y*multiplicador)//2
	if ratio_y ~= 0 then Right_XY = (Right_XY*ratio_x)//ratio_y end
	return (Right_X*multiplicador)//2, (Right_Y*multiplicador)//2, Right_XY
end

--- Retarda la carga de imágenes. -------------------------------------------------------
function tiempo_arte()
	if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE+1 then
		LISTAS.MOSTRAR = LISTAS.MOSTRAR+1
	else
		LISTAS.MOSTRAR = LISTAS.ART_LIMITE+2
	end
end

--- Cambia los índices de las imágenes extra. -------------------------------------------
function indices_extras()
	if LISTAS.INDICE >= 2 then
		LISTAS.INDICE2 = LISTAS.INDICE-1
	else
		LISTAS.INDICE2 = #LISTAS.ROMS
	end
	if LISTAS.INDICE <= #LISTAS.ROMS-1 then
		LISTAS.INDICE3 = LISTAS.INDICE+1
	else
		LISTAS.INDICE3 = 1
	end
end

--- Libera las imágenes de memoria. -----------------------------------------------------
function limpiar_art()
	if LISTAS.COVER_ART ~= nil then
		Graphics.freeImage(LISTAS.COVER_ART)
		LISTAS.COVER_ART = nil
	end
	if LISTAS.SCREENSHOT ~= nil then
		Graphics.freeImage(LISTAS.SCREENSHOT)
		LISTAS.SCREENSHOT = nil
	end
	if LISTAS.COVER_ART2 ~= nil then
		Graphics.freeImage(LISTAS.COVER_ART2)
		LISTAS.COVER_ART2 = nil
	end
	if LISTAS.COVER_ART3 ~= nil then
		Graphics.freeImage(LISTAS.COVER_ART3)
		LISTAS.COVER_ART3 = nil
	end
	LISTAS.COVER_DIR = " "; LISTAS.COVER_DIR_ALT = " "; LISTAS.SCREENSHOT_DIR = " "; LISTAS.SCREENSHOT_DIR_ALT = " ";
	LISTAS.COVER_DIR2 = " "; LISTAS.COVER_DIR2_ALT = " "; LISTAS.COVER_DIR3 = " "; LISTAS.COVER_DIR3_ALT = " ";
end

--- Buscar y cargar imágenes en memoria. ------------------------------------------------
function cargar_art()
	Pads.rumble(0, 0, 0)
	local actual = System.currentDirectory()
	local device = salida_texto_dir(actual, nil)
	local nombre = string.sub(LISTAS.ROMS[LISTAS.INDICE], 1, -CONTROL.EXTENSION)
	local nombre2 = " "
	local nombre3 = " "
	if (CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_FLOW == true then
		nombre2 = string.sub(LISTAS.ROMS[LISTAS.INDICE2], 1, -CONTROL.EXTENSION)
		nombre3 = string.sub(LISTAS.ROMS[LISTAS.INDICE3], 1, -CONTROL.EXTENSION)
	end

	-- Generar ubicaciones para la búsqueda. --------------------------------------------
	local sistemas_nombre = {"Sega Megadrive", "Sega Master System", "Sega Game Gear", "Nintendo Famicom", "Nintendo Game Boy", "Nintendo Game Boy Color", "Nintendo Game Boy Advance", "Atari 2600", "Sega SG-1000", "Neo Geo Pocket", "Nintendo Super Famicom", "APPS", "PlayStation", "PlayStation 2"}
	if LISTAS.MOSTRAR == 1 and (LISTAS.IDENTIDAD >= 1 and LISTAS.IDENTIDAD <= 14) then
		if OPCIONES.APPS_MENU_FULL_PATH == 1 and LISTAS.IDENTIDAD == 12 then
			nombre = salida_texto_dir(string.sub(LISTAS.ROMS[LISTAS.INDICE], 1, -CONTROL.EXTENSION), true)
			if (CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_FLOW == true then
				nombre2 = salida_texto_dir(string.sub(LISTAS.ROMS[LISTAS.INDICE2], 1, -CONTROL.EXTENSION), true)
				nombre3 = salida_texto_dir(string.sub(LISTAS.ROMS[LISTAS.INDICE3], 1, -CONTROL.EXTENSION), true)
			end
		end

		-- Ubicaciones para covers, screenshot y covers flow. ---------------------------
		if CONTROL.CUSTOM_ART1 == true then
			LISTAS.COVER_DIR = (actual .."/Multimedia/Covers/Covers ".. sistemas_nombre[LISTAS.IDENTIDAD] .."/".. nombre ..".png")
			LISTAS.SCREENSHOT_DIR = (actual .."/Multimedia/Screenshots/Screenshots ".. sistemas_nombre[LISTAS.IDENTIDAD] .."/".. nombre ..".png")
		end
		if (CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_FLOW == true then
			LISTAS.COVER_DIR2 = (actual .."/Multimedia/Covers/Covers ".. sistemas_nombre[LISTAS.IDENTIDAD] .."/".. nombre2 ..".png")
			LISTAS.COVER_DIR3 = (actual .."/Multimedia/Covers/Covers ".. sistemas_nombre[LISTAS.IDENTIDAD] .."/".. nombre3 ..".png")
		end

		-- Ubicaciones para la carpeta "ART". -------------------------------------------
		if LISTAS.IDENTIDAD == 12 then
			if CONTROL.CUSTOM_ART1 == true then
				LISTAS.COVER_DIR_ALT = (device .."/ART/".. nombre ..".elf_COV.png")
				LISTAS.SCREENSHOT_DIR_ALT = (device .."/ART/".. nombre ..".elf_SCR.png")
			end
			if (CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_FLOW == true then
				LISTAS.COVER_DIR2_ALT = (device .."/ART/".. nombre2 ..".elf_COV.png")
				LISTAS.COVER_DIR3_ALT = (device .."/ART/".. nombre3 ..".elf_COV.png")
			end
		elseif LISTAS.IDENTIDAD == 13 or LISTAS.IDENTIDAD == 14 then
			if CONTROL.CUSTOM_ART1 == true then
				LISTAS.COVER_DIR_ALT = (device .."/ART/".. string.sub(nombre, 1, 11) .."_COV.png")
				LISTAS.SCREENSHOT_DIR_ALT = (device .."/ART/".. string.sub(nombre, 1, 11) .."_SCR.png")
			end
			if (CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_FLOW == true then
				LISTAS.COVER_DIR2_ALT = (device .."/ART/".. string.sub(nombre2, 1, 11) .."_COV.png")
				LISTAS.COVER_DIR3_ALT = (device .."/ART/".. string.sub(nombre3, 1, 11) .."_COV.png")
			end
		end
	end

	-- Realizar la búsqueda y carga de imágenes. ----------------------------------------
	if LISTAS.MOSTRAR == LISTAS.ART_LIMITE then
		-- Carga de covers. -------------------------------------------------------------
		if doesFileExist(LISTAS.COVER_DIR) then
			LISTAS.COVER_ART = Graphics.loadImage(LISTAS.COVER_DIR)
			LISTAS.EXISTE_COV = true
		elseif LISTAS.IDENTIDAD >= 12 and LISTAS.IDENTIDAD <= 14 and doesFileExist(LISTAS.COVER_DIR_ALT) then
			LISTAS.COVER_ART = Graphics.loadImage(LISTAS.COVER_DIR_ALT)
			LISTAS.EXISTE_COV = true
		else
			LISTAS.COVER_ART = nil
			LISTAS.EXISTE_COV = false
		end

		-- Carga de screenshot. ---------------------------------------------------------
		if doesFileExist(LISTAS.SCREENSHOT_DIR) then
			LISTAS.SCREENSHOT = Graphics.loadImage(LISTAS.SCREENSHOT_DIR)
			LISTAS.EXISTE_SCR = true
		elseif LISTAS.IDENTIDAD >= 12 and LISTAS.IDENTIDAD <= 14 and doesFileExist(LISTAS.SCREENSHOT_DIR_ALT) then
			LISTAS.SCREENSHOT = Graphics.loadImage(LISTAS.SCREENSHOT_DIR_ALT)
			LISTAS.EXISTE_SCR = true
		else
			LISTAS.SCREENSHOT = nil
			LISTAS.EXISTE_SCR = false
		end

		-- Carga de covers flow. --------------------------------------------------------
		if (CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_FLOW == true then
			if doesFileExist(LISTAS.COVER_DIR2) then
				LISTAS.COVER_ART2 = Graphics.loadImage(LISTAS.COVER_DIR2)
				LISTAS.EXISTE_COV2 = true
			elseif LISTAS.IDENTIDAD >= 12 and LISTAS.IDENTIDAD <= 14 and doesFileExist(LISTAS.COVER_DIR2_ALT) then
				LISTAS.COVER_ART2 = Graphics.loadImage(LISTAS.COVER_DIR2_ALT)
				LISTAS.EXISTE_COV2 = true
			else
				LISTAS.COVER_ART2 = nil
				LISTAS.EXISTE_COV2 = false
			end
			if doesFileExist(LISTAS.COVER_DIR3) then
				LISTAS.COVER_ART3 = Graphics.loadImage(LISTAS.COVER_DIR3)
				LISTAS.EXISTE_COV3 = true
			elseif LISTAS.IDENTIDAD >= 12 and LISTAS.IDENTIDAD <= 14 and doesFileExist(LISTAS.COVER_DIR3_ALT) then
				LISTAS.COVER_ART3 = Graphics.loadImage(LISTAS.COVER_DIR3_ALT)
				LISTAS.EXISTE_COV3 = true
			else
				LISTAS.COVER_ART3 = nil
				LISTAS.EXISTE_COV3 = false
			end
		end
	end
	ajustar_art()
end

--- Corrige la relación de aspecto y centra las imágenes. -------------------------------
function ajustar_art()
	-- Relación de aspecto para cover. --------------------------------------------------
	LISTAS.COV_X = CONTROL.IMG_X
	LISTAS.COV_Y = CONTROL.IMG_Y
	LISTAS.COV_FIX = 0
	LISTAS.COV_FIX_Y = 0
	LISTAS.EX_FIX_C = 520
	LISTAS.EX_FIX_C_Y = 390
	if LISTAS.COVER_ART ~= nil and LISTAS.EXISTE_COV == true and CONTROL.CUSTOM_ART1 == true then
		local x = Graphics.getImageWidth(LISTAS.COVER_ART)
		local y = Graphics.getImageHeight(LISTAS.COVER_ART)
		local eiuqal = (CONTROL.IMG_Y*x)/y
		local ymot = (CONTROL.IMG_X*y)/x
		if eiuqal <= CONTROL.IMG_X then
			LISTAS.COV_X = eiuqal
			LISTAS.COV_Y = CONTROL.IMG_Y
			LISTAS.COV_FIX = (CONTROL.IMG_X-eiuqal)//2
			LISTAS.COV_FIX_Y = 0
		elseif ymot <= CONTROL.IMG_Y then
			LISTAS.COV_X = CONTROL.IMG_X
			LISTAS.COV_Y = ymot
			LISTAS.COV_FIX = 0
			LISTAS.COV_FIX_Y = (CONTROL.IMG_Y-ymot)//2
		end
		if (390*x)/y <= 520 then
			LISTAS.EX_FIX_C = (390*x)/y
			LISTAS.EX_FIX_C_Y = 390
		elseif (520*y)/x <= 390 then
			LISTAS.EX_FIX_C = 520
			LISTAS.EX_FIX_C_Y = (520*y)/x
		end
	end

	-- Relación de aspecto para screenshot. ---------------------------------------------
	LISTAS.SCR_X = CONTROL.IMG_X
	LISTAS.SCR_Y = CONTROL.IMG_Y
	LISTAS.SCR_ART2_X = CONTROL.IMG_X_2
	LISTAS.SCR_ART2_Y = CONTROL.IMG_Y_2
	LISTAS.SCR_FIX = 0
	LISTAS.SCR_FIX_ART2 = 0
	LISTAS.SCR_FIX_Y = 0
	LISTAS.SCR_FIX_Y_ART2 = 0
	LISTAS.EX_FIX_S = 520
	LISTAS.EX_FIX_S_Y = 390
	if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true and CONTROL.CUSTOM_ART1 == true then
		local x = Graphics.getImageWidth(LISTAS.SCREENSHOT)
		local y = Graphics.getImageHeight(LISTAS.SCREENSHOT)
		local eiuqal = (CONTROL.IMG_Y*x)/y
		local ymot = (CONTROL.IMG_X*y)/x
		if eiuqal <= CONTROL.IMG_X then
			LISTAS.SCR_X = eiuqal
			LISTAS.SCR_Y = CONTROL.IMG_Y
			LISTAS.SCR_FIX = (CONTROL.IMG_X-eiuqal)//2
			LISTAS.SCR_FIX_Y = 0
		elseif ymot <= CONTROL.IMG_Y then
			LISTAS.SCR_X = CONTROL.IMG_X
			LISTAS.SCR_Y = ymot
			LISTAS.SCR_FIX = 0
			LISTAS.SCR_FIX_Y = (CONTROL.IMG_Y-ymot)//2
		end
		if CONTROL.CUSTOM_ART2 == true then
			local eiuqal_art2 = (CONTROL.IMG_Y_2*x)/y
			local ymot_art2 = (CONTROL.IMG_X_2*y)/x
			if eiuqal_art2 <= CONTROL.IMG_X_2 then
				LISTAS.SCR_ART2_X = eiuqal_art2
				LISTAS.SCR_ART2_Y = CONTROL.IMG_Y_2
				LISTAS.SCR_FIX_ART2 = (CONTROL.IMG_X_2-eiuqal_art2)//2
				LISTAS.SCR_FIX_Y_ART2 = 0
			elseif ymot_art2 <= CONTROL.IMG_Y_2 then
				LISTAS.SCR_ART2_X = CONTROL.IMG_X_2
				LISTAS.SCR_ART2_Y = ymot_art2
				LISTAS.SCR_FIX_ART2 = 0
				LISTAS.SCR_FIX_Y_ART2 = (CONTROL.IMG_Y_2-ymot_art2)//2
			end
		end
		if (390*x)/y <= 520 then
			LISTAS.EX_FIX_S = (390*x)/y
			LISTAS.EX_FIX_S_Y = 390
		elseif (520*y)/x <= 390 then
			LISTAS.EX_FIX_S = 520
			LISTAS.EX_FIX_S_Y = (520*y)/x
		end
	end

	-- Relación de aspecto para cover flow 1. -------------------------------------------
	LISTAS.COV_1_X = CONTROL.FLOW_X
	LISTAS.COV_1_Y = CONTROL.FLOW_Y
	LISTAS.COV_1_FIX = 0
	LISTAS.COV_1_FIX_Y = 0
	if (CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and LISTAS.COVER_ART2 ~= nil and LISTAS.EXISTE_COV2 == true and CONTROL.CUSTOM_FLOW == true then
		local x = Graphics.getImageWidth(LISTAS.COVER_ART2)
		local y = Graphics.getImageHeight(LISTAS.COVER_ART2)
		local eiuqal = (CONTROL.FLOW_Y*x)/y
		local ymot = (CONTROL.FLOW_X*y)/x
		if eiuqal <= CONTROL.FLOW_X then
			LISTAS.COV_1_X = eiuqal
			LISTAS.COV_1_Y = CONTROL.FLOW_Y
			LISTAS.COV_1_FIX = (CONTROL.FLOW_X-eiuqal)//2
			LISTAS.COV_1_FIX_Y = 0
		elseif ymot <= CONTROL.FLOW_Y then
			LISTAS.COV_1_X = CONTROL.FLOW_X
			LISTAS.COV_1_Y = ymot
			LISTAS.COV_1_FIX = 0
			LISTAS.COV_1_FIX_Y = (CONTROL.FLOW_Y-ymot)//2
		end
	end

	-- Relación de aspecto para cover flow 2. -------------------------------------------
	LISTAS.COV_2_X = CONTROL.FLOW_X_2
	LISTAS.COV_2_Y = CONTROL.FLOW_Y_2
	LISTAS.COV_2_FIX = 0
	LISTAS.COV_2_FIX_Y = 0
	if (CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_FLOW == true and LISTAS.COVER_ART3 ~= nil and LISTAS.EXISTE_COV3 == true then
		local x = Graphics.getImageWidth(LISTAS.COVER_ART3)
		local y = Graphics.getImageHeight(LISTAS.COVER_ART3)
		local eiuqal = (CONTROL.FLOW_Y_2*x)/y
		local ymot = (CONTROL.FLOW_X_2*y)/x
		if eiuqal <= CONTROL.FLOW_X_2 then
			LISTAS.COV_2_X = eiuqal
			LISTAS.COV_2_Y = CONTROL.FLOW_Y_2
			LISTAS.COV_2_FIX = (CONTROL.FLOW_X_2-eiuqal)//2
			LISTAS.COV_2_FIX_Y = 0
		elseif ymot <= CONTROL.FLOW_Y_2 then
			LISTAS.COV_2_X = CONTROL.FLOW_X_2
			LISTAS.COV_2_Y = ymot
			LISTAS.COV_2_FIX = 0
			LISTAS.COV_2_FIX_Y = (CONTROL.FLOW_Y_2-ymot)//2
		end
	end
end

--- Saltar de carácter en las listas. ---------------------------------------------------
function letter_breaks(inicial, pos, lado)
	local inicial_act = string.lower(string.sub(inicial, 1, 1))
	if (LISTAS.IDENTIDAD == 13 or LISTAS.IDENTIDAD == 14) and string.match(inicial, "%a+_%d+.%d+%.") then
		inicial_act = string.lower(string.sub(inicial, 13, 13))
	end
	local inicio_bus, final_bus, minimo_bus = #LISTAS.ROMS, 1, 1
	if lado == false then
		inicio_bus, final_bus, minimo_bus = 1, -1, #LISTAS.ROMS
	end
	for n = pos, inicio_bus, final_bus do
		if (LISTAS.IDENTIDAD == 13 or LISTAS.IDENTIDAD == 14) and string.match(LISTAS.ROMS[n], "%a+_%d+.%d+%.") then
			if string.lower(string.sub(LISTAS.ROMS[n], 13, 13)) ~= inicial_act or n == inicio_bus then
				pos = n
				if n == inicio_bus then
					pos = minimo_bus
				end
				return pos
			end
		elseif string.lower(string.sub(LISTAS.ROMS[n], 1, 1)) ~= inicial_act or n == inicio_bus then
			pos = n
			if n == inicio_bus then
				pos = minimo_bus
			end
			return pos
		end
	end
end

--- Controlar el cambio entre sistemas activados y desactivados. ------------------------
function desactivados(lado)
	local buscar = true
	local sistemas_on = {SISTEMAS.MEGADRIVE_ON, SISTEMAS.MASTERSYSTEM_ON, SISTEMAS.GAMEGEAR_ON, SISTEMAS.FAMICOM_ON, SISTEMAS.GAMEBOY_ON, SISTEMAS.GAMEBOYCOLOR_ON, SISTEMAS.GAMEBOYADVANCE_ON, SISTEMAS.ATARI2600_ON, SISTEMAS.SEGASG1000_ON, SISTEMAS.NEOGEOPOCKET_ON, SISTEMAS.SUPERFAMICOM_ON, SISTEMAS.APPS_ON, SISTEMAS.PLAYSTATION_ON, SISTEMAS.PLAYSTATION2_ON}
	if OPCIONES.LIBERAR_LISTAS == 1 then
		PRE_CARGADAS[LISTAS.IDENTIDAD] = {}
	end
	while buscar do
		if lado == true then
			LISTAS.IDENTIDAD = cambiar_valor(LISTAS.IDENTIDAD, 1, #PRE_CARGADAS, 1, false)
		elseif lado == false then
			LISTAS.IDENTIDAD = cambiar_valor(LISTAS.IDENTIDAD, 1, #PRE_CARGADAS, 1, true)
		end
		if sistemas_on[LISTAS.IDENTIDAD] == 1 then
			buscar = false
		elseif lado == nil then
			LISTAS.INDICE = 1
			lado = false
		end
	end
	LISTAS.ROMS = nil
	if OPCIONES.LIBERAR_LISTAS == 1 then
		recargar_una(LISTAS.IDENTIDAD)
	end
	LISTAS.ROMS = PRE_CARGADAS[LISTAS.IDENTIDAD]
	indices_extras()
end

--- Realizar movimiento de scroll en textos largos. -------------------------------------
function scroll_texto(scroll, texto, limite)
	if string.len(texto) >= limite and scroll <= (string.len(texto)-1) then
		scroll = scroll+1
		reset_tiempo_espera(0)
	else
		reset_tiempo_espera(0-CONTROL.FPS)
		scroll = 1
	end
	return scroll
end

--- Determina las pausas durante el movimiento de scroll en textos largos. --------------
function tiempo_de_scroll()
	if CONTROL.ESPERA_CARGA_SCR == true then
		CONTROL.PAUSA_SCR_TEX = CONTROL.PAUSA_SCR_TEX+1
	end
	if CONTROL.PAUSA_SCR_TEX >= CONTROL.FPS//3 or CONTROL.ESPERA_CARGA_SCR == false then
		CONTROL.PAUSA_SCR_TEX = 0
		CONTROL.ESPERA_CARGA_SCR = false
	end
end

--- Determina las pausas antes del scroll en textos largos. -----------------------------
function reset_tiempo_espera(numero)
	CONTROL.ESPERA_CARGA_SCR = true
	CONTROL.PAUSA_SCR_TEX = numero
end

--- Realiza saltos de elementos (en ruleta) dentro de un rango predeterminado. ----------
function cambiar_valor(numero_actual, numero_minimo, numero_maximo, salto, aumentar)
	if aumentar == true then
		if numero_actual+salto <= numero_maximo then
			numero_actual = numero_actual+salto
		else
			numero_actual = numero_minimo
		end
		return numero_actual
	elseif aumentar == false then
		if numero_actual-salto >= numero_minimo then
			numero_actual = numero_actual-salto
		else
			numero_actual = numero_maximo
		end
		return numero_actual
	end
end

--- Tipos de animaciones al cambiar de emuladores. --------------------------------------
function animaciones(lado)
	Pads.rumble(0, 0, 0)
	local trans_especial, mostrar_ant = false, false
	if lado == nil then lado, trans_especial, mostrar_ant = true, true, true end
	local saibot = true
	local cambio_ani = false

	-- Determinar las posiciones de los elementos en pantalla. --------------------------
	local lista_objetos_min = {CONTROL.IMG_ANCHO, CONTROL.LISTA_ANCHO, CONTROL.LOGO_ANCHO, CONTROL.IMG_ANCHO_2, CONTROL.FLOW_ANCHO, CONTROL.FLOW_ANCHO_2}
	local lista_objetos_max = {(CONTROL.IMG_ANCHO+CONTROL.IMG_X), (CONTROL.LISTA_ANCHO+CONTROL.LISTA_X), (CONTROL.LOGO_ANCHO+CONTROL.LOGO_X), (CONTROL.IMG_ANCHO_2+CONTROL.IMG_X_2), (CONTROL.FLOW_ANCHO+CONTROL.FLOW_X), (CONTROL.FLOW_ANCHO_2+CONTROL.FLOW_X_2)}
	if CONTROL.CUSTOM_ANIM == 2 or CONTROL.CUSTOM_ANIM == 3 then
		lista_objetos_min = {CONTROL.IMG_ALTO, CONTROL.LISTA_ALTO, CONTROL.LOGO_ALTO, CONTROL.IMG_ALTO_2, CONTROL.FLOW_ALTO, CONTROL.FLOW_ALTO_2}
		lista_objetos_max = {(CONTROL.IMG_ALTO+CONTROL.IMG_Y), (CONTROL.LISTA_ALTO+CONTROL.LISTA_Y), (CONTROL.LOGO_ALTO+CONTROL.LOGO_Y), (CONTROL.IMG_ALTO_2+CONTROL.IMG_Y_2), (CONTROL.FLOW_ALTO+CONTROL.FLOW_Y), (CONTROL.FLOW_ALTO_2+CONTROL.FLOW_Y_2)}
	end
	table.sort(lista_objetos_min)
	table.sort(lista_objetos_max)
	local minimo, maximo, lista_objetos_min, lista_objetos_max = lista_objetos_min[1], lista_objetos_max[#lista_objetos_max], {}, {}
	local actual = minimo
	if CONTROL.CUSTOM_ANIM >= 4 or trans_especial == true then
		actual = 0
	else
		color_emu(LISTAS.IDENTIDAD)
	end
	while saibot do
		-- Animación estilo 1. ----------------------------------------------------------
		if lado == true and CONTROL.CUSTOM_ANIM == 1 and trans_especial == false then
			if actual > minimo and cambio_ani == true then
				actual = actual-CONTROL.ANIM_VELOCIDAD
			elseif cambio_ani == true then
				actual = 0
				saibot = false
			elseif actual+maximo > 0-CONTROL.ANIM_VELOCIDAD  and cambio_ani == false then
				actual = actual-CONTROL.ANIM_VELOCIDAD
			elseif actual+maximo <= 0-CONTROL.ANIM_VELOCIDAD  and cambio_ani == false then
				actual = CONTROL.ANCHO+CONTROL.ANIM_VELOCIDAD
				cargar_logo(LISTAS.IDENTIDAD)
				cambio_ani = true
			end
		elseif lado == false and CONTROL.CUSTOM_ANIM == 1 and trans_especial == false then
			if actual+CONTROL.ANIM_VELOCIDAD < minimo-CONTROL.ANIM_VELOCIDAD and cambio_ani == true then
				actual = actual+CONTROL.ANIM_VELOCIDAD
			elseif cambio_ani == true then
				actual = 0
				saibot = false
			elseif actual < CONTROL.ANCHO+CONTROL.ANIM_VELOCIDAD and cambio_ani == false then
				actual = actual+CONTROL.ANIM_VELOCIDAD
			elseif actual >= CONTROL.ANCHO+CONTROL.ANIM_VELOCIDAD and cambio_ani == false then
				actual = ((minimo+maximo)*(-1))-CONTROL.ANIM_VELOCIDAD
				cargar_logo(LISTAS.IDENTIDAD)
				cambio_ani = true
			end

		-- Animación estilo 2 / estilo 3. -----------------------------------------------
		elseif lado == true and (CONTROL.CUSTOM_ANIM == 2 or CONTROL.CUSTOM_ANIM == 3) and trans_especial == false then
			if actual >= minimo and cambio_ani == true then
				actual = actual-CONTROL.ANIM_VELOCIDAD
			elseif cambio_ani == true then
				actual = 0
				saibot = false
			elseif actual+maximo > 0-CONTROL.ANIM_VELOCIDAD and cambio_ani == false then
				actual = actual-CONTROL.ANIM_VELOCIDAD
			elseif actual+maximo <= 0-CONTROL.ANIM_VELOCIDAD and cambio_ani == false then
				actual = CONTROL.ALTO+CONTROL.ANIM_VELOCIDAD
				cargar_logo(LISTAS.IDENTIDAD)
				cambio_ani = true
			end
		elseif lado == false and (CONTROL.CUSTOM_ANIM == 2 or CONTROL.CUSTOM_ANIM == 3) and trans_especial == false then
			if actual+CONTROL.ANIM_VELOCIDAD <= minimo and cambio_ani == true then
				actual = actual+CONTROL.ANIM_VELOCIDAD
			elseif cambio_ani == true then
				actual = 0
				saibot = false
			elseif actual < CONTROL.ALTO+CONTROL.ANIM_VELOCIDAD and cambio_ani == false then
				actual = actual+CONTROL.ANIM_VELOCIDAD
			elseif actual >= CONTROL.ALTO+CONTROL.ANIM_VELOCIDAD and cambio_ani == false then
				actual = ((minimo+maximo)*(-1))-CONTROL.ANIM_VELOCIDAD
				cargar_logo(LISTAS.IDENTIDAD)
				cambio_ani = true
			end

		-- Animación estilo 4 / estilo 5 / estilo 6 / estilo 7 / estilo 8. --------------
		elseif CONTROL.CUSTOM_ANIM >= 4 or trans_especial == true then
			if actual >= 1 and cambio_ani == true then
				actual = actual-(CONTROL.ANIM_VELOCIDAD//10)
			elseif cambio_ani == true then
				actual = 0
				saibot = false
			elseif actual < 42 and cambio_ani == false then
				actual = actual+(CONTROL.ANIM_VELOCIDAD//10)
			elseif actual >= 42 and cambio_ani == false then
				actual = 42
				cargar_logo(LISTAS.IDENTIDAD)
				color_emu(LISTAS.IDENTIDAD)
				cambio_ani = true
				mostrar_ant = false
			end
		end

		-- Mostrar todo en pantalla. ----------------------------------------------------
		RGB()
		dibujar_fondos()
		if mostrar_ant == false then
			-- Posicionar elementos. ----------------------------------------------------
			local representar = {actual+CONTROL.IMG_ANCHO, actual+CONTROL.LISTA_ANCHO, actual+CONTROL.LOGO_ANCHO, actual+CONTROL.IMG_ANCHO_2, actual+CONTROL.FLOW_ANCHO, actual+CONTROL.FLOW_ANCHO_2, CONTROL.IMG_ALTO, CONTROL.LISTA_ALTO, CONTROL.LOGO_ALTO, CONTROL.IMG_ALTO_2, CONTROL.FLOW_ALTO, CONTROL.FLOW_ALTO_2}
			if CONTROL.CUSTOM_ANIM == 2 then
				representar = {CONTROL.IMG_ANCHO, CONTROL.LISTA_ANCHO, CONTROL.LOGO_ANCHO, CONTROL.IMG_ANCHO_2, CONTROL.FLOW_ANCHO, CONTROL.FLOW_ANCHO_2, actual+CONTROL.IMG_ALTO, actual+CONTROL.LISTA_ALTO, actual+CONTROL.LOGO_ALTO, actual+CONTROL.IMG_ALTO_2, actual+CONTROL.FLOW_ALTO, actual+CONTROL.FLOW_ALTO_2}
			elseif CONTROL.CUSTOM_ANIM == 3 then
				representar = {actual+CONTROL.IMG_ANCHO, actual+CONTROL.LISTA_ANCHO, actual+CONTROL.LOGO_ANCHO, actual+CONTROL.IMG_ANCHO_2, actual+CONTROL.FLOW_ANCHO, actual+CONTROL.FLOW_ANCHO_2, actual+CONTROL.IMG_ALTO, actual+CONTROL.LISTA_ALTO, actual+CONTROL.LOGO_ALTO, actual+CONTROL.IMG_ALTO_2, actual+CONTROL.FLOW_ALTO, actual+CONTROL.FLOW_ALTO_2}
			elseif CONTROL.CUSTOM_ANIM >= 4 or trans_especial == true then
				representar = {CONTROL.IMG_ANCHO, CONTROL.LISTA_ANCHO, CONTROL.LOGO_ANCHO, CONTROL.IMG_ANCHO_2, CONTROL.FLOW_ANCHO, CONTROL.FLOW_ANCHO_2, CONTROL.IMG_ALTO, CONTROL.LISTA_ALTO, CONTROL.LOGO_ALTO, CONTROL.IMG_ALTO_2, CONTROL.FLOW_ALTO, CONTROL.FLOW_ALTO_2}
			end

			-- Dibujar elementos. -------------------------------------------------------
			if CONTROL.ESTILO == 3 and OPCIONES.GUI_LIMPIA_ON == 1 and CONTROL.CUSTOM_LIST == true then
				Graphics.drawRect(representar[2]-3, representar[8]-3, CONTROL.LISTA_X+236+6, CONTROL.LISTA_Y+6, COLOR.NEGRO_T)
			elseif CONTROL.ESTILO ~= 2 and CONTROL.CUSTOM_LIST == true then
				Graphics.drawRect(representar[2]-3, representar[8]-3, CONTROL.LISTA_X+6, CONTROL.LISTA_Y+6, COLOR.NEGRO_T)
			end
			if CONTROL.CUSTOM_ART1 == true then
				Graphics.drawRect(representar[1]-5, representar[7]-5, CONTROL.IMG_X+10, CONTROL.IMG_Y+10, COLOR.NEGRO_T)
			end
			if (CONTROL.ESTILO == 3 or CONTROL.ESTILO == 5 or CONTROL.ESTILO == 6 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_ART2 == true then
				Graphics.drawRect(representar[4]-5, representar[10]-5, CONTROL.IMG_X_2+10, CONTROL.IMG_Y_2+10, COLOR.NEGRO_T)
			end
			if (CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_FLOW == true then
				Graphics.drawRect(representar[5]-5, representar[11]-5, CONTROL.FLOW_X+10, CONTROL.FLOW_Y+10, COLOR.NEGRO_T)
				Graphics.drawRect(representar[6]-5, representar[12]-5, CONTROL.FLOW_X_2+10, CONTROL.FLOW_Y_2+10, COLOR.NEGRO_T)
			end

			-- Dibujar Logo. ------------------------------------------------------------
			if CONTROL.CUSTOM_LOGO == true then
				Graphics.drawScaleImage(LISTAS.LOGO, representar[3], representar[9], CONTROL.LOGO_X, CONTROL.LOGO_Y)
			end
		end

		-- Dibujar elementos extras. ----------------------------------------------------
		if CONTROL.CUSTOM_ANIM == 4 or trans_especial == true then
			local suma_x, suma_y = 0, 0
			for contador = 40, CONTROL.ALTO+40, 40 do
				for contador2 = -8, CONTROL.ANCHO+40, 40 do
					suma_x = contador2
					Graphics.drawRect(suma_x-(actual//2)+4, suma_y-(actual//2)+4, actual+4, actual+4, Color.new(0, 0, 0, (actual*3)))
				end
				suma_y = contador
			end
		end
		if CONTROL.CUSTOM_ANIM == 6 and trans_especial == false then
			Graphics.drawRect(0, 0, CONTROL.ANCHO, CONTROL.ALTO, Color.new(0, 0, 0, (actual*3)))
		elseif CONTROL.CUSTOM_ANIM == 5 and trans_especial == false then
			Graphics.drawRect(0, 0, CONTROL.ANCHO, CONTROL.ALTO, Color.new(CAMBIOS_EMUS.R, CAMBIOS_EMUS.G, CAMBIOS_EMUS.B, (actual*3)))
		end
		if CONTROL.CUSTOM_ANIM == 7 and trans_especial == false then
			Graphics.drawCircle(CONTROL.ANCHO, CONTROL.ALTO, actual*15, Color.new(0, 0, 0, (actual*3)))
			Graphics.drawCircle(80, 80, actual, Color.new(0, 0, 0, (actual*3)))
			Graphics.drawCircle(140, 200, actual*2, Color.new(0, 0, 0, (actual*3)))
			Graphics.drawCircle(180, 320, actual*10, Color.new(0, 0, 0, (actual*3)))
			Graphics.drawCircle(30, 40, actual*4, Color.new(0, 0, 0, (actual*3)))
			Graphics.drawCircle(500, 70, actual*5, Color.new(0, 0, 0, (actual*3)))
			Graphics.drawCircle(600, 30, actual*3, Color.new(0, 0, 0, (actual*3)))
			Graphics.drawCircle(10, CONTROL.ALTO, actual*9, Color.new(0, 0, 0, (actual*3)))
			Graphics.drawCircle(610, 340, actual*2, Color.new(0, 0, 0, (actual*3)))
			Graphics.drawCircle(220, 30, actual, Color.new(0, 0, 0, (actual*3)))
		end
		if CONTROL.CUSTOM_ANIM == 8 and trans_especial == false then
			local inicio, final, salto, valor = 0, CONTROL.ANCHO, 16, actual//2
			if lado == false then inicio, final, salto, valor = CONTROL.ANCHO, -1, -16, actual*(-1)//2 end
			for contador = inicio, final, salto do
				Graphics.drawRect(contador, 0, valor, CONTROL.ALTO, Color.new(0, 0, 0, (actual*3)))
			end
		end
		refrescar(false)
	end
end

--- Determina los colores predeterminados de cada emulador. -----------------------------
function color_emu(identidad)
	local EMU_1 = 128
	local EMU_2 = 128
	local EMU_3 = 128
	local R = 128
	local G = 128
	local B = 128
	local MAX = 0
	local MIN = 0
	local RGB = 0
	local ACTUAL = 128
	local BLANCO_1 = 74
	local BLANCO_2 = 74
	local BLANCO_3 = 74

	-- Colores para Sega Megadrive. -----------------------------------------------------
	if identidad == 1 and OPCIONES.FONDO_RGB_ON == 1 and OPCIONES.FONDO_RGB_FIJO_ON == 0 then
		EMU_1 = 128; EMU_2 = 128; EMU_3 = 128;
		R = 128; G = 118; B = 118;
		MAX = 128; MIN = 118; RGB = 4; ACTUAL = 118; 
		BLANCO_1 = 74; BLANCO_2 = 74; BLANCO_3 = 74;

	-- Colores para Sega Master System. -------------------------------------------------
	elseif identidad == 2 and OPCIONES.FONDO_RGB_ON == 1 and OPCIONES.FONDO_RGB_FIJO_ON == 0 then
		EMU_1 = 0; EMU_2 = 60; EMU_3 = 128;
		R = 0; G = 50; B = 128;
		MAX = 70; MIN = 50; RGB = 2; ACTUAL = 50;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para Sega Game Gear. -----------------------------------------------------
	elseif identidad == 3 and OPCIONES.FONDO_RGB_ON == 1 and OPCIONES.FONDO_RGB_FIJO_ON == 0 then
		EMU_1 = 0; EMU_2 = 90; EMU_3 = 100;
		R = 0; G = 90; B = 100;
		MAX = 120; MIN = 90; RGB = 2; ACTUAL = 90;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para Nintendo Famicom. ---------------------------------------------------
	elseif identidad == 4 and OPCIONES.FONDO_RGB_ON == 1 and OPCIONES.FONDO_RGB_FIJO_ON == 0 then
		EMU_1 = 128; EMU_2 = 25; EMU_3 = 25;
		R = 128; G = 1; B = 1;
		MAX = 26; MIN = 1; RGB = 4; ACTUAL = 1;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para Nintendo Game Boy. --------------------------------------------------
	elseif identidad == 5 and OPCIONES.FONDO_RGB_ON == 1 and OPCIONES.FONDO_RGB_FIJO_ON == 0 then
		EMU_1 = 0; EMU_2 = 128; EMU_3 = 20;
		R = 0; G = 100; B = 0;
		MAX = 120; MIN = 100; RGB = 2; ACTUAL = 100;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para Nintendo Game Boy Color. --------------------------------------------
	elseif identidad == 6 and OPCIONES.FONDO_RGB_ON == 1 and OPCIONES.FONDO_RGB_FIJO_ON == 0 then
		EMU_1 = 110; EMU_2 = 110; EMU_3 = 10;
		R = 100; G = 100; B = 0;
		MAX = 120; MIN = 100; RGB = 2; ACTUAL = 100;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para Nintendo Game Boy Advance. ------------------------------------------
	elseif identidad == 7 and OPCIONES.FONDO_RGB_ON == 1 and OPCIONES.FONDO_RGB_FIJO_ON == 0 then
		EMU_1 = 118; EMU_2 = 25; EMU_3 = 118;
		R = 100; G = 0; B = 100;
		MAX = 120; MIN = 100; RGB = 5; ACTUAL = 100;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para Atari 2600. ---------------------------------------------------------
	elseif identidad == 8 and OPCIONES.FONDO_RGB_ON == 1 and OPCIONES.FONDO_RGB_FIJO_ON == 0 then
		EMU_1 = 128; EMU_2 = 80; EMU_3 = 20;
		R = 128; G = 48; B = 0;
		MAX = 70; MIN = 48; RGB = 2; ACTUAL = 48;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para Sega SG 1000. -------------------------------------------------------
	elseif identidad == 9 and OPCIONES.FONDO_RGB_ON == 1 and OPCIONES.FONDO_RGB_FIJO_ON == 0 then
		EMU_1 = 0; EMU_2 = 120; EMU_3 = 80;
		R = 0; G = 100; B = 50;
		MAX = 70; MIN = 50; RGB = 3; ACTUAL = 50;
		BLANCO_1 = 74; BLANCO_2 = 74; BLANCO_3 = 74;

	-- Colores para Neo Geo Pocket. -----------------------------------------------------
	elseif identidad == 10 and OPCIONES.FONDO_RGB_ON == 1 and OPCIONES.FONDO_RGB_FIJO_ON == 0 then
		EMU_1 = 128; EMU_2 = 30; EMU_3 = 70;
		R = 128; G = 0; B = 40;
		MAX = 60; MIN = 40; RGB = 3; ACTUAL = 40;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para Nintendo Super Famicom. ---------------------------------------------
	elseif identidad == 11 and OPCIONES.FONDO_RGB_ON == 1 and OPCIONES.FONDO_RGB_FIJO_ON == 0 then
		EMU_1 = 108; EMU_2 = 25; EMU_3 = 108;
		R = 100; G = 50; B = 100;
		MAX = 120; MIN = 100; RGB = 5; ACTUAL = 100;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para APPS. ---------------------------------------------------------------
	elseif identidad == 12 and OPCIONES.FONDO_RGB_ON == 1 and OPCIONES.FONDO_RGB_FIJO_ON == 0 then
		EMU_1 = 0; EMU_2 = 100; EMU_3 = 128;
		R = 0; G = 100; B = 128;
		MAX = 128; MIN = 100; RGB = 2; ACTUAL = 100;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para Play Station. -------------------------------------------------------
	elseif identidad == 13 and OPCIONES.FONDO_RGB_ON == 1 and OPCIONES.FONDO_RGB_FIJO_ON == 0 then
		EMU_1 = 0; EMU_2 = 60; EMU_3 = 128;
		R = 0; G = 60; B = 128;
		MAX = 80; MIN = 60; RGB = 2; ACTUAL = 60;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para Play Station 2. -----------------------------------------------------
	elseif identidad == 14 and OPCIONES.FONDO_RGB_ON == 1 and OPCIONES.FONDO_RGB_FIJO_ON == 0 then
		EMU_1 = 0; EMU_2 = 80; EMU_3 = 128;
		R = 0; G = 80; B = 128;
		MAX = 100; MIN = 80; RGB = 2; ACTUAL = 80;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores personalizados. ----------------------------------------------------------
	elseif OPCIONES.FONDO_RGB_FIJO_ON == 1 then
		EMU_1 = OPCIONES.R; EMU_2 = OPCIONES.G; EMU_3 = OPCIONES.B;
		R = OPCIONES.R; G = OPCIONES.G; B = OPCIONES.B;
		MAX = 0; MIN = 0; RGB = 0; ACTUAL = 0;
		BLANCO_1 = 74; BLANCO_2 = 74; BLANCO_3 = 74;

	-- Sin colores. ---------------------------------------------------------------------
	elseif OPCIONES.FONDO_RGB_ON == 0 then
		EMU_1 = 128; EMU_2 = 128; EMU_3 = 128;
		R = 128; G = 128; B = 128;
		MAX = 0; MIN = 0; RGB = 0; ACTUAL = 128;
		BLANCO_1 = 74; BLANCO_2 = 74; BLANCO_3 = 74;
	end

	-- Aplicar colores. -----------------------------------------------------------------
	CAMBIOS_EMUS.COLOR_EMU = Color.new(EMU_1, EMU_2, EMU_3)
	CAMBIOS_EMUS.R = R; CAMBIOS_EMUS.G = G; CAMBIOS_EMUS.B = B;
	CAMBIOS_EMUS.COLOR_MAX = MAX; CAMBIOS_EMUS.COLOR_MIN = MIN; CAMBIOS_EMUS.RGB_COLOR = RGB;
	CAMBIOS_EMUS.COLOR_ACTUAL = ACTUAL;
	COLOR.BLANCO_LISTA = Color.new(BLANCO_1, BLANCO_2, BLANCO_3)
end

--- Realiza el efecto de cambio de colores del fondo. -----------------------------------
function RGB()
	if CAMBIOS_EMUS.CAM_COLOR_ACTUAL == true and OPCIONES.FONDO_RGB_FIJO_ON == 0 then
		if CAMBIOS_EMUS.COLOR_ACTUAL <= CAMBIOS_EMUS.COLOR_MAX then
			CAMBIOS_EMUS.COLOR_ACTUAL = CAMBIOS_EMUS.COLOR_ACTUAL+1
		else
			CAMBIOS_EMUS.CAM_COLOR_ACTUAL = false
		end
	elseif CAMBIOS_EMUS.CAM_COLOR_ACTUAL == false then
		if CAMBIOS_EMUS.COLOR_ACTUAL >= CAMBIOS_EMUS.COLOR_MIN then
			CAMBIOS_EMUS.COLOR_ACTUAL = CAMBIOS_EMUS.COLOR_ACTUAL-1
		else
			CAMBIOS_EMUS.CAM_COLOR_ACTUAL = true
		end
	end
	if (CAMBIOS_EMUS.RGB_COLOR == 0 or OPCIONES.RGB_ON == 0) and OPCIONES.FONDO_RGB_FIJO_ON == 0 then
		CAMBIOS_EMUS.COLOR_EMU_BACK = Color.new(CAMBIOS_EMUS.R, CAMBIOS_EMUS.G, CAMBIOS_EMUS.B)
	elseif (CAMBIOS_EMUS.RGB_COLOR == 0 or OPCIONES.RGB_ON == 0) and OPCIONES.FONDO_RGB_FIJO_ON == 1 then
		if CAMBIOS_EMUS.TRAS == 0 then
			CAMBIOS_EMUS.COLOR_EMU_BACK = Color.new(CAMBIOS_EMUS.R, CAMBIOS_EMUS.G, CAMBIOS_EMUS.B)
		else
			CAMBIOS_EMUS.COLOR_EMU_BACK = Color.new(CAMBIOS_EMUS.R, CAMBIOS_EMUS.G, CAMBIOS_EMUS.B, CAMBIOS_EMUS.TRAS)
		end
	elseif CAMBIOS_EMUS.RGB_COLOR == 1 then
		CAMBIOS_EMUS.COLOR_EMU_BACK = Color.new(CAMBIOS_EMUS.COLOR_ACTUAL, CAMBIOS_EMUS.G, CAMBIOS_EMUS.B)
	elseif CAMBIOS_EMUS.RGB_COLOR == 2 then
		CAMBIOS_EMUS.COLOR_EMU_BACK = Color.new(CAMBIOS_EMUS.R, CAMBIOS_EMUS.COLOR_ACTUAL, CAMBIOS_EMUS.B)
	elseif CAMBIOS_EMUS.RGB_COLOR == 3 then
		CAMBIOS_EMUS.COLOR_EMU_BACK = Color.new(CAMBIOS_EMUS.R, CAMBIOS_EMUS.G, CAMBIOS_EMUS.COLOR_ACTUAL)
	elseif CAMBIOS_EMUS.RGB_COLOR == 4 then
		CAMBIOS_EMUS.COLOR_EMU_BACK = Color.new(CAMBIOS_EMUS.R, CAMBIOS_EMUS.COLOR_ACTUAL, CAMBIOS_EMUS.COLOR_ACTUAL)
	elseif CAMBIOS_EMUS.RGB_COLOR == 5 then
		CAMBIOS_EMUS.COLOR_EMU_BACK = Color.new(CAMBIOS_EMUS.COLOR_ACTUAL, CAMBIOS_EMUS.G, CAMBIOS_EMUS.COLOR_ACTUAL)
	elseif CAMBIOS_EMUS.RGB_COLOR == 6 then
		CAMBIOS_EMUS.COLOR_EMU_BACK = Color.new(CAMBIOS_EMUS.COLOR_ACTUAL, CAMBIOS_EMUS.COLOR_ACTUAL, CAMBIOS_EMUS.B)
	elseif CAMBIOS_EMUS.RGB_COLOR == 7 then
		CAMBIOS_EMUS.COLOR_EMU_BACK = Color.new(CAMBIOS_EMUS.COLOR_ACTUAL, CAMBIOS_EMUS.COLOR_ACTUAL, CAMBIOS_EMUS.COLOR_ACTUAL)
	end
end

--- Determina qué logo cargar de acuerdo al emulador. -----------------------------------
function cargar_logo(identidad)
	if identidad == 1 then
		LISTAS.LOGO = LOGOS.MEGADRIVE
	elseif identidad == 2 then
		LISTAS.LOGO = LOGOS.MASTERSYSTEM
	elseif identidad == 3 then
		LISTAS.LOGO = LOGOS.GAMEGEAR
	elseif identidad == 4 then
		LISTAS.LOGO = LOGOS.FAMICOM
	elseif identidad == 5 then
		LISTAS.LOGO = LOGOS.GAMEBOY
	elseif identidad == 6 then
		LISTAS.LOGO = LOGOS.GAMEBOYCOLOR
	elseif identidad == 7 then
		LISTAS.LOGO = LOGOS.GAMEBOYADVANCE
	elseif identidad == 8 then
		LISTAS.LOGO = LOGOS.ATARI2600
	elseif identidad == 9 then
		LISTAS.LOGO = LOGOS.SEGASG1000
	elseif identidad == 10 then
		LISTAS.LOGO = LOGOS.NEOGEOPOCKET
	elseif identidad == 11 then
		LISTAS.LOGO = LOGOS.SUPERFAMICOM
	elseif identidad == 12 then
		LISTAS.LOGO = LOGOS.APPS
	elseif identidad == 13 then
		LISTAS.LOGO = LOGOS.PLAYSTATION
	elseif identidad == 14 then
		LISTAS.LOGO = LOGOS.PLAYSTATION2
	else
		LISTAS.LOGO = LOGOS.DEFAULT
	end
end

--- Menú de configuración PS2. ----------------------------------------------------------
function menu_neutrino(nombre_iso)
	Pads.rumble(0, 0, 0)
	local actual = System.currentDirectory()
	local device = salida_texto_dir(actual, nil)
	local selector = 1
	local pregunta = true

	-- Mensaje de búsqueda. -------------------------------------------------------------
	dibujar_fondos()
	Graphics.drawScaleImage(LISTAS.LOGO, 194, 0+CONTROL.Y_FIX_PAL, 252, 76)
	for a = 1, 2, 1 do Graphics.drawRect(12, 71+CONTROL.Y_FIX_PAL, 615, 368, COLOR.NEGRO_T) end
	Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), (CONTROL.ALTO//2)-40, 8, 540, 25, "-SEARCH FOR GAME SETTINGS-", COLOR.BLANCO)
	refrescar(false)

	-- Buscar archivos de configuración del juego. --------------------------------------
	OPCIONES.PREGUNTAR_PS2 = true
	local VMCD, MODE, GSM = ejecutar_iso(nombre_iso)
	OPCIONES.PREGUNTAR_PS2 = false

	-- Cargar configuración de "VMC". ---------------------------------------------------
	local tipo = 1
	if string.lower(string.sub(nombre_iso, -4)) == ".mx4" then
		tipo = 2
	elseif string.lower(string.sub(nombre_iso, -4)) == ".hdd" then
		tipo = 3
	elseif string.lower(string.sub(nombre_iso, -4)) == ".mmc" then
		tipo = 4
	end
	local VMC_encontradas = buscar_VMC(tipo)
	local selector_VMC = 1
	if #VMC_encontradas <= 0 then
		selector_VMC = 0
	elseif #VMC_encontradas >= 1 and VMCD ~= nil then
		for contador = 1, #VMC_encontradas do
			if string.lower(VMC_encontradas[contador]) == string.lower(string.sub(VMCD, 6)) then
				selector_VMC = contador
			end
		end
	end
	local encontrado_vmcd = 0
	if VMCD ~= nil then encontrado_vmcd = 1 end

	-- Cargar modos de compatibilidad. --------------------------------------------------
	local modo_0, modo_1, modo_2, modo_3, modo_5, modo_7 = 0, 0, 0, 0, 0, 0
	if MODE ~= nil then
		if string.match(MODE, "0") == "0" then modo_0 = 1 end
		if string.match(MODE, "1") == "1" then modo_1 = 1 end
		if string.match(MODE, "2") == "2" then modo_2 = 1 end
		if string.match(MODE, "3") == "3" then modo_3 = 1 end
		if string.match(MODE, "5") == "5" then modo_5 = 1 end
		if string.match(MODE, "7") == "7" then modo_7 = 1 end
	end

	-- Cargar modos de "GMS". -----------------------------------------------------------
	local gsm_modes = {0, 0, 0}
	local gsm_text_field_mode = {"OFF", "480p/576p"}
	local gsm_text_frame_mode = {"OFF", "240p/288p", "Line Doubling"}
	local gsm_text_mode = {"OFF", "Field Flipping / 1", "Field Flipping / 2", "Field Flipping / 3"}
	if GSM ~= nil then
		if string.match(GSM, "=fp") == "=fp" then gsm_modes[1] = 1 end
		if string.match(GSM, ":fp1") == ":fp1" then gsm_modes[2] = 1
			elseif string.match(GSM, ":fp2") == ":fp2" then gsm_modes[2] = 2 end
		if string.match(GSM, ":1") == ":1" then gsm_modes[3] = 1
			elseif string.match(GSM, ":2") == ":2" then gsm_modes[3] = 2
				elseif string.match(GSM, ":3") == ":3" then gsm_modes[3] = 3 end
	end

	-- Nombres de las opciones del menú y sus estados. ----------------------------------
	local menus_nombres = {"USE VIRTUAL MEMORY CARD", "NO VIRTUAL MEMORY CARD", "-COMPATIBILITY MODES-", "IOP: FAST READS", "DUMMY", "IOP: SYNC READS", "EE : UNHOOK SYSCALLS", "IOP: EMULATE DVD-DL", "IOP: FIX GAME BUFFER OVERRUN", "-GRAPHICS SYNTHESIZER MODE-", "INTERLACED FIELD MODE:", "INTERLACED FRAME MODE:", "COMPATIBILITY MODE:", "SAVE GAME SETTINGS"}
	local menus_valores = {encontrado_vmcd, selector_VMC, 0, modo_0, modo_1, modo_2, modo_3, modo_5, modo_7, 0, gsm_modes[1], gsm_modes[2], gsm_modes[3], "SAVE"}

	-- Ejecutar y controlar menú de configuración PS2. ----------------------------------
	while pregunta do
		CONTROL.FPS = Screen.getFPS(1)
		capturar(JOYSTICK_LIMITE)

		-- Mostrar todo en pantalla. ----------------------------------------------------
		Screen.clear(COLOR.NEGRO)
		RGB()
		dibujar_fondos()
		if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true and OPCIONES.SCREENSHOT_BACK_ON == 1 then
			Graphics.drawScaleImage(LISTAS.SCREENSHOT, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F)
		end
		Graphics.drawScaleImage(LISTAS.LOGO, 194, 0+CONTROL.Y_FIX_PAL, 252, 76)
		Graphics.drawRect(12, 71+CONTROL.Y_FIX_PAL, 615, 368, COLOR.NEGRO_T)
		Graphics.drawRect(12, 71+CONTROL.Y_FIX_PAL, 615, 43, COLOR.NEGRO_T)
		Graphics.drawRect(12, 162+CONTROL.Y_FIX_PAL, 615, 23, COLOR.NEGRO_T)
		Graphics.drawRect(12, 322+CONTROL.Y_FIX_PAL, 615, 23, COLOR.NEGRO_T)
		Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 74+CONTROL.Y_FIX_PAL, 8, 540, 25, "-GAME SETTINGS-", COLOR.BLANCO)
		Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 164+CONTROL.Y_FIX_PAL, 8, 540, 25, menus_nombres[3], COLOR.BLANCO)
		Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 324+CONTROL.Y_FIX_PAL, 8, 540, 25, menus_nombres[10], COLOR.BLANCO)
		Font.ftPrint(CONTROL.fontARCA, 22, 94+CONTROL.Y_FIX_PAL, 0, 600, 8, nombre_iso, COLOR.BLANCO)
		if OPCIONES.GUI_LIMPIA_ON == 0 then
			Graphics.drawRect(515, 419+CONTROL.Y_FIX_PAL, (OPCIONES.FONT_SHADOW*OPCIONES.FONT_PIXEL_X*(string.len("CANCEL")/2)/3), 20, COLOR.NEGRO_T)
			Graphics.drawScaleImage(PAD_IMG.TRIANGLE, 515-25, 419-1+CONTROL.Y_FIX_PAL, 20, 20)
			Font.ftPrint(CONTROL.fontARCA, 515+3, 419+1+CONTROL.Y_FIX_PAL, 0, 0, 25, "CANCEL", COLOR.BLANCO)
		end
		for contador = 1, #menus_nombres do
			local acti = "STATE: ON"
			if menus_valores[contador] == 0 then acti = "STATE: OFF" end
			if contador == 2 or contador == 3 or contador == 10 then acti = " " end
			local x_fix = 0
			if contador >= 11 and contador <= 13 then x_fix = 120 end
			if contador == 11 then acti = gsm_text_field_mode[menus_valores[11]+1] end
			if contador == 12 then acti = gsm_text_frame_mode[menus_valores[12]+1] end
			if contador == 13 then acti = gsm_text_mode[menus_valores[13]+1] end
			if #VMC_encontradas <= 0 and menus_valores[1] == 1 then
				menus_nombres[2] = "VIRTUAL MEMORY CARD NOT FOUND"
			elseif #VMC_encontradas >= 1 and menus_valores[1] == 1 and selector_VMC >= 1 then
				menus_nombres[2] = string.sub(VMC_encontradas[selector_VMC], 11)
			elseif menus_valores[1] == 0 then
				menus_nombres[2] = "NO VIRTUAL MEMORY CARD"
			end
			local espacio_linea = 95+((contador)*23)+CONTROL.Y_FIX_PAL
			if contador == selector and contador ~= #menus_valores and contador ~= 3 and contador ~= 10 then
				Font.ftPrint(CONTROL.fontARCA, 22, espacio_linea, 0, 600, 25, menus_nombres[selector], CAMBIOS_EMUS.COLOR_EMU)
				Font.ftPrint(CONTROL.fontARCA, 489-x_fix, espacio_linea, 0, 0, 25, acti, CAMBIOS_EMUS.COLOR_EMU)
			elseif contador == selector and contador == #menus_valores and contador ~= 3 and contador ~= 10 then
				Font.ftPrint(CONTROL.fontARCA, 22, espacio_linea, 0, 600, 25, menus_nombres[selector], CAMBIOS_EMUS.COLOR_EMU)
			elseif contador ~= selector and contador ~= #menus_valores and contador ~= 3 and contador ~= 10 then
				Font.ftPrint(CONTROL.fontARCA, 22, espacio_linea, 0, 600, 25, menus_nombres[contador], COLOR.BLANCO_LISTA)
				Font.ftPrint(CONTROL.fontARCA, 489-x_fix, espacio_linea, 0, 0, 25, acti, COLOR.BLANCO_LISTA)
			elseif contador ~= selector and contador == #menus_valores and contador ~= 3 and contador ~= 10 then
				Font.ftPrint(CONTROL.fontARCA, 22, espacio_linea, 0, 600, 25, menus_nombres[contador], COLOR.BLANCO_LISTA)
			end
		end
		refrescar(false)

		-- Moverse por las opciones del menú. -------------------------------------------
		if ((Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) or (Pads.check(PAD, PAD_UP) or Left_Y <= -90)) and CONTROL.JOYSTICK_ON == false then
			if OPCIONES.SOUND_ON == 1 and S_MOVER ~= nil then
				Sound.playADPCM(1, S_MOVER)
			end
			if (selector == 2 or selector == 9) and (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) then
				selector = selector+2
			elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) then
				selector = cambiar_valor(selector, 1, #menus_nombres, 1, true)
			elseif (selector == 4 or selector == 11) and (Pads.check(PAD, PAD_UP) or Left_Y <= -90) then
				selector = selector-2
			elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90) then
				selector = cambiar_valor(selector, 1, #menus_nombres, 1, false)
			end
			CONTROL.JOYSTICK_ON = true
			local kabal = 1 if Left_Y ~= 1 then kabal = 2 end
			JOYSTICK_LIMITE = control_FPS(kabal)

		-- Controlar selector de "VMC" / "GSM". -----------------------------------------
		elseif ((Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90)) and CONTROL.JOYSTICK_ON == false and ((selector >= 11 and selector <= 13) or selector == 2) then
			if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then
				Sound.playADPCM(1, S_EJECUTAR)
			end
			if selector == 2 and #VMC_encontradas >= 1 and menus_valores[1] == 1 and (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
				selector_VMC = cambiar_valor(selector_VMC, 1, #VMC_encontradas, 1, true)
			elseif selector == 2 and #VMC_encontradas >= 1 and menus_valores[1] == 1 and (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
				selector_VMC = cambiar_valor(selector_VMC, 1, #VMC_encontradas, 1, false)
			elseif selector == 2 and #VMC_encontradas <= 0 then
				selector_VMC = 0
			elseif selector >= 11 and selector <= 13 and (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
				local limite_gsm = 1
				if selector == 12 then limite_gsm = 2
					elseif selector == 13 then limite_gsm = 3 end
				menus_valores[selector] = cambiar_valor(menus_valores[selector], 0, limite_gsm, 1, true)
			elseif selector >= 11 and selector <= 13 and (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
				local limite_gsm = 1
				if selector == 12 then limite_gsm = 2
					elseif selector == 13 then limite_gsm = 3 end
				menus_valores[selector] = cambiar_valor(menus_valores[selector], 0, limite_gsm, 1, false)
			end
			CONTROL.JOYSTICK_ON = true
			local kabal = 1 if Left_X ~= 1 then kabal = 2 end
			JOYSTICK_LIMITE = control_FPS(kabal)

		-- Cambiar y guardar configuraciones. -------------------------------------------
		elseif Pads.check(PAD, PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
			if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then
				Sound.playADPCM(1, S_EJECUTAR)
			end
			if selector >= 11 and selector <= 13 then
				local limite_gsm = 1
				if selector == 12 then limite_gsm = 2
					elseif selector == 13 then limite_gsm = 3 end
				menus_valores[selector] = cambiar_valor(menus_valores[selector], 0, limite_gsm, 1, true)
			elseif selector == 2 then
				selector_VMC = cambiar_valor(selector_VMC, 1, #VMC_encontradas, 1, true)
			elseif selector ~= #menus_valores then
				menus_valores[selector] = cambiar_valor(menus_valores[selector], 0, 1, 1, true)
			elseif selector == #menus_valores then
				-- Mensaje de guardado. -------------------------------------------------
				Graphics.drawRect(12, 71+CONTROL.Y_FIX_PAL, 615, 368, COLOR.NEGRO_T)
				Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), (CONTROL.ALTO//2)-40, 8, 540, 25, "-SAVING GAME SETTINGS-", COLOR.BLANCO)
				refrescar(false)

				-- Borrar las configuraciones existentes. -------------------------------
				local conf_del = {".vmcd", ".mode", ".mgsm"}
				for limpiar = 1, #conf_del, 1 do
					if doesFileExist(actual .."/Roms/ISOs PlayStation 2/Configs/".. string.sub(nombre_iso, 1, -5) .. conf_del[limpiar]) then
						System.removeFile(actual .."/Roms/ISOs PlayStation 2/Configs/".. string.sub(nombre_iso, 1, -5) .. conf_del[limpiar])
					end
					if doesFileExist(actual .."/Roms/ISOs PlayStation 2/".. string.sub(nombre_iso, 1, -5) .. conf_del[limpiar]) then
						System.removeFile(actual .."/Roms/ISOs PlayStation 2/".. string.sub(nombre_iso, 1, -5) .. conf_del[limpiar])
					end
					if doesFileExist(device .."/DVD/".. string.sub(nombre_iso, 1, -5) .. conf_del[limpiar]) then
						System.removeFile(device .."/DVD/".. string.sub(nombre_iso, 1, -5) .. conf_del[limpiar])
					end
					if doesFileExist(device .."/CD/".. string.sub(nombre_iso, 1, -5) .. conf_del[limpiar]) then
						System.removeFile(device .."/CD/".. string.sub(nombre_iso, 1, -5) .. conf_del[limpiar])
					end
				end

				-- Generar configuración de "VMC". --------------------------------------
				if menus_valores[1] == 1 and #VMC_encontradas >= 1 then
					local dir = ("-mc0=".. VMC_encontradas[selector_VMC])
					local carga_de_VMC = System.openFile(actual .."/Roms/ISOs PlayStation 2/Configs/".. string.sub(nombre_iso, 1, -5) ..".vmcd", FCREATE)
					System.writeFile(carga_de_VMC, dir, string.len(dir))
					System.closeFile(carga_de_VMC)
				end

				-- Generar configuración de compatibilidad. -----------------------------
				local modos_on = "-gc="
				local crear_modos = false
				local modos_final = {"0", "1", "2", "3", "5", "7"}
				for mc = 4, 9, 1 do
					if menus_valores[mc] == 1 then
						modos_on = modos_on.. modos_final[mc-3]
						crear_modos = true
					end
				end
				if crear_modos == true then
					local carga_de_modos = System.openFile(actual .."/Roms/ISOs PlayStation 2/Configs/".. string.sub(nombre_iso, 1, -5) ..".mode", FCREATE)
					System.writeFile(carga_de_modos, modos_on, string.len(modos_on))
					System.closeFile(carga_de_modos)
				end

				-- Generar configuración de "GSM". --------------------------------------
				local gsm_on = "-gsm="
				if menus_valores[11] > 0 then
					gsm_on = gsm_on.. "fp"
				end
				if menus_valores[12] > 0 then
					if menus_valores[12] == 1 then
						gsm_on = gsm_on.. ":fp1"
					elseif menus_valores[12] == 2 then
						gsm_on = gsm_on.. ":fp2"
					end
				end
				if menus_valores[13] > 0 then
					if menus_valores[12] <= 0 then
						gsm_on = gsm_on.. ":"
					end
					if menus_valores[13] == 1 then
						gsm_on = gsm_on.. ":1"
					elseif menus_valores[13] == 2 then
						gsm_on = gsm_on.. ":2"
					elseif menus_valores[13] == 3 then
						gsm_on = gsm_on.. ":3"
					end
				end
				if gsm_on ~= "-gsm=" then
					local carga_de_gsm = System.openFile(actual .."/Roms/ISOs PlayStation 2/Configs/".. string.sub(nombre_iso, 1, -5) ..".mgsm", FCREATE)
					System.writeFile(carga_de_gsm, gsm_on, string.len(gsm_on))
					System.closeFile(carga_de_gsm)
				end
				pregunta = false
			end
			CONTROL.JOYSTICK_ON = true
			JOYSTICK_LIMITE = control_FPS(1)

		-- Cancelar configuración y salir del menú. -------------------------------------
		elseif Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
			if OPCIONES.SOUND_ON == 1 and S_CANCELAR ~= nil then
				Sound.playADPCM(1, S_CANCELAR)
			end
			if OPCIONES.VIBRATION_ON == 1 then
				Pads.rumble(0, 250, 250)
			end
			pregunta = false
			CONTROL.JOYSTICK_ON = true
			JOYSTICK_LIMITE = control_FPS(1)
		end
	end
	animaciones(nil)
end

--- Busca y guarda "VMC" de PS2. --------------------------------------------------------
function buscar_VMC(tipo)
	local exten = ".bin"
	if tipo == 2 then
		exten = ".mx4"
	elseif tipo == 3 then
		exten = ".hdd"
	elseif tipo == 4 then
		exten = ".mmc"
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

--- Busca el nombre del juego DVD PS2. --------------------------------------------------
function obtener_nombre_DVD(nombre_id, exten)
	local ext = "    "
	if exten == true then
		ext = ".elf"
	end
	local nombre = "PS2 DISK: ".. nombre_id .. ext
	local actual = System.currentDirectory()
	if doesFileExist(actual.. "/System/Respaldo/PS2_IDs.cfg") then
		local carga_id = System.openFile(actual.. "/System/Respaldo/PS2_IDs.cfg", FREAD)
		System.seekFile(carga_id, 0, SET)
		local size = System.sizeFile(carga_id)
		local temp_tex = System.readFile(carga_id, size)
		for linea in string.gmatch(temp_tex, nombre_id .."=.+\n") do
			local salto = string.find(linea, "=")
			local fin = string.find(linea, "\n")
			local extra = string.find(linea, "\r\n")
			if salto ~= nil and fin ~= nil and extra ~= nil then
				nombre = (string.sub(linea, salto+1, fin-2).. ext)
			elseif salto ~= nil and fin ~= nil and extra == nil then
				nombre = (string.sub(linea, salto+1, fin-1).. ext)
			end
		end
		System.closeFile(carga_id)
	end
	return nombre
end

--- Determina el directorio de la aplicación. -------------------------------------------
function salida_texto_dir(texto, archivo)
	if archivo == true or archivo == false then
		local final_dir = string.reverse(texto)
		local borrar = string.find(final_dir, "/", 1, false)
		final_dir = string.reverse(final_dir)
		if borrar ~= nil and archivo == false then
			final_dir = string.sub(final_dir, 1, -borrar)
		elseif borrar ~= nil and archivo == true then
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

--- Busca el nombre de APPS (SAS) en el archivo ".cfg". ---------------------------------
function obtener_nombre_SAS(archivo_cfg, nombre_APP)
	local nombre = nombre_APP
	if doesFileExist(archivo_cfg) then
		local carga_cfg = System.openFile(archivo_cfg, FREAD)
		System.seekFile(carga_cfg, 0, SET)
		local size = System.sizeFile(carga_cfg)
		local temp_tex = System.readFile(carga_cfg, size)
		for linea in string.gmatch(temp_tex, "title=.+") do
			local salto = string.find(linea, "\n")
			if salto ~= nil then
				if string.sub(linea, salto-1, salto) == "\r\n" then
					nombre = (string.sub(linea, 7, salto-2).. "    ")
				else
					nombre = (string.sub(linea, 7, salto-1).. "    ")
				end
			else
				nombre = (string.sub(linea, 7).. "    ")
			end
		end
		System.closeFile(carga_cfg)
	end
	return nombre
end

--- Precargar las listas de cada sistema. -----------------------------------------------
function recargar_todas()
	local crea = {}
	local sistemas_on = {SISTEMAS.MEGADRIVE_ON, SISTEMAS.MASTERSYSTEM_ON, SISTEMAS.GAMEGEAR_ON, SISTEMAS.FAMICOM_ON, SISTEMAS.GAMEBOY_ON, SISTEMAS.GAMEBOYCOLOR_ON, SISTEMAS.GAMEBOYADVANCE_ON, SISTEMAS.ATARI2600_ON, SISTEMAS.SEGASG1000_ON, SISTEMAS.NEOGEOPOCKET_ON, SISTEMAS.SUPERFAMICOM_ON, SISTEMAS.APPS_ON, SISTEMAS.PLAYSTATION_ON, SISTEMAS.PLAYSTATION2_ON}
	for contador = 1, 14, 1 do
		local nueva = {}
		if sistemas_on[contador] == 1 then
			nueva = crear_listas(contador, nueva)
		end
		table.insert(crea, nueva)
	end
	PRE_CARGADAS = crea
	LISTAS.IDENTIDAD = 1
end

--- Recarga un sistema determinado. -----------------------------------------------------
function recargar_una(identidad)
	PRE_CARGADAS[identidad] = crear_listas(identidad, PRE_CARGADAS[identidad])
	LISTAS.IDENTIDAD = identidad
end

--- Buscar y guardar fuentes de texto. --------------------------------------------------
function buscar_fuentes()
	local actual = System.currentDirectory()
	local buscar_fuentes = System.listDirectory(actual .."/Multimedia/Others/Font")
	OPCIONES.FUENTES_ENCONTRADAS = {}
	table.insert(OPCIONES.FUENTES_ENCONTRADAS, actual .."/System/Medios/Font/PublicPixel.ttf")
	if buscar_fuentes ~= nil then
		for contador = 1, #buscar_fuentes do
			if buscar_fuentes[contador].directory == false and (string.lower(string.sub(buscar_fuentes[contador].name, -4)) == ".ttf" or string.lower(string.sub(buscar_fuentes[contador].name, -4)) == ".otf") then
				table.insert(OPCIONES.FUENTES_ENCONTRADAS, actual .."/Multimedia/Others/Font/".. buscar_fuentes[contador].name)
			end
		end
	end
end

--- Buscar y guardar fondos de pantallas. -----------------------------------------------
function buscar_fondos()
	local actual = System.currentDirectory()
	local buscar_fondos = System.listDirectory(actual .."/Multimedia/Others/Background")
	OPCIONES.FONDO_ENCONTRADOS = {}
	table.insert(OPCIONES.FONDO_ENCONTRADOS, actual .."/System/Medios/Default/FONDO.png")
	if buscar_fondos ~= nil then
		for contador = 1, #buscar_fondos do
			if buscar_fondos[contador].directory == false and string.lower(string.sub(buscar_fondos[contador].name, -4)) == ".png" then
				table.insert(OPCIONES.FONDO_ENCONTRADOS, actual .."/Multimedia/Others/Background/".. buscar_fondos[contador].name)
			end
		end
	end
end

--- Buscar y guardar directorios / Buscar y guardar aplicaciones. -----------------------
function buscar_directorio(dir)
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
		local actual = System.currentDirectory()
		local device = salida_texto_dir(actual, nil)
		if OPCIONES.SALIDA_RETROLANCHER_ON == 0 then
			OPCIONES.SALIDA_RETROLANCHER = "PS2 SYSTEM MENU"
			OPCIONES.SALIDA_DIR_ACTUALES, OPCIONES.SALIDA_DIR_ANTERIORES = {}, {}
		elseif OPCIONES.SALIDA_RETROLANCHER_ON == 1 then
			OPCIONES.SALIDA_RETROLANCHER = "mc0:/"
			OPCIONES.SALIDA_DIR_ACTUALES, OPCIONES.SALIDA_DIR_ANTERIORES = {}, {}
		elseif OPCIONES.SALIDA_RETROLANCHER_ON == 2 then
			OPCIONES.SALIDA_RETROLANCHER = "mc1:/"
			OPCIONES.SALIDA_DIR_ACTUALES, OPCIONES.SALIDA_DIR_ANTERIORES = {}, {}
		elseif OPCIONES.SALIDA_RETROLANCHER_ON == 3 then
			OPCIONES.SALIDA_RETROLANCHER = device .."/"
			OPCIONES.SALIDA_DIR_ACTUALES, OPCIONES.SALIDA_DIR_ANTERIORES = {}, {}
		end
	end
	if #OPCIONES.SALIDA_DIR_ACTUALES >= 1 then
		table.sort(OPCIONES.SALIDA_DIR_ACTUALES, orden_alfabetico)
	end
end

--- Muestra mini explorador de directorios. ---------------------------------------------
function marcar_directorio()
	local selector = 1
	local cachucho = true
	CONTROL.JOYSTICK_ON = true
	JOYSTICK_LIMITE = control_FPS(1)-20
	buscar_directorio(true)
	while cachucho do
		CONTROL.FPS = Screen.getFPS(1)
		capturar(JOYSTICK_LIMITE)
		tiempo_de_scroll()

		-- Controlar menú explorador. ---------------------------------------------------
		if Pads.check(PAD, PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
			if #OPCIONES.SALIDA_DIR_ANTERIORES >= 1 then
				OPCIONES.SALIDA_RETROLANCHER = OPCIONES.SALIDA_DIR_ACTUALES[selector]
			elseif #OPCIONES.SALIDA_DIR_ANTERIORES <= 0 then
				buscar_directorio(nil)
			end
			buscar_directorio(true)
			CONTROL.JOYSTICK_ON = true
			JOYSTICK_LIMITE = control_FPS(1)-5
			selector = 1
			LISTAS.SCROLL_TEX = 1
			reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
			if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then
				Sound.playADPCM(1, S_EJECUTAR)
			end
		elseif Pads.check(PAD, PAD_CIRCLE) and CONTROL.JOYSTICK_ON == false then
			if #OPCIONES.SALIDA_DIR_ANTERIORES >= 1 then
				buscar_directorio(false)
			else
				buscar_directorio(nil)
				buscar_directorio(true)
			end
			CONTROL.JOYSTICK_ON = true
			JOYSTICK_LIMITE = control_FPS(1)-5
			selector = 1
			LISTAS.SCROLL_TEX = 1
			reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
			if OPCIONES.SOUND_ON == 1 and S_CANCELAR ~= nil then
				Sound.playADPCM(1, S_CANCELAR)
			end
		elseif ((Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) or (Pads.check(PAD, PAD_UP) or Left_Y <= -90)) and #OPCIONES.SALIDA_DIR_ACTUALES >= 1 and CONTROL.JOYSTICK_ON == false then
			if (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) then
				selector = cambiar_valor(selector, 1, #OPCIONES.SALIDA_DIR_ACTUALES, 1, true)
			elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90) then
				selector = cambiar_valor(selector, 1, #OPCIONES.SALIDA_DIR_ACTUALES, 1, false)
			end
			CONTROL.JOYSTICK_ON = true
			local kabal = 1 if Left_Y ~= 1 then kabal = 2 end
			JOYSTICK_LIMITE = control_FPS(kabal)
			LISTAS.SCROLL_TEX = 1
			reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
			if OPCIONES.SOUND_ON == 1 and S_MOVER ~= nil then
				Sound.playADPCM(1, S_MOVER)
			end
		elseif Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
			if OPCIONES.SALIDA_RETROLANCHER ~= nil and string.lower(string.sub(OPCIONES.SALIDA_RETROLANCHER, -4)) == ".elf" then
				cachucho = false
				if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then
					Sound.playADPCM(1, S_EJECUTAR)
				end
			else
				OPCIONES.SALIDA_RETROLANCHER_ON = 0
				buscar_directorio(nil)
				cachucho = false
				if OPCIONES.SOUND_ON == 1 and S_ERROR ~= nil then
					Sound.playADPCM(1, S_ERROR)
				end
			end
		end

		-- Mostrar todo en pantalla. ----------------------------------------------------
		Screen.clear(COLOR.NEGRO)
		dibujar_fondos()
		Graphics.drawRect(12, 28+CONTROL.Y_FIX_PAL, 615, 375, COLOR.NEGRO_T)
		if #OPCIONES.SALIDA_DIR_ACTUALES >= 1 then
			if CONTROL.ESPERA_CARGA_SCR == false then
				LISTAS.SCROLL_TEX = scroll_texto(LISTAS.SCROLL_TEX, OPCIONES.SALIDA_DIR_ACTUALES[selector], 44)
			end
			local mostrar_lista = 0
			for contador = 0, 12, 1 do
				local espacio_linea = 62+((contador)*25)+CONTROL.Y_FIX_PAL
				if contador == 0 then
					Graphics.drawRect(12+5, espacio_linea-3, 610, 25, COLOR.NEGRO_T)
					Font.ftPrint(CONTROL.fontARCA, 22, espacio_linea, 0, 601, 2, string.sub(OPCIONES.SALIDA_DIR_ACTUALES[selector], LISTAS.SCROLL_TEX), CAMBIOS_EMUS.COLOR_EMU)
				elseif (selector+contador) <= #OPCIONES.SALIDA_DIR_ACTUALES then
					Font.ftPrint(CONTROL.fontARCA, 22, espacio_linea, 0, 601, 2, "".. OPCIONES.SALIDA_DIR_ACTUALES[selector+contador], COLOR.BLANCO_LISTA)
				end
			end
		else
			if CONTROL.ESPERA_CARGA_SCR == false then
				LISTAS.SCROLL_TEX = scroll_texto(LISTAS.SCROLL_TEX, "THE FOLDER IS EMPTY OR THE FILES ARE NOT SUPPORTED", 44)
			end
			Font.ftPrint(CONTROL.fontARCA, 22, 65+CONTROL.Y_FIX_PAL, 0, 601, 40, string.sub("THE FOLDER IS EMPTY OR THE FILES ARE NOT SUPPORTED", LISTAS.SCROLL_TEX), CAMBIOS_EMUS.COLOR_EMU)
		end
		if OPCIONES.SALIDA_RETROLANCHER ~= nil then
			Graphics.drawRect(-5, 22+CONTROL.Y_FIX_PAL, 650, 25, COLOR.NEGRO)
			Font.ftPrint(CONTROL.fontARCA, 22, 25+CONTROL.Y_FIX_PAL, 0, 601, 2, OPCIONES.SALIDA_RETROLANCHER, COLOR.BLANCO)
			if string.lower(string.sub(OPCIONES.SALIDA_RETROLANCHER, -4)) == ".elf" then
				cachucho = false
			end
		else
			Graphics.drawRect(-5, 22+CONTROL.Y_FIX_PAL, 650, 25, COLOR.NEGRO)
			Font.ftPrint(CONTROL.fontARCA, 22, 25+CONTROL.Y_FIX_PAL, 0, 601, 2, "NO VALID FILES", COLOR.BLANCO)
		end
		Graphics.drawRect(-5, 392+CONTROL.Y_FIX_PAL, 650, 25, COLOR.NEGRO)
		Graphics.drawScaleImage(PAD_IMG.TRIANGLE, 60, 392+CONTROL.Y_FIX_PAL, 25, 25)
		Font.ftPrint(CONTROL.fontARCA, 95, 395+CONTROL.Y_FIX_PAL, 0, 0, 8, "CANCEL", COLOR.BLANCO)
		Graphics.drawScaleImage(PAD_IMG.CIRCLE, 478, 392+CONTROL.Y_FIX_PAL, 25, 25)
		Font.ftPrint(CONTROL.fontARCA, 513, 395+CONTROL.Y_FIX_PAL, 0, 0, 8, "BACK", COLOR.BLANCO)
		Graphics.drawScaleImage(PAD_IMG.CROSS, 263, 392+CONTROL.Y_FIX_PAL, 25, 25)
		Font.ftPrint(CONTROL.fontARCA, 298, 395+CONTROL.Y_FIX_PAL, 0, 0, 8, "SELECT", COLOR.BLANCO)
		refrescar(false)
	end
end

--- Muestra, cambia y guarda las configuraciones. ---------------------------------------
function menu_config()
	Pads.rumble(0, 0, 0)
	-- Guardar configuraciones previas. -------------------------------------------------
	local anterior_conf = {OPCIONES.RGB_ON; OPCIONES.FONDO_RGB_ON;
	OPCIONES.FONDO_RGB_FIJO_ON; OPCIONES.R; OPCIONES.G; OPCIONES.B; CONTROL.ESTILO; SISTEMAS.MEGADRIVE_ON;
	SISTEMAS.MASTERSYSTEM_ON; SISTEMAS.GAMEGEAR_ON; SISTEMAS.FAMICOM_ON; SISTEMAS.GAMEBOY_ON; SISTEMAS.GAMEBOYCOLOR_ON;
	SISTEMAS.GAMEBOYADVANCE_ON; SISTEMAS.ATARI2600_ON; SISTEMAS.SEGASG1000_ON; SISTEMAS.NEOGEOPOCKET_ON;
	SISTEMAS.SUPERFAMICOM_ON; SISTEMAS.APPS_ON; SISTEMAS.PLAYSTATION_ON; SISTEMAS.PLAYSTATION2_ON; OPCIONES.CAMBIO_FUENTE_ON;
	OPCIONES.CAMBIO_FONDO_ON; OPCIONES.GUI_LIMPIA_ON; OPCIONES.LIMITADOR_RAM_ON; OPCIONES.SALIDA_RETROLANCHER_ON; OPCIONES.SALIDA_RETROLANCHER; OPCIONES.APPS_MENU_FULL_PATH; OPCIONES.SOUND_ON; OPCIONES.SOUND_VOLUME; OPCIONES.SCREENSHOT_BACK_ON; OPCIONES.VIBRATION_ON; OPCIONES.DIR_EXTRAS_ON; CAMBIOS_EMUS.TRAS; OPCIONES.LIBERAR_LISTAS;
	OPCIONES.FONT_PIXEL_X; OPCIONES.FONT_PIXEL_Y; OPCIONES.FONT_SHADOW; OPCIONES.SCROLL_MIN;};

	-- Variables para controlar configuraciones. ----------------------------------------
	color_emu(LISTAS.IDENTIDAD)
	local lista_config = {OPCIONES.RGB_ON; OPCIONES.FONDO_RGB_ON; OPCIONES.FONDO_RGB_FIJO_ON; OPCIONES.R; OPCIONES.G;
	OPCIONES.B; CONTROL.ESTILO; SISTEMAS.MEGADRIVE_ON; SISTEMAS.MASTERSYSTEM_ON; SISTEMAS.GAMEGEAR_ON; SISTEMAS.FAMICOM_ON;
	SISTEMAS.GAMEBOY_ON; SISTEMAS.GAMEBOYCOLOR_ON; SISTEMAS.GAMEBOYADVANCE_ON; SISTEMAS.ATARI2600_ON; SISTEMAS.SEGASG1000_ON;
	SISTEMAS.NEOGEOPOCKET_ON; SISTEMAS.SUPERFAMICOM_ON; SISTEMAS.APPS_ON; SISTEMAS.PLAYSTATION_ON; SISTEMAS.PLAYSTATION2_ON;
	OPCIONES.CAMBIO_FUENTE_ON; OPCIONES.CAMBIO_FONDO_ON; OPCIONES.GUI_LIMPIA_ON; OPCIONES.LIMITADOR_RAM_ON;
	OPCIONES.SALIDA_RETROLANCHER_ON; OPCIONES.SALIDA_RETROLANCHER; OPCIONES.APPS_MENU_FULL_PATH; OPCIONES.SOUND_ON;
	OPCIONES.SOUND_VOLUME; OPCIONES.SCREENSHOT_BACK_ON; OPCIONES.VIDEO_MODE; OPCIONES.VIBRATION_ON; OPCIONES.DIR_EXTRAS_ON;
	0; 0; "SAVE";};
	local lista_texto_config = {"RGB EFFECT"; "COLOR IN BACKGROUNDS"; "FIXED COLOR IN BACKGROUNDS"; "RED"; "GREEN"; "BLUE";
	"LIST STYLE"; "MEGADRIVE"; "MASTER SYSTEM"; "GAME GEAR"; "FAMICOM"; "GAME BOY"; "GAME BOY COLOR"; "GAME BOY ADVANCE";
	"ATARI 2600"; "SEGA SG-1000"; "NEO GEO POCKET"; "SUPER FAMICOM"; "APPS"; "PLAY STATION"; "PLAY STATION 2"; "FONT TYPE";
	"CHANGE THE BACKGROUND"; "CLEAN GUI"; "FORCE GARBAGE COLLECTION"; "CUSTOM APP/ELF OUTPUT"; "DIRECTORY";
	"SEE FULL ROUTE IN THE APPS MENU"; "SOUND IN THE MENU"; "SOUND VOLUME"; "SCREENSHOT AS BACKGROUND"; "VIDEO MODE";
	"VIBRATION IN MENU"; "EXTRA DIRECTORIES"; "RESET ALL SETTINGS"; "CREDITS"; "- SAVE SETTINGS -";};
	local noob, conf_numero, clean, reinicio, indi_rest_RL, selector, cambio_realizado, page = true, true, false, false, 0, 1, false, "PAGE 1"

	-- Opciones actuales de audio. ------------------------------------------------------
	local mus_on = "OFF"
	if doesFileExist("System/Medios/Sound/Background/music.adp") then
		mus_on = "ON"
	end
	local volume = OPCIONES.SOUND_VOLUME

	-- Opciones actuales de colores y transparencias. -----------------------------------
	local color1, color2, color3 = OPCIONES.R, OPCIONES.G, OPCIONES.B
	local color_demo = Color.new(color1, color2, color3, CAMBIOS_EMUS.TRAS)
	if CAMBIOS_EMUS.TRAS == 0 then
		color_demo = Color.new(color1, color2, color3)
	end
	local tras_demo = CAMBIOS_EMUS.TRAS

	-- Opciones actuales de salida. -----------------------------------------------------
	local selec_dir = OPCIONES.SALIDA_RETROLANCHER_ON
	lista_texto_config[27] = OPCIONES.SALIDA_RETROLANCHER

	-- Opciones actuales de fuente de texto. --------------------------------------------
	buscar_fuentes()
	local selec_fuente = 1
	if OPCIONES.CAMBIO_FUENTE_ON <= #OPCIONES.FUENTES_ENCONTRADAS then
		selec_fuente = OPCIONES.CAMBIO_FUENTE_ON
	end
	local font_x, font_Y, font_shadow, font_scroll = OPCIONES.FONT_PIXEL_X, OPCIONES.FONT_PIXEL_Y, OPCIONES.FONT_SHADOW, OPCIONES.SCROLL_MIN

	-- Opciones actuales de fondos de pantalla. -----------------------------------------
	local estilo_lista = CONTROL.ESTILO
	buscar_fondos()
	local selec_fondo = 1
	if OPCIONES.CAMBIO_FONDO_ON <= #OPCIONES.FONDO_ENCONTRADOS then
		selec_fondo = OPCIONES.CAMBIO_FONDO_ON
	end

	-- Iniciar menú de configuración. ---------------------------------------------------
	while noob do
		CONTROL.FPS = Screen.getFPS(1)
		capturar(JOYSTICK_LIMITE)
		tiempo_de_scroll()

		-- Controlar el mínimo de sistemas activos. -------------------------------------
		local rev2 = true
		for rev = 8, 21 do
			if lista_config[rev] == 1 then rev2 = false break end
		end
		if rev2 == true then lista_config[8] = 1 end

		-- Salir de configuraciones. ----------------------------------------------------
		if Pads.check(PAD, PAD_CIRCLE) or Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
			local nueva_conf = {lista_config[1]; lista_config[2]; lista_config[3]; color1; color2; color3;
			estilo_lista; lista_config[8]; lista_config[9]; lista_config[10]; lista_config[11];
			lista_config[12]; lista_config[13]; lista_config[14]; lista_config[15]; lista_config[16]; lista_config[17];
			lista_config[18]; lista_config[19]; lista_config[20]; lista_config[21]; selec_fuente; selec_fondo;
			lista_config[24]; lista_config[25]; selec_dir; lista_texto_config[27]; lista_config[28]; lista_config[29];
			volume; lista_config[31]; lista_config[33]; lista_config[34]; tras_demo; OPCIONES.LIBERAR_LISTAS; font_x;
			font_Y; font_shadow; font_scroll;};
			cambio_realizado = false
			for chequeo = 1, #nueva_conf do
				if nueva_conf[chequeo] ~= anterior_conf[chequeo] then cambio_realizado = true end
			end
			if cambio_realizado == true then
				local pregunta = true
				local message_exit = {"UNSAVED CHANGES DO YOU WANT TO EXIT?", "EXIT", "CANCEL"}
				Graphics.drawRect(0, 160+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, 114, Color.new(128, 128, 128))
				Graphics.drawRect(0, 162+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, 110, Color.new(0, 0, 0))
				Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), (162+8)+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 88, message_exit[1], COLOR.BLANCO)
				Graphics.drawScaleImage(PAD_IMG.CROSS, 300-35, 195+CONTROL.Y_FIX_PAL, 20, 20)
				Font.ftPrint(CONTROL.fontARCA, 300, 195+CONTROL.Y_FIX_PAL, 0, 160, 24, message_exit[2], COLOR.BLANCO)
				Graphics.drawScaleImage(PAD_IMG.SQUARE, 300-35, 219+CONTROL.Y_FIX_PAL, 20, 20)
				Font.ftPrint(CONTROL.fontARCA, 300, 219+CONTROL.Y_FIX_PAL, 0, 160, 24, message_exit[3], COLOR.BLANCO)
				Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 246+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 50, "All changes made will be lost upon reboot.", COLOR.BLANCO)
				refrescar(false)
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					if Pads.check(PAD, PAD_CROSS) then
						if doesFileExist(OPCIONES.SALIDA_RETROLANCHER) == false
							or string.lower(string.sub(OPCIONES.SALIDA_RETROLANCHER, -4)) ~= ".elf" then
							OPCIONES.SALIDA_RETROLANCHER_ON = anterior_conf[26]
							OPCIONES.SALIDA_RETROLANCHER = anterior_conf[27]
						end
						noob = false
						pregunta = false
					elseif Pads.check(PAD, PAD_SQUARE) then
						pregunta = false
					end
					refrescar(true)
				end
			else
				noob = false
			end
			if OPCIONES.SOUND_ON == 1 and S_CANCELAR ~= nil then
				Sound.playADPCM(1, S_CANCELAR)
			end
			CONTROL.JOYSTICK_ON = true
			JOYSTICK_LIMITE = control_FPS(1)
		end

		-- Ver controles de RETROLauncher. ----------------------------------------------
		if Pads.check(PAD, PAD_R3) or Pads.check(PAD, PAD_L3) and CONTROL.JOYSTICK_ON == false then
			if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then
				Sound.playADPCM(1, S_EJECUTAR)
			end
			if doesFileExist("System/Medios/Default/HELP.png") then
				local yoshi = true
				local help = Graphics.loadImage("System/Medios/Default/HELP.png")
				while yoshi do
					capturar(JOYSTICK_LIMITE)
					Screen.clear(CAMBIOS_EMUS.COLOR_EMU)
					local Right_X, Right_Y, Right_XY = zoom(LISTAS.ART_ZOOM, CONTROL.ANCHO, CONTROL.ALTO_F)
					Graphics.drawScaleImage(help, 0-(Right_XY//2)-(Right_X//2), -10-(Right_Y//2), CONTROL.ANCHO+Right_XY, CONTROL.ALTO_F+Right_Y)
					Font.ftPrint(CONTROL.fontARCA, 5, CONTROL.ALTO_F-19, 0, 640, 88, "RETROLauncher v1.0 / rev 0", COLOR.BLANCO)
					refrescar(false)
					if not Pads.check(PAD, PAD_L3) and not Pads.check(PAD, PAD_SELECT) and not Pads.check(PAD, PAD_R3) and not Pads.check(PAD, PAD_CROSS) and PAD ~= 0 then
						yoshi = false
						if OPCIONES.SOUND_ON == 1 and S_CANCELAR ~= nil then
							Sound.playADPCM(1, S_CANCELAR)
						end
					end
				end
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)
				Graphics.freeImage(help)
			end
		end

		-- Sistemas de configuraciones extras. ------------------------------------------
		if Pads.check(PAD, PAD_SELECT) and CONTROL.JOYSTICK_ON == false and (selector == 22 or (selector == 7 and estilo_lista == 7) or (selector >= 8 and selector <= 18) or selector == 25 or selector == 29) then
			if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then
				Sound.playADPCM(1, S_EJECUTAR)
			end

			-- Configurar estilo personalizado. -----------------------------------------
			if selector == 7 and estilo_lista == 7 then
				local reload = editor_tema()
				if CONTROL.ESTILO == 7 and reload == true then cargar_style(true) end

			-- Configurar fuente de texto. ----------------------------------------------
			elseif selector == 22 then
				local pix_txt = {"SET WIDTH: ", "SET HEIGHT: ", "SET TEXT BACKGROUND: ", "SET THE START OF THE TEXT SCROLL: "}
				local example_text = {"Increase or decrease the minimum number of scrolls until the number \"0\" is visible next to the right frame of the color box.", ""}
				local pix_option = {font_x, font_Y, font_shadow, font_scroll}
				local CONFT = Font.ftLoad("System/Medios/Font/PublicPixel.ttf")
				Font.ftSetPixelSize(CONTROL.fontARCA, pix_option[1], pix_option[2])
				Font.ftSetPixelSize(CONFT, 17, 16)
				Font.ftSetPixelSize(CONTROL.fontABC, 70, 70)
				local selector_pix = 1
				local scroll_test = 1
				local largo_actual = CONTROL.LISTA_X
				if largo_actual >= 578 then largo_actual = 578 end
				local pregunta = true
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					tiempo_de_scroll()
					dibujar_fondos()
					Graphics.drawRect(10, 16+CONTROL.Y_FIX_PAL, 619, 419, COLOR.BLANCO)
					Graphics.drawRect(12, 18+CONTROL.Y_FIX_PAL, 615, 415, COLOR.NEGRO)
					Font.ftPrint(CONFT, (CONTROL.ANCHO//2), 25+CONTROL.Y_FIX_PAL, 8, 601, 20, "-TEXT FONT SETTING-", COLOR.BLANCO)

					-- Ejemplo de cuadros de texto. -------------------------------------
					Font.ftPrint(CONFT, (CONTROL.ANCHO//2), 53+CONTROL.Y_FIX_PAL, 8, 601, 112, "-Try to fit all the text into the dark boxes-", Color.new(70, 70, 70))
					Graphics.drawRect(358, 80+CONTROL.Y_FIX_PAL, 250, 40, Color.new(70, 70, 70))
					Graphics.drawRect(396, 92+CONTROL.Y_FIX_PAL, 174, 18, Color.new(40, 40, 40))
					Font.ftPrint(CONTROL.fontARCA, (358+250//2), 92+CONTROL.Y_FIX_PAL, 8, 250, 25, "-LOADING ART-", COLOR.BLANCO)
					Graphics.drawRect(30, 80+CONTROL.Y_FIX_PAL, 250, 40, Color.new(70, 70, 70))
					Graphics.drawRect(68, 92+CONTROL.Y_FIX_PAL, 174, 18, Color.new(40, 40, 40))
					Font.ftPrint(CONTROL.fontARCA, 30+38, 92+CONTROL.Y_FIX_PAL, 0, 174, 25, "-LOADING ART-", COLOR.BLANCO)

					-- Ejemplo de listas y scroll. --------------------------------------
					if CONTROL.ESPERA_CARGA_SCR == false then
						scroll_test = scroll_texto(scroll_test, example_text[1], pix_option[4])
					end
					if pix_option[4]+4 ~= string.len(example_text[2]) then
						example_text[2] = ""
						for tex_sc = 1, pix_option[4]-3 do
							example_text[2] = example_text[2].. "W"
						end
						example_text[2] = example_text[2].. "-0-.zip"
					end
					Font.ftPrint(CONFT, (CONTROL.ANCHO//2), 127+CONTROL.Y_FIX_PAL, 8, 601, 25, "-Try placing the \"0\" in the color box-", Color.new(70, 70, 70))
					Graphics.drawRect(30, 154+CONTROL.Y_FIX_PAL, largo_actual, 25, Color.new(70, 70, 70))
					Graphics.drawRect(30+largo_actual-28, 154+CONTROL.Y_FIX_PAL, 28, 22, Color.new(20, 100, 20))
					Font.ftPrint(CONTROL.fontARCA, 35, 155+CONTROL.Y_FIX_PAL, 0, largo_actual, 25, example_text[2], COLOR.BLANCO)
					Graphics.drawRect(30, 182+CONTROL.Y_FIX_PAL, 578, 18, Color.new(70, 70, 70))
					Font.ftPrint(CONTROL.fontARCA, 35, 183+CONTROL.Y_FIX_PAL, 0, 573, 20, string.sub(example_text[1], scroll_test), COLOR.BLANCO)

					-- Ejemplo de sombras tras los textos. ------------------------------
					Font.ftPrint(CONFT, (CONTROL.ANCHO//2), 209+CONTROL.Y_FIX_PAL, 8, 597, 112, "-Try to make the dark bar cover the text-", Color.new(70, 70, 70))
					Graphics.drawRect(30, 239+CONTROL.Y_FIX_PAL, (pix_option[3]*pix_option[1]*(string.len("FIXED TEXT EXAMPLE")/2)/3), 20, Color.new(40, 40, 40))
					Graphics.drawRect(30, 261+CONTROL.Y_FIX_PAL, (pix_option[3]*pix_option[1]*(string.len("FULL SCREEN")/2)/3), 20, Color.new(40, 40, 40))
					Graphics.drawRect(30, 283+CONTROL.Y_FIX_PAL, (pix_option[3]*pix_option[1]*(string.len("RUN GAME")/2)/3), 20, Color.new(40, 40, 40))
					Font.ftPrint(CONTROL.fontARCA, 33, 240+CONTROL.Y_FIX_PAL, 0, 615, 405, "FIXED TEXT EXAMPLE", COLOR.BLANCO)
					Font.ftPrint(CONTROL.fontARCA, 33, 262+CONTROL.Y_FIX_PAL, 0, 615, 405, "FULL SCREEN", COLOR.BLANCO)
					Font.ftPrint(CONTROL.fontARCA, 33, 284+CONTROL.Y_FIX_PAL, 0, 615, 405, "RUN GAME", COLOR.BLANCO)

					-- Ejemplos de salto de carácter. -----------------------------------
					Graphics.drawRect(493, 281, 74, 68, Color.new(40, 40, 40))
					Font.ftPrint(CONTROL.fontABC, 530, 323, 8, 70, 70, "M", COLOR.BLANCO)

					-- Opciones de ajustes. ---------------------------------------------
					local espacio_linea2 = 291+((0)*20)+CONTROL.Y_FIX_PAL
					for contador = 1, #pix_option, 1 do
						espacio_linea = 291+((contador)*20)+CONTROL.Y_FIX_PAL
						if contador == selector_pix then
							Graphics.drawRect(30-2, espacio_linea-2, (5*16*(string.len(pix_txt[contador].. pix_option[contador])/2)/3)+4, 23, Color.new(128, 128, 128))
							Graphics.drawRect(30, espacio_linea, (5*16*(string.len(pix_txt[contador].. pix_option[contador])/2)/3), 19, Color.new(30, 30, 30))
							Font.ftPrint(CONFT, 30, espacio_linea, 0, 630, 405, pix_txt[contador].. pix_option[contador], COLOR.BLANCO)
						else
							Font.ftPrint(CONFT, 30, espacio_linea, 0, 630, 405, pix_txt[contador].. pix_option[contador], Color.new(70, 70, 70))
						end
					end
					Graphics.drawScaleImage(PAD_IMG.SQUARE, 30, 402+CONTROL.Y_FIX_PAL, 25, 25)
					Font.ftPrint(CONFT, 65, 405+CONTROL.Y_FIX_PAL, 0, 0, 8, "DEFAULT VALUES", COLOR.BLANCO)
					Graphics.drawScaleImage(PAD_IMG.CIRCLE, 478, 402+CONTROL.Y_FIX_PAL, 25, 25)
					Font.ftPrint(CONFT, 513, 405+CONTROL.Y_FIX_PAL, 0, 0, 8, "CANCEL", COLOR.BLANCO)
					Graphics.drawScaleImage(PAD_IMG.START, 273, 402+CONTROL.Y_FIX_PAL, 25, 25)
					Font.ftPrint(CONFT, 308, 405+CONTROL.Y_FIX_PAL, 0, 0, 8, "SET VALUES", COLOR.BLANCO)

					-- Control de ajustes. ----------------------------------------------
					if (Pads.check(PAD, PAD_UP) or Pads.check(PAD, PAD_DOWN) or Left_Y ~= 1) and CONTROL.JOYSTICK_ON == false then
						if OPCIONES.SOUND_ON == 1 and S_MOVER ~= nil then
							Sound.playADPCM(1, S_MOVER)
						end
						if Pads.check(PAD, PAD_UP) or Left_Y <= -90 then
							selector_pix = cambiar_valor(selector_pix, 1, 4, 1, false)
						elseif Pads.check(PAD, PAD_DOWN) or Left_Y >= 90 then
							selector_pix = cambiar_valor(selector_pix, 1, 4, 1, true)
						end
						CONTROL.JOYSTICK_ON = true
						JOYSTICK_LIMITE = control_FPS(1)
					elseif (Pads.check(PAD, PAD_LEFT) or Pads.check(PAD, PAD_RIGHT) or Left_X ~= 1) and CONTROL.JOYSTICK_ON == false then
						if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then
							Sound.playADPCM(1, S_EJECUTAR)
						end
						local minimo_mov, max_mov = 2, 32
						if selector_pix == 3 then
							minimo_mov, max_mov = 0, 32
						elseif selector_pix == 4 then
							minimo_mov, max_mov = 10, 150
						end
						if Pads.check(PAD, PAD_LEFT) or Left_X <= -90 then
							pix_option[selector_pix] = cambiar_valor(pix_option[selector_pix], minimo_mov, max_mov, 1, false)
						elseif Pads.check(PAD, PAD_RIGHT) or Left_X >= 90 then
							pix_option[selector_pix] = cambiar_valor(pix_option[selector_pix], minimo_mov, max_mov, 1, true)
						end
						Font.ftSetPixelSize(CONTROL.fontARCA, pix_option[1], pix_option[2])
						CONTROL.JOYSTICK_ON = true
						JOYSTICK_LIMITE = control_FPS(1)
					elseif Pads.check(PAD, PAD_SQUARE) then
						if OPCIONES.SOUND_ON == 1 and S_ERROR ~= nil then
							Sound.playADPCM(1, S_ERROR)
						end
						pix_option[1], pix_option[2], pix_option[3], pix_option[4] = 16, 16, 5, 24
						Font.ftSetPixelSize(CONTROL.fontARCA, pix_option[1], pix_option[2])
						CONTROL.JOYSTICK_ON = true
						JOYSTICK_LIMITE = control_FPS(1)
					elseif Pads.check(PAD, PAD_START) then
						if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then
							Sound.playADPCM(1, S_EJECUTAR)
						end
						font_x, font_Y, font_shadow, font_scroll = pix_option[1], pix_option[2], pix_option[3], pix_option[4]
						Font.ftSetPixelSize(CONTROL.fontARCA, font_x, font_Y)
						pregunta = false
					elseif Pads.check(PAD, PAD_CIRCLE) then
						if OPCIONES.SOUND_ON == 1 and S_CANCELAR ~= nil then
							Sound.playADPCM(1, S_CANCELAR)
						end
						Font.ftSetPixelSize(CONTROL.fontARCA, font_x, font_Y)
						pregunta = false
					end
					refrescar(false)
				end
				Font.ftUnload(CONFT)

			-- Configurar la carga de lista única. --------------------------------------
			elseif selector == 25 then
				local lis_free = "OFF"
				if OPCIONES.LIBERAR_LISTAS == 1 then
					lis_free = "ON"
				end
				local pregunta = true
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					Graphics.drawRect(0, 160+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, 172, Color.new(128, 128, 128))
					Graphics.drawRect(0, 162+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, 168, Color.new(0, 0, 0))
					Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), (162+8)+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 25, "-RELEASE REST OF LISTS?-", COLOR.BLANCO)
					Graphics.drawScaleImage(PAD_IMG.SQUARE, 300-35, 195+CONTROL.Y_FIX_PAL, 20, 20)
					Font.ftPrint(CONTROL.fontARCA, 290, 195+CONTROL.Y_FIX_PAL, 0, 160, 25, "CHANGE", COLOR.BLANCO)
					Graphics.drawScaleImage(PAD_IMG.CIRCLE, 300-35, 219+CONTROL.Y_FIX_PAL, 20, 20)
					Font.ftPrint(CONTROL.fontARCA, 290, 219+CONTROL.Y_FIX_PAL, 0, 160, 25, "CANCEL", COLOR.BLANCO)
					Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 248+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 50, "When enabled, list movement will be smoother", COLOR.BLANCO)
					Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 273+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 50, "at the cost of pauses in system changes.", COLOR.BLANCO)
					Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 303+CONTROL.Y_FIX_PAL, 8, 0, 25, "STATUS:".. lis_free, COLOR.BLANCO)
					if Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
						if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then
							Sound.playADPCM(1, S_EJECUTAR)
						end
						Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 303+CONTROL.Y_FIX_PAL, 8, 0, 25, "████████████████████", COLOR.NEGRO)
						Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 303+CONTROL.Y_FIX_PAL, 8, 0, 25, "PLEASE WAIT", COLOR.BLANCO)
						refrescar(false)
						if OPCIONES.LIBERAR_LISTAS == 0 then
							OPCIONES.LIBERAR_LISTAS = 1
							lis_free = "ON"
							PRE_CARGADAS = {{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}}
							recargar_una(LISTAS.IDENTIDAD)
						else
							OPCIONES.LIBERAR_LISTAS = 0
							lis_free = "OFF"
							local ante_l = LISTAS.IDENTIDAD
							PRE_CARGADAS = {}
							recargar_todas()
							LISTAS.IDENTIDAD = ante_l
						end
						CONTROL.JOYSTICK_ON = true
						JOYSTICK_LIMITE = control_FPS(1)
					elseif Pads.check(PAD, PAD_CIRCLE) then
						if OPCIONES.SOUND_ON == 1 and S_CANCELAR ~= nil then
							Sound.playADPCM(1, S_CANCELAR)
						end
						pregunta = false
					end
					refrescar(false)
				end

			-- Configurar música de fondo. ----------------------------------------------
			elseif selector == 29 then
				local pregunta = true
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					Graphics.drawRect(0, 160+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, 172, Color.new(128, 128, 128))
					Graphics.drawRect(0, 162+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, 168, Color.new(0, 0, 0))
					Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), (162+8)+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 25, "-BACKGROUND MUSIC LOOP?-", COLOR.BLANCO)
					Graphics.drawScaleImage(PAD_IMG.SQUARE, 300-35, 195+CONTROL.Y_FIX_PAL, 20, 20)
					Font.ftPrint(CONTROL.fontARCA, 290, 195+CONTROL.Y_FIX_PAL, 0, 160, 25, "CHANGE", COLOR.BLANCO)
					Graphics.drawScaleImage(PAD_IMG.CIRCLE, 300-35, 219+CONTROL.Y_FIX_PAL, 20, 20)
					Font.ftPrint(CONTROL.fontARCA, 290, 219+CONTROL.Y_FIX_PAL, 0, 160, 25, "CANCEL", COLOR.BLANCO)
					Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 248+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 50, "Once the change is made, wait a moment for", COLOR.BLANCO)
					Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 273+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 50, "the loop to finish playing.", COLOR.BLANCO)
					Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 303+CONTROL.Y_FIX_PAL, 8, 0, 25, "STATUS:".. mus_on, COLOR.BLANCO)
					if Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
						if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then
							Sound.playADPCM(1, S_EJECUTAR)
						end
						Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 303+CONTROL.Y_FIX_PAL, 8, 0, 25, "████████████████████", COLOR.NEGRO)
						Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 303+CONTROL.Y_FIX_PAL, 8, 0, 25, "PLEASE WAIT", COLOR.BLANCO)
						refrescar(false)
						if doesFileExist("System/Medios/Sound/Background/music.adp")then
							mus_on = "OFF"
							System.rename("System/Medios/Sound/Background/music.adp", "System/Medios/Sound/Background/music0.adp")
							Sound.freeADPCM(S_MUSICA)
							S_MUSICA = nil
						elseif doesFileExist("System/Medios/Sound/Background/music0.adp")then
							mus_on = "ON"
							System.rename("System/Medios/Sound/Background/music0.adp", "System/Medios/Sound/Background/music.adp")
							S_MUSICA = verificar_sonidos(MUSICA, "System/Medios/Sound/Background/music.adp")
						end
						CONTROL.JOYSTICK_ON = true
						JOYSTICK_LIMITE = control_FPS(1)
					elseif Pads.check(PAD, PAD_CIRCLE) then
						if OPCIONES.SOUND_ON == 1 and S_CANCELAR ~= nil then
							Sound.playADPCM(1, S_CANCELAR)
						end
						pregunta = false
					end
					refrescar(false)
				end

			-- Restauración individual de sistemas. -------------------------------------
			elseif (selector >= 8 and selector <= 18) then
				local pregunta = true
				Pads.rumble(0, 0, 0)
				local lista_indi_rest_RL = {10, 9, 8, 3, 4, 6, 5, 1, 11, 2, 7}
				local lista_indi_rest = {"Sega Megadrive", "Sega Master System", "Sega Game Gear", "Nintendo Famicom", "Nintendo Game Boy", "Nintendo Game Boy Color", "Nintendo Game Boy Advance", "Atari 2600", "Sega SG-1000", "Neo Geo Pocket", "Nintendo Super Famicom"}
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					Graphics.drawRect(0, 160+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, 144, Color.new(128, 128, 128))
					Graphics.drawRect(0, 162+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, 140, Color.new(0, 0, 0))
					Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), (162+8)+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 25, "-RESET ".. lista_indi_rest[selector-7] .."?-", COLOR.BLANCO)
					Graphics.drawScaleImage(PAD_IMG.SQUARE, 300-35, 195+CONTROL.Y_FIX_PAL, 20, 20)
					Font.ftPrint(CONTROL.fontARCA, 290, 195+CONTROL.Y_FIX_PAL, 0, 160, 25, "RESET", COLOR.BLANCO)
					Graphics.drawScaleImage(PAD_IMG.CIRCLE, 300-35, 219+CONTROL.Y_FIX_PAL, 20, 20)
					Font.ftPrint(CONTROL.fontARCA, 290, 219+CONTROL.Y_FIX_PAL, 0, 160, 25, "CANCEL", COLOR.BLANCO)
					Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 248+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 50, "-DELETING SAVES STATES?-", COLOR.BLANCO)
					Graphics.drawScaleImage(PAD_IMG.R1, 300-40, 268+CONTROL.Y_FIX_PAL, 30, 30)
					if clean == false then
						Font.ftPrint(CONTROL.fontARCA, 300, 273+CONTROL.Y_FIX_PAL, 0, 160, 25, "NO", COLOR.BLANCO)
					else
						Font.ftPrint(CONTROL.fontARCA, 300, 273+CONTROL.Y_FIX_PAL, 0, 160, 25, "YES", COLOR.BLANCO)
					end
					if Pads.check(PAD, PAD_R1) and CONTROL.JOYSTICK_ON == false then
						if OPCIONES.SOUND_ON == 1 and S_NETX ~= nil then
							Sound.playADPCM(1, S_NETX)
						end
						if clean == false then clean = true else clean = false end
						CONTROL.JOYSTICK_ON = true
						JOYSTICK_LIMITE = control_FPS(1)
					elseif Pads.check(PAD, PAD_SQUARE) then
						if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then
							Sound.playADPCM(1, S_EJECUTAR)
						end
						noob, reinicio, pregunta = false, true, false
						indi_rest_RL = lista_indi_rest_RL[selector-7]
					elseif Pads.check(PAD, PAD_CIRCLE) then
						if OPCIONES.SOUND_ON == 1 and S_CANCELAR ~= nil then
							Sound.playADPCM(1, S_CANCELAR)
						end
						pregunta, clean = false, false
						indi_rest_RL = 0
						CONTROL.JOYSTICK_ON = true
						JOYSTICK_LIMITE = control_FPS(1)
					end
					refrescar(false)
				end
			end
			CONTROL.JOYSTICK_ON = true
			JOYSTICK_LIMITE = control_FPS(1)
		end

		-- Cambio entre páginas de configuración. ---------------------------------------
		if Pads.check(PAD, PAD_L1) or Pads.check(PAD, PAD_R1) and CONTROL.JOYSTICK_ON == false then
			if OPCIONES.SOUND_ON == 1 and S_NETX ~= nil then
				Sound.playADPCM(1, S_NETX)
			end
			if conf_numero == true then
				conf_numero = false
				selector = 22
				page = "PAGE 2"
			else
				conf_numero = true
				selector = 1
				page = "PAGE 1"
			end
			if OPCIONES.VIBRATION_ON == 1 then
				Pads.rumble(0, 250, 250)
			end
			CONTROL.JOYSTICK_ON = true
			JOYSTICK_LIMITE = control_FPS(1)
		end

		-- Cambiar y guardar los estados de configuración. ------------------------------
		if Pads.check(PAD, PAD_CROSS) and (selector <= 3 or selector >= 7) and CONTROL.JOYSTICK_ON == false then
			if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then
				Sound.playADPCM(1, S_EJECUTAR)
			end
			if selector ~= #lista_config and selector ~= 7 and selector ~= 27 and selector ~= 26 and selector ~= 22 and selector ~= 23 and selector ~= 30 and selector ~= 35 and selector ~= 36 then
				-- Activa / Desactiva las opciones. -------------------------------------
				if lista_config[selector] == 0 then
					lista_config[selector] = 1
				elseif lista_config[selector] == 1 then
					lista_config[selector] = 0
				end

				-- Activa / Desactiva los directorios completos en APPS. ----------------
				if selector == 28 then
					OPCIONES.APPS_MENU_FULL_PATH = lista_config[28]
					OPCIONES.DIR_EXTRAS_ON = lista_config[34]
					PRE_CARGADAS[12] = crear_listas(12, PRE_CARGADAS[12])
					desactivados(nil)
				end

				-- Activa / Desactiva los directorios extras para APPS y PS2. -----------
				if selector == 34 then
					OPCIONES.APPS_MENU_FULL_PATH = lista_config[28]
					OPCIONES.DIR_EXTRAS_ON = lista_config[34]
					PRE_CARGADAS[12] = crear_listas(12, PRE_CARGADAS[12])
					PRE_CARGADAS[14] = crear_listas(14, PRE_CARGADAS[14])
					desactivados(nil)
				end

				-- Cambia el modo de video y reconfigura las opciones de Retroarch. -----
				if selector == 32 then
					local pregunta = true
					Pads.rumble(0, 0, 0)
					local mode_act = 1
					if lista_config[32] == 1 then mode_act = 2 end
					local mode_vi_tex = {"NTSC", "PAL"}
					Graphics.drawRect(0, 160+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, 142, Color.new(128, 128, 128))
					Graphics.drawRect(0, 162+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, 138, Color.new(0, 0, 0))
					Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), (162+8)+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 25, "-CHANGE VIDEO MODE TO ".. mode_vi_tex[mode_act] .."?-", COLOR.BLANCO)
					Graphics.drawScaleImage(PAD_IMG.SQUARE, 300-35, 195+CONTROL.Y_FIX_PAL, 20, 20)
					Font.ftPrint(CONTROL.fontARCA, 290, 195+CONTROL.Y_FIX_PAL, 0, 160, 25, "CHANGE", COLOR.BLANCO)
					Graphics.drawScaleImage(PAD_IMG.CIRCLE, 300-35, 219+CONTROL.Y_FIX_PAL, 20, 20)
					Font.ftPrint(CONTROL.fontARCA, 290, 219+CONTROL.Y_FIX_PAL, 0, 160, 25, "CANCEL", COLOR.BLANCO)
					Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 248+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 50, "WARNING !", COLOR.BLANCO)
					Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 273+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 50, "ALL RETROARCH OPTIONS WILL RESET", COLOR.BLANCO)
					refrescar(false)
					while pregunta do
						capturar(JOYSTICK_LIMITE)
						if Pads.check(PAD, PAD_SQUARE) then
							if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then
								Sound.playADPCM(1, S_EJECUTAR)
							end
							if lista_config[32] == 0 then
								Screen.setMode(NTSC, 640, 448, CT24, INTERLACED, FIELD)
								CONTROL.ALTO_F = 448
								CONTROL.Y_FIX_PAL = 0
							else
								Screen.setMode(PAL, 640, 512, CT24, INTERLACED, FIELD)
								CONTROL.ALTO_F = 512
								CONTROL.Y_FIX_PAL = 32
							end
							OPCIONES.VIDEO_MODE = lista_config[32]
							noob = false
							reinicio = true
							pregunta = false
							clean = false
							indi_rest_RL = 20
						elseif Pads.check(PAD, PAD_CIRCLE) then
							if OPCIONES.SOUND_ON == 1 and S_CANCELAR ~= nil then
								Sound.playADPCM(1, S_CANCELAR)
							end
							if lista_config[selector] == 0 then
								lista_config[selector] = 1
							elseif lista_config[selector] == 1 then
								lista_config[selector] = 0
							end
							clean = false
							pregunta = false
							indi_rest_RL = 0
						end
						refrescar(true)
					end
					CONTROL.JOYSTICK_ON = true
					JOYSTICK_LIMITE = control_FPS(1)
				end

			-- Cambia el estilo de la lista. --------------------------------------------
			elseif selector == 7 then
				estilo_lista = cambiar_valor(estilo_lista, 1, 7, 1, true)

			-- Reinicia todas las configuraciones. --------------------------------------
			elseif selector == 35 then
				local pregunta = true
				Pads.rumble(0, 0, 0)
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					Graphics.drawRect(0, 160+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, 144, Color.new(128, 128, 128))
					Graphics.drawRect(0, 162+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, 140, Color.new(0, 0, 0))
					Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), (162+8)+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 25, "- RESET ALL SETTINGS? -", COLOR.BLANCO)
					Graphics.drawScaleImage(PAD_IMG.SQUARE, 300-35, 195+CONTROL.Y_FIX_PAL, 20, 20)
					Font.ftPrint(CONTROL.fontARCA, 290, 195+CONTROL.Y_FIX_PAL, 0, 160, 25, "RESET", COLOR.BLANCO)
					Graphics.drawScaleImage(PAD_IMG.CIRCLE, 300-35, 219+CONTROL.Y_FIX_PAL, 20, 20)
					Font.ftPrint(CONTROL.fontARCA, 290, 219+CONTROL.Y_FIX_PAL, 0, 160, 25, "CANCEL", COLOR.BLANCO)
					Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 248+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 50, "-DELETING SAVES STATES?-", COLOR.BLANCO)
					Graphics.drawScaleImage(PAD_IMG.R1, 300-40, 268+CONTROL.Y_FIX_PAL, 30, 30)
					if clean == false then
						Font.ftPrint(CONTROL.fontARCA, 300, 273+CONTROL.Y_FIX_PAL, 0, 160, 25, "NO", COLOR.BLANCO)
					else
						Font.ftPrint(CONTROL.fontARCA, 300, 273+CONTROL.Y_FIX_PAL, 0, 160, 25, "YES", COLOR.BLANCO)
					end
					if Pads.check(PAD, PAD_R1) and CONTROL.JOYSTICK_ON == false then
						if OPCIONES.SOUND_ON == 1 and S_NETX ~= nil then
							Sound.playADPCM(1, S_NETX)
						end
						if clean == false then clean = true else clean = false end
						CONTROL.JOYSTICK_ON = true
						JOYSTICK_LIMITE = control_FPS(1)
					elseif Pads.check(PAD, PAD_SQUARE) then
						if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then
							Sound.playADPCM(1, S_EJECUTAR)
						end
						noob = false
						reinicio = true
						pregunta = false
					elseif Pads.check(PAD, PAD_CIRCLE) then
						if OPCIONES.SOUND_ON == 1 and S_CANCELAR ~= nil then
							Sound.playADPCM(1, S_CANCELAR)
						end
						pregunta = false
						clean = false
						CONTROL.JOYSTICK_ON = true
						JOYSTICK_LIMITE = control_FPS(1)
					end
					refrescar(false)
				end

			-- Cambia la fuente de texto. -----------------------------------------------
			elseif selector == 22 then
				selec_fuente = cambiar_valor(selec_fuente, 1, #OPCIONES.FUENTES_ENCONTRADAS, 1, true)
				if selec_fuente <= #OPCIONES.FUENTES_ENCONTRADAS and selec_fuente >= 1 then
					Font.ftUnload(CONTROL.fontARCA)
					Font.ftUnload(CONTROL.fontABC)
					CONTROL.fontARCA = Font.ftLoad(OPCIONES.FUENTES_ENCONTRADAS[selec_fuente])
					CONTROL.fontABC = Font.ftLoad(OPCIONES.FUENTES_ENCONTRADAS[selec_fuente])
					if selec_fuente == 1 then OPCIONES.FONT_SHADOW, font_shadow = 5, 5
						else OPCIONES.FONT_SHADOW, font_shadow = 0, 0 end
					Font.ftSetPixelSize(CONTROL.fontARCA, font_x, font_Y)
					Font.ftSetPixelSize(CONTROL.fontABC, 70, 70)
					OPCIONES.CAMBIO_FUENTE_ON = selec_fuente
				end

			-- Cambia el fondo de pantalla. ---------------------------------------------
			elseif selector == 23 then
				selec_fondo = cambiar_valor(selec_fondo, 1, #OPCIONES.FONDO_ENCONTRADOS, 1, true)
				if selec_fondo <= #OPCIONES.FONDO_ENCONTRADOS and selec_fondo >= 1 then
					Graphics.freeImage(LISTAS.FONDO)
					LISTAS.FONDO = Graphics.loadImage(OPCIONES.FONDO_ENCONTRADOS[selec_fondo])
					OPCIONES.CAMBIO_FONDO_ON = selec_fondo
				end

			-- Seleccionar dónde se buscará la salida de RETROLauncher. -----------------
			elseif selector == 26 then
				selec_dir = cambiar_valor(selec_dir, 0, 3, 1, true)
				OPCIONES.SALIDA_RETROLANCHER_ON = selec_dir
				buscar_directorio(nil)
				lista_config[27] = OPCIONES.SALIDA_RETROLANCHER
				lista_texto_config[27] = OPCIONES.SALIDA_RETROLANCHER

			-- Cambia la salida de RETROLauncher. ---------------------------------------
			elseif selector == 27 then
				if selec_dir ~= 0 then
					buscar_directorio(nil)
					marcar_directorio()
					selec_dir = OPCIONES.SALIDA_RETROLANCHER_ON
					lista_config[27] = OPCIONES.SALIDA_RETROLANCHER
					lista_texto_config[27] = OPCIONES.SALIDA_RETROLANCHER
				end

			-- Muestra los créditos. ----------------------------------------------------
			elseif selector == 36 then
				creditos()

			-- Guardar todas las configuraciones. ---------------------------------------
			elseif selector == #lista_config then
				OPCIONES.RGB_ON = lista_config[1]
				OPCIONES.FONDO_RGB_ON = lista_config[2]
				OPCIONES.FONDO_RGB_FIJO_ON = lista_config[3]
				OPCIONES.R = color1
				OPCIONES.G = color2
				OPCIONES.B = color3
				CONTROL.ESTILO = estilo_lista
				SISTEMAS.MEGADRIVE_ON = lista_config[8]
				if SISTEMAS.MEGADRIVE_ON == 0 then
					PRE_CARGADAS[1] = {}
				end
				SISTEMAS.MASTERSYSTEM_ON = lista_config[9]
				if SISTEMAS.MASTERSYSTEM_ON == 0 then
					PRE_CARGADAS[2] = {}
				end
				SISTEMAS.GAMEGEAR_ON = lista_config[10]
				if SISTEMAS.GAMEGEAR_ON == 0 then
					PRE_CARGADAS[3] = {}
				end
				SISTEMAS.FAMICOM_ON = lista_config[11]
				if SISTEMAS.FAMICOM_ON == 0 then
					PRE_CARGADAS[4] = {}
				end
				SISTEMAS.GAMEBOY_ON = lista_config[12]
				if SISTEMAS.GAMEBOY_ON == 0 then
					PRE_CARGADAS[5] = {}
				end
				SISTEMAS.GAMEBOYCOLOR_ON = lista_config[13]
				if SISTEMAS.GAMEBOYCOLOR_ON == 0 then
					PRE_CARGADAS[6] = {}
				end
				SISTEMAS.GAMEBOYADVANCE_ON = lista_config[14]
				if SISTEMAS.GAMEBOYADVANCE_ON == 0 then
					PRE_CARGADAS[7] = {}
				end
				SISTEMAS.ATARI2600_ON = lista_config[15]
				if SISTEMAS.ATARI2600_ON == 0 then
					PRE_CARGADAS[8] = {}
				end
				SISTEMAS.SEGASG1000_ON = lista_config[16]
				if SISTEMAS.SEGASG1000_ON == 0 then
					PRE_CARGADAS[9] = {}
				end
				SISTEMAS.NEOGEOPOCKET_ON = lista_config[17]
				if SISTEMAS.NEOGEOPOCKET_ON == 0 then
					PRE_CARGADAS[10] = {}
				end
				SISTEMAS.SUPERFAMICOM_ON = lista_config[18]
				if SISTEMAS.SUPERFAMICOM_ON == 0 then
					PRE_CARGADAS[11] = {}
				end
				SISTEMAS.APPS_ON = lista_config[19]
				if SISTEMAS.APPS_ON == 0 then
					PRE_CARGADAS[12] = {}
				end
				SISTEMAS.PLAYSTATION_ON = lista_config[20]
				if SISTEMAS.PLAYSTATION_ON == 0 then
					PRE_CARGADAS[13] = {}
				end
				SISTEMAS.PLAYSTATION2_ON = lista_config[21]
				if SISTEMAS.PLAYSTATION2_ON == 0 then
					PRE_CARGADAS[14] = {}
				end
				OPCIONES.CAMBIO_FUENTE_ON = selec_fuente
				OPCIONES.FUENTES_ENCONTRADAS = {}
				OPCIONES.CAMBIO_FONDO_ON = selec_fondo
				OPCIONES.FONDO_ENCONTRADOS = {}
				OPCIONES.GUI_LIMPIA_ON = lista_config[24]
				OPCIONES.LIMITADOR_RAM_ON = lista_config[25]
				if doesFileExist(OPCIONES.SALIDA_RETROLANCHER) and string.lower(string.sub(OPCIONES.SALIDA_RETROLANCHER, -4)) == ".elf" then
					OPCIONES.SALIDA_RETROLANCHER_ON = selec_dir
					guardar_directorio_elf()
				else
					OPCIONES.SALIDA_RETROLANCHER_ON = 0
					OPCIONES.SALIDA_RETROLANCHER = "PS2 SYSTEM MENU"
					guardar_directorio_elf()
				end
				OPCIONES.APPS_MENU_FULL_PATH = lista_config[28]
				OPCIONES.SOUND_ON = lista_config[29]
				OPCIONES.SOUND_VOLUME = volume
				OPCIONES.SCREENSHOT_BACK_ON = lista_config[31]
				OPCIONES.VIDEO_MODE = lista_config[32]
				OPCIONES.VIBRATION_ON = lista_config[33]
				OPCIONES.DIR_EXTRAS_ON = lista_config[34]
				CAMBIOS_EMUS.TRAS = tras_demo
				if CONTROL.ESTILO == 1 then
					CONTROL.IMG_ANCHO = 358; CONTROL.IMG_X = 250; CONTROL.IMG_ALTO = 92; CONTROL.IMG_Y = 193;
					CONTROL.IMG_ANCHO_2 = 358; CONTROL.IMG_X_2 = 250; CONTROL.IMG_ALTO_2 = 92; CONTROL.IMG_Y_2 = 193;
					CONTROL.LISTA_ANCHO = 30; CONTROL.LISTA_X = 310; CONTROL.LISTA_ALTO = 90; CONTROL.LISTA_Y = 290;
					CONTROL.LOGO_ANCHO = 194; CONTROL.LOGO_X = 252; CONTROL.LOGO_ALTO = 5; CONTROL.LOGO_Y = 76;
					CONTROL.FLOW_ANCHO = 358; CONTROL.FLOW_X = 250; CONTROL.FLOW_ALTO = 92; CONTROL.FLOW_Y = 193;
					CONTROL.FLOW_ANCHO_2 = 358; CONTROL.FLOW_X_2 = 250; CONTROL.FLOW_ALTO_2 = 92; CONTROL.FLOW_Y_2 = 193;
					CONTROL.X_BUTTON_X = 388; CONTROL.Y_BUTTON_X = 353; CONTROL.X_BUTTON_T = 388; CONTROL.Y_BUTTON_T = 297;
					CONTROL.X_BUTTON_S = 388; CONTROL.Y_BUTTON_S = 325; CONTROL.X_BUTTON_L1 = 144; CONTROL.Y_BUTTON_L1 = 28;
					CONTROL.X_BUTTON_R1 = 464; CONTROL.Y_BUTTON_R1 = 28; CONTROL.X_BUTTON_R3 = 388; CONTROL.Y_BUTTON_R3 = 297;
					CONTROL.X_BUTTON_STA = 423; CONTROL.Y_BUTTON_STA = 410; CONTROL.X_BUTTON_SEL = 45; CONTROL.Y_BUTTON_SEL = 410;
					CONTROL.CUSTOM_ANIM = 1; CONTROL.ANIM_VELOCIDAD = 29;
					CONTROL.CUSTOM_LIST = true; CONTROL.CUSTOM_ART1 = true; CONTROL.CUSTOM_ART2 = false;
					CONTROL.CUSTOM_FLOW = false; CONTROL.CUSTOM_LOGO = true; CONTROL.CUSTOM_BUTTON_X = true;
					CONTROL.CUSTOM_BUTTON_T = true; CONTROL.CUSTOM_BUTTON_S = true; CONTROL.CUSTOM_BUTTON_L1 = true;
					CONTROL.CUSTOM_BUTTON_R1 = true; CONTROL.CUSTOM_BUTTON_R3 = true; CONTROL.CUSTOM_BUTTON_STA = true;
					CONTROL.CUSTOM_BUTTON_SEL = true;
				elseif CONTROL.ESTILO == 2 then
					CONTROL.IMG_ANCHO = 195; CONTROL.IMG_X = 250; CONTROL.IMG_ALTO = 110; CONTROL.IMG_Y = 193;
					CONTROL.IMG_ANCHO_2 = 195; CONTROL.IMG_X_2 = 250; CONTROL.IMG_ALTO_2 = 110; CONTROL.IMG_Y_2 = 193;
					CONTROL.LISTA_ANCHO = 167; CONTROL.LISTA_X = 306; CONTROL.LISTA_ALTO = 317; CONTROL.LISTA_Y = 50;
					CONTROL.LOGO_ANCHO = 194; CONTROL.LOGO_X = 252; CONTROL.LOGO_ALTO = 5; CONTROL.LOGO_Y = 76;
					CONTROL.FLOW_ANCHO = 15; CONTROL.FLOW_X = 160; CONTROL.FLOW_ALTO = 150; CONTROL.FLOW_Y = 103;
					CONTROL.FLOW_ANCHO_2 = 465; CONTROL.FLOW_X_2 = 160; CONTROL.FLOW_ALTO_2 = 150; CONTROL.FLOW_Y_2 = 103;
					CONTROL.X_BUTTON_X = 270; CONTROL.Y_BUTTON_X = 376; CONTROL.X_BUTTON_T = 40; CONTROL.Y_BUTTON_T = 376;
					CONTROL.X_BUTTON_S = 475; CONTROL.Y_BUTTON_S = 376; CONTROL.X_BUTTON_L1 = 144; CONTROL.Y_BUTTON_L1 = 28;
					CONTROL.X_BUTTON_R1 = 464; CONTROL.Y_BUTTON_R1 = 28; CONTROL.X_BUTTON_R3 = 260; CONTROL.Y_BUTTON_R3 = 376;
					CONTROL.X_BUTTON_STA = 423; CONTROL.Y_BUTTON_STA = 410; CONTROL.X_BUTTON_SEL = 45; CONTROL.Y_BUTTON_SEL = 410;
					CONTROL.CUSTOM_ANIM = 2; CONTROL.ANIM_VELOCIDAD = 29;
					CONTROL.CUSTOM_LIST = false; CONTROL.CUSTOM_ART1 = true; CONTROL.CUSTOM_ART2 = false;
					CONTROL.CUSTOM_FLOW = true; CONTROL.CUSTOM_LOGO = true; CONTROL.CUSTOM_BUTTON_X = true;
					CONTROL.CUSTOM_BUTTON_T = true; CONTROL.CUSTOM_BUTTON_S = true; CONTROL.CUSTOM_BUTTON_L1 = true;
					CONTROL.CUSTOM_BUTTON_R1 = true; CONTROL.CUSTOM_BUTTON_R3 = true; CONTROL.CUSTOM_BUTTON_STA = true;
					CONTROL.CUSTOM_BUTTON_SEL = true;
				elseif CONTROL.ESTILO == 3 then
					CONTROL.IMG_ANCHO = 48; CONTROL.IMG_X = 250; CONTROL.IMG_ALTO = 92; CONTROL.IMG_Y = 193;
					CONTROL.IMG_ANCHO_2 = 340; CONTROL.IMG_X_2 = 250; CONTROL.IMG_ALTO_2 = 92; CONTROL.IMG_Y_2 = 193;
					CONTROL.LISTA_ANCHO = 46; CONTROL.LISTA_X = 310; CONTROL.LISTA_ALTO = 300; CONTROL.LISTA_Y = 137;
					CONTROL.LOGO_ANCHO = 194; CONTROL.LOGO_X = 252; CONTROL.LOGO_ALTO = 5; CONTROL.LOGO_Y = 76;
					CONTROL.FLOW_ANCHO = 48; CONTROL.FLOW_X = 250; CONTROL.FLOW_ALTO = 92; CONTROL.FLOW_Y = 193;
					CONTROL.FLOW_ANCHO_2 = 48; CONTROL.FLOW_X_2 = 250; CONTROL.FLOW_ALTO_2 = 92; CONTROL.FLOW_Y_2 = 193;
					CONTROL.X_BUTTON_X = 399; CONTROL.Y_BUTTON_X = 353; CONTROL.X_BUTTON_T = 399; CONTROL.Y_BUTTON_T = 297;
					CONTROL.X_BUTTON_S = 399; CONTROL.Y_BUTTON_S = 325; CONTROL.X_BUTTON_L1 = 144; CONTROL.Y_BUTTON_L1 = 28;
					CONTROL.X_BUTTON_R1 = 464; CONTROL.Y_BUTTON_R1 = 28; CONTROL.X_BUTTON_R3 = 399; CONTROL.Y_BUTTON_R3 = 297;
					CONTROL.X_BUTTON_STA = 399; CONTROL.Y_BUTTON_STA = 407; CONTROL.X_BUTTON_SEL = 399; CONTROL.Y_BUTTON_SEL = 379;
					CONTROL.CUSTOM_ANIM = 2; CONTROL.ANIM_VELOCIDAD = 29;
					CONTROL.CUSTOM_LIST = true; CONTROL.CUSTOM_ART1 = true; CONTROL.CUSTOM_ART2 = true;
					CONTROL.CUSTOM_FLOW = false; CONTROL.CUSTOM_LOGO = true; CONTROL.CUSTOM_BUTTON_X = true;
					CONTROL.CUSTOM_BUTTON_T = true; CONTROL.CUSTOM_BUTTON_S = true; CONTROL.CUSTOM_BUTTON_L1 = true;
					CONTROL.CUSTOM_BUTTON_R1 = true; CONTROL.CUSTOM_BUTTON_R3 = true; CONTROL.CUSTOM_BUTTON_STA = true;
					CONTROL.CUSTOM_BUTTON_SEL = true;
				elseif CONTROL.ESTILO == 4 then
					CONTROL.IMG_ANCHO = 333; CONTROL.IMG_X = 295; CONTROL.IMG_ALTO = 92; CONTROL.IMG_Y = 228;
					CONTROL.IMG_ANCHO_2 = 333; CONTROL.IMG_X_2 = 295; CONTROL.IMG_ALTO_2 = 92; CONTROL.IMG_Y_2 = 228;
					CONTROL.LISTA_ANCHO = 10; CONTROL.LISTA_X = 310; CONTROL.LISTA_ALTO = 90; CONTROL.LISTA_Y = 290;
					CONTROL.LOGO_ANCHO = 194; CONTROL.LOGO_X = 252; CONTROL.LOGO_ALTO = 5; CONTROL.LOGO_Y = 76;
					CONTROL.FLOW_ANCHO = 333; CONTROL.FLOW_X = 295; CONTROL.FLOW_ALTO = 92; CONTROL.FLOW_Y = 228;
					CONTROL.FLOW_ANCHO_2 = 333; CONTROL.FLOW_X_2 = 295; CONTROL.FLOW_ALTO_2 = 92; CONTROL.FLOW_Y_2 = 228;
					CONTROL.X_BUTTON_X = 270; CONTROL.Y_BUTTON_X = 391; CONTROL.X_BUTTON_T = 40; CONTROL.Y_BUTTON_T = 391;
					CONTROL.X_BUTTON_S = 475; CONTROL.Y_BUTTON_S = 391; CONTROL.X_BUTTON_L1 = 144; CONTROL.Y_BUTTON_L1 = 28;
					CONTROL.X_BUTTON_R1 = 464; CONTROL.Y_BUTTON_R1 = 28; CONTROL.X_BUTTON_R3 = 260; CONTROL.Y_BUTTON_R3 = 391;
					CONTROL.X_BUTTON_STA = 423; CONTROL.Y_BUTTON_STA = 415; CONTROL.X_BUTTON_SEL = 45; CONTROL.Y_BUTTON_SEL = 415;
					CONTROL.CUSTOM_ANIM = 1; CONTROL.ANIM_VELOCIDAD = 29;
					CONTROL.CUSTOM_LIST = true; CONTROL.CUSTOM_ART1 = true; CONTROL.CUSTOM_ART2 = false;
					CONTROL.CUSTOM_FLOW = false; CONTROL.CUSTOM_LOGO = true; CONTROL.CUSTOM_BUTTON_X = true;
					CONTROL.CUSTOM_BUTTON_T = true; CONTROL.CUSTOM_BUTTON_S = true; CONTROL.CUSTOM_BUTTON_L1 = true;
					CONTROL.CUSTOM_BUTTON_R1 = true; CONTROL.CUSTOM_BUTTON_R3 = true; CONTROL.CUSTOM_BUTTON_STA = true;
					CONTROL.CUSTOM_BUTTON_SEL = true;
				elseif CONTROL.ESTILO == 5 then
					CONTROL.IMG_ANCHO = 12; CONTROL.IMG_X = 295; CONTROL.IMG_ALTO = 20; CONTROL.IMG_Y = 228;
					CONTROL.IMG_ANCHO_2 = 332; CONTROL.IMG_X_2 = 295; CONTROL.IMG_ALTO_2 = 20; CONTROL.IMG_Y_2 = 228;
					CONTROL.LISTA_ANCHO = 10; CONTROL.LISTA_X = 299; CONTROL.LISTA_ALTO = 263; CONTROL.LISTA_Y = 115;
					CONTROL.LOGO_ANCHO = 352; CONTROL.LOGO_X = 252; CONTROL.LOGO_ALTO = 280; CONTROL.LOGO_Y = 76;
					CONTROL.FLOW_ANCHO = 12; CONTROL.FLOW_X = 295; CONTROL.FLOW_ALTO = 20; CONTROL.FLOW_Y = 228;
					CONTROL.FLOW_ANCHO_2 = 12; CONTROL.FLOW_X_2 = 295; CONTROL.FLOW_ALTO_2 = 20; CONTROL.FLOW_Y_2 = 228;
					CONTROL.X_BUTTON_X = 270; CONTROL.Y_BUTTON_X = 391; CONTROL.X_BUTTON_T = 40; CONTROL.Y_BUTTON_T = 391;
					CONTROL.X_BUTTON_S = 475; CONTROL.Y_BUTTON_S = 391; CONTROL.X_BUTTON_L1 = 324; CONTROL.Y_BUTTON_L1 = 252;
					CONTROL.X_BUTTON_R1 = 602; CONTROL.Y_BUTTON_R1 = 252; CONTROL.X_BUTTON_R3 = 260; CONTROL.Y_BUTTON_R3 = 391;
					CONTROL.X_BUTTON_STA = 423; CONTROL.Y_BUTTON_STA = 415; CONTROL.X_BUTTON_SEL = 45; CONTROL.Y_BUTTON_SEL = 415;
					CONTROL.CUSTOM_ANIM = 2; CONTROL.ANIM_VELOCIDAD = 29;
					CONTROL.CUSTOM_LIST = true; CONTROL.CUSTOM_ART1 = true; CONTROL.CUSTOM_ART2 = true;
					CONTROL.CUSTOM_FLOW = false; CONTROL.CUSTOM_LOGO = true; CONTROL.CUSTOM_BUTTON_X = true;
					CONTROL.CUSTOM_BUTTON_T = true; CONTROL.CUSTOM_BUTTON_S = true; CONTROL.CUSTOM_BUTTON_L1 = true;
					CONTROL.CUSTOM_BUTTON_R1 = true; CONTROL.CUSTOM_BUTTON_R3 = true; CONTROL.CUSTOM_BUTTON_STA = true;
					CONTROL.CUSTOM_BUTTON_SEL = true;
				elseif CONTROL.ESTILO == 6 then
					CONTROL.IMG_ANCHO = 345; CONTROL.IMG_X = 270; CONTROL.IMG_ALTO = 10; CONTROL.IMG_Y = 208;
					CONTROL.IMG_ANCHO_2 = 345; CONTROL.IMG_X_2 = 270; CONTROL.IMG_ALTO_2 = 230; CONTROL.IMG_Y_2 = 208;
					CONTROL.LISTA_ANCHO = 22; CONTROL.LISTA_X = 310; CONTROL.LISTA_ALTO = 90; CONTROL.LISTA_Y = 290;
					CONTROL.LOGO_ANCHO = 52; CONTROL.LOGO_X = 252; CONTROL.LOGO_ALTO = 5; CONTROL.LOGO_Y = 76;
					CONTROL.FLOW_ANCHO = 345; CONTROL.FLOW_X = 270; CONTROL.FLOW_ALTO = 10; CONTROL.FLOW_Y = 208;
					CONTROL.FLOW_ANCHO_2 = 345; CONTROL.FLOW_X_2 = 270; CONTROL.FLOW_ALTO_2 = 10; CONTROL.FLOW_Y_2 = 208;
					CONTROL.X_BUTTON_X = 162; CONTROL.Y_BUTTON_X = 391; CONTROL.X_BUTTON_T = 52; CONTROL.Y_BUTTON_T = 391;
					CONTROL.X_BUTTON_S = 272; CONTROL.Y_BUTTON_S = 391; CONTROL.X_BUTTON_L1 = 17; CONTROL.Y_BUTTON_L1 = 60;
					CONTROL.X_BUTTON_R1 = 305; CONTROL.Y_BUTTON_R1 = 60; CONTROL.X_BUTTON_R3 = 52; CONTROL.Y_BUTTON_R3 = 391;
					CONTROL.X_BUTTON_STA = 246; CONTROL.Y_BUTTON_STA = 416; CONTROL.X_BUTTON_SEL = 57; CONTROL.Y_BUTTON_SEL = 416;
					CONTROL.CUSTOM_ANIM = 1; CONTROL.ANIM_VELOCIDAD = 29;
					CONTROL.CUSTOM_LIST = true; CONTROL.CUSTOM_ART1 = true; CONTROL.CUSTOM_ART2 = true;
					CONTROL.CUSTOM_FLOW = false; CONTROL.CUSTOM_LOGO = true; CONTROL.CUSTOM_BUTTON_X = true;
					CONTROL.CUSTOM_BUTTON_T = true; CONTROL.CUSTOM_BUTTON_S = true; CONTROL.CUSTOM_BUTTON_L1 = true;
					CONTROL.CUSTOM_BUTTON_R1 = true; CONTROL.CUSTOM_BUTTON_R3 = true; CONTROL.CUSTOM_BUTTON_STA = true;
					CONTROL.CUSTOM_BUTTON_SEL = true;
				elseif CONTROL.ESTILO == 7 then
					cargar_style(false)
				end
				if OPCIONES.VIDEO_MODE == 1 then
					CONTROL.ALTO_F = 512
					CONTROL.ALTO = 544
					CONTROL.Y_FIX_PAL = 32
				else
					CONTROL.ALTO_F = 448
					CONTROL.ALTO = 480
					CONTROL.Y_FIX_PAL = 0
				end
				CONTROL.LISTA_ALTO = CONTROL.LISTA_ALTO + CONTROL.Y_FIX_PAL
				CONTROL.IMG_ALTO = CONTROL.IMG_ALTO + CONTROL.Y_FIX_PAL
				CONTROL.LOGO_ALTO = CONTROL.LOGO_ALTO + CONTROL.Y_FIX_PAL
				CONTROL.IMG_ALTO_2 = CONTROL.IMG_ALTO_2 + CONTROL.Y_FIX_PAL
				CONTROL.FLOW_ALTO = CONTROL.FLOW_ALTO + CONTROL.Y_FIX_PAL
				CONTROL.FLOW_ALTO_2 = CONTROL.FLOW_ALTO_2 + CONTROL.Y_FIX_PAL
				OPCIONES.FONT_PIXEL_X, OPCIONES.FONT_PIXEL_Y, OPCIONES.FONT_SHADOW, OPCIONES.SCROLL_MIN = font_x, font_Y, font_shadow, font_scroll
				Font.ftSetPixelSize(CONTROL.fontARCA, OPCIONES.FONT_PIXEL_X, OPCIONES.FONT_PIXEL_Y)
				Font.ftSetPixelSize(CONTROL.fontABC, 70, 70)
				desactivados(nil)
				guardar_opciones()
				cambio_realizado = false
				noob = false
			end

			-- Desactiva "RGB" si la personalización está activada. ---------------------
			if (lista_config[2] == 0 or lista_config[3] == 1) and lista_config[1] == 1 then
				lista_config[1] = 0
			end

			-- Aplica los cambios de colores al estilo. ---------------------------------
			if lista_config[3] == 1 then
				CAMBIOS_EMUS.COLOR_EMU = Color.new(color1, color2, color3)
			elseif lista_config[3] == 0 then
				color_emu(LISTAS.IDENTIDAD)
			end
			if (selector <= 3 or selector >= 1) and lista_config[1] == 0 and lista_config[2] == 0 and lista_config[3] == 0 then
				color_emu(0)
			elseif (selector <= 3 or selector >= 1) and lista_config[1] == 0 and lista_config[2] == 1 and lista_config[3] == 0 then
				color_emu(LISTAS.IDENTIDAD)
			end

			-- Activa / Desactiva los sonidos y la vibración. ---------------------------
			OPCIONES.SOUND_ON = lista_config[29]
			OPCIONES.VIBRATION_ON = lista_config[33]
			if OPCIONES.VIBRATION_ON == 1 then
				Pads.rumble(0, 250, 250)
			end
			CONTROL.JOYSTICK_ON = true
			JOYSTICK_LIMITE = control_FPS(1)
		end

		-- Controlar el movimiento vertical por las opciones de configuración. ----------
		if (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90 or Pads.check(PAD, PAD_R2)) or (Pads.check(PAD, PAD_UP) or Left_Y <= -90 or Pads.check(PAD, PAD_L2)) and CONTROL.JOYSTICK_ON == false then
			if OPCIONES.SOUND_ON == 1 and S_MOVER ~= nil then
				Sound.playADPCM(1, S_MOVER)
			end
			if Pads.check(PAD, PAD_R2) and conf_numero == true then
				selector = cambiar_valor(selector, 1, 22, 4, true)
				if selector == 22 then selector = #lista_config end
			elseif Pads.check(PAD, PAD_R2) and conf_numero == false then
				selector = cambiar_valor(selector, 22, #lista_config, 4, true)
			elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) and conf_numero == true then
				selector = cambiar_valor(selector, 1, 22, 1, true)
				if selector == 22 then selector = #lista_config end
			elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) and conf_numero == false then
				selector = cambiar_valor(selector, 22, #lista_config, 1, true)
			elseif Pads.check(PAD, PAD_L2) and conf_numero == true then
				selector = cambiar_valor(selector, 1, #lista_config, 4, false)
				if selector <= #lista_config-1 and selector >= 22 then selector = 22-4 end
			elseif Pads.check(PAD, PAD_L2) and conf_numero == false then
				selector = cambiar_valor(selector, 22, #lista_config, 4, false)
			elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90) and conf_numero == true then
				selector = cambiar_valor(selector, 1, #lista_config, 1, false)
				if selector == #lista_config-1 then selector = 21 end
			elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90) and conf_numero == false then
				selector = cambiar_valor(selector, 22, #lista_config, 1, false)
			end

			-- vibración y cambio de velocidades. ---------------------------------------
			local shake_r, shake_l = 100, 255
			if (Pads.check(PAD, PAD_UP) or Left_Y <= -90) then
				shake_r, shake_l = 255, 100
			end
			if OPCIONES.VIBRATION_ON == 1 then
				Pads.rumble(0, shake_r, shake_l)
			end
			CONTROL.JOYSTICK_ON = true
			local kabal = 1 if Left_Y ~= 1 then kabal = 2 end
			JOYSTICK_LIMITE = control_FPS(kabal)
		end

		-- Controlar el movimiento horizontal por las opciones de configuración. --------
		if ((Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90)) and (selector == 7 or selector == 30 or (selector >= 4 and selector <= 6) or (selector >= 8 and selector <= 21)) and CONTROL.JOYSTICK_ON == false then
			if OPCIONES.SOUND_ON == 1 and S_MOVER ~= nil and selector ~= 7 then
				Sound.playADPCM(1, S_MOVER)
			elseif OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil and selector == 7 then
				Sound.playADPCM(1, S_EJECUTAR)
			end

			-- Realizar cambios en el volumen. ------------------------------------------
			if (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and selector == 30 then
				volume = cambiar_valor(volume, 1, 100, 1, false)
			elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and selector == 30 then
				volume = cambiar_valor(volume, 1, 100, 1, true)

			-- Realizar cambios en los colores. -----------------------------------------
			elseif Pads.check(PAD, PAD_SQUARE) and (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and lista_config[3] == 1 and selector >= 4 and selector <= 6 then
				tras_demo = cambiar_valor(tras_demo, 0, 120, 1, false)
			elseif Pads.check(PAD, PAD_SQUARE) and (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and lista_config[3] == 1 and selector >= 4 and selector <= 6 then
				tras_demo = cambiar_valor(tras_demo, 0, 120, 1, true)
			elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and selector == 4 then
				color1 = cambiar_valor(color1, 0, 128, 1, false)
			elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and selector == 5 then
				color2 = cambiar_valor(color2, 11, 128, 1, false)
			elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and selector == 6 then
				color3 = cambiar_valor(color3, 11, 128, 1, false)
			elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and selector == 4 then
				color1 = cambiar_valor(color1, 0, 128, 1, true)
			elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and selector == 5 then
				color2 = cambiar_valor(color2, 11, 128, 1, true)
			elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and selector == 6 then
				color3 = cambiar_valor(color3, 11, 128, 1, true)

			-- Realizar cambios de estilos. ---------------------------------------------
			elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and selector == 7 then
				estilo_lista = cambiar_valor(estilo_lista, 1, 7, 1, false)
			elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and selector == 7 then
				estilo_lista = cambiar_valor(estilo_lista, 1, 7, 1, true)

			-- Realizar salto lateral en sistemas. --------------------------------------
			elseif (selector >= 8 and selector <= 21) and (selector <= 14 and selector >= 8) then
				selector = selector+7
			elseif (selector >= 8 and selector <= 21) and (selector <= 21 and selector >= 15) then
				selector = selector-7
			end

			-- Aplicar modificaciones / volumen / colores. ------------------------------
			if selector == 30 then
				OPCIONES.SOUND_VOLUME = volume
				set_volume()
			elseif selector >= 4 and selector <= 6 then
				if tras_demo == 0 then
					color_demo = Color.new(color1, color2, color3)
				else
					color_demo = Color.new(color1, color2, color3, tras_demo)
				end
				if lista_config[3] == 1 then
					CAMBIOS_EMUS.COLOR_EMU = Color.new(color1, color2, color3)
				end
			end

			-- vibración y cambio de velocidades. ---------------------------------------
			local shake_r, shake_l = 100, 255
			if selector == 30 then
				shake_r, shake_l = 1, 150+volume
			elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
				shake_r, shake_l = 255, 100
			end
			if OPCIONES.VIBRATION_ON == 1 then
				Pads.rumble(0, shake_r, shake_l)
			end
			CONTROL.JOYSTICK_ON = true
			local kabal = 1 if Left_X ~= 1 then kabal = 2 end
			JOYSTICK_LIMITE = control_FPS(kabal)
		end

		-- Mostrar todo en pantalla. ----------------------------------------------------
		Screen.clear(COLOR.NEGRO)
		RGB()
		if lista_config[2] == 1 and (lista_config[3] == 0 or (lista_config[3] == 1 and tras_demo == 0)) then
			Graphics.drawRect(0, 0, CONTROL.ANCHO, CONTROL.ALTO_F, CAMBIOS_EMUS.COLOR_EMU)
			Graphics.drawScaleImage(LISTAS.FONDO, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F, CAMBIOS_EMUS.COLOR_EMU)
		elseif lista_config[3] == 1 and lista_config[2] == 1 then
			Graphics.drawScaleImage(LISTAS.FONDO, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F)
			Graphics.drawRect(0, 0, CONTROL.ANCHO, CONTROL.ALTO_F, color_demo)
		else
			Graphics.drawScaleImage(LISTAS.FONDO, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F)
		end
		Graphics.drawRect(12, 28+CONTROL.Y_FIX_PAL, 615, 405, COLOR.NEGRO_T)

		-- Muestra y determina el estado de cada página. --------------------------------
		Graphics.drawScaleImage(PAD_IMG.L1, (CONTROL.ANCHO//2)-106, 0+CONTROL.Y_FIX_PAL, 32, 32)
		Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 6+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 25, page, COLOR.BLANCO_LISTA)
		Graphics.drawScaleImage(PAD_IMG.R1, (CONTROL.ANCHO//2)+74, 0+CONTROL.Y_FIX_PAL, 32, 32)
		local contador, ini = 1, 1
		if conf_numero == true then ini = 1 else ini = 22 end

		-- Controla el scroll. ----------------------------------------------------------
		if CONTROL.ESPERA_CARGA_SCR == false then
			LISTAS.SCROLL_TEX = scroll_texto(LISTAS.SCROLL_TEX, lista_texto_config[27], 44)
		end

		-- Muestra las opciones y su estado. --------------------------------------------
		for estado = ini, #lista_config do
			-- Define el estado. --------------------------------------------------------
			local acti = "ON"
			if lista_config[estado] == 0 then acti = "OFF" end
			if contador == 11 and conf_numero == false then
				if lista_config[estado] == 0 then acti = "NTSC" else acti = "PAL" end
			end
			local text_especial = {"DEFAULT", "MC 0", "MC 1", "CURRENT", "SIMPLE", "COVER ART", "FULL ART", "BIG COVER", "BIG ART", "BIG LIST", "CUSTOM"}
			if contador == 7 and conf_numero == true then acti = text_especial[estilo_lista+4] end
			if contador == 5 and conf_numero == false then acti = text_especial[selec_dir+1] end

			-- Muestra todas las opciones de la página y su estado. ---------------------
			local espacio_linea = (8+(contador)*25)+CONTROL.Y_FIX_PAL
			if estado <= 7 or estado >= 22 or estado == #lista_config then
				local color_mos = COLOR.BLANCO_LISTA
				if estado == selector then
					color_mos = CAMBIOS_EMUS.COLOR_EMU
					Graphics.drawRect(12+5, espacio_linea-3, 610-7, 25, COLOR.NEGRO_T)
				end
				if estado == #lista_config then
					Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 408+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 25, "".. lista_texto_config[estado], color_mos)
				elseif estado == 27 then
					Font.ftPrint(CONTROL.fontARCA, 22, espacio_linea, 0, 601, 8, "".. string.sub(lista_texto_config[estado], LISTAS.SCROLL_TEX), color_mos)
				else
					Font.ftPrint(CONTROL.fontARCA, 22, espacio_linea, 0, 0, 8, "".. lista_texto_config[estado], color_mos)
				end
				if estado >= 4 and estado <= 6 then
					Graphics.drawRect(565, 19+100+CONTROL.Y_FIX_PAL, 45, 45, color_demo)
					if estado == 4 then
						Font.ftPrint(CONTROL.fontARCA, 489, espacio_linea, 0, 0, 8, "".. color1, color_mos)
					elseif estado == 5 then
						Font.ftPrint(CONTROL.fontARCA, 489, espacio_linea, 0, 0, 8, "".. color2, color_mos)
					elseif estado == 6 then
						Font.ftPrint(CONTROL.fontARCA, 489, espacio_linea, 0, 0, 8, "".. color3, color_mos)
					end
				else
					if estado == 7 then
						Font.ftPrint(CONTROL.fontARCA, 489, espacio_linea, 0, 0, 8, "".. acti, color_mos)
					elseif estado == #lista_config then
						Font.ftPrint(CONTROL.fontARCA, 209, 408+CONTROL.Y_FIX_PAL, 0, 0, 8, " ", color_mos)
					elseif estado == 22 then
						Font.ftPrint(CONTROL.fontARCA, 489, espacio_linea, 0, 0, 8, "".. selec_fuente, color_mos)
					elseif estado == 23 then
						Font.ftPrint(CONTROL.fontARCA, 489, espacio_linea, 0, 0, 8, "".. selec_fondo, color_mos)
					elseif estado == 26 or estado == 32 then
						Font.ftPrint(CONTROL.fontARCA, 489, espacio_linea, 0, 0, 8, "".. acti, color_mos)
					elseif estado == 30 then
						Font.ftPrint(CONTROL.fontARCA, 489, espacio_linea, 0, 0, 8, "".. volume, color_mos)
					elseif estado == 27 or estado == 35 or estado == 36 then
						Font.ftPrint(CONTROL.fontARCA, 16, espacio_linea, 0, 0, 8, "", color_mos)
					else
						Font.ftPrint(CONTROL.fontARCA, 489, espacio_linea, 0, 0, 8, "STATE: ".. acti, color_mos)
					end
				end
				if estado == selector and ((estado == 7 and estilo_lista == 7 ) or estado == 22 or estado == 25 or estado == 29) then
					Graphics.drawScaleImage(PAD_IMG.SELECT_S, 458, espacio_linea, 20, 20)
				end
			else
				Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 206+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 25, "- Activate Systems -", COLOR.BLANCO_LISTA)
				if selector == #lista_config then Graphics.drawRect(12+5, 408-3+CONTROL.Y_FIX_PAL, 610-7, 25, COLOR.NEGRO_T) end
				local color_mos = COLOR.BLANCO_LISTA
				local x_recta, y_recta_fix, x_name, x_act, x_img = 17, 23, 22, 261, 232
				if estado >= 15 then
					x_recta, y_recta_fix, x_name, x_act, x_img = 332, -152, 337, 576, 547
				end
				if estado == selector then
					color_mos = CAMBIOS_EMUS.COLOR_EMU
					Graphics.drawRect(x_recta, espacio_linea-3+(y_recta_fix), 293-7, 25, COLOR.NEGRO_T)
					Font.ftPrint(CONTROL.fontARCA, x_name, espacio_linea+(y_recta_fix), 0, 0, 8, "".. lista_texto_config[estado], CAMBIOS_EMUS.COLOR_EMU)
					Font.ftPrint(CONTROL.fontARCA, x_act, espacio_linea+(y_recta_fix), 0, 0, 8, "".. acti, CAMBIOS_EMUS.COLOR_EMU)
					if estado <= 18 then
						Graphics.drawScaleImage(PAD_IMG.SELECT_S, x_img, espacio_linea+(y_recta_fix), 20, 20)
					end
				else
					Font.ftPrint(CONTROL.fontARCA, x_name, espacio_linea+(y_recta_fix), 0, 0, 8, "".. lista_texto_config[estado], COLOR.BLANCO_LISTA)
					Font.ftPrint(CONTROL.fontARCA, x_act, espacio_linea+(y_recta_fix), 0, 0, 8, "".. acti, COLOR.BLANCO_LISTA)
				end
			end
			contador = contador+1
		end

		-- Dibuja una pequeña muestra de los efectos en el cambio de colores. -----------
		if conf_numero == true then
			if lista_config[3] == 1 and tras_demo ~= 0 then
				Graphics.drawRect(194-3, 109-3+CONTROL.Y_FIX_PAL, 252+6, 76+6, COLOR.NEGRO_T)
				Graphics.drawScaleImage(LOGOS.DEFAULT_DEMO, 194, 109+CONTROL.Y_FIX_PAL, 252, 76)
				Graphics.drawRect(194, 109+CONTROL.Y_FIX_PAL, 252, 76, color_demo)
			else
				Graphics.drawScaleImage(LOGOS.DEFAULT_DEMO, 194, 109+CONTROL.Y_FIX_PAL, 252, 76, CAMBIOS_EMUS.COLOR_EMU)
			end
			if lista_config[3] == 1 and selector >= 4 and selector <= 6 then
				local color_mos, text_tras = COLOR.BLANCO_LISTA, ("Transparency ".. tras_demo)
				Graphics.drawRect(12+5, 185-3+CONTROL.Y_FIX_PAL, 610, 25, COLOR.NEGRO)
				Graphics.drawScaleImage(PAD_IMG.SQUARE, 194, 185+CONTROL.Y_FIX_PAL, 20, 20)
				if tras_demo == 0 then text_tras = "Transparency OFF" end
				local PAD_indi = Pads.get(0)
				if Pads.check(PAD_indi, PAD_SQUARE) then color_mos = CAMBIOS_EMUS.COLOR_EMU end
				Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 185+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 25, text_tras, color_mos)
			end
		end
		refrescar(false)
	end
	Pads.rumble(0, 0, 0)
	if reinicio == false then
		animaciones(nil)
	elseif reinicio == true then
		reiniciar_conf(clean, indi_rest_RL)
		if indi_rest_RL ~= 0 and indi_rest_RL ~= 20 then animaciones(nil) end
	end
	CONTROL.JOYSTICK_ON = false
	JOYSTICK_LIMITE = control_FPS(2)
	limpiar_art()
	LISTAS.MOSTRAR = 0
end

--- Ordena las listas ignorando mayúsculas. ---------------------------------------------
function orden_alfabetico(a, b)
	return a:lower() < b:lower()
end

--- Ordena las listas para PS1 y PS2. ---------------------------------------------------
function orden_alfabetico_PS(a, b)
	local consiA, consiB = false, false
	if string.match(a, "%a+_%d+.%d+%.") then
		consiA = true
	end
	if string.match(b, "%a+_%d+.%d+%.") then
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

	-- Búsquedas para cores de Retroarch. -----------------------------------------------
	if identidad <= 11 then
		-- Lista de sistemas. -----------------------------------------------------------
		local dir_sistemas = {"Sega Megadrive", "Sega Master System", "Sega Game Gear", "Nintendo Famicom", "Nintendo Game Boy", "Nintendo Game Boy Color", "Nintendo Game Boy Advance", "Atari 2600", "Sega SG-1000", "Neo Geo Pocket", "Nintendo Super Famicom"}

		-- Lista de extensiones. --------------------------------------------------------
		local name_exten = {{".zip", ".bin", ".gen", ".smd", ".md"}; {".zip", ".sms"}; {".zip", ".gg"};
		{".zip", ".nes", ".fds", ".unf"}; {".zip", ".gb"}; {".zip", ".gbc"}; {".gba", ".bin"}; {".zip", ".a26", ".bin"};
		{".zip", ".sg"}; {".zip", ".ngc", ".ngp", ".npc"}; {".zip", ".sfc", ".smc"};};
		local exten = name_exten[identidad]
		local exten_mini = true
		local temp_ext2 = ""
		if identidad ~= 1 and identidad ~= 3 and identidad ~= 5 and identidad ~= 9 then exten_mini = false end

		-- Realizar búsquedas. ----------------------------------------------------------
		local buscar = System.listDirectory(actual.."/Roms/Roms ".. dir_sistemas[identidad])
		if buscar ~= nil then
			for contador = 1, #buscar do
				if buscar[contador].directory == false then
					local temp_ext = string.lower(string.sub(buscar[contador].name, -4))
					if exten_mini == true then temp_ext2 = string.lower(string.sub(buscar[contador].name, -3)) end
					for test = 1, #exten do
						if temp_ext == exten[test] then
							table.insert(encontrados, buscar[contador].name)
						elseif exten_mini == true and temp_ext2 == exten[test] then
							table.insert(encontrados, buscar[contador].name .." ")
						end
					end
				end
			end
			if encontrados ~= nil and #encontrados >= 1 then
				lista = encontrados
				table.sort(lista, orden_alfabetico)
				return lista
			else
				lista = {}
				return lista
			end
		else
			lista = {}
			return lista
		end

	-- Búsquedas para APPS. -------------------------------------------------------------
	elseif identidad == 12 then
		-- Lista de directorios. --------------------------------------------------------
		local buscar_directorio = {device .."/APPS", "mc0:/APPS", "mc1:/APPS", actual .."/Roms/APPS", "cdfs:", "mc0:", "mc1:", device}
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
		for buscar_apps = 1, #buscar_directorio do
			if buscar_directorio[buscar_apps] ~= nil then
				local buscar = System.listDirectory(buscar_directorio[buscar_apps])
				if buscar ~= nil then
					for contador = 1, #buscar do
						local recursiva = nil
						if buscar[contador].directory == false and (string.lower(string.sub(buscar[contador].name, -4)) == ".elf"
							or (buscar_apps == 5 and string.match(buscar[contador].name, "%a+_%d+.%d+") == buscar[contador].name)) then
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
							elseif (buscar_apps == 2 or buscar_apps == 3) and (string.sub(buscar[contador].name, -1) ~= "." and
								string.sub(buscar[contador].name, -2) ~= ".." and string.lower(buscar[contador].name) ~= "retrolauncher") then
								recursiva = System.listDirectory(buscar_directorio[buscar_apps] .."/".. buscar[contador].name)
							elseif (buscar_apps == 6 or buscar_apps == 7) and (string.match(buscar[contador].name, ".+_.+") and
								string.sub(buscar[contador].name, -1) ~= "." and string.sub(buscar[contador].name, -2) ~= ".." ) then
								recursiva = System.listDirectory(buscar_directorio[buscar_apps] .."/".. buscar[contador].name)
							elseif buscar_apps == 8 and string.lower(buscar[contador].name) ~= "retrolauncher" and
								string.lower(buscar[contador].name) ~= "sys-conf" and string.lower(buscar[contador].name) ~= "boot" and
									string.lower(buscar[contador].name) ~= "pops" and string.lower(buscar[contador].name) ~= "apps" then
								recursiva = System.listDirectory(buscar_directorio[buscar_apps] .."/".. buscar[contador].name)
							end
						end
						if recursiva ~= nil then
							for contador2 = 1, #recursiva do
								if recursiva[contador2].directory == false and string.lower(string.sub(recursiva[contador2].name, -4)) == ".elf" then
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

	-- Búsquedas para Play Station 1. ---------------------------------------------------
	elseif identidad == 13 then
		-- Realizar búsqueda. -----------------------------------------------------------
		local buscar = System.listDirectory(device .."/POPS")
		if buscar ~= nil then
			for contador = 1, #buscar do
				if buscar[contador].directory == false and string.lower(string.sub(buscar[contador].name, -4)) == ".vcd" then
					table.insert(encontrados, buscar[contador].name)
				end
			end
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

	-- Búsquedas para Play Station 2. ---------------------------------------------------
	elseif identidad == 14 then
		-- Lista de directorios. --------------------------------------------------------
		local buscar_directorio = {actual.."/Roms/ISOs PlayStation 2", device .."/DVD", device .."/CD", "cdfs:"}
		if OPCIONES.DIR_EXTRAS_ON == 0 then
			buscar_directorio[2] = nil
			buscar_directorio[3] = nil
		end

		-- Realizar búsqueda. -----------------------------------------------------------
		for buscar_ps2 = 1, #buscar_directorio do
			if buscar_directorio[buscar_ps2] ~= nil then
				local buscar = System.listDirectory(buscar_directorio[buscar_ps2])
				if buscar ~= nil then
					for contador = 1, #buscar do
						if buscar[contador].directory == false and (buscar_ps2 ~= 4 and string.lower(string.sub(buscar[contador].name, -4)) == ".iso")
							or ((buscar_ps2 == 2 or buscar_ps2 == 3) and string.lower(string.sub(buscar[contador].name, -4)) == ".mx4" or string.lower(string.sub(buscar[contador].name, -4)) == ".hdd" or string.lower(string.sub(buscar[contador].name, -4)) == ".mmc")
								or (buscar_ps2 == 4 and string.match(buscar[contador].name, "%a+_%d+.%d+") == buscar[contador].name) then
							if buscar_ps2 == 4 then
								table.insert(encontrados, buscar[contador].name ..".".. obtener_nombre_DVD(buscar[contador].name, true))
							else
								table.insert(encontrados, buscar[contador].name)
							end
						end
					end
				end
			end
		end
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
	if identidad <= 11 then
		-- Lista de sistemas. -----------------------------------------------------------
		local dir_sistemas = {"Sega Megadrive", "Sega Master System", "Sega Game Gear", "Nintendo Famicom", "Nintendo Game Boy", "Nintendo Game Boy Color", "Nintendo Game Boy Advance", "Atari 2600", "Sega SG-1000", "Neo Geo Pocket", "Nintendo Super Famicom"}

		-- Lista de aplicaciones. -------------------------------------------------------
		local name_cores = {"picodrive_libretro_ps2.elf", "picodrive_libretro_ps2.elf", "picodrive_libretro_ps2.elf", "fceumm_libretro_ps2.elf", "gambatte_libretro_ps2.elf", "gambatte_libretro_ps2.elf", "gpsp_libretro_ps2.elf", "stella2014_libretro_ps2.elf", "picodrive_libretro_ps2.elf", "race_libretro_ps2.elf", "snes9x2002_libretro_ps2.elf"}

		-- Lista de aplicaciones alternativas. ------------------------------------------
		local name_cores_alt = {"picodrive_libretro_ps2_alt.elf", " ", " ", "quicknes_libretro_ps2.elf", "tgbdual_libretro_ps2.elf", "tgbdual_libretro_ps2.elf", "TempGBA.elf", " ", " ", " ", " "}

		-- Corrección en directorios alternativos. --------------------------------------
		local dir_especiales = "cores"
		if identidad == 7 and alternativo == true then dir_especiales = "TempGBA" end
		if doesFileExist(actual .."/Roms/Roms ".. dir_sistemas[identidad] .."/".. nombre_juego) and doesFileExist(actual .."/System/RetroarchPS2/".. dir_sistemas[identidad] .."/".. dir_especiales .."/".. name_cores[identidad]) and alternativo == false then
			return true
		elseif doesFileExist(actual .."/Roms/Roms ".. dir_sistemas[identidad] .."/".. nombre_juego) and doesFileExist(actual .."/System/RetroarchPS2/".. dir_sistemas[identidad] .."/".. dir_especiales .."/".. name_cores_alt[identidad]) and alternativo == true then
			return true
		else
			return false
		end

	-- Comprobar la existencia de archivos necesarios (APPS). ---------------------------
	elseif identidad == 12 then
		if doesFileExist(LISTAS.DIR_FULL_APP[LISTAS.INDICE]) and doesFileExist(actual .."/System/RetroarchPS2/APPS/WLE.elf") and alternativo == false then
			return true
		elseif doesFileExist(LISTAS.DIR_FULL_APP[LISTAS.INDICE]) then
			return true
		else
			return false
		end

	-- Comprobar la existencia de archivos necesarios (Play Station 1). -----------------
	elseif identidad == 13 then
		if doesFileExist(device .."/POPS/".. nombre_juego) and doesFileExist(device .."/POPS/POPS_IOX.PAK") and doesFileExist(device .."/POPS/IOPRP252.IMG") then
			return true
		else
			return false
		end

	-- Comprobar la existencia de archivos necesarios (Play Station 2). -----------------
	elseif identidad == 14 then
		if doesFileExist(actual .."/Roms/ISOs PlayStation 2/".. nombre_juego) and doesFileExist(actual .."/System/RetroarchPS2/Sony PlayStation 2/neutrino.elf") then
			return true
		elseif doesFileExist(device .."/DVD/".. nombre_juego) and doesFileExist(actual .."/System/RetroarchPS2/Sony PlayStation 2/neutrino.elf") and OPCIONES.DIR_EXTRAS_ON == 1 then
			return true
		elseif doesFileExist(device .."/CD/".. nombre_juego) and doesFileExist(actual .."/System/RetroarchPS2/Sony PlayStation 2/neutrino.elf") and OPCIONES.DIR_EXTRAS_ON == 1 then
			return true
		elseif doesFileExist("cdfs:/".. string.sub(nombre_juego, 1, 11)) then
			return true
		else
			return false
		end
	else
		return false
	end
end

--- Ejecuta las ISO de Play Station 2. --------------------------------------------------
function ejecutar_iso(nombre)
	local actual = System.currentDirectory()
	local device = salida_texto_dir(actual, nil)

	-- Buscar y cargar configuraciones de "VMC". ----------------------------------------
	local vmc, carga_vmc = nil, nil
	if doesFileExist(actual .."/Roms/ISOs PlayStation 2/Configs/".. string.sub(nombre, 1, -5) ..".vmcd") then
		carga_vmc = System.openFile(actual .."/Roms/ISOs PlayStation 2/Configs/".. string.sub(nombre, 1, -5) ..".vmcd", FREAD)
	elseif doesFileExist(actual .."/Roms/ISOs PlayStation 2/".. string.sub(nombre, 1, -5) ..".vmcd") then
		carga_vmc = System.openFile(actual .."/Roms/ISOs PlayStation 2/".. string.sub(nombre, 1, -5) ..".vmcd", FREAD)
	elseif doesFileExist(device .."/DVD/".. string.sub(nombre, 1, -5) ..".vmcd") and OPCIONES.DIR_EXTRAS_ON == 1 then
		carga_vmc = System.openFile(device .."/DVD/".. string.sub(nombre, 1, -5) ..".vmcd", FREAD)
	elseif doesFileExist(device .."/CD/".. string.sub(nombre, 1, -5) ..".vmcd") and OPCIONES.DIR_EXTRAS_ON == 1 then
		carga_vmc = System.openFile(device .."/CD/".. string.sub(nombre, 1, -5) ..".vmcd", FREAD)
	end
	if carga_vmc ~= nil then
		System.seekFile(carga_vmc, 0, SET)
		local size = System.sizeFile(carga_vmc)
		local temp = System.readFile(carga_vmc, size)
		for linea in string.gmatch(temp, "-mc0=.+") do
			vmc = linea
		end
		if vmc ~= nil then
			if doesFileExist(string.sub(vmc, 6)) == false then
				vmc = nil
			elseif doesFileExist(string.sub(vmc, 6)) == true and OPCIONES.PREGUNTAR_PS2 == false then
				local fix_ext = string.lower(string.sub(vmc, -4))
				if fix_ext == ".mx4" or fix_ext == ".hdd" or fix_ext == ".mmc" then
					vmc = string.sub(vmc, 1, -5) ..".bin"
				end
			end
		end
		System.closeFile(carga_vmc)
	end

	-- Buscar y cargar modos de compatibilidad. -----------------------------------------
	local modos, carga_mode = nil, nil
	if doesFileExist(actual .."/Roms/ISOs PlayStation 2/Configs/".. string.sub(nombre, 1, -5) ..".mode") then
		carga_mode = System.openFile(actual .."/Roms/ISOs PlayStation 2/Configs/".. string.sub(nombre, 1, -5) ..".mode", FREAD)
	elseif doesFileExist(actual .."/Roms/ISOs PlayStation 2/".. string.sub(nombre, 1, -5) ..".mode") then
		carga_mode = System.openFile(actual .."/Roms/ISOs PlayStation 2/".. string.sub(nombre, 1, -5) ..".mode", FREAD)
	elseif doesFileExist(device .."/DVD/".. string.sub(nombre, 1, -5) ..".mode") and OPCIONES.DIR_EXTRAS_ON == 1 then
		carga_mode = System.openFile(device .."/DVD/".. string.sub(nombre, 1, -5) ..".mode", FREAD)
	elseif doesFileExist(device .."/CD/".. string.sub(nombre, 1, -5) ..".mode") and OPCIONES.DIR_EXTRAS_ON == 1 then
		carga_mode = System.openFile(device .."/CD/".. string.sub(nombre, 1, -5) ..".mode", FREAD)
	end
	if carga_mode ~= nil then
		System.seekFile(carga_mode, 0, SET)
		local size2 = System.sizeFile(carga_mode)
		local temp2 = System.readFile(carga_mode, size2)
		for linea in string.gmatch(temp2, "-gc=%d+") do
			modos = linea
		end
		System.closeFile(carga_mode)
	end

	-- Buscar y cargar configuraciones de "GSM". ----------------------------------------
	local GSM, carga_gsm = nil, nil
	if doesFileExist(actual .."/Roms/ISOs PlayStation 2/Configs/".. string.sub(nombre, 1, -5) ..".mgsm") then
		carga_gsm = System.openFile(actual .."/Roms/ISOs PlayStation 2/Configs/".. string.sub(nombre, 1, -5) ..".mgsm", FREAD)
	elseif doesFileExist(actual .."/Roms/ISOs PlayStation 2/".. string.sub(nombre, 1, -5) ..".mgsm") then
		carga_gsm = System.openFile(actual .."/Roms/ISOs PlayStation 2/".. string.sub(nombre, 1, -5) ..".mgsm", FREAD)
	elseif doesFileExist(device .."/DVD/".. string.sub(nombre, 1, -5) ..".mgsm") and OPCIONES.DIR_EXTRAS_ON == 1 then
		carga_gsm = System.openFile(device .."/DVD/".. string.sub(nombre, 1, -5) ..".mgsm", FREAD)
	elseif doesFileExist(device .."/CD/".. string.sub(nombre, 1, -5) ..".mgsm") and OPCIONES.DIR_EXTRAS_ON == 1 then
		carga_gsm = System.openFile(device .."/CD/".. string.sub(nombre, 1, -5) ..".mgsm", FREAD)
	end
	if carga_gsm ~= nil then
		System.seekFile(carga_gsm, 0, SET)
		local size3 = System.sizeFile(carga_gsm)
		local temp3 = System.readFile(carga_gsm, size3)
		for linea in string.gmatch(temp3, "-gsm=.+") do
			GSM = linea
		end
		System.closeFile(carga_gsm)
	end

	-- Preparar comandos para ejecutar el juego. ----------------------------------------
	if OPCIONES.PREGUNTAR_PS2 == false then
		-- Verificar GSM. ---------------------------------------------------------------
		if GSM == nil then GSM = "-gsm=" end

		-- Definir el directorio donde se encuentra el juego. ---------------------------
		local selector_device = 1
		local name_device = {actual, device, "mmce:"}
		local selector_dir = 1
		local dir_iso = {"/Roms/ISOs PlayStation 2/", "/DVD/", "/CD/"}
		if doesFileExist(actual .."/Roms/ISOs PlayStation 2/".. nombre) then
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
		local name_bsd = {"usb", "mx4sio", "ata", "mmce"}
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
		end

		-- Lanzar el juego. -------------------------------------------------------------
		local directorio_iso = name_device[selector_device] .. dir_iso[selector_dir]
		if modos == nil and vmc == nil then
			System.loadELF(actual .."/System/RetroarchPS2/Sony PlayStation 2/neutrino.elf", 0, GSM, "-bsd=".. name_bsd[selector_bsd], "-dvd=".. directorio_iso .. nombre_final)
		elseif modos == nil and vmc ~= nil then
			System.loadELF(actual .."/System/RetroarchPS2/Sony PlayStation 2/neutrino.elf", 0, vmc, GSM, "-bsd=".. name_bsd[selector_bsd], "-dvd=".. directorio_iso .. nombre_final)
		elseif modos ~= nil and vmc == nil then
			System.loadELF(actual .."/System/RetroarchPS2/Sony PlayStation 2/neutrino.elf", 0, modos, GSM, "-bsd=".. name_bsd[selector_bsd], "-dvd=".. directorio_iso .. nombre_final)
		elseif modos ~= nil and vmc ~= nil then
			System.loadELF(actual .."/System/RetroarchPS2/Sony PlayStation 2/neutrino.elf", 0, vmc, modos, GSM, "-bsd=".. name_bsd[selector_bsd], "-dvd=".. directorio_iso .. nombre_final)
		end

	-- Devuelve las configuraciones encontradas al menú de configuración de PS2. --------
	elseif OPCIONES.PREGUNTAR_PS2 == true then
		return vmc, modos, GSM
	end
end

--- Ejecuta cada juego con su respectiva aplicación. ------------------------------------
function ejecutar_juego(identidad, nombre_juego, alternativo)
	local actual = System.currentDirectory()
	local device = salida_texto_dir(actual, nil)

	-- Ejecutar los sistemas de Retroarch. ----------------------------------------------
	if identidad <= 11 then
		-- Lista de sistemas. -----------------------------------------------------------
		local dir_sistemas = {"Sega Megadrive", "Sega Master System", "Sega Game Gear", "Nintendo Famicom", "Nintendo Game Boy", "Nintendo Game Boy Color", "Nintendo Game Boy Advance", "Atari 2600", "Sega SG-1000", "Neo Geo Pocket", "Nintendo Super Famicom"}

		-- Lista de aplicaciones. -------------------------------------------------------
		local name_cores = {"picodrive_libretro_ps2.elf", "picodrive_libretro_ps2.elf", "picodrive_libretro_ps2.elf", "fceumm_libretro_ps2.elf", "gambatte_libretro_ps2.elf", "gambatte_libretro_ps2.elf", "gpsp_libretro_ps2.elf", "stella2014_libretro_ps2.elf", "picodrive_libretro_ps2.elf", "race_libretro_ps2.elf", "snes9x2002_libretro_ps2.elf"}

		-- Lista de aplicaciones alternativas. ------------------------------------------
		local name_cores_alt = {"picodrive_libretro_ps2_alt.elf", " ", " ", "quicknes_libretro_ps2.elf", "tgbdual_libretro_ps2.elf", "tgbdual_libretro_ps2.elf", "TempGBA.elf", " ", " ", " ", " "}

		-- Corrección en directorios alternativos. --------------------------------------
		local dir_especiales = "cores"
		if identidad == 7 and alternativo == true then dir_especiales = "TempGBA" end

		-- Ejecutar juego. --------------------------------------------------------------
		guardar()
		if alternativo == true then
			System.loadELF(actual .."/System/RetroarchPS2/".. dir_sistemas[identidad] .."/".. dir_especiales .."/".. name_cores_alt[identidad], 0, actual .."/Roms/Roms ".. dir_sistemas[identidad] .."/".. nombre_juego)
		else
			System.loadELF(actual .."/System/RetroarchPS2/".. dir_sistemas[identidad] .."/".. dir_especiales .."/".. name_cores[identidad], 0, actual .."/Roms/Roms ".. dir_sistemas[identidad] .."/".. nombre_juego)
		end

	-- Ejecutar APPS. -------------------------------------------------------------------
	elseif identidad == 12 then
		guardar()
		if doesFileExist(actual .."/System/RetroarchPS2/APPS/WLE.elf") and alternativo == false then
			app_alt(false)
			System.loadELF(actual .."/System/RetroarchPS2/APPS/WLE.elf", 0, actual .."/System/RetroarchPS2/APPS/")
		else
			System.loadELF(LISTAS.DIR_FULL_APP[LISTAS.INDICE], 0, salida_texto_dir(LISTAS.DIR_FULL_APP[LISTAS.INDICE], false))
		end

	-- Ejecutar sistema de Play Station 1. ----------------------------------------------
	elseif identidad == 13 then
		guardar()
		if doesFileExist(device .."/POPS/XX.".. string.sub(nombre_juego, 1, -5) ..".ELF") then
			System.loadELF(device .."/POPS/XX.".. string.sub(nombre_juego, 1, -5) ..".ELF", 0, device .."/POPS/", "--nr")
		else
			if doesFileExist(actual .."/System/RetroarchPS2/Sony PlayStation/POPSTARTER.ELF") then
				System.copyFile(actual .."/System/RetroarchPS2/Sony PlayStation/POPSTARTER.ELF", device .."/POPS/XX.".. string.sub(nombre_juego, 1, -5) ..".ELF")
			else
				error("No found \"".. actual .."/System/RetroarchPS2/Sony PlayStation/POPSTARTER.ELF\"")
			end
			System.loadELF(device .."/POPS/XX.".. string.sub(nombre_juego, 1, -5) ..".ELF", 0, device .."/POPS/", "--nr")
		end

	-- Ejecutar sistema de Play Station 2. ----------------------------------------------
	elseif identidad == 14 then
		guardar()
		if string.lower(string.sub(nombre_juego, -4)) == ".elf" then
			System.loadELF("cdfs:/".. string.sub(nombre_juego, 1, 11), 0, "cdfs:/")
		else
			ejecutar_iso(nombre_juego)
		end
	end
end

--- Crear archivo "LAUNCHELF.CNF" para lanzar aplicaciones con WLE. ---------------------
function app_alt(salida)
	local actual = System.currentDirectory()
	if doesFileExist(actual.. "/System/RetroarchPS2/APPS/LAUNCHELF.CNF") then
		System.removeFile(actual.. "/System/RetroarchPS2/APPS/LAUNCHELF.CNF")
	end
	local apps_l = LISTAS.DIR_FULL_APP[LISTAS.INDICE]
	local title_app_l = string.sub(LISTAS.ROMS[LISTAS.INDICE], 1, -CONTROL.EXTENSION)
	if OPCIONES.APPS_MENU_FULL_PATH == 1 then
		title_app_l = salida_texto_dir(string.sub(LISTAS.ROMS[LISTAS.INDICE], 1, -CONTROL.EXTENSION), true)
	end
	if salida == true then
		apps_l = OPCIONES.SALIDA_RETROLANCHER
		title_app_l = string.sub(salida_texto_dir(OPCIONES.SALIDA_RETROLANCHER, true), 1, -CONTROL.EXTENSION)
	elseif salida == nil then
		apps_l = actual .."/RETROLauncher.elf"
		title_app_l = "RETROLauncher"
	end
	local config_wlc = {"CNF_version = 3"; "LK_auto_E1 = ".. apps_l; "LK_Circle_E1 = ".. actual.. "/RETROLauncher.elf"; "LK_Cross_E1 = ".. apps_l;
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
	"Menu_Title = RETROLauncher"; "Init_Delay = 0"; "USBKBD_USED = 0"; "USBKBD_FILE = "; "KBDMAP_FILE = "; "Menu_Show_Titles = 1";
	"PathPad_Lock = 0"; "CNF_Path = "; "LANG_FILE = "; "FONT_FILE = "; "JpgView_Timer = 5"; "JpgView_Trans = 2"; "JpgView_Full = 0";
	"PSU_HugeNames = 0"; "PSU_DateNames = 0"; "PSU_NoOverwrite = 0"; "FB_NoIcons = 0"; "LK_Circle_Title = RETROLauncher";
	"LK_Cross_Title = ".. title_app_l; "LK_Square_Title = About uLE"; "PathPad_Lock = 0";};
	local LCHELF_COF = ""
	for crear = 1, #config_wlc do
		LCHELF_COF = LCHELF_COF .. config_wlc[crear] .. "\r\n"
	end
	local LCHELF = System.openFile(actual.. "/System/RetroarchPS2/APPS/LAUNCHELF.CNF", FCREATE)
	System.writeFile(LCHELF, LCHELF_COF, string.len(LCHELF_COF))
	System.closeFile(LCHELF)
end

--- Determina el volumen de los sonidos y la música. ------------------------------------
function set_volume()
	Sound.setADPCMVolume(1, OPCIONES.SOUND_VOLUME)
	Sound.setADPCMVolume(3, OPCIONES.SOUND_VOLUME)
	if OPCIONES.SOUND_VOLUME >= 10 then
		Sound.setADPCMVolume(2, OPCIONES.SOUND_VOLUME-9)
	else
		Sound.setADPCMVolume(2, 0)
	end
end

--- Muestra barra de progreso. ----------------------------------------------------------
function pantalla_reiniciar_conf(FONDO, estado, limpiar, indi_rest)
	Screen.clear(Color.new(0, 0, 0))
	local res_x, res_y_tex, res_y = 640, 0, 448
	if doesFileExist("System/Respaldo/PAL") then
		res_x, res_y_tex, res_y = 640, 34, 512
	end
	Graphics.drawScaleImage(FONDO, -5, 0, res_x+5, res_y, Color.new(0, 80, 120))
	Graphics.drawScaleImage(LISTAS.LOADING, 0, 0, res_x, res_y)
	Graphics.drawRect(-5, 278-3+res_y_tex, 650, 25, COLOR.NEGRO)
	local lista_indi_rest = {"Atari 2600", "Neo Geo Pocket", "Nintendo Famicom", "Nintendo Game Boy", "Nintendo Game Boy Advance", "Nintendo Game Boy Color", "Nintendo Super Famicom", "Sega Game Gear", "Sega Master System", "Sega Megadrive", "Sega SG-1000"}
	if limpiar == true then
		Font.ftPrint(CONTROL.fontARCA, (640//2), 278+res_y_tex, 8, 640, 25, "- DELETING SAVES STATES -", COLOR.BLANCO)
	elseif indi_rest ~= 0 and indi_rest ~= 20 and indi_rest ~= 21 and limpiar == false then
		Font.ftPrint(CONTROL.fontARCA, (640//2), 278+res_y_tex, 8, 640, 25, "-RESTARTING ".. lista_indi_rest[indi_rest] .."-", COLOR.BLANCO)
	elseif indi_rest == 20 and limpiar == false then
		Font.ftPrint(CONTROL.fontARCA, (640//2), 278+res_y_tex, 8, 640, 25, "-CHANGING VIDEO SETTINGS-", COLOR.BLANCO)
	elseif indi_rest == 21 and limpiar == false then
		Font.ftPrint(CONTROL.fontARCA, (640//2), 278+res_y_tex, 8, 640, 25, "-LOADING GAME LISTS AND SETTINGS-", COLOR.BLANCO)
	else
		Font.ftPrint(CONTROL.fontARCA, (640//2), 278+res_y_tex, 8, 640, 25, "-RESTARTING ALL SETTINGS-", COLOR.BLANCO)
	end
	Font.ftPrint(CONTROL.fontARCA, (640//2), 304+res_y_tex, 8, 640, 25, "█████████████████████████", COLOR.BLANCO)
	if estado ~= 0 then
		Font.ftPrint(CONTROL.fontARCA, (640//2), 304+res_y_tex, 8, 640, 25, string.sub("█████████████████████████", 1, estado), Color.new(0, 80, 120))
	end
	refrescar(false)
end

--- Guardar último juego y sistema usado. -----------------------------------------------
function guardar()
	local actual = System.currentDirectory()
	local config = ("".. LISTAS.IDENTIDAD .." ".. LISTAS.INDICE .." ".. LAST_MOVE[1] .." ".. LAST_MOVE[2] .." ".. LAST_MOVE[3] .." ".. LAST_MOVE[4] .." ".. LAST_MOVE[5] .." ".. LAST_MOVE[6] .." ".. LAST_MOVE[7] .." ".. LAST_MOVE[8] .." ".. LAST_MOVE[9] .." ".. LAST_MOVE[10] .." ".. LAST_MOVE[11] .." ".. LAST_MOVE[12] .." ".. LAST_MOVE[13] .." ".. LAST_MOVE[14] .."                                                                                                    ")
	if doesFileExist(actual .."/System/Config/Config.cfg") then
		local carga_de_config = System.openFile("System/Config/Config.cfg", FRDWR)
		System.writeFile(carga_de_config, config .." ", string.len(config))
		System.closeFile(carga_de_config)
	else
		if doesFileExist(actual .."/System/Respaldo/Config.cfg") then
			System.copyFile(actual .."/System/Respaldo/Config.cfg", "System/Config/Config.cfg")
			guardar()
		else
			error("No found ".. actual .."/System/Respaldo/Config.cfg")
		end
	end
end

--- Carga el directorio de salida seleccionado. -----------------------------------------
function cargar_directorio_elf()
	local actual = System.currentDirectory()
	if doesFileExist(actual .."/System/Config/Path_file.cfg") then
		local carga_de_dir = System.openFile(actual .."/System/Config/Path_file.cfg", FREAD)
		System.seekFile(carga_de_dir, 0, SET)
		local size = System.sizeFile(carga_de_dir)
		local temp_dir = System.readFile(carga_de_dir, size)
		if temp_dir ~= "PS2 SYSTEM MENU" and doesFileExist(temp_dir) then
			OPCIONES.SALIDA_RETROLANCHER = temp_dir
			OPCIONES.SALIDA_DIR_ACTUALES, OPCIONES.SALIDA_DIR_ANTERIORES = {}, {}
			return true
		else
			OPCIONES.SALIDA_RETROLANCHER = "PS2 SYSTEM MENU"
			OPCIONES.SALIDA_DIR_ACTUALES, OPCIONES.SALIDA_DIR_ANTERIORES = {}, {}
			return false
		end
		System.closeFile(carga_de_dir)
	else
		guardar_directorio_elf()
		cargar_directorio_elf()
	end
end

--- Guardar el directorio de salida seleccionado. ---------------------------------------
function guardar_directorio_elf()
	local actual = System.currentDirectory()
	local dir = ("".. OPCIONES.SALIDA_RETROLANCHER .."")
	if doesFileExist(actual .."/System/Config/Path_file.cfg") then
		System.removeFile(actual .."/System/Config/Path_file.cfg")
	end
	local carga_de_dir = System.openFile("System/Config/Path_file.cfg", FCREATE)
	System.writeFile(carga_de_dir, dir, string.len(dir))
	System.closeFile(carga_de_dir)
end

--- Guardar opciones. -------------------------------------------------------------------
function guardar_opciones()
	local actual = System.currentDirectory()
	local config = ("".. OPCIONES.RGB_ON .." ".. OPCIONES.FONDO_RGB_ON .." ".. OPCIONES.FONDO_RGB_FIJO_ON .." ".. OPCIONES.R .." ".. OPCIONES.G .." ".. OPCIONES.B .." ".. CONTROL.ESTILO .." ".. SISTEMAS.MEGADRIVE_ON .." ".. SISTEMAS.MASTERSYSTEM_ON .." ".. SISTEMAS.GAMEGEAR_ON .." ".. SISTEMAS.FAMICOM_ON .." ".. SISTEMAS.GAMEBOY_ON .." ".. SISTEMAS.GAMEBOYCOLOR_ON .." ".. SISTEMAS.GAMEBOYADVANCE_ON .." ".. SISTEMAS.ATARI2600_ON .." ".. SISTEMAS.SEGASG1000_ON .." ".. SISTEMAS.NEOGEOPOCKET_ON .." ".. SISTEMAS.SUPERFAMICOM_ON .." ".. SISTEMAS.APPS_ON .." ".. SISTEMAS.PLAYSTATION_ON .." ".. OPCIONES.CAMBIO_FUENTE_ON .." ".. OPCIONES.CAMBIO_FONDO_ON .." ".. OPCIONES.GUI_LIMPIA_ON .." ".. OPCIONES.LIMITADOR_RAM_ON .." ".. OPCIONES.SALIDA_RETROLANCHER_ON .." ".. OPCIONES.APPS_MENU_FULL_PATH .." ".. OPCIONES.SOUND_ON .." ".. OPCIONES.SOUND_VOLUME .." ".. OPCIONES.SCREENSHOT_BACK_ON .." ".. OPCIONES.VIDEO_MODE .." ".. OPCIONES.VIBRATION_ON .." ".. SISTEMAS.PLAYSTATION2_ON .." ".. OPCIONES.DIR_EXTRAS_ON .." ".. CAMBIOS_EMUS.TRAS .." ".. OPCIONES.LIBERAR_LISTAS .." ".. OPCIONES.FONT_PIXEL_X .." ".. OPCIONES.FONT_PIXEL_Y .." ".. OPCIONES.FONT_SHADOW .." ".. OPCIONES.SCROLL_MIN .."                                                                                                    ")
	if doesFileExist(actual .."/System/Config/System.cfg") then
		local carga_de_opciones = System.openFile("System/Config/System.cfg", FRDWR)
		System.writeFile(carga_de_opciones, config, string.len(config))
		System.closeFile(carga_de_opciones)
	else
		if doesFileExist(actual .."/System/Respaldo/System.cfg") then
			System.copyFile(actual .."/System/Respaldo/System.cfg", "System/Config/System.cfg")
			guardar_opciones()
		else
			error("No found ".. actual .."/System/Respaldo/System.cfg")
		end
	end
end

--- Cargar último juego y sistema usado / Cargar opciones guardadas. --------------------
function cargar_config()
	local actual = System.currentDirectory()
	pantalla_reiniciar_conf(LISTAS.FONDO, 20, false, 21)
	-- Cargar opciones guardadas. -------------------------------------------------------
	if doesFileExist(actual .."/System/Config/System.cfg") then
		local carga_de_config2 = System.openFile(actual .."/System/Config/System.cfg", FREAD)
		System.seekFile(carga_de_config2, 0, SET)
		local size_config2 = System.sizeFile(carga_de_config2)
		local temp2 = System.readFile(carga_de_config2, size_config2)
		local lista_config2 = {}
		for linea in string.gmatch(temp2, "%d+") do
			table.insert(lista_config2, tonumber(linea))
		end
		if lista_config2 ~= nil and #lista_config2 == 39 then
			if lista_config2[1] <= 1 and lista_config2[1] >= 0 then
				OPCIONES.RGB_ON = lista_config2[1]
			end
			if lista_config2[2] <= 1 and lista_config2[2] >= 0 then
				OPCIONES.FONDO_RGB_ON = lista_config2[2]
			end
			if lista_config2[3] <= 1 and lista_config2[3] >= 0 then
				OPCIONES.FONDO_RGB_FIJO_ON = lista_config2[3]
			end
			if lista_config2[4] <= 128 and lista_config2[4] >= 0 then
				OPCIONES.R = lista_config2[4]
			end
			if lista_config2[5] <= 128 and lista_config2[5] >= 0 then
				OPCIONES.G = lista_config2[5]
			end
			if lista_config2[6] <= 128 and lista_config2[6] >= 0 then
				OPCIONES.B = lista_config2[6]
			end
			if lista_config2[7] >= 1 and lista_config2[7] <= 7 then
				CONTROL.ESTILO = lista_config2[7]
				if CONTROL.ESTILO == 1 then
					CONTROL.IMG_ANCHO = 358; CONTROL.IMG_X = 250; CONTROL.IMG_ALTO = 92; CONTROL.IMG_Y = 193;
					CONTROL.IMG_ANCHO_2 = 358; CONTROL.IMG_X_2 = 250; CONTROL.IMG_ALTO_2 = 92; CONTROL.IMG_Y_2 = 193;
					CONTROL.LISTA_ANCHO = 30; CONTROL.LISTA_X = 310; CONTROL.LISTA_ALTO = 90; CONTROL.LISTA_Y = 290;
					CONTROL.LOGO_ANCHO = 194; CONTROL.LOGO_X = 252; CONTROL.LOGO_ALTO = 5; CONTROL.LOGO_Y = 76;
					CONTROL.FLOW_ANCHO = 358; CONTROL.FLOW_X = 250; CONTROL.FLOW_ALTO = 92; CONTROL.FLOW_Y = 193;
					CONTROL.FLOW_ANCHO_2 = 358; CONTROL.FLOW_X_2 = 250; CONTROL.FLOW_ALTO_2 = 92; CONTROL.FLOW_Y_2 = 193;
					CONTROL.X_BUTTON_X = 388; CONTROL.Y_BUTTON_X = 353; CONTROL.X_BUTTON_T = 388; CONTROL.Y_BUTTON_T = 297;
					CONTROL.X_BUTTON_S = 388; CONTROL.Y_BUTTON_S = 325; CONTROL.X_BUTTON_L1 = 144; CONTROL.Y_BUTTON_L1 = 28;
					CONTROL.X_BUTTON_R1 = 464; CONTROL.Y_BUTTON_R1 = 28; CONTROL.X_BUTTON_R3 = 388; CONTROL.Y_BUTTON_R3 = 297;
					CONTROL.X_BUTTON_STA = 423; CONTROL.Y_BUTTON_STA = 410; CONTROL.X_BUTTON_SEL = 45; CONTROL.Y_BUTTON_SEL = 410;
					CONTROL.CUSTOM_ANIM = 1; CONTROL.ANIM_VELOCIDAD = 29;
					CONTROL.CUSTOM_LIST = true; CONTROL.CUSTOM_ART1 = true; CONTROL.CUSTOM_ART2 = false;
					CONTROL.CUSTOM_FLOW = false; CONTROL.CUSTOM_LOGO = true; CONTROL.CUSTOM_BUTTON_X = true;
					CONTROL.CUSTOM_BUTTON_T = true; CONTROL.CUSTOM_BUTTON_S = true; CONTROL.CUSTOM_BUTTON_L1 = true;
					CONTROL.CUSTOM_BUTTON_R1 = true; CONTROL.CUSTOM_BUTTON_R3 = true; CONTROL.CUSTOM_BUTTON_STA = true;
					CONTROL.CUSTOM_BUTTON_SEL = true;
				elseif CONTROL.ESTILO == 2 then
					CONTROL.IMG_ANCHO = 195; CONTROL.IMG_X = 250; CONTROL.IMG_ALTO = 110; CONTROL.IMG_Y = 193;
					CONTROL.IMG_ANCHO_2 = 195; CONTROL.IMG_X_2 = 250; CONTROL.IMG_ALTO_2 = 110; CONTROL.IMG_Y_2 = 193;
					CONTROL.LISTA_ANCHO = 167; CONTROL.LISTA_X = 306; CONTROL.LISTA_ALTO = 317; CONTROL.LISTA_Y = 50;
					CONTROL.LOGO_ANCHO = 194; CONTROL.LOGO_X = 252; CONTROL.LOGO_ALTO = 5; CONTROL.LOGO_Y = 76;
					CONTROL.FLOW_ANCHO = 15; CONTROL.FLOW_X = 160; CONTROL.FLOW_ALTO = 150; CONTROL.FLOW_Y = 103;
					CONTROL.FLOW_ANCHO_2 = 465; CONTROL.FLOW_X_2 = 160; CONTROL.FLOW_ALTO_2 = 150; CONTROL.FLOW_Y_2 = 103;
					CONTROL.X_BUTTON_X = 270; CONTROL.Y_BUTTON_X = 376; CONTROL.X_BUTTON_T = 40; CONTROL.Y_BUTTON_T = 376;
					CONTROL.X_BUTTON_S = 475; CONTROL.Y_BUTTON_S = 376; CONTROL.X_BUTTON_L1 = 144; CONTROL.Y_BUTTON_L1 = 28;
					CONTROL.X_BUTTON_R1 = 464; CONTROL.Y_BUTTON_R1 = 28; CONTROL.X_BUTTON_R3 = 260; CONTROL.Y_BUTTON_R3 = 376;
					CONTROL.X_BUTTON_STA = 423; CONTROL.Y_BUTTON_STA = 410; CONTROL.X_BUTTON_SEL = 45; CONTROL.Y_BUTTON_SEL = 410;
					CONTROL.CUSTOM_ANIM = 2; CONTROL.ANIM_VELOCIDAD = 29;
					CONTROL.CUSTOM_LIST = false; CONTROL.CUSTOM_ART1 = true; CONTROL.CUSTOM_ART2 = false;
					CONTROL.CUSTOM_FLOW = true; CONTROL.CUSTOM_LOGO = true; CONTROL.CUSTOM_BUTTON_X = true;
					CONTROL.CUSTOM_BUTTON_T = true; CONTROL.CUSTOM_BUTTON_S = true; CONTROL.CUSTOM_BUTTON_L1 = true;
					CONTROL.CUSTOM_BUTTON_R1 = true; CONTROL.CUSTOM_BUTTON_R3 = true; CONTROL.CUSTOM_BUTTON_STA = true;
					CONTROL.CUSTOM_BUTTON_SEL = true;
				elseif CONTROL.ESTILO == 3 then
					CONTROL.IMG_ANCHO = 48; CONTROL.IMG_X = 250; CONTROL.IMG_ALTO = 92; CONTROL.IMG_Y = 193;
					CONTROL.IMG_ANCHO_2 = 340; CONTROL.IMG_X_2 = 250; CONTROL.IMG_ALTO_2 = 92; CONTROL.IMG_Y_2 = 193;
					CONTROL.LISTA_ANCHO = 46; CONTROL.LISTA_X = 310; CONTROL.LISTA_ALTO = 300; CONTROL.LISTA_Y = 137;
					CONTROL.LOGO_ANCHO = 194; CONTROL.LOGO_X = 252; CONTROL.LOGO_ALTO = 5; CONTROL.LOGO_Y = 76;
					CONTROL.FLOW_ANCHO = 48; CONTROL.FLOW_X = 250; CONTROL.FLOW_ALTO = 92; CONTROL.FLOW_Y = 193;
					CONTROL.FLOW_ANCHO_2 = 48; CONTROL.FLOW_X_2 = 250; CONTROL.FLOW_ALTO_2 = 92; CONTROL.FLOW_Y_2 = 193;
					CONTROL.X_BUTTON_X = 399; CONTROL.Y_BUTTON_X = 353; CONTROL.X_BUTTON_T = 399; CONTROL.Y_BUTTON_T = 297;
					CONTROL.X_BUTTON_S = 399; CONTROL.Y_BUTTON_S = 325; CONTROL.X_BUTTON_L1 = 144; CONTROL.Y_BUTTON_L1 = 28;
					CONTROL.X_BUTTON_R1 = 464; CONTROL.Y_BUTTON_R1 = 28; CONTROL.X_BUTTON_R3 = 399; CONTROL.Y_BUTTON_R3 = 297;
					CONTROL.X_BUTTON_STA = 399; CONTROL.Y_BUTTON_STA = 407; CONTROL.X_BUTTON_SEL = 399; CONTROL.Y_BUTTON_SEL = 379;
					CONTROL.CUSTOM_ANIM = 2; CONTROL.ANIM_VELOCIDAD = 29;
					CONTROL.CUSTOM_LIST = true; CONTROL.CUSTOM_ART1 = true; CONTROL.CUSTOM_ART2 = true;
					CONTROL.CUSTOM_FLOW = false; CONTROL.CUSTOM_LOGO = true; CONTROL.CUSTOM_BUTTON_X = true;
					CONTROL.CUSTOM_BUTTON_T = true; CONTROL.CUSTOM_BUTTON_S = true; CONTROL.CUSTOM_BUTTON_L1 = true;
					CONTROL.CUSTOM_BUTTON_R1 = true; CONTROL.CUSTOM_BUTTON_R3 = true; CONTROL.CUSTOM_BUTTON_STA = true;
					CONTROL.CUSTOM_BUTTON_SEL = true;
				elseif CONTROL.ESTILO == 4 then
					CONTROL.IMG_ANCHO = 333; CONTROL.IMG_X = 295; CONTROL.IMG_ALTO = 92; CONTROL.IMG_Y = 228;
					CONTROL.IMG_ANCHO_2 = 333; CONTROL.IMG_X_2 = 295; CONTROL.IMG_ALTO_2 = 92; CONTROL.IMG_Y_2 = 228;
					CONTROL.LISTA_ANCHO = 10; CONTROL.LISTA_X = 310; CONTROL.LISTA_ALTO = 90; CONTROL.LISTA_Y = 290;
					CONTROL.LOGO_ANCHO = 194; CONTROL.LOGO_X = 252; CONTROL.LOGO_ALTO = 5; CONTROL.LOGO_Y = 76;
					CONTROL.FLOW_ANCHO = 333; CONTROL.FLOW_X = 295; CONTROL.FLOW_ALTO = 92; CONTROL.FLOW_Y = 228;
					CONTROL.FLOW_ANCHO_2 = 333; CONTROL.FLOW_X_2 = 295; CONTROL.FLOW_ALTO_2 = 92; CONTROL.FLOW_Y_2 = 228;
					CONTROL.X_BUTTON_X = 270; CONTROL.Y_BUTTON_X = 391; CONTROL.X_BUTTON_T = 40; CONTROL.Y_BUTTON_T = 391;
					CONTROL.X_BUTTON_S = 475; CONTROL.Y_BUTTON_S = 391; CONTROL.X_BUTTON_L1 = 144; CONTROL.Y_BUTTON_L1 = 28;
					CONTROL.X_BUTTON_R1 = 464; CONTROL.Y_BUTTON_R1 = 28; CONTROL.X_BUTTON_R3 = 260; CONTROL.Y_BUTTON_R3 = 391;
					CONTROL.X_BUTTON_STA = 423; CONTROL.Y_BUTTON_STA = 415; CONTROL.X_BUTTON_SEL = 45; CONTROL.Y_BUTTON_SEL = 415;
					CONTROL.CUSTOM_ANIM = 1; CONTROL.ANIM_VELOCIDAD = 29;
					CONTROL.CUSTOM_LIST = true; CONTROL.CUSTOM_ART1 = true; CONTROL.CUSTOM_ART2 = false;
					CONTROL.CUSTOM_FLOW = false; CONTROL.CUSTOM_LOGO = true; CONTROL.CUSTOM_BUTTON_X = true;
					CONTROL.CUSTOM_BUTTON_T = true; CONTROL.CUSTOM_BUTTON_S = true; CONTROL.CUSTOM_BUTTON_L1 = true;
					CONTROL.CUSTOM_BUTTON_R1 = true; CONTROL.CUSTOM_BUTTON_R3 = true; CONTROL.CUSTOM_BUTTON_STA = true;
					CONTROL.CUSTOM_BUTTON_SEL = true;
				elseif CONTROL.ESTILO == 5 then
					CONTROL.IMG_ANCHO = 12; CONTROL.IMG_X = 295; CONTROL.IMG_ALTO = 20; CONTROL.IMG_Y = 228;
					CONTROL.IMG_ANCHO_2 = 332; CONTROL.IMG_X_2 = 295; CONTROL.IMG_ALTO_2 = 20; CONTROL.IMG_Y_2 = 228;
					CONTROL.LISTA_ANCHO = 10; CONTROL.LISTA_X = 299; CONTROL.LISTA_ALTO = 263; CONTROL.LISTA_Y = 115;
					CONTROL.LOGO_ANCHO = 352; CONTROL.LOGO_X = 252; CONTROL.LOGO_ALTO = 280; CONTROL.LOGO_Y = 76;
					CONTROL.FLOW_ANCHO = 12; CONTROL.FLOW_X = 295; CONTROL.FLOW_ALTO = 20; CONTROL.FLOW_Y = 228;
					CONTROL.FLOW_ANCHO_2 = 12; CONTROL.FLOW_X_2 = 295; CONTROL.FLOW_ALTO_2 = 20; CONTROL.FLOW_Y_2 = 228;
					CONTROL.X_BUTTON_X = 270; CONTROL.Y_BUTTON_X = 391; CONTROL.X_BUTTON_T = 40; CONTROL.Y_BUTTON_T = 391;
					CONTROL.X_BUTTON_S = 475; CONTROL.Y_BUTTON_S = 391; CONTROL.X_BUTTON_L1 = 324; CONTROL.Y_BUTTON_L1 = 252;
					CONTROL.X_BUTTON_R1 = 602; CONTROL.Y_BUTTON_R1 = 252; CONTROL.X_BUTTON_R3 = 260; CONTROL.Y_BUTTON_R3 = 391;
					CONTROL.X_BUTTON_STA = 423; CONTROL.Y_BUTTON_STA = 415; CONTROL.X_BUTTON_SEL = 45; CONTROL.Y_BUTTON_SEL = 415;
					CONTROL.CUSTOM_ANIM = 2; CONTROL.ANIM_VELOCIDAD = 29;
					CONTROL.CUSTOM_LIST = true; CONTROL.CUSTOM_ART1 = true; CONTROL.CUSTOM_ART2 = true;
					CONTROL.CUSTOM_FLOW = false; CONTROL.CUSTOM_LOGO = true; CONTROL.CUSTOM_BUTTON_X = true;
					CONTROL.CUSTOM_BUTTON_T = true; CONTROL.CUSTOM_BUTTON_S = true; CONTROL.CUSTOM_BUTTON_L1 = true;
					CONTROL.CUSTOM_BUTTON_R1 = true; CONTROL.CUSTOM_BUTTON_R3 = true; CONTROL.CUSTOM_BUTTON_STA = true;
					CONTROL.CUSTOM_BUTTON_SEL = true;
				elseif CONTROL.ESTILO == 6 then
					CONTROL.IMG_ANCHO = 345; CONTROL.IMG_X = 270; CONTROL.IMG_ALTO = 10; CONTROL.IMG_Y = 208;
					CONTROL.IMG_ANCHO_2 = 345; CONTROL.IMG_X_2 = 270; CONTROL.IMG_ALTO_2 = 230; CONTROL.IMG_Y_2 = 208;
					CONTROL.LISTA_ANCHO = 22; CONTROL.LISTA_X = 310; CONTROL.LISTA_ALTO = 90; CONTROL.LISTA_Y = 290;
					CONTROL.LOGO_ANCHO = 52; CONTROL.LOGO_X = 252; CONTROL.LOGO_ALTO = 5; CONTROL.LOGO_Y = 76;
					CONTROL.FLOW_ANCHO = 345; CONTROL.FLOW_X = 270; CONTROL.FLOW_ALTO = 10; CONTROL.FLOW_Y = 208;
					CONTROL.FLOW_ANCHO_2 = 345; CONTROL.FLOW_X_2 = 270; CONTROL.FLOW_ALTO_2 = 10; CONTROL.FLOW_Y_2 = 208;
					CONTROL.X_BUTTON_X = 162; CONTROL.Y_BUTTON_X = 391; CONTROL.X_BUTTON_T = 52; CONTROL.Y_BUTTON_T = 391;
					CONTROL.X_BUTTON_S = 272; CONTROL.Y_BUTTON_S = 391; CONTROL.X_BUTTON_L1 = 17; CONTROL.Y_BUTTON_L1 = 60;
					CONTROL.X_BUTTON_R1 = 305; CONTROL.Y_BUTTON_R1 = 60; CONTROL.X_BUTTON_R3 = 52; CONTROL.Y_BUTTON_R3 = 391;
					CONTROL.X_BUTTON_STA = 246; CONTROL.Y_BUTTON_STA = 416; CONTROL.X_BUTTON_SEL = 57; CONTROL.Y_BUTTON_SEL = 416;
					CONTROL.CUSTOM_ANIM = 1; CONTROL.ANIM_VELOCIDAD = 29;
					CONTROL.CUSTOM_LIST = true; CONTROL.CUSTOM_ART1 = true; CONTROL.CUSTOM_ART2 = true;
					CONTROL.CUSTOM_FLOW = false; CONTROL.CUSTOM_LOGO = true; CONTROL.CUSTOM_BUTTON_X = true;
					CONTROL.CUSTOM_BUTTON_T = true; CONTROL.CUSTOM_BUTTON_S = true; CONTROL.CUSTOM_BUTTON_L1 = true;
					CONTROL.CUSTOM_BUTTON_R1 = true; CONTROL.CUSTOM_BUTTON_R3 = true; CONTROL.CUSTOM_BUTTON_STA = true;
					CONTROL.CUSTOM_BUTTON_SEL = true;
				elseif CONTROL.ESTILO == 7 then
					cargar_style(false)
				end
			end
			pantalla_reiniciar_conf(LISTAS.FONDO, 30, false, 21)
			if lista_config2[8] <= 1 and lista_config2[8] >= 0 then
				SISTEMAS.MEGADRIVE_ON = lista_config2[8]
			end
			if lista_config2[9] <= 1 and lista_config2[9] >= 0 then
				SISTEMAS.MASTERSYSTEM_ON = lista_config2[9]
			end
			if lista_config2[10] <= 1 and lista_config2[10] >= 0 then
				SISTEMAS.GAMEGEAR_ON = lista_config2[10]
			end
			if lista_config2[11] <= 1 and lista_config2[11] >= 0 then
				SISTEMAS.FAMICOM_ON = lista_config2[11]
			end
			if lista_config2[12] <= 1 and lista_config2[12] >= 0 then
				SISTEMAS.GAMEBOY_ON = lista_config2[12]
			end
			if lista_config2[13] <= 1 and lista_config2[13] >= 0 then
				SISTEMAS.GAMEBOYCOLOR_ON = lista_config2[13]
			end
			if lista_config2[14] <= 1 and lista_config2[14] >= 0 then
				SISTEMAS.GAMEBOYADVANCE_ON = lista_config2[14]
			end
			if lista_config2[15] <= 1 and lista_config2[15] >= 0 then
				SISTEMAS.ATARI2600_ON = lista_config2[15]
			end
			if lista_config2[16] <= 1 and lista_config2[16] >= 0 then
				SISTEMAS.SEGASG1000_ON = lista_config2[16]
			end
			if lista_config2[17] <= 1 and lista_config2[17] >= 0 then
				SISTEMAS.NEOGEOPOCKET_ON = lista_config2[17]
			end
			if lista_config2[18] <= 1 and lista_config2[18] >= 0 then
				SISTEMAS.SUPERFAMICOM_ON = lista_config2[18]
			end
			if lista_config2[19] <= 1 and lista_config2[19] >= 0 then
				SISTEMAS.APPS_ON = lista_config2[19]
			end
			if lista_config2[20] <= 1 and lista_config2[20] >= 0 then
				SISTEMAS.PLAYSTATION_ON = lista_config2[20]
			end
			if lista_config2[21] ~= 1 and lista_config2[21] >= 2 then
				buscar_fuentes()
				if lista_config2[21] <= #OPCIONES.FUENTES_ENCONTRADAS then
					Font.ftUnload(CONTROL.fontARCA)
					Font.ftUnload(CONTROL.fontABC)
					CONTROL.fontARCA = Font.ftLoad(OPCIONES.FUENTES_ENCONTRADAS[lista_config2[21]])
					CONTROL.fontABC = Font.ftLoad(OPCIONES.FUENTES_ENCONTRADAS[lista_config2[21]])
					OPCIONES.CAMBIO_FUENTE_ON = lista_config2[21]
				else
					OPCIONES.CAMBIO_FUENTE_ON = 1
					OPCIONES.FUENTES_ENCONTRADAS = {}
				end
			end
			if lista_config2[22] ~= 1 and lista_config2[22] >= 2 then
				buscar_fondos()
				if lista_config2[22] <= #OPCIONES.FONDO_ENCONTRADOS then
					Graphics.freeImage(LISTAS.FONDO)
					LISTAS.FONDO = Graphics.loadImage(OPCIONES.FONDO_ENCONTRADOS[lista_config2[22]])
					OPCIONES.CAMBIO_FONDO_ON = lista_config2[22]
				else
					OPCIONES.CAMBIO_FONDO_ON = 1
					OPCIONES.FONDO_ENCONTRADOS = {}
				end
			end
			if lista_config2[23] <= 1 and lista_config2[23] >= 0 then
				OPCIONES.GUI_LIMPIA_ON = lista_config2[23]
			end
			if lista_config2[24] <= 1 and lista_config2[24] >= 0 then
				OPCIONES.LIMITADOR_RAM_ON = lista_config2[24]
			end
			if lista_config2[25] <= 3 and lista_config2[25] >= 0 then
				if lista_config2[25] >= 1 and cargar_directorio_elf() == true then
					OPCIONES.SALIDA_RETROLANCHER_ON = lista_config2[25]
				else
					OPCIONES.SALIDA_RETROLANCHER_ON = 0
				end
			end
			if lista_config2[26] <= 1 and lista_config2[26] >= 0 then
				OPCIONES.APPS_MENU_FULL_PATH = lista_config2[26]
			end
			if lista_config2[27] <= 1 and lista_config2[27] >= 0 then
				OPCIONES.SOUND_ON = lista_config2[27]
			end
			if lista_config2[28] <= 100 and lista_config2[28] >= 0 then
				OPCIONES.SOUND_VOLUME = lista_config2[28]
				set_volume()
			end
			if lista_config2[29] <= 1 and lista_config2[29] >= 0 then
				OPCIONES.SCREENSHOT_BACK_ON = lista_config2[29]
			end
			if lista_config2[30] <= 1 and lista_config2[30] >= 0 then
				OPCIONES.VIDEO_MODE = lista_config2[30]
				if OPCIONES.VIDEO_MODE == 0 and doesFileExist("System/Respaldo/PAL") then
					Screen.setMode(NTSC, 640, 448, CT24, INTERLACED, FIELD)
					System.rename("System/Respaldo/PAL", "System/Respaldo/NTSC")
				elseif OPCIONES.VIDEO_MODE == 1 and doesFileExist("System/Respaldo/NTSC") then
					Screen.setMode(PAL, 640, 512, CT24, INTERLACED, FIELD)
					System.rename("System/Respaldo/NTSC", "System/Respaldo/PAL")
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
			end
			if lista_config2[31] <= 1 and lista_config2[31] >= 0 then
				OPCIONES.VIBRATION_ON = lista_config2[31]
			end
			if lista_config2[32] <= 1 and lista_config2[32] >= 0 then
				SISTEMAS.PLAYSTATION2_ON = lista_config2[32]
			end
			if lista_config2[33] <= 1 and lista_config2[33] >= 0 then
				OPCIONES.DIR_EXTRAS_ON = lista_config2[33]
			end
			if lista_config2[34] <= 128 and lista_config2[34] >= 0 then
				CAMBIOS_EMUS.TRAS = lista_config2[34]
			end
			if lista_config2[35] <= 1 and lista_config2[35] >= 0 then
				OPCIONES.LIBERAR_LISTAS = lista_config2[35]
			end
			if lista_config2[36] <= 32 and lista_config2[36] >= 1 then
				OPCIONES.FONT_PIXEL_X = lista_config2[36]
			end
			if lista_config2[37] <= 32 and lista_config2[37] >= 1 then
				OPCIONES.FONT_PIXEL_Y = lista_config2[37]
			end
			if lista_config2[38] <= 32 and lista_config2[38] >= 0 then
				OPCIONES.FONT_SHADOW = lista_config2[38]
			end
			if lista_config2[39] <= 100 and lista_config2[39] >= 10 then
				OPCIONES.SCROLL_MIN = lista_config2[39]
			end
		else
			OPCIONES.RGB_ON = 1
			OPCIONES.FONDO_RGB_ON = 1
			OPCIONES.FONDO_RGB_FIJO_ON = 0
			OPCIONES.R = 0
			OPCIONES.G = 80
			OPCIONES.B = 120
			CONTROL.ESTILO = 1
			SISTEMAS.MEGADRIVE_ON = 1
			SISTEMAS.MASTERSYSTEM_ON = 1
			SISTEMAS.GAMEGEAR_ON = 1
			SISTEMAS.FAMICOM_ON = 1
			SISTEMAS.GAMEBOY_ON = 1
			SISTEMAS.GAMEBOYCOLOR_ON = 1
			SISTEMAS.GAMEBOYADVANCE_ON = 1
			SISTEMAS.ATARI2600_ON = 1
			SISTEMAS.SEGASG1000_ON = 1
			SISTEMAS.NEOGEOPOCKET_ON = 1
			SISTEMAS.SUPERFAMICOM_ON = 1
			SISTEMAS.APPS_ON = 1
			SISTEMAS.PLAYSTATION_ON = 1
			OPCIONES.CAMBIO_FUENTE_ON = 1
			OPCIONES.CAMBIO_FONDO_ON = 1
			OPCIONES.GUI_LIMPIA_ON = 0
			OPCIONES.LIMITADOR_RAM_ON = 1
			OPCIONES.SALIDA_RETROLANCHER_ON = 0
			OPCIONES.APPS_MENU_FULL_PATH = 0
			OPCIONES.SOUND_ON = 0
			OPCIONES.SOUND_VOLUME = 65
			set_volume()
			OPCIONES.SCREENSHOT_BACK_ON = 0
			if doesFileExist("System/Respaldo/PAL") then
				OPCIONES.VIDEO_MODE = 1
			else
				OPCIONES.VIDEO_MODE = 0
			end
			OPCIONES.VIBRATION_ON = 0
			SISTEMAS.PLAYSTATION2_ON = 0
			OPCIONES.DIR_EXTRAS_ON = 1
			CAMBIOS_EMUS.TRAS = 74
			OPCIONES.LIBERAR_LISTAS = 0
			OPCIONES.FONT_PIXEL_X = 16
			OPCIONES.FONT_PIXEL_Y = 16
			OPCIONES.FONT_SHADOW = 5
			OPCIONES.SCROLL_MIN = 24
		end
		System.closeFile(carga_de_config2)
	else
		OPCIONES.RGB_ON = 1
		OPCIONES.FONDO_RGB_ON = 1
		OPCIONES.FONDO_RGB_FIJO_ON = 0
		OPCIONES.R = 0
		OPCIONES.G = 80
		OPCIONES.B = 120
		CONTROL.ESTILO = 1
		SISTEMAS.MEGADRIVE_ON = 1
		SISTEMAS.MASTERSYSTEM_ON = 1
		SISTEMAS.GAMEGEAR_ON = 1
		SISTEMAS.FAMICOM_ON = 1
		SISTEMAS.GAMEBOY_ON = 1
		SISTEMAS.GAMEBOYCOLOR_ON = 1
		SISTEMAS.GAMEBOYADVANCE_ON = 1
		SISTEMAS.ATARI2600_ON = 1
		SISTEMAS.SEGASG1000_ON = 1
		SISTEMAS.NEOGEOPOCKET_ON = 1
		SISTEMAS.SUPERFAMICOM_ON = 1
		SISTEMAS.APPS_ON = 1
		SISTEMAS.PLAYSTATION_ON = 1
		OPCIONES.CAMBIO_FUENTE_ON = 1
		OPCIONES.CAMBIO_FONDO_ON = 1
		OPCIONES.GUI_LIMPIA_ON = 0
		OPCIONES.LIMITADOR_RAM_ON = 1
		OPCIONES.SALIDA_RETROLANCHER_ON = 0
		OPCIONES.APPS_MENU_FULL_PATH = 0
		OPCIONES.SOUND_ON = 0
		OPCIONES.SOUND_VOLUME = 65
		set_volume()
		OPCIONES.SCREENSHOT_BACK_ON = 0
		if doesFileExist("System/Respaldo/PAL") then
			OPCIONES.VIDEO_MODE = 1
		else
			OPCIONES.VIDEO_MODE = 0
		end
		OPCIONES.VIBRATION_ON = 0
		SISTEMAS.PLAYSTATION2_ON = 0
		OPCIONES.DIR_EXTRAS_ON = 1
		CAMBIOS_EMUS.TRAS = 74
		OPCIONES.LIBERAR_LISTAS = 0
		OPCIONES.FONT_PIXEL_X = 16
		OPCIONES.FONT_PIXEL_Y = 16
		OPCIONES.FONT_SHADOW = 5
		OPCIONES.SCROLL_MIN = 24
		guardar_opciones()
	end
	pantalla_reiniciar_conf(LISTAS.FONDO, 40, false, 21)
	recargar_todas()
	pantalla_reiniciar_conf(LISTAS.FONDO, 60, false, 21)

	-- Cargar último juego y sistema usado. ---------------------------------------------
	if doesFileExist(actual .."/System/Config/Config.cfg") then
		local carga_de_config = System.openFile(actual .."/System/Config/Config.cfg", FREAD)
		System.seekFile(carga_de_config, 0, SET)
		local size_config = System.sizeFile(carga_de_config)
		local temp = System.readFile(carga_de_config, size_config)
		local lista_config = {}
		for linea in string.gmatch(temp, "%d+") do
			table.insert(lista_config, tonumber(linea))
		end
		if lista_config ~= nil and #lista_config == 16 then
			LISTAS.IDENTIDAD = lista_config[1]
			if OPCIONES.LIBERAR_LISTAS == 1 then
				PRE_CARGADAS = {{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}}
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
			LAST_MOVE = {lista_config[3], lista_config[4], lista_config[5], lista_config[6], lista_config[7], lista_config[8], lista_config[9], lista_config[10], lista_config[11], lista_config[12], lista_config[13], lista_config[14], lista_config[15], lista_config[16]}
		else
			LISTAS.IDENTIDAD = 1
			if OPCIONES.LIBERAR_LISTAS == 1 then
				PRE_CARGADAS = {{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}}
				recargar_una(LISTAS.IDENTIDAD)
			end
			LISTAS.ROMS = nil
			LISTAS.ROMS = PRE_CARGADAS[LISTAS.IDENTIDAD]
			LISTAS.INDICE = 1
			indices_extras()
			LAST_MOVE = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
		end
		System.closeFile(carga_de_config)
	else
		LISTAS.IDENTIDAD = 1
		if OPCIONES.LIBERAR_LISTAS == 1 then
			PRE_CARGADAS = {{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}}
			recargar_una(LISTAS.IDENTIDAD)
		end
		LISTAS.ROMS = nil
		LISTAS.ROMS = PRE_CARGADAS[LISTAS.IDENTIDAD]
		LISTAS.INDICE = 1
		indices_extras()
		LAST_MOVE = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
		guardar()
	end
	pantalla_reiniciar_conf(LISTAS.FONDO, 74, false, 21)
	desactivados(nil)
	indices_extras()
	color_emu(LISTAS.IDENTIDAD)
	Font.ftSetPixelSize(CONTROL.fontARCA, OPCIONES.FONT_PIXEL_X, OPCIONES.FONT_PIXEL_Y)
	Font.ftSetPixelSize(CONTROL.fontABC, 70, 70)
	animaciones(nil)
end

--- Elimina "Save states" y "Save RAM" (SRM) de juegos creados por Retroarch. -----------
function limpiar_retroarch(emulador)
	local actual = System.currentDirectory()
	local limpiar = System.listDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch/savestates")
	if limpiar ~= nil then
		for contador = 1, #limpiar do
			System.removeFile(actual .."/System/RetroarchPS2/".. emulador .."/retroarch/savestates/".. limpiar[contador].name)
		end
	end
	local limpiar2 = System.listDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch/savefiles")
	if limpiar2 ~= nil then
		for contador = 1, #limpiar2 do
			System.removeFile(actual .."/System/RetroarchPS2/".. emulador .."/retroarch/savefiles/".. limpiar2[contador].name)
		end
	end

	-- Elimina "Save states" y "Save RAM" (SRM) de juegos creados por TempGBA. ----------
	if emulador == "Nintendo Game Boy Advance" then
		local limpiar3 = System.listDirectory(actual .."/System/RetroarchPS2/".. emulador .."/TempGBA")
		if limpiar3 ~= nil then
			for contador = 1, #limpiar3 do
				if limpiar3[contador].directory == false and (string.lower(string.sub(limpiar3[contador].name, -4)) == ".sav" or string.match(string.sub(limpiar3[contador].name, -4), ".s%d%d")) then
					System.removeFile(actual .."/System/RetroarchPS2/".. emulador .."/TempGBA/".. limpiar3[contador].name)
				end
			end
		end
	end
end

--- Crea los directorios faltantes. -----------------------------------------------------
function directorios_faltantes(emulador, core)
	local actual = System.currentDirectory()
	if emulador == "Nintendo Game Boy" or emulador == "Nintendo Game Boy Color" then
		if System.listDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch") == nil then
			System.createDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch")
		end
		if System.listDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch/config") == nil then
			System.createDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch/config")
		end
		if System.listDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch/config/".. core) == nil then
			System.createDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch/config/".. core)
		end
		if System.listDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch/config/remaps") == nil then
			System.createDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch/config/remaps")
		end
		if System.listDirectory(actual .."/System/RetroarchPS2/".. emulador.. "/retroarch/config/remaps/".. core) == nil then
			System.createDirectory(actual .."/System/RetroarchPS2/".. emulador.. "/retroarch/config/remaps/".. core)
		end
	elseif emulador == "Nintendo Famicom" then
		if System.listDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch") == nil then
			System.createDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch")
		end
		if System.listDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch/config") == nil then
			System.createDirectory(actual .."/System/RetroarchPS2/".. emulador .. "/retroarch/config")
		end
		if System.listDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch/remaps") == nil then
			System.createDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch/remaps")
		end
		if System.listDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch/config/".. core) == nil then
			System.createDirectory(actual .."/System/RetroarchPS2/".. emulador.. "/retroarch/config/".. core)
		end
		if System.listDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch/remaps/".. core) == nil then
			System.createDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch/remaps/".. core)
		end
	else
		if System.listDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch") == nil then
			System.createDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch")
		end
		if System.listDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch/config") == nil then
			System.createDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch/config")
		end
		if System.listDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch/config/".. core) == nil then
			System.createDirectory(actual .."/System/RetroarchPS2/".. emulador .."/retroarch/config/".. core)
		end
	end
end

--- Reinicia todas las configuraciones. -------------------------------------------------
function reiniciar_conf(limpiar, indi_rest)
	local actual = System.currentDirectory()
	local FONDO_LOAD = Graphics.loadImage("System/Medios/Default/FONDO.png")
	pantalla_reiniciar_conf(FONDO_LOAD, 0, limpiar, indi_rest)
	local dir_mode_video = "RetroarchPS2"
	if OPCIONES.VIDEO_MODE == 0 then
		dir_mode_video = "RetroarchPS2"
	else
		dir_mode_video = "RetroarchPS2_PAL"
	end
	if indi_rest == 0 or indi_rest == 20 then
		if OPCIONES.VIDEO_MODE == 0 and doesFileExist("System/Respaldo/PAL")then
			System.rename("System/Respaldo/PAL", "System/Respaldo/NTSC")
		elseif OPCIONES.VIDEO_MODE == 1 and doesFileExist("System/Respaldo/NTSC")then
			System.rename("System/Respaldo/NTSC", "System/Respaldo/PAL")
		end
	end
	if indi_rest == 0 then
		OPCIONES.RGB_ON = 1
		OPCIONES.FONDO_RGB_ON = 1
		OPCIONES.FONDO_RGB_FIJO_ON = 0
		OPCIONES.R = 0
		OPCIONES.G = 80
		OPCIONES.B = 120
		CONTROL.ESTILO = 1
		SISTEMAS.MEGADRIVE_ON = 1
		SISTEMAS.MASTERSYSTEM_ON = 1
		SISTEMAS.GAMEGEAR_ON = 1
		SISTEMAS.FAMICOM_ON = 1
		SISTEMAS.GAMEBOY_ON = 1
		SISTEMAS.GAMEBOYCOLOR_ON = 1
		SISTEMAS.GAMEBOYADVANCE_ON = 1
		SISTEMAS.ATARI2600_ON = 1
		SISTEMAS.SEGASG1000_ON = 1
		SISTEMAS.NEOGEOPOCKET_ON = 1
		SISTEMAS.SUPERFAMICOM_ON = 0
		SISTEMAS.APPS_ON = 0
		SISTEMAS.PLAYSTATION_ON = 1
		Font.ftUnload(CONTROL.fontARCA)
		Font.ftUnload(CONTROL.fontABC)
		CONTROL.fontARCA = Font.ftLoad("System/Medios/Font/PublicPixel.ttf")
		CONTROL.fontABC = Font.ftLoad("System/Medios/Font/PublicPixel.ttf")
		OPCIONES.CAMBIO_FUENTE_ON = 1
		Graphics.freeImage(LISTAS.FONDO)
		LISTAS.FONDO = Graphics.loadImage("System/Medios/Default/FONDO.png")
		OPCIONES.CAMBIO_FONDO_ON = 1
		OPCIONES.GUI_LIMPIA_ON = 0
		OPCIONES.LIMITADOR_RAM_ON = 1
		OPCIONES.SALIDA_RETROLANCHER_ON = 0
		OPCIONES.SALIDA_RETROLANCHER = "PS2 SYSTEM MENU"
		OPCIONES.SALIDA_DIR_ACTUALES = {}
		OPCIONES.SALIDA_DIR_ANTERIORES = {}
		OPCIONES.APPS_MENU_FULL_PATH = 0
		OPCIONES.SOUND_ON = 0
		OPCIONES.SOUND_VOLUME = 65
		set_volume()
		OPCIONES.SCREENSHOT_BACK_ON = 0
		OPCIONES.VIBRATION_ON = 0
		SISTEMAS.PLAYSTATION2_ON = 0
		OPCIONES.DIR_EXTRAS_ON = 1
		CAMBIOS_EMUS.TRAS = 74
		OPCIONES.LIBERAR_LISTAS = 0
		OPCIONES.FONT_PIXEL_X = 16
		OPCIONES.FONT_PIXEL_Y = 16
		OPCIONES.FONT_SHADOW = 5
		OPCIONES.SCROLL_MIN = 24
		Font.ftSetPixelSize(CONTROL.fontARCA, OPCIONES.FONT_PIXEL_X, OPCIONES.FONT_PIXEL_Y)
		Font.ftSetPixelSize(CONTROL.fontABC, 70, 70)
		if doesFileExist("System/Medios/Sound/Background/music.adp") then
			System.rename("System/Medios/Sound/Background/music.adp", "System/Medios/Sound/Background/music0.adp")
			Sound.freeADPCM(S_MUSICA)
			S_MUSICA = nil
		end
	end

	-- Limpiar partidas guardadas por Retroarch. ----------------------------------------
	if limpiar == true then
		pantalla_reiniciar_conf(FONDO_LOAD, 5, true, indi_rest)
		if indi_rest == 0 or indi_rest == 1 then
			limpiar_retroarch("Atari 2600")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 10, true, indi_rest)
		if indi_rest == 0 or indi_rest == 2 then
			limpiar_retroarch("Neo Geo Pocket")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 15, true, indi_rest)
		if indi_rest == 0 or indi_rest == 3 then
			limpiar_retroarch("Nintendo Famicom")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 20, true, indi_rest)
		if indi_rest == 0 or indi_rest == 4 then
			limpiar_retroarch("Nintendo Game Boy")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 25, true, indi_rest)
		if indi_rest == 0 or indi_rest == 5 then
			limpiar_retroarch("Nintendo Game Boy Advance")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 30, true, indi_rest)
		if indi_rest == 0 or indi_rest == 6 then
			limpiar_retroarch("Nintendo Game Boy Color")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 35, true, indi_rest)
		if indi_rest == 0 or indi_rest == 7 then
			limpiar_retroarch("Nintendo Super Famicom")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 40, true, indi_rest)
		if indi_rest == 0 or indi_rest == 8 then
			limpiar_retroarch("Sega Game Gear")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 45, true, indi_rest)
		if indi_rest == 0 or indi_rest == 9 then
			limpiar_retroarch("Sega Master System")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 50, true, indi_rest)
		if indi_rest == 0 or indi_rest == 10 then
			limpiar_retroarch("Sega Megadrive")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 75, true, indi_rest)
		if indi_rest == 0 or indi_rest == 11 then
			limpiar_retroarch("Sega SG-1000")
		end
	end

	-- Restaura Atari 2600. -------------------------------------------------------------
	if indi_rest == 0 or indi_rest == 20 or indi_rest == 1 then
		directorios_faltantes("Atari 2600", "Stella 2014")
		pantalla_reiniciar_conf(FONDO_LOAD, 3, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Atari 2600/retroarch/retroarch.cfg") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Atari 2600/retroarch/retroarch.cfg", actual .."/System/RetroarchPS2/Atari 2600/retroarch/retroarch.cfg")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 6, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Atari 2600/retroarch/config/Stella 2014/Stella 2014.opt") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Atari 2600/retroarch/config/Stella 2014/Stella 2014.opt", actual .."/System/RetroarchPS2/Atari 2600/retroarch/config/Stella 2014/Stella 2014.opt")
		end
	end

	-- Restaura Neo Geo Pocket. ---------------------------------------------------------
	if indi_rest == 0 or indi_rest == 20 or indi_rest == 2 then
		directorios_faltantes("Neo Geo Pocket", "RACE")
		pantalla_reiniciar_conf(FONDO_LOAD, 9, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Neo Geo Pocket/retroarch/retroarch.cfg") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Neo Geo Pocket/retroarch/retroarch.cfg", actual .."/System/RetroarchPS2/Neo Geo Pocket/retroarch/retroarch.cfg")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 12, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Neo Geo Pocket/retroarch/config/RACE/RACE.opt") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Neo Geo Pocket/retroarch/config/RACE/RACE.opt", actual .."/System/RetroarchPS2/Neo Geo Pocket/retroarch/config/RACE/RACE.opt")
		end
	end

	-- Restaura Nintendo Famicom. -------------------------------------------------------
	if indi_rest == 0 or indi_rest == 20 or indi_rest == 3 then
		directorios_faltantes("Nintendo Famicom", "FCEUmm")
		directorios_faltantes("Nintendo Famicom", "QuickNES")
		pantalla_reiniciar_conf(FONDO_LOAD, 15, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Famicom/retroarch/retroarch.cfg") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Famicom/retroarch/retroarch.cfg", actual .."/System/RetroarchPS2/Nintendo Famicom/retroarch/retroarch.cfg")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 17, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Famicom/retroarch/remaps/FCEUmm/FCEUmm.rmp") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Famicom/retroarch/remaps/FCEUmm/FCEUmm.rmp", actual .."/System/RetroarchPS2/Nintendo Famicom/retroarch/remaps/FCEUmm/FCEUmm.rmp")
		end
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Famicom/retroarch/remaps/QuickNES/QuickNES.rmp") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Famicom/retroarch/remaps/QuickNES/QuickNES.rmp", actual .."/System/RetroarchPS2/Nintendo Famicom/retroarch/remaps/QuickNES/QuickNES.rmp")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 19, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Famicom/retroarch/config/FCEUmm/FCEUmm.opt") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Famicom/retroarch/config/FCEUmm/FCEUmm.opt", actual .."/System/RetroarchPS2/Nintendo Famicom/retroarch/config/FCEUmm/FCEUmm.opt")
		end
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Famicom/retroarch/config/QuickNES/QuickNES.opt") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Famicom/retroarch/config/QuickNES/QuickNES.opt", actual .."/System/RetroarchPS2/Nintendo Famicom/retroarch/config/QuickNES/QuickNES.opt")
		end
	end

	-- Restaura Nintendo Game Boy. ------------------------------------------------------
	if indi_rest == 0 or indi_rest == 20 or indi_rest == 4 then
		directorios_faltantes("Nintendo Game Boy", "Gambatte")
		directorios_faltantes("Nintendo Game Boy", "TGB Dual")
		pantalla_reiniciar_conf(FONDO_LOAD, 22, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy/retroarch/retroarch.cfg") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy/retroarch/retroarch.cfg", actual .."/System/RetroarchPS2/Nintendo Game Boy/retroarch/retroarch.cfg")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 24, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy/retroarch/config/remaps/Gambatte/Gambatte.rmp") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy/retroarch/config/remaps/Gambatte/Gambatte.rmp", actual .."/System/RetroarchPS2/Nintendo Game Boy/retroarch/config/remaps/Gambatte/Gambatte.rmp")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 26, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy/retroarch/config/Gambatte/Gambatte.opt") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy/retroarch/config/Gambatte/Gambatte.opt", actual .."/System/RetroarchPS2/Nintendo Game Boy/retroarch/config/Gambatte/Gambatte.opt")
		end
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy/retroarch/config/TGB Dual/TGB Dual.opt") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy/retroarch/config/TGB Dual/TGB Dual.opt", actual .."/System/RetroarchPS2/Nintendo Game Boy/retroarch/config/TGB Dual/TGB Dual.opt")
		end
	end

	-- Restaura Nintendo Game Boy Advance. ----------------------------------------------
	if indi_rest == 0 or indi_rest == 20 or indi_rest == 5 then
		directorios_faltantes("Nintendo Game Boy Advance", "gpSP")
		pantalla_reiniciar_conf(FONDO_LOAD, 29, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy Advance/retroarch/retroarch.cfg") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy Advance/retroarch/retroarch.cfg", actual .."/System/RetroarchPS2/Nintendo Game Boy Advance/retroarch/retroarch.cfg")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 32, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy Advance/retroarch/config/gpSP/gpSP.opt") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy Advance/retroarch/config/gpSP/gpSP.opt", actual .."/System/RetroarchPS2/Nintendo Game Boy Advance/retroarch/config/gpSP/gpSP.opt")
		end
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy Advance/TempGBA/global_config.cfg") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy Advance/TempGBA/global_config.cfg", actual .."/System/RetroarchPS2/Nintendo Game Boy Advance/TempGBA/global_config.cfg")
		end
	end

	-- Restaura Nintendo Game Boy Color. ------------------------------------------------
	if indi_rest == 0 or indi_rest == 20 or indi_rest == 6 then
		directorios_faltantes("Nintendo Game Boy Color", "Gambatte")
		directorios_faltantes("Nintendo Game Boy Color", "TGB Dual")
		pantalla_reiniciar_conf(FONDO_LOAD, 35, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy Color/retroarch/retroarch.cfg") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy Color/retroarch/retroarch.cfg", actual .."/System/RetroarchPS2/Nintendo Game Boy Color/retroarch/retroarch.cfg")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 37, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy Color/retroarch/config/remaps/Gambatte/Gambatte.rmp") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy Color/retroarch/config/remaps/Gambatte/Gambatte.rmp", actual .."/System/RetroarchPS2/Nintendo Game Boy Color/retroarch/config/remaps/Gambatte/Gambatte.rmp")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 39, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy Color/retroarch/config/Gambatte/Gambatte.opt") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy Color/retroarch/config/Gambatte/Gambatte.opt", actual .."/System/RetroarchPS2/Nintendo Game Boy Color/retroarch/config/Gambatte/Gambatte.opt")
		end
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy Color/retroarch/config/TGB Dual/TGB Dual.opt") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Game Boy Color/retroarch/config/TGB Dual/TGB Dual.opt", actual .."/System/RetroarchPS2/Nintendo Game Boy Color/retroarch/config/TGB Dual/TGB Dual.opt")
		end
	end

	-- Restaura Nintendo Super Famicom. -------------------------------------------------
	if indi_rest == 0 or indi_rest == 20 or indi_rest == 7 then
		directorios_faltantes("Nintendo Super Famicom", "Snes9x 2002")
		pantalla_reiniciar_conf(FONDO_LOAD, 42, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Super Famicom/retroarch/retroarch.cfg") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Super Famicom/retroarch/retroarch.cfg", actual .."/System/RetroarchPS2/Nintendo Super Famicom/retroarch/retroarch.cfg")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 45, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Super Famicom/retroarch/config/Snes9x 2002/Snes9x 2002.opt") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Nintendo Super Famicom/retroarch/config/Snes9x 2002/Snes9x 2002.opt", actual .."/System/RetroarchPS2/Nintendo Super Famicom/retroarch/config/Snes9x 2002/Snes9x 2002.opt")
		end
	end

	-- Restaura Sega Game Gear. ---------------------------------------------------------
	if indi_rest == 0 or indi_rest == 20 or indi_rest == 8 then
		directorios_faltantes("Sega Game Gear", "PicoDrive")
		pantalla_reiniciar_conf(FONDO_LOAD, 48, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Sega Game Gear/retroarch/retroarch.cfg") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Sega Game Gear/retroarch/retroarch.cfg", actual .."/System/RetroarchPS2/Sega Game Gear/retroarch/retroarch.cfg")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 51, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Sega Game Gear/retroarch/config/PicoDrive/PicoDrive.opt") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Sega Game Gear/retroarch/config/PicoDrive/PicoDrive.opt", actual .."/System/RetroarchPS2/Sega Game Gear/retroarch/config/PicoDrive/PicoDrive.opt")
		end
	end

	-- Restaura Sega Master System. -----------------------------------------------------
	if indi_rest == 0 or indi_rest == 20 or indi_rest == 9 then
		directorios_faltantes("Sega Master System", "PicoDrive")
		pantalla_reiniciar_conf(FONDO_LOAD, 54, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Sega Master System/retroarch/retroarch.cfg") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Sega Master System/retroarch/retroarch.cfg", actual .."/System/RetroarchPS2/Sega Master System/retroarch/retroarch.cfg")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 57, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Sega Master System/retroarch/config/PicoDrive/PicoDrive.opt") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Sega Master System/retroarch/config/PicoDrive/PicoDrive.opt", actual .."/System/RetroarchPS2/Sega Master System/retroarch/config/PicoDrive/PicoDrive.opt")
		end
	end

	-- Restaura Sega Megadrive. ---------------------------------------------------------
	if indi_rest == 0 or indi_rest == 20 or indi_rest == 10 then
		directorios_faltantes("Sega Megadrive", "PicoDrive")
		pantalla_reiniciar_conf(FONDO_LOAD, 60, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Sega Megadrive/retroarch/retroarch.cfg") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Sega Megadrive/retroarch/retroarch.cfg", actual .."/System/RetroarchPS2/Sega Megadrive/retroarch/retroarch.cfg")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 63, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Sega Megadrive/retroarch/config/PicoDrive/PicoDrive.opt") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Sega Megadrive/retroarch/config/PicoDrive/PicoDrive.opt", actual .."/System/RetroarchPS2/Sega Megadrive/retroarch/config/PicoDrive/PicoDrive.opt")
		end
	end

	-- Restaura Sega SG-1000. -----------------------------------------------------------
	if indi_rest == 0 or indi_rest == 20 or indi_rest == 11 then
		directorios_faltantes("Sega SG-1000", "PicoDrive")
		pantalla_reiniciar_conf(FONDO_LOAD, 66, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Sega SG-1000/retroarch/retroarch.cfg") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Sega SG-1000/retroarch/retroarch.cfg", actual .."/System/RetroarchPS2/Sega SG-1000/retroarch/retroarch.cfg")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 68, false, indi_rest)
		if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/Sega SG-1000/retroarch/config/PicoDrive/PicoDrive.opt") then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/Sega SG-1000/retroarch/config/PicoDrive/PicoDrive.opt", actual .."/System/RetroarchPS2/Sega SG-1000/retroarch/config/PicoDrive/PicoDrive.opt")
		end
	end

	-- Restaura retroarch-salamander.cfg. -----------------------------------------------
	pantalla_reiniciar_conf(FONDO_LOAD, 70, false, indi_rest)
	if doesFileExist(actual .."/System/Respaldo/".. dir_mode_video .."/retroarch-salamander.cfg") then
		if indi_rest == 0 or indi_rest == 20 or indi_rest == 1 then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/retroarch-salamander.cfg", actual .."/System/RetroarchPS2/Atari 2600/retroarch/retroarch-salamander.cfg")
		end
		if indi_rest == 0 or indi_rest == 20 or indi_rest == 2 then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/retroarch-salamander.cfg", actual .."/System/RetroarchPS2/Neo Geo Pocket/retroarch/retroarch-salamander.cfg")
		end
		if indi_rest == 0 or indi_rest == 20 or indi_rest == 3 then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/retroarch-salamander.cfg", actual .."/System/RetroarchPS2/Nintendo Famicom/retroarch/retroarch-salamander.cfg")
		end
		if indi_rest == 0 or indi_rest == 20 or indi_rest == 4 then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/retroarch-salamander.cfg", actual .."/System/RetroarchPS2/Nintendo Game Boy/retroarch/retroarch-salamander.cfg")
		end
		if indi_rest == 0 or indi_rest == 20 or indi_rest == 5 then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/retroarch-salamander.cfg", actual .."/System/RetroarchPS2/Nintendo Game Boy Advance/retroarch/retroarch-salamander.cfg")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 71, false, indi_rest)
		if indi_rest == 0 or indi_rest == 20 or indi_rest == 6 then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/retroarch-salamander.cfg", actual .."/System/RetroarchPS2/Nintendo Game Boy Color/retroarch/retroarch-salamander.cfg")
		end
		if indi_rest == 0 or indi_rest == 20 or indi_rest == 7 then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/retroarch-salamander.cfg", actual .."/System/RetroarchPS2/Nintendo Super Famicom/retroarch/retroarch-salamander.cfg")
		end
		if indi_rest == 0 or indi_rest == 20 or indi_rest == 8 then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/retroarch-salamander.cfg", actual .."/System/RetroarchPS2/Sega Game Gear/retroarch/retroarch-salamander.cfg")
		end
		if indi_rest == 0 or indi_rest == 20 or indi_rest == 9 then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/retroarch-salamander.cfg", actual .."/System/RetroarchPS2/Sega Master System/retroarch/retroarch-salamander.cfg")
		end
		if indi_rest == 0 or indi_rest == 20 or indi_rest == 10 then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/retroarch-salamander.cfg", actual .."/System/RetroarchPS2/Sega Megadrive/retroarch/retroarch-salamander.cfg")
		end
		if indi_rest == 0 or indi_rest == 20 or indi_rest == 11 then
			System.copyFile(actual .."/System/Respaldo/".. dir_mode_video .."/retroarch-salamander.cfg", actual .."/System/RetroarchPS2/Sega SG-1000/retroarch/retroarch-salamander.cfg")
		end
	end

	-- Restaura las configuraciones. ----------------------------------------------------
	pantalla_reiniciar_conf(FONDO_LOAD, 72, false, indi_rest)
	if indi_rest == 0 then
		if doesFileExist(actual .."/System/Respaldo/Path_file.cfg") then
			System.copyFile(actual .."/System/Respaldo/Path_file.cfg", actual .."/System/Config/Path_file.cfg")
		end
		if doesFileExist(actual .."/System/Respaldo/Config.cfg") then
			System.copyFile(actual .."/System/Respaldo/Config.cfg", actual .."/System/Config/Config.cfg")
		end
		if doesFileExist(actual .."/System/Respaldo/System.cfg") then
			System.copyFile(actual .."/System/Respaldo/System.cfg", actual .."/System/Config/System.cfg")
		end
	end

	-- Restaura variables. --------------------------------------------------------------
	pantalla_reiniciar_conf(FONDO_LOAD, 73, false, indi_rest)
	if indi_rest == 0 or indi_rest == 20 then
		guardar_opciones()
		pantalla_reiniciar_conf(FONDO_LOAD, 75, false, indi_rest)
		cargar_config()
		cargar_directorio_elf()
	end
	Graphics.freeImage(FONDO_LOAD)
end

--- Muestra los créditos. ---------------------------------------------------------------
function creditos()
	local FONDO_LOAD = Graphics.loadImage("System/Medios/Default/FONDO.png")
	local LOADING_LOAD = Graphics.loadImage("System/Medios/Default/LOADING.png")
	local res_x, res_y_tex, res_y = 640, 0, 448
	if doesFileExist("System/Respaldo/PAL") then
		res_x, res_y_tex, res_y = 640, 32, 512
	end
	Screen.clear(Color.new(0, 0, 0))
	Graphics.drawScaleImage(FONDO_LOAD, -5, 0, res_x+5, res_y, Color.new(0, 80, 120))
	Graphics.drawScaleImage(LOADING_LOAD, 0, 0, res_x, res_y)
	refrescar(false)
	local ENCELADUS = Graphics.loadImage("System/Medios/Credits/ENCELADUS.png")
	local POPSTARTER = Graphics.loadImage("System/Medios/Credits/POPSTARTER.png")
	local RETROARCH = Graphics.loadImage("System/Medios/Credits/RETROARCH.png")
	local GPSP = Graphics.loadImage("System/Medios/Credits/GPSP.png")
	local RETROLAUNCHER = Graphics.loadImage("System/Medios/Credits/RETROLAUNCHER.png")
	local NEUTRINO = Graphics.loadImage("System/Medios/Credits/NEUTRINO.png")
	local WLAUNCHELF = Graphics.loadImage("System/Medios/Credits/WLAUNCHELF_ISR.png")
	local SPAGHETTICODE = Graphics.loadImage("System/Medios/Credits/SPAGHETTICODE.png")
	local CREDITOS_IMG = {ENCELADUS, RETROARCH, GPSP, POPSTARTER, NEUTRINO, WLAUNCHELF, SPAGHETTICODE, RETROLAUNCHER, RETROLAUNCHER}
	local CREDITOS_TXT = {"Enceladus is an enhanced Lua environment for\ncreating homebrew software for the PS2.\nDanielSant0s X: https://x.com/danadsees\n\nProject Link:\nhttps://github.com/DanielSant0s/Enceladus\nLicense: Distributed under GNU GPL-3.0 License.";
	"Retroarch port created by RetroArch contributor\nfjtrujy (Francisco J. Trujillo).\nfjtrujy X: https://x.com/fjtrujy\n\nRetroarch Link:\nhttps://www.retroarch.com\n\nLicenses: There is software behind RetroArch\nthat is protected by Non-Commercial licenses.\nIt is important to respect the wishes of the\ndevelopers and people behind the respective\nprojects.\nhttps://docs.libretro.com/development/licenses/";
	"TempGBA (GpSP) is a GBA emulator ported to PS2\nby developer belek666.\n\nbelek666 GitHub: https://github.com/belek666\n\nGpSP - PS2 link: https://www.psx-place.com/\nresources/gpsp-by-belek666.687/";
	"POPStarter is a launcher which lets you play\nyour PS1 games in combination with PS1 emulator\nfor PS2.\n\nPOPStarter v13 was created by developer krHACKen.\nPOPStarter Link: https://\nwww.psx-place.com/threads/popstarter.19139/";
	"Neutrino is a small, fast and modular PS2 device\nemulator that maximizes compatibility and\nperformance. Neutrino was created by developer\nMaximus32 (Rick Gaiser).\n\nNeutrino Link:\nhttps://github.com/rickgaiser/neutrino\n\nLicense: Academic Free License \"AFL\" v. 3.0";
	"wLaunchELF ISR is an open source file manager\nand executable launcher for the PS2 console.\nwLaunchELF 4.43x_ISR was created by developer\nisrapps (Matías Israelson) and is a wLaunchELF\nmod.\n\nisrapps (Matías Israelson):\nhttps://israpps.github.io\nwLaunchELF 4.43x_ISR Project Link:\nhttps://github.com/israpps/wLaunchELF_ISR\n\nwLaunchELF Project Link:\nhttps://github.com/ps2homebrew/wLaunchELF\nLicense: Academic Free License \"AFL\" v. 2.0\nwLaunchELF / project by AKuHAK and SP193.\nuLaunchELF / project by E P and dlanor.\nLaunchELF / project by Mirakichi.\nAnd to all the developers who contributed to uLE.";
	"Thanks to public education for the support \nduring my technical training.\nSpaghetticode / LC - Mendoza - Argentina / 2024";
	"Original background created by < e s c p > Art\nLicense: This Image is licensed under the\nCreative Commons Zero v1.0 Universal.\nFree images by https://www.artapixel.com\n\nFont \"Public Pixel\" Designed by GGBotNet.\nGGBotNet X: https://twitter.com/ggbotnet\nPublic Pixel Link: https://www.ggbot.net/fonts/\nLicense: This Font Software is licensed under\nthe Creative Commons Zero v1.0 Universal.\nCC0 1.0 Link: https://\ncreativecommons.org/publicdomain/zero/1.0/\n";
	"A special thank you to the entire \"PSX-PLACE\"\ncommunity for providing support and visibility\nto the program.\nWe also thank all YouTube channels along with\ntheir communities for spreading and improving\nRETROLauncher with their supportive messages\nand constructive feedback.\n\nThanks for using RETROLauncher.     Boon Tobias"}
	local color_img = 129
	local color_tex = 128
	local cambio = true
	local cambio_t = true
	local pasaje = false
	local estado = 1
	local lista_pos_imgY = {-73, -140, -140, -40, -93, -179, -80, -110, -110}
	local lista_pos_imgX = {10, 0, 0, 10, 10, 10, -10, 0, 0}
	local lista_pos_tex = {309+res_y_tex, 185+res_y_tex, 240+res_y_tex, 310+res_y_tex, 260+res_y_tex, 109+res_y_tex, 360+res_y_tex, 210+res_y_tex, 234+res_y_tex}
	local lista_pos_img_x = {620, 640, 640, 620, 620, 620, 660, 640, 640}
	local lista_pos_img_y = {460+res_y_tex, 480+res_y_tex, 480+res_y_tex, 460+res_y_tex, 460+res_y_tex, 460+res_y_tex, 500+res_y_tex, 480+res_y_tex, 480+res_y_tex}
	local autocambio = 0
	local mostrar_sob = false
	local TheLastLive = true
	while TheLastLive do
		CONTROL.FPS = Screen.getFPS(1)
		capturar(JOYSTICK_LIMITE)
		Screen.clear(Color.new(0, 0, 0))
		if pasaje == false then
			if color_img >= 1 and cambio == true then
				color_img = color_img-1
			elseif color_img <= 0 and cambio == true then
				color_img = 0
			elseif color_img <= 127 and cambio == false then
				color_img = color_img+1
			elseif color_img >= 128 and cambio == false then
				color_img = 128
				cambio = true
				estado = estado+1
			end
			if color_tex >= 1 and cambio_t == true and color_img == 0 then
				color_tex = color_tex-1
			elseif color_tex <= 0 and cambio_t == true and color_img == 0 then
				color_tex = 0
				cambio_t = false
				pasaje = true
			elseif color_tex <= 127 and cambio_t == false and color_img == 0 then
				color_tex = color_tex+1
			elseif color_tex >= 128 and cambio_t == false and color_img == 0 then
				color_tex = 128
				cambio_t = true
				cambio = false
			end
		if estado == 8 and color_img == 0 and color_tex == 128 then
			mostrar_sob = true
		elseif estado == 9 and color_img == 0 and color_tex == 0 then
			mostrar_sob = false
		end

		-- Controla los créditos. -------------------------------------------------------
		elseif Pads.check(PAD, PAD_CIRCLE) or Pads.check(PAD, PAD_TRIANGLE) then
			TheLastLive = false
		elseif pasaje == true and PAD ~= 0 then
			pasaje = false
			autocambio = 0
		elseif pasaje == true and autocambio >= 256 then
			pasaje = false
			autocambio = 0
		elseif pasaje == true then
			autocambio = autocambio+1
		end
		
		-- Mostrar todo en pantalla. ----------------------------------------------------
		if estado <= #CREDITOS_IMG then
			Graphics.drawScaleImage(CREDITOS_IMG[estado], lista_pos_imgX[estado]-5, lista_pos_imgY[estado], lista_pos_img_x[estado]+5, lista_pos_img_y[estado])
			Graphics.drawRect(0, 0, res_x, res_y, Color.new(0, 0, 0, color_img))
			if mostrar_sob == true then
				Graphics.drawScaleImage(CREDITOS_IMG[estado], lista_pos_imgX[estado]-5, lista_pos_imgY[estado], lista_pos_img_x[estado]+5, lista_pos_img_y[estado])
			end
			Font.ftPrint(CONTROL.fontARCA, 5, lista_pos_tex[estado], 0, res_x, res_y, CREDITOS_TXT[estado], Color.new(128, 128, 128))
			Graphics.drawRect(0, lista_pos_tex[estado], res_x, res_y, Color.new(0, 0, 0, color_tex))
		else
			TheLastLive = false
		end
		refrescar(false)
	end
	Graphics.freeImage(FONDO_LOAD)
	Graphics.freeImage(LOADING_LOAD)
	Graphics.freeImage(ENCELADUS)
	Graphics.freeImage(POPSTARTER)
	Graphics.freeImage(NEUTRINO)
	Graphics.freeImage(WLAUNCHELF)
	Graphics.freeImage(RETROARCH)
	Graphics.freeImage(GPSP)
	Graphics.freeImage(RETROLAUNCHER)
	Graphics.freeImage(SPAGHETTICODE)
	CREDITOS_IMG = nil
end

--[[Líneas para las funciones encargadas del editor de estilos.]]--
--- Dibuja en pantalla la vista previa de todos los elementos. --------------------------
function dibujar_demo(selector_elementos, elementos_pos_new, elementos_tam_new, cambio_tama_pos, fijar, largo_lista, estado_elementos_new)
	-- Vista previa del arte relacionado con cover flow. --------------------------------
	if estado_elementos_new[4] == true then
		Graphics.drawRect(elementos_pos_new[7]-5, elementos_pos_new[8]-5+CONTROL.Y_FIX_PAL, elementos_tam_new[7]+10, elementos_tam_new[8]+10, COLOR.NEGRO_T)
		Graphics.drawRect((CONTROL.ANCHO-(elementos_pos_new[7]+elementos_tam_new[7]))-5, elementos_pos_new[8]-5+CONTROL.Y_FIX_PAL, elementos_tam_new[7]+10, elementos_tam_new[8]+10, COLOR.NEGRO_T)
		if OPCIONES.FONDO_RGB_FIJO_ON == 1 and CAMBIOS_EMUS.TRAS ~= 0 then
			Graphics.drawScaleImage(LISTAS.COVER_DEFAULT, elementos_pos_new[7], elementos_pos_new[8]+CONTROL.Y_FIX_PAL, elementos_tam_new[7], elementos_tam_new[8])
			Graphics.drawRect(elementos_pos_new[7], elementos_pos_new[8]+CONTROL.Y_FIX_PAL, elementos_tam_new[7], elementos_tam_new[8], CAMBIOS_EMUS.COLOR_EMU_BACK)
		else
			Graphics.drawScaleImage(LISTAS.COVER_DEFAULT, elementos_pos_new[7], elementos_pos_new[8]+CONTROL.Y_FIX_PAL, elementos_tam_new[7], elementos_tam_new[8], CAMBIOS_EMUS.COLOR_EMU_BACK)
		end
		if OPCIONES.FONDO_RGB_FIJO_ON == 1 and CAMBIOS_EMUS.TRAS ~= 0 then
			Graphics.drawScaleImage(LISTAS.COVER_DEFAULT, (CONTROL.ANCHO-(elementos_pos_new[7]+elementos_tam_new[7])), elementos_pos_new[8]+CONTROL.Y_FIX_PAL, elementos_tam_new[7], elementos_tam_new[8])
			Graphics.drawRect((CONTROL.ANCHO-(elementos_pos_new[7]+elementos_tam_new[7])), elementos_pos_new[8]+CONTROL.Y_FIX_PAL, elementos_tam_new[7], elementos_tam_new[8], CAMBIOS_EMUS.COLOR_EMU_BACK)
		else
			Graphics.drawScaleImage(LISTAS.COVER_DEFAULT, (CONTROL.ANCHO-(elementos_pos_new[7]+elementos_tam_new[7])), elementos_pos_new[8]+CONTROL.Y_FIX_PAL, elementos_tam_new[7], elementos_tam_new[8], CAMBIOS_EMUS.COLOR_EMU_BACK)
		end
	end

	-- Vista previa del arte extra. -----------------------------------------------------
	if estado_elementos_new[3] == true then
		Graphics.drawRect(elementos_pos_new[5]-5, elementos_pos_new[6]-5+CONTROL.Y_FIX_PAL, elementos_tam_new[5]+10, elementos_tam_new[6]+10, COLOR.NEGRO_T)
		if OPCIONES.FONDO_RGB_FIJO_ON == 1 and CAMBIOS_EMUS.TRAS ~= 0 then
			Graphics.drawScaleImage(LISTAS.SCREENSHOT_DEFAULT, elementos_pos_new[5], elementos_pos_new[6]+CONTROL.Y_FIX_PAL, elementos_tam_new[5], elementos_tam_new[6])
			Graphics.drawRect(elementos_pos_new[5], elementos_pos_new[6]+CONTROL.Y_FIX_PAL, elementos_tam_new[5], elementos_tam_new[6], CAMBIOS_EMUS.COLOR_EMU_BACK)
		else
			Graphics.drawScaleImage(LISTAS.SCREENSHOT_DEFAULT, elementos_pos_new[5], elementos_pos_new[6]+CONTROL.Y_FIX_PAL, elementos_tam_new[5], elementos_tam_new[6], CAMBIOS_EMUS.COLOR_EMU_BACK)
		end
	end

	-- Vista previa del fondo de lista. -------------------------------------------------
	if estado_elementos_new[1] == true then
		Graphics.drawRect(elementos_pos_new[1]-3, elementos_pos_new[2]-3+CONTROL.Y_FIX_PAL, elementos_tam_new[1]+6, elementos_tam_new[2]+6, COLOR.NEGRO_T)
	end

	-- Vista previa de las listas de juegos. --------------------------------------------
	local lista_ejemplo = {}
	if estado_elementos_new[4] == false and estado_elementos_new[1] == true then
		for agregar = 1, largo_lista do table.insert(lista_ejemplo, agregar.. ".Example of game name.zip") end
		local espacio_linea = elementos_pos_new[2]+((0)*24)+CONTROL.Y_FIX_PAL
		for contador = 1, largo_lista, 1 do
			if contador == 1 then
				Font.ftPrint(CONTROL.fontARCA, elementos_pos_new[1]+3, espacio_linea, 0, elementos_tam_new[1]-6, 25, string.sub(lista_ejemplo[contador], 1, -5), CAMBIOS_EMUS.COLOR_EMU)
			else
				Font.ftPrint(CONTROL.fontARCA, elementos_pos_new[1]+3, espacio_linea, 0, elementos_tam_new[1]-6, 25, string.sub(lista_ejemplo[contador], 1, -5), COLOR.BLANCO_LISTA)
			end
			espacio_linea = elementos_pos_new[2]+((contador)*24)+CONTROL.Y_FIX_PAL
		end

	-- Vista previa de las listas de juegos en cover flow. ------------------------------
	elseif estado_elementos_new[4] == true or estado_elementos_new[1] == false then
		lista_ejemplo = {"Center / Example of game name.zip", "Right / Example of game name.zip", "Left / Example of game name.zip"}
		if estado_elementos_new[4] == true then
			-- Vista previa / izquierda. ------------------------------------------------
			Graphics.drawRect(elementos_pos_new[7], (elementos_pos_new[8]+elementos_tam_new[8])+10+CONTROL.Y_FIX_PAL, elementos_tam_new[7], 25, COLOR.NEGRO_T)
			Font.ftPrint(CONTROL.fontARCA, elementos_pos_new[7]+5, (elementos_pos_new[8]+elementos_tam_new[8])+12+CONTROL.Y_FIX_PAL, 0, elementos_tam_new[7]-10, 25, string.sub(lista_ejemplo[3], 1, -CONTROL.EXTENSION), COLOR.BLANCO_LISTA)

			-- Vista previa / derecha. --------------------------------------------------
			Graphics.drawRect((CONTROL.ANCHO-(elementos_pos_new[7]+elementos_tam_new[7])), (elementos_pos_new[8]+elementos_tam_new[8])+10+CONTROL.Y_FIX_PAL, elementos_tam_new[7], 25, COLOR.NEGRO_T)
			Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO-(elementos_pos_new[7]+elementos_tam_new[7]))+5, (elementos_pos_new[8]+elementos_tam_new[8])+12+CONTROL.Y_FIX_PAL, 0, elementos_tam_new[7]-10, 25, string.sub(lista_ejemplo[2], 1, -CONTROL.EXTENSION), COLOR.BLANCO_LISTA)
		end

		-- Vista previa / centro. -------------------------------------------------------
		Graphics.drawRect(elementos_pos_new[3]-31, (elementos_pos_new[4]+elementos_tam_new[4])+14+CONTROL.Y_FIX_PAL, elementos_tam_new[3]+62, 25, COLOR.NEGRO_T)
		Font.ftPrint(CONTROL.fontARCA, (elementos_pos_new[3]-31)+5, (elementos_pos_new[4]+elementos_tam_new[4])+16+CONTROL.Y_FIX_PAL, 0, (elementos_tam_new[3]+62)-5, 25, string.sub(lista_ejemplo[1], 1, -CONTROL.EXTENSION), CAMBIOS_EMUS.COLOR_EMU)
	end

	-- Vista previa de juegos encontrados. ----------------------------------------------
	if selector_elementos ~= 1 then
		local text_con = "FOUND GAMES: "
		local fix_estilo = 29
		if (estado_elementos_new[4] == true or estado_elementos_new[1] == false) then fix_estilo = 24 end
		Graphics.drawRect(elementos_pos_new[1]-3, (elementos_pos_new[2]+elementos_tam_new[2])-fix_estilo+1+CONTROL.Y_FIX_PAL, elementos_tam_new[1]+6, fix_estilo+1, COLOR.NEGRO)
		Graphics.drawScaleImage(PAD_IMG.CIRCLE, elementos_pos_new[1]+3, (elementos_pos_new[2]+elementos_tam_new[2])-(fix_estilo-4)+CONTROL.Y_FIX_PAL, 20, 20)
		Font.ftPrint(CONTROL.fontARCA, elementos_pos_new[1]+30, (elementos_pos_new[2]+elementos_tam_new[2])-(fix_estilo-4)+CONTROL.Y_FIX_PAL, 0, elementos_tam_new[1]-30, 25, text_con.. #lista_ejemplo, CAMBIOS_EMUS.COLOR_EMU)
	end

	-- Vista previa de indicadores. -----------------------------------------------------
	local message = {"SAMPLE / EXIT", "SAMPLE / CONFIG", "SAMPLE/ART", "SAMPLE/FULL", "SAMPLE/RUN", "SAMPLE/UPDATE"}

	-- Vista previa de indicador para actualizar la lista. ------------------------------
	if selector_elementos == 11 and estado_elementos_new[11] == true then
		Graphics.drawScaleImage(PAD_IMG.R3, elementos_pos_new[21]-30, elementos_pos_new[22]-3+CONTROL.Y_FIX_PAL, 25, 25)
		Font.ftPrint(CONTROL.fontARCA, elementos_pos_new[21]+3, elementos_pos_new[22]+1+CONTROL.Y_FIX_PAL, 0, 0, 25, message[6], COLOR.BLANCO)
	end

	-- Vista previa de indicadores para cambio de sistemas. -----------------------------
	if estado_elementos_new[9] == true then
		Graphics.drawScaleImage(PAD_IMG.L1, elementos_pos_new[17], elementos_pos_new[18]+CONTROL.Y_FIX_PAL, 32, 32)
	end
	if estado_elementos_new[10] == true then
		Graphics.drawScaleImage(PAD_IMG.R1, elementos_pos_new[19], elementos_pos_new[18]+CONTROL.Y_FIX_PAL, 32, 32)
	end

	-- Vista previa de indicador de salida. ---------------------------------------------
	if estado_elementos_new[13] == true then
		Graphics.drawScaleImage(PAD_IMG.SELECT_S, elementos_pos_new[25]-36, elementos_pos_new[26]-7+CONTROL.Y_FIX_PAL, 32, 32)
		Font.ftPrint(CONTROL.fontARCA, elementos_pos_new[25]+3, elementos_pos_new[26]+1+CONTROL.Y_FIX_PAL, 0, 0, 25, message[1], COLOR.BLANCO)
	end

	-- Vista previa del indicador de configuración. -------------------------------------
	if estado_elementos_new[12] == true then
		Graphics.drawScaleImage(PAD_IMG.START, elementos_pos_new[23]-36, elementos_pos_new[24]-7+CONTROL.Y_FIX_PAL, 32, 32)
		Font.ftPrint(CONTROL.fontARCA, elementos_pos_new[23]+3, elementos_pos_new[24]+1+CONTROL.Y_FIX_PAL, 0, 0, 25, message[2], COLOR.BLANCO)
	end
	if selector_elementos ~= 11 then
		-- Vista previa: indicadores / cambio de arte. ----------------------------------
		if estado_elementos_new[7] == true then
			Graphics.drawScaleImage(PAD_IMG.TRIANGLE, elementos_pos_new[13]-30, elementos_pos_new[14]-3+CONTROL.Y_FIX_PAL, 25, 25)
				Font.ftPrint(CONTROL.fontARCA, elementos_pos_new[13]+3, elementos_pos_new[14]+1+CONTROL.Y_FIX_PAL, 0, 0, 25, message[3], COLOR.BLANCO)
		end

		-- Vista previa: indicadores / arte a pantalla completa. ------------------------
		if estado_elementos_new[8] == true then
			Graphics.drawScaleImage(PAD_IMG.SQUARE, elementos_pos_new[15]-30, elementos_pos_new[16]-3+CONTROL.Y_FIX_PAL, 25, 25)
				Font.ftPrint(CONTROL.fontARCA, elementos_pos_new[15]+3, elementos_pos_new[16]+1+CONTROL.Y_FIX_PAL, 0, 0, 25, message[4], COLOR.BLANCO)
		end

		-- Vista previa: indicadores / ejecución. ---------------------------------------
		if estado_elementos_new[6] == true then
			Graphics.drawScaleImage(PAD_IMG.CROSS, elementos_pos_new[11]-30, elementos_pos_new[12]-3+CONTROL.Y_FIX_PAL, 25, 25)
				Font.ftPrint(CONTROL.fontARCA, elementos_pos_new[11]+3, elementos_pos_new[12]+1+CONTROL.Y_FIX_PAL, 0, 0, 25, message[5], COLOR.BLANCO)
		end
	end

	-- Vista previa de portadas / capturas / fondos. ------------------------------------
	if estado_elementos_new[2] == true then
		Graphics.drawRect(elementos_pos_new[3]-5, elementos_pos_new[4]-5+CONTROL.Y_FIX_PAL, elementos_tam_new[3]+10, elementos_tam_new[4]+10, COLOR.NEGRO_T)
		if OPCIONES.FONDO_RGB_FIJO_ON == 1 and CAMBIOS_EMUS.TRAS ~= 0 then
			Graphics.drawScaleImage(LISTAS.COVER_DEFAULT, elementos_pos_new[3], elementos_pos_new[4]+CONTROL.Y_FIX_PAL, elementos_tam_new[3], elementos_tam_new[4])
			Graphics.drawRect(elementos_pos_new[3], elementos_pos_new[4]+CONTROL.Y_FIX_PAL, elementos_tam_new[3], elementos_tam_new[4], CAMBIOS_EMUS.COLOR_EMU_BACK)
		else
			Graphics.drawScaleImage(LISTAS.COVER_DEFAULT, elementos_pos_new[3], elementos_pos_new[4]+CONTROL.Y_FIX_PAL, elementos_tam_new[3], elementos_tam_new[4], CAMBIOS_EMUS.COLOR_EMU_BACK)
		end
	end

	-- Vista previa del logo. -----------------------------------------------------------
	if estado_elementos_new[5] == true then
		Graphics.drawScaleImage(LISTAS.LOGO, elementos_pos_new[9], elementos_pos_new[10]+CONTROL.Y_FIX_PAL, elementos_tam_new[9], elementos_tam_new[10])
	end

	-- Marca sobre el elemento seleccionado. --------------------------------------------
	local color_selector = Color.new(0, 128, 0, 90)
	if cambio_tama_pos == true and selector_elementos <= 5 then color_selector = Color.new(0, 0, 128, 90) end
	if fijar[selector_elementos] == true then color_selector = Color.new(128, 0, 0, 90) end
	if selector_elementos == 1 and estado_elementos_new[1] == true then
		Graphics.drawRect(elementos_pos_new[1]-3, elementos_pos_new[2]-3+CONTROL.Y_FIX_PAL, elementos_tam_new[1]+6, elementos_tam_new[2]+6, color_selector)
	elseif selector_elementos == 2 and estado_elementos_new[2] == true then
		Graphics.drawRect(elementos_pos_new[3]-5, elementos_pos_new[4]-5+CONTROL.Y_FIX_PAL, elementos_tam_new[3]+10, elementos_tam_new[4]+10, color_selector)
	elseif selector_elementos == 3 and estado_elementos_new[3] == true then
		Graphics.drawRect(elementos_pos_new[5]-5, elementos_pos_new[6]-5+CONTROL.Y_FIX_PAL, elementos_tam_new[5]+10, elementos_tam_new[6]+10, color_selector)
	elseif selector_elementos == 4 and estado_elementos_new[4] == true then
		Graphics.drawRect(elementos_pos_new[7]-5, elementos_pos_new[8]-5+CONTROL.Y_FIX_PAL, elementos_tam_new[7]+10, elementos_tam_new[8]+10, color_selector)
		Graphics.drawRect((CONTROL.ANCHO-(elementos_pos_new[7]+elementos_tam_new[7]))-5, elementos_pos_new[8]-5+CONTROL.Y_FIX_PAL, elementos_tam_new[7]+10, elementos_tam_new[8]+10, color_selector)
	elseif selector_elementos == 5 and estado_elementos_new[5] == true then
		Graphics.drawRect(elementos_pos_new[9]-5, elementos_pos_new[10]-5+CONTROL.Y_FIX_PAL, elementos_tam_new[9]+10, elementos_tam_new[10]+10, color_selector)
	elseif selector_elementos == 6 and estado_elementos_new[6] == true then
		Graphics.drawRect(elementos_pos_new[11]-30, elementos_pos_new[12]-3+CONTROL.Y_FIX_PAL, 25, 25, color_selector)
	elseif selector_elementos == 7 and estado_elementos_new[7] == true then
		Graphics.drawRect(elementos_pos_new[13]-30, elementos_pos_new[14]-3+CONTROL.Y_FIX_PAL, 25, 25, color_selector)
	elseif selector_elementos == 8 and estado_elementos_new[8] == true then
		Graphics.drawRect(elementos_pos_new[15]-30, elementos_pos_new[16]-3+CONTROL.Y_FIX_PAL, 25, 25, color_selector)
	elseif selector_elementos == 9 and estado_elementos_new[9] == true then
		Graphics.drawRect(elementos_pos_new[17], elementos_pos_new[18]+CONTROL.Y_FIX_PAL+4, 32, 24, color_selector)
	elseif selector_elementos == 10 and estado_elementos_new[10] == true then
		Graphics.drawRect(elementos_pos_new[19], elementos_pos_new[18]+CONTROL.Y_FIX_PAL+4, 32, 24, color_selector)
	elseif selector_elementos == 11 and estado_elementos_new[11] == true then
		Graphics.drawRect(elementos_pos_new[21]-30, elementos_pos_new[22]-3+CONTROL.Y_FIX_PAL, 25, 25, color_selector)
	elseif selector_elementos == 12 and estado_elementos_new[12] == true then
		Graphics.drawRect(elementos_pos_new[23]-36, elementos_pos_new[24]+2+CONTROL.Y_FIX_PAL, 32, 20, color_selector)
	elseif selector_elementos == 13 and estado_elementos_new[13] == true then
		Graphics.drawRect(elementos_pos_new[25]-36, elementos_pos_new[26]+2+CONTROL.Y_FIX_PAL, 32, 20, color_selector)
	end
end

--- Cambio entre elementos activados y desactivados. ------------------------------------
function estado(selector_X_Y, selector_elementos, lado, estado_elementos_new)
	local buscar = true
	while buscar do
		if lado == true then
			selector_elementos = cambiar_valor(selector_elementos, 1, #estado_elementos_new, 1, true)
		elseif lado == false then
			selector_elementos = cambiar_valor(selector_elementos, 1, #estado_elementos_new, 1, false)
		end
		if estado_elementos_new[selector_elementos] == true then
			buscar = false
		elseif lado == nil then
			selector_elementos = 1
			lado = true
		end
	end
	selector_X_Y = selector_elementos+(selector_elementos-1)
	return selector_X_Y, selector_elementos
end

--- Dibujar líneas de guía en pantalla. -------------------------------------------------
function reglas(X, Y, cuadricula, selector_elementos)
	if selector_elementos == 1 then
		X, Y = X-3, Y-3
	elseif selector_elementos >= 2 and selector_elementos <= 5 then
		X, Y = X-5, Y-5
	elseif (selector_elementos >= 6 and selector_elementos <= 8) or selector_elementos == 11 then
		X, Y = X-30, Y-3
	elseif selector_elementos == 9 or selector_elementos == 10 then
		Y = Y+4
	elseif selector_elementos == 12 or selector_elementos == 13 then
		X, Y = X-36, Y+2
	end
	Graphics.drawLine(X, Y+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, Y+CONTROL.Y_FIX_PAL, Color.new(128, 128, 128))
	Graphics.drawLine(X, Y+CONTROL.Y_FIX_PAL, -10, Y+CONTROL.Y_FIX_PAL, Color.new(128, 128, 128))
	Graphics.drawLine(X, Y+CONTROL.Y_FIX_PAL, X, CONTROL.ALTO_F, Color.new(128, 128, 128))
	Graphics.drawLine(X, Y+CONTROL.Y_FIX_PAL, X, -10, Color.new(128, 128, 128))
	if cuadricula == 2 or cuadricula == 4 then
		local size_X, size_Y = 40, 32
		for ancho = -size_X, CONTROL.ANCHO+(size_X*2), size_X do
			Graphics.drawLine(ancho, -size_Y, ancho, CONTROL.ALTO_F+size_Y, Color.new(80, 80, 80))
		end
		for alto = -size_Y, CONTROL.ALTO_F+(size_Y*2), size_Y do
			Graphics.drawLine(-size_X, alto, CONTROL.ANCHO+size_X, alto, Color.new(80, 80, 80))
		end
	end
end

--- Líneas para configurar el estilo personalizado. -------------------------------------
function editor_tema()
	CONTROL.JOYSTICK_ON = true
	JOYSTICK_LIMITE = control_FPS(1)
	local actual = System.currentDirectory()
	local FONT_CNF = Font.ftLoad("System/Medios/Font/PublicPixel.ttf")
	Font.ftSetPixelSize(FONT_CNF, 17, 16)

	-- Estados previos de activación de elementos. --------------------------------------
	local estado_elementos_ant = {CONTROL.CUSTOM_LIST; CONTROL.CUSTOM_ART1; CONTROL.CUSTOM_ART2; CONTROL.CUSTOM_FLOW;
	CONTROL.CUSTOM_LOGO; CONTROL.CUSTOM_BUTTON_X; CONTROL.CUSTOM_BUTTON_T; CONTROL.CUSTOM_BUTTON_S; CONTROL.CUSTOM_BUTTON_L1;
	CONTROL.CUSTOM_BUTTON_R1; CONTROL.CUSTOM_BUTTON_R3; CONTROL.CUSTOM_BUTTON_STA; CONTROL.CUSTOM_BUTTON_SEL;};

	-- Nuevos estados de activación de elementos. ---------------------------------------
	local selector_elementos = 1
	local estado_elementos_new = {CONTROL.CUSTOM_LIST; CONTROL.CUSTOM_ART1; CONTROL.CUSTOM_ART2; CONTROL.CUSTOM_FLOW;
	CONTROL.CUSTOM_LOGO; CONTROL.CUSTOM_BUTTON_X; CONTROL.CUSTOM_BUTTON_T; CONTROL.CUSTOM_BUTTON_S; CONTROL.CUSTOM_BUTTON_L1;
	CONTROL.CUSTOM_BUTTON_R1; CONTROL.CUSTOM_BUTTON_R3; CONTROL.CUSTOM_BUTTON_STA; CONTROL.CUSTOM_BUTTON_SEL;};

	-- Lista con los nombres de objetos y opciones extras. ------------------------------
	local nombres_opciones = {"LIST"; "ART"; "EXTRA ART"; "COVER FLOW"; "LOGO"; "CROSS BUTTON"; "TRIANGLE BUTTON";
	"SQUARE BUTTON"; "L1 BUTTON"; "R1 BUTTON"; "R3 BUTTON"; "START BUTTON"; "SELECT BUTTON"; "TRANSITION TYPE";
	"TRANSITION SPEED"; "RESTORE ALL ITEMS"; "SAVE STYLE"; "EXIT EDIT MENU";};
	local nombres_acciones = {"LOCK ITEM"; "LINE GUIDE"; "POSITION"; "RESIZE"; "PIXELS";
	"RESTORE"; "NEXT ITEM"; "PREV ITEM"; "HELP"; "MENU ITEM"; "SAVE STYLE";};

	-- Lista para fijar el estado de elementos durante la edición. ----------------------
	local fijar = {false, false, false, false, false, false, false, false, false, false, false, false, false}

	-- Configuración de restauración completa. ------------------------------------------
	local restaura_estado = {true; true; false; false; true; true; true; true; true; true; true; true; true;};
	local restaura_pos = {30; 90; 358; 92; 358; 92; 30; 92; 194; 5; 270; 391; 40; 391; 475; 391; 144; 28; 464; 28; 260; 391; 423; 415; 45; 415;};
	local restaura_tam = {310; 290; 250; 193; 250; 193; 160; 103; 252; 76;};

	-- Posiciones y tamaños previos. ----------------------------------------------------
	local elementos_pos_ant = {
	CONTROL.LISTA_ANCHO; CONTROL.LISTA_ALTO-CONTROL.Y_FIX_PAL;
	CONTROL.IMG_ANCHO; CONTROL.IMG_ALTO-CONTROL.Y_FIX_PAL;
	CONTROL.IMG_ANCHO_2; CONTROL.IMG_ALTO_2-CONTROL.Y_FIX_PAL;
	CONTROL.FLOW_ANCHO; CONTROL.FLOW_ALTO-CONTROL.Y_FIX_PAL;
	CONTROL.LOGO_ANCHO; CONTROL.LOGO_ALTO-CONTROL.Y_FIX_PAL;
	CONTROL.X_BUTTON_X; CONTROL.Y_BUTTON_X;
	CONTROL.X_BUTTON_T; CONTROL.Y_BUTTON_T;
	CONTROL.X_BUTTON_S; CONTROL.Y_BUTTON_S;
	CONTROL.X_BUTTON_L1; CONTROL.Y_BUTTON_L1;
	CONTROL.X_BUTTON_R1; CONTROL.Y_BUTTON_R1;
	CONTROL.X_BUTTON_R3; CONTROL.Y_BUTTON_R3;
	CONTROL.X_BUTTON_STA; CONTROL.Y_BUTTON_STA;
	CONTROL.X_BUTTON_SEL; CONTROL.Y_BUTTON_SEL;};
	local elementos_tam_ant = {
	CONTROL.LISTA_X; CONTROL.LISTA_Y;
	CONTROL.IMG_X; CONTROL.IMG_Y;
	CONTROL.IMG_X_2; CONTROL.IMG_Y_2;
	CONTROL.FLOW_X; CONTROL.FLOW_Y;
	CONTROL.LOGO_X; CONTROL.LOGO_Y;};

	-- Nuevas posiciones y tamaños. -----------------------------------------------------
	local selector_X_Y = 1
	local elementos_pos_new = {
	CONTROL.LISTA_ANCHO; CONTROL.LISTA_ALTO-CONTROL.Y_FIX_PAL;
	CONTROL.IMG_ANCHO; CONTROL.IMG_ALTO-CONTROL.Y_FIX_PAL;
	CONTROL.IMG_ANCHO_2; CONTROL.IMG_ALTO_2-CONTROL.Y_FIX_PAL;
	CONTROL.FLOW_ANCHO; CONTROL.FLOW_ALTO-CONTROL.Y_FIX_PAL;
	CONTROL.LOGO_ANCHO; CONTROL.LOGO_ALTO-CONTROL.Y_FIX_PAL;
	CONTROL.X_BUTTON_X; CONTROL.Y_BUTTON_X;
	CONTROL.X_BUTTON_T; CONTROL.Y_BUTTON_T;
	CONTROL.X_BUTTON_S; CONTROL.Y_BUTTON_S;
	CONTROL.X_BUTTON_L1; CONTROL.Y_BUTTON_L1;
	CONTROL.X_BUTTON_R1; CONTROL.Y_BUTTON_R1;
	CONTROL.X_BUTTON_R3; CONTROL.Y_BUTTON_R3;
	CONTROL.X_BUTTON_STA; CONTROL.Y_BUTTON_STA;
	CONTROL.X_BUTTON_SEL; CONTROL.Y_BUTTON_SEL;};
	local elementos_tam_new = {
	CONTROL.LISTA_X; CONTROL.LISTA_Y;
	CONTROL.IMG_X; CONTROL.IMG_Y;
	CONTROL.IMG_X_2; CONTROL.IMG_Y_2;
	CONTROL.FLOW_X; CONTROL.FLOW_Y;
	CONTROL.LOGO_X; CONTROL.LOGO_Y;};

	-- Largo de la lista de juegos. -----------------------------------------------------
	local largo_lista = LISTAS.ELEMENTOS_LIST
	local anterior_anim, anterior_anim_vel = CONTROL.CUSTOM_ANIM, CONTROL.ANIM_VELOCIDAD

	-- Elementos para controlar el menú. ------------------------------------------------
	local submenu = false
	local hud = false
	local selector_submenu = 1
	local velocidad = 1
	local act_reglas = 0
	local cambio_tama_pos = false
	local salida = false
	local editar = true
	local change_detector = false
	selector_X_Y, selector_elementos = estado(selector_X_Y, selector_elementos, nil, estado_elementos_new)

	-- Iniciar la edición del estilo personalizado. -------------------------------------
	while editar do
		CONTROL.FPS = Screen.getFPS(1)
		capturar(JOYSTICK_LIMITE)
		dibujar_fondos()

		-- Determina el largo de la lista de juegos según su tamaño. --------------------
		if estado_elementos_new[1] == true then
			largo_lista = elementos_tam_new[2]//24
		else
			largo_lista = 1
		end

		-- Dibujar sobre fondo cuando las lineas de guia estan activadas. ---------------
		if act_reglas >= 1 and act_reglas <= 2 then
			Graphics.drawRect(-10, -10, CONTROL.ANCHO+20, CONTROL.ALTO_F+20, Color.new(20, 20, 20, 100))
		elseif act_reglas >= 3 then
			Graphics.drawRect(-10, -10, CONTROL.ANCHO+20, CONTROL.ALTO_F+20, Color.new(0, 40, 70))
		end

		-- Dibujar vistas previas de todos los elementos. -------------------------------
		dibujar_demo(selector_elementos, elementos_pos_new, elementos_tam_new, cambio_tama_pos, fijar, largo_lista, estado_elementos_new)

		-- Dibujar líneas de guía. ------------------------------------------------------
		if act_reglas >= 1 then reglas(elementos_pos_new[selector_X_Y], elementos_pos_new[selector_X_Y+1], act_reglas, selector_elementos) end

		-- Reubicar la ayuda en pantalla. -----------------------------------------------
		local hud_Y, hud_X, hud_alto, fix_hud = 0, 0, 102, 0
		if hud == false then hud_alto, fix_hud = 22, 86 end
		if (elementos_pos_new[selector_X_Y] <= CONTROL.ANCHO//2 and cambio_tama_pos == false) or
			(selector_elementos <= 5 and elementos_pos_new[selector_X_Y]+elementos_tam_new[selector_X_Y] <= CONTROL.ANCHO//2 and cambio_tama_pos == true) then
			hud_X = CONTROL.ANCHO-(CONTROL.ANCHO//2)-fix_hud
		end
		if (elementos_pos_new[selector_X_Y+1] <= CONTROL.ALTO_F//2 and cambio_tama_pos == false) or (selector_elementos <= 5 and elementos_pos_new[selector_X_Y+1]+elementos_tam_new[selector_X_Y+1] <= CONTROL.ALTO_F//2 and cambio_tama_pos == true) then
			hud_Y = CONTROL.ALTO_F-(hud_alto)-2
		end

		-- Dibujar la ayuda en pantalla. ------------------------------------------------
		if hud == true and submenu == false then
			Graphics.drawRect(hud_X, hud_Y, CONTROL.ANCHO//2, hud_alto, Color.new(117, 117, 117))
			Graphics.drawRect(hud_X+2, hud_Y+2, (CONTROL.ANCHO//2)-4, hud_alto-4, Color.new(20, 20, 20))
			Graphics.drawScaleImage(PAD_IMG.L1, hud_X+1, hud_Y, 25, 25)
			Font.ftPrint(FONT_CNF, hud_X+29, hud_Y+3, 0, CONTROL.ANCHO//2, 20, nombres_acciones[8], COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.R1, hud_X+160, hud_Y, 25, 25)
			Font.ftPrint(FONT_CNF, hud_X+188, hud_Y+3, 0, CONTROL.ANCHO//2, 20, nombres_acciones[7], COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.SQUARE, hud_X+6, hud_Y+23, 16, 16)
			Font.ftPrint(FONT_CNF, hud_X+28, hud_Y+21, 0, CONTROL.ANCHO//2, 20, nombres_acciones[9], COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.SELECT_S, hud_X+161, hud_Y+18, 25, 25)
			Font.ftPrint(FONT_CNF, hud_X+188, hud_Y+21, 0, CONTROL.ANCHO//2, 20, nombres_acciones[10], COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.CROSS, hud_X+6, hud_Y+44, 16, 16)
			Font.ftPrint(FONT_CNF, hud_X+28, hud_Y+43, 0, CONTROL.ANCHO//2, 20, nombres_acciones[1], COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.R3, hud_X+160, hud_Y+41, 24, 22)
			Font.ftPrint(FONT_CNF, hud_X+188, hud_Y+43, 0, CONTROL.ANCHO//2, 20, nombres_acciones[6], COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.L2, hud_X+1, hud_Y+60, 25, 25)
			if cambio_tama_pos == true and selector_elementos <= 5 then
				Font.ftPrint(FONT_CNF, hud_X+29, hud_Y+63, 0, CONTROL.ANCHO//2, 20, nombres_acciones[3], COLOR.BLANCO)
			else
				Font.ftPrint(FONT_CNF, hud_X+29, hud_Y+63, 0, CONTROL.ANCHO//2, 20, nombres_acciones[4], COLOR.BLANCO)
			end
			Graphics.drawScaleImage(PAD_IMG.R2, hud_X+160, hud_Y+60, 25, 25)
			Font.ftPrint(FONT_CNF, hud_X+188, hud_Y+63, 0, CONTROL.ANCHO//2, 20, nombres_acciones[5] .. ":" .. velocidad, COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.TRIANGLE, hud_X+6, hud_Y+83, 16, 16)
			Font.ftPrint(FONT_CNF, hud_X+28, hud_Y+81, 0, CONTROL.ANCHO//2, 20, nombres_acciones[2], COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.START, hud_X+161, hud_Y+78, 25, 25)
			Font.ftPrint(FONT_CNF, hud_X+188, hud_Y+81, 0, CONTROL.ANCHO//2, 20, nombres_acciones[11], COLOR.BLANCO)
		elseif hud == false and submenu == false then
			Graphics.drawRect(hud_X, hud_Y, (CONTROL.ANCHO//2)+86, hud_alto, Color.new(117, 117, 117))
			Graphics.drawRect(hud_X+2, hud_Y+2, (CONTROL.ANCHO//2)+82, hud_alto-4, Color.new(20, 20, 20))
			Graphics.drawScaleImage(PAD_IMG.SQUARE, hud_X+6, hud_Y+3, 16, 16)
			Font.ftPrint(FONT_CNF, hud_X+28, hud_Y+1, 0, CONTROL.ANCHO//2, 20, nombres_acciones[9], COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.SELECT_S, hud_X+86, hud_Y-1, 25, 25)
			Font.ftPrint(FONT_CNF, hud_X+114, hud_Y+1, 0, CONTROL.ANCHO//2, 20, "MENU", COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.R2, hud_X+170, hud_Y-1, 25, 25)
			Font.ftPrint(FONT_CNF, hud_X+198, hud_Y+1, 0, CONTROL.ANCHO//2, 20, "PIXELS:" .. velocidad, COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.START, hud_X+320, hud_Y-1, 25, 25)
			Font.ftPrint(FONT_CNF, hud_X+348, hud_Y+1, 0, CONTROL.ANCHO//2, 20, "SAVE", COLOR.BLANCO)
		end

		-- Controlar el menú de edición. ------------------------------------------------
		if submenu == false then
			-- Mostrar submenú de elementos. --------------------------------------------
			if Pads.check(PAD, PAD_SELECT) and CONTROL.JOYSTICK_ON == false then
				submenu = true
				if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then Sound.playADPCM(1, S_EJECUTAR) end
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)

			-- Guardar configuración. ---------------------------------------------------
			elseif Pads.check(PAD, PAD_START) and CONTROL.JOYSTICK_ON == false then
				if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then Sound.playADPCM(1, S_EJECUTAR) end
				local aplicar = guardar_style(estado_elementos_new, elementos_pos_new, elementos_tam_new, largo_lista, FONT_CNF)
				if aplicar == true then
					for actualiza = 1, #elementos_pos_new do
						elementos_pos_ant[actualiza] = elementos_pos_new[actualiza]
					end
					for actualiza2 = 1, #elementos_tam_new do
						elementos_tam_ant[actualiza2] = elementos_tam_new[actualiza2]
					end
					for actualiza3 = 1, #estado_elementos_new do
						estado_elementos_ant[actualiza3] = estado_elementos_new[actualiza3]
					end
					anterior_anim, anterior_anim_vel = CONTROL.CUSTOM_ANIM, CONTROL.ANIM_VELOCIDAD
					change_detector = true
				end
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)

			-- Salir del editor. --------------------------------------------------------
			elseif Pads.check(PAD, PAD_CIRCLE) and CONTROL.JOYSTICK_ON == false then
				salida = true
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)

			-- Cambiar entre los elementos en pantalla. ---------------------------------
			elseif (Pads.check(PAD, PAD_L1) or Pads.check(PAD, PAD_R1)) and CONTROL.JOYSTICK_ON == false then
				local lado_elemento = false
				if Pads.check(PAD, PAD_R1) then lado_elemento = true end
				selector_X_Y, selector_elementos = estado(selector_X_Y, selector_elementos, lado_elemento, estado_elementos_new)
				cambio_tama_pos = false
				if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then Sound.playADPCM(1, S_EJECUTAR) end
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)

			-- Intercambiar menú de ayuda en pantalla. ----------------------------------
			elseif Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
				if hud == false then hud = true else hud = false end
				if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then Sound.playADPCM(1, S_EJECUTAR) end
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)

			-- Activar / desactivar las líneas de guía en pantalla. ---------------------
			elseif Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
				act_reglas = cambiar_valor(act_reglas, 0, 4, 1, true)
				if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then Sound.playADPCM(1, S_EJECUTAR) end
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)

			-- Fijar un elemento para evitar su edición. --------------------------------
			elseif Pads.check(PAD, PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
				if fijar[selector_elementos] == false then fijar[selector_elementos] = true else fijar[selector_elementos] = false end
				if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then Sound.playADPCM(1, S_EJECUTAR) end
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)

			-- Restaura el elemento a su última posición guardada. ----------------------
			elseif (Pads.check(PAD, PAD_R3) or Pads.check(PAD, PAD_L3)) and CONTROL.JOYSTICK_ON == false and fijar[selector_elementos] == false then
				elementos_pos_new[selector_X_Y] = elementos_pos_ant[selector_X_Y]
				elementos_pos_new[selector_X_Y+1] = elementos_pos_ant[selector_X_Y+1]
				if selector_elementos <= 5 then
					elementos_tam_new[selector_X_Y] = elementos_tam_ant[selector_X_Y]
					elementos_tam_new[selector_X_Y+1] = elementos_tam_ant[selector_X_Y+1]
				end
				if OPCIONES.SOUND_ON == 1 and S_CANCELAR ~= nil then Sound.playADPCM(1, S_CANCELAR) end
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)

			-- Cambia las posiciones y tamaños de los elementos. ------------------------
			elseif (Pads.check(PAD, PAD_DOWN) or Pads.check(PAD, PAD_UP) or Pads.check(PAD, PAD_LEFT) or Pads.check(PAD, PAD_RIGHT) or (Left_Y ~= 1 or Left_X ~= 1) or Pads.check(PAD, PAD_L2) or Pads.check(PAD, PAD_R2)) and CONTROL.JOYSTICK_ON == false then
				-- Cambiar el salto de píxeles. -----------------------------------------
				if Pads.check(PAD, PAD_R2) then velocidad = cambiar_valor(velocidad, 1, 10, 1, true) end

				-- Intercambiar entre cambio de posición o tamaño. ----------------------
				if Pads.check(PAD, PAD_L2) and cambio_tama_pos == false and selector_elementos <= 5 then
					cambio_tama_pos = true
				elseif Pads.check(PAD, PAD_L2) and cambio_tama_pos == true and selector_elementos <= 5 then
					cambio_tama_pos = false
				end

				-- Realizar los movimientos de posicionamiento y redimensión. -----------
				if (Pads.check(PAD, PAD_UP) or Left_Y <= -90) and cambio_tama_pos == true and selector_elementos <= 5 and fijar[selector_elementos] == false then
					elementos_tam_new[selector_X_Y+1] = cambiar_valor(elementos_tam_new[selector_X_Y+1], 48, ((CONTROL.ALTO_F-CONTROL.Y_FIX_PAL)-elementos_pos_new[selector_X_Y+1]), velocidad, false)
				elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) and cambio_tama_pos == true and selector_elementos <= 5 and fijar[selector_elementos] == false then
					elementos_tam_new[selector_X_Y+1] = cambiar_valor(elementos_tam_new[selector_X_Y+1], 48, ((CONTROL.ALTO_F-CONTROL.Y_FIX_PAL)-elementos_pos_new[selector_X_Y+1]), velocidad, true)
				elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and cambio_tama_pos == true and selector_elementos <= 5 and fijar[selector_elementos] == false then
					elementos_tam_new[selector_X_Y] = cambiar_valor(elementos_tam_new[selector_X_Y], 48, (CONTROL.ANCHO-elementos_pos_new[selector_X_Y]), velocidad, false)
				elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and cambio_tama_pos == true and selector_elementos <= 5 and fijar[selector_elementos] == false then
					elementos_tam_new[selector_X_Y] = cambiar_valor(elementos_tam_new[selector_X_Y], 48, (CONTROL.ANCHO-elementos_pos_new[selector_X_Y]), velocidad, true)
				elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90) and fijar[selector_elementos] == false then
					elementos_pos_new[selector_X_Y+1] = cambiar_valor(elementos_pos_new[selector_X_Y+1], 0, (CONTROL.ALTO_F-(CONTROL.Y_FIX_PAL*2)), velocidad, false)
				elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) and fijar[selector_elementos] == false then
					elementos_pos_new[selector_X_Y+1] = cambiar_valor(elementos_pos_new[selector_X_Y+1], 0, (CONTROL.ALTO_F-(CONTROL.Y_FIX_PAL*2)), velocidad, true)
				elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and fijar[selector_elementos] == false then
					elementos_pos_new[selector_X_Y] = cambiar_valor(elementos_pos_new[selector_X_Y], 0, CONTROL.ANCHO, velocidad, false)
				elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and fijar[selector_elementos] == false then
					elementos_pos_new[selector_X_Y] = cambiar_valor(elementos_pos_new[selector_X_Y], 0, CONTROL.ANCHO, velocidad, true)
				end
				if Pads.check(PAD, PAD_R2) or Pads.check(PAD, PAD_L2) then
					if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then Sound.playADPCM(1, S_EJECUTAR) end
				else
					if OPCIONES.SOUND_ON == 1 and S_MOVER ~= nil then Sound.playADPCM(1, S_MOVER) end
				end
				CONTROL.JOYSTICK_ON = true
				local kabal = 1 if (Left_Y ~= 1 or Left_X ~= 1) and not (Pads.check(PAD, PAD_R2) or Pads.check(PAD, PAD_L2)) then kabal = 2 end
				JOYSTICK_LIMITE = control_FPS(kabal)
			end

		-- Muestra submenú de elementos. ------------------------------------------------
		else
			-- Dibujar las opciones del submenú y su estado. ----------------------------
			Graphics.drawRect((CONTROL.ANCHO//2), 0, 320, CONTROL.ALTO_F, Color.new(117, 117, 117))
			Graphics.drawRect((CONTROL.ANCHO//2)+2, 2, 316, CONTROL.ALTO_F-4, Color.new(20, 20, 20))
			Font.ftPrint(FONT_CNF, (CONTROL.ANCHO//2)+160, 12+CONTROL.Y_FIX_PAL, 8, 320, 21, "-ACTIVATE ELEMENTS-", Color.new(128, 128, 128))
			local espacio_linea = 12+((0)*21)+CONTROL.Y_FIX_PAL
			for elementos = 1, 13 do
				espacio_linea = 12+((elementos)*21)+CONTROL.Y_FIX_PAL
				local estado_on = "OFF"
				if estado_elementos_new[elementos] == true then estado_on = "ON" end
				if selector_submenu == elementos then
					Graphics.drawRect((CONTROL.ANCHO//2)+9, espacio_linea-2, 302, 23, Color.new(128, 128, 128))
					Graphics.drawRect((CONTROL.ANCHO//2)+11, espacio_linea, 298, 19, Color.new(30, 30, 30))
					Font.ftPrint(FONT_CNF, (CONTROL.ANCHO//2)+13, espacio_linea, 0, 320, 21, nombres_opciones[elementos], Color.new(128, 128, 128))
					Font.ftPrint(FONT_CNF, CONTROL.ANCHO-52, espacio_linea, 0, 320, 21, estado_on, Color.new(128, 128, 128))
				else
					Font.ftPrint(FONT_CNF, (CONTROL.ANCHO//2)+13, espacio_linea, 0, 320, 21, nombres_opciones[elementos], Color.new(70, 70, 70))
					Font.ftPrint(FONT_CNF, CONTROL.ANCHO-52, espacio_linea, 0, 320, 21, estado_on, Color.new(70, 70, 70))
				end
			end
			Font.ftPrint(FONT_CNF, (CONTROL.ANCHO//2)+160, 304+CONTROL.Y_FIX_PAL, 8, 320, 21, "-EXTRA OPTIONS-", Color.new(128, 128, 128))
			local espacio_linea2 = 33+((0)*21)+CONTROL.Y_FIX_PAL
			for elementos = 14, #nombres_opciones do
				espacio_linea2 = 33+((elementos)*21)+CONTROL.Y_FIX_PAL
				if selector_submenu == elementos then
					Graphics.drawRect((CONTROL.ANCHO//2)+9, espacio_linea2-2, 302, 23, Color.new(128, 128, 128))
					Graphics.drawRect((CONTROL.ANCHO//2)+11, espacio_linea2, 298, 19, Color.new(30, 30, 30))
					Font.ftPrint(FONT_CNF, (CONTROL.ANCHO//2)+13, espacio_linea2, 0, 320, 21, nombres_opciones[elementos], Color.new(128, 128, 128))
					if elementos == 14 then
						Font.ftPrint(FONT_CNF, CONTROL.ANCHO-52, espacio_linea2, 0, 320, 21, CONTROL.CUSTOM_ANIM, Color.new(128, 128, 128))
					elseif elementos == 15 then
						Font.ftPrint(FONT_CNF, CONTROL.ANCHO-52, espacio_linea2, 0, 320, 21, CONTROL.ANIM_VELOCIDAD, Color.new(128, 128, 128))
					end
				else
					Font.ftPrint(FONT_CNF, (CONTROL.ANCHO//2)+13, espacio_linea2, 0, 320, 21, nombres_opciones[elementos], Color.new(70, 70, 70))
					if elementos == 14 then
						Font.ftPrint(FONT_CNF, CONTROL.ANCHO-52, espacio_linea2, 0, 320, 21, CONTROL.CUSTOM_ANIM, Color.new(70, 70, 70))
					elseif elementos == 15 then
						Font.ftPrint(FONT_CNF, CONTROL.ANCHO-52, espacio_linea2, 0, 320, 21, CONTROL.ANIM_VELOCIDAD, Color.new(70, 70, 70))
					end
				end
			end

			-- Salir del submenú. -------------------------------------------------------
			if (Pads.check(PAD, PAD_SELECT) or Pads.check(PAD, PAD_TRIANGLE) or Pads.check(PAD, PAD_CIRCLE)) and CONTROL.JOYSTICK_ON == false then
				submenu = false
				if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then Sound.playADPCM(1, S_EJECUTAR) end
				selector_X_Y, selector_elementos = estado(selector_X_Y, selector_elementos, nil, estado_elementos_new)
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)

			-- Moverse entre los elementos del submenú. ---------------------------------
			elseif (Pads.check(PAD, PAD_DOWN) or Pads.check(PAD, PAD_UP) or Left_Y ~= 1) and CONTROL.JOYSTICK_ON == false then
				if (Pads.check(PAD, PAD_UP) or Left_Y <= -90) then
					selector_submenu = cambiar_valor(selector_submenu, 1, #nombres_opciones, 1, false)
				elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) then
					selector_submenu = cambiar_valor(selector_submenu, 1, #nombres_opciones, 1, true)
				end
				if OPCIONES.SOUND_ON == 1 and S_MOVER ~= nil then Sound.playADPCM(1, S_MOVER) end
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)

			-- Cambiar el estado de los elementos del submenú. --------------------------
			elseif (Pads.check(PAD, PAD_CROSS) or Pads.check(PAD, PAD_LEFT) or Pads.check(PAD, PAD_RIGHT) or Left_X ~= 1) and CONTROL.JOYSTICK_ON == false then
				-- Activar / desactivar elemento. ---------------------------------------
				if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then Sound.playADPCM(1, S_EJECUTAR) end
				if ((Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) or Pads.check(PAD, PAD_CROSS)) and selector_submenu <= 13 then
					if estado_elementos_new[selector_submenu] == false then
						estado_elementos_new[selector_submenu] = true
					else
						estado_elementos_new[selector_submenu] = false
					end

				-- Vista previa de la animación de transición. --------------------------
				elseif Pads.check(PAD, PAD_CROSS) and selector_submenu == 14 then
					animaciones(true)

				-- Cambiar entre las animaciones de transición disponibles. -------------
				elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and selector_submenu == 14 then
					CONTROL.CUSTOM_ANIM = cambiar_valor(CONTROL.CUSTOM_ANIM, 1, 8, 1, false)
				elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and selector_submenu == 14 then
					CONTROL.CUSTOM_ANIM = cambiar_valor(CONTROL.CUSTOM_ANIM, 1, 8, 1, true)

				-- Cambiar la velocidad de las animaciones de transición. ---------------
				elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and selector_submenu == 15 then
					CONTROL.ANIM_VELOCIDAD = cambiar_valor(CONTROL.ANIM_VELOCIDAD, 10, 50, 1, false)
				elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and selector_submenu == 15 then
					CONTROL.ANIM_VELOCIDAD = cambiar_valor(CONTROL.ANIM_VELOCIDAD, 10, 50, 1, true)

				-- Reiniciar todas las posiciones y tamaños a los de por defecto. -------
				elseif Pads.check(PAD, PAD_CROSS) and selector_submenu == 16 then
					local confirmar = false
					local pregunta_res = true
					Graphics.drawRect(0, 160+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, 104, Color.new(128, 128, 128))
					Graphics.drawRect(0, 162+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, 100, Color.new(0, 0, 0))
					Font.ftPrint(FONT_CNF, (CONTROL.ANCHO//2), (162+8)+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 25, "- RESET ALL ELEMENTS? -", COLOR.BLANCO)
					Graphics.drawScaleImage(PAD_IMG.SQUARE, 300-35, 195+CONTROL.Y_FIX_PAL, 20, 20)
					Font.ftPrint(FONT_CNF, 290, 195+CONTROL.Y_FIX_PAL, 0, 160, 25, "RESET", COLOR.BLANCO)
					Graphics.drawScaleImage(PAD_IMG.CIRCLE, 300-35, 219+CONTROL.Y_FIX_PAL, 20, 20)
					Font.ftPrint(FONT_CNF, 290, 219+CONTROL.Y_FIX_PAL, 0, 160, 25, "CANCEL", COLOR.BLANCO)
					refrescar(false)
					while pregunta_res do
						capturar(JOYSTICK_LIMITE)
						if Pads.check(PAD, PAD_SQUARE) then
							confirmar = true
							pregunta_res = false
							if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then Sound.playADPCM(1, S_EJECUTAR) end
						elseif Pads.check(PAD, PAD_CIRCLE) then
							confirmar = false
							pregunta_res = false
							if OPCIONES.SOUND_ON == 1 and S_CANCELAR ~= nil then Sound.playADPCM(1, S_CANCELAR) end
						end
						refrescar(true)
					end
					if confirmar == true then
						for restaura = 1, #elementos_pos_new do
							elementos_pos_new[restaura] = restaura_pos[restaura]
						end
						for restaura2 = 1, #elementos_tam_new do
							elementos_tam_new[restaura2] = restaura_tam[restaura2]
						end
						for restaura3 = 1, #estado_elementos_new do
							estado_elementos_new[restaura3] = restaura_estado[restaura3]
						end
						largo_lista = LISTAS.ELEMENTOS_LIST
						CONTROL.CUSTOM_ANIM, CONTROL.ANIM_VELOCIDAD = anterior_anim, anterior_anim_vel
					end

				-- Guardar configuración. -----------------------------------------------
				elseif Pads.check(PAD, PAD_CROSS) and selector_submenu == 17 then
					if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then Sound.playADPCM(1, S_EJECUTAR) end
					local aplicar = guardar_style(estado_elementos_new, elementos_pos_new, elementos_tam_new, largo_lista, FONT_CNF)
					if aplicar == true then
						for actualiza = 1, #elementos_pos_new do
							elementos_pos_ant[actualiza] = elementos_pos_new[actualiza]
						end
						for actualiza2 = 1, #elementos_tam_new do
							elementos_tam_ant[actualiza2] = elementos_tam_new[actualiza2]
						end
						for actualiza3 = 1, #estado_elementos_new do
							estado_elementos_ant[actualiza3] = estado_elementos_new[actualiza3]
						end
						anterior_anim, anterior_anim_vel = CONTROL.CUSTOM_ANIM, CONTROL.ANIM_VELOCIDAD
						change_detector = true
					end

				-- Salir del editor. ----------------------------------------------------
				elseif Pads.check(PAD, PAD_CROSS) and selector_submenu == 18 then
					salida = true
				end
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)
			end
		end

		-- Confirmar la salida del editor. ----------------------------------------------
		if salida == true then
			if OPCIONES.SOUND_ON == 1 and S_CANCELAR ~= nil then Sound.playADPCM(1, S_CANCELAR) end
			local cambio_realizado = false
			for chequeo1 = 1, #estado_elementos_new do
				if estado_elementos_new[chequeo1] ~= estado_elementos_ant[chequeo1] then cambio_realizado = true end
			end
			for chequeo2 = 1, #elementos_pos_new do
				if elementos_pos_new[chequeo2] ~= elementos_pos_ant[chequeo2] then cambio_realizado = true end
			end
			for chequeo3 = 1, #elementos_tam_new do
				if elementos_tam_new[chequeo3] ~= elementos_tam_ant[chequeo3] then cambio_realizado = true end
			end
			if CONTROL.CUSTOM_ANIM ~= anterior_anim or CONTROL.ANIM_VELOCIDAD ~= anterior_anim_vel then cambio_realizado = true end
			if cambio_realizado == true then
				local pregunta = true
				local message_exit = {"UNSAVED CHANGES DO YOU WANT TO EXIT?", "EXIT", "CANCEL"}
				Graphics.drawRect(0, 160+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, 114, Color.new(128, 128, 128))
				Graphics.drawRect(0, 162+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, 110, Color.new(0, 0, 0))
				Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), (162+8)+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 88, message_exit[1], COLOR.BLANCO)
				Graphics.drawScaleImage(PAD_IMG.SQUARE, 300-35, 195+CONTROL.Y_FIX_PAL, 20, 20)
				Font.ftPrint(CONTROL.fontARCA, 300, 195+CONTROL.Y_FIX_PAL, 0, 160, 24, message_exit[2], COLOR.BLANCO)
				Graphics.drawScaleImage(PAD_IMG.TRIANGLE, 300-35, 219+CONTROL.Y_FIX_PAL, 20, 20)
				Font.ftPrint(CONTROL.fontARCA, 300, 219+CONTROL.Y_FIX_PAL, 0, 160, 24, message_exit[3], COLOR.BLANCO)
				Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 246+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 50, "All changes made will be lost upon reboot.", COLOR.BLANCO)
				refrescar(false)
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					if Pads.check(PAD, PAD_SQUARE) then
						CONTROL.CUSTOM_ANIM, CONTROL.ANIM_VELOCIDAD = anterior_anim, anterior_anim_vel
						editar = false
						pregunta = false
					elseif Pads.check(PAD, PAD_TRIANGLE) then
						if OPCIONES.SOUND_ON == 1 and S_CANCELAR ~= nil then Sound.playADPCM(1, S_CANCELAR) end
						pregunta = false
						salida = false
					end
					refrescar(true)
				end
			else
				editar = false
			end
			CONTROL.JOYSTICK_ON = true
			JOYSTICK_LIMITE = control_FPS(1)
		end

		-- Asegura que al menos una representación de listas esté activa. ---------------
		if estado_elementos_new[4] == true or estado_elementos_new[1] == false then
			estado_elementos_new[1] = false
			estado_elementos_new[2] = true
			elementos_pos_new[1], elementos_pos_new[2] = elementos_pos_new[3]-28, (elementos_pos_new[4]+elementos_tam_new[4])+14
			elementos_tam_new[1], elementos_tam_new[2] = elementos_tam_new[3]+(28*2), 50
		end
		refrescar(false)
	end
	-- Limpiar y restaurar tamaños en fuentes de texto. ---------------------------------
	Font.ftUnload(FONT_CNF)
	Font.ftSetPixelSize(CONTROL.fontARCA, OPCIONES.FONT_PIXEL_X, OPCIONES.FONT_PIXEL_Y)
	Font.ftSetPixelSize(CONTROL.fontABC, 70, 70)
	return change_detector
end

--- Líneas para cargar el estilo personalizado. -----------------------------------------
function cargar_style(fix_pal)
	local actual = System.currentDirectory()
	-- Cargar opciones guardadas. -------------------------------------------------------
	if doesFileExist(actual .."/System/Config/style.cfg") then
		local carga_de_style = System.openFile(actual .."/System/Config/style.cfg", FREAD)
		System.seekFile(carga_de_style, 0, SET)
		local size_config = System.sizeFile(carga_de_style)
		local temp2 = System.readFile(carga_de_style, size_config)
		local lista_style = {}
		for linea in string.gmatch(temp2, "%d+") do
			table.insert(lista_style, tonumber(linea))
		end
		if lista_style ~= nil and #lista_style == 56 then
			CONTROL.IMG_ANCHO = lista_style[1]; CONTROL.IMG_X = lista_style[2];
			CONTROL.IMG_ALTO = lista_style[3]; CONTROL.IMG_Y = lista_style[4];
			CONTROL.IMG_ANCHO_2 = lista_style[5]; CONTROL.IMG_X_2 = lista_style[6];
			CONTROL.IMG_ALTO_2 = lista_style[7]; CONTROL.IMG_Y_2 = lista_style[8];
			CONTROL.LISTA_ANCHO = lista_style[9]; CONTROL.LISTA_X = lista_style[10];
			CONTROL.LISTA_ALTO = lista_style[11]; CONTROL.LISTA_Y = lista_style[12];
			CONTROL.LOGO_ANCHO = lista_style[13]; CONTROL.LOGO_X = lista_style[14];
			CONTROL.LOGO_ALTO = lista_style[15]; CONTROL.LOGO_Y = lista_style[16];
			CONTROL.FLOW_ANCHO = lista_style[17]; CONTROL.FLOW_X = lista_style[18];
			CONTROL.FLOW_ALTO = lista_style[19]; CONTROL.FLOW_Y = lista_style[20];
			CONTROL.FLOW_ANCHO_2 = lista_style[21]; CONTROL.FLOW_X_2 = lista_style[22];
			CONTROL.FLOW_ALTO_2 = lista_style[23]; CONTROL.FLOW_Y_2 = lista_style[24];
			CONTROL.X_BUTTON_X = lista_style[25]; CONTROL.Y_BUTTON_X = lista_style[26];
			CONTROL.X_BUTTON_T = lista_style[27]; CONTROL.Y_BUTTON_T = lista_style[28];
			CONTROL.X_BUTTON_S = lista_style[29]; CONTROL.Y_BUTTON_S = lista_style[30];
			CONTROL.X_BUTTON_L1 = lista_style[31]; CONTROL.Y_BUTTON_L1 = lista_style[32];
			CONTROL.X_BUTTON_R1 = lista_style[33]; CONTROL.Y_BUTTON_R1 = lista_style[34];
			CONTROL.X_BUTTON_R3 = lista_style[35]; CONTROL.Y_BUTTON_R3 = lista_style[36];
			CONTROL.X_BUTTON_STA = lista_style[37]; CONTROL.Y_BUTTON_STA = lista_style[38];
			CONTROL.X_BUTTON_SEL = lista_style[39]; CONTROL.Y_BUTTON_SEL = lista_style[40];
			if lista_style[41] <= 8 and lista_style[1] >= 1 then
				CONTROL.CUSTOM_ANIM = lista_style[41];
			else
				CONTROL.CUSTOM_ANIM = 1;
			end
			if lista_style[42] <= 50 and lista_style[1] >= 10 then
				CONTROL.ANIM_VELOCIDAD = lista_style[42];
			else
				CONTROL.ANIM_VELOCIDAD = 29;
			end
			if lista_style[43] == 1 then CONTROL.CUSTOM_LIST = true else CONTROL.CUSTOM_LIST = false end
			if lista_style[44] == 1 then CONTROL.CUSTOM_ART1 = true else CONTROL.CUSTOM_ART1 = false end
			if lista_style[45] == 1 then CONTROL.CUSTOM_ART2 = true else CONTROL.CUSTOM_ART2 = false end
			if lista_style[46] == 1 then CONTROL.CUSTOM_FLOW = true else CONTROL.CUSTOM_FLOW = false end
			if lista_style[47] == 1 then CONTROL.CUSTOM_LOGO = true else CONTROL.CUSTOM_LOGO = false end
			if lista_style[48] == 1 then CONTROL.CUSTOM_BUTTON_X = true else CONTROL.CUSTOM_BUTTON_X = false end
			if lista_style[49] == 1 then CONTROL.CUSTOM_BUTTON_T = true else CONTROL.CUSTOM_BUTTON_T = false end
			if lista_style[50] == 1 then CONTROL.CUSTOM_BUTTON_S = true else CONTROL.CUSTOM_BUTTON_S = false end
			if lista_style[51] == 1 then CONTROL.CUSTOM_BUTTON_L1 = true else CONTROL.CUSTOM_BUTTON_L1 = false end
			if lista_style[52] == 1 then CONTROL.CUSTOM_BUTTON_R1 = true else CONTROL.CUSTOM_BUTTON_R1 = false end
			if lista_style[53] == 1 then CONTROL.CUSTOM_BUTTON_R3 = true else CONTROL.CUSTOM_BUTTON_R3 = false end
			if lista_style[54] == 1 then CONTROL.CUSTOM_BUTTON_STA = true else CONTROL.CUSTOM_BUTTON_STA = false end
			if lista_style[55] == 1 then CONTROL.CUSTOM_BUTTON_SEL = true else CONTROL.CUSTOM_BUTTON_SEL = false end
			LISTAS.ELEMENTOS_LIST = lista_style[56];
		else
			CONTROL.IMG_ANCHO = 358; CONTROL.IMG_X = 250; CONTROL.IMG_ALTO = 92; CONTROL.IMG_Y = 193;
			CONTROL.IMG_ANCHO_2 = 358; CONTROL.IMG_X_2 = 250; CONTROL.IMG_ALTO_2 = 92; CONTROL.IMG_Y_2 = 193;
			CONTROL.LISTA_ANCHO = 30; CONTROL.LISTA_X = 310; CONTROL.LISTA_ALTO = 90; CONTROL.LISTA_Y = 290;
			CONTROL.LOGO_ANCHO = 194; CONTROL.LOGO_X = 252; CONTROL.LOGO_ALTO = 5; CONTROL.LOGO_Y = 76;
			CONTROL.FLOW_ANCHO = 30; CONTROL.FLOW_X = 160; CONTROL.FLOW_ALTO = 92; CONTROL.FLOW_Y = 103;
			CONTROL.FLOW_ANCHO_2 = 30; CONTROL.FLOW_X_2 = 160; CONTROL.FLOW_ALTO_2 = 92; CONTROL.FLOW_Y_2 = 103;
			CONTROL.X_BUTTON_X = 270; CONTROL.Y_BUTTON_X = 391; CONTROL.X_BUTTON_T = 40; CONTROL.Y_BUTTON_T = 391;
			CONTROL.X_BUTTON_S = 475; CONTROL.Y_BUTTON_S = 391; CONTROL.X_BUTTON_L1 = 144; CONTROL.Y_BUTTON_L1 = 28;
			CONTROL.X_BUTTON_R1 = 464; CONTROL.Y_BUTTON_R1 = 28; CONTROL.X_BUTTON_R3 = 260; CONTROL.Y_BUTTON_R3 = 391;
			CONTROL.X_BUTTON_STA = 423; CONTROL.Y_BUTTON_STA = 415; CONTROL.X_BUTTON_SEL = 45; CONTROL.Y_BUTTON_SEL = 415;
			CONTROL.CUSTOM_ANIM = 1; CONTROL.ANIM_VELOCIDAD = 29;
			CONTROL.CUSTOM_LIST = true; CONTROL.CUSTOM_ART1 = true; CONTROL.CUSTOM_ART2 = false;
			CONTROL.CUSTOM_FLOW = false; CONTROL.CUSTOM_LOGO = true; CONTROL.CUSTOM_BUTTON_X = true;
			CONTROL.CUSTOM_BUTTON_T = true; CONTROL.CUSTOM_BUTTON_S = true; CONTROL.CUSTOM_BUTTON_L1 = true;
			CONTROL.CUSTOM_BUTTON_R1 = true; CONTROL.CUSTOM_BUTTON_R3 = true; CONTROL.CUSTOM_BUTTON_STA = true;
			CONTROL.CUSTOM_BUTTON_SEL = true;
			LISTAS.ELEMENTOS_LIST = 11;
		end
		System.closeFile(carga_de_style)
	else
		CONTROL.IMG_ANCHO = 358; CONTROL.IMG_X = 250; CONTROL.IMG_ALTO = 92; CONTROL.IMG_Y = 193;
		CONTROL.IMG_ANCHO_2 = 358; CONTROL.IMG_X_2 = 250; CONTROL.IMG_ALTO_2 = 92; CONTROL.IMG_Y_2 = 193;
		CONTROL.LISTA_ANCHO = 30; CONTROL.LISTA_X = 310; CONTROL.LISTA_ALTO = 90; CONTROL.LISTA_Y = 290;
		CONTROL.LOGO_ANCHO = 194; CONTROL.LOGO_X = 252; CONTROL.LOGO_ALTO = 5; CONTROL.LOGO_Y = 76;
		CONTROL.FLOW_ANCHO = 30; CONTROL.FLOW_X = 160; CONTROL.FLOW_ALTO = 92; CONTROL.FLOW_Y = 103;
		CONTROL.FLOW_ANCHO_2 = 30; CONTROL.FLOW_X_2 = 160; CONTROL.FLOW_ALTO_2 = 92; CONTROL.FLOW_Y_2 = 103;
		CONTROL.X_BUTTON_X = 270; CONTROL.Y_BUTTON_X = 391; CONTROL.X_BUTTON_T = 40; CONTROL.Y_BUTTON_T = 391;
		CONTROL.X_BUTTON_S = 475; CONTROL.Y_BUTTON_S = 391; CONTROL.X_BUTTON_L1 = 144; CONTROL.Y_BUTTON_L1 = 28;
		CONTROL.X_BUTTON_R1 = 464; CONTROL.Y_BUTTON_R1 = 28; CONTROL.X_BUTTON_R3 = 260; CONTROL.Y_BUTTON_R3 = 391;
		CONTROL.X_BUTTON_STA = 423; CONTROL.Y_BUTTON_STA = 415; CONTROL.X_BUTTON_SEL = 45; CONTROL.Y_BUTTON_SEL = 415;
		CONTROL.CUSTOM_ANIM = 1; CONTROL.ANIM_VELOCIDAD = 29;
		CONTROL.CUSTOM_LIST = true; CONTROL.CUSTOM_ART1 = true; CONTROL.CUSTOM_ART2 = false;
		CONTROL.CUSTOM_FLOW = false; CONTROL.CUSTOM_LOGO = true; CONTROL.CUSTOM_BUTTON_X = true;
		CONTROL.CUSTOM_BUTTON_T = true; CONTROL.CUSTOM_BUTTON_S = true; CONTROL.CUSTOM_BUTTON_L1 = true;
		CONTROL.CUSTOM_BUTTON_R1 = true; CONTROL.CUSTOM_BUTTON_R3 = true; CONTROL.CUSTOM_BUTTON_STA = true;
		CONTROL.CUSTOM_BUTTON_SEL = true;
		LISTAS.ELEMENTOS_LIST = 11;
	end
	if fix_pal == true then
		CONTROL.LISTA_ALTO = CONTROL.LISTA_ALTO + CONTROL.Y_FIX_PAL
		CONTROL.IMG_ALTO = CONTROL.IMG_ALTO + CONTROL.Y_FIX_PAL
		CONTROL.LOGO_ALTO = CONTROL.LOGO_ALTO + CONTROL.Y_FIX_PAL
		CONTROL.IMG_ALTO_2 = CONTROL.IMG_ALTO_2 + CONTROL.Y_FIX_PAL
		CONTROL.FLOW_ALTO = CONTROL.FLOW_ALTO + CONTROL.Y_FIX_PAL
		CONTROL.FLOW_ALTO_2 = CONTROL.FLOW_ALTO_2 + CONTROL.Y_FIX_PAL
	end
end

--- Líneas para guardar el estilo personalizado. ----------------------------------------
function guardar_style(estado_elementos_new, elementos_pos_new, elementos_tam_new, largo_lista, FONT_CNF)
	local actual = System.currentDirectory()
	CONTROL.JOYSTICK_ON = true
	JOYSTICK_LIMITE = control_FPS(1)
	-- Confirmar el guardado. -----------------------------------------------------------
	local message_exit = {"SAVE CHANGES?", "SAVE", "CANCEL"}
	Graphics.drawRect(0, 160+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, 154, Color.new(128, 128, 128))
	Graphics.drawRect(0, 162+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, 150, Color.new(0, 0, 0))
	Font.ftPrint(FONT_CNF, (CONTROL.ANCHO//2), (162+8)+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 88, message_exit[1], COLOR.BLANCO)
	Graphics.drawScaleImage(PAD_IMG.SQUARE, 300-35, 195+CONTROL.Y_FIX_PAL, 20, 20)
	Font.ftPrint(FONT_CNF, 300, 195+CONTROL.Y_FIX_PAL, 0, 160, 24, message_exit[2], COLOR.BLANCO)
	Graphics.drawScaleImage(PAD_IMG.TRIANGLE, 300-35, 219+CONTROL.Y_FIX_PAL, 20, 20)
	Font.ftPrint(FONT_CNF, 300, 219+CONTROL.Y_FIX_PAL, 0, 160, 24, message_exit[3], COLOR.BLANCO)
	Font.ftPrint(FONT_CNF, (CONTROL.ANCHO//2), 246+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 20, "When saving, if a previous configuration", COLOR.BLANCO)
	Font.ftPrint(FONT_CNF, (CONTROL.ANCHO//2), 266+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 20, "exists, a backup of it will be created", COLOR.BLANCO)
	Font.ftPrint(FONT_CNF, (CONTROL.ANCHO//2), 286+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 20, "(replacing the last backup if it exists).", COLOR.BLANCO)
	refrescar(false)
	local confirmar = false
	local pregunta = true
	while pregunta do
		capturar(JOYSTICK_LIMITE)
		if Pads.check(PAD, PAD_TRIANGLE) then
			pregunta = false
			if OPCIONES.SOUND_ON == 1 and S_CANCELAR ~= nil then Sound.playADPCM(1, S_CANCELAR) end
		elseif Pads.check(PAD, PAD_SQUARE) then
			confirmar = true
			pregunta = false
			if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then Sound.playADPCM(1, S_EJECUTAR) end
		end
		refrescar(true)
	end

	-- Guardar la configuración. --------------------------------------------------------
	if confirmar == true then
		-- Reubicar posiciones de elementos desactivados. -------------------------------
		local n1, n2 = 1, 2
		if estado_elementos_new[1] == false then n1, n2 = 3, 4 end
		if estado_elementos_new[2] == false then
			elementos_pos_new[3], elementos_pos_new[4] = elementos_pos_new[n1], elementos_pos_new[n2]
			elementos_tam_new[3], elementos_tam_new[4] = elementos_tam_new[n1], elementos_tam_new[n2]
		end
		if estado_elementos_new[3] == false then
			elementos_pos_new[5], elementos_pos_new[6] = elementos_pos_new[n1], elementos_pos_new[n2]
			elementos_tam_new[5], elementos_tam_new[6] = elementos_tam_new[n1], elementos_tam_new[n2]
		end
		if estado_elementos_new[4] == false then
			elementos_pos_new[7], elementos_pos_new[8] = elementos_pos_new[n1], elementos_pos_new[n2]
			elementos_tam_new[7], elementos_tam_new[8] = elementos_tam_new[n1], elementos_tam_new[n2]
		end
		if estado_elementos_new[5] == false then
			elementos_pos_new[9], elementos_pos_new[10] = elementos_pos_new[n1], elementos_pos_new[n2]
			elementos_tam_new[9], elementos_tam_new[10] = elementos_tam_new[n1], elementos_tam_new[n2]
		end

		-- Convertir a número los elementos con valor booleano. -------------------------
		local estado_binario = {}
		for booleano = 1, #estado_elementos_new do
			if estado_elementos_new[booleano] == true then
				table.insert(estado_binario, "1")
			else
				table.insert(estado_binario, "0")
			end
		end

		-- Crear archivo de configuración para el estilo personalizado. -----------------
		local style_conf_final = ("".. elementos_pos_new[3] .." ".. elementos_tam_new[3] .." ".. elementos_pos_new[4] .." ".. elementos_tam_new[4] .." ".. elementos_pos_new[5] .." ".. elementos_tam_new[5] .." ".. elementos_pos_new[6] .." ".. elementos_tam_new[6] .." ".. elementos_pos_new[1] .." ".. elementos_tam_new[1] .." ".. elementos_pos_new[2] .." ".. elementos_tam_new[2] .." ".. elementos_pos_new[9] .." ".. elementos_tam_new[9] .." ".. elementos_pos_new[10] .." ".. elementos_tam_new[10] .." ".. elementos_pos_new[7] .." ".. elementos_tam_new[7] .." ".. elementos_pos_new[8] .." ".. elementos_tam_new[8] .." ".. (CONTROL.ANCHO-(elementos_pos_new[7]+elementos_tam_new[7])) .." ".. elementos_tam_new[7] .." ".. elementos_pos_new[8] .." ".. elementos_tam_new[8] .." ".. elementos_pos_new[11] .." ".. elementos_pos_new[12] .." ".. elementos_pos_new[13] .." ".. elementos_pos_new[14] .." ".. elementos_pos_new[15] .." ".. elementos_pos_new[16] .." ".. elementos_pos_new[17] .." ".. elementos_pos_new[18] .." ".. elementos_pos_new[19] .." ".. elementos_pos_new[18] .." ".. elementos_pos_new[21] .." ".. elementos_pos_new[22] .." ".. elementos_pos_new[23] .." ".. elementos_pos_new[24] .." ".. elementos_pos_new[25] .." ".. elementos_pos_new[26] .." ".. CONTROL.CUSTOM_ANIM .." ".. CONTROL.ANIM_VELOCIDAD .." ".. estado_binario[1] .." ".. estado_binario[2] .." ".. estado_binario[3] .." ".. estado_binario[4] .." ".. estado_binario[5] .." ".. estado_binario[6] .." ".. estado_binario[7] .." ".. estado_binario[8] .." ".. estado_binario[9] .." ".. estado_binario[10] .." ".. estado_binario[11] .." ".. estado_binario[12] .." ".. estado_binario[13] .." ".. largo_lista-1 .."                                                                                                    ")

		-- Guardar archivo nuevo y crear respaldo del anterior. -------------------------
		if doesFileExist(actual .."/System/Config/style.cfg") then
			if doesFileExist(actual .."/System/Config/style_old.cfg") then
				System.removeFile(actual .."/System/Config/style_old.cfg")
			end
			System.rename(actual .."/System/Config/style.cfg", actual .."/System/Config/style_old.cfg")
		end
		local crear_style = System.openFile(actual .."/System/Config/style.cfg", FCREATE)
		System.writeFile(crear_style, style_conf_final, string.len(style_conf_final))
		System.closeFile(crear_style)
	end
	return confirmar
end
--[[------------------SPAGHETTICODE-------------------]]--