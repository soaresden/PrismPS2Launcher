-- Prism PS2 Launcher - menus/settings.lua
-- Settings menu (START) and the configuration reset screens.
-- Split from the original funciones.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Functions are globals; this file only defines them. Loaded by System/system.lua.

--- Muestra, cambia y guarda las configuraciones. ---------------------------------------
function menu_config()
	Pads.rumble(0, 0, 0)
	local cambio_ani, n_ani = true, 45

	-- Guardar configuraciones previas. -------------------------------------------------
	local anterior_conf = {OPCIONES.RGB_ON; OPCIONES.FONDO_RGB_ON; OPCIONES.FONDO_RGB_FIJO_ON; OPCIONES.R; OPCIONES.G; OPCIONES.B;
	CONTROL.ESTILO; SISTEMAS.MEGADRIVE_ON; SISTEMAS.MASTERSYSTEM_ON; SISTEMAS.GAMEGEAR_ON; SISTEMAS.FAMICOM_ON; SISTEMAS.GAMEBOY_ON;
	SISTEMAS.GAMEBOYCOLOR_ON; SISTEMAS.GAMEBOYADVANCE_ON; SISTEMAS.ATARI2600_ON; SISTEMAS.ATARILYNX_ON; SISTEMAS.SEGASG1000_ON;
	SISTEMAS.NEOGEOPOCKET_ON; SISTEMAS.SUPERFAMICOM_ON; SISTEMAS.APPS_ON; SISTEMAS.PLAYSTATION_ON; SISTEMAS.PLAYSTATION2_ON;
	OPCIONES.CAMBIO_FUENTE_ON; OPCIONES.CAMBIO_FONDO_ON; OPCIONES.GUI_LIMPIA_ON; OPCIONES.LIMITADOR_RAM_ON; OPCIONES.SALIDA_RETROLANCHER_ON;
	OPCIONES.SALIDA_RETROLANCHER; OPCIONES.APPS_MENU_FULL_PATH; OPCIONES.SOUND_ON; OPCIONES.SOUND_VOLUME; OPCIONES.SCREENSHOT_BACK_ON;
	OPCIONES.VIBRATION_ON; OPCIONES.DIR_EXTRAS_ON; CAMBIOS_EMUS.TRAS; OPCIONES.LIBERAR_LISTAS; OPCIONES.FONT_PIXEL_X; OPCIONES.FONT_PIXEL_Y;
	OPCIONES.FONT_SHADOW; OPCIONES.SCROLL_MIN; OPCIONES.SPRITE_ON; OPCIONES.SEE_INDEX; OPCIONES.COLOR_LISTA_B; OPCIONES.SCREENSHOT_BACK_TR;
	OPCIONES.RUN_DEFAULT, COLOR.CC_BACK[1], COLOR.CC_BACK[2], COLOR.CC_BACK[3], COLOR.CC_BACK[4]};

	-- Variables para controlar configuraciones. ----------------------------------------
	color_emu(LISTAS.IDENTIDAD, OPCIONES.FONDO_RGB_ON, OPCIONES.FONDO_RGB_FIJO_ON)
	local lista_config = {OPCIONES.RGB_ON; OPCIONES.FONDO_RGB_ON; OPCIONES.FONDO_RGB_FIJO_ON; OPCIONES.R; OPCIONES.G;
	OPCIONES.B; CONTROL.ESTILO; SISTEMAS.MEGADRIVE_ON; SISTEMAS.MASTERSYSTEM_ON; SISTEMAS.GAMEGEAR_ON; SISTEMAS.FAMICOM_ON;
	SISTEMAS.GAMEBOY_ON; SISTEMAS.GAMEBOYCOLOR_ON; SISTEMAS.GAMEBOYADVANCE_ON; SISTEMAS.ATARI2600_ON; SISTEMAS.ATARILYNX_ON;
	SISTEMAS.SEGASG1000_ON; SISTEMAS.NEOGEOPOCKET_ON; SISTEMAS.SUPERFAMICOM_ON; SISTEMAS.APPS_ON; SISTEMAS.PLAYSTATION_ON;
	SISTEMAS.PLAYSTATION2_ON; OPCIONES.CAMBIO_FUENTE_ON; OPCIONES.CAMBIO_FONDO_ON; OPCIONES.GUI_LIMPIA_ON; OPCIONES.LIMITADOR_RAM_ON;
	OPCIONES.SALIDA_RETROLANCHER_ON; OPCIONES.SALIDA_RETROLANCHER; OPCIONES.APPS_MENU_FULL_PATH; OPCIONES.SOUND_ON;
	OPCIONES.SOUND_VOLUME; OPCIONES.SCREENSHOT_BACK_ON; OPCIONES.VIDEO_MODE; OPCIONES.VIBRATION_ON; OPCIONES.DIR_EXTRAS_ON; 0; 0; 0;};
	local lista_texto_config = {TEXT_M_CON[1]; TEXT_M_CON[2]; TEXT_M_CON[3]; TEXT_M_CON[4]; TEXT_M_CON[5]; TEXT_M_CON[6];
	TEXT_M_CON[7]; "Megadrive"; "Master System"; "Game Gear"; "Famicom"; "Game Boy"; "Game Boy Color"; "Game Boy Advance";
	"Atari 2600"; "Atari Lynx"; "SEGA SG-1000"; "Neo Geo Pocket"; "Super Famicom"; "APPS"; "PlayStation"; "PlayStation 2";
	TEXT_M_CON[8]; TEXT_M_CON[9]; TEXT_M_CON[10]; TEXT_M_CON[11]; TEXT_M_CON[12]; TEXT_M_CON[13]; TEXT_M_CON[14]; TEXT_M_CON[15];
	TEXT_M_CON[16]; TEXT_M_CON[17]; TEXT_M_CON[18]; TEXT_M_CON[19]; TEXT_M_CON[20]; "Language: English"; TEXT_M_CON[21]; TEXT_M_CON[22];};
	local noob, conf_numero, clean, reinicio, indi_rest_RL, selector, cambio_realizado, page = true, true, false, false, 0, 1, false, TEXT_M_CON[24]

	-- Opciones actuales de idioma. -----------------------------------------------------
	if doesFileExist("System/Defaults/SPA") then
		lista_texto_config[36] = "Lenguaje: Español"
	elseif doesFileExist("System/Defaults/POR") then
		lista_texto_config[36] = "Linguagem: Português"
	end

	-- Opciones actuales de audio. ------------------------------------------------------
	local mus_on = TEXT_GEN[14]
	if doesFileExist("System/Medias/Sound/Background/music.adp") then
		mus_on = TEXT_GEN[13]
	elseif doesFileExist("System/Medias/Sound/Background/music0.adp") then
		mus_on = TEXT_GEN[14]
	else
		mus_on = TEXT_M_PRI[15]
	end
	local volume = OPCIONES.SOUND_VOLUME

	-- Opciones actuales de colores y transparencias. -----------------------------------
	local cc_back_1, cc_back_2, cc_back_3, cc_back_4 = COLOR.CC_BACK[1], COLOR.CC_BACK[2], COLOR.CC_BACK[3], COLOR.CC_BACK[4]
	local color_demo = Color.new(OPCIONES.R, OPCIONES.G, OPCIONES.B, CAMBIOS_EMUS.TRAS)
	local prev_back_tras = OPCIONES.SCREENSHOT_BACK_TR
	if CAMBIOS_EMUS.TRAS == 0 then
		color_demo = Color.new(OPCIONES.R, OPCIONES.G, OPCIONES.B)
	end
	local tras_demo = CAMBIOS_EMUS.TRAS

	-- Opciones actuales de salida. -----------------------------------------------------
	local selec_dir, local_disp, menu_run = OPCIONES.SALIDA_RETROLANCHER_ON, salida_texto_dir(System.currentDirectory(), nil), OPCIONES.RUN_DEFAULT
	lista_texto_config[28] = OPCIONES.SALIDA_RETROLANCHER
	local function cambiar_medio()
		OPCIONES.SALIDA_RETROLANCHER_ON = selec_dir
		buscar_directorio(nil, OPCIONES.SALIDA_RETROLANCHER_ON)
		lista_config[28] = OPCIONES.SALIDA_RETROLANCHER
		lista_texto_config[28] = OPCIONES.SALIDA_RETROLANCHER
	end

	-- Opciones actuales de fuente de texto. --------------------------------------------
	local on_index = OPCIONES.SEE_INDEX
	buscar_fuentes()
	local selec_fuente = 1
	if OPCIONES.CAMBIO_FUENTE_ON <= #OPCIONES.FUENTES_ENCONTRADAS then
		selec_fuente = OPCIONES.CAMBIO_FUENTE_ON
	end
	local font_x, font_Y, font_shadow, font_scroll = OPCIONES.FONT_PIXEL_X, OPCIONES.FONT_PIXEL_Y, OPCIONES.FONT_SHADOW, OPCIONES.SCROLL_MIN
	local function cambia_fuente()
		if selec_fuente <= #OPCIONES.FUENTES_ENCONTRADAS and selec_fuente >= 1 then
			Font.ftUnload(CONTROL.fontARCA)
			Font.ftUnload(CONTROL.fontABC)
			CONTROL.fontARCA = Font.ftLoad(OPCIONES.FUENTES_ENCONTRADAS[selec_fuente])
			CONTROL.fontABC = Font.ftLoad(OPCIONES.FUENTES_ENCONTRADAS[selec_fuente])
			if selec_fuente == 1 then
				OPCIONES.FONT_SHADOW, font_shadow = 5, 5
			else
				OPCIONES.FONT_SHADOW, font_shadow = 0, 0
			end
			Font.ftSetPixelSize(CONTROL.fontARCA, font_x, font_Y)
			Font.ftSetPixelSize(CONTROL.fontABC, 70, 70)
			OPCIONES.CAMBIO_FUENTE_ON = selec_fuente
		end
	end

	-- Opciones actuales de fondos de pantalla. -----------------------------------------
	local estilo_lista, ini_sprite = CONTROL.ESTILO, OPCIONES.SPRITE_ON
	buscar_fondos(nil, nil)
	local selec_fondo = 1
	if OPCIONES.CAMBIO_FONDO_ON <= #OPCIONES.FONDO_ENCONTRADOS then
		selec_fondo = OPCIONES.CAMBIO_FONDO_ON
	end
	local function m_dibujar_fondos()
		RGB(lista_config[1], lista_config[3], tras_demo)
		Screen.clear(CAMBIOS_EMUS.COLOR_EMU_BACK)
		if lista_config[2] == 1 and (lista_config[3] == 0 or (lista_config[3] == 1 and tras_demo == 0)) then
			if SPRITES.FONDO_ANI == true then
				fondo_sprites(LISTAS.FONDO, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F, 0.00, true, CAMBIOS_EMUS.COLOR_EMU_BACK)
			else
				Graphics.drawScaleImage(LISTAS.FONDO, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F, CAMBIOS_EMUS.COLOR_EMU_BACK)
			end
		elseif lista_config[3] == 1 and lista_config[2] == 1 then
			if SPRITES.FONDO_ANI == true then
				fondo_sprites(LISTAS.FONDO, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F, 0.00, false, CAMBIOS_EMUS.COLOR_EMU_BACK)
			else
				Graphics.drawScaleImage(LISTAS.FONDO, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F)
			end
			Graphics.drawRect(0, 0, CONTROL.ANCHO, CONTROL.ALTO_F, color_demo)
		else
			if SPRITES.FONDO_ANI == true then
				fondo_sprites(LISTAS.FONDO, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F, 0.00, false, CAMBIOS_EMUS.COLOR_EMU_BACK)
			else
				Graphics.drawScaleImage(LISTAS.FONDO, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F)
			end
		end
	end

	-- Restaura opciones antes de salir. ------------------------------------------------
	local function rest()
		if doesFileExist(OPCIONES.SALIDA_RETROLANCHER) == false or string.lower(string.sub(OPCIONES.SALIDA_RETROLANCHER, -4)) ~= ".elf" then
			OPCIONES.SALIDA_RETROLANCHER_ON = anterior_conf[27]
			OPCIONES.SALIDA_RETROLANCHER = anterior_conf[28]
		end
		OPCIONES.R, OPCIONES.G, OPCIONES.B, OPCIONES.COLOR_LISTA_B = anterior_conf[4], anterior_conf[5], anterior_conf[6], anterior_conf[43]
	end

	-- Iniciar menú de configuración. ---------------------------------------------------
	while noob do
		CONTROL.FPS = Screen.getFPS(1)
		capturar(JOYSTICK_LIMITE)
		tiempo_de_scroll()

		-- Controlar el mínimo de sistemas activos. -------------------------------------
		local rev2 = true
		for rev = 8, 22 do
			if lista_config[rev] == 1 then
				rev2 = false
				break
			end
		end
		if rev2 == true then
			lista_config[8] = 1
		end

		if cambio_ani == false then
		-- Salir de configuraciones. ----------------------------------------------------
		if Pads.check(PAD, PAD_CIRCLE) and CONTROL.JOYSTICK_ON == false then
			local nueva_conf = {lista_config[1]; lista_config[2]; lista_config[3]; OPCIONES.R; OPCIONES.G; OPCIONES.B;
			estilo_lista; lista_config[8]; lista_config[9]; lista_config[10]; lista_config[11]; lista_config[12]; lista_config[13];
			lista_config[14]; lista_config[15]; lista_config[16]; lista_config[17]; lista_config[18]; lista_config[19]; lista_config[20];
			lista_config[21]; lista_config[22]; selec_fuente; selec_fondo; lista_config[25]; lista_config[26]; selec_dir; lista_texto_config[28];
			lista_config[29]; lista_config[30]; volume; lista_config[32]; lista_config[34]; lista_config[35]; tras_demo; OPCIONES.LIBERAR_LISTAS;
			font_x; font_Y; font_shadow; font_scroll; ini_sprite; on_index; OPCIONES.COLOR_LISTA_B; prev_back_tras, menu_run, cc_back_1, cc_back_2,
			cc_back_3, cc_back_4};
			cambio_realizado = false
			for chequeo = 1, #nueva_conf do
				if nueva_conf[chequeo] ~= anterior_conf[chequeo] then
					cambio_realizado = true
				end
			end
			if cambio_realizado == true then
				local pregunta = true
				local text_prin = TEXT_M_CON[26]
				local lista_resp = {TEXT_GEN[7], TEXT_GEN[6]}
				submenu_selector({TEXT_M_CON[27]}, nil, text_prin, 160, 224, true, CONTROL.ANCHO//2, lista_resp, false, false, {}, nil)
				refrescar(false)
				JOYSTICK_LIMITE = control_FPS(1)-10
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					if Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
						rest()
						noob = false
						pregunta = false
					elseif Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
						pregunta = false
					end
					refrescar(true)
				end
			else
				noob = false
			end
			repro_sfx(S_CANCELAR, 1, false, nil)
			JOYSTICK_LIMITE = control_FPS(1)-10
		end

		-- Ver controles de Prism. ----------------------------------------------
		if Pads.check(PAD, PAD_R3) or Pads.check(PAD, PAD_L3) and CONTROL.JOYSTICK_ON == false then
			JOYSTICK_LIMITE = control_FPS(1)
			ver_controles(false)
		end

		-- Sistemas de configuraciones extras. ------------------------------------------
		if Pads.check(PAD, PAD_SELECT) and CONTROL.JOYSTICK_ON == false and ((selector >= 4 and selector <= 23) or (selector == 24 and SPRITES.FONDO_ANI == true) or selector == 26 or selector == 29 or selector == 30 or selector == 32 or selector == 35) then
			repro_sfx(S_EJECUTAR, 1, false, nil)
			-- Seleccionar configuración a editar con estilo personalizado. -------------
			local spr_menu = true
			if selector == 7 and estilo_lista == 7 then
				local lista_resp, pregunta, selec, submenu_lista = {TEXT_GEN[5], TEXT_GEN[4]}, true, 1, {TEXT_M_CON[117], TEXT_M_CON[118]}
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					submenu_selector(submenu_lista, selec, TEXT_M_CON[116], 160, 248, true, CONTROL.ANCHO//2, lista_resp, false, false, {}, nil)
					refrescar(false)
					if ((Pads.check(PAD, PAD_UP) or Left_Y <= -90) or (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90)) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_MOVER, 1, false, nil)
						if (Pads.check(PAD, PAD_UP) or Left_Y <= -90) then
							selec = cambiar_valor(selec, 1, 2, 1, false)
						elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) then
							selec = cambiar_valor(selec, 1, 2, 1, true)
						end
						JOYSTICK_LIMITE = control_FPS(1)
					elseif Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_EJECUTAR, 1, false, nil)
						if selec == 1 then
							spr_menu = false
						elseif selec == 2 then
							spr_menu = true
						end
						pregunta = false
						JOYSTICK_LIMITE = control_FPS(1)-20
					elseif Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_CANCELAR, 1, false, nil)
						spr_menu = nil
						pregunta = false
						JOYSTICK_LIMITE = control_FPS(1)
					end
				end
			end

			-- Configurar el color de sombras tras cada elemento. -----------------------
			if (selector >= 4 and selector <= 6) then
				local selec, pregunta = 1, true
				local nombres_conf = {TEXT_M_CON[4], TEXT_M_CON[5], TEXT_M_CON[6], TEXT_M_CON[65]}
				local lista_resp = {TEXT_GEN[12], TEXT_GEN[6]}
				local valores_actual = {cc_back_1, cc_back_2, cc_back_3, cc_back_4}
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					m_dibujar_fondos()
					Graphics.drawRect(12, 23+CONTROL.Y_FIX_PAL, 615, 400, Color.new(valores_actual[1], valores_actual[2], valores_actual[3], valores_actual[4]))
					submenu_selector(nombres_conf, selec, TEXT_M_CON[121], 100, 240, false, 22, lista_resp, false, false, valores_actual, 498)
					Graphics.drawRect(230, 137+CONTROL.Y_FIX_PAL, 210, 85, COLOR.BLANCO)
					Graphics.drawRect(235, 142+CONTROL.Y_FIX_PAL, 100, 75, COLOR.BLANCO)
					Graphics.drawRect(335, 142+CONTROL.Y_FIX_PAL, 100, 75, COLOR.NEGRO)
					Graphics.drawRect(235, 142+CONTROL.Y_FIX_PAL, 200, 75, Color.new(valores_actual[1], valores_actual[2], valores_actual[3], valores_actual[4]))
					refrescar(false)
					if ((Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) or (Pads.check(PAD, PAD_UP) or Left_Y <= -90) or (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90)) and CONTROL.JOYSTICK_ON == false then
						if (Pads.check(PAD, PAD_UP) or Left_Y <= -90) then
							selec = cambiar_valor(selec, 1, #valores_actual, 1, false)
						elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) then
							selec = cambiar_valor(selec, 1, #valores_actual, 1, true)
						elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
							valores_actual[selec] = cambiar_valor(valores_actual[selec], 0, 128, 1, false)
						elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
							valores_actual[selec] = cambiar_valor(valores_actual[selec], 0, 128, 1, true)
						end
						local kabal = 1 if Left_Y ~= 1 or Left_X ~= 1 then
							kabal = 2
						end
						if kabal == 1 then
							repro_sfx(S_MOVER, 1, true, nil)
						end
						JOYSTICK_LIMITE = control_FPS(kabal)
					elseif Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_EJECUTAR, 1, false, nil)
						cc_back_1, cc_back_2, cc_back_3, cc_back_4 = valores_actual[1], valores_actual[2], valores_actual[3], valores_actual[4]
						COLOR.NEGRO_T = Color.new(cc_back_1, cc_back_2, cc_back_3, cc_back_4)
						JOYSTICK_LIMITE = control_FPS(1)
						pregunta = false
					elseif Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_CANCELAR, 1, false, nil)
						JOYSTICK_LIMITE = control_FPS(1)
						pregunta = false
					end
				end

			-- Configurar estilo personalizado. -----------------------------------------
			elseif selector == 7 and estilo_lista == 7 and spr_menu == false then
				local reload = editor_tema()
				if CONTROL.ESTILO == 7 and reload == true then
					cargar_style(true)
				end

			-- Configurar sprites en los estilos predefinidos. --------------------------
			elseif selector == 7 and spr_menu == true then
				local selec, sistemas, pregunta, text_info = 1, LISTAS.IDENTIDAD, true, " "
				local lista_resp = {TEXT_M_CON[41], TEXT_GEN[4]}
				local nombres_sist = {"Megadrive"; "Master System"; "Game Gear"; "Famicom"; "Game Boy"; "Game Boy Color";
					"Game Boy Advance"; "Atari 2600"; "Atari Lynx"; "Sega SG-1000"; "NeoGeo Pocket"; "Super Famicom"; "APPS";
					"PlayStation"; "PlayStation 2";};
				local nombres_conf = {TEXT_M_CON[107] ..":"; TEXT_M_CON[108] .." \"".. nombres_sist[sistemas] .."\""; TEXT_M_CON[109] ..":";
					TEXT_M_CON[110] ..":"; TEXT_M_CON[111] ..":"; TEXT_M_CON[112] ..":"; TEXT_M_CON[113] ..":"; TEXT_M_CON[77] ..":";
					TEXT_M_CON[78] ..":"; TEXT_M_CON[79] ..":";};
				local pre_pos_x, pre_pos_y = CONTROL.SPRITE_ANCHO, CONTROL.SPRITE_ALTO
				CONTROL.SPRITE_ANCHO, CONTROL.SPRITE_ALTO = (CONTROL.ANCHO//2)-(74//2), 382-(100//2)+CONTROL.Y_FIX_PAL
				rest_sprites(true)
				local valores_actual = {ini_sprite, sistemas; SPRITES.MOVE[sistemas]; SPRITES.SPEED_SPRITE[sistemas];
					SPRITES.TRAN_SPRITE_ON[sistemas]; SPRITES.SPIN_SPRITE_ON[sistemas]; SPRITES.AUTO_MOVE_SPRITE[sistemas];
					SPRITES.N_COLUMNS[sistemas]; SPRITES.N_ROWS[sistemas]; (SPRITES.N_COLUMNS[sistemas]*SPRITES.N_ROWS[sistemas]);};
				local conf_min = {0, 1, 0, 1, 0, 0, 0, 1, 1}
				local conf_max = {1, 15, 62, 62, 24, 62, 9, 9, 9}
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					local veloc = "\nx ".. valores_actual[4]
					if valores_actual[3] >= 53 and valores_actual[3] <= 58 then
						if valores_actual[4] >= 1 and valores_actual[4] <= 9 then
							veloc = "\nx 0.00".. valores_actual[4]
						elseif valores_actual[4] >= 10 and valores_actual[4] <= 18 then
							veloc = "\nx 0.0".. valores_actual[4]-9
						elseif valores_actual[4] >= 19 and valores_actual[4] <= 27 then
							veloc = "\nx 0.1".. valores_actual[4]
						elseif valores_actual[4] >= 28 and valores_actual[4] <= 36 then
							veloc = "\nx 0.2".. valores_actual[4]
						elseif valores_actual[4] >= 37 and valores_actual[4] <= 45 then
							veloc = "\nx 0.3".. valores_actual[4]
						elseif valores_actual[4] >= 46 and valores_actual[4] <= 54 then
							veloc = "\nx 0.4".. valores_actual[4]
						elseif valores_actual[4] >= 55 and valores_actual[4] <= 62 then
							veloc = "\nx 0.5".. valores_actual[4]
						end
					end
					local spr_trasp = TEXT_GEN[14]
					if valores_actual[5] >= 1 and valores_actual[5] <= 8 then
						spr_trasp = TEXT_SPR_T[64] .."\n".. ((16*valores_actual[5])*100)//128 .."%"
					elseif valores_actual[5] >= 9 and valores_actual[5] <= 16 then
						spr_trasp = TEXT_SPR_T[65] .."\n0% - ".. ((16*(valores_actual[5]-8))*100)//128 .."%"
					elseif valores_actual[5] >= 17 and valores_actual[5] <= 24 then
						spr_trasp = TEXT_SPR_T[66] .."\n".. (((16*(valores_actual[5]-16))*100)//128)//2 .."% - ".. ((16*(valores_actual[5]-16))*100)//128 .."%"
					end
					local spr_giro = TEXT_GEN[14]
					if valores_actual[6] >= 1 and valores_actual[6] <= 9 then
						spr_giro = TEXT_M_CON[97] .."\nx 0.00".. valores_actual[6]
					elseif valores_actual[6] >= 10 and valores_actual[6] <= 18 then
						spr_giro = TEXT_M_CON[97] .."\nx 0.0".. valores_actual[6]-9
					elseif valores_actual[6] >= 19 and valores_actual[6] <= 27 then
						spr_giro = TEXT_M_CON[97] .."\nx 0.1".. valores_actual[6]-18
					elseif valores_actual[6] >= 28 and valores_actual[6] <= 36 then
						spr_giro = TEXT_M_CON[98] .."\nx 0.00".. valores_actual[6]-27
					elseif valores_actual[6] >= 37 and valores_actual[6] <= 45 then
						spr_giro = TEXT_M_CON[98] .."\nx 0.0".. valores_actual[6]-36
					elseif valores_actual[6] >= 46 and valores_actual[6] <= 54 then
						spr_giro = TEXT_M_CON[98] .."\nx 0.1".. valores_actual[6]-45
					elseif valores_actual[6] >= 55 and valores_actual[6] <= 62 then
						spr_giro = TEXT_M_CON[99] .."\nx 0.1".. valores_actual[6]-54
					end
					local spr_refle = TEXT_GEN[14]
					if valores_actual[7] >= 1 and valores_actual[7] <= 9 then
						spr_refle = TEXT_SPR_T[66+valores_actual[7]]
					end
					text_info = TEXT_SPR_T[valores_actual[3]+1] .. veloc
					if selec == 5 then
						text_info = spr_trasp
					elseif selec == 6 then
						text_info = spr_giro
					elseif selec == 7 then
						text_info = spr_refle
					elseif selec == 8 then
						text_info = TEXT_SPR_T[76]
					elseif selec == 9 then
						text_info = TEXT_SPR_T[77]
					end
					local spr_on, pre_sys = valores_actual[1], valores_actual[2]
					if spr_on == 1 then
						valores_actual[1] = TEXT_GEN[13]
					else
						valores_actual[1] = TEXT_GEN[14]
					end
					valores_actual[2] = " "
					m_dibujar_fondos()
					submenu_selector(nombres_conf, selec, TEXT_M_CON[106], 20, 298, false, 20, lista_resp, false, false, valores_actual, 424)
					valores_actual[1] = spr_on
					valores_actual[2] =	pre_sys
					Graphics.drawRect(458, 110+CONTROL.Y_FIX_PAL, 2, 176, COLOR.BLANCO)
					Font.ftPrint(CONTROL.fontARCA, 470, 104+CONTROL.Y_FIX_PAL, 0, 200, 200, text_info, COLOR.BLANCO)
					if ini_sprite == 1 then
						dibujar_sprites(valores_actual[2], CONTROL.SPRITE_ANCHO, CONTROL.SPRITE_ALTO, 74, 100, 0.00, SPRITES.FLIP[1], SPRITES.FLIP[2], true)
					end
					refrescar(false)
					if ((Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) or (Pads.check(PAD, PAD_UP) or Left_Y <= -90) or (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) or Pads.check(PAD, PAD_R1) or Pads.check(PAD, PAD_L1)) and CONTROL.JOYSTICK_ON == false then
						if Pads.check(PAD, PAD_L1) then
							valores_actual[2] = cambiar_valor(valores_actual[2], conf_min[2], conf_max[2], 1, false)
						elseif Pads.check(PAD, PAD_R1) then
							valores_actual[2] = cambiar_valor(valores_actual[2], conf_min[2], conf_max[2], 1, true)
						elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90) then
							selec = cambiar_valor(selec, 1, #valores_actual-1, 1, false)
						elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) then
							selec = cambiar_valor(selec, 1, #valores_actual-1, 1, true)
						elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
							valores_actual[selec] = cambiar_valor(valores_actual[selec], conf_min[selec], conf_max[selec], 1, false)
						elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
							valores_actual[selec] = cambiar_valor(valores_actual[selec], conf_min[selec], conf_max[selec], 1, true)
						end
						if (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) or (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or Pads.check(PAD, PAD_R1) or Pads.check(PAD, PAD_L1) then
							if selec == 2 or Pads.check(PAD, PAD_R1) or Pads.check(PAD, PAD_L1) then
								nombres_conf[2] = TEXT_M_CON[108] .." \"".. nombres_sist[valores_actual[2]] .."\""
								valores_actual = {valores_actual[1], valores_actual[2]; SPRITES.MOVE[valores_actual[2]];
								SPRITES.SPEED_SPRITE[valores_actual[2]]; SPRITES.TRAN_SPRITE_ON[valores_actual[2]];
								SPRITES.SPIN_SPRITE_ON[valores_actual[2]]; SPRITES.AUTO_MOVE_SPRITE[valores_actual[2]];
								SPRITES.N_COLUMNS[valores_actual[2]]; SPRITES.N_ROWS[valores_actual[2]];
								(SPRITES.N_COLUMNS[valores_actual[2]]*SPRITES.N_ROWS[valores_actual[2]]);};
							else
								valores_actual[10] = valores_actual[8]*valores_actual[9]
								ini_sprite = valores_actual[1]
								SPRITES.MOVE[valores_actual[2]] = valores_actual[3]
								SPRITES.SPEED_SPRITE[valores_actual[2]] = valores_actual[4]
								SPRITES.TRAN_SPRITE_ON[valores_actual[2]] = valores_actual[5]
								SPRITES.SPIN_SPRITE_ON[valores_actual[2]] = valores_actual[6]
								SPRITES.AUTO_MOVE_SPRITE[valores_actual[2]] = valores_actual[7]
								SPRITES.N_COLUMNS[valores_actual[2]] = valores_actual[8]
								SPRITES.N_ROWS[valores_actual[2]] = valores_actual[9]
								SPRITES.WIDTH_X[valores_actual[2]] = (Graphics.getImageWidth(SPRITES[SPRITES.SPRITE_SYS[valores_actual[2]]])/SPRITES.N_COLUMNS[valores_actual[2]])
								SPRITES.HEIGHT_Y[valores_actual[2]] = (Graphics.getImageHeight(SPRITES[SPRITES.SPRITE_SYS[valores_actual[2]]])/SPRITES.N_ROWS[valores_actual[2]])
							end
							rest_sprites(true)
						end
						local kabal = 1 if Left_Y ~= 1 or Left_X ~= 1 then
							kabal = 2
						end
						if kabal == 1 then
							repro_sfx(S_MOVER, 1, true, nil)
						end
						JOYSTICK_LIMITE = control_FPS(kabal)
					elseif Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_EJECUTAR, 1, false, nil)
						local actual = System.currentDirectory()
						local list_sprites, presente, prev_name = System.listDirectory(actual .."/System/Medias/Sprites"), false, " "
						local comparar = {"Megadrive_"; "MasterSystem_"; "GameGear_"; "Famicom_"; "GameBoy_"; "GameBoyColor_"; "GameBoyAdvance_";
						"Atari2600_"; "AtariLynx_"; "SegaSG1000_"; "NeoGeoPocket_"; "SuperFamicom_"; "Apps_"; "PlayStation_"; "PlayStation2_";}
						local new_name = comparar[valores_actual[2]] .. cha_res(nil, valores_actual[3]) .. cha_res(nil, valores_actual[4]) ..
						cha_res(nil, valores_actual[5]) .. cha_res(nil, valores_actual[6]) .. cha_res(nil, valores_actual[7]) .."_"..
						cha_res(nil, valores_actual[8]) .."x".. cha_res(nil, valores_actual[9]) ..".png"
						if list_sprites ~= nil then
							for cont = 1, #comparar do
								for cont2 = 1, #list_sprites do
									if string.match(string.lower(list_sprites[cont2].name), string.lower(comparar[valores_actual[2]] .."[%w#][%w#][%w#][%w#][%w#].%d.%d%.png")) and not (valores_actual[2] == 4 and string.match(list_sprites[cont2].name, "SuperFamicom_")) then
										prev_name = list_sprites[cont2].name
										presente = true
									end
									if presente == true then break end
								end
								if presente == true then break end
							end
						end
						if presente == true and new_name ~= prev_name then
							local conf = true
							while conf do
								CONTROL.FPS = Screen.getFPS(1)
								capturar(JOYSTICK_LIMITE)
								m_dibujar_fondos()
								local submenu_lista = {nombres_conf[2], TEXT_M_CON[81] ..":", prev_name, TEXT_M_CON[82] ..":", new_name}
								local lista_resp2 = {TEXT_GEN[8], TEXT_GEN[6]}
								submenu_selector(submenu_lista, nil, TEXT_M_CON[80] .."?", 160, 318, true, (CONTROL.ANCHO//2), lista_resp2, true, false, {}, nil)
								if Pads.check(PAD, PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
									submenu_selector({}, nil, TEXT_M_CON[46], 160, 318, true, CONTROL.ANCHO//2, {}, false, true, {}, nil)
									repro_sfx(S_EJECUTAR, 1, false, nil)
									submenu_selector({}, nil, TEXT_M_CON[46], 160, 318, true, CONTROL.ANCHO//2, {}, false, true, {}, nil)
									System.rename(actual .."/System/Medias/Sprites/".. prev_name, actual .."/System/Medias/Sprites/".. new_name)
									conf = false
								elseif Pads.check(PAD, PAD_CIRCLE) and CONTROL.JOYSTICK_ON == false then
									repro_sfx(S_CANCELAR, 1, false, nil)
									conf = false
								end
								refrescar(false)
							end
						end
						JOYSTICK_LIMITE = control_FPS(1)
					elseif Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_CANCELAR, 1, false, nil)
						TEML(false)
						CONTROL.SPRITE_ANCHO, CONTROL.SPRITE_ALTO = pre_pos_x, pre_pos_y
						rest_sprites(true)
						pregunta = false
						JOYSTICK_LIMITE = control_FPS(1)
					end
				end

			-- Restauración individual de sistemas. -------------------------------------
			elseif (selector >= 8 and selector <= 19) then
				local pregunta = true
				Pads.rumble(0, 0, 0)
				local lista_indi_rest_RL = {11, 10, 9, 4, 5, 7, 6, 1, 2, 12, 3, 8}
				local lista_indi_rest = {"Sega Megadrive"; "Sega Master System"; "Sega Game Gear"; "Nintendo Famicom"; "Nintendo Game Boy";
				"Nintendo Game Boy Color"; "Nintendo Game Boy Advance"; "Atari 2600"; "Atari Lynx"; "Sega SG-1000"; "Neo Geo Pocket";
				"Nintendo Super Famicom";};
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					local eliminar_partidas = TEXT_GEN[9]
					if clean == true then
						eliminar_partidas = TEXT_GEN[10]
					end
					local submenu_lista = {"-".. TEXT_M_CON[51] .."-", eliminar_partidas}
					local text_prin = "-".. TEXT_M_CON[50] .." ".. lista_indi_rest[selector-7] .."?-"
					local lista_resp = {TEXT_GEN[11], TEXT_GEN[6]}
					submenu_selector(submenu_lista, nil, text_prin, 160, 245, true, CONTROL.ANCHO//2, lista_resp, false, false, {}, nil)
					Graphics.drawScaleImage(PAD_IMG.L1, CONTROL.ANCHO//2-64, 214+CONTROL.Y_FIX_PAL, 30, 30)
					Graphics.drawScaleImage(PAD_IMG.R1, CONTROL.ANCHO//2+32, 214+CONTROL.Y_FIX_PAL, 30, 30)
					if (Pads.check(PAD, PAD_R1) or Pads.check(PAD, PAD_L1)) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_NETX, 1, false, nil)
						if clean == false then
							clean = true
						else
							clean = false
						end
						JOYSTICK_LIMITE = control_FPS(1)
					elseif Pads.check(PAD, PAD_SQUARE) then
						repro_sfx(S_EJECUTAR, 1, false, nil)
						rest()
						noob, reinicio, pregunta = false, true, false
						indi_rest_RL = lista_indi_rest_RL[selector-7]
					elseif Pads.check(PAD, PAD_TRIANGLE) then
						repro_sfx(S_CANCELAR, 1, false, nil)
						pregunta, clean = false, false
						indi_rest_RL = 0
						JOYSTICK_LIMITE = control_FPS(1)
					end
					refrescar(false)
				end

			-- Configuraciones extras de APPS. ------------------------------------------
			elseif selector == 20 then
				local actual, pregunta, estado = System.currentDirectory(), true, "WLE: "
				-- El ELF cambia de nombre en cada version de uLaunchELF: se busca por
				-- extension, no por nombre.
				local _, wle_n, wle_off = RUTA_WLE(true)
				if wle_n == nil then
					estado = TEXT_M_PRI[17] .." ".. TEXT_M_PRI[20]
				elseif wle_off == true then
					estado = "WLE: ".. TEXT_GEN[14]
				else
					estado = "WLE: ".. TEXT_GEN[13]
				end
				while pregunta do
					CONTROL.FPS = Screen.getFPS(1)
					capturar(JOYSTICK_LIMITE)
					submenu_selector({estado}, nil, TEXT_M_CON[45], 160, 226, true, CONTROL.ANCHO//2, {TEXT_GEN[8], TEXT_GEN[6]}, false, false, {}, nil)
					refrescar(false)
					if Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_EJECUTAR, 1, false, nil)
						submenu_selector({}, nil, TEXT_M_CON[46], 160, 226, true, CONTROL.ANCHO//2, {}, false, true, {}, nil)
						local _, nom, apagado = RUTA_WLE(true)
						if nom == nil then
							estado = TEXT_M_PRI[17] .." ".. TEXT_M_PRI[20]
						elseif apagado == true then
							-- Quitar el "_" del principio: vuelve a la lista.
							System.rename("uLaunchELF/".. nom, "uLaunchELF/".. string.sub(nom, 2))
							estado = "WLE: ".. TEXT_GEN[13]
						else
							System.rename("uLaunchELF/".. nom, "uLaunchELF/_".. nom)
							estado = "WLE: ".. TEXT_GEN[14]
						end
						JOYSTICK_LIMITE = control_FPS(1)
					elseif Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_CANCELAR, 1, false, nil)
						pregunta = false
					end
				end

			-- Configuraciones extras de POPStarter. ------------------------------------
			elseif selector == 21 then
				local pregunta, selec_opt, device, actual = true, 1, salida_texto_dir(System.currentDirectory(), nil), System.currentDirectory()
				local lang = "ENG"
				if doesFileExist(actual .."/System/Defaults/SPA") then
					lang = "SPA"
				elseif doesFileExist(actual .."/System/Defaults/POR") then
					lang = "POR"
				end
				local estados_pops = {2, 2, 2}
				if doesFileExist(POPS_RAIZ .."/POPS/PATCH_9.BIN") == true then
					estados_pops[1] = 3
				end
				if doesFileExist(POPS_RAIZ .."/POPS/TROJAN_9.BIN") == true then
					estados_pops[2] = 3
				end
				while pregunta do
					CONTROL.FPS = Screen.getFPS(1)
					capturar(JOYSTICK_LIMITE)
					local text_prin = TEXT_M_CON[83]
					local submenu_lista = {TEXT_M_CON[84] ..": ".. TEXT_GEN[estados_pops[1]], TEXT_M_CON[85] ..": ".. TEXT_GEN[estados_pops[2]], TEXT_M_CON[86] .." (".. lang .."): ".. TEXT_GEN[estados_pops[3]]}
					local lista_resp = {TEXT_M_CON[41], TEXT_GEN[6]}
					submenu_selector(submenu_lista, selec_opt, text_prin, 160, 274, true, CONTROL.ANCHO//2, lista_resp, false, false, {}, nil)
					refrescar(false)
					if Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_EJECUTAR, 1, false, nil)
						submenu_selector({}, nil, TEXT_M_CON[46], 160, 274, true, CONTROL.ANCHO//2, {}, false, true, {}, nil)
						if estados_pops[1] == 2 then
							if doesFileExist(POPS_RAIZ .."/POPS/PATCH_9.BIN") == true then
								System.removeFile(POPS_RAIZ .."/POPS/PATCH_9.BIN")
							end
						elseif estados_pops[1] == 3 then
							if doesFileExist(POPS_RAIZ .."/POPS/PATCH_9.BIN") == false and doesFileExist(actual .."/POPStarter/PATCH_9.BIN") then
								System.copyFile(actual .."/POPStarter/PATCH_9.BIN", POPS_RAIZ .."/POPS/PATCH_9.BIN")
							end
						end
						if estados_pops[2] == 2 then
							if doesFileExist(POPS_RAIZ .."/POPS/TROJAN_9.BIN") == true then
								System.removeFile(POPS_RAIZ .."/POPS/TROJAN_9.BIN")
							end
						elseif estados_pops[2] == 3 then
							if doesFileExist(POPS_RAIZ .."/POPS/TROJAN_9.BIN") == false and doesFileExist(actual .."/POPStarter/TROJAN_9.BIN") then
								System.copyFile(actual .."/POPStarter/TROJAN_9.BIN", POPS_RAIZ .."/POPS/TROJAN_9.BIN")
							end
						end
						if estados_pops[3] == 3 then
							if doesFileExist(actual .."/POPStarter/".. lang .."/IGR_BG.TM2") and doesFileExist(actual .."/POPStarter/".. lang .."/IGR_NO.TM2") and doesFileExist(actual .."/POPStarter/".. lang .."/IGR_YES.TM2") and System.listDirectory(POPS_RAIZ .."/POPS") ~= nil then
								System.copyFile(actual .."/POPStarter/".. lang .."/IGR_BG.TM2", POPS_RAIZ .."/POPS/IGR_BG.TM2")
								System.copyFile(actual .."/POPStarter/".. lang .."/IGR_NO.TM2", POPS_RAIZ .."/POPS/IGR_NO.TM2")
								System.copyFile(actual .."/POPStarter/".. lang .."/IGR_YES.TM2", POPS_RAIZ .."/POPS/IGR_YES.TM2")
							end
						end
						pregunta = false
						JOYSTICK_LIMITE = control_FPS(1)
					elseif ((Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) or (Pads.check(PAD, PAD_UP) or Left_Y <= -90) or (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90)) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_MOVER, 1, false, nil)
						if (Pads.check(PAD, PAD_UP) or Left_Y <= -90) then
							selec_opt = cambiar_valor(selec_opt, 1, 3, 1, false)
						elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) then
							selec_opt = cambiar_valor(selec_opt, 1, 3, 1, true)
						elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and selec_opt == 1 then
							estados_pops[1] = cambiar_valor(estados_pops[1], 2, 3, 1, false)
						elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and selec_opt == 1 then
							estados_pops[1] = cambiar_valor(estados_pops[1], 2, 3, 1, true)
						elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and selec_opt == 2 then
							estados_pops[2] = cambiar_valor(estados_pops[2], 2, 3, 1, false)
						elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and selec_opt == 2 then
							estados_pops[2] = cambiar_valor(estados_pops[2], 2, 3, 1, true)
						elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and selec_opt == 3 then
							estados_pops[3] = cambiar_valor(estados_pops[3], 2, 3, 1, false)
						elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and selec_opt == 3 then
							estados_pops[3] = cambiar_valor(estados_pops[3], 2, 3, 1, true)
						end
						JOYSTICK_LIMITE = control_FPS(1)
					elseif Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_CANCELAR, 1, false, nil)
						pregunta = false
					end
				end

			-- Configurar directorio de OPL. --------------------------------------------
			elseif selector == 22 then
				local pregunta, selec_disp, scroll_opl, device = true, 1, 1, salida_texto_dir(System.currentDirectory(), nil)
				local text_prin = TEXT_M_CON[28]
				local lista_resp = {TEXT_M_CON[29], TEXT_GEN[4]}
				JOYSTICK_LIMITE = control_FPS(1)-20
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					tiempo_de_scroll()
					m_dibujar_fondos()
					if CONTROL.ESPERA_CARGA_SCR == false then
						scroll_opl = scroll_texto(scroll_opl, OPCIONES.OPL_ELF, 44)
					end
					-- Soportes disponibles + unidades BDM detectadas (disco interno exFAT). --
					local submenu_lista = {"mc0:", "mc1:", device}
					if BDM_DEVICES ~= nil then
						for i_bdm = 1, #BDM_DEVICES do
							table.insert(submenu_lista, BDM_DEVICES[i_bdm])
						end
					end
					local n_disp = #submenu_lista
					table.insert(submenu_lista, string.sub(OPCIONES.OPL_ELF, scroll_opl))
					-- Mismo ajuste de altura: 3 soportes de base + la linea de la ruta.
					local extra_bdm = #submenu_lista - 4
					if extra_bdm < 0 then extra_bdm = 0 end
					submenu_selector(submenu_lista, selec_disp, text_prin, 160-(extra_bdm*12), 297+(extra_bdm*12), true, CONTROL.ANCHO//2, lista_resp, false, false, {}, nil)
					refrescar(false)
					if Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_EJECUTAR, 1, false, nil)
						marcar_directorio(true, selec_disp, m_dibujar_fondos)
						JOYSTICK_LIMITE = control_FPS(1)
					elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90 or Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90 or Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_MOVER, 1, false, nil)
						if (Pads.check(PAD, PAD_UP) or Left_Y <= -90 or Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
							selec_disp = cambiar_valor(selec_disp, 1, n_disp, 1, false)
						elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90 or Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
							selec_disp = cambiar_valor(selec_disp, 1, n_disp, 1, true)
						end
						JOYSTICK_LIMITE = control_FPS(1)
					elseif Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_CANCELAR, 1, false, nil)
						JOYSTICK_LIMITE = control_FPS(1)
						pregunta = false
					end
				end

			-- Configurar fuente de texto. ----------------------------------------------
			elseif selector == 23 then
				local pix_txt = {TEXT_M_CON[30] ..": ", TEXT_M_CON[31] ..": ", TEXT_M_CON[32] ..": ", TEXT_M_CON[33] ..": "}
				local example_text = {TEXT_M_CON[34], ""}
				local pix_option = {font_x, font_Y, font_shadow, font_scroll}
				local CONFT = Font.ftLoad("System/Medias/Font/PublicPixel.ttf")
				Font.ftSetPixelSize(CONTROL.fontARCA, pix_option[1], pix_option[2])
				Font.ftSetPixelSize(CONFT, 17, 16)
				Font.ftSetPixelSize(CONTROL.fontABC, 70, 70)
				local selector_pix = 1
				local scroll_test = 1
				local largo_actual = CONTROL.LISTA_X
				if largo_actual >= 578 then
					largo_actual = 578
				end
				local pregunta = true
				while pregunta do
					CONTROL.FPS = Screen.getFPS(1)
					capturar(JOYSTICK_LIMITE)
					tiempo_de_scroll()
					m_dibujar_fondos()
					Graphics.drawRect(10, 16+CONTROL.Y_FIX_PAL, 619, 419, COLOR.BLANCO)
					Graphics.drawRect(12, 18+CONTROL.Y_FIX_PAL, 615, 415, COLOR.NEGRO)
					Font.ftPrint(CONFT, (CONTROL.ANCHO//2), 25+CONTROL.Y_FIX_PAL, 8, 601, 20, "-".. TEXT_M_CON[35] .."-", COLOR.BLANCO)

					-- Ejemplo de cuadros de texto. -------------------------------------
					Font.ftPrint(CONFT, (CONTROL.ANCHO//2), 53+CONTROL.Y_FIX_PAL, 8, 601, 112, "-".. TEXT_M_CON[36] .."-", COLOR.GRIS)
					Graphics.drawRect(358, 80+CONTROL.Y_FIX_PAL, 250, 40, COLOR.GRIS)
					Graphics.drawRect(396, 92+CONTROL.Y_FIX_PAL, 174, 18, Color.new(40, 40, 40))
					Font.ftPrint(CONTROL.fontARCA, (358+250//2), 92+CONTROL.Y_FIX_PAL, 8, 250, 25, TEXT_M_PRI[1], COLOR.BLANCO)
					Graphics.drawRect(30, 80+CONTROL.Y_FIX_PAL, 250, 40, COLOR.GRIS)
					Graphics.drawRect(68, 92+CONTROL.Y_FIX_PAL, 174, 18, Color.new(40, 40, 40))
					Font.ftPrint(CONTROL.fontARCA, 30+38, 92+CONTROL.Y_FIX_PAL, 0, 174, 25, TEXT_M_PRI[27], COLOR.BLANCO)

					-- Ejemplo de listas y scroll. --------------------------------------
					if CONTROL.ESPERA_CARGA_SCR == false then
						scroll_test = scroll_texto(scroll_test, example_text[1], pix_option[4])
					end
					if pix_option[4]+4 ~= string.len(example_text[2]) then
						example_text[2] = ""
						for tex_sc = 1, pix_option[4]-3 do
							example_text[2] = example_text[2] .. TEXT_M_CON[75]
						end
						example_text[2] = example_text[2] .."-0-.zip"
					end
					Font.ftPrint(CONFT, (CONTROL.ANCHO//2), 127+CONTROL.Y_FIX_PAL, 8, 601, 25, "-".. TEXT_M_CON[37] .."-", COLOR.GRIS)
					Graphics.drawRect(30, 154+CONTROL.Y_FIX_PAL, largo_actual, 25, COLOR.GRIS)
					Graphics.drawRect(30+largo_actual-28, 154+CONTROL.Y_FIX_PAL, 28, 22, Color.new(20, 100, 20))
					Font.ftPrint(CONTROL.fontARCA, 35, 155+CONTROL.Y_FIX_PAL, 0, largo_actual, 25, example_text[2], COLOR.BLANCO)
					Graphics.drawRect(30, 182+CONTROL.Y_FIX_PAL, 578, 18, COLOR.GRIS)
					Font.ftPrint(CONTROL.fontARCA, 35, 183+CONTROL.Y_FIX_PAL, 0, 573, 20, string.sub(example_text[1], scroll_test), COLOR.BLANCO)

					-- Ejemplo de sombras tras los textos. ------------------------------
					Font.ftPrint(CONFT, (CONTROL.ANCHO//2), 209+CONTROL.Y_FIX_PAL, 8, 597, 112, "-".. TEXT_M_CON[38] .."-", COLOR.GRIS)
					Graphics.drawRect(30, 239+CONTROL.Y_FIX_PAL, (pix_option[3]*pix_option[1]*(string.len(TEXT_M_CON[39])/2)/3), 20, Color.new(40, 40, 40))
					Graphics.drawRect(30, 261+CONTROL.Y_FIX_PAL, (pix_option[3]*pix_option[1]*(string.len(TEXT_M_PRI[5])/2)/3), 20, Color.new(40, 40, 40))
					Graphics.drawRect(30, 283+CONTROL.Y_FIX_PAL, (pix_option[3]*pix_option[1]*(string.len(TEXT_M_PRI[6])/2)/3), 20, Color.new(40, 40, 40))
					Font.ftPrint(CONTROL.fontARCA, 33, 240+CONTROL.Y_FIX_PAL, 0, 615, 405, TEXT_M_CON[39], COLOR.BLANCO)
					Font.ftPrint(CONTROL.fontARCA, 33, 262+CONTROL.Y_FIX_PAL, 0, 615, 405, TEXT_M_PRI[5], COLOR.BLANCO)
					Font.ftPrint(CONTROL.fontARCA, 33, 284+CONTROL.Y_FIX_PAL, 0, 615, 405, TEXT_M_PRI[6], COLOR.BLANCO)

					-- Ejemplos de salto de carácter. -----------------------------------
					Graphics.drawRect(493, 281, 74, 68, Color.new(40, 40, 40))
					Font.ftPrint(CONTROL.fontABC, 530, 323, 8, 70, 70, TEXT_M_CON[76], COLOR.BLANCO)

					-- Opciones de ajustes. ---------------------------------------------
					local espacio_linea2 = 291+((0)*20)+CONTROL.Y_FIX_PAL
					for contador = 1, #pix_option, 1 do
						espacio_linea = 291+((contador)*20)+CONTROL.Y_FIX_PAL
						if contador == selector_pix then
							Graphics.drawRect(30-2, espacio_linea-2, (5*16*(string.len(pix_txt[contador] .. pix_option[contador])/2)/3)+4, 23, Color.new(128, 128, 128))
							Graphics.drawRect(30, espacio_linea, (5*16*(string.len(pix_txt[contador] .. pix_option[contador])/2)/3), 19, Color.new(30, 30, 30))
							Font.ftPrint(CONFT, 30, espacio_linea, 0, 630, 405, pix_txt[contador] .. pix_option[contador], COLOR.BLANCO)
						else
							Font.ftPrint(CONFT, 30, espacio_linea, 0, 630, 405, pix_txt[contador] .. pix_option[contador], COLOR.GRIS)
						end
					end
					Graphics.drawScaleImage(PAD_IMG.CIRCLE, 30, 402+CONTROL.Y_FIX_PAL, 25, 25)
					Font.ftPrint(CONFT, 65, 405+CONTROL.Y_FIX_PAL, 0, 0, 8, TEXT_M_CON[40], COLOR.BLANCO)
					Graphics.drawScaleImage(PAD_IMG.SQUARE, 273, 402+CONTROL.Y_FIX_PAL, 25, 25)
					Font.ftPrint(CONFT, 308, 405+CONTROL.Y_FIX_PAL, 0, 0, 8, TEXT_M_CON[41], COLOR.BLANCO)
					Graphics.drawScaleImage(PAD_IMG.TRIANGLE, 478, 402+CONTROL.Y_FIX_PAL, 25, 25)
					Font.ftPrint(CONFT, 513, 405+CONTROL.Y_FIX_PAL, 0, 0, 8, TEXT_GEN[6], COLOR.BLANCO)

					-- Control de ajustes. ----------------------------------------------
					if (Pads.check(PAD, PAD_UP) or Pads.check(PAD, PAD_DOWN) or Left_Y ~= 1) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_MOVER, 1, false, nil)
						if Pads.check(PAD, PAD_UP) or Left_Y <= -90 then
							selector_pix = cambiar_valor(selector_pix, 1, 4, 1, false)
						elseif Pads.check(PAD, PAD_DOWN) or Left_Y >= 90 then
							selector_pix = cambiar_valor(selector_pix, 1, 4, 1, true)
						end
						JOYSTICK_LIMITE = control_FPS(1)
					elseif (Pads.check(PAD, PAD_LEFT) or Pads.check(PAD, PAD_RIGHT) or Left_X ~= 1) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_EJECUTAR, 1, false, nil)
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
						JOYSTICK_LIMITE = control_FPS(1)
					elseif Pads.check(PAD, PAD_CIRCLE) then
						repro_sfx(S_CANCELAR, 1, false, nil)
						pix_option[1], pix_option[2], pix_option[3], pix_option[4] = 16, 16, 5, 24
						Font.ftSetPixelSize(CONTROL.fontARCA, pix_option[1], pix_option[2])
						JOYSTICK_LIMITE = control_FPS(1)
					elseif Pads.check(PAD, PAD_SQUARE) then
						repro_sfx(S_EJECUTAR, 1, false, nil)
						font_x, font_Y, font_shadow, font_scroll = pix_option[1], pix_option[2], pix_option[3], pix_option[4]
						Font.ftSetPixelSize(CONTROL.fontARCA, font_x, font_Y)
						pregunta = false
					elseif Pads.check(PAD, PAD_TRIANGLE) then
						repro_sfx(S_CANCELAR, 1, false, nil)
						Font.ftSetPixelSize(CONTROL.fontARCA, font_x, font_Y)
						pregunta = false
					end
					refrescar(false)
				end
				Font.ftUnload(CONFT)

			-- Configurar fondo animado. ------------------------------------------------
			elseif selector == 24 and SPRITES.FONDO_ANI == true then
				local actual, pregunta, selec_opt = System.currentDirectory(), true, 1
				local ex_conf = {SPRITES.FONDO_N_COLUMNS; SPRITES.FONDO_N_ROWS; SPRITES.LAYER_TYPE; SPRITES.LAYER_SPEED; SPRITES.LAYER_MULTI;
				SPRITES.TRAN_TYPE; SPRITES.TRAN_LEVEL; SPRITES.TRAN_SPEED; SPRITES.SPIN_TYPE; SPRITES.SPIN_SPEED;};
				local tipo_conf_sel, opcio_conf, opcio_limit, opcio_limit_min = 2, {SPRITES.FONDO_N_COLUMNS, SPRITES.FONDO_N_ROWS}, {4, 4}, {1,1}
				local names_conf = {TEXT_M_CON[77], TEXT_M_CON[78]}
				local pos_fix_pre = {160, 116, 162, 170, 244, 238, 390}
				local act_lay_1 = {0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1}
				local act_lay_2 = {0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1}
				local act_lay_3 = {0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1}
				local act_lay_4 = {0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1}
				local lista_resp = {TEXT_M_CON[41], TEXT_GEN[6]}
				if SPRITES.LAYER == true then
					tipo_conf_sel = 8
					opcio_conf = {SPRITES.LAYER_TYPE; SPRITES.LAYER_SPEED; SPRITES.LAYER_MULTI; SPRITES.TRAN_TYPE; SPRITES.TRAN_LEVEL;
					SPRITES.TRAN_SPEED; SPRITES.SPIN_TYPE; SPRITES.SPIN_SPEED;};
					opcio_limit = {62, 62, 16, 20, 40, 16, 30, 62}
					opcio_limit_min = {0, 1, 1, 0, 1, 1, 0, 1}
					names_conf = {TEXT_M_CON[88]; TEXT_M_CON[89]; TEXT_M_CON[90]; TEXT_M_CON[91]; TEXT_M_CON[92]; TEXT_M_CON[93]; TEXT_M_CON[94]; TEXT_M_CON[95];};
					pos_fix_pre = {100, 254, 102, 110, 330, 20, 380}
				end
				while pregunta do
					CONTROL.FPS = Screen.getFPS(1)
					capturar(JOYSTICK_LIMITE)
					m_dibujar_fondos()
					local title_menu = TEXT_M_CON[87]
					if SPRITES.LAYER == false then
						title_menu = TEXT_M_CON[79] ..": ".. (opcio_conf[1]*opcio_conf[2])
					end
					if not (Pads.check(PAD, PAD_CIRCLE) and SPRITES.LAYER == true) or (SPRITES.LAYER == false and SPRITES.FONDO_ANI == true) then
					submenu_selector(names_conf, selec_opt, title_menu, pos_fix_pre[1], pos_fix_pre[5], false, pos_fix_pre[6], lista_resp, false, false, opcio_conf, pos_fix_pre[7])

					-- Vista previa para la configuración de las capas. -----------------
					if SPRITES.LAYER == true then
						dibujar_indicador(CONTROL.ANCHO-78, pos_fix_pre[5]-1, TEXT_M_STI[41], PAD_IMG.CIRCLE, 20, 20, 5, false)
						if opcio_conf[1] >= 41 and opcio_conf[1] <= 58 then
							names_conf[3] = TEXT_M_CON[63]
						elseif opcio_conf[1] >= 39 and opcio_conf[1] <= 40 then
							names_conf[3] = TEXT_M_CON[115]
						else
							names_conf[3] = TEXT_M_CON[90]
						end
						local valor_mos_t, valor_mos_r = opcio_conf[4], opcio_conf[7]
						local text_info, text_velo, multiplicador = " ", "0.01", opcio_conf[3]
						if opcio_conf[7] >= 16 then
							valor_mos_r = valor_mos_r-15
						end
						if selec_opt >= 1 and selec_opt <= 3 then
							text_info = TEXT_LAY_T[opcio_conf[1]+1]
							if opcio_conf[1] >= 41 and opcio_conf[1] <= 58 then
								multiplicador = 1
								text_info = text_info ..": ".. 50*opcio_conf[3]
							elseif opcio_conf[1] >= 39 and opcio_conf[1] <= 40 then
								multiplicador = 1
								text_info = text_info .." /R:".. 20*opcio_conf[3]
							end
							if (opcio_conf[2] >= 1 and opcio_conf[2] <= 9) and (opcio_conf[1] == 39 or opcio_conf[1] == 40) then
								text_velo = string.format("x %.3f", (tonumber("0.00".. opcio_conf[2]))*multiplicador)
							elseif (opcio_conf[2] >= 10 and opcio_conf[2] <= 18) and (opcio_conf[1] == 39 or opcio_conf[1] == 40) then
								text_velo = string.format("x %.2f", (tonumber("0.0".. opcio_conf[2]-9))*multiplicador)
							elseif (opcio_conf[2] >= 28 and opcio_conf[2] <= 36) and (opcio_conf[1] == 39 or opcio_conf[1] == 40) then
								text_velo = string.format("x %.2f", (tonumber("0.0".. opcio_conf[2]-27))*multiplicador)
							elseif (opcio_conf[2] >= 46 and opcio_conf[2] <= 54) and (opcio_conf[1] == 39 or opcio_conf[1] == 40) then
								text_velo = string.format("x %.2f", (tonumber("0.0".. opcio_conf[2]-45))*multiplicador)
							elseif (opcio_conf[2] >= 19 and opcio_conf[2] <= 27) and (opcio_conf[1] == 39 or opcio_conf[1] == 40) then
								text_velo = string.format("x %.2f", (tonumber("0.".. opcio_conf[2]-18))*multiplicador)
							elseif (opcio_conf[2] >= 37 and opcio_conf[2] <= 45) and (opcio_conf[1] == 39 or opcio_conf[1] == 40) then
								text_velo = string.format("x %.2f", (tonumber("0.".. opcio_conf[2]-36))*multiplicador)
							elseif (opcio_conf[2] >= 55 and opcio_conf[2] <= 62) and (opcio_conf[1] == 39 or opcio_conf[1] == 40) then
								text_velo = string.format("x %.2f", (tonumber("0.".. opcio_conf[2]-54))*multiplicador)
							elseif opcio_conf[2] >= 1 and opcio_conf[2] <= 9 then
								text_velo = string.format("x %.2f", (tonumber("0.".. opcio_conf[2]))*multiplicador)
							elseif opcio_conf[2] >= 10 then
								text_velo = "x ".. (opcio_conf[2]-9)*multiplicador ..".00"
							end
						elseif selec_opt >= 4 and selec_opt <= 6 then
							if opcio_conf[5] <= 8 then
								text_velo = ((16*opcio_conf[5])*100)//128 .."%"
								text_info = TEXT_M_CON[100]
							elseif opcio_conf[5] >= 9 and opcio_conf[5] <= 16 then
								text_velo = "0% - ".. ((16*(opcio_conf[5]-8))*100)//128 .."%"
								text_info = TEXT_M_CON[101]
							elseif opcio_conf[5] >= 17 and opcio_conf[5] <= 24 then
								text_velo = (((16*(opcio_conf[5]-16))*100)//128)//2 .."% - ".. ((16*(opcio_conf[5]-16))*100)//128 .."%"
								text_info = TEXT_M_CON[102]
							elseif opcio_conf[5] >= 25 and opcio_conf[5] <= 32 then
								text_velo = "0% - ".. ((16*(opcio_conf[5]-24))*100)//128 .."%"
								text_info = TEXT_M_CON[103]
							elseif opcio_conf[5] >= 33 and opcio_conf[5] <= 40 then
								text_velo = (((16*(opcio_conf[5]-32))*100)//128)//2 .."% - ".. ((16*(opcio_conf[5]-32))*100)//128 .."%"
								text_info = TEXT_M_CON[104]
							end
							if opcio_conf[4] == 0 then
								text_velo = "0%"
							end
						elseif selec_opt >= 7 and selec_opt <= 8 then
							text_info = TEXT_M_CON[97]
							if opcio_conf[7] >= 16 then
								text_info = TEXT_M_CON[98]
							end
							if opcio_conf[8] <= 9 then
								text_velo = "x 0.00".. opcio_conf[8]
							elseif opcio_conf[8] >= 10 and opcio_conf[8] <= 18 then
								text_velo = "x 0.0".. opcio_conf[8]-9
							elseif opcio_conf[8] >= 19 and opcio_conf[8] <= 27 then
								text_velo = "x 0.1".. opcio_conf[8]-18
							elseif opcio_conf[8] >= 28 and opcio_conf[8] <= 36 then
								text_velo = "x 0.0".. opcio_conf[8]-27
								text_info = TEXT_M_CON[99] .." 30°"
							elseif opcio_conf[8] >= 37 and opcio_conf[8] <= 45 then
								text_velo = "x 0.0".. opcio_conf[8]-36
								text_info = TEXT_M_CON[99] .." 180°"
							elseif opcio_conf[8] >= 46 and opcio_conf[8] <= 54 then
								text_velo = "x 0.0".. opcio_conf[8]-45
								text_info = TEXT_M_CON[99] .." 90°"
							elseif opcio_conf[8] >= 55 and opcio_conf[8] <= 62 then
								text_velo = "x 0.0".. opcio_conf[8]-54
								text_info = TEXT_M_CON[99] .." 360°"
							end
							if opcio_conf[7] == 0 then text_velo = "x 0.00" end
						end
						local largo_x, alto_y = SPRITES.FONDO_WIDTH_X, SPRITES.FONDO_HEIGHT_Y
						local cuadro_1 = {0, largo_x, 0, alto_y, 0, Color.new(128, 128, 128, 128)}
						local cuadro_2 = {largo_x, (largo_x*2), 0, alto_y, 0, Color.new(128, 128, 128, 128)}
						local cuadro_3 = {0, largo_x, alto_y, (alto_y*2), 0, Color.new(128, 128, 128, 128)}
						local cuadro_4 = {largo_x, (largo_x*2), alto_y, (alto_y*2), 0, Color.new(128, 128, 128, 128)}
						if act_lay_1[valor_mos_t+1] == 1 then cuadro_1[6] = Color.new(128, 128, 128, SPRITES.TRAN[1]) end
						if act_lay_2[valor_mos_t+1] == 1 then cuadro_2[6] = Color.new(128, 128, 128, SPRITES.TRAN[2]) end
						if act_lay_3[valor_mos_t+1] == 1 then cuadro_3[6] = Color.new(128, 128, 128, SPRITES.TRAN[3]) end
						if act_lay_4[valor_mos_t+1] == 1 then cuadro_4[6] = Color.new(128, 128, 128, SPRITES.TRAN[4]) end
						if act_lay_1[valor_mos_r+1] == 1 then cuadro_1[5] = SPRITES.SPIN end
						if act_lay_2[valor_mos_r+1] == 1 then cuadro_2[5] = SPRITES.SPIN end
						if act_lay_3[valor_mos_r+1] == 1 then cuadro_3[5] = SPRITES.SPIN end
						if act_lay_4[valor_mos_r+1] == 1 then cuadro_4[5] = SPRITES.SPIN end
						local x_l, y_l = 60, 42
						Graphics.drawImageExtended(LISTAS.FONDO, (435+(x_l/2))+x_l, 158+(y_l/2)+CONTROL.Y_FIX_PAL, cuadro_2[1], cuadro_2[3], cuadro_2[2], cuadro_2[4], x_l, y_l, cuadro_2[5], cuadro_2[6])
						Graphics.drawImageExtended(LISTAS.FONDO, 430+(x_l/2), (163+(y_l/2))+y_l+CONTROL.Y_FIX_PAL, cuadro_3[1], cuadro_3[3], cuadro_3[2], cuadro_3[4], x_l, y_l, cuadro_3[5], cuadro_3[6])
						Graphics.drawImageExtended(LISTAS.FONDO, (435+(x_l/2))+x_l, (163+(y_l/2))+y_l+CONTROL.Y_FIX_PAL, cuadro_4[1], cuadro_4[3], cuadro_4[2], cuadro_4[4], x_l, y_l, cuadro_4[5], cuadro_4[6])
						Graphics.drawImageExtended(LISTAS.FONDO, 430+(x_l/2), 158+(y_l/2)+CONTROL.Y_FIX_PAL, cuadro_1[1], cuadro_1[3], cuadro_1[2], cuadro_1[4], x_l, y_l, cuadro_1[5], cuadro_1[6])
						Graphics.drawRect(414, 136+CONTROL.Y_FIX_PAL, 2, 190, COLOR.BLANCO)
						Font.ftPrint(CONTROL.fontARCA, 430, 134+CONTROL.Y_FIX_PAL, 0, 210, 25, TEXT_M_CON[96], COLOR.BLANCO)
						Font.ftPrint(CONTROL.fontARCA, 430, 254+CONTROL.Y_FIX_PAL, 0, 210, 25, text_velo, COLOR.BLANCO)
						Font.ftPrint(CONTROL.fontARCA, 430, 278+CONTROL.Y_FIX_PAL, 0, 210, 25, text_info, COLOR.BLANCO)
					end

					-- Control de ajustes. ----------------------------------------------
					if Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_EJECUTAR, 1, false, nil)
						local nombre_img = salida_texto_dir(OPCIONES.FONDO_ENCONTRADOS[selec_fondo], true)
						local nombre_new = nombre_img
						local mismo_nombre = ""
						if SPRITES.LAYER == false then
							mismo_nombre = string.match(string.lower(nombre_img), opcio_conf[1] .."%a".. opcio_conf[2] .."_ani%.png", -11)
						elseif SPRITES.LAYER == true then
							mismo_nombre = string.match(nombre_img, "_".. cha_res(nil, opcio_conf[1]) .. cha_res(nil, opcio_conf[2]) ..
							cha_res(nil, opcio_conf[3]) .. cha_res(nil, opcio_conf[4]) .. cha_res(nil, opcio_conf[5]) .. cha_res(nil, opcio_conf[6]) ..
							cha_res(nil, opcio_conf[7]) .. cha_res(nil, opcio_conf[8]) .."_[Ll][Aa][Yy]%.[Pp][Nn][Gg]", -17)
						end
						if ((SPRITES.LAYER == false and not mismo_nombre) or (SPRITES.LAYER == true and not mismo_nombre)) and not (selec_fondo >= 1 and selec_fondo <= 3) then
							if SPRITES.LAYER == false then
								if string.match(string.lower(nombre_img), "%d.%d_ani.png", -11) then
									nombre_new = string.sub(nombre_img, 1, -12) .. opcio_conf[1] .."x".. opcio_conf[2] .."_ANI.png"
								else
									nombre_new = string.sub(nombre_img, 1, -9) .." ".. opcio_conf[1] .."x".. opcio_conf[2] .."_ANI.png"
								end
							elseif SPRITES.LAYER == true then
								if string.match(string.lower(nombre_img), "_[%w#][%w#][%w#][%w#][%w#][%w#][%w#][%w#]_lay%.png", -17) then
									nombre_new = string.sub(nombre_img, 1, -17) .. cha_res(nil, opcio_conf[1]) .. cha_res(nil, opcio_conf[2]) ..
									cha_res(nil, opcio_conf[3]) .. cha_res(nil, opcio_conf[4]) .. cha_res(nil, opcio_conf[5]) ..
									cha_res(nil, opcio_conf[6]) .. cha_res(nil, opcio_conf[7]) .. cha_res(nil, opcio_conf[8]) .."_LAY.png"
								else
									nombre_new = string.sub(nombre_img, 1, -9) .."_".. cha_res(nil, opcio_conf[1]) .. cha_res(nil, opcio_conf[2]) ..
									cha_res(nil, opcio_conf[3]) .. cha_res(nil, opcio_conf[4]) .. cha_res(nil, opcio_conf[5]) ..
									cha_res(nil, opcio_conf[6]) .. cha_res(nil, opcio_conf[7]) .. cha_res(nil, opcio_conf[8]) .."_LAY.png"
								end
							end
							local pregunta_2 = true
							while pregunta_2 do
								CONTROL.FPS = Screen.getFPS(1)
								capturar(JOYSTICK_LIMITE)
								m_dibujar_fondos()
								local submenu_lista = {TEXT_M_CON[81] ..":", nombre_img, TEXT_M_CON[82] ..":", nombre_new}
								local lista_resp = {TEXT_GEN[8], TEXT_GEN[6]}
								submenu_selector(submenu_lista, nil, TEXT_M_CON[80] .."?", 160, 294, true, (CONTROL.ANCHO//2), lista_resp, true, false, {}, nil)
								if Pads.check(PAD, PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
									repro_sfx(S_EJECUTAR, 1, false, nil)
									submenu_selector({}, nil, TEXT_M_CON[46], 160, 294, true, CONTROL.ANCHO//2, {}, false, true, {}, nil)
									-- Los fondos viven bajo "Roms/!Prism/Background". RUTA_GLOBAL lo
									-- resuelve, con "Multimedia/Others" como respaldo historico; la ruta fija
									-- que habia aqui se saltaba ese respaldo y el renombrado no ocurria.
									local dir_fondos = RUTA_GLOBAL("Background")
									if dir_fondos ~= nil and doesFileExist(dir_fondos .."/".. nombre_img) then
										System.rename(dir_fondos .."/".. nombre_img, dir_fondos .."/".. nombre_new)
									end
									buscar_fondos(nil, nil)
									if #OPCIONES.FONDO_ENCONTRADOS >= 1 and OPCIONES.FONDO_ENCONTRADOS ~= nil then
										for cont = 1, #OPCIONES.FONDO_ENCONTRADOS, 1 do
											if salida_texto_dir(OPCIONES.FONDO_ENCONTRADOS[cont], true) == nombre_new then
												selec_fondo = cont
											end
										end
										buscar_fondos(true, selec_fondo)
									end
									pregunta_2 = false
								elseif Pads.check(PAD, PAD_CIRCLE) and CONTROL.JOYSTICK_ON == false then
									repro_sfx(S_CANCELAR, 1, false, nil)
									pregunta_2 = false
								end
								refrescar(false)
							end
						end
						pregunta = false
						JOYSTICK_LIMITE = control_FPS(1)
					elseif ((Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) or (Pads.check(PAD, PAD_UP) or Left_Y <= -90) or (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90)) and CONTROL.JOYSTICK_ON == false then
						if (Pads.check(PAD, PAD_UP) or Left_Y <= -90) then
							selec_opt = cambiar_valor(selec_opt, 1, tipo_conf_sel, 1, false)
						elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) then
							selec_opt = cambiar_valor(selec_opt, 1, tipo_conf_sel, 1, true)
						elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
							opcio_conf[selec_opt] = cambiar_valor(opcio_conf[selec_opt], opcio_limit_min[selec_opt], opcio_limit[selec_opt], 1, false)
						elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
							opcio_conf[selec_opt] = cambiar_valor(opcio_conf[selec_opt], opcio_limit_min[selec_opt], opcio_limit[selec_opt], 1, true)
						end
						if (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) or (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
							if SPRITES.LAYER == false then
								SPRITES.FONDO_N_COLUMNS, SPRITES.FONDO_N_ROWS = opcio_conf[1], opcio_conf[2]
								SPRITES.FONDO_WIDTH_X = (Graphics.getImageWidth(LISTAS.FONDO)/opcio_conf[1])
								SPRITES.FONDO_HEIGHT_Y = (Graphics.getImageHeight(LISTAS.FONDO)/opcio_conf[2])
							elseif SPRITES.LAYER == true then
								SPRITES.LAYER_TYPE, SPRITES.LAYER_SPEED, SPRITES.LAYER_MULTI = opcio_conf[1], opcio_conf[2], opcio_conf[3]
								SPRITES.TRAN_TYPE, SPRITES.TRAN_LEVEL, SPRITES.TRAN_SPEED = opcio_conf[4], opcio_conf[5], opcio_conf[6]
								SPRITES.SPIN_TYPE, SPRITES.SPIN_SPEED = opcio_conf[7], opcio_conf[8]
								SPRITES.LAYER_X_1, SPRITES.LAYER_X_2, SPRITES.LAYER_X_3, SPRITES.LAYER_X_4 = 0, 0, 0, 0
								SPRITES.LAYER_Y_1, SPRITES.LAYER_Y_2, SPRITES.LAYER_Y_3, SPRITES.LAYER_Y_4 = 0, 0, 0, 0
								SPRITES.BACK_X, SPRITES.BACK_Y = 0, 0
								SPRITES.TRAN, SPRITES.SPIN = {128, 128, 128, 128}, 0.00
								SPRITES.TRAN_ALT, SPRITES.ZOOM, SPRITES.ANG = {false, false, false, false}, {0, false}, {0.00, 3.14}
								SPRITES.ALTERNATE, SPRITES.ALTERNATE_R, SPRITES.ALTERNATE_T, SPRITES.ACTIVATE_ALTER_T = false, false, false, true
							end
						end
						local kabal = 1 if Left_Y ~= 1 or Left_X ~= 1 then
							kabal = 2
						end
						if kabal == 1 then
							repro_sfx(S_MOVER, 1, true, nil)
						end
						JOYSTICK_LIMITE = control_FPS(kabal)
					elseif Pads.check(PAD, PAD_TRIANGLE) then
						repro_sfx(S_CANCELAR, 1, false, nil)
						SPRITES.FONDO_N_COLUMNS, SPRITES.FONDO_N_ROWS = ex_conf[1], ex_conf[2]
						SPRITES.FONDO_WIDTH_X = (Graphics.getImageWidth(LISTAS.FONDO)/SPRITES.FONDO_N_COLUMNS)
						SPRITES.FONDO_HEIGHT_Y = (Graphics.getImageHeight(LISTAS.FONDO)/SPRITES.FONDO_N_ROWS)
						SPRITES.LAYER_TYPE, SPRITES.LAYER_SPEED, SPRITES.LAYER_MULTI = ex_conf[3], ex_conf[4], ex_conf[5]
						SPRITES.TRAN_TYPE, SPRITES.TRAN_LEVEL, SPRITES.TRAN_SPEED = ex_conf[6], ex_conf[7], ex_conf[8]
						SPRITES.SPIN_TYPE, SPRITES.SPIN_SPEED = ex_conf[9], ex_conf[10]
						SPRITES.LAYER_X_1, SPRITES.LAYER_X_2, SPRITES.LAYER_X_3, SPRITES.LAYER_X_4 = 0, 0, 0, 0
						SPRITES.LAYER_Y_1, SPRITES.LAYER_Y_2, SPRITES.LAYER_Y_3, SPRITES.LAYER_Y_4 = 0, 0, 0, 0
						SPRITES.BACK_X, SPRITES.BACK_Y = 0, 0
						SPRITES.TRAN, SPRITES.SPIN = {128, 128, 128, 128}, 0.00
						SPRITES.TRAN_ALT, SPRITES.ZOOM, SPRITES.ANG = {false, false, false, false}, {0, false}, {0.00, 3.14}
						SPRITES.ALTERNATE, SPRITES.ALTERNATE_R, SPRITES.ALTERNATE_T, SPRITES.ACTIVATE_ALTER_T = false, false, false, true
						pregunta = false
					end
					end
					refrescar(false)
				end

			-- Configurar la carga de lista única. --------------------------------------
			elseif selector == 26 then
				local lis_free = TEXT_GEN[14]
				if OPCIONES.LIBERAR_LISTAS == 1 then
					lis_free = TEXT_GEN[13]
				end
				local pregunta = true
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					local lista_resp = {TEXT_GEN[8], TEXT_GEN[4]}
					local submenu_lista = {TEXT_M_CON[43], TEXT_M_CON[44], lis_free}
					submenu_selector(submenu_lista, nil, "-".. TEXT_M_CON[42] .."-", 160, 272, true, CONTROL.ANCHO//2, lista_resp, false, false, {}, nil)
					if Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_EJECUTAR, 1, false, nil)
						submenu_selector({}, nil, TEXT_M_CON[46], 160, 272, true, CONTROL.ANCHO//2, {}, false, true, {}, nil)
						if OPCIONES.LIBERAR_LISTAS == 0 then
							OPCIONES.LIBERAR_LISTAS = 1
							lis_free = TEXT_GEN[13]
							PRE_CARGADAS = {{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}}
							recargar_una(LISTAS.IDENTIDAD)
						else
							OPCIONES.LIBERAR_LISTAS = 0
							lis_free = TEXT_GEN[14]
							local ante_l = LISTAS.IDENTIDAD
							PRE_CARGADAS = {}
							recargar_todas()
							LISTAS.IDENTIDAD = ante_l
						end
						JOYSTICK_LIMITE = control_FPS(1)
					elseif Pads.check(PAD, PAD_TRIANGLE) then
						repro_sfx(S_CANCELAR, 1, false, nil)
						pregunta = false
					end
					refrescar(false)
				end

			-- Activar la selección de aplicación al ejecutar juegos. -------------------
			elseif selector == 29 then
				local pregunta = true
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					local lista_resp = {TEXT_GEN[8], TEXT_GEN[4]}
					local index_text = TEXT_GEN[14]
					if menu_run == 1 then
						index_text = TEXT_GEN[13]
					end
					submenu_selector({index_text}, nil, "-".. TEXT_M_CON[120] .."-", 160, 226, true, CONTROL.ANCHO//2, lista_resp, false, false, {}, nil)
					if Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_EJECUTAR, 1, false, nil)
						menu_run = cambiar_valor(menu_run, 0, 1, 1, true)
						JOYSTICK_LIMITE = control_FPS(1)
					elseif Pads.check(PAD, PAD_TRIANGLE) then
						repro_sfx(S_CANCELAR, 1, false, nil)
						pregunta = false
					end
					refrescar(false)
				end

			-- Configurar música de fondo. ----------------------------------------------
			elseif selector == 30 then
				local pregunta = true
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					local lista_resp = {TEXT_GEN[8], TEXT_GEN[4]}
					submenu_selector({mus_on}, nil, "-".. TEXT_M_CON[47] .."-", 160, 226, true, CONTROL.ANCHO//2, lista_resp, false, false, {}, nil)
					if Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_EJECUTAR, 1, false, nil)
						submenu_selector({}, nil, TEXT_M_CON[46], 160, 226, true, CONTROL.ANCHO//2, {}, false, true, {}, nil)
						if doesFileExist("System/Medias/Sound/Background/music.adp") then
							mus_on = TEXT_GEN[14]
							System.rename("System/Medias/Sound/Background/music.adp", "System/Medias/Sound/Background/music0.adp")
							Sound.freeADPCM(S_MUSICA)
							S_MUSICA = nil
							Sound.setADPCMVolume(2, 0)
						elseif doesFileExist("System/Medias/Sound/Background/music0.adp") then
							mus_on = TEXT_GEN[13]
							System.rename("System/Medias/Sound/Background/music0.adp", "System/Medias/Sound/Background/music.adp")
							S_MUSICA = verificar_sonidos(MUSICA, "System/Medias/Sound/Background/music.adp")
							set_volume()
						else
							mus_on = TEXT_M_PRI[15]
						end
						JOYSTICK_LIMITE = control_FPS(1)
					elseif Pads.check(PAD, PAD_TRIANGLE) then
						repro_sfx(S_CANCELAR, 1, false, nil)
						pregunta = false
					end
					refrescar(false)
				end

			-- Cambiar nivel de transparencia sobre los screenshots de fondo. -----------
			elseif selector == 32 and lista_config[32] == 1 then
				local pregunta = true
				local prev_tras = prev_back_tras
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					m_dibujar_fondos()
					if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true then
						Graphics.drawScaleImage(LISTAS.SCREENSHOT, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F, Color.new(128, 128, 128, prev_back_tras))
					else
						Graphics.drawScaleImage(LISTAS.COVER_DEFAULT, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F, Color.new(128, 128, 128, prev_back_tras))
					end
					local lista_resp = {TEXT_GEN[12], TEXT_GEN[6]}
					local index_text = "<- %".. (prev_back_tras*100)//128 .." ->"
					submenu_selector({index_text}, nil, "-".. TEXT_M_CON[119] .."-", 160, 226, true, CONTROL.ANCHO//2, lista_resp, false, false, {}, nil)
					if ((Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90)) and CONTROL.JOYSTICK_ON == false then
						if (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
							prev_back_tras = cambiar_valor(prev_back_tras, 1, 128, 1, false)
						elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
							prev_back_tras = cambiar_valor(prev_back_tras, 1, 128, 1, true)
						end
						local kabal = 1 if Left_X ~= 1 then
							kabal = 2
						end
						if kabal == 1 then
							repro_sfx(S_MOVER, 1, false, nil)
						end
						JOYSTICK_LIMITE = control_FPS(kabal)
					elseif Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_EJECUTAR, 1, false, nil)
						JOYSTICK_LIMITE = control_FPS(1)
						pregunta = false
					elseif Pads.check(PAD, PAD_TRIANGLE) then
						repro_sfx(S_CANCELAR, 1, false, nil)
						prev_back_tras = prev_tras
						pregunta = false
					end
					refrescar(false)
				end

			-- Mostrar índice junto a nombre de juego. ----------------------------------
			elseif selector == 35 then
				local pregunta = true
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					local lista_resp = {TEXT_GEN[8], TEXT_GEN[4]}
					local index_text = TEXT_GEN[14]
					if on_index == 1 then
						index_text = TEXT_GEN[13]
					end
					submenu_selector({index_text}, nil, "-".. TEXT_M_CON[105] .."-", 160, 226, true, CONTROL.ANCHO//2, lista_resp, false, false, {}, nil)
					if Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_EJECUTAR, 1, false, nil)
						submenu_selector({}, nil, TEXT_M_CON[46], 160, 226, true, CONTROL.ANCHO//2, {}, false, true, {}, nil)
						on_index = cambiar_valor(on_index, 0, 1, 1, true)
						-- Efecto inmediato Y guardado aparte. El valor viajaba hasta
						-- "nueva_conf" y de ahi a la casilla 42 de System.cfg, y
						-- despues de activarlo esa casilla seguia a 0. System.cfg son
						-- cuarenta y nueve numeros separados por espacios, releidos por
						-- posicion, y una de esas casillas guarda una RUTA: basta con
						-- que contenga un digito de mas o de menos para que todo lo que
						-- viene detras se lea corrido. No es sitio para un interruptor.
						OPCIONES.SEE_INDEX = on_index
						see_index_save(on_index)
						JOYSTICK_LIMITE = control_FPS(1)
					elseif Pads.check(PAD, PAD_TRIANGLE) then
						repro_sfx(S_CANCELAR, 1, false, nil)
						pregunta = false
					end
					refrescar(false)
				end
			end
			JOYSTICK_LIMITE = control_FPS(1)
		end

		-- Cambio entre páginas de configuración. ---------------------------------------
		if Pads.check(PAD, PAD_L1) or Pads.check(PAD, PAD_R1) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_NETX, 1, true, nil)
			if conf_numero == true then
				conf_numero = false
				selector = 23
				page = TEXT_M_CON[25]
			else
				conf_numero = true
				selector = 1
				page = TEXT_M_CON[24]
			end
			JOYSTICK_LIMITE = control_FPS(1)
		end

		-- Cambiar y guardar los estados de configuración. ------------------------------
		if Pads.check(PAD, PAD_CROSS) and (selector <= 3 or selector >= 7) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_EJECUTAR, 1, true, nil)
			if selector ~= 7 and selector ~= 23 and selector ~= 24 and selector ~= 27 and selector ~= 28 and selector ~= 31 and selector ~= 33 and selector <= 35 then
				-- Activa / Desactiva las opciones. -------------------------------------
				if lista_config[selector] == 0 then
					lista_config[selector] = 1
				elseif lista_config[selector] == 1 then
					lista_config[selector] = 0
				end

				-- Activa / Desactiva los directorios completos en APPS. ----------------
				if selector == 29 then
					OPCIONES.APPS_MENU_FULL_PATH = lista_config[29]
					OPCIONES.DIR_EXTRAS_ON = lista_config[35]
					PRE_CARGADAS[13] = crear_listas(13, PRE_CARGADAS[13])
					desactivados(nil)
				end

				-- Activa / Desactiva los directorios extras para APPS y PS2. -----------
				if selector == 35 then
					OPCIONES.APPS_MENU_FULL_PATH = lista_config[29]
					OPCIONES.DIR_EXTRAS_ON = lista_config[35]
					PRE_CARGADAS[13] = crear_listas(13, PRE_CARGADAS[13])
					PRE_CARGADAS[15] = crear_listas(15, PRE_CARGADAS[15])
					desactivados(nil)
				end

			-- Cambia el estilo de la lista. --------------------------------------------
			elseif selector == 7 then
				estilo_lista = cambiar_valor(estilo_lista, 1, 7, 1, true)

			-- Cambia la fuente de texto. -----------------------------------------------
			elseif selector == 23 then
				selec_fuente = cambiar_valor(selec_fuente, 1, #OPCIONES.FUENTES_ENCONTRADAS, 1, true)
				cambia_fuente()

			-- Cambia el fondo de pantalla. ---------------------------------------------
			elseif selector == 24 then
				selec_fondo = cambiar_valor(selec_fondo, 1, #OPCIONES.FONDO_ENCONTRADOS, 1, true)
				buscar_fondos(true, selec_fondo)

			-- Seleccionar dónde se buscará la salida de Prism. -----------------
			elseif selector == 27 then
				selec_dir = cambiar_valor(selec_dir, 0, 3, 1, true)
				cambiar_medio()

			-- Cambia la salida de Prism. ---------------------------------------
			elseif selector == 28 then
				if selec_dir ~= 0 then
					marcar_directorio(false, selec_dir, m_dibujar_fondos)
					selec_dir = OPCIONES.SALIDA_RETROLANCHER_ON
					lista_config[28] = OPCIONES.SALIDA_RETROLANCHER
					lista_texto_config[28] = OPCIONES.SALIDA_RETROLANCHER
				end

			-- Cambia el modo de video y reconfigura las opciones de RetroArch. ---------
			elseif selector == 33 then
				local pregunta = true
				Pads.rumble(0, 0, 0)
				local mode_act, prev = 1, lista_config[33]
				if lista_config[33] == 1 then
					mode_act = 2
				end
				local mode_vi_tex = {"NTSC", "PAL"}
				local submenu_lista = {TEXT_M_PRI[25], TEXT_M_CON[48], TEXT_M_CON[49] ..".", TEXT_M_PRI[26] .."."}
				local text_prin = "-".. TEXT_M_CON[52] .." ".. mode_vi_tex[mode_act] .."?-"
				local lista_resp = {TEXT_GEN[8], TEXT_GEN[6]}
				submenu_selector(submenu_lista, nil, text_prin, 160, 294, true, CONTROL.ANCHO//2, lista_resp, false, false, {}, nil)
				refrescar(false)
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					if Pads.check(PAD, PAD_SQUARE) then
						repro_sfx(S_EJECUTAR, 1, false, nil)
						lista_config[33] = cambiar_valor(lista_config[33], 0, 1, 1, true)
						if lista_config[33] == 0 then
							Screen.setMode(NTSC, 640, 448, CT24, INTERLACED, FIELD)
							CONTROL.ALTO_F = 448
							CONTROL.Y_FIX_PAL = 0
							OPCIONES.VIDEO_MODE = 0
						elseif lista_config[33] == 1 then
							Screen.setMode(PAL, 640, 512, CT24, INTERLACED, FIELD)
							CONTROL.ALTO_F = 512
							CONTROL.Y_FIX_PAL = 32
							OPCIONES.VIDEO_MODE = 1
						end
						OPCIONES.VIDEO_MODE = lista_config[33]
						rest()
						noob = false
						reinicio = true
						pregunta = false
						clean = false
						indi_rest_RL = 20
					elseif Pads.check(PAD, PAD_TRIANGLE) then
						repro_sfx(S_CANCELAR, 1, false, nil)
						lista_config[33] = prev
						clean = false
						pregunta = false
						indi_rest_RL = 0
					end
					refrescar(true)
				end

			-- Configurar lenguaje de Prism. ------------------------------------
			elseif selector == 36 then
				local actual, pregunta, selec_lang = System.currentDirectory(), true, 1
				if doesFileExist(actual .."/System/Defaults/SPA") then
					selec_lang = 2
				elseif doesFileExist(actual .."/System/Defaults/POR") then
					selec_lang = 3
				end
				local lenguaje_pre = {"Change language?", "¿Cambiar de idioma?", "Alterar idioma?"}
				local lenguaje = {"English", "Español", "Português"}
				local lenguaje_op1 = {"Change", "Cambiar", "Mudar"}
				local lenguaje_op2 = {"Cancel", "Cancelar", "Cancelar"}
				local lenguaje_name = {"ENG", "SPA", "POR"}
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					local submenu_lista = {"<- ".. lenguaje[selec_lang] .." ->"}
					local lista_resp = {lenguaje_op1[selec_lang], lenguaje_op2[selec_lang]}
					submenu_selector(submenu_lista, nil, lenguaje_pre[selec_lang], 160, 224, true, CONTROL.ANCHO//2, lista_resp, false, false, {}, nil)
					if Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_EJECUTAR, 1, false, nil)
						if doesFileExist(actual .."/System/Defaults/SPA") and selec_lang ~= 2 then
							System.rename(actual .."/System/Defaults/SPA", actual .."/System/Defaults/".. lenguaje_name[selec_lang])
							lang_select()
						elseif doesFileExist(actual .."/System/Defaults/POR") and selec_lang ~= 3 then
							System.rename(actual .."/System/Defaults/POR", actual .."/System/Defaults/".. lenguaje_name[selec_lang])
							lang_select()
						elseif doesFileExist(actual .."/System/Defaults/ENG") and selec_lang ~= 1 then
							System.rename(actual .."/System/Defaults/ENG", actual .."/System/Defaults/".. lenguaje_name[selec_lang])
							lang_select()
						end
						submenu_selector({}, nil, TEXT_M_CON[46], 160, 224, true, CONTROL.ANCHO//2, {}, false, true, {}, nil)
						Graphics.freeImage(LISTAS.COVER_DEFAULT)
						Graphics.freeImage(LISTAS.SCREENSHOT_DEFAULT)
						LISTAS.COVER_DEFAULT = Graphics.loadImage(verif_img("System/Medias/Default/".. img_lang("COVER_DEFAULT", true) ..".png"));
						LISTAS.SCREENSHOT_DEFAULT = Graphics.loadImage(verif_img("System/Medias/Default/".. img_lang("SCREENSHOT_DEFAULT", false) ..".png"));
						pregunta = false
						rest()
						noob = false
						JOYSTICK_LIMITE = control_FPS(1)
					elseif ((Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90)) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_MOVER, 1, false, nil)
						if (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) then
							selec_lang = cambiar_valor(selec_lang, 1, 3, 1, false)
						elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
							selec_lang = cambiar_valor(selec_lang, 1, 3, 1, true)
						end
						JOYSTICK_LIMITE = control_FPS(1)
					elseif Pads.check(PAD, PAD_TRIANGLE) then
						repro_sfx(S_CANCELAR, 1, false, nil)
						pregunta = false
					end
					refrescar(false)
				end

			-- Reinicia todas las configuraciones. --------------------------------------
			elseif selector == 37 then
				local pregunta = true
				Pads.rumble(0, 0, 0)
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					local eliminar_partidas = TEXT_GEN[9]
					if clean == true then
						eliminar_partidas = TEXT_GEN[10]
					end
					local submenu_lista = {"-".. TEXT_M_CON[51] .."-", eliminar_partidas}
					local text_prin = "-".. TEXT_M_CON[53] .."-"
					local lista_resp = {TEXT_GEN[11], TEXT_GEN[6]}
					submenu_selector(submenu_lista, nil, text_prin, 160, 245, true, CONTROL.ANCHO//2, lista_resp, false, false, {}, nil)
					Graphics.drawScaleImage(PAD_IMG.L1, CONTROL.ANCHO//2-64, 214+CONTROL.Y_FIX_PAL, 30, 30)
					Graphics.drawScaleImage(PAD_IMG.R1, CONTROL.ANCHO//2+32, 214+CONTROL.Y_FIX_PAL, 30, 30)
					if Pads.check(PAD, PAD_R1) and CONTROL.JOYSTICK_ON == false then
						repro_sfx(S_NETX, 1, false, nil)
						if clean == false then
							clean = true
						else
							clean = false
						end
						JOYSTICK_LIMITE = control_FPS(1)
					elseif Pads.check(PAD, PAD_SQUARE) then
						repro_sfx(S_EJECUTAR, 1, false, nil)
						noob = false
						reinicio = true
						pregunta = false
					elseif Pads.check(PAD, PAD_TRIANGLE) then
						repro_sfx(S_CANCELAR, 1, false, nil)
						pregunta = false
						clean = false
						JOYSTICK_LIMITE = control_FPS(1)
					end
					refrescar(false)
				end

			-- Muestra los créditos. ----------------------------------------------------
			elseif selector == 38 then
				creditos(m_dibujar_fondos)
			end

			-- Desactiva "RGB" si la personalización está activada. ---------------------
			if (lista_config[2] == 0 or lista_config[3] == 1) and lista_config[1] == 1 then
				lista_config[1] = 0
			end

			-- Aplica los cambios de colores al estilo. ---------------------------------
			if lista_config[3] == 1 then
				color_emu(0, lista_config[2], lista_config[3])
			elseif lista_config[3] == 0 then
				color_emu(LISTAS.IDENTIDAD, lista_config[2], lista_config[3])
			end
			if (selector <= 3 or selector >= 1) and lista_config[1] == 0 and lista_config[2] == 0 and lista_config[3] == 0 then
				color_emu(0, lista_config[2], lista_config[3])
			elseif (selector <= 3 or selector >= 1) and lista_config[1] == 0 and lista_config[2] == 1 and lista_config[3] == 0 then
				color_emu(LISTAS.IDENTIDAD, lista_config[2], lista_config[3])
			end

			-- Activa / Desactiva los sonidos y la vibración. ---------------------------
			OPCIONES.SOUND_ON = lista_config[30]
			OPCIONES.VIBRATION_ON = lista_config[34]
			JOYSTICK_LIMITE = control_FPS(1)
		end

		-- Guardar todas las configuraciones. -------------------------------------------
		if Pads.check(PAD, PAD_START) and CONTROL.JOYSTICK_ON == false then
			repro_sfx(S_EJECUTAR, 1, true, nil)
			Pads.rumble(0, 0, 0)
			OPCIONES.RGB_ON = lista_config[1]
			OPCIONES.FONDO_RGB_ON = lista_config[2]
			OPCIONES.FONDO_RGB_FIJO_ON = lista_config[3]
			CONTROL.ESTILO = estilo_lista
			definir_estilos()
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
			SISTEMAS.ATARILYNX_ON = lista_config[16]
			if SISTEMAS.ATARILYNX_ON == 0 then
				PRE_CARGADAS[9] = {}
			end
			SISTEMAS.SEGASG1000_ON = lista_config[17]
			if SISTEMAS.SEGASG1000_ON == 0 then
				PRE_CARGADAS[10] = {}
			end
			SISTEMAS.NEOGEOPOCKET_ON = lista_config[18]
			if SISTEMAS.NEOGEOPOCKET_ON == 0 then
				PRE_CARGADAS[11] = {}
			end
			SISTEMAS.SUPERFAMICOM_ON = lista_config[19]
			if SISTEMAS.SUPERFAMICOM_ON == 0 then
				PRE_CARGADAS[12] = {}
			end
			SISTEMAS.APPS_ON = lista_config[20]
			if SISTEMAS.APPS_ON == 0 then
				PRE_CARGADAS[13] = {}
			end
			SISTEMAS.PLAYSTATION_ON = lista_config[21]
			if SISTEMAS.PLAYSTATION_ON == 0 then
				PRE_CARGADAS[14] = {}
			end
			SISTEMAS.PLAYSTATION2_ON = lista_config[22]
			if SISTEMAS.PLAYSTATION2_ON == 0 then
				PRE_CARGADAS[15] = {}
			end
			OPCIONES.CAMBIO_FUENTE_ON = selec_fuente
			OPCIONES.FUENTES_ENCONTRADAS = {}
			OPCIONES.CAMBIO_FONDO_ON = selec_fondo
			OPCIONES.FONDO_ENCONTRADOS = {}
			OPCIONES.GUI_LIMPIA_ON = lista_config[25]
			OPCIONES.LIMITADOR_RAM_ON = lista_config[26]
			if doesFileExist(OPCIONES.SALIDA_RETROLANCHER) and string.lower(string.sub(OPCIONES.SALIDA_RETROLANCHER, -4)) == ".elf" then
				OPCIONES.SALIDA_RETROLANCHER_ON = selec_dir
				guardar_directorio_elf(false)
			else
				OPCIONES.SALIDA_RETROLANCHER_ON = 0
				OPCIONES.SALIDA_RETROLANCHER = "PS2 SYSTEM MENU"
				guardar_directorio_elf(false)
			end
			OPCIONES.APPS_MENU_FULL_PATH = lista_config[29]
			OPCIONES.SOUND_ON = lista_config[30]
			OPCIONES.SOUND_VOLUME = volume
			OPCIONES.SCREENSHOT_BACK_ON = lista_config[32]
			if OPCIONES.SCREENSHOT_BACK_ON == 0 then 
				OPCIONES.SCREENSHOT_BACK_TR = 128
			elseif OPCIONES.SCREENSHOT_BACK_ON == 1 then
				OPCIONES.SCREENSHOT_BACK_TR = prev_back_tras
			end
			OPCIONES.VIDEO_MODE = lista_config[33]
			OPCIONES.VIBRATION_ON = lista_config[34]
			OPCIONES.VIBRATION = false
			OPCIONES.VIBRATION_MODE = nil
			OPCIONES.DIR_EXTRAS_ON = lista_config[35]
			OPCIONES.SEE_INDEX = on_index
			-- Tambien por esta via: el interruptor se guarda tanto si se pulsa como si
			-- se confirma el menu entero. Su fichero propio es la unica fuente fiable.
			see_index_save(on_index)
			CAMBIOS_EMUS.TRAS = tras_demo
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
			CONTROL.SPRITE_ALTO = CONTROL.SPRITE_ALTO + CONTROL.Y_FIX_PAL
			if ini_sprite == 1 and CONTROL.ESTILO ~= 7 then
				CONTROL.CUSTOM_SPRITE = true
			end
			OPCIONES.SPRITE_ON = ini_sprite
			OPCIONES.FONT_PIXEL_X, OPCIONES.FONT_PIXEL_Y, OPCIONES.FONT_SHADOW, OPCIONES.SCROLL_MIN = font_x, font_Y, font_shadow, font_scroll
			Font.ftSetPixelSize(CONTROL.fontARCA, OPCIONES.FONT_PIXEL_X, OPCIONES.FONT_PIXEL_Y)
			Font.ftSetPixelSize(CONTROL.fontABC, 70, 70)
			OPCIONES.RUN_DEFAULT = menu_run
			COLOR.CC_BACK[1], COLOR.CC_BACK[2], COLOR.CC_BACK[3], COLOR.CC_BACK[4] = cc_back_1, cc_back_2, cc_back_3, cc_back_4
			desactivados(nil)
			guardar_opciones()
			cambio_realizado = false
			noob = false
		end

		-- Controlar el movimiento vertical por las opciones de configuración. ----------
		if (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90 or Pads.check(PAD, PAD_R2)) or (Pads.check(PAD, PAD_UP) or Left_Y <= -90 or Pads.check(PAD, PAD_L2)) and CONTROL.JOYSTICK_ON == false then
			if Pads.check(PAD, PAD_R2) and conf_numero == true then
				selector = cambiar_valor(selector, 1, 22, 4, true)
			elseif Pads.check(PAD, PAD_R2) and conf_numero == false then
				selector = cambiar_valor(selector, 23, #lista_config, 4, true)
			elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) and conf_numero == true then
				selector = cambiar_valor(selector, 1, 22, 1, true)
			elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) and conf_numero == false then
				selector = cambiar_valor(selector, 23, #lista_config, 1, true)
			elseif Pads.check(PAD, PAD_L2) and conf_numero == true then
				selector = cambiar_valor(selector, 1, 22, 4, false)
			elseif Pads.check(PAD, PAD_L2) and conf_numero == false then
				selector = cambiar_valor(selector, 23, #lista_config, 4, false)
			elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90) and conf_numero == true then
				selector = cambiar_valor(selector, 1, 22, 1, false)
			elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90) and conf_numero == false then
				selector = cambiar_valor(selector, 23, #lista_config, 1, false)
			end

			-- vibración y cambio de velocidades. ---------------------------------------
			local shake_type = false
			if (Pads.check(PAD, PAD_UP) or Left_Y <= -90) then
				shake_type = true
			end
			local kabal = 1 if Left_Y ~= 1 then
				kabal = 2
			end
			if kabal == 1 then
				repro_sfx(S_MOVER, 1, true, shake_type)
			end
			JOYSTICK_LIMITE = control_FPS(kabal)
		end

		-- Controlar el movimiento horizontal por las opciones de configuración. --------
		if ((Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90)) and ((selector >= 4 and selector <= 24) or selector == 27 or selector == 31) and CONTROL.JOYSTICK_ON == false then
			-- Realizar cambios en el volumen. ------------------------------------------
			if (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and selector == 31 then
				volume = cambiar_valor(volume, 1, 100, 1, false)
			elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and selector == 31 then
				volume = cambiar_valor(volume, 1, 100, 1, true)

			-- Cambia la fuente de texto.------------------------------------------------
			elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and selector == 23 then
				selec_fuente = cambiar_valor(selec_fuente, 1, #OPCIONES.FUENTES_ENCONTRADAS, 1, false)
				cambia_fuente()
			elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and selector == 23 then
				selec_fuente = cambiar_valor(selec_fuente, 1, #OPCIONES.FUENTES_ENCONTRADAS, 1, true)
				cambia_fuente()

			-- Cambia el fondo de pantalla.----------------------------------------------
			elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and selector == 24 then
				selec_fondo = cambiar_valor(selec_fondo, 1, #OPCIONES.FONDO_ENCONTRADOS, 1, false)
				buscar_fondos(true, selec_fondo)
			elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and selector == 24 then
				selec_fondo = cambiar_valor(selec_fondo, 1, #OPCIONES.FONDO_ENCONTRADOS, 1, true)
				buscar_fondos(true, selec_fondo)

			-- Cambia la salida de Prism. ---------------------------------------
			elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and selector == 27 then
				selec_dir = cambiar_valor(selec_dir, 0, 3, 1, false)
				cambiar_medio()
			elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and selector == 27 then
				selec_dir = cambiar_valor(selec_dir, 0, 3, 1, true)
				cambiar_medio()

			-- Realizar cambios en los colores. -----------------------------------------
			elseif Pads.check(PAD, PAD_SQUARE) and (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and lista_config[3] == 1 and selector >= 4 and selector <= 6 then
				tras_demo = cambiar_valor(tras_demo, 0, 120, 1, false)
			elseif Pads.check(PAD, PAD_SQUARE) and (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and lista_config[3] == 1 and selector >= 4 and selector <= 6 then
				tras_demo = cambiar_valor(tras_demo, 0, 120, 1, true)
			elseif Pads.check(PAD, PAD_TRIANGLE) and (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and lista_config[3] == 1 and selector >= 4 and selector <= 6 then
				OPCIONES.COLOR_LISTA_B = cambiar_valor(OPCIONES.COLOR_LISTA_B, 50, 128, 1, false)
			elseif Pads.check(PAD, PAD_TRIANGLE) and (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and lista_config[3] == 1 and selector >= 4 and selector <= 6 then
				OPCIONES.COLOR_LISTA_B = cambiar_valor(OPCIONES.COLOR_LISTA_B, 50, 128, 1, true)
			elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and selector == 4 then
				OPCIONES.R = cambiar_valor(OPCIONES.R, 0, 128, 1, false)
			elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and selector == 5 then
				OPCIONES.G = cambiar_valor(OPCIONES.G, 11, 128, 1, false)
			elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and selector == 6 then
				OPCIONES.B = cambiar_valor(OPCIONES.B, 11, 128, 1, false)
			elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and selector == 4 then
				OPCIONES.R = cambiar_valor(OPCIONES.R, 0, 128, 1, true)
			elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and selector == 5 then
				OPCIONES.G = cambiar_valor(OPCIONES.G, 11, 128, 1, true)
			elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and selector == 6 then
				OPCIONES.B = cambiar_valor(OPCIONES.B, 11, 128, 1, true)

			-- Realizar cambios de estilos. ---------------------------------------------
			elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and selector == 7 then
				estilo_lista = cambiar_valor(estilo_lista, 1, 7, 1, false)
			elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and selector == 7 then
				estilo_lista = cambiar_valor(estilo_lista, 1, 7, 1, true)

			-- Realizar salto lateral en sistemas. --------------------------------------
			elseif (selector >= 8 and selector <= 22) and (selector <= 14 and selector >= 8) then
				selector = selector+8
			elseif (selector >= 8 and selector <= 22) and (selector <= 22 and selector >= 16) then
				selector = selector-8
			elseif selector == 15 then
				selector = selector+7
			end

			-- Aplicar modificaciones / volumen / colores. ------------------------------
			if selector == 31 then
				OPCIONES.SOUND_VOLUME = volume
				set_volume()
			elseif selector >= 4 and selector <= 6 then
				if tras_demo == 0 then
					color_demo = Color.new(OPCIONES.R, OPCIONES.G, OPCIONES.B)
				else
					color_demo = Color.new(OPCIONES.R, OPCIONES.G, OPCIONES.B, tras_demo)
				end
				if lista_config[3] == 1 then
					color_emu(0, lista_config[2], lista_config[3])
				end
			end

			-- Vibración y cambio de velocidades. ---------------------------------------
			local shake_type = true
			if (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) then
				shake_type = false
			end
			local kabal = 1 if Left_X ~= 1 and selector ~= 23 and selector ~= 24 then
				kabal = 2
			end
			if selector ~= 7 and selector ~= 23 and selector ~= 24 and kabal == 1 then
				repro_sfx(S_MOVER, 1, true, shake_type)
			elseif selector == 7 or selector == 23 or selector == 24 and kabal == 1 then
				repro_sfx(S_EJECUTAR, 1, true, shake_type)
			end
			JOYSTICK_LIMITE = control_FPS(kabal)
		end
		end

		-- Mostrar todo en pantalla. ----------------------------------------------------
		Screen.clear(CAMBIOS_EMUS.COLOR_EMU_BACK)
		m_dibujar_fondos()
		local ajuste_m = 5
		Graphics.drawRect(12, (28-ajuste_m)+CONTROL.Y_FIX_PAL, 615, 423, COLOR.NEGRO_T)

		-- Muestra y determina el estado de cada página. --------------------------------
		local page_long = calcular_sombras(page)
		Graphics.drawScaleImage(PAD_IMG.L1, (CONTROL.ANCHO//2)-104, (-1)+CONTROL.Y_FIX_PAL, 30, 26)
		Graphics.drawScaleImage(PAD_IMG.R1, (CONTROL.ANCHO//2)+74, (-1)+CONTROL.Y_FIX_PAL, 30, 26)
		Graphics.drawRect((CONTROL.ANCHO//2)-(page_long//2), 2+CONTROL.Y_FIX_PAL, page_long, 20, COLOR.NEGRO_T)
		Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), 3+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 25, page, COLOR.BLANCO_LISTA)
		local contador, ini = 1, 1
		if conf_numero == true then
			ini = 1
		else
			ini = 23
		end

		-- Controla el scroll. ----------------------------------------------------------
		if CONTROL.ESPERA_CARGA_SCR == false then
			LISTAS.SCROLL_TEX = scroll_texto(LISTAS.SCROLL_TEX, lista_texto_config[28], 44)
		end

		-- Muestra las opciones y su estado. --------------------------------------------
		for estado = ini, #lista_config do
			-- Define el estado. --------------------------------------------------------
			local text_especial = {TEXT_M_CON[54]; "MC0:", "MC1:"; local_disp; TEXT_M_CON[56]; TEXT_M_CON[57]; TEXT_M_CON[58]; TEXT_M_CON[59];
			TEXT_M_CON[60]; TEXT_M_CON[61]; TEXT_M_CON[62];};
			local acti = TEXT_GEN[13]
			if lista_config[estado] == 0 then
				acti = TEXT_GEN[14]
			end
			if estado == 7 and conf_numero == true then
				acti = text_especial[estilo_lista+4]
			elseif estado >= 8 and estado <= 22 and conf_numero == true then
				if lista_config[estado] == 0 then
					acti = TEXT_GEN[2]
				else
					acti = TEXT_GEN[3]
				end
			elseif estado == 27 and conf_numero == false then
				acti = text_especial[selec_dir+1]
			elseif estado == 33 and conf_numero == false then
				if lista_config[estado] == 0 then
					acti = "NTSC"
				else
					acti = "PAL"
				end
			end

			-- Muestra todas las opciones de la página y su estado. ---------------------
			local espacio_linea = ((8-ajuste_m)+(contador)*25)+CONTROL.Y_FIX_PAL
			if estado <= 7 or estado >= 23 then
				local color_mos = COLOR.BLANCO_LISTA
				if estado == selector then
					color_mos = CAMBIOS_EMUS.COLOR_EMU
					Graphics.drawRect(12+5, espacio_linea-3, 610-7, 25, COLOR.NEGRO_T)
				end
				if estado == 28 then
					Font.ftPrint(CONTROL.fontARCA, 22, espacio_linea, 0, 601, 8, "".. string.sub(lista_texto_config[estado], LISTAS.SCROLL_TEX), color_mos)
				else
					Font.ftPrint(CONTROL.fontARCA, 22, espacio_linea, 0, 0, 8, "".. lista_texto_config[estado], color_mos)
				end
				if estado >= 4 and estado <= 6 then
					Graphics.drawRect(558, (119-ajuste_m)+CONTROL.Y_FIX_PAL, 45, 45, color_demo)
					if estado == 4 then
						Font.ftPrint(CONTROL.fontARCA, 498, espacio_linea, 0, 0, 8, "".. OPCIONES.R, color_mos)
					elseif estado == 5 then
						Font.ftPrint(CONTROL.fontARCA, 498, espacio_linea, 0, 0, 8, "".. OPCIONES.G, color_mos)
					elseif estado == 6 then
						Font.ftPrint(CONTROL.fontARCA, 498, espacio_linea, 0, 0, 8, "".. OPCIONES.B, color_mos)
					end
				else
					if estado == 7 then
						Font.ftPrint(CONTROL.fontARCA, 498, espacio_linea, 0, 0, 8, "".. acti, color_mos)
					elseif estado == 23 then
						Font.ftPrint(CONTROL.fontARCA, 498, espacio_linea, 0, 0, 8, "".. selec_fuente, color_mos)
					elseif estado == 24 then
						Font.ftPrint(CONTROL.fontARCA, 498, espacio_linea, 0, 0, 8, "".. selec_fondo, color_mos)
					elseif estado == 27 or estado == 33 then
						Font.ftPrint(CONTROL.fontARCA, 498, espacio_linea, 0, 0, 8, "".. acti, color_mos)
					elseif estado == 31 then
						Font.ftPrint(CONTROL.fontARCA, 498, espacio_linea, 0, 0, 8, "".. volume, color_mos)
					elseif estado == 28 or (estado >= 36 and estado <= 38) then
						Font.ftPrint(CONTROL.fontARCA, 16, espacio_linea, 0, 0, 8, "", color_mos)
					else
						Font.ftPrint(CONTROL.fontARCA, 498, espacio_linea, 0, 0, 8, acti, color_mos)
					end
				end
				if estado == selector and ((estado >= 4 and estado <= 7) or estado == 23 or (estado == 24 and SPRITES.FONDO_ANI == true) or estado == 26 or estado == 29 or estado == 30 or (estado == 32 and lista_config[32] == 1) or estado == 35) then
					local fix_sel = 0
					if estado == 7 and estilo_lista ~= 7 and ini_sprite == 1 then
						fix_sel = 40
					end
					Graphics.drawScaleImage(PAD_IMG.SELECT_S, 464-fix_sel, espacio_linea, 20, 20)
				end
			else
				Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), (206-ajuste_m)+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 25, "- ".. TEXT_M_CON[64] .." -", COLOR.BLANCO_LISTA)
				local color_mos = COLOR.BLANCO_LISTA
				local x_recta, y_recta_fix, x_name, x_act, x_img = 17, 21, 22, 261, 232
				if estado >= 16 then
					x_recta, y_recta_fix, x_name, x_act, x_img = 332, -179, 337, 576, 547
				end
				if estado == selector then
					color_mos = CAMBIOS_EMUS.COLOR_EMU
					Graphics.drawRect(x_recta, espacio_linea-3+(y_recta_fix), 293-7, 25, COLOR.NEGRO_T)
					Font.ftPrint(CONTROL.fontARCA, x_name, espacio_linea+(y_recta_fix), 0, 0, 8, "".. lista_texto_config[estado], CAMBIOS_EMUS.COLOR_EMU)
					Font.ftPrint(CONTROL.fontARCA, x_act, espacio_linea+(y_recta_fix), 0, 0, 8, "".. acti, CAMBIOS_EMUS.COLOR_EMU)
					Graphics.drawScaleImage(PAD_IMG.SELECT_S, x_img, espacio_linea+(y_recta_fix), 20, 20)
				else
					Font.ftPrint(CONTROL.fontARCA, x_name, espacio_linea+(y_recta_fix), 0, 0, 8, "".. lista_texto_config[estado], COLOR.BLANCO_LISTA)
					Font.ftPrint(CONTROL.fontARCA, x_act, espacio_linea+(y_recta_fix), 0, 0, 8, "".. acti, COLOR.BLANCO_LISTA)
				end
			end
			if estado == 7 and estilo_lista ~= 7 and ini_sprite == 1 and conf_numero == true then
				dibujar_sprites(LISTAS.IDENTIDAD, 454, (espacio_linea-20), 30, 40, 0.00, SPRITES.FLIP[1], SPRITES.FLIP[2], false)
			end
			contador = contador+1
		end

		-- Dibuja una pequeña muestra de los efectos en el cambio de colores. -----------
		if conf_numero == true then
			if lista_config[3] == 1 and tras_demo ~= 0 then
				Graphics.drawRect(199-2, (108-ajuste_m)-2+CONTROL.Y_FIX_PAL, 244+4, 70+4, COLOR.NEGRO_T)
				Graphics.drawScaleImage(LOGOS.DEFAULT_DEMO, 199, (108-ajuste_m)+CONTROL.Y_FIX_PAL, 244, 70)
				Graphics.drawRect(199, (108-ajuste_m)+CONTROL.Y_FIX_PAL, 244, 70, color_demo)
			else
				Graphics.drawScaleImage(LOGOS.DEFAULT_DEMO, 199, (108-ajuste_m)+CONTROL.Y_FIX_PAL, 244, 70, CAMBIOS_EMUS.COLOR_EMU)
			end
			if lista_config[3] == 1 and selector >= 4 and selector <= 6 then
				local color_mos, text_tras = COLOR.BLANCO_LISTA, (TEXT_M_CON[65] .." ".. tras_demo)
				if tras_demo == 0 then
					text_tras = TEXT_M_CON[66]
				end
				local PAD_indi, fix1, fix2 = Pads.get(0), 5, 5
				if Pads.check(PAD_indi, PAD_SQUARE) then
					fix1 = 10
				elseif Pads.check(PAD_indi, PAD_TRIANGLE) then
					fix2 = 10
				end
				Graphics.drawRect(12+5, (184-ajuste_m)-3+CONTROL.Y_FIX_PAL, 610-7, 25, COLOR.NEGRO)
				dibujar_indicador(126, 178, text_tras, PAD_IMG.SQUARE, 20, 20, fix1, false)
				dibujar_indicador(404, 178, TEXT_M_CON[114] .." ".. OPCIONES.COLOR_LISTA_B, PAD_IMG.TRIANGLE, 20, 20, fix2, false)
			end
		end
		dibujar_indicador(54, 425, TEXT_M_CON[23], PAD_IMG.START, 32, 32, 2, false)
		dibujar_indicador(412, 425, TEXT_GEN[8], PAD_IMG.CROSS, 20, 20, 5, false)
		dibujar_indicador(550, 425, TEXT_GEN[7], PAD_IMG.CIRCLE, 20, 20, 5, false)
		if cambio_ani == true then
			cambio_ani, n_ani = intro_menu(cambio_ani, n_ani)
			JOYSTICK_LIMITE = control_FPS(1)-18
		end
		refrescar(false)
	end
	if reinicio == false then
		animaciones(nil, false)
	elseif reinicio == true then
		reiniciar_conf(clean, indi_rest_RL)
		if indi_rest_RL ~= 0 and indi_rest_RL ~= 20 then
			animaciones(nil, false)
		end
	end
	JOYSTICK_LIMITE = control_FPS(1)-16
	limpiar_art()
	LISTAS.MOSTRAR = 0
end

--- Obtener el valor de un carácter. ----------------------------------------------------
function cha_res(character, limit)
	local resultado = 0
	local character_list = {"1"; "2"; "3"; "4"; "5"; "6"; "7"; "8"; "9"; "a"; "b"; "c"; "d"; "e"; "f"; "g"; "h"; "i";
	"j"; "k"; "l"; "m"; "n"; "o"; "p"; "q"; "r"; "s"; "t"; "u"; "v"; "w"; "x"; "y"; "z"; "A"; "B"; "C"; "D"; "E"; "F";
	"G"; "H"; "I"; "J"; "K"; "L"; "M"; "N"; "O"; "P"; "Q"; "R"; "S"; "T"; "U"; "V"; "W"; "X"; "Y"; "Z"; "#";};
	if character ~= nil then
		if limit >= #character_list+1 then
			limit = #character_list
		end
		for decimal = 1, limit do
			if string.match(character, character_list[decimal]) then
				resultado = decimal
				break
			end
		end
	elseif character == nil then
		if limit ~= 0 then
			resultado = character_list[limit]
		end
	end
	return resultado
end

--- Dividir un texto por un carácter determinado. ---------------------------------------
function sub_string(texto, c_divisor, l_resultado, tipo)
	if tipo == true then
		for linea in string.gmatch(texto, c_divisor) do
			table.insert(l_resultado, tonumber(linea))
		end
	elseif tipo == false then
		for linea in string.gmatch(texto, c_divisor) do
			table.insert(l_resultado, tostring(linea))
		end
	end
	return l_resultado
end

--- Muestra barra de progreso. ----------------------------------------------------------
function pantalla_reiniciar_conf(FONDO, estado, limpiar, indi_rest)
	-- Durante el arranque manda la lista de pasos, y solo ella. Las dos se pintaban
	-- por turnos -- pantalla de progreso, panel negro, pantalla de progreso -- y el
	-- resultado era un parpadeo sin sentido. Fuera del arranque LOAD_BG ya es nil
	-- y esta pantalla vuelve a funcionar, que es la que usa "reiniciar configuracion".
	if LOAD_BG ~= nil then return end
	Screen.clear(COLOR.NEGRO)
	local res_x, res_y_tex, res_y = 640, 0, 448
	if doesFileExist("System/Defaults/PAL") then
		res_x, res_y_tex, res_y = 640, 34, 512
	end
	if OPCIONES.FONDO_RGB_ON == 1 and (OPCIONES.FONDO_RGB_FIJO_ON == 0 or (OPCIONES.FONDO_RGB_FIJO_ON == 1 and CAMBIOS_EMUS.TRAS == 0)) then
		if SPRITES.FONDO_ANI == true then
			fondo_sprites(LISTAS.FONDO, -5, 0, res_x+5, res_y, 0.00, nil, Color.new(0, 80, 120))
		else
			Graphics.drawScaleImage(FONDO, -5, 0, res_x+5, res_y, Color.new(0, 80, 120))
		end
	elseif OPCIONES.FONDO_RGB_ON == 1 and OPCIONES.FONDO_RGB_FIJO_ON == 1 then
		if SPRITES.FONDO_ANI == true then
			fondo_sprites(LISTAS.FONDO, -5, 0, res_x+5, res_y, 0.00, false, Color.new(0, 80, 120))
		else
			Graphics.drawScaleImage(FONDO, -5, 0, res_x+5, res_y)
		end
		Graphics.drawRect(0, 0, res_x+5, res_y, Color.new(0, 80, 120, CAMBIOS_EMUS.TRAS))
	else
		if SPRITES.FONDO_ANI == true then
			fondo_sprites(LISTAS.FONDO, -5, 0, res_x+5, res_y, 0.00, false, Color.new(0, 80, 120))
		else
			Graphics.drawScaleImage(FONDO, -5, 0, res_x+5, res_y)
		end
	end
	Graphics.drawScaleImage(LISTAS.LOADING, 0, 0, res_x, res_y)
	Graphics.drawRect(-5, 278-3+res_y_tex, 650, 25, COLOR.NEGRO)
	local lista_indi_rest = {"Atari 2600"; "Atari Lynx"; "Neo Geo Pocket"; "Nintendo Famicom"; "Nintendo Game Boy"; "Nintendo Game Boy Advance";
	"Nintendo Game Boy Color"; "Nintendo Super Famicom"; "Sega Game Gear"; "Sega Master System"; "Sega Megadrive"; "Sega SG-1000";};
	if limpiar == true then
		Font.ftPrint(CONTROL.fontARCA, (640//2), 278+res_y_tex, 8, 640, 25, "- ".. TEXT_M_CON[70] .." -", COLOR.BLANCO)
	elseif indi_rest ~= 0 and indi_rest ~= 20 and indi_rest ~= 21 and limpiar == false then
		Font.ftPrint(CONTROL.fontARCA, (640//2), 278+res_y_tex, 8, 640, 25, "-".. TEXT_M_CON[71] .." ".. lista_indi_rest[indi_rest] .."-", COLOR.BLANCO)
	elseif indi_rest == 20 and limpiar == false then
		Font.ftPrint(CONTROL.fontARCA, (640//2), 278+res_y_tex, 8, 640, 25, "-".. TEXT_M_CON[72] .."-", COLOR.BLANCO)
	elseif indi_rest == 21 and limpiar == false then
		Font.ftPrint(CONTROL.fontARCA, (640//2), 278+res_y_tex, 8, 640, 25, "-".. TEXT_M_CON[73] .."-", COLOR.BLANCO)
	else
		Font.ftPrint(CONTROL.fontARCA, (640//2), 278+res_y_tex, 8, 640, 25, "-".. TEXT_M_CON[74] .."-", COLOR.BLANCO)
	end
	Font.ftPrint(CONTROL.fontARCA, (640//2), 304+res_y_tex, 8, 640, 25, "█████████████████████████", COLOR.BLANCO)
	if estado ~= 0 then
		Font.ftPrint(CONTROL.fontARCA, (640//2), 304+res_y_tex, 8, 640, 25, string.sub("█████████████████████████", 1, estado), Color.new(0, 80, 120))
	end
	refrescar(false)
end

--- Reinicia todas las configuraciones. -------------------------------------------------
function reiniciar_conf(limpiar, indi_rest)
	Pads.rumble(0, 0, 0)
	local actual = System.currentDirectory()
	local FONDO_LOAD = Graphics.loadImage(verif_img("System/Medias/Default/FONDO.png"))
	pantalla_reiniciar_conf(FONDO_LOAD, 0, limpiar, indi_rest)
	local dir_mode_video = "NTSC"
	if OPCIONES.VIDEO_MODE ~= 0 then
		dir_mode_video = "PAL"
	end
	if indi_rest == 0 or indi_rest == 20 then
		if OPCIONES.VIDEO_MODE == 0 and doesFileExist("System/Defaults/PAL") then
			System.rename("System/Defaults/PAL", "System/Defaults/NTSC")
		elseif OPCIONES.VIDEO_MODE == 1 and doesFileExist("System/Defaults/NTSC") then
			System.rename("System/Defaults/NTSC", "System/Defaults/PAL")
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
		Font.ftUnload(CONTROL.fontARCA)
		Font.ftUnload(CONTROL.fontABC)
		CONTROL.fontARCA = Font.ftLoad("System/Medias/Font/PublicPixel.ttf")
		CONTROL.fontABC = Font.ftLoad("System/Medias/Font/PublicPixel.ttf")
		OPCIONES.CAMBIO_FUENTE_ON = 1
		Graphics.freeImage(LISTAS.FONDO)
		LISTAS.FONDO = Graphics.loadImage(verif_img("System/Medias/Default/FONDO.png"))
		SPRITES.FONDO_ANI = false
		SPRITES.FONDO_N_COLUMNS = 4
		SPRITES.FONDO_N_ROWS = 4
		SPRITES.LAYER = false
		SPRITES.LAYER_TYPE = 1
		OPCIONES.CAMBIO_FONDO_ON = 1
		OPCIONES.GUI_LIMPIA_ON = 0
		OPCIONES.LIMITADOR_RAM_ON = 0
		OPCIONES.SALIDA_RETROLANCHER_ON = 0
		OPCIONES.SALIDA_RETROLANCHER = "PS2 SYSTEM MENU"
		OPCIONES.SALIDA_DIR_ACTUALES = {}
		OPCIONES.SALIDA_DIR_ANTERIORES = {}
		OPCIONES.APPS_MENU_FULL_PATH = 0
		OPCIONES.SOUND_ON = 0
		OPCIONES.SOUND_VOLUME = 65
		set_volume()
		OPCIONES.SCREENSHOT_BACK_ON = 0
		OPCIONES.SCREENSHOT_BACK_TR = 128
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
		CONTROL.CUSTOM_SPRITE = false
		OPCIONES.SEE_INDEX = 0
		OPCIONES.COLOR_LISTA_B = 74
		OPCIONES.RUN_DEFAULT = 0
		COLOR.CC_BACK = {0, 0, 0, 85}
		COLOR.NEGRO_T = Color.new(COLOR.CC_BACK[1], COLOR.CC_BACK[2], COLOR.CC_BACK[3], COLOR.CC_BACK[4])
		Font.ftSetPixelSize(CONTROL.fontARCA, OPCIONES.FONT_PIXEL_X, OPCIONES.FONT_PIXEL_Y)
		Font.ftSetPixelSize(CONTROL.fontABC, 70, 70)
		if doesFileExist("System/Medias/Sound/Background/music.adp") then
			System.rename("System/Medias/Sound/Background/music.adp", "System/Medias/Sound/Background/music0.adp")
			Sound.freeADPCM(S_MUSICA)
			S_MUSICA = nil
		end
	end

	-- Limpiar partidas guardadas por RetroArch. ----------------------------------------
	if limpiar == true then
		pantalla_reiniciar_conf(FONDO_LOAD, 5, true, indi_rest)
		if indi_rest == 0 or indi_rest == 1 then
			limpiar_retroarch("Atari 2600")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 10, true, indi_rest)
		if indi_rest == 0 or indi_rest == 2 then
			limpiar_retroarch("Atari Lynx")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 15, true, indi_rest)
		if indi_rest == 0 or indi_rest == 3 then
			limpiar_retroarch("Neo Geo Pocket")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 20, true, indi_rest)
		if indi_rest == 0 or indi_rest == 4 then
			limpiar_retroarch("Nintendo Famicom")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 25, true, indi_rest)
		if indi_rest == 0 or indi_rest == 5 then
			limpiar_retroarch("Nintendo Game Boy")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 30, true, indi_rest)
		if indi_rest == 0 or indi_rest == 6 then
			limpiar_retroarch("Nintendo Game Boy Advance")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 35, true, indi_rest)
		if indi_rest == 0 or indi_rest == 7 then
			limpiar_retroarch("Nintendo Game Boy Color")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 40, true, indi_rest)
		if indi_rest == 0 or indi_rest == 8 then
			limpiar_retroarch("Nintendo Super Famicom")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 45, true, indi_rest)
		if indi_rest == 0 or indi_rest == 9 then
			limpiar_retroarch("Sega Game Gear")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 50, true, indi_rest)
		if indi_rest == 0 or indi_rest == 10 then
			limpiar_retroarch("Sega Master System")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 55, true, indi_rest)
		if indi_rest == 0 or indi_rest == 11 then
			limpiar_retroarch("Sega Megadrive")
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 60, true, indi_rest)
		if indi_rest == 0 or indi_rest == 12 then
			limpiar_retroarch("Sega SG-1000")
		end
		if indi_rest == 0 then
			-- Sin ordenacion por core las partidas caen en la raiz: hay que barrerla.
			limpiar_retroarch(nil)
		end
		pantalla_reiniciar_conf(FONDO_LOAD, 75, true, indi_rest)
	end

	-- Restaura la configuracion de RetroArch. ------------------------------------------
	-- Aqui habia doce bloques casi identicos, uno por sistema, que copiaban doce
	-- "retroarch.cfg" hacia "System/RetroarchPS2/<sistema>/retroarch/". Esos doce
	-- ficheros no se diferenciaban entre si mas que en veinte rutas absolutas
	-- ("mass:/Prism/...") -- que RetroArch recalcula solo a partir de su propio
	-- directorio, asi que estorbaban en cuanto la carpeta cambiaba de sitio o de
	-- unidad -- y en un punado de claves de video y audio.
	-- Hoy hay un solo "retroarch.cfg", en "LibretroPS2Files/retroarch/", y esas claves
	-- viajan como override de core ("config/<Core>/<Core>.cfg") o de carpeta de
	-- contenido ("config/PicoDrive/gamegear.cfg"), que es el mecanismo previsto por
	-- RetroArch para justamente esto.
	pantalla_reiniciar_conf(FONDO_LOAD, 1, false, indi_rest)
	if indi_rest == 0 or indi_rest == 20 or (indi_rest >= 1 and indi_rest <= 12) then
		restaurar_conf_retroarch(OPCIONES.VIDEO_MODE ~= 0)
	end
	pantalla_reiniciar_conf(FONDO_LOAD, 68, false, indi_rest)


	-- Restaura las configuraciones. ----------------------------------------------------
	pantalla_reiniciar_conf(FONDO_LOAD, 72, false, indi_rest)
	if indi_rest == 0 then
		if doesFileExist(actual .."/System/Defaults/Path_file.cfg") then
			System.copyFile(actual .."/System/Defaults/Path_file.cfg", actual .."/System/Config/Path_file.cfg")
		end
		if doesFileExist(actual .."/System/Defaults/Config.cfg") then
			System.copyFile(actual .."/System/Defaults/Config.cfg", actual .."/System/Config/Config.cfg")
		end
		if doesFileExist(actual .."/System/Defaults/System.cfg") then
			System.copyFile(actual .."/System/Defaults/System.cfg", actual .."/System/Config/System.cfg")
		end
		if doesFileExist(actual .."/System/Defaults/Path_OPL.cfg") then
			System.copyFile(actual .."/System/Defaults/Path_OPL.cfg", actual .."/System/Config/Path_OPL.cfg")
		end
	end

	-- Restaura variables. --------------------------------------------------------------
	pantalla_reiniciar_conf(FONDO_LOAD, 73, false, indi_rest)
	if indi_rest == 0 or indi_rest == 20 then
		guardar_opciones()
		pantalla_reiniciar_conf(FONDO_LOAD, 75, false, indi_rest)
		cargar_config()
		cargar_directorio_elf(false)
		cargar_directorio_elf(true)
	end
	Graphics.freeImage(FONDO_LOAD)
end
