-- Prism PS2 Launcher - ui/sprites.lua
-- System selector: sprites, logos, animations and per-system colours.
-- Split from the original funciones.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Functions are globals; this file only defines them. Loaded by System/system.lua.

--- Controlar el cambio entre sistemas activados y desactivados. ------------------------
--- Salta directamente a un sistema concreto (usado por la rejilla). -------------------
function ir_a_sistema(id)
	if id == nil or id == LISTAS.IDENTIDAD then return end
	if OPCIONES.LIBERAR_LISTAS == 1 then
		PRE_CARGADAS[LISTAS.IDENTIDAD] = {}
	end
	LISTAS.IDENTIDAD = id
	LISTAS.ROMS = nil
	if OPCIONES.LIBERAR_LISTAS == 1 then
		recargar_una(LISTAS.IDENTIDAD)
	end
	LISTAS.ROMS = PRE_CARGADAS[LISTAS.IDENTIDAD]
	indices_extras()
	rest_sprites(CONTROL.CUSTOM_SPRITE)
	if LISTAS.ROMS ~= nil and LAST_MOVE[LISTAS.IDENTIDAD] <= #LISTAS.ROMS then
		LISTAS.INDICE = LAST_MOVE[LISTAS.IDENTIDAD]
	else
		LISTAS.INDICE = 1
		LAST_MOVE[LISTAS.IDENTIDAD] = 1
	end
end

