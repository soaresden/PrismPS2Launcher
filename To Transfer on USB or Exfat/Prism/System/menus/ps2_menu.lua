-- Prism PS2 Launcher - menus/ps2_menu.lua
-- PlayStation 2: OPL and Neutrino per-game configuration.
-- Split from the original funciones.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Functions are globals; this file only defines them. Loaded by System/system.lua.

--- Menú de configuración PS2 (OPL). ----------------------------------------------------
function opl_config(nombre_iso, ps2_menu, dir_iso)
	Pads.rumble(0, 0, 0)
	local actual = System.currentDirectory()
	local device = salida_texto_dir(actual, nil)

	-- Buscar y cargar configuraciones existentes (OPL). --------------------------------
	local menu_opl, lista_config, lista_config_new, selector = true, {}, {}, 1
	local VMCD_o, MODE_o, GSM_o = nil, nil, nil
	submenu_selector({}, nil, TEXT_M_PS2[1], 160, 214, true, CONTROL.ANCHO//2, {}, false, true, {}, nil)
	local nombre_juego, id_iso = id_opl(dir_iso, nombre_iso, false)
	local lista_comparar_config = {"$VMC_0=", "$Compatibility=", "$EnableGSM=", "$GSMVMode=", "$GSMXOffset=", "$GSMYOffset="}
	if id_iso ~= nil and doesFileExist(device .."/CFG/".. id_iso ..".cfg") then
		local opl_cfg = System.openFile(device .."/CFG/".. id_iso ..".cfg", FREAD)
		System.seekFile(opl_cfg, 0, SET)
		local size_config = System.sizeFile(opl_cfg)
		local temp = System.readFile(opl_cfg, size_config)
		System.closeFile(opl_cfg)
		lista_config = sub_string(temp, "[^\r\n]+", lista_config, false)
		if lista_config ~= nil and #lista_config >= 1 then
			for cont = 1, #lista_comparar_config do
				local presente = false
				for cont2 = 1, #lista_config do
					if string.match(lista_config[cont2], lista_comparar_config[cont]) then
						table.insert(lista_config_new, lista_config[cont2])
						presente = true
						break
					end
				end
				if presente == false then
					lista_config_new[cont] = "nil"
				end
			end
		end
	elseif id_iso ~= nil then
		lista_config_new = lista_comparar_config
	else
		menu_opl = false
	end

	-- Cargar configuración de "VMC" (OPL). ---------------------------------------------
	if menu_opl == true then
		if string.match(lista_config_new[1], "$VMC_%d=.+") then
			VMCD_o = lista_config_new[1]
		else
			VMCD_o = nil
		end
	end
	local VMC_encontradas = buscar_VMC(1)
	local selector_VMC = 1
	if #VMC_encontradas <= 0 then
		selector_VMC = 0
	elseif #VMC_encontradas >= 1 and VMCD_o ~= nil then
		for contador = 1, #VMC_encontradas do
			if string.lower(VMC_encontradas[contador]) == string.lower(device .."/VMC/".. string.sub(VMCD_o, 8) ..".bin") then
				selector_VMC = contador
				break
			end
		end
	end
	local encontrado_vmcd = 0
	if VMCD_o ~= nil then
		encontrado_vmcd = 1
	end

	-- Cargar modos de compatibilidad (OPL). --------------------------------------------
	local m_l = {1, 2, 4, 8, 16, 32}
	local modo_1, modo_2, modo_3, modo_4, modo_5, modo_6 = 0, 0, 0, 0, 0, 0
	if menu_opl == true then
		if string.match(lista_config_new[2], "$Compatibility=%d+") then
			MODE_o = lista_config_new[2]
		else
			MODE_o = nil
		end
	end
	if MODE_o ~= nil then
		local resultado, encontrado = tonumber(string.sub(lista_config_new[2], 16)), false
		for m1 = 0, 1 do
			modo_1 = m1
			if m1 == 1 then m_l[1] = 1 else m_l[1] = 0 end
			for m2 = 0, 1 do
				modo_2 = m2
				if m2 == 1 then m_l[2] = 2 else m_l[2] = 0 end
				for m3 = 0, 1 do
					modo_3 = m3
					if m3 == 1 then m_l[3] = 4 else m_l[3] = 0 end
					for m4 = 0, 1 do
						modo_4 = m4
						if m4 == 1 then m_l[4] = 8 else m_l[4] = 0 end
						for m5 = 0, 1 do
							modo_5 = m5
							if m5 == 1 then m_l[5] = 16 else m_l[5] = 0 end
							for m6 = 0, 1 do
								modo_6 = m6
								if m6 == 1 then m_l[6] = 32 else m_l[6] = 0 end
								if m_l[1]+m_l[2]+m_l[3]+m_l[4]+m_l[5]+m_l[6] == resultado then
									encontrado = true
								end
								if encontrado == true then break end
							end
							if encontrado == true then break end
						end
						if encontrado == true then break end
					end
					if encontrado == true then break end
				end
				if encontrado == true then break end
			end
			if encontrado == true then break end
		end
		m_l = {1, 2, 4, 8, 16, 32}
	end

	-- Cargar modos de "GMS" (OPL). -----------------------------------------------------
	local gsm_x_fix, gsm_y_fix = 0, 0
	if menu_opl == true then
		if string.match(lista_config_new[3], "$EnableGSM=1") then
			if string.match(lista_config_new[4], "$GSMVMode=%d+") then
				GSM_o = tonumber(string.sub(lista_config_new[4], 11))
			else
				GSM_o = 0
			end
			if string.match(lista_config_new[5], "$GSMXOffset=%-?%d+") then
				gsm_x_fix = tonumber(string.sub(lista_config_new[5], 13))
			else
				gsm_x_fix = 0
			end
			if string.match(lista_config_new[6], "$GSMYOffset=%-?%d+") then
				gsm_y_fix = tonumber(string.sub(lista_config_new[6], 13))
			else
				gsm_y_fix = 0
			end
		else
			GSM_o = nil
		end
	end
	local activar_gsm, selector_gsm = 0, 0
	if GSM_o ~= nil then
		activar_gsm, selector_gsm = 1, GSM_o
	end

	-- Nombres de las opciones del menú y sus estados (OPL). ----------------------------
	local menus_nombres = {TEXT_M_PS2[2]; TEXT_M_PS2[3]; "-".. TEXT_M_PS2[4] .."-"; TEXT_M_PS2[20]; TEXT_M_PS2[21]; TEXT_M_PS2[22];
	TEXT_M_PS2[23]; TEXT_M_PS2[24]; TEXT_M_PS2[25]; TEXT_M_PS2[11]; " "; TEXT_M_PS2[26]; TEXT_M_PS2[27];};
	local gsm_nombres = {"NTSC"; "NTSC Non interlaced"; "PAL"; "PAL Non interlaced"; "PAL 60Hz"; "PAL 60Hz Non interlaced";
	"PS1 NTSC (HDTV 480P 60Hz)"; "PS1 PAL (HDTV 576P 50Hz)"; "HDTV 480P 60Hz"; "HDTV 576P 50Hz"; "HDTV 720P 60Hz"; "HDTV 1080i 60Hz";
	"HDTV 1080i 60Hz NON INTERLACED"; "VGA 640x480p 60hz"; "VGA 640x480p 72hz"; "VGA 640x480p 75hz"; "VGA 640x480p 85hz";
	"VGA 640x992i 60hz"; "VGA 800x600p 56hz"; "VGA 800x600p 60hz"; "VGA 800x600p 72hz"; "VGA 800x600p 75hz"; "VGA 800x600p 85hz";
	"VGA 1024x768p 60hz"; "VGA 1024x768p 70hz"; "VGA 1024x768p 75hz"; "VGA 1024x768p 85hz"; "VGA 1260x1024p 60hz"; "VGA 1260x1024p 75hz";};
	local menus_valores = {encontrado_vmcd, selector_VMC, 0, modo_1, modo_2, modo_3, modo_4, modo_5, modo_6, activar_gsm, selector_gsm, gsm_x_fix, gsm_y_fix}

	-- Ejecutar y controlar menú de configuración PS2 (OPL). ----------------------------
	while menu_opl do
		CONTROL.FPS = Screen.getFPS(1)
		capturar(JOYSTICK_LIMITE)

		-- Mostrar todo en pantalla (OPL). ----------------------------------------------
		dibujar_fondos()
		if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true and OPCIONES.SCREENSHOT_BACK_ON == 1 then
			Graphics.drawScaleImage(LISTAS.SCREENSHOT, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F, Color.new(128, 128, 128, OPCIONES.SCREENSHOT_BACK_TR))
		end
		Graphics.drawScaleImage(LISTAS.LOGO, (CONTROL.ANCHO//2)-(240//2), 0+CONTROL.Y_FIX_PAL, 240, 72)
		Graphics.drawRect(12, 67+CONTROL.Y_FIX_PAL, 615, 350, COLOR.NEGRO_T)
		Graphics.drawRect(12, 67+CONTROL.Y_FIX_PAL, 615, 43, COLOR.NEGRO_T)
		Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 70+CONTROL.Y_FIX_PAL, 8, 540, 25, "-".. TEXT_M_PRI[8] .." ".. TEXT_M_PS2[16] .."-", COLOR.BLANCO)
		Font.ftPrint(CONTROL.fontARCA, 22, 90+CONTROL.Y_FIX_PAL, 0, 600, 8, nombre_iso, COLOR.BLANCO)
		for contador = 1, #menus_nombres do
			local espacio_linea = 90+((contador)*23)+CONTROL.Y_FIX_PAL
			-- Las dos primeras lineas eran el ajuste de VMC de Boon, y se rellenaban
			-- aqui en cada fotograma. La tarjeta se elige ahora en el menu de
			-- lanzamiento; tener un segundo sitio que decia otra cosa sobre lo mismo
			-- es justo lo que hacia el conjunto incomprensible. Se quedan en blanco en
			-- vez de borrarse, para no correr la numeracion de todo lo que viene
			-- detras.
			menus_nombres[1] = " "
			menus_nombres[2] = " "
			-- Y el VALOR de la linea 1 tambien, que es lo que quedaba a la vista.
			--
			-- El menu de Neutrino pone menus_valores[1] a 0 al entrar; el de OPL no lo
			-- hacia, asi que se quedaba con lo que trajera la configuracion guardada.
			-- Con el rotulo en blanco pero el valor en 1, la linea salia vacia y con
			-- "activado" a la derecha, sin nada que dijera de que. A 0 desaparece el
			-- rotulo y ademas deja de escribirse la linea "$VMC_0=" al generar la
			-- configuracion de OPL, mas abajo.
			menus_valores[1] = 0
			local acti, fix_m = TEXT_GEN[13], 498
			if contador == 1 or contador == 2 then
				acti = " "
			elseif contador == 11 then
				acti, fix_m = gsm_nombres[menus_valores[contador]+1], 22
			elseif contador >= 12 then
				if menus_valores[contador] >= 1 then
					acti = "+".. tostring(menus_valores[contador])
				else
					acti = tostring(menus_valores[contador])
				end
			elseif menus_valores[contador] == 0 then
				acti = TEXT_GEN[14]
			end
			if contador == 10 then
				Graphics.drawRect(12, espacio_linea-2, 615, 23, COLOR.NEGRO_T)
			end
			if contador == selector and contador ~= 3 then
				Font.ftPrint(CONTROL.fontARCA, 22, espacio_linea, 0, 600, 25, menus_nombres[selector], CAMBIOS_EMUS.COLOR_EMU)
				Font.ftPrint(CONTROL.fontARCA, fix_m, espacio_linea, 0, 0, 25, acti, CAMBIOS_EMUS.COLOR_EMU)
			elseif contador ~= selector and contador ~= 3 then
				Font.ftPrint(CONTROL.fontARCA, 22, espacio_linea, 0, 600, 25, menus_nombres[contador], COLOR.BLANCO_LISTA)
				Font.ftPrint(CONTROL.fontARCA, fix_m, espacio_linea, 0, 0, 25, acti, COLOR.BLANCO_LISTA)
			elseif contador == 3 then
				Graphics.drawRect(12, espacio_linea-2, 615, 23, COLOR.NEGRO_T)
				Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), espacio_linea, 8, 0, 20, menus_nombres[contador], COLOR.BLANCO)
			end
		end
		Graphics.drawScaleImage(PAD_IMG.R1, (CONTROL.ANCHO//2)+(240//2)+(72-35), 70-5+CONTROL.Y_FIX_PAL, 34, 28)
		Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2)+(240//2)+(72+3), 70+CONTROL.Y_FIX_PAL, 0, 0, 25, TEXT_M_PS2[17], COLOR.BLANCO)
		if OPCIONES.GUI_LIMPIA_ON == 0 then
			dibujar_indicador(515, 422, TEXT_GEN[6], PAD_IMG.TRIANGLE, 20, 20, 5, true)
			dibujar_indicador(42, 422, TEXT_M_PS2[15], PAD_IMG.START, 22, 35, 4, true)
		end
		refrescar(false)

		-- Moverse por las opciones del menú (OPL). -------------------------------------
		if ((Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) or (Pads.check(PAD, PAD_UP) or Left_Y <= -90)) and CONTROL.JOYSTICK_ON == false then
			if selector == 2 and (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) then
				selector = selector+2
			elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) then
				selector = cambiar_valor(selector, 1, #menus_nombres, 1, true)
			elseif selector == 4 and (Pads.check(PAD, PAD_UP) or Left_Y <= -90) then
				selector = selector-2
			elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90) then
				selector = cambiar_valor(selector, 1, #menus_nombres, 1, false)
			end
			local kabal = 1 if Left_Y ~= 1 then
				kabal = 2
			end
			if kabal == 1 then
				repro_sfx(S_MOVER, 1, true, nil)
			end
			JOYSTICK_LIMITE = control_FPS(kabal)

		-- Cambiar configuraciones (OPL). -----------------------------------------------
		elseif Pads.check(PAD, PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_EJECUTAR, 1, false, nil)
			if selector == 2 and #VMC_encontradas >= 1 and menus_valores[1] == 1 then
				selector_VMC = cambiar_valor(selector_VMC, 1, #VMC_encontradas, 1, true)
			elseif selector == 2 and #VMC_encontradas <= 0 then
				selector_VMC = 0
			elseif selector == 11 then
				menus_valores[selector] = cambiar_valor(menus_valores[selector], 0, 28, 1, true)
			elseif selector >= 12 and selector <= 13 then
				menus_valores[selector] = cambiar_valor(menus_valores[selector], -100, 100, 1, true)
			else
				menus_valores[selector] = cambiar_valor(menus_valores[selector], 0, 1, 1, true)
			end
			JOYSTICK_LIMITE = control_FPS(1)
		elseif ((Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90)) and CONTROL.JOYSTICK_ON == false and ((selector >= 11 and selector <= 13) or selector == 2) then
			if selector == 2 and #VMC_encontradas >= 1 and menus_valores[1] == 1 and (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
				selector_VMC = cambiar_valor(selector_VMC, 1, #VMC_encontradas, 1, true)
			elseif selector == 2 and #VMC_encontradas >= 1 and menus_valores[1] == 1 and (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
				selector_VMC = cambiar_valor(selector_VMC, 1, #VMC_encontradas, 1, false)
			elseif selector == 2 and #VMC_encontradas <= 0 then
				selector_VMC = 0
			elseif selector == 11 and (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
				menus_valores[selector] = cambiar_valor(menus_valores[selector], 0, 28, 1, true)
			elseif selector == 11 and (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
				menus_valores[selector] = cambiar_valor(menus_valores[selector], 0, 28, 1, false)
			elseif selector >= 12 and selector <= 13 and (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
				menus_valores[selector] = cambiar_valor(menus_valores[selector], -100, 100, 1, true)
			elseif selector >= 12 and selector <= 13 and (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
				menus_valores[selector] = cambiar_valor(menus_valores[selector], -100, 100, 1, false)
			end
			local kabal = 1 if Left_X ~= 1 then
				kabal = 2
			end
			if kabal == 1 then
				repro_sfx(S_EJECUTAR, 1, true, nil)
			end
			JOYSTICK_LIMITE = control_FPS(kabal)

		-- Guardar configuraciones (OPL). -----------------------------------------------
		elseif Pads.check(PAD, PAD_START) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_EJECUTAR, 1, false, nil)

			-- Confirmar guardado (OPL). ------------------------------------------------
			local pregunta, confirmar, submenu_lista = true, false, {}
			JOYSTICK_LIMITE = control_FPS(1)
			submenu_lista = sub_string(TEXT_M_PS2[29], "[^\n]+", submenu_lista, false)
			while pregunta do
				CONTROL.FPS = Screen.getFPS(1)
				capturar(JOYSTICK_LIMITE)
				submenu_selector(submenu_lista, nil, TEXT_M_PS2[28], 138, 298, false, 14, {TEXT_GEN[12], TEXT_GEN[6]}, true, false, {}, nil)
				refrescar(false)
				if Pads.check(PAD, PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
					pregunta = false
					confirmar = true
				elseif Pads.check(PAD, PAD_CIRCLE) and CONTROL.JOYSTICK_ON == false then
					pregunta = false
					confirmar = false
				end
			end

			if confirmar == true then
				-- Mensaje de guardado (OPL). -------------------------------------------
				submenu_selector({}, nil, TEXT_M_PS2[19] .."...", 138, 298, true, CONTROL.ANCHO//2, {}, false, true, {}, nil)

				-- Borrar las configuraciones existentes (OPL). -------------------------
				if doesFileExist(device .."/CFG/".. id_iso ..".cfg") then
					System.removeFile(device .."/CFG/".. id_iso ..".cfg")
				end
				local ps2_config_final = lista_config
				for cont = 1, #lista_comparar_config do
					for cont2 = 1, #ps2_config_final do
						if string.match(ps2_config_final[cont2], lista_comparar_config[cont]) then
							table.remove(ps2_config_final, cont2)
							break
						end
					end
				end

				-- Generar configuración de "VMC" (OPL). --------------------------------
				if menus_valores[1] == 1 and #VMC_encontradas >= 1 then
					lista_config_new[1] = "$VMC_0=".. string.sub(VMC_encontradas[selector_VMC], 11, -5)
				else
					lista_config_new[1] = "nil"
				end

				-- Generar configuración de compatibilidad (OPL). -----------------------
				if menus_valores[4] == 1 then m_l[1] = 1 else m_l[1] = 0 end
				if menus_valores[5] == 1 then m_l[2] = 2 else m_l[2] = 0 end
				if menus_valores[6] == 1 then m_l[3] = 4 else m_l[3] = 0 end
				if menus_valores[7] == 1 then m_l[4] = 8 else m_l[4] = 0 end
				if menus_valores[8] == 1 then m_l[5] = 16 else m_l[5] = 0 end
				if menus_valores[9] == 1 then m_l[6] = 32 else m_l[6] = 0 end
				local modo_c_final = m_l[1]+m_l[2]+m_l[3]+m_l[4]+m_l[5]+m_l[6]
				if modo_c_final >= 1 then
					lista_config_new[2] = "$Compatibility=".. tostring(modo_c_final)
				else
					lista_config_new[2] = "nil"
				end

				-- Generar configuración de "GSM" (OPL). --------------------------------
				if menus_valores[10] == 1 then
					lista_config_new[3] = "$EnableGSM=1"
					if menus_valores[11] >= 1 then
						lista_config_new[4] = "$GSMVMode=".. tostring(menus_valores[11])
					else
						lista_config_new[4] = "nil"
					end
					if menus_valores[12] ~= 0 then
						lista_config_new[5] = "$GSMXOffset=".. tostring(menus_valores[12])
					else
						lista_config_new[5] = "nil"
					end
					if menus_valores[13] ~= 0 then
						lista_config_new[6] = "$GSMYOffset=".. tostring(menus_valores[13])
					else
						lista_config_new[6] = "nil"
					end
				else
					lista_config_new[3] = "nil"
					lista_config_new[4] = "nil"
					lista_config_new[5] = "nil"
					lista_config_new[6] = "nil"
				end
				local source1, source2, pos_s = false, false, 1
				for cont = 1, #ps2_config_final do
					if string.match(ps2_config_final[cont], "$ConfigSource=1") then
						source1 = true
					end
					if string.match(ps2_config_final[cont], "$GSMSource=1") then
						source2, pos_s = true, cont
					end
				end
				if source1 == false then table.insert(ps2_config_final, "$ConfigSource=1") end
				if source2 == false and menus_valores[10] == 1 then table.insert(ps2_config_final, "$GSMSource=1") end
				if source2 == true and menus_valores[10] == 0 then table.remove(ps2_config_final, pos_s) end

				-- Crear el archivo de configuración del juego (OPL). -------------------
				for cont = 1, #lista_config_new do
					if lista_config_new[cont] ~= "nil" then
						table.insert(ps2_config_final, lista_config_new[cont])
					end
				end
				if ps2_config_final ~= nil and #ps2_config_final >= 1 then
					local config_ps2 = System.openFile(device .."/CFG/".. id_iso ..".cfg", FCREATE)
					local ps2_data = ""
					for cont = 1, #ps2_config_final do
						if cont == 1 then
							ps2_data = ps2_config_final[cont] .."\r\n"
						else
							ps2_data = ps2_data .. ps2_config_final[cont] .."\r\n"
						end
					end
					System.writeFile(config_ps2, ps2_data, string.len(ps2_data))
					System.closeFile(config_ps2)
				end
				ps2_menu = false
				menu_opl = false
				JOYSTICK_LIMITE = control_FPS(1)-16
			else
				JOYSTICK_LIMITE = control_FPS(1)
			end

		-- Abrir menú de configuración para Neutrino. -----------------------------------
		elseif Pads.check(PAD, PAD_R1) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_EJECUTAR, 1, false, nil)
			menu_opl = false
			ps2_menu = true
			JOYSTICK_LIMITE = control_FPS(1)

		-- Cancelar configuración y salir del menú (OPL). -------------------------------
		elseif Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_CANCELAR, 1, false, nil)
			menu_opl = false
			ps2_menu = false
			JOYSTICK_LIMITE = control_FPS(1)-16
		end
	end
	return ps2_menu
end

--- Menú de configuración PS2 (Neutrino). -----------------------------------------------
function menu_neutrino(nombre_iso)
	Pads.rumble(0, 0, 0)
	local cambio_ani, n_ani = true, 45
	local actual = System.currentDirectory()
	local device = salida_texto_dir(actual, nil)
	local selector, ps2_menu, mode_menu = 1, true, false
	local dir_iso = nil
	if doesFileExist(device .."/DVD/".. nombre_iso) == true then
		dir_iso = device .."/DVD/"
	elseif doesFileExist(device .."/CD/".. nombre_iso) == true then
		dir_iso = device .."/CD/"
	end

	-- Buscar archivos de configuración del juego (Neutrino). ---------------------------
	OPCIONES.PREGUNTAR_PS2 = true
	local VMCD, MODE, GSM, SOPORTE = ejecutar_iso(nombre_iso)
	OPCIONES.PREGUNTAR_PS2 = false

	-- Cargar configuración de "VMC" (Neutrino). ----------------------------------------
	local tipo = 1
	if string.lower(string.sub(nombre_iso, -4)) == ".iso" then
		tipo, mode_menu = 1, true
	elseif string.lower(string.sub(nombre_iso, -4)) == ".mx4" then
		tipo = 2
	elseif string.lower(string.sub(nombre_iso, -4)) == ".hdd" then
		tipo = 3
	elseif string.lower(string.sub(nombre_iso, -4)) == ".mmc" then
		tipo = 4
	elseif string.lower(string.sub(nombre_iso, -4)) == ".udp" then
		tipo = 5
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
	if VMCD ~= nil then
		encontrado_vmcd = 1
	end

	-- Cargar modos de compatibilidad (Neutrino). ---------------------------------------
	local modo_0, modo_1, modo_2, modo_3, modo_5, modo_7 = 0, 0, 0, 0, 0, 0
	if MODE ~= nil then
		if string.match(MODE, "0") == "0" then
			modo_0 = 1
		end
		if string.match(MODE, "1") == "1" then
			modo_1 = 1
		end
		if string.match(MODE, "2") == "2" then
			modo_2 = 1
		end
		if string.match(MODE, "3") == "3" then
			modo_3 = 1
		end
		if string.match(MODE, "5") == "5" then
			modo_5 = 1
		end
		if string.match(MODE, "7") == "7" then
			modo_7 = 1
		end
	end

	-- Cargar modos de "GMS" (Neutrino). ------------------------------------------------
	local gsm_modes = {0, 0}
	local gsm_text_force = {TEXT_GEN[14], "240p/288p", "480p/576p", "1080i x 1", "1080i x 2", "1080i x 3"}
	local gsm_text_mode = {TEXT_GEN[14], "Field Flipping / 1", "Field Flipping / 2", "Field Flipping / 3"}
	if GSM ~= nil then
		if string.match(GSM, "=fp1") == "=fp1" then
			gsm_modes[1] = 1
		elseif string.match(GSM, "=fp2") == "=fp2" then
			gsm_modes[1] = 2
		elseif string.match(GSM, "=1080ix1") == "=1080ix1" then
			gsm_modes[1] = 3
		elseif string.match(GSM, "=1080ix2") == "=1080ix2" then
			gsm_modes[1] = 4
		elseif string.match(GSM, "=1080ix3") == "=1080ix3" then
			gsm_modes[1] = 5
		end
		if string.match(GSM, ":1") == ":1" then
			gsm_modes[2] = 1
		elseif string.match(GSM, ":2") == ":2" then
			gsm_modes[2] = 2
		elseif string.match(GSM, ":3") == ":3" then
			gsm_modes[2] = 3
		end
	end

	-- Cargar soporte de medios (Neutrino). ---------------------------------------------
	local sopor_m = 1
	local sopor_m_text = {" ", "+NET", "+HDD"}
	if SOPORTE ~= nil then
		if string.match(SOPORTE, "-net") then
			sopor_m = 2
		elseif string.match(SOPORTE, "-hdd") then
			sopor_m = 3
		end
	end

	-- Nombres de las opciones del menú y sus estados (Neutrino). -----------------------
	local menus_nombres = {TEXT_M_PS2[2]; TEXT_M_PS2[3]; "-".. TEXT_M_PS2[4] .."-"; TEXT_M_PS2[5]; TEXT_M_PS2[6]; TEXT_M_PS2[7]; TEXT_M_PS2[8];
	TEXT_M_PS2[9]; TEXT_M_PS2[10]; "-".. TEXT_M_PS2[11] .."-"; TEXT_M_PS2[12] ..":"; TEXT_M_PS2[13] ..":";};
	local menus_valores = {encontrado_vmcd, selector_VMC, 0, modo_0, modo_1, modo_2, modo_3, modo_5, modo_7, 0, gsm_modes[1], gsm_modes[2]}

	-- Las dos primeras lineas eran el ajuste de tarjeta virtual de este menu. Se
	-- desactivan: la tarjeta se elige en el menu del juego (TRIANGULO), donde se ve la
	-- ruta completa del fichero. Tener dos sitios para decidir lo mismo, cada uno con
	-- su forma de guardarlo, es lo que hacia el conjunto incomprensible.
	-- No se BORRAN las entradas para no correr toda la numeracion del controlador que
	-- viene despues; se vacian y se anula su valor, asi no hacen nada.
	menus_nombres[1] = " "
	menus_nombres[2] = " "
	menus_valores[1] = 0
	menus_valores[2] = 0

	-- Ejecutar y controlar menú de configuración PS2 (Neutrino). -----------------------
	while ps2_menu do
		CONTROL.FPS = Screen.getFPS(1)
		capturar(JOYSTICK_LIMITE)

		-- Mostrar todo en pantalla (Neutrino). -----------------------------------------
		dibujar_fondos()
		if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true and OPCIONES.SCREENSHOT_BACK_ON == 1 then
			Graphics.drawScaleImage(LISTAS.SCREENSHOT, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F, Color.new(128, 128, 128, OPCIONES.SCREENSHOT_BACK_TR))
		end
		Graphics.drawScaleImage(LISTAS.LOGO, (CONTROL.ANCHO//2)-(240//2), 0+CONTROL.Y_FIX_PAL, 240, 72)
		Graphics.drawRect(12, 67+CONTROL.Y_FIX_PAL, 615, 350, COLOR.NEGRO_T)
		Graphics.drawRect(12, 67+CONTROL.Y_FIX_PAL, 615, 43, COLOR.NEGRO_T)
		Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 70+CONTROL.Y_FIX_PAL, 8, 540, 25, "-".. TEXT_M_PRI[8] .." ".. TEXT_M_PS2[17] .."-", COLOR.BLANCO)
		Font.ftPrint(CONTROL.fontARCA, 22, 90+CONTROL.Y_FIX_PAL, 0, 600, 8, nombre_iso, COLOR.BLANCO)
		if mode_menu == true and dir_iso ~= nil then
			Graphics.drawScaleImage(PAD_IMG.R1, (CONTROL.ANCHO//2)+(240//2)+(138-35), 70-5+CONTROL.Y_FIX_PAL, 34, 28)
			Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2)+(240//2)+(138+3), 70+CONTROL.Y_FIX_PAL, 0, 0, 25, TEXT_M_PS2[16], COLOR.BLANCO)
		end
		if string.lower(string.sub(nombre_iso, -4)) == ".hdd" or string.lower(string.sub(nombre_iso, -4)) == ".udp" then
			Graphics.drawScaleImage(PAD_IMG.L1, (47-35), 70-5+CONTROL.Y_FIX_PAL, 34, 28)
			Font.ftPrint(CONTROL.fontARCA, (47+3), 70+CONTROL.Y_FIX_PAL, 0, 0, 25, sopor_m_text[sopor_m], COLOR.BLANCO)
		end
		if OPCIONES.GUI_LIMPIA_ON == 0 then
			dibujar_indicador(515, 422, TEXT_GEN[6], PAD_IMG.TRIANGLE, 20, 20, 5, true)
			dibujar_indicador(42, 422, TEXT_M_PS2[15], PAD_IMG.START, 22, 35, 4, true)
		end
		for contador = 1, #menus_nombres do
			local acti, x_fix = TEXT_GEN[13], 0
			if menus_valores[contador] == 0 then
				acti = TEXT_GEN[14]
			end
			if contador == 2 or contador == 3 or contador == 10 then
				acti = " "
			end
			if contador == 11 then
				acti = gsm_text_force[menus_valores[11]+1]
			elseif contador == 12 then
				acti = gsm_text_mode[menus_valores[12]+1]
			end
			if contador >= 11 and contador <= 13 then
				x_fix = 120
			end
			-- Las dos primeras lineas eran el ajuste de VMC de Boon, y se rellenaban
			-- aqui en cada fotograma. La tarjeta se elige ahora en el menu de
			-- lanzamiento; tener un segundo sitio que decia otra cosa sobre lo mismo
			-- es justo lo que hacia el conjunto incomprensible. Se quedan en blanco en
			-- vez de borrarse, para no correr la numeracion de todo lo que viene
			-- detras.
			menus_nombres[1] = " "
			menus_nombres[2] = " "
			local espacio_linea = 90+((contador)*23)+CONTROL.Y_FIX_PAL
			if contador == selector and contador ~= 3 and contador ~= 10 then
				Font.ftPrint(CONTROL.fontARCA, 22, espacio_linea, 0, 600, 25, menus_nombres[selector], CAMBIOS_EMUS.COLOR_EMU)
				Font.ftPrint(CONTROL.fontARCA, 498-x_fix, espacio_linea, 0, 0, 25, acti, CAMBIOS_EMUS.COLOR_EMU)
			elseif contador ~= selector and contador ~= 3 and contador ~= 10 then
				Font.ftPrint(CONTROL.fontARCA, 22, espacio_linea, 0, 600, 25, menus_nombres[contador], COLOR.BLANCO_LISTA)
				Font.ftPrint(CONTROL.fontARCA, 498-x_fix, espacio_linea, 0, 0, 25, acti, COLOR.BLANCO_LISTA)
			elseif contador == 3 or contador == 10 then
				Graphics.drawRect(12, espacio_linea-2, 615, 23, COLOR.NEGRO_T)
				Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), espacio_linea, 8, 0, 20, menus_nombres[contador], COLOR.BLANCO)
			end
		end
		if cambio_ani == true then
			cambio_ani, n_ani = intro_menu(cambio_ani, n_ani)
		end
		refrescar(false)

		-- Moverse por las opciones del menú (Neutrino). --------------------------------
		if cambio_ani == false then
		if ((Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) or (Pads.check(PAD, PAD_UP) or Left_Y <= -90)) and CONTROL.JOYSTICK_ON == false then
			if (selector == 2 or selector == 9) and (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) then
				selector = selector+2
			elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) then
				selector = cambiar_valor(selector, 1, #menus_nombres, 1, true)
			elseif (selector == 4 or selector == 11) and (Pads.check(PAD, PAD_UP) or Left_Y <= -90) then
				selector = selector-2
			elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90) then
				selector = cambiar_valor(selector, 1, #menus_nombres, 1, false)
			end
			local kabal = 1 if Left_Y ~= 1 then
				kabal = 2
			end
			if kabal == 1 then
				repro_sfx(S_MOVER, 1, true, nil)
			end
			JOYSTICK_LIMITE = control_FPS(kabal)

		-- Controlar selector de "VMC" / "GSM" (Neutrino). -----------------------------
		elseif ((Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90)) and CONTROL.JOYSTICK_ON == false and ((selector >= 11 and selector <= 12) or selector == 2) then
			if selector == 2 and #VMC_encontradas >= 1 and menus_valores[1] == 1 and (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
				selector_VMC = cambiar_valor(selector_VMC, 1, #VMC_encontradas, 1, true)
			elseif selector == 2 and #VMC_encontradas >= 1 and menus_valores[1] == 1 and (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
				selector_VMC = cambiar_valor(selector_VMC, 1, #VMC_encontradas, 1, false)
			elseif selector == 2 and #VMC_encontradas <= 0 then
				selector_VMC = 0
			elseif selector >= 11 and selector <= 12 and (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
				local limite_gsm = 5
				if selector == 12 then
					limite_gsm = 3
				end
				menus_valores[selector] = cambiar_valor(menus_valores[selector], 0, limite_gsm, 1, true)
			elseif selector >= 11 and selector <= 12 and (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
				local limite_gsm = 5
				if selector == 12 then
					limite_gsm = 3
				end
				menus_valores[selector] = cambiar_valor(menus_valores[selector], 0, limite_gsm, 1, false)
			end
			local kabal = 1 if Left_X ~= 1 then
				kabal = 2
			end
			if kabal == 1 then
				repro_sfx(S_EJECUTAR, 1, true, nil)
			end
			JOYSTICK_LIMITE = control_FPS(kabal)

		-- Cambiar configuraciones (Neutrino). ------------------------------------------
		elseif Pads.check(PAD, PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_EJECUTAR, 1, false, nil)
			if selector >= 11 and selector <= 12 then
				local limite_gsm = 5
				if selector == 12 then
					limite_gsm = 3
				end
				menus_valores[selector] = cambiar_valor(menus_valores[selector], 0, limite_gsm, 1, true)
			elseif selector == 2 and #VMC_encontradas >= 1 and menus_valores[1] == 1 then
				selector_VMC = cambiar_valor(selector_VMC, 1, #VMC_encontradas, 1, true)
			elseif selector == 2 and #VMC_encontradas <= 0 then
				selector_VMC = 0
			else
				menus_valores[selector] = cambiar_valor(menus_valores[selector], 0, 1, 1, true)
			end
			JOYSTICK_LIMITE = control_FPS(1)

		-- Cambiar configuración de soporte para medios (Neutrino). ---------------------
		elseif Pads.check(PAD, PAD_L1) and (string.lower(string.sub(nombre_iso, -4)) == ".hdd" or string.lower(string.sub(nombre_iso, -4)) == ".udp") and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_EJECUTAR, 1, false, nil)
			if string.lower(string.sub(nombre_iso, -4)) == ".hdd" and sopor_m == 1 then 
				sopor_m = 2
			elseif string.lower(string.sub(nombre_iso, -4)) == ".udp" and sopor_m == 1 then 
				sopor_m = 3
			elseif sopor_m ~= 1 then
				sopor_m = 1
			end
			JOYSTICK_LIMITE = control_FPS(1)

		-- Guardar configuraciones (Neutrino). ------------------------------------------
		elseif Pads.check(PAD, PAD_START) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_EJECUTAR, 1, false, nil)

			-- Mensaje de guardado (Neutrino). ------------------------------------------
			submenu_selector({}, nil, TEXT_M_PS2[19] .."...", 160, 188, true, CONTROL.ANCHO//2, {}, false, true, {}, nil)

			-- Borrar las configuraciones existentes (Neutrino). ------------------------
			if doesFileExist(actual .."/Roms/ISOs PlayStation 2/Configs/".. string.sub(nombre_iso, 1, -5) ..".cfg") then
				System.removeFile(actual .."/Roms/ISOs PlayStation 2/Configs/".. string.sub(nombre_iso, 1, -5) ..".cfg")
			end
			local ps2_config_final = {"nil", "nil", "nil", "nil"}

			-- Borrar las configuraciones de versiones previas (Neutrino). --------------
			local conf_del = {".vmcd", ".mode", ".mgsm"}
			for limpiar = 1, #conf_del, 1 do
				if doesFileExist(actual .."/Roms/ISOs PlayStation 2/Configs/".. string.sub(nombre_iso, 1, -5) .. conf_del[limpiar]) then
					System.removeFile(actual .."/Roms/ISOs PlayStation 2/Configs/".. string.sub(nombre_iso, 1, -5) .. conf_del[limpiar])
				end
				if doesFileExist(actual .."/Roms/ps2-isos/".. string.sub(nombre_iso, 1, -5) .. conf_del[limpiar]) then
					System.removeFile(actual .."/Roms/ps2-isos/".. string.sub(nombre_iso, 1, -5) .. conf_del[limpiar])
				end
				if doesFileExist(device .."/DVD/".. string.sub(nombre_iso, 1, -5) .. conf_del[limpiar]) then
					System.removeFile(device .."/DVD/".. string.sub(nombre_iso, 1, -5) .. conf_del[limpiar])
				end
				if doesFileExist(device .."/CD/".. string.sub(nombre_iso, 1, -5) .. conf_del[limpiar]) then
					System.removeFile(device .."/CD/".. string.sub(nombre_iso, 1, -5) .. conf_del[limpiar])
				end
			end

			-- Generar configuración de "VMC" (Neutrino). -------------------------------
			if menus_valores[1] == 1 and #VMC_encontradas >= 1 then
				ps2_config_final[1] = "-mc0=".. VMC_encontradas[selector_VMC]
			end

			-- Generar configuración de compatibilidad (Neutrino). ----------------------
			local modos_on = "-gc="
			local crear_modos = false
			local modos_final = {"0", "1", "2", "3", "5", "7"}
			for mc = 4, 9, 1 do
				if menus_valores[mc] == 1 then
					modos_on = modos_on .. modos_final[mc-3]
					crear_modos = true
				end
			end
			if crear_modos == true then
				ps2_config_final[2] = modos_on
			end

			-- Generar configuración de "GSM" (Neutrino). -------------------------------
			local gsm_on = "-gsm="
			if menus_valores[11] > 0 then
				if menus_valores[11] == 1 then
					gsm_on = gsm_on .."fp1"
				elseif menus_valores[11] == 2 then
					gsm_on = gsm_on .."fp2"
				elseif menus_valores[11] == 3 then
					gsm_on = gsm_on .."1080ix1"
				elseif menus_valores[11] == 4 then
					gsm_on = gsm_on .."1080ix2"
				elseif menus_valores[11] == 5 then
					gsm_on = gsm_on .."1080ix3"
				end
			end
			if menus_valores[12] > 0 then
				if menus_valores[12] == 1 then
					gsm_on = gsm_on ..":1"
				elseif menus_valores[12] == 2 then
					gsm_on = gsm_on ..":2"
				elseif menus_valores[12] == 3 then
					gsm_on = gsm_on ..":3"
				end
			end
			if gsm_on ~= "-gsm=" then
				ps2_config_final[3] = gsm_on
			end

			-- Generar configuración de soporte para medios (Neutrino). -----------------
			if sopor_m >= 2 and sopor_m <= 3 then
				ps2_config_final[4] = tostring(sopor_m-1)
			else
				ps2_config_final[4] = "nil"
			end

			-- Crear el archivo de configuración del juego (Neutrino). ------------------
			if not (ps2_config_final[1] == "nil" and ps2_config_final[2] == "nil" and ps2_config_final[3] == "nil" and ps2_config_final[4] == "nil") then
				local config_ps2 = System.openFile(actual .."/Roms/ISOs PlayStation 2/Configs/".. string.sub(nombre_iso, 1, -5) ..".cfg", FCREATE)
				local ps2_data = ps2_config_final[1] .."\r\n".. ps2_config_final[2] .."\r\n".. ps2_config_final[3] .."\r\n".. ps2_config_final[4]
				System.writeFile(config_ps2, ps2_data, string.len(ps2_data))
				System.closeFile(config_ps2)
			end
			ps2_menu = false
			JOYSTICK_LIMITE = control_FPS(1)-16

		-- Abrir menú de configuración para OPL. ----------------------------------------
		elseif Pads.check(PAD, PAD_R1) and CONTROL.JOYSTICK_ON == false then
			if string.lower(string.sub(nombre_iso, -4)) == ".iso" and dir_iso ~= nil then
				repro_sfx(S_EJECUTAR, 1, false, nil)
				JOYSTICK_LIMITE = control_FPS(1)
				ps2_menu = opl_config(nombre_iso, ps2_menu, dir_iso)
			else
				repro_sfx(S_CANCELAR, 1, false, nil)
				JOYSTICK_LIMITE = control_FPS(1)
			end

		-- Cancelar configuración y salir del menú (Neutrino). --------------------------
		elseif Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_CANCELAR, 1, false, nil)
			ps2_menu = false
			JOYSTICK_LIMITE = control_FPS(1)-16
		end
		end
	end
	animaciones(nil, false)
	CONTROL.FPS = Screen.getFPS(1)
	capturar(JOYSTICK_LIMITE)
end

--- Busca el nombre del juego DVD PS2. --------------------------------------------------
function obtener_nombre_DVD(nombre_id, exten)
	local ext = "    "
	if exten == true then
		ext = ".elf"
	end
	local nombre = "PS2 DISK: ".. nombre_id .. ext
	local actual = System.currentDirectory()
	if doesFileExist(actual .."/System/Defaults/PS2_IDs.cfg") then
		local carga_id = System.openFile(actual .."/System/Defaults/PS2_IDs.cfg", FREAD)
		System.seekFile(carga_id, 0, SET)
		local size = System.sizeFile(carga_id)
		local temp_tex = System.readFile(carga_id, size)
		System.closeFile(carga_id)
		for linea in string.gmatch(temp_tex, nombre_id .."=.+\n") do
			local salto = string.find(linea, "=")
			local fin = string.find(linea, "\n")
			local extra = string.find(linea, "\r\n")
			if salto ~= nil and fin ~= nil and extra ~= nil then
				nombre = (string.sub(linea, salto+1, fin-2) .. ext)
			elseif salto ~= nil and fin ~= nil and extra == nil then
				nombre = (string.sub(linea, salto+1, fin-1) .. ext)
			end
		end
	end
	return nombre
end

--- Busca el nombre de APPS (SAS) en el archivo ".cfg". ---------------------------------
function obtener_nombre_SAS(archivo_cfg, nombre_APP)
	local nombre = nombre_APP
	if doesFileExist(archivo_cfg) then
		local carga_cfg = System.openFile(archivo_cfg, FREAD)
		System.seekFile(carga_cfg, 0, SET)
		local size = System.sizeFile(carga_cfg)
		local temp_tex = System.readFile(carga_cfg, size)
		System.closeFile(carga_cfg)
		for linea in string.gmatch(temp_tex, "title=.+") do
			local salto = string.find(linea, "\n")
			if salto ~= nil then
				if string.sub(linea, salto-1, salto) == "\r\n" then
					nombre = (string.sub(linea, 7, salto-2) .."    ")
				else
					nombre = (string.sub(linea, 7, salto-1) .."    ")
				end
			else
				nombre = (string.sub(linea, 7) .."    ")
			end
		end
	end
	return nombre
end

--- Obtener parámetros para lanzar juegos con OPL. --------------------------------------
function id_opl(directorio_iso, game_name, n_load)
	local id_name = nil
	if string.match(game_name, "%a+_%d+%.%d+%.") then
		id_name = string.upper(string.sub(game_name, 1, 11))
	elseif string.lower(string.sub(game_name, -4)) == ".iso" then
		if n_load == true then
			submenu_selector({}, nil, TEXT_M_CON[46], 160, 247, true, CONTROL.ANCHO//2, {}, false, true, {}, nil)
		end
		local iso_r = System.openFile(directorio_iso .. game_name, FREAD)
		System.seekFile(iso_r, 0, SET)
		local temp_dir_r = System.readFile(iso_r, 1500000)
		System.closeFile(iso_r)
		local start_n, end_n = string.find(temp_dir_r, "%a%a%a%a_%d%d%d%.%d%d")
		if start_n ~= nil then
			id_name = string.upper(string.sub(temp_dir_r, start_n, end_n))
		end
	end
	local nombre_iso = string.sub(game_name, 1, -4) .."iso"
	return nombre_iso, id_name
end

--- Buscar y cargar configuraciones de PS2. ---------------------------------------------
function load_ps2_cfg(nombre_juego)
	local actual = System.currentDirectory()
	local device = salida_texto_dir(actual, nil)
	local vmc, modos, GSM, soporte, lista_config = "nil", "nil", "nil", "nil", {}
	if doesFileExist(actual .."/Roms/ISOs PlayStation 2/Configs/".. string.sub(nombre_juego, 1, -5) ..".cfg") then
		local carga_cfg = System.openFile(actual .."/Roms/ISOs PlayStation 2/Configs/".. string.sub(nombre_juego, 1, -5) ..".cfg", FREAD)
		System.seekFile(carga_cfg, 0, SET)
		local size_config = System.sizeFile(carga_cfg)
		local temp = System.readFile(carga_cfg, size_config)
		System.closeFile(carga_cfg)
		lista_config = sub_string(temp, "[^\r\n]+", lista_config, false)
		local lista_comparar_config = {"-mc%d=.+", "-gc=%d+", "-gsm=.+", "%d"}
		if lista_config ~= nil and (#lista_config >= 1 and #lista_config <= 4) then
			for cont = 1, #lista_comparar_config do
				local presente = false
				for cont2 = 1, #lista_config do
					if string.match(lista_config[cont2], lista_comparar_config[cont]) then
						presente = true
						break
					end
				end
				if presente == false then
					lista_config[cont] = "nil"
				end
			end
		else
			lista_config = {vmc, modos, GSM, soporte}
		end
		if lista_config[1] == "nil" and lista_config[2] == "nil" and lista_config[3] == "nil" and lista_config[4] == "nil" then
			System.removeFile(actual .."/Roms/ISOs PlayStation 2/Configs/".. string.sub(nombre_juego, 1, -5) ..".cfg")
		end
	else
		lista_config = {vmc, modos, GSM, soporte}
	end
	return lista_config
end
