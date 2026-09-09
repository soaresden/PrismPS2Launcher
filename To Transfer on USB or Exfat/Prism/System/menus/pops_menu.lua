-- Prism PS2 Launcher - menus/pops_menu.lua
-- POPStarter per-game options menu.
-- Split from the original funciones.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Functions are globals; this file only defines them. Loaded by System/system.lua.

--- Menú de configuración PS1. ----------------------------------------------------------
function menu_pops(nombre_vcd)
	Pads.rumble(0, 0, 0)
	local creditos = "Configurations based on POPStarter documentation created by ShaolinAssassin and POPStarter patches created by Hugopocked."
	local cambio_ani, n_ani = true, 45
	local actual = System.currentDirectory()
	local device = salida_texto_dir(actual, nil)
	local nombre_game = string.sub(nombre_vcd, 1, -5)
	local pops_u = POPS_DE(nombre_vcd)   -- unidad cuyo POPS/ contiene este juego
	local parches_indi_enc, parches_indi, ubicar, tipo, selec_act, selec_opt = {}, nil, " ", nil, true, 1
	LISTAS.SCROLL_TEX = 1
	reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
	local estatus_game = System.listDirectory(pops_u .."/POPS/".. nombre_game)

	-- Crear directorios faltantes. -----------------------------------------------------
	if estatus_game == nil then
		System.createDirectory(pops_u .."/POPS/".. nombre_game)
	end
	if System.listDirectory(pops_u .."/POPS/Hugopocked Fixes") == nil then
		System.createDirectory(pops_u .."/POPS/Hugopocked Fixes")
	end
	if System.listDirectory(pops_u .."/POPS/Hugopocked Fixes/POPS General Fixes") == nil then
		System.createDirectory(pops_u .."/POPS/Hugopocked Fixes/POPS General Fixes")
	end
	if System.listDirectory(pops_u .."/POPS/Hugopocked Fixes/POPS Game Fixes") == nil then
		System.createDirectory(pops_u .."/POPS/Hugopocked Fixes/POPS Game Fixes")
	end

	-- Dibujar los submenús con múltiples opciones. -------------------------------------
	local function sub_menu_multi(sub_menu_lista, sub_menu_actual, nombre_game, text_prin, p_ini, p_end, centrado, p_cen, most_fondos, lista_resp, tipo_act, modo_alt)
		p_end = (p_end-p_ini)+32
		local x_menu, x_cent, p_end_res = (CONTROL.ANCHO//2), 8, ((p_ini+p_end)-32)+CONTROL.Y_FIX_PAL
		if centrado == false then
			x_menu, x_cent = p_cen, 0
		end
		if most_fondos == true then
			dibujar_fondos()
			if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true and OPCIONES.SCREENSHOT_BACK_ON == 1 then
				Graphics.drawScaleImage(LISTAS.SCREENSHOT, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F, Color.new(128, 128, 128, OPCIONES.SCREENSHOT_BACK_TR))
			end
		end
		Graphics.drawScaleImage(LISTAS.LOGO, (CONTROL.ANCHO//2)-(240//2), 0+CONTROL.Y_FIX_PAL, 240, 72)
		if modo_alt == true then
			Graphics.drawRect(12, 74+CONTROL.Y_FIX_PAL, 615, 343, COLOR.NEGRO_T)
			Graphics.drawRect(12, 74+CONTROL.Y_FIX_PAL, 615, 74, COLOR.NEGRO_T)
			Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 77+CONTROL.Y_FIX_PAL, 8, 600, 25, "-".. TEXT_M_PRI[8] .."-", COLOR.BLANCO)
			Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 101+CONTROL.Y_FIX_PAL, 8, 600, 8, nombre_game, CAMBIOS_EMUS.COLOR_EMU)
			Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 126+CONTROL.Y_FIX_PAL, 8, 600, 8, "-".. text_prin .."-", COLOR.BLANCO)
			if OPCIONES.GUI_LIMPIA_ON == 0 then
				local x_gui_pos = {40, 186, 322, 515}
				local img_gui = {PAD_IMG.CROSS, PAD_IMG.START, PAD_IMG.SQUARE, PAD_IMG.CIRCLE}
				for mostrar_gui = 1, #x_gui_pos do
					local fix_x, fix_y = 0, 0
					if tipo == nil and mostrar_gui == 2 then
						fix_x, fix_y = 10, 5
					end
					if (mostrar_gui ~= 2 and mostrar_gui ~= 3) or (tipo == nil and mostrar_gui == 2) or (((sub_menu_actual <= #sub_menu_lista and tipo == nil) or tipo == true) and mostrar_gui == 3) then
						Graphics.drawRect(x_gui_pos[mostrar_gui], 422+CONTROL.Y_FIX_PAL, calcular_sombras(lista_resp[mostrar_gui]), 20, COLOR.NEGRO_T)
						Graphics.drawScaleImage(img_gui[mostrar_gui], x_gui_pos[mostrar_gui]-(25+fix_x), 422-fix_y+CONTROL.Y_FIX_PAL, (20+fix_x), (20+fix_x))
						Font.ftPrint(CONTROL.fontARCA, x_gui_pos[mostrar_gui]+3, 422+CONTROL.Y_FIX_PAL, 0, 0, 25, lista_resp[mostrar_gui], COLOR.BLANCO)
					end
				end
				img_gui = nil
			end
		elseif tipo_act ~= nil and modo_alt == false then
			Graphics.drawRect(0, (p_ini)+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, p_end, COLOR.BLANCO)
			Graphics.drawRect(0, (p_ini+2)+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, (p_end-4), COLOR.NEGRO)
			Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), (p_ini+10)+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 25, nombre_game, CAMBIOS_EMUS.COLOR_EMU)
			Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), (p_ini+38)+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 25, text_prin, COLOR.BLANCO)
			for mostrar = 1, #sub_menu_lista do
				local espacio_linea = (p_ini+40)+((mostrar)*24)+CONTROL.Y_FIX_PAL
				if sub_menu_actual == mostrar then
					Font.ftPrint(CONTROL.fontARCA, x_menu, espacio_linea, x_cent, CONTROL.ANCHO, 25, sub_menu_lista[sub_menu_actual], COLOR.BLANCO)
				else
					Font.ftPrint(CONTROL.fontARCA, x_menu, espacio_linea, x_cent, CONTROL.ANCHO, 25, sub_menu_lista[mostrar], COLOR.GRIS)
				end
			end
			if tipo_act == true then
				Graphics.drawScaleImage(PAD_IMG.CROSS, 224-35, p_end_res, 20, 20)
				Graphics.drawScaleImage(PAD_IMG.CIRCLE, 380-35, p_end_res, 20, 20)
			elseif tipo_act == false then
				Graphics.drawScaleImage(PAD_IMG.SQUARE, 224-35, p_end_res, 20, 20)
				Graphics.drawScaleImage(PAD_IMG.TRIANGLE, 380-35, p_end_res, 20, 20)
			end
			Font.ftPrint(CONTROL.fontARCA, 214, p_end_res, 0, 160, 25, lista_resp[1], COLOR.BLANCO)
			Font.ftPrint(CONTROL.fontARCA, 370, p_end_res, 0, 160, 25, lista_resp[2], COLOR.BLANCO)
		elseif tipo_act == nil and modo_alt == false then
			Graphics.drawRect(0, (p_ini)+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, p_end, COLOR.BLANCO)
			Graphics.drawRect(0, (p_ini+2)+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, (p_end-4), COLOR.NEGRO)
			Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), (p_ini+(p_end//2)-17)+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 25, text_prin, COLOR.BLANCO)
			refrescar(false)
		end
	end

	-- Menú de configuración de "CHEATS.TXT". -------------------------------------------
	local function def_cheats(new, conf_load)
		local set_num_conf = {""; "", 1; ""; ""; 10; 640; 2559; 2560; ""; ""; ""; ""; "";
		""; ""; ""; ""; ""; ""; ""; ""; ""; ""; ""; ""; ""; ""; ""; ""; ""; ""; ""; ""; "";}
		local lista_comparar_config = {"$SAFEMODE"; "SMOOTH"; "USBDELAY_"; "FORCEPAL"; "NOPAL"; "YPOS_"; "XPOS_"; "DWSTRETCH_"; "DWCROP_";
		"SCANLINES"; "D2LS"; "D2LS_ALT"; "HDTVFIX"; "MUTE_VAB"; "IGR0"; "IGR1"; "IGR2"; "IGR3"; "IGR4"; "IGR5"; "NOIGR"; "FAKELC"; "WIDESCREEN";
		"ULTRA_WIDESCREEN"; "EYEFINITY"; "480p"; "NOVMC0"; "NOVMC1"; "UNDO_GAME_FIXES"; "COMPATIBILITY_0x01"; "COMPATIBILITY_0x02";
		"COMPATIBILITY_0x03"; "COMPATIBILITY_0x04"; "COMPATIBILITY_0x05"; "COMPATIBILITY_0x06";}
		local new_cheats_config = {"$SAFEMODE"; "SMOOTH"; "USBDELAY_"; "FORCEPAL"; "NOPAL"; "YPOS_"; "XPOS_"; "DWSTRETCH_"; "DWCROP_";
		"SCANLINES"; "D2LS"; "D2LS_ALT"; "HDTVFIX"; "MUTE_VAB"; "IGR0"; "IGR1"; "IGR2"; "IGR3"; "IGR4"; "IGR5"; "NOIGR"; "FAKELC"; "WIDESCREEN";
		"ULTRA_WIDESCREEN"; "EYEFINITY"; "480p"; "NOVMC0"; "NOVMC1"; "UNDO_GAME_FIXES"; "COMPATIBILITY_0x01"; "COMPATIBILITY_0x02";
		"COMPATIBILITY_0x03"; "COMPATIBILITY_0x04"; "COMPATIBILITY_0x05"; "COMPATIBILITY_0x06";}
		local descriptions_cheats = {TEXT_POPS_DESCR[1]; TEXT_POPS_DESCR[2]; TEXT_POPS_DESCR[3]; TEXT_POPS_DESCR[4]; TEXT_POPS_DESCR[5];
		TEXT_POPS_DESCR[6]; TEXT_POPS_DESCR[7]; TEXT_POPS_DESCR[8]; TEXT_POPS_DESCR[9]; TEXT_POPS_DESCR[10]; TEXT_POPS_DESCR[11];
		TEXT_POPS_DESCR[12]; TEXT_POPS_DESCR[13]; TEXT_POPS_DESCR[14]; TEXT_POPS_DESCR[15]; TEXT_POPS_DESCR[16]; TEXT_POPS_DESCR[17];
		TEXT_POPS_DESCR[18]; TEXT_POPS_DESCR[19]; TEXT_POPS_DESCR[20]; TEXT_POPS_DESCR[21]; TEXT_POPS_DESCR[22]; TEXT_POPS_DESCR[23];
		TEXT_POPS_DESCR[24]; TEXT_POPS_DESCR[25]; TEXT_POPS_DESCR[26]; TEXT_POPS_DESCR[27]; TEXT_POPS_DESCR[28]; TEXT_POPS_DESCR[29];
		TEXT_POPS_DESCR[30]; TEXT_POPS_DESCR[31]; TEXT_POPS_DESCR[32]; TEXT_POPS_DESCR[33]; TEXT_POPS_DESCR[34]; TEXT_POPS_DESCR[35];}
		local other_cheats, hexa_code, text_codi_ext, text_codi_pops = {}, "%x%x%x%x%x%x%x%x%s%x%x%x%x", "EXTRA CODES", "POPSTARTER CODES"
		if conf_load ~= nil and #conf_load >= 1 then
			for cont = 1, #lista_comparar_config do
				local presente = false
				for cont2 = 1, #conf_load do
					if string.match(conf_load[cont2], lista_comparar_config[cont]) then
						new_cheats_config[cont] = conf_load[cont2]
						presente = true
						break
					end
				end
				if presente == false then
					new_cheats_config[cont] = lista_comparar_config[cont] .. set_num_conf[cont]
				elseif presente == true and (cont == 3 or (cont >= 6 and cont <= 9)) then
					local pos_n = string.find(new_cheats_config[cont], "_")
					set_num_conf[cont] = tonumber(string.sub(new_cheats_config[cont], pos_n+1))
				end
			end
			for cont = 1, #conf_load do
				local presente = false
				for cont2 = 1, #lista_comparar_config do
					if string.match(conf_load[cont], lista_comparar_config[cont2]) then
						presente = true
						break
					end
				end
				if presente == false and not string.match("// ".. text_codi_ext .." //", conf_load[cont]) and not string.match("// ".. text_codi_pops .." //", conf_load[cont]) and not string.match(conf_load[cont], "SAFEMODE") then
					table.insert(other_cheats, conf_load[cont])
				end
			end
		end
		if new == true or conf_load == nil or #conf_load <= 0 then
			for cont = 1, #lista_comparar_config do
				new_cheats_config[cont] = lista_comparar_config[cont] .. set_num_conf[cont]
			end
		end
		if #other_cheats >= 1 then
			table.insert(new_cheats_config, "/-----------/ ".. text_codi_ext .." /-----------/")
			for cont = 1, #other_cheats do
				table.insert(new_cheats_config, other_cheats[cont])
			end
		end
		if new == true then
			for cont = 1, #new_cheats_config do
				if string.match(new_cheats_config[cont], "%$") and not string.match(new_cheats_config[cont], "SAFEMODE") then
					new_cheats_config[cont] = string.sub(new_cheats_config[cont], 2)
				end
			end
		end
		table.insert(new_cheats_config, "/---------/ ".. text_codi_pops .." /---------/")
		local cheats_menu = true
		local selec_cheat = 1
		while cheats_menu do
			CONTROL.FPS = Screen.getFPS(1)
			capturar(JOYSTICK_LIMITE)
			tiempo_de_scroll()

			-- Mostrar todo en pantalla. ------------------------------------------------
			local lista_resp = {TEXT_GEN[8], TEXT_GEN[12], TEXT_M_PS1[3], TEXT_GEN[6]}
			sub_menu_multi(lista_comparar_config, selec_cheat, nombre_game, TEXT_M_PS1[4], 74, 422, true, 0, true, lista_resp, nil, true)
			if CONTROL.ESPERA_CARGA_SCR == false then
				LISTAS.SCROLL_TEX = scroll_texto(LISTAS.SCROLL_TEX, new_cheats_config[selec_cheat], 38)
			end
			local max_lista = 0
			for contador_1 = 0, 10 do
				local espacio_linea = 152+((contador_1)*24)+CONTROL.Y_FIX_PAL
				if contador_1 == 0 then
					Font.ftPrint(CONTROL.fontARCA, 22, espacio_linea, 0, 552, 25, string.sub(new_cheats_config[selec_cheat], LISTAS.SCROLL_TEX), CAMBIOS_EMUS.COLOR_EMU)
					local acti = TEXT_GEN[2]
					if string.match(new_cheats_config[selec_cheat], "%$") then
						acti = TEXT_GEN[3]
					end
					if selec_cheat >= #lista_comparar_config+1 and not string.match(new_cheats_config[selec_cheat], hexa_code) then
						acti = " "
					end
					Font.ftPrint(CONTROL.fontARCA, 578, espacio_linea, 0, 0, 8, "".. acti, CAMBIOS_EMUS.COLOR_EMU)
				elseif (selec_cheat+contador_1) <= #new_cheats_config then
					Font.ftPrint(CONTROL.fontARCA, 22, espacio_linea, 0, 552, 25, new_cheats_config[selec_cheat+contador_1], COLOR.BLANCO_LISTA)
					local acti = TEXT_GEN[2]
					if string.match(new_cheats_config[selec_cheat+contador_1], "%$") then
						acti = TEXT_GEN[3]
					end
					if selec_cheat+contador_1 >= #lista_comparar_config+1 and not string.match(new_cheats_config[selec_cheat+contador_1], hexa_code) then
						acti = " "
					end
					Font.ftPrint(CONTROL.fontARCA, 578, espacio_linea, 0, 0, 8, "".. acti, COLOR.BLANCO_LISTA)
				elseif max_lista <= #new_cheats_config-1 and #new_cheats_config >= 11 then
					max_lista = max_lista+1
					Font.ftPrint(CONTROL.fontARCA, 22, espacio_linea, 0, 552, 25, new_cheats_config[max_lista], COLOR.BLANCO_LISTA)
					local acti = TEXT_GEN[2]
					if string.match(new_cheats_config[max_lista], "%$") then
						acti = TEXT_GEN[3]
					end
					Font.ftPrint(CONTROL.fontARCA, 578, espacio_linea, 0, 0, 8, "".. acti, COLOR.BLANCO_LISTA)
				end
			end
			if selec_cheat <= #lista_comparar_config and Pads.check(PAD, PAD_SQUARE) then
				Graphics.drawRect(20, 182+CONTROL.Y_FIX_PAL, 600, 104, COLOR.BLANCO)
				Graphics.drawRect(24, 186+CONTROL.Y_FIX_PAL, 592, 96, COLOR.NEGRO)
				Font.ftPrint(CONTROL.fontARCA, 35, 192+CONTROL.Y_FIX_PAL, 0, 615, 96, descriptions_cheats[selec_cheat], CAMBIOS_EMUS.COLOR_EMU)
			end
			if new == false then
				refrescar(false)
			end

			-- Moverse por las opciones del menú. ---------------------------------------
			if (((Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) or (Pads.check(PAD, PAD_UP) or Left_Y <= -90)) or ((Pads.check(PAD, PAD_LEFT) or Pads.check(PAD, PAD_RIGHT) or Left_X ~= 1) and (selec_cheat == 3 or (selec_cheat >= 6 and selec_cheat <= 9)))) and CONTROL.JOYSTICK_ON == false then
				local min_s, max_s = 1, 3
				if selec_cheat == 6 then
					min_s, max_s = 1, 100
				elseif selec_cheat == 7 then
					min_s, max_s = 540, 740
				elseif selec_cheat == 8 then
					min_s, max_s = 2000, 3000
				elseif selec_cheat == 9 then
					min_s, max_s = 2160, 2560
				end
				if (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) then
					selec_cheat = cambiar_valor(selec_cheat, 1, #new_cheats_config, 1, true)
					if selec_cheat == #new_cheats_config then
						selec_cheat = 1
					elseif #other_cheats >= 1 and selec_cheat == #lista_comparar_config+1 and #lista_comparar_config+2 <= #new_cheats_config then
						selec_cheat = selec_cheat+1
					end
				elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90) then
					selec_cheat = cambiar_valor(selec_cheat, 1, #new_cheats_config, 1, false)
					if selec_cheat == #new_cheats_config then
						selec_cheat = selec_cheat-1
					elseif #other_cheats >= 1 and selec_cheat == #lista_comparar_config+1 then
						selec_cheat = #lista_comparar_config
					end
				elseif Pads.check(PAD, PAD_LEFT) or Left_X <= -90 then
					set_num_conf[selec_cheat] = cambiar_valor(set_num_conf[selec_cheat], min_s, max_s, 1, false)
					local pos_n = string.find(new_cheats_config[selec_cheat], "_")
					new_cheats_config[selec_cheat] = string.sub(new_cheats_config[selec_cheat], 1, pos_n) .. set_num_conf[selec_cheat]
				elseif Pads.check(PAD, PAD_RIGHT) or Left_X >= 90 then
					set_num_conf[selec_cheat] = cambiar_valor(set_num_conf[selec_cheat], min_s, max_s, 1, true)
					local pos_n = string.find(new_cheats_config[selec_cheat], "_")
					new_cheats_config[selec_cheat] = string.sub(new_cheats_config[selec_cheat], 1, pos_n) .. set_num_conf[selec_cheat]
				end
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				local kabal = 1 if (Left_Y ~= 1 or Left_X ~= 1) then
					kabal = 2
				end
				if kabal == 1 then
					repro_sfx(S_MOVER, 1, true, nil)
				end
				JOYSTICK_LIMITE = control_FPS(kabal)
			elseif Pads.check(PAD, PAD_CROSS) and selec_cheat ~= 1 and CONTROL.JOYSTICK_ON == false then
				repro_sfx(S_EJECUTAR, 1, false, nil)
				if selec_cheat <= #lista_comparar_config or (selec_cheat >= #lista_comparar_config+1 and string.match(new_cheats_config[selec_cheat], hexa_code)) then
					if string.match(new_cheats_config[selec_cheat], "%$") then
						new_cheats_config[selec_cheat] = string.sub(new_cheats_config[selec_cheat], 2)
					else
						new_cheats_config[selec_cheat] = "$".. new_cheats_config[selec_cheat]
					end
					if selec_cheat == 4 and string.match(new_cheats_config[5], "%$") then
						new_cheats_config[5] = string.sub(new_cheats_config[5], 2)
					elseif selec_cheat == 5 and string.match(new_cheats_config[4], "%$") then
						new_cheats_config[4] = string.sub(new_cheats_config[4], 2)
					elseif selec_cheat == 11 and string.match(new_cheats_config[12], "%$") then
						new_cheats_config[12] = string.sub(new_cheats_config[12], 2)
					elseif selec_cheat == 12 and string.match(new_cheats_config[11], "%$") then
						new_cheats_config[11] = string.sub(new_cheats_config[11], 2)
					elseif selec_cheat >= 15 and selec_cheat <= 21 then
						for change = 15, 21 do
							if change ~= selec_cheat and string.match(new_cheats_config[change], "%$") then
								new_cheats_config[change] = string.sub(new_cheats_config[change], 2)
							end
						end
					elseif selec_cheat >= 23 and selec_cheat <= 25 then
						for change = 23, 25 do
							if change ~= selec_cheat and string.match(new_cheats_config[change], "%$") then
								new_cheats_config[change] = string.sub(new_cheats_config[change], 2)
							end
						end
					elseif (selec_cheat >= 30 and selec_cheat <= 32) or selec_cheat == 34 then
						for change = 30, 34 do
							if change ~= selec_cheat and change ~= 33 and string.match(new_cheats_config[change], "%$") then
								new_cheats_config[change] = string.sub(new_cheats_config[change], 2)
							end
						end
					end
				end
				JOYSTICK_LIMITE = control_FPS(1)
			elseif (Pads.check(PAD, PAD_START) and CONTROL.JOYSTICK_ON == false) or new == true then
				repro_sfx(S_EJECUTAR, 1, false, nil)
				local pregunta, confirmar_cheat = true, false
				if new == false then
					while pregunta do
						CONTROL.FPS = Screen.getFPS(1)
						capturar(JOYSTICK_LIMITE)
						local lista_resp = {TEXT_GEN[12], TEXT_GEN[6]}
						sub_menu_multi({}, 1, nombre_game, TEXT_M_PS1[5] .."?", 160, 226, true, 0, true, lista_resp, false, false)
						refrescar(false)
						if Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
							repro_sfx(S_EJECUTAR, 1, false, nil)
							confirmar_cheat, cheats_menu, pregunta = true, false, false
						elseif Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
							repro_sfx(S_CANCELAR, 1, false, nil)
							pregunta = false
						end
					end
				end
				if (confirmar_cheat == true or new == true) and System.listDirectory(pops_u .."/POPS/".. nombre_game) ~= nil then
					if new == false then
						sub_menu_multi({}, 1, nombre_game, TEXT_M_PS1[6] .."... ".. TEXT_M_CON[46], 160, 226, true, 0, true, lista_resp, nil, false)
					end
					if #other_cheats >= 1 then
						new_cheats_config[#lista_comparar_config+1] = "// ".. text_codi_ext .." //"
					end
					table.remove(new_cheats_config, #new_cheats_config)
					for cont = #lista_comparar_config, 2, -1 do
						if not string.match(new_cheats_config[cont], "%$") then
							table.remove(new_cheats_config, cont)
						end
					end
					table.insert(new_cheats_config, 1, "// ".. text_codi_pops .." //")
					local config_f = ""
					for create = 1, #new_cheats_config do
						local salto_linea = "\r\n"
						if create == #new_cheats_config then
							salto_linea = ""
						end
						config_f = config_f .. new_cheats_config[create] .. salto_linea
					end
					if doesFileExist(pops_u .."/POPS/".. nombre_game .."/CHEATS.TXT") then
						System.removeFile(pops_u .."/POPS/".. nombre_game .."/CHEATS.TXT")
					end
					local final_cheats = System.openFile(pops_u .."/POPS/".. nombre_game .."/CHEATS.TXT", FCREATE)
					System.writeFile(final_cheats, config_f, string.len(config_f))
					System.closeFile(final_cheats)
					cheats_menu = false
					JOYSTICK_LIMITE = control_FPS(1)-20
					estatus_game = System.listDirectory(pops_u .."/POPS/".. nombre_game)
					System.sleep(1)
				end
			elseif Pads.check(PAD, PAD_CIRCLE) and CONTROL.JOYSTICK_ON == false then
				repro_sfx(S_CANCELAR, 1, false, nil)
				cheats_menu = false
				JOYSTICK_LIMITE = control_FPS(1)-20
			end
		end
	end

	-- Cargar configuraciones desde "CHEATS.TXT". ---------------------------------------
	local function cargar_cheats_txt(rest)
		local lista_config = {}
		if doesFileExist(pops_u .."/POPS/".. nombre_game .."/CHEATS.TXT") then
			local cheats_txt = System.openFile(pops_u .."/POPS/".. nombre_game .."/CHEATS.TXT", FREAD)
			System.seekFile(cheats_txt, 0, SET)
			local size_config = System.sizeFile(cheats_txt)
			local temp = System.readFile(cheats_txt, size_config)
			System.closeFile(cheats_txt)
			lista_config = sub_string(temp, "[^\r\n]+", lista_config, false)
			def_cheats(rest, lista_config)
		else
			def_cheats(rest, nil)
		end
	end

	-- Instalar parches para POPStarter. ------------------------------------------------
	local function instalar_parches(tipo_de_inst, dir_orig, cheats_ins)
		local dir_pops_game = pops_u .."/POPS/".. nombre_game
		if tipo_de_inst == false or tipo_de_inst == nil then
			local prev_parches = System.listDirectory(dir_pops_game)
			if prev_parches ~= nil then
				for cont = 1, #prev_parches do
					if (string.lower(string.sub(prev_parches[cont].name, -4)) == ".bin" and cheats_ins == false) or (prev_parches[cont].name == "CHEATS.TXT" and cheats_ins == true) then
						System.removeFile(dir_pops_game .."/".. prev_parches[cont].name)
					end
				end
			end
		end
		if tipo_de_inst ~= nil then
			local nuev_parches = System.listDirectory(dir_orig)
			if nuev_parches ~= nil then
				for cont = 1, #nuev_parches do
					if (string.lower(string.sub(nuev_parches[cont].name, -4)) == ".bin" and cheats_ins == false) or (nuev_parches[cont].name == "CHEATS.TXT" and cheats_ins == true) then
						System.copyFile(dir_orig .."/".. nuev_parches[cont].name, dir_pops_game .."/".. nuev_parches[cont].name)
					end
				end
			end
		end
		estatus_game = System.listDirectory(pops_u .."/POPS/".. nombre_game)
	end

	-- Buscar parches para POPStarter. --------------------------------------------------
	local function menu_pops_paches(cheats_ins)
		parches_indi_enc = {}
		parches_indi = nil
		local text_parche, text_adver = " ", " "
		if tipo == true then
			parches_indi = System.listDirectory(pops_u .."/POPS/Hugopocked Fixes/POPS General Fixes")
			ubicar = pops_u .."/POPS/Hugopocked Fixes/POPS General Fixes/"
			text_parche, text_adver = TEXT_M_PS1[11], TEXT_M_PS1[12]
		elseif tipo == false then
			parches_indi = System.listDirectory(pops_u .."/POPS/Hugopocked Fixes/POPS Game Fixes")
			ubicar = pops_u .."/POPS/Hugopocked Fixes/POPS Game Fixes/"
			text_parche, text_adver = TEXT_M_PS1[13], TEXT_M_PS1[14]
			if cheats_ins == true then
				text_parche, text_adver = TEXT_M_PS1[29], TEXT_M_PS1[30]
			end
		end
		if parches_indi ~= nil and (tipo == true or tipo == false) then
			for cont_1 = 1, #parches_indi do
				if parches_indi[cont_1].directory == true then
					local conf_bin2 = System.listDirectory(ubicar .. parches_indi[cont_1].name)
					if conf_bin2 ~= nil then
						for cont_2 = 1, #conf_bin2 do
							if (string.lower(string.sub(conf_bin2[cont_2].name, -4)) == ".bin" and cheats_ins == false) or (conf_bin2[cont_2].name == "CHEATS.TXT" and cheats_ins == true) then
								table.insert(parches_indi_enc, ubicar .. parches_indi[cont_1].name)
								break
							elseif conf_bin2[cont_2].directory == true then
								local conf_bin3 = System.listDirectory(ubicar .. parches_indi[cont_1].name .."/".. conf_bin2[cont_2].name)
								for cont_3 = 1, #conf_bin3 do
									if (string.lower(string.sub(conf_bin3[cont_3].name, -4)) == ".bin" and cheats_ins == false) or (conf_bin2[cont_2].name == "CHEATS.TXT" and cheats_ins == true) then
										table.insert(parches_indi_enc, ubicar .. parches_indi[cont_1].name .."/".. conf_bin2[cont_2].name)
										break
									end
								end
							end
						end
					end
				end
			end
			if parches_indi_enc ~= nil and #parches_indi_enc >= 1 then
				table.sort(parches_indi_enc, orden_alfabetico)
				local lista_comparar_fix = {"%[DQA,DQB,default%]INTPL,RTPS,IRGB,%[ORGB div7Ch%]"; "%[DQA,DQB,default%]INTPL,RTPS,IRGB,%[ORGB div80h%]";
				"%[DQA,DQB,default%]INTPL,RTPS,IRGB,%[ORGB div84h%]"; "%[DQA,DQB,default%]INTPL,RTPS,IRGB,%[ORGB div90h%]";
				"%[DQA,DQB,hack%]INTPL,RTPS,IRGB,%[ORGB div84h%]"; "%[IR0%=zero%]INTPL,RTPS,IRGB,%[ORGB div84h%]"; "INTPL,RTPS,IRGB,%[ORGB div84h%]";
				"Renew CodeCache Scan"; "SPU_IRQ_"; "CPU_Clock"; "GPU Timing_Fix 0"; "GPU Timing_OverclockFix"; "GPU Dithering Off"; ".*";}
				local descriptions_fix = {TEXT_POPS_DESCR[36]; TEXT_POPS_DESCR[37]; TEXT_POPS_DESCR[38]; TEXT_POPS_DESCR[39]; TEXT_POPS_DESCR[40];
				TEXT_POPS_DESCR[41]; TEXT_POPS_DESCR[42]; TEXT_POPS_DESCR[43]; TEXT_POPS_DESCR[44]; TEXT_POPS_DESCR[45]; TEXT_POPS_DESCR[46];
				TEXT_POPS_DESCR[47]; TEXT_POPS_DESCR[48]; TEXT_POPS_DESCR[49]; }
				local menu_conf_ps1, selector = true, 1
				while menu_conf_ps1 do
					CONTROL.FPS = Screen.getFPS(1)
					capturar(JOYSTICK_LIMITE)
					tiempo_de_scroll()

					-- Mostrar todo en pantalla. ----------------------------------------
					local lista_resp = {TEXT_M_PS1[15], TEXT_GEN[12], TEXT_M_PS1[3], TEXT_GEN[6]}
					if cheats_ins == true then
						lista_resp[1] = TEXT_M_PS1[1]
					end
					local submenu_conf = {}
					sub_menu_multi(submenu_conf, selector, nombre_game, text_parche, 74, 422, true, 0, true, lista_resp, nil, true)
					if CONTROL.ESPERA_CARGA_SCR == false then
						LISTAS.SCROLL_TEX = scroll_texto(LISTAS.SCROLL_TEX, salida_texto_dir(parches_indi_enc[selector], true), 44)
					end
					local max_lista = 0
					for contador_l = 0, 10 do
						local espacio_linea = 152+((contador_l)*24)+CONTROL.Y_FIX_PAL
						if contador_l == 0 then
							Font.ftPrint(CONTROL.fontARCA, 22, espacio_linea, 0, 600, 25, string.sub(salida_texto_dir(parches_indi_enc[selector], true), LISTAS.SCROLL_TEX), CAMBIOS_EMUS.COLOR_EMU)
						elseif (selector+contador_l) <= #parches_indi_enc then
							Font.ftPrint(CONTROL.fontARCA, 22, espacio_linea, 0, 600, 25, salida_texto_dir(parches_indi_enc[selector+contador_l], true), COLOR.BLANCO_LISTA)
						elseif max_lista <= #parches_indi_enc-1 and #parches_indi_enc >= 11 then
							max_lista = max_lista+1
							Font.ftPrint(CONTROL.fontARCA, 22, espacio_linea, 0, 600, 25, salida_texto_dir(parches_indi_enc[max_lista], true), COLOR.BLANCO_LISTA)
						end
					end
					if Pads.check(PAD, PAD_SQUARE) and tipo == true and cheats_ins == false then
						for buscar = 1, #lista_comparar_fix do
							if string.match(salida_texto_dir(parches_indi_enc[selector], true), lista_comparar_fix[buscar]) then
								Graphics.drawRect(20, 182+CONTROL.Y_FIX_PAL, 600, 104, COLOR.BLANCO)
								Graphics.drawRect(24, 186+CONTROL.Y_FIX_PAL, 592, 96, COLOR.NEGRO)
								Font.ftPrint(CONTROL.fontARCA, 35, 192+CONTROL.Y_FIX_PAL, 0, 615, 96, descriptions_fix[buscar], CAMBIOS_EMUS.COLOR_EMU)
								break
							end
						end
					end
					refrescar(false)

					-- Moverse por las opciones del menú. -------------------------------
					if ((Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) or (Pads.check(PAD, PAD_UP) or Left_Y <= -90)) and CONTROL.JOYSTICK_ON == false then
						if (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) then
							selector = cambiar_valor(selector, 1, #parches_indi_enc, 1, true)
						elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90) then
							selector = cambiar_valor(selector, 1, #parches_indi_enc, 1, false)
						end
						LISTAS.SCROLL_TEX = 1
						reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
						local kabal = 1 if Left_Y ~= 1 then
							kabal = 2
						end
						if kabal == 1 then
							repro_sfx(S_MOVER, 1, true, nil)
						end
						JOYSTICK_LIMITE = control_FPS(kabal)
					elseif Pads.check(PAD, PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_EJECUTAR, 1, false, nil)
						local confir, pregunta = false, true
						LISTAS.SCROLL_TEX = 1
						reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
						local lista_text_sele = {TEXT_M_PS1[16], TEXT_M_PS1[18], TEXT_M_PS1[7]}
						if cheats_ins == true then
							lista_text_sele = {TEXT_M_PS1[32], TEXT_M_PS1[31], TEXT_M_PS1[33]}
						end
						while pregunta do
							CONTROL.FPS = Screen.getFPS(1)
							capturar(JOYSTICK_LIMITE)
							tiempo_de_scroll()
							if CONTROL.ESPERA_CARGA_SCR == false then
								LISTAS.SCROLL_TEX = scroll_texto(LISTAS.SCROLL_TEX, salida_texto_dir(parches_indi_enc[selector], true), 44)
							end
							local sub_menu_lista = {text_adver, lista_text_sele[1] ..":", string.sub(salida_texto_dir(parches_indi_enc[selector], true), LISTAS.SCROLL_TEX)}
							local lista_resp = {TEXT_M_PS1[17], TEXT_GEN[6]}
							sub_menu_multi(sub_menu_lista, 1, nombre_game, lista_text_sele[2] .."?", 160, 298, true, 0, true, lista_resp, false, false)
							refrescar(false)
							if Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
								repro_sfx(S_EJECUTAR, 1, false, nil)
								confir = true
								menu_conf_ps1 = false
								pregunta = false
							elseif Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
								repro_sfx(S_CANCELAR, 1, false, nil)
								LISTAS.SCROLL_TEX = 1
								reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
								pregunta = false
							end
						end
						if confir == true then
							sub_menu_multi({}, 1, nombre_game, lista_text_sele[3] .."... ".. TEXT_M_CON[46], 160, 298, true, 0, true, {}, nil, false)
							instalar_parches(tipo, parches_indi_enc[selector], cheats_ins)
							System.sleep(1)
						end
						JOYSTICK_LIMITE = control_FPS(1)-20
					elseif Pads.check(PAD, PAD_CIRCLE) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_CANCELAR, 1, false, nil)
						menu_conf_ps1 = false
						JOYSTICK_LIMITE = control_FPS(1)-20
					end
				end
			end
		end
	end

	-- Selector de configuraciones para POPStarter. -------------------------------------
	local function menu_pops_ini()
		while selec_act do
			CONTROL.FPS = Screen.getFPS(1)
			capturar(JOYSTICK_LIMITE)
			tiempo_de_scroll()

			-- Mostrar todo en pantalla. ------------------------------------------------
			local submenu_conf = {TEXT_M_PS1[19], TEXT_M_PS1[20], TEXT_M_PS1[1], TEXT_M_PS1[21], TEXT_M_PS1[22]}
			local lista_resp = {TEXT_GEN[5], TEXT_GEN[6]}
			sub_menu_multi(submenu_conf, selec_opt, nombre_game, TEXT_M_PS1[23], 74, 264, true, 0, true, lista_resp, false, false)
			if estatus_game ~= nil then
				local x_ms, y_ms = 22, 1
				Graphics.drawRect(12, 304+CONTROL.Y_FIX_PAL, 615, 111, COLOR.NEGRO_T)
				for mostrar = 1, #estatus_game do
					if mostrar >= 21 then
						break
					end
					local espacio_linea = 288+((y_ms)*24)+CONTROL.Y_FIX_PAL
					Font.ftPrint(CONTROL.fontARCA, x_ms, espacio_linea, 0, 140, 25, string.sub(estatus_game[mostrar].name, 1, -5), COLOR.BLANCO)
					y_ms = y_ms+1
					if (mostrar == 4 or mostrar == 8 or mostrar == 12) then
						x_ms, y_ms = x_ms+150, 1
					end
				end
			end
			if CONTROL.ESPERA_CARGA_SCR == false then
				LISTAS.SCROLL_TEX = scroll_texto(LISTAS.SCROLL_TEX, creditos, 44)
			end
			Graphics.drawRect(12, 422+CONTROL.Y_FIX_PAL, 615, 22, COLOR.NEGRO_T)
			Font.ftPrint(CONTROL.fontARCA, 22, 424+CONTROL.Y_FIX_PAL, 0, 600, 25, string.sub(creditos, LISTAS.SCROLL_TEX), COLOR.BLANCO)
			if cambio_ani == true then
				cambio_ani, n_ani = intro_menu(cambio_ani, n_ani)
			end
			refrescar(false)

			-- Moverse por las opciones del menú. ---------------------------------------
			if cambio_ani == false then
			if Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
				repro_sfx(S_EJECUTAR, 1, false, nil)
				local text_carga = TEXT_M_PS1[8] .."..."
				if selec_opt == 1 then
					tipo = false
				elseif selec_opt == 2 then
					tipo = true
				elseif selec_opt == 3 then
					tipo, text_carga = false, TEXT_M_PS1[2] .."..."
				elseif selec_opt == 4 then
					tipo, text_carga = nil, TEXT_M_PS1[9] .."..."
				elseif selec_opt == 5 then
					tipo, text_carga = nil, TEXT_M_PS1[10] .."..."
				end
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				JOYSTICK_LIMITE = control_FPS(1)-15
				if tipo ~= nil and selec_opt ~= 5 then
					sub_menu_multi({}, 1, nombre_game, text_carga, 160, 298, true, 0, true, {}, nil, false)
					System.sleep(2)
					if selec_opt == 3 then
						menu_pops_paches(true)
					else
						menu_pops_paches(false)
					end
				elseif tipo == nil and selec_opt ~= 5 then
					sub_menu_multi({}, 1, nombre_game, text_carga, 160, 298, true, 0, true, {}, nil, false)
					System.sleep(2)
					cargar_cheats_txt(false)
				elseif tipo == nil and selec_opt == 5 then
					local confirmar_limp, pregunta3, selector_lim = false, true, 1
					while pregunta3 do
						CONTROL.FPS = Screen.getFPS(1)
						capturar(JOYSTICK_LIMITE)
						local submenu_conf = {TEXT_M_PS1[24], TEXT_M_PS1[25], TEXT_M_PS1[26]}
						local lista_resp = {TEXT_M_PS1[28], TEXT_GEN[6]}
						sub_menu_multi(submenu_conf, selector_lim, nombre_game, TEXT_M_PS1[27] .."?", 160, 298, true, 0, true, lista_resp, true, false)
						refrescar(false)
						if Pads.check(PAD, PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
							repro_sfx(S_EJECUTAR, 1, false, nil)
							confirmar_limp = true
							pregunta3 = false
						elseif ((Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) or (Pads.check(PAD, PAD_UP) or Left_Y <= -90)) and CONTROL.JOYSTICK_ON == false then
							repro_sfx(S_MOVER, 1, false, nil)
							if (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) then
								selector_lim = cambiar_valor(selector_lim, 1, #submenu_conf, 1, true)
							elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90) then
								selector_lim = cambiar_valor(selector_lim, 1, #submenu_conf, 1, false)
							end
							JOYSTICK_LIMITE = control_FPS(1)
						elseif Pads.check(PAD, PAD_CIRCLE) and CONTROL.JOYSTICK_ON == false then
							repro_sfx(S_CANCELAR, 1, false, nil)
							pregunta3 = false
							JOYSTICK_LIMITE = control_FPS(1)
						end
					end
					if confirmar_limp == true and System.listDirectory(pops_u .."/POPS/".. nombre_game) ~= nil then
						sub_menu_multi({}, 1, nombre_game, text_carga, 160, 298, true, 0, true, {}, nil, false)
						if selector_lim == 1 then
							instalar_parches(nil, "", false); System.sleep(2)
						elseif selector_lim == 2 then
							cargar_cheats_txt(true)
						elseif selector_lim == 3 then
							instalar_parches(nil, "", false)
							cargar_cheats_txt(true)
						end
					end
				end
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
			elseif ((Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) or (Pads.check(PAD, PAD_UP) or Left_Y <= -90) or (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90)) and CONTROL.JOYSTICK_ON == false then
				if (Pads.check(PAD, PAD_UP) or Left_Y <= -90) or (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
					selec_opt = cambiar_valor(selec_opt, 1, #submenu_conf, 1, false)
				elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) or (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
					selec_opt = cambiar_valor(selec_opt, 1, #submenu_conf, 1, true)
				end
				local kabal = 1 if Left_Y ~= 1 then
					kabal = 2
				end
				if kabal == 1 then
					repro_sfx(S_MOVER, 1, true, nil)
				end
				JOYSTICK_LIMITE = control_FPS(kabal)
			elseif Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
				repro_sfx(S_CANCELAR, 1, false, nil)
				selec_act = false
				JOYSTICK_LIMITE = control_FPS(1)-16
			end
			end
		end
	end
	menu_pops_ini()
	animaciones(nil, false)
end
