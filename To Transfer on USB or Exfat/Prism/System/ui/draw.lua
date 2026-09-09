-- Prism PS2 Launcher - ui/draw.lua
-- Drawing primitives: frame, backgrounds, input capture, artwork, text helpers.
-- Split from the original funciones.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Functions are globals; this file only defines them. Loaded by System/system.lua.

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
	RGB(OPCIONES.RGB_ON, OPCIONES.FONDO_RGB_FIJO_ON, CAMBIOS_EMUS.TRAS)
	Screen.clear(CAMBIOS_EMUS.COLOR_EMU_BACK)
	if OPCIONES.FONDO_RGB_ON == 1 and (OPCIONES.FONDO_RGB_FIJO_ON == 0 or (OPCIONES.FONDO_RGB_FIJO_ON == 1 and CAMBIOS_EMUS.TRAS == 0)) then
		if SPRITES.FONDO_ANI == true then
			fondo_sprites(LISTAS.FONDO, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F, 0.00, true, CAMBIOS_EMUS.COLOR_EMU_BACK)
		else
			Graphics.drawScaleImage(LISTAS.FONDO, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F, CAMBIOS_EMUS.COLOR_EMU_BACK)
		end
	elseif OPCIONES.FONDO_RGB_ON == 1 and OPCIONES.FONDO_RGB_FIJO_ON == 1 then
		if SPRITES.FONDO_ANI == true then
			fondo_sprites(LISTAS.FONDO, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F, 0.00, false, CAMBIOS_EMUS.COLOR_EMU_BACK)
		else
			Graphics.drawScaleImage(LISTAS.FONDO, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F)
		end
		Graphics.drawRect(0, 0, CONTROL.ANCHO, CONTROL.ALTO_F, CAMBIOS_EMUS.COLOR_EMU_BACK)
	else
		if SPRITES.FONDO_ANI == true then
			fondo_sprites(LISTAS.FONDO, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F, 0.00, false, CAMBIOS_EMUS.COLOR_EMU_BACK)
		else
			Graphics.drawScaleImage(LISTAS.FONDO, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F)
		end
	end
end

--- Controla los tiempos de captura y pausa para los controles. -------------------------
function capturar(limite)
	if CONTROL.JOYSTICK_ON == false or limite >= CONTROL.FPS//3 then
		PAD = Pads.get(0)
		Left_X, Left_Y = Pads.getLeftStick(0)
		JOYSTICK_LIMITE = 0
		CONTROL.JOYSTICK_ON = false
		if CONTROL.ACT_FONTABC == true then
			CONTROL.ACT_FONTABC = false
		end
		Pads.rumble(0, 0, 0)
		OPCIONES.VIBRATION = false
		OPCIONES.VIBRATION_MODE = nil
	end
	if CONTROL.JOYSTICK_ON == true then
		PAD = 0
		Left_X, Left_Y = 1, 1
		JOYSTICK_LIMITE = JOYSTICK_LIMITE+1
		if OPCIONES.VIBRATION_ON == 1 and OPCIONES.VIBRATION == true and limite <= -4 then
			local shake_left, shake_rigth = 80, 80
			if OPCIONES.VIBRATION_MODE == true then
				shake_left, shake_rigth = 90, 80
			elseif OPCIONES.VIBRATION_MODE == false then
				shake_left, shake_rigth = 80, 90
			end
			Pads.rumble(0, shake_left, shake_rigth)
		else
			Pads.rumble(0, 0, 0)
		end
	end
end

--- La palanca esta REALMENTE movida. ---------------------------------------------------
--- En varios sitios se pregunta "Left_Y ~= 1" para saber si el usuario ha tocado la
--- palanca. Ese 1 viene de capturar(), que hace "Left_X, Left_Y = 1, 1" cuando la
--- lectura ya se ha consumido; es un centinela, no la posicion de reposo.
---
--- La posicion de reposo es 0. Todo el programa lo da por hecho -- compara siempre
--- contra -90 y 90 --, asi que "~= 1" es CIERTO con la palanca quieta, y es cierto en
--- todos los fotogramas.
---
--- Donde eso solo elegia la velocidad de repeticion no se notaba. Donde abre una rama
--- de un "elseif", se lleva por delante todo lo que viene detras: en el submenu de
--- elementos del editor de temas, la rama de "moverse" se disparaba sola en cada
--- fotograma -- de ahi el sonido de seleccion sin fin -- y CRUZ y R1 no llegaban nunca
--- a sus ramas, de ahi que no se pudiera encender ni apagar nada.
function stick_moved(valor)
	if valor == nil then return false end
	return valor <= -90 or valor >= 90