--- Rejilla de seleccion de sistema (L1+R1). Devuelve la identidad o nil. -------------
--- Solo muestra los sistemas activados en SISTEMAS.*_ON, con su logo.
function selector_sistemas(fondos)
	local claves = {"MEGADRIVE", "MASTERSYSTEM", "GAMEGEAR", "FAMICOM", "GAMEBOY", "GAMEBOYCOLOR",
		"GAMEBOYADVANCE", "ATARI2600", "ATARILYNX", "SEGASG1000", "NEOGEOPOCKET", "SUPERFAMICOM",
		"APPS", "PLAYSTATION", "PLAYSTATION2"}
	local nombres = {"Sega Megadrive", "Sega Master System", "Sega Game Gear", "Nintendo Famicom",
		"Nintendo Game Boy", "Nintendo Game Boy Color", "Nintendo Game Boy Advance", "Atari 2600",
		"Atari Lynx", "Sega SG-1000", "Neo Geo Pocket", "Nintendo Super Famicom",
		"APPS", "PlayStation", "PlayStation 2"}
	local activos = {SISTEMAS.MEGADRIVE_ON, SISTEMAS.MASTERSYSTEM_ON, SISTEMAS.GAMEGEAR_ON,
		SISTEMAS.FAMICOM_ON, SISTEMAS.GAMEBOY_ON, SISTEMAS.GAMEBOYCOLOR_ON, SISTEMAS.GAMEBOYADVANCE_ON,
		SISTEMAS.ATARI2600_ON, SISTEMAS.ATARILYNX_ON, SISTEMAS.SEGASG1000_ON, SISTEMAS.NEOGEOPOCKET_ON,
		SISTEMAS.SUPERFAMICOM_ON, SISTEMAS.APPS_ON, SISTEMAS.PLAYSTATION_ON, SISTEMAS.PLAYSTATION2_ON}

	local lista = {}
	for i = 1, 15 do
		if activos[i] == 1 then table.insert(lista, i) end
	end
	if #lista == 0 then return nil end

	-- Posicionarse sobre el sistema actual. ------------------------------------------
	local sel = 1
	for i = 1, #lista do
		if lista[i] == LISTAS.IDENTIDAD then sel = i end
	end

	local COLS, CW, CH, GX, GY = 5, 118, 86, 6, 8
	local X0 = (640 - (COLS*CW + (COLS-1)*GX)) // 2
	local Y0 = 78 + CONTROL.Y_FIX_PAL
	local elegido, abierto = nil, true
	JOYSTICK_LIMITE = control_FPS(1)-20

	while abierto do
		CONTROL.FPS = Screen.getFPS(1)
		capturar(JOYSTICK_LIMITE)
		fondos()

		Graphics.drawRect(10, 16+CONTROL.Y_FIX_PAL, 619, 419, COLOR.NEGRO_T)
		Graphics.drawRect(-5, 22+CONTROL.Y_FIX_PAL, 650, 25, COLOR.NEGRO)
		Font.ftPrint(CONTROL.fontARCA, 320, 28+CONTROL.Y_FIX_PAL, 8, 600, 25, "SELECT SYSTEM", COLOR.BLANCO)

		for i = 1, #lista do
			local col = (i-1) % COLS
			local fila = (i-1) // COLS
			local x = X0 + col*(CW+GX)
			local y = Y0 + fila*(CH+GY)
			if i == sel then
				Graphics.drawRect(x-3, y-3, CW+6, CH+6, CAMBIOS_EMUS.COLOR_EMU)
			end
			Graphics.drawRect(x, y, CW, CH, COLOR.NEGRO)
			local img = LOGOS[claves[lista[i]]]
			if img ~= nil then
				Graphics.drawScaleImage(img, x+5, y+5, CW-10, CH-10)
			end
		end

		Graphics.drawRect(-5, 394+CONTROL.Y_FIX_PAL, 650, 26, COLOR.NEGRO)
		Font.ftPrint(CONTROL.fontARCA, 320, 400+CONTROL.Y_FIX_PAL, 8, 620, 25, nombres[lista[sel]], COLOR.BLANCO_LISTA)
		refrescar(false)

		if CONTROL.JOYSTICK_ON == false then
			if Pads.check(PAD, PAD_CROSS) then
				repro_sfx(S_EJECUTAR, 1, false, nil)
				elegido, abierto = lista[sel], false
				-- Bloquear el pad al salir: sin esto, la misma pulsacion de CRUZ se
				-- propaga al menu principal y lanza el juego seleccionado.
				JOYSTICK_LIMITE = control_FPS(1)-40
			elseif Pads.check(PAD, PAD_TRIANGLE) then
				repro_sfx(S_CANCELAR, 1, false, nil)
				abierto = false
				JOYSTICK_LIMITE = control_FPS(1)-40
			elseif Pads.check(PAD, PAD_LEFT) or Left_X <= -90 then
				repro_sfx(S_MOVER, 1, false, nil)
				sel = cambiar_valor(sel, 1, #lista, 1, false)
				JOYSTICK_LIMITE = control_FPS(1)-6
			elseif Pads.check(PAD, PAD_RIGHT) or Left_X >= 90 then
				repro_sfx(S_MOVER, 1, false, nil)
				sel = cambiar_valor(sel, 1, #lista, 1, true)
				JOYSTICK_LIMITE = control_FPS(1)-6
			elseif Pads.check(PAD, PAD_UP) or Left_Y <= -90 then
				repro_sfx(S_MOVER, 1, false, nil)
				if sel - COLS >= 1 then sel = sel - COLS end
				JOYSTICK_LIMITE = control_FPS(1)-6
			elseif Pads.check(PAD, PAD_DOWN) or Left_Y >= 90 then
				repro_sfx(S_MOVER, 1, false, nil)
				if sel + COLS <= #lista then sel = sel + COLS end
				JOYSTICK_LIMITE = control_FPS(1)-6
			end
		end
	end
	return elegido
end

function desactivados(lado)
	local buscar = true
	local sistemas_on = {SISTEMAS.MEGADRIVE_ON; SISTEMAS.MASTERSYSTEM_ON; SISTEMAS.GAMEGEAR_ON; SISTEMAS.FAMICOM_ON; SISTEMAS.GAMEBOY_ON;
	SISTEMAS.GAMEBOYCOLOR_ON; SISTEMAS.GAMEBOYADVANCE_ON; SISTEMAS.ATARI2600_ON; SISTEMAS.ATARILYNX_ON; SISTEMAS.SEGASG1000_ON;
	SISTEMAS.NEOGEOPOCKET_ON; SISTEMAS.SUPERFAMICOM_ON; SISTEMAS.APPS_ON; SISTEMAS.PLAYSTATION_ON; SISTEMAS.PLAYSTATION2_ON;};
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
	rest_sprites(CONTROL.CUSTOM_SPRITE)
end

--- Restaurar posiciones y valores de sprites. ------------------------------------------
function rest_sprites(custom)
	SPRITES.X = 0
	SPRITES.Y = 0
	SPRITES.ANI_FRAME = 0
	if custom == true then
		SPRITES.MOVE_X, SPRITES.MOVE_Y = CONTROL.SPRITE_ANCHO, CONTROL.SPRITE_ALTO
		SPRITES.TRAN_ALT_SPRITE, SPRITES.MOVE_ALT_X, SPRITES.MOVE_ALT_Y = false, false, false
		SPRITES.SPIN_SPRITE, SPRITES.ANG_SPRITE = 0.00, 0.00
		SPRITES.TRAN_SPRITE, SPRITES.ZOOM_SPRITE, SPRITES.SPIN_SPRITE_ALT = 128, {0, false}, false
		SPRITES.FLIP[1], SPRITES.FLIP[2] = 0, 0
	end
end

--- Tipos de animaciones al cambiar de emuladores. --------------------------------------
function animaciones(lado, intro)
	Pads.rumble(0, 0, 0)
	local trans_especial, mostrar_ant = false, false
	if lado == nil then
		lado, trans_especial, mostrar_ant = true, true, true
	end
	local saibot = true
	local cambio_ani = false
	local pre_time = JOYSTICK_LIMITE
	JOYSTICK_LIMITE = control_FPS(1)

	-- Determinar las posiciones de los elementos en pantalla. --------------------------
	local lista_objetos_min = {CONTROL.IMG_ANCHO; CONTROL.LISTA_ANCHO; CONTROL.LOGO_ANCHO; CONTROL.IMG_ANCHO_2; CONTROL.FLOW_ANCHO;
	CONTROL.FLOW_ANCHO_2; CONTROL.SPRITE_ANCHO;};
	local lista_objetos_max = {(CONTROL.IMG_ANCHO+CONTROL.IMG_X); (CONTROL.LISTA_ANCHO+CONTROL.LISTA_X); (CONTROL.LOGO_ANCHO+CONTROL.LOGO_X);
	(CONTROL.IMG_ANCHO_2+CONTROL.IMG_X_2); (CONTROL.FLOW_ANCHO+CONTROL.FLOW_X); (CONTROL.FLOW_ANCHO_2+CONTROL.FLOW_X_2);
	(CONTROL.SPRITE_ANCHO+CONTROL.SPRITE_X);};
	if CONTROL.CUSTOM_ANIM == 2 or CONTROL.CUSTOM_ANIM == 3 then
		lista_objetos_min = {CONTROL.IMG_ALTO; CONTROL.LISTA_ALTO; CONTROL.LOGO_ALTO; CONTROL.IMG_ALTO_2; CONTROL.FLOW_ALTO;
		CONTROL.FLOW_ALTO_2; CONTROL.SPRITE_ALTO;};
		lista_objetos_max = {(CONTROL.IMG_ALTO+CONTROL.IMG_Y); (CONTROL.LISTA_ALTO+CONTROL.LISTA_Y); (CONTROL.LOGO_ALTO+CONTROL.LOGO_Y);
		(CONTROL.IMG_ALTO_2+CONTROL.IMG_Y_2); (CONTROL.FLOW_ALTO+CONTROL.FLOW_Y); (CONTROL.FLOW_ALTO_2+CONTROL.FLOW_Y_2);
		(CONTROL.SPRITE_ALTO+CONTROL.SPRITE_Y);};
	end
	table.sort(lista_objetos_min)
	table.sort(lista_objetos_max)
	local minimo, maximo, lista_objetos_min, lista_objetos_max = lista_objetos_min[1], lista_objetos_max[#lista_objetos_max], {}, {}
	local actual = minimo
	if CONTROL.CUSTOM_ANIM >= 4 or trans_especial == true then
		actual = 0
	else
		color_emu(LISTAS.IDENTIDAD, OPCIONES.FONDO_RGB_ON, OPCIONES.FONDO_RGB_FIJO_ON)
	end
	if CONTROL.CUSTOM_ANIM == 15 and trans_especial == false then
		cargar_logo(LISTAS.IDENTIDAD)
		color_emu(LISTAS.IDENTIDAD, OPCIONES.FONDO_RGB_ON, OPCIONES.FONDO_RGB_FIJO_ON)
		saibot = false
	end
	while saibot do
		-- Animación estilo 1. ----------------------------------------------------------
		if lado == true and CONTROL.CUSTOM_ANIM == 1 and trans_especial == false then
			if actual > minimo and cambio_ani == true then
				actual = actual-CONTROL.ANIM_VELOCIDAD
			elseif cambio_ani == true then
				actual = 0
				saibot = false
			elseif actual+maximo > 0-CONTROL.ANIM_VELOCIDAD and cambio_ani == false then
				actual = actual-CONTROL.ANIM_VELOCIDAD
			elseif actual+maximo <= 0-CONTROL.ANIM_VELOCIDAD and cambio_ani == false then
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
				actual = (-(minimo+maximo))-CONTROL.ANIM_VELOCIDAD
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
				actual = (-(minimo+maximo))-CONTROL.ANIM_VELOCIDAD
				cargar_logo(LISTAS.IDENTIDAD)
				cambio_ani = true
			end

		-- Animaciones del estilo 4 al estilo 15. ---------------------------------------
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
				if intro == true then
					saibot = false
					break
				end
				cargar_logo(LISTAS.IDENTIDAD)
				color_emu(LISTAS.IDENTIDAD, OPCIONES.FONDO_RGB_ON, OPCIONES.FONDO_RGB_FIJO_ON)
				cambio_ani = true
				mostrar_ant = false
			end
		end

		-- Mostrar todo en pantalla. ----------------------------------------------------
		CONTROL.FPS = Screen.getFPS(1)
		capturar(JOYSTICK_LIMITE)
		dibujar_fondos()
		if mostrar_ant == false then
			-- Posicionar elementos. ----------------------------------------------------
			local representar = {actual+CONTROL.IMG_ANCHO; actual+CONTROL.LISTA_ANCHO; actual+CONTROL.LOGO_ANCHO; actual+CONTROL.IMG_ANCHO_2;
			actual+CONTROL.FLOW_ANCHO; actual+CONTROL.FLOW_ANCHO_2; CONTROL.IMG_ALTO; CONTROL.LISTA_ALTO; CONTROL.LOGO_ALTO; CONTROL.IMG_ALTO_2;
			CONTROL.FLOW_ALTO; CONTROL.FLOW_ALTO_2; actual+CONTROL.SPRITE_ANCHO; CONTROL.SPRITE_ALTO;};
			if CONTROL.CUSTOM_ANIM == 2 then
				representar = {CONTROL.IMG_ANCHO; CONTROL.LISTA_ANCHO; CONTROL.LOGO_ANCHO; CONTROL.IMG_ANCHO_2; CONTROL.FLOW_ANCHO; CONTROL.FLOW_ANCHO_2;
				actual+CONTROL.IMG_ALTO; actual+CONTROL.LISTA_ALTO; actual+CONTROL.LOGO_ALTO; actual+CONTROL.IMG_ALTO_2; actual+CONTROL.FLOW_ALTO;
				actual+CONTROL.FLOW_ALTO_2; CONTROL.SPRITE_ANCHO; actual+CONTROL.SPRITE_ALTO;};
			elseif CONTROL.CUSTOM_ANIM == 3 then
				representar = {actual+CONTROL.IMG_ANCHO; actual+CONTROL.LISTA_ANCHO; actual+CONTROL.LOGO_ANCHO; actual+CONTROL.IMG_ANCHO_2;
				actual+CONTROL.FLOW_ANCHO; actual+CONTROL.FLOW_ANCHO_2; actual+CONTROL.IMG_ALTO; actual+CONTROL.LISTA_ALTO; actual+CONTROL.LOGO_ALTO;
				actual+CONTROL.IMG_ALTO_2; actual+CONTROL.FLOW_ALTO; actual+CONTROL.FLOW_ALTO_2; actual+CONTROL.SPRITE_ANCHO; actual+CONTROL.SPRITE_ALTO;};
			elseif CONTROL.CUSTOM_ANIM >= 4 or trans_especial == true then
				representar = {CONTROL.IMG_ANCHO; CONTROL.LISTA_ANCHO; CONTROL.LOGO_ANCHO; CONTROL.IMG_ANCHO_2; CONTROL.FLOW_ANCHO; CONTROL.FLOW_ANCHO_2;
				CONTROL.IMG_ALTO; CONTROL.LISTA_ALTO; CONTROL.LOGO_ALTO; CONTROL.IMG_ALTO_2; CONTROL.FLOW_ALTO; CONTROL.FLOW_ALTO_2; CONTROL.SPRITE_ANCHO;
				CONTROL.SPRITE_ALTO;};
			end

			-- Dibujar elementos. -------------------------------------------------------
			if CONTROL.ESTILO == 3 and OPCIONES.GUI_LIMPIA_ON == 1 and CONTROL.CUSTOM_LIST == true then
				Graphics.drawRect(representar[2]-3, representar[8]-3, CONTROL.LISTA_X+236+6, CONTROL.LISTA_Y+6, COLOR.NEGRO_T)
			elseif CONTROL.ESTILO ~= 2 and CONTROL.CUSTOM_LIST == true then
				Graphics.drawRect(representar[2]-3, representar[8]-3, CONTROL.LISTA_X+6, CONTROL.LISTA_Y+6, COLOR.NEGRO_T)
			end
			if CONTROL.CUSTOM_BACK == true then
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
			end

			-- Dibujar logo. ------------------------------------------------------------
			if CONTROL.CUSTOM_LOGO == true then
				Graphics.drawScaleImage(LISTAS.LOGO, representar[3], representar[9], CONTROL.LOGO_X, CONTROL.LOGO_Y)
			end

			-- Dibujar sprite. ----------------------------------------------------------
			if CONTROL.CUSTOM_SPRITE == true and cambio_ani == true then
				if SPRITES.MOVE[LISTAS.IDENTIDAD] <= 50 or ( SPRITES.MOVE[LISTAS.IDENTIDAD] >= 53 and SPRITES.MOVE[LISTAS.IDENTIDAD] <= 56) or SPRITES.MOVE[LISTAS.IDENTIDAD] == 59 or SPRITES.MOVE[LISTAS.IDENTIDAD] == 62 then
					SPRITES.MOVE_X, SPRITES.MOVE_Y = representar[13], representar[14]
				end
				dibujar_sprites(LISTAS.IDENTIDAD, representar[13], representar[14], CONTROL.SPRITE_X, CONTROL.SPRITE_Y, 0.00, SPRITES.FLIP[1], SPRITES.FLIP[2], true)
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
		if (CONTROL.CUSTOM_ANIM >= 7 and CONTROL.CUSTOM_ANIM <= 10) and trans_especial == false then
			if CONTROL.CUSTOM_ANIM == 7 or CONTROL.CUSTOM_ANIM == 9 then
				local x_mov, radio = actual*15, actual
				if CONTROL.CUSTOM_ANIM == 9 then
					radio = 0
				end
				for contador = 0, CONTROL.ANCHO, 100 do
					Graphics.drawCircle(0+x_mov, contador, 16+radio, Color.new(0, 0, 0, (actual*3)))
					Graphics.drawCircle(contador, 0+x_mov, 16+radio, Color.new(0, 0, 0, (actual*3)))
					Graphics.drawCircle(CONTROL.ANCHO-x_mov, contador, 16+radio, Color.new(0, 0, 0, (actual*3)))
					Graphics.drawCircle(contador, CONTROL.ALTO-x_mov, 16+radio, Color.new(0, 0, 0, (actual*3)))
				end
			end
			if CONTROL.CUSTOM_ANIM == 8 or CONTROL.CUSTOM_ANIM == 9 then
				local list_x = {CONTROL.ANCHO, 80, 140, 180, 30, 500, 600, 10, 610, 220}
				local list_y = {CONTROL.ALTO, 80, 200, 320, 40, 70, 30, CONTROL.ALTO, 340, 30}
				local list_circle = {15, 1, 2, 10, 4, 5, 3, 9, 2, 1}
				for num = 1, #list_circle, 1 do
					Graphics.drawCircle(list_x[num], list_y[num], actual*list_circle[num], Color.new(0, 0, 0, (actual*3)))
				end
			end
			if CONTROL.CUSTOM_ANIM == 10 then
				local suma_x, suma_y = 0, 0
				for contador = 0, CONTROL.ALTO+50, 50 do
					for contador2 = 25, CONTROL.ANCHO, 50 do
						suma_x = contador2
						Graphics.drawCircle(suma_x, suma_y, actual, Color.new(0, 0, 0, (actual*3)))
					end
					suma_y = contador
				end
			end
		end
		if (CONTROL.CUSTOM_ANIM == 11 or CONTROL.CUSTOM_ANIM == 12) and trans_especial == false then
			local inicio, final, salto, valor = 0, CONTROL.ANCHO, 16, actual//2
			if CONTROL.CUSTOM_ANIM == 12 then
				final = CONTROL.ALTO
				if lado == false then
					inicio, final, salto, valor = CONTROL.ALTO, -1, -16, -actual//2
				end
			else
				if lado == false then
					inicio, final, salto, valor = CONTROL.ANCHO, -1, -16, -actual//2
				end
			end
			for contador = inicio, final, salto do
				if CONTROL.CUSTOM_ANIM == 11 then
					Graphics.drawRect(contador, 0, valor, CONTROL.ALTO, Color.new(0, 0, 0, (actual*3)))
				else
					Graphics.drawRect(0, contador, CONTROL.ANCHO, valor, Color.new(0, 0, 0, (actual*3)))
				end
			end
		end
		if (CONTROL.CUSTOM_ANIM == 13 or CONTROL.CUSTOM_ANIM == 14) and trans_especial == false then
			if CONTROL.CUSTOM_ANIM == 13 then
				local zoom_x, zoom_y = CONTROL.LOGO_X*actual/6, CONTROL.LOGO_Y*actual/6
				Graphics.drawScaleImage(LISTAS.LOGO, (CONTROL.ANCHO//2)-(zoom_x//2), (CONTROL.ALTO//2)-(zoom_y//2), zoom_x, zoom_y)
			elseif CONTROL.CUSTOM_ANIM == 14 then
				local zoom_x, zoom_y, flip_1, flip_2 = CONTROL.SPRITE_X*actual/6, CONTROL.SPRITE_Y*actual/6, 0, 0
				if SPRITES.AUTO_MOVE_SPRITE[LISTAS.IDENTIDAD] == 7 or SPRITES.AUTO_MOVE_SPRITE[LISTAS.IDENTIDAD] == 9 then
					flip_1 = 1
				end
				if SPRITES.AUTO_MOVE_SPRITE[LISTAS.IDENTIDAD] == 8 or SPRITES.AUTO_MOVE_SPRITE[LISTAS.IDENTIDAD] == 9 then
					flip_2 = 1
				end
				dibujar_sprites(LISTAS.IDENTIDAD, (CONTROL.ANCHO//2)-(zoom_x//2), (CONTROL.ALTO//2)-(zoom_y//2), zoom_x, zoom_y, 0.00, flip_1, flip_2, false)
			end
		end
		refrescar(false)
	end
	if CONTROL.CUSTOM_ANIM == 15 and trans_especial == false then
		JOYSTICK_LIMITE = control_FPS(1)
	else
		CONTROL.JOYSTICK_ON, JOYSTICK_LIMITE = true, pre_time
	end
end

--- Determina los colores predeterminados de cada emulador. -----------------------------
function color_emu(identidad, act_rgb_fondo, act_color_fondo)
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
	if identidad == 1 and act_rgb_fondo == 1 and act_color_fondo == 0 then
		EMU_1 = 128; EMU_2 = 128; EMU_3 = 128;
		R = 128; G = 128; B = 128;
		MAX = 128; MIN = 118; RGB = 4; ACTUAL = 128;
		BLANCO_1 = 74; BLANCO_2 = 74; BLANCO_3 = 74;

	-- Colores para Sega Master System. -------------------------------------------------
	elseif identidad == 2 and act_rgb_fondo == 1 and act_color_fondo == 0 then
		EMU_1 = 0; EMU_2 = 60; EMU_3 = 128;
		R = 0; G = 50; B = 128;
		MAX = 70; MIN = 50; RGB = 2; ACTUAL = 50;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para Sega Game Gear. -----------------------------------------------------
	elseif identidad == 3 and act_rgb_fondo == 1 and act_color_fondo == 0 then
		EMU_1 = 0; EMU_2 = 90; EMU_3 = 100;
		R = 0; G = 90; B = 100;
		MAX = 120; MIN = 90; RGB = 2; ACTUAL = 90;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para Nintendo Famicom. ---------------------------------------------------
	elseif identidad == 4 and act_rgb_fondo == 1 and act_color_fondo == 0 then
		EMU_1 = 128; EMU_2 = 25; EMU_3 = 25;
		R = 128; G = 1; B = 1;
		MAX = 26; MIN = 1; RGB = 4; ACTUAL = 1;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para Nintendo Game Boy. --------------------------------------------------
	elseif identidad == 5 and act_rgb_fondo == 1 and act_color_fondo == 0 then
		EMU_1 = 0; EMU_2 = 128; EMU_3 = 20;
		R = 0; G = 100; B = 0;
		MAX = 120; MIN = 100; RGB = 2; ACTUAL = 100;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para Nintendo Game Boy Color. --------------------------------------------
	elseif identidad == 6 and act_rgb_fondo == 1 and act_color_fondo == 0 then
		EMU_1 = 110; EMU_2 = 110; EMU_3 = 5;
		R = 108; G = 108; B = 0;
		MAX = 128; MIN = 108; RGB = 2; ACTUAL = 108;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para Nintendo Game Boy Advance. ------------------------------------------
	elseif identidad == 7 and act_rgb_fondo == 1 and act_color_fondo == 0 then
		EMU_1 = 118; EMU_2 = 25; EMU_3 = 118;
		R = 100; G = 0; B = 100;
		MAX = 120; MIN = 100; RGB = 5; ACTUAL = 100;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para Atari 2600. ---------------------------------------------------------
	elseif identidad == 8 and act_rgb_fondo == 1 and act_color_fondo == 0 then
		EMU_1 = 120; EMU_2 = 80; EMU_3 = 0;
		R = 128; G = 42; B = 0;
		MAX = 64; MIN = 42; RGB = 2; ACTUAL = 42;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para Atari Lynx. ---------------------------------------------------------
	elseif identidad == 9 and act_rgb_fondo == 1 and act_color_fondo == 0 then
		EMU_1 = 128; EMU_2 = 128; EMU_3 = 58;
		R = 128; G = 128; B = 74;
		MAX = 94; MIN = 74; RGB = 3; ACTUAL = 74;
		BLANCO_1 = 84; BLANCO_2 = 84; BLANCO_3 = 84;

	-- Colores para Sega SG 1000. -------------------------------------------------------
	elseif identidad == 10 and act_rgb_fondo == 1 and act_color_fondo == 0 then
		EMU_1 = 0; EMU_2 = 120; EMU_3 = 80;
		R = 0; G = 100; B = 50;
		MAX = 70; MIN = 50; RGB = 3; ACTUAL = 50;
		BLANCO_1 = 74; BLANCO_2 = 74; BLANCO_3 = 74;

	-- Colores para Neo Geo Pocket. -----------------------------------------------------
	elseif identidad == 11 and act_rgb_fondo == 1 and act_color_fondo == 0 then
		EMU_1 = 128; EMU_2 = 30; EMU_3 = 70;
		R = 128; G = 0; B = 40;
		MAX = 60; MIN = 40; RGB = 3; ACTUAL = 40;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para Nintendo Super Famicom. ---------------------------------------------
	elseif identidad == 12 and act_rgb_fondo == 1 and act_color_fondo == 0 then
		EMU_1 = 108; EMU_2 = 25; EMU_3 = 108;
		R = 100; G = 50; B = 100;
		MAX = 120; MIN = 100; RGB = 5; ACTUAL = 100;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para APPS. ---------------------------------------------------------------
	elseif identidad == 13 and act_rgb_fondo == 1 and act_color_fondo == 0 then
		EMU_1 = 0; EMU_2 = 100; EMU_3 = 128;
		R = 0; G = 100; B = 128;
		MAX = 128; MIN = 100; RGB = 2; ACTUAL = 100;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para PlayStation 1. ------------------------------------------------------
	elseif identidad == 14 and act_rgb_fondo == 1 and act_color_fondo == 0 then
		EMU_1 = 0; EMU_2 = 60; EMU_3 = 128;
		R = 0; G = 60; B = 128;
		MAX = 80; MIN = 60; RGB = 2; ACTUAL = 60;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores para PlayStation 2. ------------------------------------------------------
	elseif identidad == 15 and act_rgb_fondo == 1 and act_color_fondo == 0 then
		EMU_1 = 0; EMU_2 = 80; EMU_3 = 128;
		R = 0; G = 80; B = 128;
		MAX = 100; MIN = 80; RGB = 2; ACTUAL = 80;
		BLANCO_1 = 128; BLANCO_2 = 128; BLANCO_3 = 128;

	-- Colores personalizados. ----------------------------------------------------------
	elseif act_color_fondo == 1 then
		EMU_1 = OPCIONES.R; EMU_2 = OPCIONES.G; EMU_3 = OPCIONES.B;
		R = OPCIONES.R; G = OPCIONES.G; B = OPCIONES.B;
		MAX = 0; MIN = 0; RGB = 0; ACTUAL = 0;
		BLANCO_1 = OPCIONES.COLOR_LISTA_B ; BLANCO_2 = OPCIONES.COLOR_LISTA_B; BLANCO_3 = OPCIONES.COLOR_LISTA_B;

	-- Sin colores. ---------------------------------------------------------------------
	elseif act_rgb_fondo == 0 then
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
function RGB(rgb_on, act_color_fondo, transparencia)
	if CAMBIOS_EMUS.CAM_COLOR_ACTUAL == true and act_color_fondo == 0 and rgb_on == 1 then
		if CAMBIOS_EMUS.COLOR_ACTUAL <= CAMBIOS_EMUS.COLOR_MAX then
			CAMBIOS_EMUS.COLOR_ACTUAL = CAMBIOS_EMUS.COLOR_ACTUAL+1
		else
			CAMBIOS_EMUS.CAM_COLOR_ACTUAL = false
		end
	elseif CAMBIOS_EMUS.CAM_COLOR_ACTUAL == false and act_color_fondo == 0 and rgb_on == 1 then
		if CAMBIOS_EMUS.COLOR_ACTUAL >= CAMBIOS_EMUS.COLOR_MIN then
			CAMBIOS_EMUS.COLOR_ACTUAL = CAMBIOS_EMUS.COLOR_ACTUAL-1
		else
			CAMBIOS_EMUS.CAM_COLOR_ACTUAL = true
		end
	end
	if (CAMBIOS_EMUS.RGB_COLOR == 0 or rgb_on == 0) and act_color_fondo == 0 then
		CAMBIOS_EMUS.COLOR_EMU_BACK = Color.new(CAMBIOS_EMUS.R, CAMBIOS_EMUS.G, CAMBIOS_EMUS.B)
	elseif (CAMBIOS_EMUS.RGB_COLOR == 0 or rgb_on == 0) and act_color_fondo == 1 then
		if transparencia == 0 then
			CAMBIOS_EMUS.COLOR_EMU_BACK = Color.new(CAMBIOS_EMUS.R, CAMBIOS_EMUS.G, CAMBIOS_EMUS.B)
		else
			CAMBIOS_EMUS.COLOR_EMU_BACK = Color.new(CAMBIOS_EMUS.R, CAMBIOS_EMUS.G, CAMBIOS_EMUS.B, transparencia)
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
		LISTAS.LOGO = LOGOS.ATARILYNX
	elseif identidad == 10 then
		LISTAS.LOGO = LOGOS.SEGASG1000
	elseif identidad == 11 then
		LISTAS.LOGO = LOGOS.NEOGEOPOCKET
	elseif identidad == 12 then
		LISTAS.LOGO = LOGOS.SUPERFAMICOM
	elseif identidad == 13 then
		LISTAS.LOGO = LOGOS.APPS
	elseif identidad == 14 then
		LISTAS.LOGO = LOGOS.PLAYSTATION
	elseif identidad == 15 then
		LISTAS.LOGO = LOGOS.PLAYSTATION2
	else
		LISTAS.LOGO = LOGOS.DEFAULT
	end
end

--- Realizar animaciones de los sprites. ------------------------------------------------
function dibujar_sprites(sistema, pos_x, pos_y, esc_x, esc_y, angulo, voltear_x, voltear_y, mover)
	local largo_x, alto_y, fix = SPRITES.WIDTH_X[sistema], SPRITES.HEIGHT_Y[sistema], 0
	local frame_speed, num_filas, num_columnas = 4, SPRITES.N_ROWS[sistema], SPRITES.N_COLUMNS[sistema]
	local color_sprite, zoom_x_fix, zoom_y_fix = Color.new(128, 128, 128), 0, 0
	-- Controlar la velocidad en las animaciones. ---------------------------------------
	if CONTROL.FPS >= 28 then
		frame_speed = 5
	elseif CONTROL.FPS >= 10 then
		frame_speed = CONTROL.FPS//6
	elseif CONTROL.FPS <= 9 then
		frame_speed = 1
	end

	-- Cambiar las animaciones. ---------------------------------------------------------
	if SPRITES.ANI_FRAME >= 1 then
		SPRITES.ANI_FRAME = SPRITES.ANI_FRAME-1
	else
		SPRITES.ANI_FRAME = frame_speed
	end

	-- Recorrer las animaciones. --------------------------------------------------------
	if SPRITES.X == (largo_x*num_columnas)-largo_x and SPRITES.ANI_FRAME == frame_speed then
		SPRITES.Y = cambiar_valor(SPRITES.Y, 0, (alto_y*num_filas)-alto_y, alto_y, true)
		SPRITES.X = cambiar_valor(SPRITES.X, 0, (largo_x*num_columnas)-largo_x, largo_x, true)
	elseif SPRITES.ANI_FRAME == frame_speed then
		SPRITES.X = cambiar_valor(SPRITES.X, 0, (largo_x*num_columnas)-largo_x, largo_x, true)
	end

	-- Voltear horizontalmente. ---------------------------------------------------------
	local x_flip = 0
	if voltear_x == 1 then
		x_flip = largo_x-1
		largo_x = (-largo_x)+1
	end

	-- Voltear verticalmente. -----------------------------------------------------------
	local y_flip = 0
	if voltear_y == 1 then
		y_flip = alto_y-1
		alto_y = (-alto_y)+1
	end

	-- Movimientos de sprites. ----------------------------------------------------------
	if (SPRITES.MOVE[sistema] >= 1 or SPRITES.TRAN_SPRITE_ON[sistema] >= 1 or SPRITES.SPIN_SPRITE_ON[sistema] >= 1 or SPRITES.AUTO_MOVE_SPRITE[sistema] >= 1) and mover == true then
		-- Define las animaciones de sprites. -------------------------------------------
		local veloc = SPRITES.SPEED_SPRITE[sistema]
		local sprite_pos_x, sprite_pos_y, sprite_tam_x, sprite_tam_y = SPRITES.MOVE_X, SPRITES.MOVE_Y, CONTROL.SPRITE_X, CONTROL.SPRITE_Y
		local sprite_ant_x, sprite_ant_y, limit_x, limit_y = pos_x, pos_y, CONTROL.ANCHO, CONTROL.ALTO_F
		if (SPRITES.MOVE[sistema] >= 13 and SPRITES.MOVE[sistema] <= 24) or (SPRITES.MOVE[sistema] >= 35 and SPRITES.MOVE[sistema] <= 44) then
			sprite_pos_x, sprite_pos_y, sprite_tam_x, sprite_tam_y = SPRITES.MOVE_Y, SPRITES.MOVE_X, CONTROL.SPRITE_Y, CONTROL.SPRITE_X
			sprite_ant_x, sprite_ant_y, limit_x, limit_y = pos_y, pos_x, CONTROL.ALTO_F, CONTROL.ANCHO
		end
		local function animar_sprite(pos, mini, maxi, tama, velocidad, invertir, ruleta, control)
			if (pos > maxi and invertir == false) or (pos < mini and invertir == true) then
				if invertir == false and (ruleta == true) then
					if ruleta == true then
						pos = mini-velocidad
					end
				elseif invertir == true and (ruleta == true) then
					if ruleta == true then
						pos = maxi+velocidad
					end
				elseif invertir == false and ruleta == false then
					control = true
				elseif invertir == true and ruleta == false then
					control = false
				end
			else
				pos = pos+velocidad
			end
			return pos, control
		end

		-- Realizar animaciones de sprites. ---------------------------------------------
		-- Animaciones de sprites generales. --------------------------------------------
		if (SPRITES.MOVE[sistema] >= 1 and SPRITES.MOVE[sistema] <= 24) or (SPRITES.MOVE[sistema] >= 45 and SPRITES.MOVE[sistema] <= 50) then
			local inv_move_1, inv_move_2, min_x, max_x, min_y, max_y = false, false, 0-sprite_tam_x, limit_x, 0-sprite_tam_y, limit_y
			local ruleta_act_1, ruleta_act_2, veloc_1, veloc_2 = true, true, veloc, veloc
			local wanted = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 0}
			local tipo = 13
			if SPRITES.MOVE[sistema] >= 1 and SPRITES.MOVE[sistema] <= 12 then
				tipo = SPRITES.MOVE[sistema]
			elseif SPRITES.MOVE[sistema] >= 13 and SPRITES.MOVE[sistema] <= 24 then
				tipo = SPRITES.MOVE[sistema]-12
			end
			-- Invertir desplazamiento. -------------------------------------------------
			if (wanted[tipo] == 2 or wanted[tipo] == 4 or wanted[tipo] == 6 or SPRITES.MOVE[sistema] == 48 or SPRITES.MOVE[sistema] == 50) or (((wanted[tipo] >= 7 and wanted[tipo] <= 12) or SPRITES.MOVE[sistema] == 45 or SPRITES.MOVE[sistema] == 46) and SPRITES.MOVE_ALT_X == true) then
				inv_move_1, veloc_1 = true, -veloc_1
			end
			if SPRITES.MOVE[sistema] == 49 or SPRITES.MOVE[sistema] == 50 or (((wanted[tipo] >= 3 and wanted[tipo] <= 6) or (wanted[tipo] >= 10 and wanted[tipo] <= 12) or SPRITES.MOVE[sistema] == 45 or SPRITES.MOVE[sistema] == 46) and SPRITES.MOVE_ALT_Y == true) then
				inv_move_2, veloc_2 = true, -veloc_2
			end

			-- Desplazamiento en el eje x. ----------------------------------------------
			if wanted[tipo] >= 7 and wanted[tipo] <= 12 then
				ruleta_act_1 = false
				local caminata = 100
				if wanted[tipo] == 8 or wanted[tipo] == 11 then
					caminata = 160
				end
				min_x, max_x = (sprite_ant_x+(sprite_tam_x/2))-caminata, (sprite_ant_x-(sprite_tam_x/2))+caminata
				if min_x <= 0 or wanted[tipo] == 9 or wanted[tipo] == 12 then
					min_x = 0
				end
				if max_x >= limit_x-sprite_tam_x or wanted[tipo] == 9 or wanted[tipo] == 12 then
					max_x = limit_x-sprite_tam_x
				end
			end
			if SPRITES.MOVE[sistema] == 45 or SPRITES.MOVE[sistema] == 46 then
				ruleta_act_1, ruleta_act_2 = false, false
				local tam_final = (sprite_tam_x+sprite_tam_y)/2
				min_x, max_x = (pos_x)-(tam_final/3), (pos_x)+(tam_final/3)
				min_y, max_y = (pos_y)-(tam_final/3), (pos_y)+(tam_final/3)
				veloc_1, veloc_2 = veloc_1/2, veloc_2/2
			end
			sprite_pos_x, SPRITES.MOVE_ALT_X = animar_sprite(sprite_pos_x, min_x, max_x, sprite_tam_x, veloc_1, inv_move_1, ruleta_act_1, SPRITES.MOVE_ALT_X)

			-- Desplazamiento en el eje y. ----------------------------------------------
			if wanted[tipo] == 3 or wanted[tipo] == 4 then
				ruleta_act_2 = false
				min_y, max_y = sprite_ant_y-(sprite_tam_y/2), sprite_ant_y+(sprite_tam_y/2)
			elseif wanted[tipo] == 5 or wanted[tipo] == 6 then
				ruleta_act_2 = false
				min_y, max_y = 0, limit_y-sprite_tam_y
			elseif SPRITES.MOVE[sistema] >= 47 and SPRITES.MOVE[sistema] <= 50 then
				veloc_2 = veloc_2/2
			elseif wanted[tipo] >= 10 and wanted[tipo] <= 12 then
				ruleta_act_2 = false
				min_y, max_y = (sprite_ant_y-(sprite_tam_y/2))+(sprite_tam_y/3), (sprite_ant_y+(sprite_tam_y/2))-(sprite_tam_y/3)
			end
			if (wanted[tipo] >= 3 and wanted[tipo] <= 6) or (wanted[tipo] >= 10 and wanted[tipo] <= 12) or (SPRITES.MOVE[sistema] >= 45 and SPRITES.MOVE[sistema] <= 50) then
				sprite_pos_y, SPRITES.MOVE_ALT_Y = animar_sprite(sprite_pos_y, min_y, max_y, sprite_tam_y, veloc_2, inv_move_2, ruleta_act_2, SPRITES.MOVE_ALT_Y)
			end
			if SPRITES.MOVE[sistema] == 45 then
				SPRITES.MOVE_ALT_Y = SPRITES.MOVE_ALT_X
			elseif SPRITES.MOVE[sistema] == 46 then
				if SPRITES.MOVE_ALT_X == true then SPRITES.MOVE_ALT_Y = false else SPRITES.MOVE_ALT_Y = true end
			end

		-- Animación de velocidad. ------------------------------------------------------
		elseif SPRITES.MOVE[sistema] >= 25 and SPRITES.MOVE[sistema] <= 44 then
			local inv_move_1, veloc_1, veloc_2, reset_x, reset_y, aumento, divisor = false, veloc, veloc, 0-(50+sprite_tam_x), 0-(sprite_tam_y/2), 0, limit_x
			local wanted = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
			local tipo = SPRITES.MOVE[sistema]-24
			if SPRITES.MOVE[sistema] >= 35 then
				tipo = SPRITES.MOVE[sistema]-34
			end
			-- Invertir desplazamiento. -------------------------------------------------
			if wanted[tipo] == 2 or wanted[tipo] == 4 or wanted[tipo] == 6 or wanted[tipo] == 8 or wanted[tipo] == 10 then
				inv_move_1, veloc_1, reset_x = true, -veloc_1, limit_x+50
			end

			-- Calcular aumento y disminución de velocidad. -----------------------------
			if wanted[tipo] == 3 or wanted[tipo] == 4 then
				reset_y = limit_y-(sprite_tam_y/2)
			elseif (wanted[tipo] == 7 or wanted[tipo] == 8) and SPRITES.MOVE_ALT_Y == true then
				sprite_pos_y = sprite_pos_y+sprite_tam_y
				if sprite_pos_y >= limit_y-(sprite_tam_y/2) then
					sprite_pos_y = 0
				end
			elseif (wanted[tipo] == 9 or wanted[tipo] == 10) then
				divisor = divisor/2
			end
			for plus = 1, 20 do
				if (sprite_pos_x <= (divisor/20)*plus and inv_move_1 == false) or (sprite_pos_x >= (limit_x-sprite_tam_x)-((divisor/20)*plus) and inv_move_1 == true) then
					aumento = plus
					if (wanted[tipo] == 9 or wanted[tipo] == 10) then
						aumento = 21-(aumento+1)
					end
					break
				end
			end

			-- Invertir valor del aumento. ----------------------------------------------
			if wanted[tipo] == 2 or wanted[tipo] == 4 or wanted[tipo] == 6 or wanted[tipo] == 8 or wanted[tipo] == 10 then
				aumento = -aumento
			end
			SPRITES.MOVE_ALT_Y = false

			-- Desplazamiento en el eje x. ----------------------------------------------
			if (sprite_pos_x <= limit_x+50 and inv_move_1 == false) or (sprite_pos_x >= 0-(50+sprite_tam_x) and inv_move_1 == true) then
				sprite_pos_x = sprite_pos_x+(veloc_1+aumento)
			elseif (sprite_pos_x >= limit_x+50 and inv_move_1 == false) or (sprite_pos_x <= 0-(50+sprite_tam_x) and inv_move_1 == true) then
				sprite_pos_x = reset_x
				SPRITES.MOVE_ALT_X = false
				if wanted[tipo] >= 1 and wanted[tipo] <= 4 then
					sprite_pos_y = reset_y
				elseif wanted[tipo] == 7 or wanted[tipo] == 8 then
					SPRITES.MOVE_ALT_Y = true
				end
			end

			-- Desplazamiento en el eje y. ----------------------------------------------
			if wanted[tipo] >= 1 and wanted[tipo] <= 4 then
				local alternar = (limit_x/2)-(sprite_tam_x/2)
				if (sprite_pos_x <= alternar and inv_move_1 == false) or (sprite_pos_x >= alternar and inv_move_1 == true) then
					if wanted[tipo] == 3 or wanted[tipo] == 4 then
						sprite_pos_y = sprite_pos_y-(veloc_2*2)
					else
						sprite_pos_y = sprite_pos_y+(veloc_2*2)
					end
				else
					if wanted[tipo] == 3 or wanted[tipo] == 4 then
						sprite_pos_y = sprite_pos_y+(veloc_2/2)*2
					else
						sprite_pos_y = sprite_pos_y-(veloc_2/2)*2
					end
				end
			end

		-- Animación de marco. ----------------------------------------------------------
		elseif SPRITES.MOVE[sistema] == 51 or SPRITES.MOVE[sistema] == 52 then
			local inv_move_1, min_x, max_x, min_y, max_y, flip = false, 0, limit_x, 0, limit_y, 1
			if SPRITES.MOVE[sistema] == 52 then
				inv_move_1 = true
			end
			if veloc == 1 then
				flip = 0.99
			end
			if inv_move_1 == false then
				if sprite_pos_x <= max_x-sprite_tam_x-veloc and SPRITES.MOVE_ALT_X == false then
					sprite_pos_x = sprite_pos_x+veloc
				elseif sprite_pos_x >= max_x-sprite_tam_x-veloc and sprite_pos_y <= max_y-sprite_tam_y-veloc and SPRITES.MOVE_ALT_X == false then
					sprite_pos_x = max_x-sprite_tam_x-(flip)
					sprite_pos_y = sprite_pos_y+veloc
				elseif sprite_pos_y >= max_y-sprite_tam_y-veloc and SPRITES.MOVE_ALT_X == false then
					sprite_pos_y = max_y-sprite_tam_y-(flip)
					SPRITES.MOVE_ALT_X = true
				elseif sprite_pos_x >= min_x+veloc and SPRITES.MOVE_ALT_X == true then
					sprite_pos_x = sprite_pos_x-veloc
				elseif sprite_pos_x <= min_x+veloc and sprite_pos_y >= min_y+veloc and SPRITES.MOVE_ALT_X == true then
					sprite_pos_x = min_x+(flip)
					sprite_pos_y = sprite_pos_y-veloc
				elseif sprite_pos_y <= min_y+veloc and SPRITES.MOVE_ALT_X == true then
					sprite_pos_y = min_y+(flip)
					SPRITES.MOVE_ALT_X = false
				end
			elseif inv_move_1 == true then
				if sprite_pos_x >= min_x+veloc and SPRITES.MOVE_ALT_X == false then
					sprite_pos_x = sprite_pos_x-veloc
				elseif sprite_pos_x <= min_x+veloc and sprite_pos_y <= max_y-sprite_tam_y-veloc and SPRITES.MOVE_ALT_X == false then
					sprite_pos_x = min_x+(flip)
					sprite_pos_y = sprite_pos_y+veloc
				elseif sprite_pos_y >= max_y-sprite_tam_y-veloc and SPRITES.MOVE_ALT_X == false then
					sprite_pos_y = max_y-sprite_tam_y-(flip)
					SPRITES.MOVE_ALT_X = true
				elseif sprite_pos_x <= max_x-sprite_tam_x-veloc and SPRITES.MOVE_ALT_X == true then
					sprite_pos_x = sprite_pos_x+veloc
				elseif sprite_pos_x >= max_x-sprite_tam_x-veloc and sprite_pos_y >= min_y+veloc and SPRITES.MOVE_ALT_X == true then
					sprite_pos_x = max_x-sprite_tam_x-(flip)
					sprite_pos_y = sprite_pos_y-veloc
				elseif sprite_pos_y <= min_y+veloc and SPRITES.MOVE_ALT_X == true then
					sprite_pos_y = min_y+(flip)
					SPRITES.MOVE_ALT_X = false
				end
			end

		-- Animación en círculos. -------------------------------------------------------
		elseif SPRITES.MOVE[sistema] >= 53 and SPRITES.MOVE[sistema] <= 58 then
			local maximo, veloc_c = sprite_tam_y, "0.00".. veloc
			if veloc >= 1 and veloc <= 9 then
				veloc_c = "0.00".. veloc
			elseif veloc >= 10 and veloc <= 18 then
				veloc_c = "0.0".. veloc-9
			elseif veloc >= 19 and veloc <= 27 then
				veloc_c = "0.1".. veloc
			elseif veloc >= 28 and veloc <= 36 then
				veloc_c = "0.2".. veloc
			elseif veloc >= 37 and veloc <= 45 then
				veloc_c = "0.3".. veloc
			elseif veloc >= 46 and veloc <= 54 then
				veloc_c = "0.4".. veloc
			elseif veloc >= 55 and veloc <= 62 then
				veloc_c = "0.5".. veloc
			end
			if sprite_tam_x >= sprite_tam_y then
				maximo = sprite_tam_x
			end
			local pos_x, pos_y, inv_move_1, radio = sprite_ant_x, sprite_ant_y, false, (maximo/2)
			if SPRITES.MOVE[sistema] == 54 or SPRITES.MOVE[sistema] == 56 or SPRITES.MOVE[sistema] == 58 then
				inv_move_1 = true
			end
			if SPRITES.MOVE[sistema] == 55 or SPRITES.MOVE[sistema] == 56 then
				radio = (maximo/2)+26
			elseif SPRITES.MOVE[sistema] == 57 or SPRITES.MOVE[sistema] == 58 then
				pos_x, pos_y, radio = CONTROL.ANCHO//2-(sprite_tam_x//2), CONTROL.ALTO_F//2-(sprite_tam_y//2), (CONTROL.ALTO_F//2)-(maximo//2)
			end
			if inv_move_1 == false and SPRITES.ANG_SPRITE+tonumber(veloc_c) <= 6.27 then
				SPRITES.ANG_SPRITE = SPRITES.ANG_SPRITE+tonumber(veloc_c)
			elseif inv_move_1 == false then
				SPRITES.ANG_SPRITE = 0.00
			end
			if inv_move_1 == true and SPRITES.ANG_SPRITE-tonumber(veloc_c) >= 0.00 then
				SPRITES.ANG_SPRITE = SPRITES.ANG_SPRITE-tonumber(veloc_c)
			elseif inv_move_1 == true then
				SPRITES.ANG_SPRITE = 6.27
			end
			sprite_pos_x = pos_x+radio*math.cos(SPRITES.ANG_SPRITE)
			sprite_pos_y = pos_y+radio*math.sin(SPRITES.ANG_SPRITE)

		-- Animación rebotando. ---------------------------------------------------------
		elseif SPRITES.MOVE[sistema] == 59 then
			if sprite_pos_x <= limit_x-sprite_tam_x and SPRITES.MOVE_ALT_X == false then
				sprite_pos_x = sprite_pos_x+veloc
			elseif SPRITES.MOVE_ALT_X == false then
				sprite_pos_x = limit_x-sprite_tam_x
				SPRITES.MOVE_ALT_X = true
			elseif sprite_pos_x >= 0 and SPRITES.MOVE_ALT_X == true then
				sprite_pos_x = sprite_pos_x-veloc
			elseif SPRITES.MOVE_ALT_X == true then
				sprite_pos_x = 0
				SPRITES.MOVE_ALT_X = false
			end
			if sprite_pos_y <= limit_y-sprite_tam_y and SPRITES.MOVE_ALT_Y == false then
				sprite_pos_y = sprite_pos_y+veloc
			elseif SPRITES.MOVE_ALT_Y == false then
				sprite_pos_y = limit_y-sprite_tam_y
				SPRITES.MOVE_ALT_Y = true
			elseif sprite_pos_y >= 0 and SPRITES.MOVE_ALT_Y == true then
				sprite_pos_y = sprite_pos_y-veloc
			elseif SPRITES.MOVE_ALT_Y == true then
				sprite_pos_y = 0
				SPRITES.MOVE_ALT_Y = false
			end

		-- Animación de zoom. -----------------------------------------------------------
		elseif SPRITES.MOVE[sistema] == 60 or SPRITES.MOVE[sistema] == 61 then
			local z_max = sprite_tam_x+(sprite_tam_x/2)
			if SPRITES.MOVE[sistema] == 61 then
				z_max = sprite_tam_x*2
			end
			if SPRITES.ZOOM_SPRITE[1]+veloc <= z_max and SPRITES.ZOOM_SPRITE[2] == false then
				SPRITES.ZOOM_SPRITE[1] = SPRITES.ZOOM_SPRITE[1]+veloc
			elseif SPRITES.ZOOM_SPRITE[2] == false then
				SPRITES.ZOOM_SPRITE[1] = SPRITES.ZOOM_SPRITE[1]+veloc
				SPRITES.ZOOM_SPRITE[2] = true
			elseif SPRITES.ZOOM_SPRITE[1]-veloc >= veloc and SPRITES.ZOOM_SPRITE[2] == true then
				SPRITES.ZOOM_SPRITE[1] = SPRITES.ZOOM_SPRITE[1]-veloc
			elseif SPRITES.ZOOM_SPRITE[2] == true then
				SPRITES.ZOOM_SPRITE[1] = SPRITES.ZOOM_SPRITE[1]-veloc
				SPRITES.ZOOM_SPRITE[2] = false
			end
			local zoom_fix = -(SPRITES.ZOOM_SPRITE[1]/2)
			zoom_x_fix, zoom_y_fix, esc_x, esc_y = zoom_fix/2, zoom_fix/2, esc_x+SPRITES.ZOOM_SPRITE[1]/2, esc_y+SPRITES.ZOOM_SPRITE[1]/2

		-- Controlar animación de sprites (stick derecho). ------------------------------
		elseif SPRITES.MOVE[sistema] == 62 then
			local Right_X_spr, Right_Y_spr = Pads.getRightStick(0)
			if Right_X_spr >= 2 then
				sprite_pos_x = cambiar_valor(sprite_pos_x, 0-sprite_tam_x, limit_x, veloc, true)
			elseif Right_X_spr <= -2 then
				sprite_pos_x = cambiar_valor(sprite_pos_x, 0-sprite_tam_x, limit_x, veloc, false)
			end
			if Right_Y_spr >= 2 then
				sprite_pos_y = cambiar_valor(sprite_pos_y, 0-sprite_tam_y, limit_y, veloc, true)
			elseif Right_Y_spr <= -2 then
				sprite_pos_y = cambiar_valor(sprite_pos_y, 0-sprite_tam_y, limit_y, veloc, false)
			end
		end

		-- Aplicar las posiciones en las animaciones. -----------------------------------
		local pos_flip_x, pos_flip_y = sprite_pos_x, sprite_pos_y
		if (SPRITES.MOVE[sistema] >= 13 and SPRITES.MOVE[sistema] <= 24) or (SPRITES.MOVE[sistema] >= 35 and SPRITES.MOVE[sistema] <= 44) then
			pos_flip_x, pos_flip_y = sprite_pos_y, sprite_pos_x
		end
		if (SPRITES.AUTO_MOVE_SPRITE[sistema] == 1 or SPRITES.AUTO_MOVE_SPRITE[sistema] == 3) then
			if pos_flip_x > SPRITES.MOVE_X then
				SPRITES.FLIP[1] = 0
			elseif pos_flip_x < SPRITES.MOVE_X then
				SPRITES.FLIP[1] = 1
			end
		end
		if (SPRITES.AUTO_MOVE_SPRITE[sistema] == 2 or SPRITES.AUTO_MOVE_SPRITE[sistema] == 3) then
			if pos_flip_y > SPRITES.MOVE_Y then
				SPRITES.FLIP[2] = 1
			elseif pos_flip_y < SPRITES.MOVE_Y then
				SPRITES.FLIP[2] = 0
			end
		end
		if SPRITES.AUTO_MOVE_SPRITE[sistema] >= 4 and SPRITES.AUTO_MOVE_SPRITE[sistema] <= 9 then
			local Right_X_spr, Right_Y_spr = Pads.getRightStick(0)
			if Right_X_spr > 2 and (SPRITES.AUTO_MOVE_SPRITE[sistema] == 4 or SPRITES.AUTO_MOVE_SPRITE[sistema] == 6) then
				SPRITES.FLIP[1] = 0
			elseif Right_X_spr < -2 and (SPRITES.AUTO_MOVE_SPRITE[sistema] == 4 or SPRITES.AUTO_MOVE_SPRITE[sistema] == 6) then
				SPRITES.FLIP[1] = 1
			elseif SPRITES.AUTO_MOVE_SPRITE[sistema] == 7 or SPRITES.AUTO_MOVE_SPRITE[sistema] == 9 then
				SPRITES.FLIP[1] = 1
			end
			if Right_Y_spr > 2 and (SPRITES.AUTO_MOVE_SPRITE[sistema] == 5 or SPRITES.AUTO_MOVE_SPRITE[sistema] == 6) then
				SPRITES.FLIP[2] = 1
			elseif Right_Y_spr < -2 and (SPRITES.AUTO_MOVE_SPRITE[sistema] == 5 or SPRITES.AUTO_MOVE_SPRITE[sistema] == 6) then
				SPRITES.FLIP[2] = 0
			elseif SPRITES.AUTO_MOVE_SPRITE[sistema] == 8 or SPRITES.AUTO_MOVE_SPRITE[sistema] == 9 then
				SPRITES.FLIP[2] = 1
			end
		end
		if (SPRITES.MOVE[sistema] >= 1 and SPRITES.MOVE[sistema] <= 12) or (SPRITES.MOVE[sistema] >= 25 and SPRITES.MOVE[sistema] <= 34) or (SPRITES.MOVE[sistema] >= 45 and SPRITES.MOVE[sistema] <= 62) then
			SPRITES.MOVE_X, pos_x = sprite_pos_x, sprite_pos_x
			SPRITES.MOVE_Y, pos_y = sprite_pos_y, sprite_pos_y
		elseif (SPRITES.MOVE[sistema] >= 13 and SPRITES.MOVE[sistema] <= 24) or (SPRITES.MOVE[sistema] >= 35 and SPRITES.MOVE[sistema] <= 44) then
			SPRITES.MOVE_X, pos_x = sprite_pos_y, sprite_pos_y
			SPRITES.MOVE_Y, pos_y = sprite_pos_x, sprite_pos_x
		end

		-- Aplicar las rotaciones en los sprites. ---------------------------------------
		if SPRITES.SPIN_SPRITE_ON[sistema] >= 1 and SPRITES.SPIN_SPRITE_ON[sistema] <= 62 then
			local inv_move_1, spr_rota, zig_sprite, limi_r1_spr, limi_r2_spr = false, "0.00".. SPRITES.SPIN_SPRITE_ON[sistema], false, 0.52, 5.76
			if SPRITES.SPIN_SPRITE_ON[sistema] >= 1 and  SPRITES.SPIN_SPRITE_ON[sistema] <= 9 then
				spr_rota, inv_move_1 = "0.00".. SPRITES.SPIN_SPRITE_ON[sistema], false
			elseif SPRITES.SPIN_SPRITE_ON[sistema] >= 10 and SPRITES.SPIN_SPRITE_ON[sistema] <= 18 then
				spr_rota, inv_move_1 = "0.0".. SPRITES.SPIN_SPRITE_ON[sistema]-9, false
			elseif SPRITES.SPIN_SPRITE_ON[sistema] >= 19 and SPRITES.SPIN_SPRITE_ON[sistema] <= 27 then
				spr_rota, inv_move_1 = "0.1".. SPRITES.SPIN_SPRITE_ON[sistema]-18, false
			elseif SPRITES.SPIN_SPRITE_ON[sistema] >= 28 and SPRITES.SPIN_SPRITE_ON[sistema] <= 36 then
				spr_rota, inv_move_1 = "0.00".. SPRITES.SPIN_SPRITE_ON[sistema]-27, true
			elseif SPRITES.SPIN_SPRITE_ON[sistema] >= 37 and SPRITES.SPIN_SPRITE_ON[sistema] <= 45 then
				spr_rota, inv_move_1 = "0.0".. SPRITES.SPIN_SPRITE_ON[sistema]-36, true
			elseif SPRITES.SPIN_SPRITE_ON[sistema] >= 46 and  SPRITES.SPIN_SPRITE_ON[sistema] <= 54 then
				spr_rota, inv_move_1 = "0.1".. SPRITES.SPIN_SPRITE_ON[sistema]-45, true
			elseif SPRITES.SPIN_SPRITE_ON[sistema] >= 55 and  SPRITES.SPIN_SPRITE_ON[sistema] <= 62 then
				spr_rota, zig_sprite, inv_move_1 = "0.1".. SPRITES.SPIN_SPRITE_ON[sistema]-54, true, SPRITES.SPIN_SPRITE_ALT
			end
			if inv_move_1 == false and SPRITES.SPIN_SPRITE+tonumber(spr_rota) <= 6.27 then
				SPRITES.SPIN_SPRITE = SPRITES.SPIN_SPRITE+tonumber(spr_rota)
				if (SPRITES.SPIN_SPRITE >= limi_r1_spr and SPRITES.SPIN_SPRITE <= (limi_r1_spr+0.9)) and zig_sprite == true then
					SPRITES.SPIN_SPRITE_ALT, SPRITES.SPIN_SPRITE = true, (limi_r1_spr-0.01)
				end
			elseif inv_move_1 == false then
				SPRITES.SPIN_SPRITE = 0.00
			end
			if inv_move_1 == true and SPRITES.SPIN_SPRITE-tonumber(spr_rota) >= 0.00 then
				SPRITES.SPIN_SPRITE = SPRITES.SPIN_SPRITE-tonumber(spr_rota)
				if (SPRITES.SPIN_SPRITE <= limi_r2_spr and SPRITES.SPIN_SPRITE >= (limi_r2_spr-0.9)) and zig_sprite == true then
					SPRITES.SPIN_SPRITE_ALT, SPRITES.SPIN_SPRITE = false, (limi_r2_spr+0.01)
				end
			elseif inv_move_1 == true then
				SPRITES.SPIN_SPRITE = 6.27
			end
			angulo = SPRITES.SPIN_SPRITE
		else
			angulo = 0.00
		end

		-- Aplicar las transparencias en los sprites. -----------------------------------
		if SPRITES.TRAN_SPRITE_ON[sistema] >= 1 and SPRITES.TRAN_SPRITE_ON[sistema] <= 24 then
			local spr_tras, alternar, t_veloc = 0, false, 1
			if SPRITES.TRAN_SPRITE_ON[sistema] >= 1 and SPRITES.TRAN_SPRITE_ON[sistema] <= 8 then
				spr_tras, alternar = SPRITES.TRAN_SPRITE_ON[sistema], false
			elseif SPRITES.TRAN_SPRITE_ON[sistema] >= 9 and SPRITES.TRAN_SPRITE_ON[sistema] <= 16 then
				spr_tras, alternar = SPRITES.TRAN_SPRITE_ON[sistema]-8, true
			elseif SPRITES.TRAN_SPRITE_ON[sistema] >= 17 and SPRITES.TRAN_SPRITE_ON[sistema] <= 24 then
				spr_tras, alternar = SPRITES.TRAN_SPRITE_ON[sistema]-16, nil
			end
			local max_tras_spr, min_tras_spr = 128, 0
			if spr_tras <= 7 then
				max_tras_spr = (16*spr_tras)
			end
			if alternar == nil then
				min_tras_spr = max_tras_spr//2
			end
			if alternar == false then
				SPRITES.TRAN_SPRITE = max_tras_spr
			elseif alternar == true or alternar == nil and SPRITES.ANI_FRAME == frame_speed then
				if SPRITES.TRAN_SPRITE >= min_tras_spr+t_veloc and SPRITES.TRAN_ALT_SPRITE == true then
					SPRITES.TRAN_SPRITE = SPRITES.TRAN_SPRITE-t_veloc
				elseif SPRITES.TRAN_ALT_SPRITE == true then
					SPRITES.TRAN_SPRITE = min_tras_spr
					SPRITES.TRAN_ALT_SPRITE = false
				end
				if SPRITES.TRAN_SPRITE <= max_tras_spr-t_veloc and SPRITES.TRAN_ALT_SPRITE == false then
					SPRITES.TRAN_SPRITE = SPRITES.TRAN_SPRITE+t_veloc
				elseif SPRITES.TRAN_ALT_SPRITE == false then
					SPRITES.TRAN_SPRITE = max_tras_spr
					SPRITES.TRAN_ALT_SPRITE = true
				end
			end
			color_sprite = Color.new(128, 128, 128, SPRITES.TRAN_SPRITE)
		end
	end

	-- Dibujar las animaciones en pantalla. ---------------------------------------------
	if CONTROL.ESTILO == 3 and OPCIONES.GUI_LIMPIA_ON == 1 and CONTROL.CUSTOM_LIST == true then
		fix = 242
	end
	Graphics.drawImageExtended(SPRITES[SPRITES.SPRITE_SYS[sistema]], (pos_x+fix+(esc_x/2))+zoom_x_fix, (pos_y+(esc_y/2))+zoom_y_fix, SPRITES.X+x_flip, SPRITES.Y+y_flip, (SPRITES.X+x_flip)+largo_x, (SPRITES.Y+y_flip)+alto_y, esc_x, esc_y, angulo, color_sprite)
end

--- Realizar animaciones de los sprites en fondos. --------------------------------------
function fondo_sprites(img, pos_x, pos_y, esc_x, esc_y, angulo, color, def_color)
	local largo_x, alto_y = SPRITES.FONDO_WIDTH_X, SPRITES.FONDO_HEIGHT_Y
	local frame_speed_f, num_filas, num_columnas = 4, SPRITES.FONDO_N_ROWS, SPRITES.FONDO_N_COLUMNS
	-- Controlar la velocidad en las animaciones. ---------------------------------------
	if CONTROL.FPS >= 28 then
		frame_speed_f = 5
	elseif CONTROL.FPS >= 10 then
		frame_speed_f = CONTROL.FPS//6
	elseif CONTROL.FPS <= 9 then
		frame_speed_f = 1
	end

	-- Cambiar las animaciones. ---------------------------------------------------------
	if SPRITES.FONDO_ANI_FRAME >= 1 then
		SPRITES.FONDO_ANI_FRAME = SPRITES.FONDO_ANI_FRAME-1
	else
		SPRITES.FONDO_ANI_FRAME = frame_speed_f
	end

	-- Animación por sprites. -----------------------------------------------------------
	if SPRITES.LAYER == false then
		-- Recorrer las animaciones. ----------------------------------------------------
		if SPRITES.FOND_X == (largo_x*num_columnas)-largo_x and SPRITES.FONDO_ANI_FRAME == frame_speed_f then
			SPRITES.FOND_Y = cambiar_valor(SPRITES.FOND_Y, 0, (alto_y*num_filas)-alto_y, alto_y, true)
			SPRITES.FOND_X = cambiar_valor(SPRITES.FOND_X, 0, (largo_x*num_columnas)-largo_x, largo_x, true)
		elseif SPRITES.FONDO_ANI_FRAME == frame_speed_f then
			SPRITES.FOND_X = cambiar_valor(SPRITES.FOND_X, 0, (largo_x*num_columnas)-largo_x, largo_x, true)
		end

		-- Dibujar las animaciones en pantalla. -----------------------------------------
		if color == true or color == nil then
			Graphics.drawImageExtended(img, pos_x+(esc_x/2), pos_y+(esc_y/2), SPRITES.FOND_X, SPRITES.FOND_Y, SPRITES.FOND_X+largo_x, SPRITES.FOND_Y+alto_y, esc_x, esc_y, angulo, def_color)
		else
			Graphics.drawImageExtended(img, pos_x+(esc_x/2), pos_y+(esc_y/2), SPRITES.FOND_X, SPRITES.FOND_Y, SPRITES.FOND_X+largo_x, SPRITES.FOND_Y+alto_y, esc_x, esc_y, angulo)
		end

	-- Animación por capas. -------------------------------------------------------------
	elseif SPRITES.LAYER == true then
		-- Define las animaciones de las capas. -----------------------------------------
		esc_x = esc_x-5
		local list_rgb = {CAMBIOS_EMUS.R, CAMBIOS_EMUS.G, CAMBIOS_EMUS.B}
		if CAMBIOS_EMUS.RGB_COLOR == 1 and color == true then
			list_rgb = {CAMBIOS_EMUS.COLOR_ACTUAL, CAMBIOS_EMUS.G, CAMBIOS_EMUS.B}
		elseif CAMBIOS_EMUS.RGB_COLOR == 2 and color == true then
			list_rgb = {CAMBIOS_EMUS.R, CAMBIOS_EMUS.COLOR_ACTUAL, CAMBIOS_EMUS.B}
		elseif CAMBIOS_EMUS.RGB_COLOR == 3 and color == true then
			list_rgb = {CAMBIOS_EMUS.R, CAMBIOS_EMUS.G, CAMBIOS_EMUS.COLOR_ACTUAL}
		elseif CAMBIOS_EMUS.RGB_COLOR == 4 and color == true then
			list_rgb = {CAMBIOS_EMUS.R, CAMBIOS_EMUS.COLOR_ACTUAL, CAMBIOS_EMUS.COLOR_ACTUAL}
		elseif CAMBIOS_EMUS.RGB_COLOR == 5 and color == true then
			list_rgb = {CAMBIOS_EMUS.COLOR_ACTUAL, CAMBIOS_EMUS.G, CAMBIOS_EMUS.COLOR_ACTUAL}
		elseif CAMBIOS_EMUS.RGB_COLOR == 6 and color == true then
			list_rgb = {CAMBIOS_EMUS.COLOR_ACTUAL, CAMBIOS_EMUS.COLOR_ACTUAL, CAMBIOS_EMUS.B}
		elseif CAMBIOS_EMUS.RGB_COLOR == 7 and color == true then
			list_rgb = {CAMBIOS_EMUS.COLOR_ACTUAL, CAMBIOS_EMUS.COLOR_ACTUAL, CAMBIOS_EMUS.COLOR_ACTUAL}
		elseif color == false then
			list_rgb = {128, 128, 128}
		elseif color == nil then
			list_rgb = {0, 80, 120}
		end
		local cuadro_1 = {0, largo_x, 0, alto_y, 0.00, Color.new(list_rgb[1], list_rgb[2], list_rgb[3], 128)}
		local cuadro_2 = {largo_x, (largo_x*2), 0, alto_y, 0.00, Color.new(list_rgb[1], list_rgb[2], list_rgb[3], 128)}
		local cuadro_3 = {0, largo_x, alto_y, (alto_y*2), 0.00, Color.new(list_rgb[1], list_rgb[2], list_rgb[3], 128)}
		local cuadro_4 = {largo_x, (largo_x*2), alto_y, (alto_y*2), 0.00, Color.new(list_rgb[1], list_rgb[2], list_rgb[3], 128)}
		if SPRITES.TRAN_LEVEL <= 0 then
			SPRITES.TRAN_LEVEL = 1
		end
		if SPRITES.TRAN_SPEED <= 0 then
			SPRITES.TRAN_SPEED = 1
		end
		if SPRITES.SPIN_SPEED <= 0 then
			SPRITES.SPIN_SPEED = 1
		end
		if SPRITES.LAYER_MULTI <= 0 then
			SPRITES.LAYER_MULTI = 1
		end
		local regulador = SPRITES.LAYER_SPEED
		local lay_vel, lay_vel2 = 0, 0
		if SPRITES.LAYER_SPEED <= 0 then
			regulador = 0
		elseif SPRITES.LAYER_SPEED >= 1 and SPRITES.LAYER_SPEED <= 9 then
			regulador = tonumber("0.".. SPRITES.LAYER_SPEED)
			lay_vel, lay_vel2 = tonumber(string.format("%.2f", SPRITES.LAYER_MULTI*regulador)), 0.1
			if regulador ~= 0.1 then
				lay_vel2 = tonumber(string.format("%.2f", regulador/2))
			end
		elseif SPRITES.LAYER_SPEED >= 10 and SPRITES.LAYER_SPEED <= 62 then
			regulador = SPRITES.LAYER_SPEED-9
			lay_vel, lay_vel2 = SPRITES.LAYER_MULTI*regulador, 1
			if regulador ~= 1 then
				lay_vel2 = (regulador//2)
			end
		end
		local x_fix1, x_fix2, x_fix3, x_fix4 = esc_x, esc_x, esc_x, esc_x
		local y_fix1, y_fix2, y_fix3, y_fix4 = esc_y, esc_y, esc_y, esc_y
		local pos_lay_1, pos_lay_2, pos_lay_3, pos_lay_4, pos_lay_limite = SPRITES.LAYER_X_1, SPRITES.LAYER_X_2, SPRITES.LAYER_Y_3, SPRITES.LAYER_Y_4, esc_x
		local pos_lay_ex1, pos_lay_ex2, pos_lay_ex3, pos_lay_ex4 = SPRITES.LAYER_Y_1, SPRITES.LAYER_Y_2, SPRITES.LAYER_X_3, SPRITES.LAYER_X_4
		if (SPRITES.LAYER_TYPE >= 20 and SPRITES.LAYER_TYPE <= 38) then
			pos_lay_1, pos_lay_2, pos_lay_3, pos_lay_4, pos_lay_limite = SPRITES.LAYER_Y_1, SPRITES.LAYER_Y_2, SPRITES.LAYER_X_3, SPRITES.LAYER_X_4, esc_y
			pos_lay_ex1, pos_lay_ex2, pos_lay_ex3, pos_lay_ex4 = SPRITES.LAYER_X_1, SPRITES.LAYER_X_2, SPRITES.LAYER_Y_3, SPRITES.LAYER_Y_4
		elseif SPRITES.LAYER_TYPE == 59 or SPRITES.LAYER_TYPE == 60 then
			pos_lay_ex3, pos_lay_ex4, pos_lay_1, pos_lay_2, pos_lay_limite = SPRITES.LAYER_X_1, SPRITES.LAYER_X_2, SPRITES.BACK_X, SPRITES.LAYER_X_4, esc_x
		elseif SPRITES.LAYER_TYPE == 61 or SPRITES.LAYER_TYPE == 62 then
			pos_lay_ex3, pos_lay_ex4, pos_lay_1, pos_lay_2, pos_lay_limite = SPRITES.LAYER_Y_1, SPRITES.LAYER_Y_2, SPRITES.BACK_Y, SPRITES.LAYER_Y_4, esc_y
		end

		-- Cálculos de posicionamientos extras. -----------------------------------------
		local function ani_lay(pos1, pos2, pos_limite, invertir, veloc, nueva_pos)
			if ((pos1 >= pos_limite and invertir == false) or (pos1 <= -pos_limite and invertir == true)) or (((pos1 >= pos_limite and invertir == false) or (pos1 <= -pos_limite and invertir == true)) and veloc == nil) then
				if invertir == false then
					pos1 = pos2-nueva_pos
				elseif invertir == true then
					pos1 = pos2+nueva_pos
				end
			elseif veloc ~= nil then
				pos1 = pos1+veloc
			end
			return pos1
		end
		local function snake_fx()
			if SPRITES.LAYER_TYPE == 3 or SPRITES.LAYER_TYPE == 4 or SPRITES.LAYER_TYPE == 22 or SPRITES.LAYER_TYPE == 23 then
				local vel_sna = (SPRITES.LAYER_MULTI*regulador)
				if SPRITES.ALTERNATE == true then
					pos_lay_ex1, pos_lay_ex2 = pos_lay_ex1+vel_sna, pos_lay_ex2-vel_sna
				elseif SPRITES.ALTERNATE == false then
					pos_lay_ex1, pos_lay_ex2 = pos_lay_ex1-vel_sna, pos_lay_ex2+vel_sna
				end
				if pos_lay_ex1 <= -28 then
					SPRITES.ALTERNATE = true
				elseif pos_lay_ex1 >= 28 then
					SPRITES.ALTERNATE = false
				end
			elseif SPRITES.LAYER_TYPE == 7 or SPRITES.LAYER_TYPE == 26 then
				if SPRITES.ALTERNATE == false and pos_lay_1 >= pos_lay_limite/2 then
					SPRITES.ALTERNATE = true
				elseif SPRITES.ALTERNATE == true and pos_lay_1 <= (-pos_lay_limite)/2 then
					SPRITES.ALTERNATE = false
				end
			end
		end

		-- Realizar las animaciones. ----------------------------------------------------
		-- Animaciones generales. -------------------------------------------------------
		if (SPRITES.LAYER_TYPE >= 1 and SPRITES.LAYER_TYPE <= 13) or (SPRITES.LAYER_TYPE >= 20 and SPRITES.LAYER_TYPE <= 32) or (SPRITES.LAYER_TYPE >= 59 and SPRITES.LAYER_TYPE <= 62) then
			local inv_reve, reve = true, false
			local wanted = {0; 1; 0; 1; 0; 1; 0; 0; 1; 0; 1; 0; 1; 0; 1; 0; 0; 0; 0; 0; 1; 0; 1; 0; 1; 0; 0; 1; 0; 1; 0;
							1; 0; 1; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 1; 0; 1;};
			local wanted2 = {0; 0; 0; 0; 1; 1; 0; 0; 0; 1; 1; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 1; 1; 0; 0; 0; 1; 1; 0;
							0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 1; 1; 1; 1;};
			if (SPRITES.ALTERNATE == true and (SPRITES.LAYER_TYPE == 7 or SPRITES.LAYER_TYPE == 26)) or (lay_vel >= 0.1 and wanted[SPRITES.LAYER_TYPE] == 1) then
				lay_vel, lay_vel2, inv_reve, reve = -lay_vel, -lay_vel2, false, true
			end
			pos_lay_1 = ani_lay(pos_lay_1, pos_lay_2, pos_lay_limite, reve, lay_vel, pos_lay_limite)
			pos_lay_2 = ani_lay(pos_lay_2, pos_lay_1, pos_lay_limite, reve, lay_vel, pos_lay_limite)
			pos_lay_1 = ani_lay(pos_lay_1, pos_lay_2, pos_lay_limite, reve, nil, pos_lay_limite)
			pos_lay_2 = ani_lay(pos_lay_2, pos_lay_1, pos_lay_limite, reve, nil, pos_lay_limite)
			if wanted2[SPRITES.LAYER_TYPE] == 1 then
				if SPRITES.LAYER_TYPE == 10 or SPRITES.LAYER_TYPE == 11 or SPRITES.LAYER_TYPE == 29 or SPRITES.LAYER_TYPE == 30 or (SPRITES.LAYER_TYPE >= 59 and SPRITES.LAYER_TYPE <= 62) then
					pos_lay_ex3 = ani_lay(pos_lay_ex3, pos_lay_ex4, pos_lay_limite, inv_reve, -lay_vel2, pos_lay_limite)
					pos_lay_ex4 = ani_lay(pos_lay_ex4, pos_lay_ex3, pos_lay_limite, inv_reve, -lay_vel2, pos_lay_limite)
					pos_lay_ex3 = ani_lay(pos_lay_ex3, pos_lay_ex4, pos_lay_limite, inv_reve, nil, pos_lay_limite)
					pos_lay_ex4 = ani_lay(pos_lay_ex4, pos_lay_ex3, pos_lay_limite, inv_reve, nil, pos_lay_limite)
				else
					pos_lay_ex3 = ani_lay(pos_lay_ex3, 0, pos_lay_limite, inv_reve, -lay_vel2, pos_lay_limite)
				end
			elseif SPRITES.LAYER_TYPE == 12 or SPRITES.LAYER_TYPE == 13 or SPRITES.LAYER_TYPE == 31 or SPRITES.LAYER_TYPE == 32 then
				pos_lay_ex3 = pos_lay_1
			end
			snake_fx()
			if pos_lay_1 == pos_lay_2 then
				pos_lay_1, pos_lay_2, pos_lay_ex3, pos_lay_ex4 = 0, pos_lay_limite, 0, 0
				if SPRITES.LAYER_TYPE == 3 or SPRITES.LAYER_TYPE == 4 or SPRITES.LAYER_TYPE == 22 or SPRITES.LAYER_TYPE == 23 then
					pos_lay_ex1, pos_lay_ex2 = 0, 0
				elseif SPRITES.LAYER_TYPE == 10 or SPRITES.LAYER_TYPE == 11 or SPRITES.LAYER_TYPE == 29 or SPRITES.LAYER_TYPE == 30 then
					pos_lay_ex4 = pos_lay_limite
				elseif SPRITES.LAYER_TYPE >= 59 and SPRITES.LAYER_TYPE <= 62 then
					pos_lay_1, pos_lay_2, pos_lay_ex3, pos_lay_ex4 = 0, pos_lay_limite, 0, pos_lay_limite
				end
			end

		-- Animación panorámica. --------------------------------------------------------
		elseif (SPRITES.LAYER_TYPE >= 14 and SPRITES.LAYER_TYPE <= 17) or (SPRITES.LAYER_TYPE >= 33 and SPRITES.LAYER_TYPE <= 36) then
			local reve = false
			if SPRITES.LAYER_TYPE == 15 or SPRITES.LAYER_TYPE == 17 or SPRITES.LAYER_TYPE == 34 or SPRITES.LAYER_TYPE == 36 then
				lay_vel, reve = -lay_vel, true
			end
			pos_lay_ex3 = ani_lay(pos_lay_ex3, pos_lay_1+lay_vel, pos_lay_limite, reve, lay_vel, pos_lay_limite)
			if SPRITES.LAYER_TYPE == 16 or SPRITES.LAYER_TYPE == 17 or SPRITES.LAYER_TYPE == 35 or SPRITES.LAYER_TYPE == 36 then
				pos_lay_ex4 = ani_lay(pos_lay_ex4, pos_lay_ex3, pos_lay_limite, reve, lay_vel, pos_lay_limite)
				pos_lay_2 = ani_lay(pos_lay_2, pos_lay_ex4, pos_lay_limite, reve, lay_vel, pos_lay_limite)
			else
				pos_lay_2 = ani_lay(pos_lay_2, pos_lay_ex3, pos_lay_limite, reve, lay_vel, pos_lay_limite)
			end
			pos_lay_1 = ani_lay(pos_lay_1, pos_lay_2, pos_lay_limite, reve, lay_vel, pos_lay_limite)
			if pos_lay_1 == pos_lay_2 and reve == true then
				pos_lay_1, pos_lay_2, pos_lay_ex3, pos_lay_ex4 = pos_lay_ex3-pos_lay_limite, pos_lay_ex3-pos_lay_limite, 0, pos_lay_ex3-pos_lay_limite
			elseif pos_lay_1 == pos_lay_2 and reve == false then
				pos_lay_1, pos_lay_2, pos_lay_ex3, pos_lay_ex4 = pos_lay_limite, pos_lay_limite, 0, pos_lay_limite
			end

		-- Animación de entrecruzar la pantalla completa. -------------------------------
		elseif (SPRITES.LAYER_TYPE == 18 or SPRITES.LAYER_TYPE == 37) then
			if pos_lay_1 >= pos_lay_limite+lay_vel then
				pos_lay_1, pos_lay_2 = -pos_lay_limite, pos_lay_limite
			else
				pos_lay_1, pos_lay_2 = pos_lay_1+lay_vel, pos_lay_2-lay_vel
			end

		-- Animación de entrecruzar media pantalla. -------------------------------------
		elseif (SPRITES.LAYER_TYPE == 19 or SPRITES.LAYER_TYPE == 38) then
			if ((pos_lay_1 >= pos_lay_limite/6 and SPRITES.ALTERNATE == false) or (pos_lay_1 <= -(pos_lay_limite/6) and SPRITES.ALTERNATE == true)) then
				if SPRITES.ALTERNATE == true then
					SPRITES.ALTERNATE = false
				else
					SPRITES.ALTERNATE = true
				end
			else
				if SPRITES.ALTERNATE == false then
					pos_lay_1, pos_lay_2 = pos_lay_1+lay_vel, pos_lay_2-lay_vel
				elseif SPRITES.ALTERNATE == true then
					pos_lay_1, pos_lay_2 = pos_lay_1-lay_vel, pos_lay_2+lay_vel
				end
			end

		-- Animación de remolino. -------------------------------------------------------
		elseif (SPRITES.LAYER_TYPE == 39 or SPRITES.LAYER_TYPE == 40) then
			local veloc_c, hori, veti, radio = "0.00".. lay_vel, false, false, (20*SPRITES.LAYER_MULTI)
			local pos_x1, pos_x2, pos_y = (CONTROL.ANCHO/2), (CONTROL.ANCHO/2), 0
			if SPRITES.LAYER_SPEED >= 1 and SPRITES.LAYER_SPEED <= 9 then
				veloc_c, hori, veti = "0.00".. SPRITES.LAYER_SPEED, false, false
			elseif SPRITES.LAYER_SPEED >= 10 and SPRITES.LAYER_SPEED <= 18 then
				veloc_c, hori, veti = "0.0".. SPRITES.LAYER_SPEED-9, false, false
			elseif SPRITES.LAYER_SPEED >= 19 and SPRITES.LAYER_SPEED <= 27 then
				veloc_c, hori, veti = "0.1".. SPRITES.LAYER_SPEED-18, false, false
			elseif SPRITES.LAYER_SPEED >= 28 and SPRITES.LAYER_SPEED <= 36 then
				veloc_c, hori, veti, pos_x1, pos_x2 = "0.0".. SPRITES.LAYER_SPEED-27, true, false, 0-radio, 0+radio
			elseif SPRITES.LAYER_SPEED >= 37 and SPRITES.LAYER_SPEED <= 45 then
				veloc_c, hori, veti, pos_x1, pos_x2 = "0.".. SPRITES.LAYER_SPEED-36, true, false, 0-radio, 0+radio
			elseif SPRITES.LAYER_SPEED >= 46 and SPRITES.LAYER_SPEED <= 54 then
				veloc_c, hori, veti, pos_x1, pos_x2 = "0.0".. SPRITES.LAYER_SPEED-45, false, true, 0, 0
			elseif SPRITES.LAYER_SPEED >= 55 and SPRITES.LAYER_SPEED <= 62 then
				veloc_c, hori, veti, pos_x1, pos_x2 = "0.".. SPRITES.LAYER_SPEED-54, false, true, 0, 0
			end
			if SPRITES.LAYER_TYPE == 39 then
				if SPRITES.ANG[1]+tonumber(veloc_c) <= 6.27 then
					SPRITES.ANG[1] = SPRITES.ANG[1]+tonumber(veloc_c)
					SPRITES.ANG[2] = SPRITES.ANG[2]+tonumber(veloc_c)
				else
					SPRITES.ANG[1] = 0.00
					SPRITES.ANG[2] = 3.14
				end
			elseif SPRITES.LAYER_TYPE == 40 then
				if SPRITES.ANG[1]-tonumber(veloc_c) >= 0.00 then
					SPRITES.ANG[1] = SPRITES.ANG[1]-tonumber(veloc_c)
					SPRITES.ANG[2] = SPRITES.ANG[2]-tonumber(veloc_c)
				else
					SPRITES.ANG[1] = 6.27
					SPRITES.ANG[2] = 3.14
				end
			end
			if veti == false and (hori == true or hori == false) then
				pos_lay_1 = pos_x1+radio*math.cos(SPRITES.ANG[1])
				pos_lay_2 = pos_x2+radio*math.cos(SPRITES.ANG[2])
			end
			if hori == false and (veti == true or veti == false) then
				pos_lay_ex1 = pos_y+radio*math.sin(SPRITES.ANG[1])
				pos_lay_ex2 = pos_y+radio*math.sin(SPRITES.ANG[2])
			end
			if hori == false and veti == false then
				pos_lay_1 = pos_lay_1-CONTROL.ANCHO/2
				pos_lay_2 = pos_lay_2-CONTROL.ANCHO/2
			end

		-- Animación de zoom. -----------------------------------------------------------
		elseif SPRITES.LAYER_TYPE >= 41 and SPRITES.LAYER_TYPE <= 58 then
			local z_max = 50*SPRITES.LAYER_MULTI
			if SPRITES.ZOOM[1]+regulador <= z_max and SPRITES.ZOOM[2] == false then
				SPRITES.ZOOM[1] = SPRITES.ZOOM[1]+regulador
			elseif SPRITES.ZOOM[2] == false then
				SPRITES.ZOOM[1] = SPRITES.ZOOM[1]+regulador
				SPRITES.ZOOM[2] = true
			elseif SPRITES.ZOOM[1]-regulador >= regulador and SPRITES.ZOOM[2] == true then
				SPRITES.ZOOM[1] = SPRITES.ZOOM[1]-regulador
			elseif SPRITES.ZOOM[2] == true then
				SPRITES.ZOOM[1] = SPRITES.ZOOM[1]-regulador
				SPRITES.ZOOM[2] = false
			end
			local z_tipo, z_act, z_fix = 1, false, -(SPRITES.ZOOM[1]/2)
			if SPRITES.LAYER_TYPE >= 41 and SPRITES.LAYER_TYPE <= 49 then
				z_tipo, z_act = SPRITES.LAYER_TYPE-40, false
			elseif SPRITES.LAYER_TYPE >= 50 and SPRITES.LAYER_TYPE <= 58 then
				z_tipo, z_act = SPRITES.LAYER_TYPE-49, true
			end
			local z_lay_1 = {0, 1, 0, 1, 1, 1, 0, 1, 1}
			local z_lay_2 = {0, 1, 1, 0, 0, 1, 1, 1, 1}
			local z_lay_3 = {1, 0, 1, 0, 1, 1, 1, 0, 1}
			local z_lay_4 = {1, 0, 0, 1, 1, 0, 1, 1, 1}
			if z_lay_1[z_tipo] == 1 then
				if (SPRITES.LAYER_TYPE == 53 or SPRITES.LAYER_TYPE == 57 or SPRITES.LAYER_TYPE == 58) and z_act == true then
					pos_lay_ex3, pos_lay_3, x_fix1, y_fix1 = z_fix/2, z_fix/2, esc_x+SPRITES.ZOOM[1]/2, esc_y+SPRITES.ZOOM[1]/2
				else
					pos_lay_ex3, pos_lay_3, x_fix1, y_fix1 = z_fix, z_fix, esc_x+SPRITES.ZOOM[1], esc_y+SPRITES.ZOOM[1]
				end
			end
			if z_lay_2[z_tipo] == 1 then
				if (SPRITES.LAYER_TYPE == 51 or SPRITES.LAYER_TYPE == 55) and z_act == true then
					pos_lay_ex4, pos_lay_4, x_fix2, y_fix2 = z_fix/2, z_fix/2, esc_x+SPRITES.ZOOM[1]/2, esc_y+SPRITES.ZOOM[1]/2
				else
					pos_lay_ex4, pos_lay_4, x_fix2, y_fix2 = z_fix, z_fix, esc_x+SPRITES.ZOOM[1], esc_y+SPRITES.ZOOM[1]
				end
			end
			if z_lay_3[z_tipo] == 1 then
				if (SPRITES.LAYER_TYPE == 52 or SPRITES.LAYER_TYPE == 56 or SPRITES.LAYER_TYPE == 58) and z_act == true then
					pos_lay_2, pos_lay_ex2, x_fix3, y_fix3 = z_fix/2, z_fix/2, esc_x+SPRITES.ZOOM[1]/2, esc_y+SPRITES.ZOOM[1]/2
				else
					pos_lay_2, pos_lay_ex2, x_fix3, y_fix3 = z_fix, z_fix, esc_x+SPRITES.ZOOM[1], esc_y+SPRITES.ZOOM[1]
				end
			end
			if z_lay_4[z_tipo] == 1 then
				if (SPRITES.LAYER_TYPE == 50 or SPRITES.LAYER_TYPE == 54 or SPRITES.LAYER_TYPE == 58) and z_act == true then
					pos_lay_1, pos_lay_ex1, x_fix4, y_fix4 = z_fix/2, z_fix/2, esc_x+SPRITES.ZOOM[1]/2, esc_y+SPRITES.ZOOM[1]/2
				else
					pos_lay_1, pos_lay_ex1, x_fix4, y_fix4 = z_fix, z_fix, esc_x+SPRITES.ZOOM[1], esc_y+SPRITES.ZOOM[1]
				end
			end
		end

		-- Aplicar las posiciones en las animaciones. -----------------------------------
		if (SPRITES.LAYER_TYPE >= 1 and SPRITES.LAYER_TYPE <= 19) or SPRITES.LAYER_TYPE == 39 or SPRITES.LAYER_TYPE == 40 then
			SPRITES.LAYER_X_1, SPRITES.LAYER_X_2, SPRITES.LAYER_X_3, SPRITES.LAYER_X_4 = pos_lay_1, pos_lay_2, pos_lay_ex3, pos_lay_ex4
			SPRITES.LAYER_Y_1, SPRITES.LAYER_Y_2 = pos_lay_ex1, pos_lay_ex2
			SPRITES.BACK_X, SPRITES.BACK_Y = 0, 0
		elseif SPRITES.LAYER_TYPE >= 20 and SPRITES.LAYER_TYPE <= 38 then
			SPRITES.LAYER_Y_1, SPRITES.LAYER_Y_2, SPRITES.LAYER_Y_3, SPRITES.LAYER_Y_4 = pos_lay_1, pos_lay_2, pos_lay_ex3, pos_lay_ex4
			SPRITES.LAYER_X_1, SPRITES.LAYER_X_2 = pos_lay_ex1, pos_lay_ex2
			SPRITES.BACK_X, SPRITES.BACK_Y = 0, 0
		elseif SPRITES.LAYER_TYPE >= 41 and SPRITES.LAYER_TYPE <= 58 then
			SPRITES.LAYER_X_1, SPRITES.LAYER_X_2, SPRITES.LAYER_X_3, SPRITES.BACK_X = pos_lay_1, pos_lay_2, pos_lay_ex3, pos_lay_ex4
			SPRITES.LAYER_Y_1, SPRITES.LAYER_Y_2, SPRITES.LAYER_Y_3, SPRITES.BACK_Y = pos_lay_ex1, pos_lay_ex2, pos_lay_3, pos_lay_4
		elseif SPRITES.LAYER_TYPE == 59 or SPRITES.LAYER_TYPE == 60 then
			SPRITES.LAYER_X_1, SPRITES.LAYER_X_2, SPRITES.BACK_X, SPRITES.LAYER_X_4 = pos_lay_ex3, pos_lay_ex4, pos_lay_1, pos_lay_2
		elseif SPRITES.LAYER_TYPE == 61 or SPRITES.LAYER_TYPE == 62 then
			SPRITES.LAYER_Y_1, SPRITES.LAYER_Y_2, SPRITES.BACK_Y, SPRITES.LAYER_Y_4 = pos_lay_ex3, pos_lay_ex4, pos_lay_1, pos_lay_2
		elseif SPRITES.LAYER_TYPE == 0 then
			SPRITES.LAYER_Y_1, SPRITES.LAYER_Y_2, SPRITES.LAYER_Y_3, SPRITES.LAYER_Y_4 = 0, 0, 0, 0
			SPRITES.LAYER_X_1, SPRITES.LAYER_X_2, SPRITES.LAYER_X_3, SPRITES.LAYER_X_4 = 0, 0, 0, 0
			SPRITES.BACK_X, SPRITES.BACK_Y = 0, 0
		end

		-- Aplicar las rotaciones en las animaciones. -----------------------------------
		if SPRITES.SPIN_TYPE >= 1 and SPRITES.SPIN_TYPE <= 30 then
			-- Determinar velocidad de giro. --------------------------------------------
			local v_r_final, ro_l_act, limi_r1, limi_r2, v_r_final, t_rota = 0.01, false, 0.52, 5.76, "0.00".. SPRITES.SPIN_SPEED, SPRITES.SPIN_TYPE
			if SPRITES.SPIN_SPEED <= 9 then
				v_r_final = "0.00".. SPRITES.SPIN_SPEED
			elseif SPRITES.SPIN_SPEED >= 10 and SPRITES.SPIN_SPEED <= 18 then
				v_r_final = "0.0".. SPRITES.SPIN_SPEED-9
			elseif SPRITES.SPIN_SPEED >= 19 and SPRITES.SPIN_SPEED <= 27 then
				v_r_final = "0.1".. SPRITES.SPIN_SPEED-18
			elseif SPRITES.SPIN_SPEED >= 28 and SPRITES.SPIN_SPEED <= 36 then
				v_r_final, ro_l_act, limi_r1, limi_r2 = "0.0".. SPRITES.SPIN_SPEED-27, true, 0.52, 5.76
			elseif SPRITES.SPIN_SPEED >= 37 and SPRITES.SPIN_SPEED <= 45 then
				v_r_final, ro_l_act, limi_r1, limi_r2 = "0.0".. SPRITES.SPIN_SPEED-36, true, 3.05, 0.09
			elseif SPRITES.SPIN_SPEED >= 46 and SPRITES.SPIN_SPEED <= 54 then
				v_r_final, ro_l_act, limi_r1, limi_r2 = "0.0".. SPRITES.SPIN_SPEED-45, true, 1.57, 4.71
			elseif SPRITES.SPIN_SPEED >= 55 and SPRITES.SPIN_SPEED <= 62 then
				v_r_final, ro_l_act, limi_r1, limi_r2 = "0.0".. SPRITES.SPIN_SPEED-54, true, 6.18, 0.09
			end
			if SPRITES.SPIN_TYPE <= 15 then
				if ro_l_act == false then
					SPRITES.ALTERNATE_R = false
				end
			elseif SPRITES.SPIN_TYPE >= 16 and SPRITES.SPIN_TYPE <= 30 then
				if ro_l_act == false then
					SPRITES.ALTERNATE_R = true
				end
				t_rota = t_rota-15
			end

			-- Realizar las rotaciones de capas. ----------------------------------------
			if SPRITES.ALTERNATE_R == false and SPRITES.SPIN+tonumber(v_r_final) <= 6.27 then
				SPRITES.SPIN = SPRITES.SPIN+tonumber(v_r_final)
				if (SPRITES.SPIN >= limi_r1 and SPRITES.SPIN <= (limi_r1+0.9)) and ro_l_act == true then
					SPRITES.ALTERNATE_R, SPRITES.SPIN = true, (limi_r1-0.01)
				end
			elseif SPRITES.ALTERNATE_R == false then
				SPRITES.SPIN = 0.00
			end
			if SPRITES.ALTERNATE_R == true and SPRITES.SPIN-tonumber(v_r_final) >= 0.00 then
				SPRITES.SPIN = SPRITES.SPIN-tonumber(v_r_final)
				if (SPRITES.SPIN <= limi_r2 and SPRITES.SPIN >= (limi_r2-0.9)) and ro_l_act == true then
					SPRITES.ALTERNATE_R, SPRITES.SPIN = false, (limi_r2+0.01)
				end
			elseif SPRITES.ALTERNATE_R == true then
				SPRITES.SPIN = 6.27
			end
			local r_lay_1 = {1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1}
			local r_lay_2 = {0, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1}
			local r_lay_3 = {0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1}
			local r_lay_4 = {0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1}
			if r_lay_1[t_rota] == 1 then cuadro_1[5] = SPRITES.SPIN end
			if r_lay_2[t_rota] == 1 then cuadro_2[5] = SPRITES.SPIN end
			if r_lay_3[t_rota] == 1 then cuadro_3[5] = SPRITES.SPIN end
			if r_lay_4[t_rota] == 1 then cuadro_4[5] = SPRITES.SPIN end
		end

		-- Aplicar las transparencias en las animaciones. -------------------------------
		if SPRITES.TRAN_TYPE >= 1 and SPRITES.TRAN_TYPE <= 20 then
			-- Cambiar los niveles de transparencia y alternar entre las capas. ---------
			local function tras_apli(mini, maxi, n_capa, n_vel_t, alterna)
				if SPRITES.TRAN_ALT[n_capa] == true then
					if SPRITES.TRAN[n_capa] <= maxi-n_vel_t then
						SPRITES.TRAN[n_capa] = SPRITES.TRAN[n_capa]+n_vel_t;
					else
						SPRITES.TRAN[n_capa], SPRITES.TRAN_ALT[n_capa] = maxi, false
					end
				elseif SPRITES.TRAN_ALT[n_capa] == false and SPRITES.TRAN[n_capa] <= maxi then
					if SPRITES.TRAN[n_capa] >= mini+n_vel_t then
						SPRITES.TRAN[n_capa] = SPRITES.TRAN[n_capa]-n_vel_t
					else
						SPRITES.TRAN[n_capa], SPRITES.TRAN_ALT[n_capa] = mini, true
					end
				elseif SPRITES.TRAN_ALT[n_capa] == false and SPRITES.TRAN[n_capa] > maxi then
					SPRITES.TRAN[n_capa] = maxi
				end
				if alterna == true and SPRITES.ACTIVATE_ALTER_T == true then
					if SPRITES.TRAN_TYPE >= 16 and SPRITES.TRAN_TYPE <= 20 then
						if SPRITES.TRAN_TYPE == 16 or SPRITES.TRAN_TYPE == 17 or SPRITES.TRAN_TYPE == 20 then
							SPRITES.TRAN_ALT[1], SPRITES.TRAN[1] = true, mini
						end
						if SPRITES.TRAN_TYPE == 16 or SPRITES.TRAN_TYPE == 20 or SPRITES.TRAN_TYPE == 17 or SPRITES.TRAN_TYPE == 19 then
							SPRITES.TRAN_ALT[3], SPRITES.TRAN[3] = false, maxi
						end
						if SPRITES.TRAN_TYPE == 16 or SPRITES.TRAN_TYPE == 20 or SPRITES.TRAN_TYPE == 18 or SPRITES.TRAN_TYPE == 19 then
							if SPRITES.TRAN_TYPE == 18 then
								SPRITES.TRAN_ALT[4], SPRITES.TRAN[4] = true, mini
							else
								SPRITES.TRAN_ALT[4], SPRITES.TRAN[4] = false, maxi
							end
						end
						if SPRITES.TRAN_TYPE == 18 or SPRITES.TRAN_TYPE == 19 or SPRITES.TRAN_TYPE == 20 then
							if SPRITES.TRAN_TYPE == 20 or SPRITES.TRAN_TYPE == 19 then
								SPRITES.TRAN_ALT[2], SPRITES.TRAN[2] = true, mini
							else
								SPRITES.TRAN_ALT[2], SPRITES.TRAN[2] = false, maxi
							end
						end
					else
						SPRITES.TRAN_ALT[1], SPRITES.TRAN[1] = true, mini
						SPRITES.TRAN_ALT[2], SPRITES.TRAN[2] = false, maxi
						SPRITES.TRAN_ALT[3], SPRITES.TRAN[3] = true, mini
						SPRITES.TRAN_ALT[4], SPRITES.TRAN[4] = false, maxi
					end
					SPRITES.ACTIVATE_ALTER_T = false
				end
			end

			-- Determinar el tipo de transparencia. -------------------------------------
			local niv_tras, velo_tras, t_capas_act, act_tras_min = 8, 1, false, false
			if SPRITES.TRAN_LEVEL <= 8 then
				niv_tras, SPRITES.ALTERNATE_T = SPRITES.TRAN_LEVEL, false
			elseif SPRITES.TRAN_LEVEL >= 9 and SPRITES.TRAN_LEVEL <= 16 then
				niv_tras, SPRITES.ALTERNATE_T = SPRITES.TRAN_LEVEL-8, true
			elseif SPRITES.TRAN_LEVEL >= 17 and SPRITES.TRAN_LEVEL <= 24 then
				niv_tras, SPRITES.ALTERNATE_T, t_capas_act, act_tras_min = SPRITES.TRAN_LEVEL-16, true, false, true
			elseif SPRITES.TRAN_LEVEL >= 25 and SPRITES.TRAN_LEVEL <= 32 then
				niv_tras, SPRITES.ALTERNATE_T, t_capas_act, act_tras_min = SPRITES.TRAN_LEVEL-24, true, true, false
			elseif SPRITES.TRAN_LEVEL >= 33 and SPRITES.TRAN_LEVEL <= 40 then
				niv_tras, SPRITES.ALTERNATE_T, t_capas_act, act_tras_min = SPRITES.TRAN_LEVEL-32, true, true, true
			end

			-- Determinar la velocidad y rangos de transparencia. -----------------------
			if SPRITES.TRAN_SPEED <= 16 then
				velo_tras = SPRITES.TRAN_SPEED
			else
				velo_tras = 1
			end
			local max_tras_l, min_tras_l = 128, 0
			if niv_tras <= 7 then
				max_tras_l = (16*niv_tras)
			end
			if act_tras_min == true then
				min_tras_l = max_tras_l//2
			end
			local trasp_lay_1 = {1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1}
			local trasp_lay_2 = {0, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1}
			local trasp_lay_3 = {0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1}
			local trasp_lay_4 = {0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1}
			if t_capas_act == false and SPRITES.ALTERNATE_T == false then
				SPRITES.TRAN[1], SPRITES.TRAN[2], SPRITES.TRAN[3], SPRITES.TRAN[4] = max_tras_l, max_tras_l, max_tras_l, max_tras_l
			elseif SPRITES.ALTERNATE_T == true and SPRITES.FONDO_ANI_FRAME == frame_speed_f then
				if trasp_lay_1[SPRITES.TRAN_TYPE] == 1 then tras_apli(min_tras_l, max_tras_l, 1, velo_tras, t_capas_act) end
				if trasp_lay_2[SPRITES.TRAN_TYPE] == 1 then tras_apli(min_tras_l, max_tras_l, 2, velo_tras, t_capas_act) end
				if trasp_lay_3[SPRITES.TRAN_TYPE] == 1 then tras_apli(min_tras_l, max_tras_l, 3, velo_tras, t_capas_act) end
				if trasp_lay_4[SPRITES.TRAN_TYPE] == 1 then tras_apli(min_tras_l, max_tras_l, 4, velo_tras, t_capas_act) end
			end
			if trasp_lay_1[SPRITES.TRAN_TYPE] == 1 then
				cuadro_1[6] = Color.new(list_rgb[1], list_rgb[2], list_rgb[3], SPRITES.TRAN[1])
			end
			if trasp_lay_2[SPRITES.TRAN_TYPE] == 1 then
				cuadro_2[6] = Color.new(list_rgb[1], list_rgb[2], list_rgb[3], SPRITES.TRAN[2])
			end
			if trasp_lay_3[SPRITES.TRAN_TYPE] == 1 then
				cuadro_3[6] = Color.new(list_rgb[1], list_rgb[2], list_rgb[3], SPRITES.TRAN[3])
			end
			if trasp_lay_4[SPRITES.TRAN_TYPE] == 1 then
				cuadro_4[6] = Color.new(list_rgb[1], list_rgb[2], list_rgb[3], SPRITES.TRAN[4])
			end
		end

		-- Dibujar las animaciones en pantalla (capa 2). --------------------------------
		Graphics.drawImageExtended(img, 0+(x_fix2/2)+SPRITES.BACK_X, 0+(y_fix2/2)+SPRITES.BACK_Y, cuadro_2[1], cuadro_2[3], cuadro_2[2], cuadro_2[4], x_fix2, y_fix2, cuadro_2[5], cuadro_2[6])
		if SPRITES.LAYER_TYPE >= 59 and SPRITES.LAYER_TYPE <= 62 then
			Graphics.drawImageExtended(img, 0+(x_fix2/2)+SPRITES.LAYER_X_4, 0+(y_fix2/2)+SPRITES.LAYER_Y_4, cuadro_2[1], cuadro_2[3], cuadro_2[2], cuadro_2[4], x_fix2, y_fix2, cuadro_2[5], cuadro_2[6])
		end

		-- Dibujar las animaciones en pantalla (capa 3). --------------------------------
		Graphics.drawImageExtended(img, 0+(x_fix3/2)+SPRITES.LAYER_X_2, 0+(y_fix3/2)+SPRITES.LAYER_Y_2, cuadro_3[1], cuadro_3[3], cuadro_3[2], cuadro_3[4], x_fix3, y_fix3, cuadro_3[5], cuadro_3[6])
		if SPRITES.LAYER_TYPE == 8 or SPRITES.LAYER_TYPE == 9 or SPRITES.LAYER_TYPE == 27 or SPRITES.LAYER_TYPE == 28 then
			Graphics.drawImageExtended(img, 0+(x_fix3/2)+SPRITES.LAYER_X_1, 0+(y_fix3/2)+SPRITES.LAYER_Y_1, cuadro_3[1], cuadro_3[3], cuadro_3[2], cuadro_3[4], x_fix3, y_fix3, cuadro_3[5], cuadro_3[6])
		end

		-- Dibujar las animaciones en pantalla (capa 4). --------------------------------
		Graphics.drawImageExtended(img, 0+(x_fix4/2)+SPRITES.LAYER_X_1, 0+(y_fix4/2)+SPRITES.LAYER_Y_1, cuadro_4[1], cuadro_4[3], cuadro_4[2], cuadro_4[4], x_fix4, y_fix4, cuadro_4[5], cuadro_4[6])
		if SPRITES.LAYER_TYPE == 8 or SPRITES.LAYER_TYPE == 9 or SPRITES.LAYER_TYPE == 27 or SPRITES.LAYER_TYPE == 28 then
			Graphics.drawImageExtended(img, 0+(x_fix4/2)+SPRITES.LAYER_X_2, 0+(y_fix4/2)+SPRITES.LAYER_Y_2, cuadro_4[1], cuadro_4[3], cuadro_4[2], cuadro_4[4], x_fix4, y_fix4, cuadro_4[5], cuadro_4[6])
		end

		-- Dibujar las animaciones en pantalla (capa 2 junto a capa 1). -----------------
		if SPRITES.LAYER_TYPE == 10 or SPRITES.LAYER_TYPE == 11 or SPRITES.LAYER_TYPE == 29 or SPRITES.LAYER_TYPE == 30 or (SPRITES.LAYER_TYPE >= 14 and SPRITES.LAYER_TYPE <= 17) or (SPRITES.LAYER_TYPE >= 33 and SPRITES.LAYER_TYPE <= 36) then
			Graphics.drawImageExtended(img, 0+(x_fix2/2)+SPRITES.LAYER_X_4, 0+(y_fix2/2)+SPRITES.LAYER_Y_4, cuadro_2[1], cuadro_2[3], cuadro_2[2], cuadro_2[4], x_fix2, y_fix2, cuadro_2[5], cuadro_2[6])
		end

		-- Dibujar las animaciones en pantalla (capa 1). --------------------------------
		Graphics.drawImageExtended(img, 0+(x_fix1/2)+SPRITES.LAYER_X_3, 0+(y_fix1/2)+SPRITES.LAYER_Y_3, cuadro_1[1], cuadro_1[3], cuadro_1[2], cuadro_1[4], x_fix1, y_fix1, cuadro_1[5], cuadro_1[6])
	end
end