end

--- Cambia los tiempos de captura de los controles, de acuerdo a los FPS. ---------------
function control_FPS(vel)
	CONTROL.JOYSTICK_ON = true
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

--- Controlar la reproducción de sonidos y vibración al realizar movimientos. -----------
function repro_sfx(sonido, canal, vibrar, lado_vibrar)
	if OPCIONES.SOUND_ON == 1 and sonido ~= nil then
		-- La voz sale del sonido, no del numero que se pasa aqui: los 166 sitios que
		-- llaman a esta funcion pasan "1", y una sola voz no puede reproducir dos
		-- sonidos a la vez. Ver SFX_CHANNELS en system.lua.
		Sound.playADPCM(sfx_voice(sonido, canal), sonido)
	end
	OPCIONES.VIBRATION = vibrar
	OPCIONES.VIBRATION_MODE = lado_vibrar
end

--- Controla el zoom sobre el arte. -----------------------------------------------------
function zoom(multiplicador, ratio_x, ratio_y)
	local Right_X, Right_Y = Pads.getRightStick(0)
	if Right_Y <= -1 then
		Right_Y = -Right_Y
	elseif Right_Y == 1 then
		Right_Y = 0
	end
	if Right_X == 1 then
		Right_X = 0
	end
	local Right_XY = (Right_Y*multiplicador)//2
	if ratio_y ~= 0 then
		Right_XY = (Right_XY*ratio_x)//ratio_y
	end
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
	local sistemas_nombre = {"Sega Megadrive"; "Sega Master System"; "Sega Game Gear"; "Nintendo Famicom"; "Nintendo Game Boy";
	"Nintendo Game Boy Color"; "Nintendo Game Boy Advance"; "Atari 2600"; "Atari Lynx"; "Sega SG-1000"; "Neo Geo Pocket";
	"Nintendo Super Famicom"; "APPS"; "PlayStation"; "PlayStation 2";};
	if LISTAS.MOSTRAR == 1 and (LISTAS.IDENTIDAD >= 1 and LISTAS.IDENTIDAD <= 15) then
		if OPCIONES.APPS_MENU_FULL_PATH == 1 and LISTAS.IDENTIDAD == 12 then
			nombre = salida_texto_dir(string.sub(LISTAS.ROMS[LISTAS.INDICE], 1, -CONTROL.EXTENSION), true)
			if (CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_FLOW == true then
				nombre2 = salida_texto_dir(string.sub(LISTAS.ROMS[LISTAS.INDICE2], 1, -CONTROL.EXTENSION), true)
				nombre3 = salida_texto_dir(string.sub(LISTAS.ROMS[LISTAS.INDICE3], 1, -CONTROL.EXTENSION), true)
			end
		end

		-- Ubicaciones para covers, screenshot y covers flow. ---------------------------
		if CONTROL.CUSTOM_ART1 == true then
			LISTAS.COVER_DIR = RUTA_MEDIA("cover", LISTAS.IDENTIDAD, sistemas_nombre[LISTAS.IDENTIDAD], LISTAS.ROMS[LISTAS.INDICE], nombre)
			LISTAS.SCREENSHOT_DIR = RUTA_MEDIA("screenshot", LISTAS.IDENTIDAD, sistemas_nombre[LISTAS.IDENTIDAD], LISTAS.ROMS[LISTAS.INDICE], nombre)
		end
		if (CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_FLOW == true then
			LISTAS.COVER_DIR2 = RUTA_MEDIA("cover", LISTAS.IDENTIDAD, sistemas_nombre[LISTAS.IDENTIDAD], LISTAS.ROMS[LISTAS.INDICE2], nombre2)
			LISTAS.COVER_DIR3 = RUTA_MEDIA("cover", LISTAS.IDENTIDAD, sistemas_nombre[LISTAS.IDENTIDAD], LISTAS.ROMS[LISTAS.INDICE3], nombre3)
		end

		-- Ubicaciones para la carpeta "ART". -------------------------------------------
		if LISTAS.IDENTIDAD == 13 or LISTAS.IDENTIDAD == 14 then
			if LISTAS.IDENTIDAD == 14 and string.lower(string.sub(LISTAS.ROMS[LISTAS.INDICE], -4)) ~= ".elf" then
				nombre = "XX.".. nombre
			end
			if CONTROL.CUSTOM_ART1 == true then
				LISTAS.COVER_DIR_ALT = RUTA_ART(nombre ..".elf_COV.png")
				LISTAS.SCREENSHOT_DIR_ALT = RUTA_ART(nombre ..".elf_SCR.png")
			end
			if (CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_FLOW == true then
				if LISTAS.IDENTIDAD == 14 and string.lower(string.sub(LISTAS.ROMS[LISTAS.INDICE2], -4)) ~= ".elf" then
					nombre2 = "XX.".. nombre2
				end
				if LISTAS.IDENTIDAD == 14 and string.lower(string.sub(LISTAS.ROMS[LISTAS.INDICE3], -4)) ~= ".elf" then
					nombre3 = "XX.".. nombre3
				end
				LISTAS.COVER_DIR2_ALT = RUTA_ART(nombre2 ..".elf_COV.png")
				LISTAS.COVER_DIR3_ALT = RUTA_ART(nombre3 ..".elf_COV.png")
			end
		elseif LISTAS.IDENTIDAD == 15 then
			if CONTROL.CUSTOM_ART1 == true then
				LISTAS.COVER_DIR_ALT = RUTA_ART(string.sub(nombre, 1, 11) .."_COV.png")
				LISTAS.SCREENSHOT_DIR_ALT = RUTA_ART(string.sub(nombre, 1, 11) .."_SCR.png")
			end
			if (CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_FLOW == true then
				LISTAS.COVER_DIR2_ALT = RUTA_ART(string.sub(nombre2, 1, 11) .."_COV.png")
				LISTAS.COVER_DIR3_ALT = RUTA_ART(string.sub(nombre3, 1, 11) .."_COV.png")
			end
		end
	end

	-- Realizar la búsqueda y carga de imágenes. ----------------------------------------
	if LISTAS.MOSTRAR == LISTAS.ART_LIMITE then
		Pads.rumble(0, 0, 0)
		-- Carga de covers. -------------------------------------------------------------
		if doesFileExist(LISTAS.COVER_DIR) then
			log_art("cover  cargando", LISTAS.COVER_DIR)
			LISTAS.COVER_ART = Graphics.loadImage(LISTAS.COVER_DIR)
			log_art("cover  ok       ", LISTAS.COVER_DIR)
			LISTAS.EXISTE_COV = true
		elseif LISTAS.IDENTIDAD >= 13 and LISTAS.IDENTIDAD <= 15 and doesFileExist(LISTAS.COVER_DIR_ALT) then
			log_art("cover  cargando", LISTAS.COVER_DIR_ALT)
			LISTAS.COVER_ART = Graphics.loadImage(LISTAS.COVER_DIR_ALT)
			log_art("cover  ok       ", LISTAS.COVER_DIR_ALT)
			LISTAS.EXISTE_COV = true
		else
			LISTAS.COVER_ART = nil
			LISTAS.EXISTE_COV = false
		end

		-- Carga de screenshot. ---------------------------------------------------------
		if doesFileExist(LISTAS.SCREENSHOT_DIR) then
			log_art("screen cargando", LISTAS.SCREENSHOT_DIR)
			LISTAS.SCREENSHOT = Graphics.loadImage(LISTAS.SCREENSHOT_DIR)
			log_art("screen ok      ", LISTAS.SCREENSHOT_DIR)
			LISTAS.EXISTE_SCR = true
		elseif LISTAS.IDENTIDAD >= 13 and LISTAS.IDENTIDAD <= 15 and doesFileExist(LISTAS.SCREENSHOT_DIR_ALT) then
			log_art("screen cargando", LISTAS.SCREENSHOT_DIR_ALT)
			LISTAS.SCREENSHOT = Graphics.loadImage(LISTAS.SCREENSHOT_DIR_ALT)
			log_art("screen ok      ", LISTAS.SCREENSHOT_DIR_ALT)
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
			elseif LISTAS.IDENTIDAD >= 13 and LISTAS.IDENTIDAD <= 15 and doesFileExist(LISTAS.COVER_DIR2_ALT) then
				LISTAS.COVER_ART2 = Graphics.loadImage(LISTAS.COVER_DIR2_ALT)
				LISTAS.EXISTE_COV2 = true
			else
				LISTAS.COVER_ART2 = nil
				LISTAS.EXISTE_COV2 = false
			end
			if doesFileExist(LISTAS.COVER_DIR3) then
				LISTAS.COVER_ART3 = Graphics.loadImage(LISTAS.COVER_DIR3)
				LISTAS.EXISTE_COV3 = true
			elseif LISTAS.IDENTIDAD >= 13 and LISTAS.IDENTIDAD <= 15 and doesFileExist(LISTAS.COVER_DIR3_ALT) then
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
	-- Realizar cálculos para corregir la relación de aspecto. --------------------------
	local function fix_art_edit(tama_x, tama_y, x, y, full_art)
		local x_prin, y_prin, x_fix, y_fix, full_x_fix, full_y_fix = tama_x, tama_y, 0, 0, 570, 390
		local eiuqal, ymot = (tama_y*x)/y, (tama_x*y)/x
		if eiuqal <= tama_x then
			x_prin, y_prin, x_fix, y_fix = eiuqal, tama_y, (tama_x-eiuqal)//2, 0
		elseif ymot <= tama_y then
			x_prin, y_prin, x_fix, y_fix = tama_x, ymot, 0, (tama_y-ymot)//2
		end
		if full_art == true then
			if (390*x)/y <= 570 then
				full_x_fix, full_y_fix = (390*x)/y, 390
			elseif (570*y)/x <= 390 then
				full_x_fix, full_y_fix = 570, (570*y)/x
			end
			return x_prin, y_prin, x_fix, y_fix, full_x_fix, full_y_fix
		else
			return x_prin, y_prin, x_fix, y_fix
		end
	end

	-- Relación de aspecto para cover. --------------------------------------------------
	if CONTROL.CUSTOM_ART1 == true then
		local x = Graphics.getImageWidth(LISTAS.COVER_DEFAULT)
		local y = Graphics.getImageHeight(LISTAS.COVER_DEFAULT)
		if LISTAS.COVER_ART ~= nil and LISTAS.EXISTE_COV == true then
			x = Graphics.getImageWidth(LISTAS.COVER_ART)
			y = Graphics.getImageHeight(LISTAS.COVER_ART)
		end
		LISTAS.COV_X, LISTAS.COV_Y, LISTAS.COV_FIX, LISTAS.COV_FIX_Y, LISTAS.EX_FIX_C, LISTAS.EX_FIX_C_Y = fix_art_edit(CONTROL.IMG_X, CONTROL.IMG_Y, x, y, true)
	end

	-- Relación de aspecto para screenshot. ---------------------------------------------
	if CONTROL.CUSTOM_ART1 == true or CONTROL.CUSTOM_ART2 == true then
		local x = Graphics.getImageWidth(LISTAS.SCREENSHOT_DEFAULT)
		local y = Graphics.getImageHeight(LISTAS.SCREENSHOT_DEFAULT)
		if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true then
			x = Graphics.getImageWidth(LISTAS.SCREENSHOT)
			y = Graphics.getImageHeight(LISTAS.SCREENSHOT)
		end
		LISTAS.SCR_X, LISTAS.SCR_Y, LISTAS.SCR_FIX, LISTAS.SCR_FIX_Y, LISTAS.EX_FIX_S, LISTAS.EX_FIX_S_Y = fix_art_edit(CONTROL.IMG_X, CONTROL.IMG_Y, x, y, true)
		LISTAS.SCR_ART2_X, LISTAS.SCR_ART2_Y, LISTAS.SCR_FIX_ART2, LISTAS.SCR_FIX_Y_ART2 = fix_art_edit(CONTROL.IMG_X_2, CONTROL.IMG_Y_2, x, y, false)
	end

	-- Relación de aspecto para cover flow. ---------------------------------------------
	if (CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_FLOW == true then
		-- Relación de aspecto para cover flow 1. ---------------------------------------
		local x = Graphics.getImageWidth(LISTAS.COVER_DEFAULT)
		local y = Graphics.getImageHeight(LISTAS.COVER_DEFAULT)
		if LISTAS.COVER_ART2 ~= nil and LISTAS.EXISTE_COV2 == true then
			x = Graphics.getImageWidth(LISTAS.COVER_ART2)
			y = Graphics.getImageHeight(LISTAS.COVER_ART2)
		end
		LISTAS.COV_1_X, LISTAS.COV_1_Y, LISTAS.COV_1_FIX, LISTAS.COV_1_FIX_Y = fix_art_edit(CONTROL.FLOW_X, CONTROL.FLOW_Y, x, y, false)

		-- Relación de aspecto para cover flow 2. ---------------------------------------
		local x2 = Graphics.getImageWidth(LISTAS.COVER_DEFAULT)
		local y2 = Graphics.getImageHeight(LISTAS.COVER_DEFAULT)
		if LISTAS.COVER_ART3 ~= nil and LISTAS.EXISTE_COV3 == true then
			x2 = Graphics.getImageWidth(LISTAS.COVER_ART3)
			y2 = Graphics.getImageHeight(LISTAS.COVER_ART3)
		end
		LISTAS.COV_2_X, LISTAS.COV_2_Y, LISTAS.COV_2_FIX, LISTAS.COV_2_FIX_Y = fix_art_edit(CONTROL.FLOW_X_2, CONTROL.FLOW_Y_2, x2, y2, false)
	end
end

--- Dibuja el arte en pantalla. ---------------------------------------------------------
function dibujar_arte(img_juego, existe, img_default, pos_x, pos_y, img_ancho, img_alto, asp_x, asp_y, asp_fix_x, asp_fix_y, act_zoom)
	if img_juego ~= nil and existe == true then
		local Right_X, Right_Y, Right_XY = 0, 0, 0
		if act_zoom == true then
			Right_X, Right_Y, Right_XY = zoom(LISTAS.ART_ZOOM, asp_x, asp_y)
		end
		if CONTROL.CUSTOM_BACK == true and act_zoom ~= nil then
			Graphics.drawRect(pos_x-5-(Right_XY//2)-(Right_X//2), pos_y-5-(Right_Y//2), img_ancho+10+Right_XY, img_alto+10+Right_Y, COLOR.NEGRO_T)
		end
		Graphics.drawScaleImage(img_juego, pos_x+asp_fix_x-(Right_XY//2)-(Right_X//2), pos_y+asp_fix_y-(Right_Y//2), asp_x+Right_XY, asp_y+Right_Y)
	else
		if CONTROL.CUSTOM_BACK == true and act_zoom ~= nil then
			Graphics.drawRect(pos_x-5, pos_y-5, img_ancho+10, img_alto+10, COLOR.NEGRO_T)
		end
		if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
			local texto_m = TEXT_M_PRI[1]
			if img_ancho <= 214 and img_ancho >= 135 then texto_m = TEXT_M_PRI[13]
			elseif img_ancho <= 134 then texto_m = " " end
			Font.ftPrint(CONTROL.fontARCA, pos_x+(img_ancho//2), pos_y+(img_alto//2)-20, 8, img_ancho, img_alto, texto_m, COLOR.BLANCO)
		else
			if OPCIONES.FONDO_RGB_FIJO_ON == 1 and CAMBIOS_EMUS.TRAS ~= 0 then
				Graphics.drawScaleImage(img_default, pos_x+asp_fix_x, pos_y+asp_fix_y, asp_x, asp_y)
				if CONTROL.CUSTOM_BACK == true then
					Graphics.drawRect(pos_x, pos_y, img_ancho, img_alto, CAMBIOS_EMUS.COLOR_EMU_BACK)
				end
			else
				Graphics.drawScaleImage(img_default, pos_x+asp_fix_x, pos_y+asp_fix_y, asp_x, asp_y, CAMBIOS_EMUS.COLOR_EMU_BACK)
			end
		end
	end
end

--- Calcular sombras tras los textos. ---------------------------------------------------
function calcular_sombras(texto)
	local result = (OPCIONES.FONT_SHADOW*OPCIONES.FONT_PIXEL_X*(string.len(texto)/2)/3)
	return result
end

--- Dibujar indicadores en pantalla. ----------------------------------------------------
function dibujar_indicador(pos_x, pos_y, texto, img_boton, img_size_x, img_size_y, fix, sombra)
	local fix_x, fix_y, color = {30, 36, 27, 27, 25}, {3, 6, 0, 7, 0}, COLOR.BLANCO
	if fix >= 6 then
		fix = fix-5
		color = CAMBIOS_EMUS.COLOR_EMU
	end
	if sombra == true then
		Graphics.drawRect(pos_x, pos_y+CONTROL.Y_FIX_PAL, calcular_sombras(texto), 20, COLOR.NEGRO_T)
	end
	Graphics.drawScaleImage(img_boton, pos_x-fix_x[fix], pos_y-fix_y[fix]+CONTROL.Y_FIX_PAL, img_size_x, img_size_y)
	Font.ftPrint(CONTROL.fontARCA, pos_x+3, pos_y+1+CONTROL.Y_FIX_PAL, 0, 0, 25, texto, color)
end

--- Saltar de carácter en las listas. ---------------------------------------------------
function letter_breaks(inicial, pos, lado)
	local inicial_act = string.lower(string.sub(inicial, 1, 1))
	if (LISTAS.IDENTIDAD == 14 or LISTAS.IDENTIDAD == 15) and string.match(inicial, "%a+_%d+%.%d+%.") then
		inicial_act = string.lower(string.sub(inicial, 13, 13))
	end
	local inicio_bus, final_bus, minimo_bus = #LISTAS.ROMS, 1, 1
	if lado == false then
		inicio_bus, final_bus, minimo_bus = 1, -1, #LISTAS.ROMS
	end
	for n = pos, inicio_bus, final_bus do
		if (LISTAS.IDENTIDAD == 14 or LISTAS.IDENTIDAD == 15) and string.match(LISTAS.ROMS[n], "%a+_%d+%.%d+%.") then
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

--- Realizar movimiento de scroll en textos largos. -------------------------------------
function scroll_texto(scroll, texto, limite)
	if string.len(texto) >= limite and scroll <= (string.len(texto)-1) then
		scroll = scroll+1
		if string.byte(texto, scroll) >= 128 and scroll <= string.len(texto) then
			for proximo = scroll, string.len(texto) do
				if string.byte(texto, proximo) <= 127 then
					scroll = proximo
					reset_tiempo_espera(0)
					break
				elseif proximo == string.len(texto) then
					scroll = 1
					reset_tiempo_espera(0-CONTROL.FPS)
					break
				end
			end
		else
			reset_tiempo_espera(0)
		end
	else
		scroll = 1
		reset_tiempo_espera(0-CONTROL.FPS)
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

--- Realizar animación para la ejecución de juegos. -------------------------------------
function black_blur()
	local multi_n_vel, actual_n_vel, centrar_img_x, centrar_img_y = 3, 4, CONTROL.IMG_ANCHO, CONTROL.IMG_ALTO
	local pant_x, pant_y = (CONTROL.ANCHO//2)-(CONTROL.IMG_X//2), (CONTROL.ALTO_F//2)-(CONTROL.IMG_Y//2)
	for actual_n = 0, 128, actual_n_vel do
		CONTROL.FPS = Screen.getFPS(1)
		dibujar_fondos()
		if LISTAS.SCREENSHOT_FULL == false then
			if (centrar_img_x <= pant_x+(actual_n_vel*multi_n_vel) and centrar_img_x >= pant_x-(actual_n_vel*multi_n_vel)) then
				centrar_img_x = pant_x
			elseif not (centrar_img_x >= pant_x+(actual_n_vel*multi_n_vel) and centrar_img_x <= pant_x-(actual_n_vel*multi_n_vel)) then
				if centrar_img_x >= pant_x+(actual_n_vel*multi_n_vel) then
					centrar_img_x = centrar_img_x-(actual_n_vel*multi_n_vel)
				elseif centrar_img_x <= pant_x-(actual_n_vel*multi_n_vel) then
					centrar_img_x = centrar_img_x+(actual_n_vel*multi_n_vel)
				end
			end
			if (centrar_img_y <= pant_y+(actual_n_vel*multi_n_vel) and centrar_img_y >= pant_y-(actual_n_vel*multi_n_vel)) then
				centrar_img_y = pant_y
			elseif not (centrar_img_y >= pant_y+(actual_n_vel*multi_n_vel) and centrar_img_y <= pant_y-(actual_n_vel*multi_n_vel)) then
				if centrar_img_y >= pant_y+(actual_n_vel*multi_n_vel) then
					centrar_img_y = centrar_img_y-(actual_n_vel*multi_n_vel)
				elseif centrar_img_y <= pant_y-(actual_n_vel*multi_n_vel) then
					centrar_img_y = centrar_img_y+(actual_n_vel*multi_n_vel)
				end
			end
			local Right_XY = ((actual_n*actual_n_vel)*LISTAS.ART_ZOOM)//2
			if LISTAS.COV_Y ~= 0 then
				Right_XY = (Right_XY*LISTAS.COV_X)//LISTAS.COV_Y
			end
			local Right_Y = ((actual_n*actual_n_vel)*LISTAS.ART_ZOOM)//2
			if LISTAS.COVER_ART ~= nil and LISTAS.EXISTE_COV == true then
				Graphics.drawScaleImage(LISTAS.COVER_ART, centrar_img_x+LISTAS.COV_FIX-(Right_XY//2), centrar_img_y+LISTAS.COV_FIX_Y-(Right_Y//2), LISTAS.COV_X+Right_XY, LISTAS.COV_Y+Right_Y)
			else
				if OPCIONES.FONDO_RGB_FIJO_ON == 1 and CAMBIOS_EMUS.TRAS ~= 0 then
					Graphics.drawScaleImage(LISTAS.COVER_DEFAULT, centrar_img_x+LISTAS.COV_FIX-(Right_XY//2), centrar_img_y+LISTAS.COV_FIX_Y-(Right_Y//2), LISTAS.COV_X+Right_XY, LISTAS.COV_Y+Right_Y)
					if CONTROL.CUSTOM_BACK == true then
						Graphics.drawRect(centrar_img_x+LISTAS.COV_FIX-(Right_XY//2), centrar_img_y+LISTAS.COV_FIX_Y-(Right_Y//2), LISTAS.COV_X+Right_XY, LISTAS.COV_Y+Right_Y, CAMBIOS_EMUS.COLOR_EMU_BACK)
					end
				else
					Graphics.drawScaleImage(LISTAS.COVER_DEFAULT, centrar_img_x+LISTAS.COV_FIX-(Right_XY//2), centrar_img_y+LISTAS.COV_FIX_Y-(Right_Y//2), LISTAS.COV_X+Right_XY, LISTAS.COV_Y+Right_Y, CAMBIOS_EMUS.COLOR_EMU_BACK)
				end
			end
		end
		Graphics.drawRect(0, 0, CONTROL.ANCHO, CONTROL.ALTO, Color.new(0, 0, 0, actual_n))
		Screen.flip()
	end
end

--- Realizar animación para las introducciones a los menús. -----------------------------
function intro_menu(cambio_ani, n_ani)
	if n_ani >= 1+(CONTROL.ANIM_VELOCIDAD//10) and cambio_ani == true then
		n_ani = n_ani-(CONTROL.ANIM_VELOCIDAD//10)
	elseif cambio_ani == true then
		n_ani = 0
		cambio_ani = false
	end
	local suma_x, suma_y = 0, 0
	for contador = 40, CONTROL.ALTO+40, 40 do
		for contador2 = -8, CONTROL.ANCHO+40, 40 do
			suma_x = contador2
			Graphics.drawRect(suma_x-(n_ani//2)+4, suma_y-(n_ani//2)+4, n_ani+4, n_ani+4, Color.new(0, 0, 0, (n_ani*3)))
		end
		suma_y = contador
	end
	return cambio_ani, n_ani
end

--- Dibujar los submenús con múltiples opciones. ----------------------------------------
--- "colores" es opcional y va al final para no tocar a las otras llamadas: una tabla
--- paralela a "submenu_lista" con el color de cada linea. Sin ella, todo como antes.
function submenu_selector(submenu_lista, submenu_actual, text_prin, pos_ini, pos_end, centrado, pos_cen, lista_resp, tipo_act, cargando, extra_list, pos_ext, colores)
	pos_end = (pos_end-pos_ini)+32
	if cargando == false then
		local p_end_res = ((pos_ini+pos_end)-32)+CONTROL.Y_FIX_PAL
		local x_menu, x_cent = (CONTROL.ANCHO//2), 8
		local fix_a, fix_b = (OPCIONES.FONT_PIXEL_X)*(string.len(lista_resp[1])), (OPCIONES.FONT_PIXEL_X)*(string.len(lista_resp[2]))
		if fix_b >= fix_a then fix_a = fix_b end
		local resp_pos_1, resp_pos_2 = ((CONTROL.ANCHO//2)-(fix_a))-3, ((CONTROL.ANCHO//2)+(fix_a//2))-3
		if centrado == false then
			x_menu, x_cent = pos_cen, 0
		end
		Graphics.drawRect(0, (pos_ini)+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, pos_end, COLOR.BLANCO)
		Graphics.drawRect(0, (pos_ini+2)+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, (pos_end-4), COLOR.NEGRO)
		Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), (pos_ini+10)+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 25, text_prin, COLOR.BLANCO)
		if #submenu_lista >= 1 then
			for mostrar = 1, #submenu_lista do
				local espacio_linea = (pos_ini+12)+((mostrar)*24)+CONTROL.Y_FIX_PAL
				local col_act, col_ina = COLOR.BLANCO, COLOR.GRIS
				if colores ~= nil and colores[mostrar] ~= nil then
					col_act, col_ina = colores[mostrar], colores[mostrar]
				end
				if submenu_actual == mostrar or submenu_actual == nil then
					Font.ftPrint(CONTROL.fontARCA, x_menu, espacio_linea, x_cent, CONTROL.ANCHO, 25, submenu_lista[mostrar], col_act)
					if pos_ext ~= nil and #extra_list == #submenu_lista then
						Font.ftPrint(CONTROL.fontARCA, pos_ext, espacio_linea, 0, CONTROL.ANCHO, 25, extra_list[mostrar], COLOR.BLANCO)
					end
				else
					Font.ftPrint(CONTROL.fontARCA, x_menu, espacio_linea, x_cent, CONTROL.ANCHO, 25, submenu_lista[mostrar], col_ina)
					if pos_ext ~= nil and #extra_list == #submenu_lista then
						Font.ftPrint(CONTROL.fontARCA, pos_ext, espacio_linea, 0, CONTROL.ANCHO, 25, extra_list[mostrar], col_ina)
					end
				end
			end
		end
		if tipo_act == true then
			Graphics.drawScaleImage(PAD_IMG.CROSS, resp_pos_1-25, p_end_res, 20, 20)
			Graphics.drawScaleImage(PAD_IMG.CIRCLE, resp_pos_2-25, p_end_res, 20, 20)
		elseif tipo_act == false then
			Graphics.drawScaleImage(PAD_IMG.SQUARE, resp_pos_1-25, p_end_res, 20, 20)
			Graphics.drawScaleImage(PAD_IMG.TRIANGLE, resp_pos_2-25, p_end_res, 20, 20)
		end
		Font.ftPrint(CONTROL.fontARCA, resp_pos_1, p_end_res, 0, 160, 25, lista_resp[1], COLOR.BLANCO)
		Font.ftPrint(CONTROL.fontARCA, resp_pos_2, p_end_res, 0, 160, 25, lista_resp[2], COLOR.BLANCO)
	elseif cargando == true then
		Graphics.drawRect(0, (pos_ini)+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, pos_end, COLOR.BLANCO)
		Graphics.drawRect(0, (pos_ini+2)+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, (pos_end-4), COLOR.NEGRO)
		Font.ftPrint(CONTROL.fontARCA, (CONTROL.ANCHO//2), (pos_ini+(pos_end//2)-17)+CONTROL.Y_FIX_PAL, 8, CONTROL.ANCHO, 25, text_prin, COLOR.BLANCO)
		refrescar(false)
		System.sleep(1)
	end
end

--- Ver los controles en pantalla. ------------------------------------------------------
function ver_controles(tipo)
	repro_sfx(S_EJECUTAR, 1, false, nil)
	local help_texto, help_texto2, help_texto3 = "HELP", "HELPSPA", "HELPPOR"
	if tipo == true then
		help_texto, help_texto2, help_texto3 = "HELP_EDIT", "HELP_EDITSPA", "HELP_EDITPOR"
	end
	if doesFileExist("System/Defaults/SPA") then
		help_texto = help_texto2
	elseif doesFileExist("System/Defaults/POR") then
		help_texto = help_texto3
	end
	if doesFileExist("System/Medias/Default/".. help_texto ..".png") then
		local yoshi, help, multi = true, Graphics.loadImage(verif_img("System/Medias/Default/".. help_texto ..".png")), 2
		while yoshi do
			capturar(JOYSTICK_LIMITE)
			Screen.clear(CAMBIOS_EMUS.COLOR_EMU)
			local Right_X, Right_Y, Right_XY = zoom(LISTAS.ART_ZOOM*multi, CONTROL.ANCHO, CONTROL.ALTO_F)
			local Left_X, Left_Y = Pads.getLeftStick(0)
			local x_pos, y_pos = 0-(Right_XY//2)-(Right_X//2)+(-Left_X), 0-(Right_Y//2)+(-Left_Y)
			Graphics.drawScaleImage(help, x_pos, y_pos, CONTROL.ANCHO+Right_XY, CONTROL.ALTO_F+Right_Y)
			if Right_X == 0 and Right_Y == 0 and Left_X == 1 and Left_Y == 1 then
				Graphics.drawRect(5, CONTROL.ALTO_F-23, calcular_sombras("Prism PS2 Launcher"), 20, COLOR.NEGRO_T)
				Font.ftPrint(CONTROL.fontARCA, 8, CONTROL.ALTO_F-22, 0, 640, 88, "Prism PS2 Launcher", COLOR.BLANCO)
				dibujar_indicador(558, (CONTROL.ALTO_F-23)-CONTROL.Y_FIX_PAL, TEXT_GEN[7], PAD_IMG.TRIANGLE, 20, 20, 3, true)
			end
			refrescar(false)
			if Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
				yoshi = false
				repro_sfx(S_CANCELAR, 1, false, nil)
			elseif (Pads.check(PAD, PAD_R1) or Pads.check(PAD, PAD_L1)) and CONTROL.JOYSTICK_ON == false then
				if Pads.check(PAD, PAD_R1) then
					multi = cambiar_valor(multi, 1, 3, 1, true)
				elseif Pads.check(PAD, PAD_L1) then
					multi = cambiar_valor(multi, 1, 3, 1, false)
				end
				JOYSTICK_LIMITE = control_FPS(1)
			end
		end
		Graphics.freeImage(help)
		JOYSTICK_LIMITE = control_FPS(1)-10
	end
end
