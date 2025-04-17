--[[------------------SPAGHETTICODE-------------------]]--
--[[█▀█ ██▀ ▀█▀ █▀█ █▀█ █    ▄▄ ▄ ▄ ▄▄▄ ▄▄▄ █▄▄ ▄▄  ▄▄]]--
--[[█▀▄ █▄▄  █  █▀▄ █▄█ █▄▄ ▀▄█ █▄█ █ █ █▄▄ █ █ ██▄ █ ]]--
--[[----------------------v1.0------------------------]]--

--[[Líneas para las funciones encargadas del menú principal de RETROLauncher.]]--
--- Líneas para dibujar elementos. ------------------------------------------------------
function dibujar_covers()
	if LISTAS.SCREENSHOT_FULL == false and #LISTAS.ROMS >= 1 and LISTAS.ROMS ~= nil then
		-- Dibujar artes extras (Cover Flow). -------------------------------------------
		if (CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_FLOW == true then
			if CONTROL.CUSTOM_BACK == true then
				Graphics.drawRect(CONTROL.FLOW_ANCHO-5, CONTROL.FLOW_ALTO-5, CONTROL.FLOW_X+10, CONTROL.FLOW_Y+10, COLOR.NEGRO_T)
				Graphics.drawRect(CONTROL.FLOW_ANCHO_2-5, CONTROL.FLOW_ALTO_2-5, CONTROL.FLOW_X_2+10, CONTROL.FLOW_Y_2+10, COLOR.NEGRO_T)
			end
			if LISTAS.COVER_ART2 ~= nil and LISTAS.EXISTE_COV2 == true then
				Graphics.drawScaleImage(LISTAS.COVER_ART2, CONTROL.FLOW_ANCHO+LISTAS.COV_1_FIX, CONTROL.FLOW_ALTO+LISTAS.COV_1_FIX_Y, LISTAS.COV_1_X, LISTAS.COV_1_Y)
			else
				if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
						Font.ftPrint(CONTROL.fontARCA, CONTROL.FLOW_ANCHO+(CONTROL.FLOW_X//2), CONTROL.FLOW_ALTO+(CONTROL.FLOW_Y//2)-10, 8, CONTROL.FLOW_X, CONTROL.FLOW_Y, "LOADING ART", COLOR.BLANCO)
				else
					if OPCIONES.FONDO_RGB_FIJO_ON == 1 and CAMBIOS_EMUS.TRAS ~= 0 then
						Graphics.drawScaleImage(LISTAS.COVER_DEFAULT, CONTROL.FLOW_ANCHO, CONTROL.FLOW_ALTO, CONTROL.FLOW_X, CONTROL.FLOW_Y)
						if CONTROL.CUSTOM_BACK == true then
							Graphics.drawRect(CONTROL.FLOW_ANCHO, CONTROL.FLOW_ALTO, CONTROL.FLOW_X, CONTROL.FLOW_Y, CAMBIOS_EMUS.COLOR_EMU_BACK)
						end
					else
						Graphics.drawScaleImage(LISTAS.COVER_DEFAULT, CONTROL.FLOW_ANCHO, CONTROL.FLOW_ALTO, CONTROL.FLOW_X, CONTROL.FLOW_Y, CAMBIOS_EMUS.COLOR_EMU_BACK)
					end
				end
			end
			if LISTAS.COVER_ART3 ~= nil and LISTAS.EXISTE_COV3 == true then
				Graphics.drawScaleImage(LISTAS.COVER_ART3, CONTROL.FLOW_ANCHO_2+LISTAS.COV_2_FIX, CONTROL.FLOW_ALTO_2+LISTAS.COV_2_FIX_Y, LISTAS.COV_2_X, LISTAS.COV_2_Y)
			else
				if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
					Font.ftPrint(CONTROL.fontARCA, CONTROL.FLOW_ANCHO_2+(CONTROL.FLOW_X_2//2), CONTROL.FLOW_ALTO_2+(CONTROL.FLOW_Y_2//2)-10, 8, CONTROL.FLOW_X_2, CONTROL.FLOW_Y_2, "LOADING ART", COLOR.BLANCO)
				else
					if OPCIONES.FONDO_RGB_FIJO_ON == 1 and CAMBIOS_EMUS.TRAS ~= 0 then
						Graphics.drawScaleImage(LISTAS.COVER_DEFAULT, CONTROL.FLOW_ANCHO_2, CONTROL.FLOW_ALTO_2, CONTROL.FLOW_X_2, CONTROL.FLOW_Y_2)
						if CONTROL.CUSTOM_BACK == true then
							Graphics.drawRect(CONTROL.FLOW_ANCHO_2, CONTROL.FLOW_ALTO_2, CONTROL.FLOW_X_2, CONTROL.FLOW_Y_2, CAMBIOS_EMUS.COLOR_EMU_BACK)
						end
					else
						Graphics.drawScaleImage(LISTAS.COVER_DEFAULT, CONTROL.FLOW_ANCHO_2, CONTROL.FLOW_ALTO_2, CONTROL.FLOW_X_2, CONTROL.FLOW_Y_2, CAMBIOS_EMUS.COLOR_EMU_BACK)
					end
				end
			end
		end

		-- Dibujar arte extra. ----------------------------------------------------------
		if (CONTROL.ESTILO == 3 or CONTROL.ESTILO == 5 or CONTROL.ESTILO == 6 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_ART2 == true then
			if CONTROL.CUSTOM_BACK == true then
				Graphics.drawRect(CONTROL.IMG_ANCHO_2-5, CONTROL.IMG_ALTO_2-5, CONTROL.IMG_X_2+10, CONTROL.IMG_Y_2+10, COLOR.NEGRO_T)
			end
			if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true then
				Graphics.drawScaleImage(LISTAS.SCREENSHOT, CONTROL.IMG_ANCHO_2+LISTAS.SCR_FIX_ART2, CONTROL.IMG_ALTO_2+LISTAS.SCR_FIX_Y_ART2, LISTAS.SCR_ART2_X, LISTAS.SCR_ART2_Y)
			else
				if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
					Font.ftPrint(CONTROL.fontARCA, CONTROL.IMG_ANCHO_2+(CONTROL.IMG_X_2//2), CONTROL.IMG_ALTO_2+(CONTROL.IMG_Y_2//2)-20, 8, CONTROL.IMG_X_2, CONTROL.IMG_Y_2, "-LOADING ART-", COLOR.BLANCO)
				else
					if OPCIONES.FONDO_RGB_FIJO_ON == 1 and CAMBIOS_EMUS.TRAS ~= 0 then
						Graphics.drawScaleImage(LISTAS.SCREENSHOT_DEFAULT, CONTROL.IMG_ANCHO_2, CONTROL.IMG_ALTO_2, CONTROL.IMG_X_2, CONTROL.IMG_Y_2)
						if CONTROL.CUSTOM_BACK == true then
							Graphics.drawRect(CONTROL.IMG_ANCHO_2, CONTROL.IMG_ALTO_2, CONTROL.IMG_X_2, CONTROL.IMG_Y_2, CAMBIOS_EMUS.COLOR_EMU_BACK)
						end
					else
						Graphics.drawScaleImage(LISTAS.SCREENSHOT_DEFAULT, CONTROL.IMG_ANCHO_2, CONTROL.IMG_ALTO_2, CONTROL.IMG_X_2, CONTROL.IMG_Y_2, CAMBIOS_EMUS.COLOR_EMU_BACK)
					end
				end
			end
		end
	end

	-- Dibujar fondo de lista. ----------------------------------------------------------
	if LISTAS.SCREENSHOT_FULL == false then
		if CONTROL.ESTILO == 3 and OPCIONES.GUI_LIMPIA_ON == 1 and CONTROL.CUSTOM_LIST == true then
			Graphics.drawRect(CONTROL.LISTA_ANCHO-3, CONTROL.LISTA_ALTO-3, CONTROL.LISTA_X+236+6, CONTROL.LISTA_Y+6, COLOR.NEGRO_T)
		elseif CONTROL.ESTILO ~= 2 and CONTROL.CUSTOM_LIST == true then
			Graphics.drawRect(CONTROL.LISTA_ANCHO-3, CONTROL.LISTA_ALTO-3, CONTROL.LISTA_X+6, CONTROL.LISTA_Y+6, COLOR.NEGRO_T)
		end
	end

	-- Dibujar listas. ------------------------------------------------------------------
	if #LISTAS.ROMS >= 1 and LISTAS.ROMS ~= nil then
		generar_listas()
		Controles_Listas()
		cargar_art()
	elseif LISTAS.SCREENSHOT_FULL == false then
		empty_list()
	end

	-- Dibujar logo. --------------------------------------------------------------------
	if LISTAS.SCREENSHOT_FULL == false and CONTROL.CUSTOM_LOGO == true then
		Graphics.drawScaleImage(LISTAS.LOGO, CONTROL.LOGO_ANCHO, CONTROL.LOGO_ALTO, CONTROL.LOGO_X, CONTROL.LOGO_Y)
	end

	if LISTAS.SCREENSHOT_FULL == false and #LISTAS.ROMS >= 1 and LISTAS.ROMS ~= nil then
		-- Dibujar indicadores. ---------------------------------------------------------
		if OPCIONES.GUI_LIMPIA_ON == 0 then
			dibujar_indicadores()
		end

		-- Dibujar cover / capturas / fondos. -------------------------------------------
		if CONTROL.CUSTOM_ART1 == true then
			if LISTAS.SCREENSHOT_ON == true then
				if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true then
					local Right_X, Right_Y, Right_XY = zoom(LISTAS.ART_ZOOM, LISTAS.SCR_X, LISTAS.SCR_Y)
					if CONTROL.CUSTOM_BACK == true then
						Graphics.drawRect(CONTROL.IMG_ANCHO-5-(Right_XY//2)-(Right_X//2), CONTROL.IMG_ALTO-5-(Right_Y//2), CONTROL.IMG_X+10+Right_XY, CONTROL.IMG_Y+10+Right_Y, COLOR.NEGRO_T)
					end
					Graphics.drawScaleImage(LISTAS.SCREENSHOT, CONTROL.IMG_ANCHO+LISTAS.SCR_FIX-(Right_XY//2)-(Right_X//2), CONTROL.IMG_ALTO+LISTAS.SCR_FIX_Y-(Right_Y//2), LISTAS.SCR_X+Right_XY, LISTAS.SCR_Y+Right_Y)
				else
					if CONTROL.CUSTOM_BACK == true then
						Graphics.drawRect(CONTROL.IMG_ANCHO-5, CONTROL.IMG_ALTO-5, CONTROL.IMG_X+10, CONTROL.IMG_Y+10, COLOR.NEGRO_T)
					end
					if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
						Font.ftPrint(CONTROL.fontARCA, CONTROL.IMG_ANCHO+(CONTROL.IMG_X//2), CONTROL.IMG_ALTO+(CONTROL.IMG_Y//2)-20, 8, CONTROL.IMG_X, CONTROL.IMG_Y, "-LOADING ART-", COLOR.BLANCO)
					else
						if OPCIONES.FONDO_RGB_FIJO_ON == 1 and CAMBIOS_EMUS.TRAS ~= 0 then
							Graphics.drawScaleImage(LISTAS.SCREENSHOT_DEFAULT, CONTROL.IMG_ANCHO, CONTROL.IMG_ALTO, CONTROL.IMG_X, CONTROL.IMG_Y)
							if CONTROL.CUSTOM_BACK == true then
								Graphics.drawRect(CONTROL.IMG_ANCHO, CONTROL.IMG_ALTO, CONTROL.IMG_X, CONTROL.IMG_Y, CAMBIOS_EMUS.COLOR_EMU_BACK)
							end
						else
							Graphics.drawScaleImage(LISTAS.SCREENSHOT_DEFAULT, CONTROL.IMG_ANCHO, CONTROL.IMG_ALTO, CONTROL.IMG_X, CONTROL.IMG_Y, CAMBIOS_EMUS.COLOR_EMU_BACK)
						end
					end
				end
			else
				if LISTAS.COVER_ART ~= nil and LISTAS.EXISTE_COV == true then
					local Right_X, Right_Y, Right_XY = zoom(LISTAS.ART_ZOOM, LISTAS.COV_X, LISTAS.COV_Y)
					if CONTROL.CUSTOM_BACK == true then
						Graphics.drawRect(CONTROL.IMG_ANCHO-5-(Right_XY//2)-(Right_X//2), CONTROL.IMG_ALTO-5-(Right_Y//2), CONTROL.IMG_X+10+Right_XY, CONTROL.IMG_Y+10+Right_Y, COLOR.NEGRO_T)
					end
					Graphics.drawScaleImage(LISTAS.COVER_ART, CONTROL.IMG_ANCHO+LISTAS.COV_FIX-(Right_XY//2)-(Right_X//2), CONTROL.IMG_ALTO+LISTAS.COV_FIX_Y-(Right_Y//2), LISTAS.COV_X+Right_XY, LISTAS.COV_Y+Right_Y)
				else
					if CONTROL.CUSTOM_BACK == true then
						Graphics.drawRect(CONTROL.IMG_ANCHO-5, CONTROL.IMG_ALTO-5, CONTROL.IMG_X+10, CONTROL.IMG_Y+10, COLOR.NEGRO_T)
					end
					if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
						Font.ftPrint(CONTROL.fontARCA, CONTROL.IMG_ANCHO+(CONTROL.IMG_X//2), CONTROL.IMG_ALTO+(CONTROL.IMG_Y//2)-20, 8, CONTROL.IMG_X, CONTROL.IMG_Y, "-LOADING ART-", COLOR.BLANCO)
					else
						if OPCIONES.FONDO_RGB_FIJO_ON == 1 and CAMBIOS_EMUS.TRAS ~= 0 then
							Graphics.drawScaleImage(LISTAS.COVER_DEFAULT, CONTROL.IMG_ANCHO, CONTROL.IMG_ALTO, CONTROL.IMG_X, CONTROL.IMG_Y)
							if CONTROL.CUSTOM_BACK == true then
								Graphics.drawRect(CONTROL.IMG_ANCHO, CONTROL.IMG_ALTO, CONTROL.IMG_X, CONTROL.IMG_Y, CAMBIOS_EMUS.COLOR_EMU_BACK)
							end
						else
							Graphics.drawScaleImage(LISTAS.COVER_DEFAULT, CONTROL.IMG_ANCHO, CONTROL.IMG_ALTO, CONTROL.IMG_X, CONTROL.IMG_Y, CAMBIOS_EMUS.COLOR_EMU_BACK)
						end
					end
				end
			end
		end
	end
end

--- Dibujar indicadores. ----------------------------------------------------------------
function dibujar_indicadores()
	local message = {"PRESS TO EXIT", "PRESS TO CONFIG", "CHANGE ART", "FULL SCREEN", "RUN GAME", "UPDATE LIST"}
	if CONTROL.ESTILO == 6 then
		message = {"EXIT", "CONFIG", "ART", "FULL", "RUN", "UPDATE LIST"}
	end
	-- Indicadores para cambio de sistemas. ---------------------------------------------
	if CONTROL.CUSTOM_BUTTON_L1 == true then
		Graphics.drawScaleImage(PAD_IMG.L1, CONTROL.X_BUTTON_L1, CONTROL.Y_BUTTON_L1+CONTROL.Y_FIX_PAL, 32, 32)
	end
	if CONTROL.CUSTOM_BUTTON_R1 == true then
		Graphics.drawScaleImage(PAD_IMG.R1, CONTROL.X_BUTTON_R1, CONTROL.Y_BUTTON_R1+CONTROL.Y_FIX_PAL, 32, 32)
	end

	-- Indicador de salida. -------------------------------------------------------------
	if CONTROL.CUSTOM_BUTTON_SEL == true then
		Graphics.drawRect(CONTROL.X_BUTTON_SEL, CONTROL.Y_BUTTON_SEL+CONTROL.Y_FIX_PAL, (OPCIONES.FONT_SHADOW*OPCIONES.FONT_PIXEL_X*(string.len(message[1])/2)/3), 20, COLOR.NEGRO_T)
		Graphics.drawScaleImage(PAD_IMG.SELECT_S, CONTROL.X_BUTTON_SEL-36, CONTROL.Y_BUTTON_SEL-7+CONTROL.Y_FIX_PAL, 32, 32)
		Font.ftPrint(CONTROL.fontARCA, CONTROL.X_BUTTON_SEL+3, CONTROL.Y_BUTTON_SEL+1+CONTROL.Y_FIX_PAL, 0, 0, 25, message[1], COLOR.BLANCO)
	end

	-- Indicador de configuración. ------------------------------------------------------
	if CONTROL.CUSTOM_BUTTON_STA == true then
		Graphics.drawRect(CONTROL.X_BUTTON_STA, CONTROL.Y_BUTTON_STA+CONTROL.Y_FIX_PAL, (OPCIONES.FONT_SHADOW*OPCIONES.FONT_PIXEL_X*(string.len(message[2])/2)/3), 20, COLOR.NEGRO_T)
		Graphics.drawScaleImage(PAD_IMG.START, CONTROL.X_BUTTON_STA-36, CONTROL.Y_BUTTON_STA-7+CONTROL.Y_FIX_PAL, 32, 32)
		Font.ftPrint(CONTROL.fontARCA, CONTROL.X_BUTTON_STA+3, CONTROL.Y_BUTTON_STA+1+CONTROL.Y_FIX_PAL, 0, 0, 25, message[2], COLOR.BLANCO)
	end

	-- Indicadores en listas. -----------------------------------------------------------
	if #LISTAS.ROMS >= 1 then
		-- Cambio de arte. --------------------------------------------------------------
		if CONTROL.CUSTOM_BUTTON_T == true then
			Graphics.drawRect(CONTROL.X_BUTTON_T, CONTROL.Y_BUTTON_T+CONTROL.Y_FIX_PAL, (OPCIONES.FONT_SHADOW*OPCIONES.FONT_PIXEL_X*(string.len(message[3])/2)/3), 20, COLOR.NEGRO_T)
			Graphics.drawScaleImage(PAD_IMG.TRIANGLE, CONTROL.X_BUTTON_T-30, CONTROL.Y_BUTTON_T-3+CONTROL.Y_FIX_PAL, 25, 25)
			Font.ftPrint(CONTROL.fontARCA, CONTROL.X_BUTTON_T+3, CONTROL.Y_BUTTON_T+1+CONTROL.Y_FIX_PAL, 0, 0, 25, message[3], COLOR.BLANCO)
		end

		-- Arte a pantalla completa. ----------------------------------------------------
		if CONTROL.CUSTOM_BUTTON_S == true then
			Graphics.drawRect(CONTROL.X_BUTTON_S, CONTROL.Y_BUTTON_S+CONTROL.Y_FIX_PAL, (OPCIONES.FONT_SHADOW*OPCIONES.FONT_PIXEL_X*(string.len(message[4])/2)/3), 20, COLOR.NEGRO_T)
			Graphics.drawScaleImage(PAD_IMG.SQUARE, CONTROL.X_BUTTON_S-30, CONTROL.Y_BUTTON_S-3+CONTROL.Y_FIX_PAL, 25, 25)
			Font.ftPrint(CONTROL.fontARCA, CONTROL.X_BUTTON_S+3, CONTROL.Y_BUTTON_S+1+CONTROL.Y_FIX_PAL, 0, 0, 25, message[4], COLOR.BLANCO)
		end

		-- Indicador de ejecución. ------------------------------------------------------
		if CONTROL.CUSTOM_BUTTON_X == true then
			Graphics.drawRect(CONTROL.X_BUTTON_X, CONTROL.Y_BUTTON_X+CONTROL.Y_FIX_PAL, (OPCIONES.FONT_SHADOW*OPCIONES.FONT_PIXEL_X*(string.len(message[5])/2)/3), 20, COLOR.NEGRO_T)
			Graphics.drawScaleImage(PAD_IMG.CROSS, CONTROL.X_BUTTON_X-30, CONTROL.Y_BUTTON_X-3+CONTROL.Y_FIX_PAL, 25, 25)
			Font.ftPrint(CONTROL.fontARCA, CONTROL.X_BUTTON_X+3, CONTROL.Y_BUTTON_X+1+CONTROL.Y_FIX_PAL, 0, 0, 25, message[5], COLOR.BLANCO)
		end
	else
		-- Actualizar la lista. ---------------------------------------------------------
		if CONTROL.CUSTOM_BUTTON_R3 == true then
			Graphics.drawRect(CONTROL.X_BUTTON_R3, CONTROL.Y_BUTTON_R3+CONTROL.Y_FIX_PAL, (OPCIONES.FONT_SHADOW*OPCIONES.FONT_PIXEL_X*(string.len(message[6])/2)/3), 20, COLOR.NEGRO_T)
			Graphics.drawScaleImage(PAD_IMG.R3, CONTROL.X_BUTTON_R3-30, CONTROL.Y_BUTTON_R3-3+CONTROL.Y_FIX_PAL, 25, 25)
			Font.ftPrint(CONTROL.fontARCA, CONTROL.X_BUTTON_R3+3, CONTROL.Y_BUTTON_R3+1+CONTROL.Y_FIX_PAL, 0, 0, 25, message[6], COLOR.BLANCO)
		end
	end
end

--- Dibujar listas vacías. --------------------------------------------------------------
function empty_list()
	if CONTROL.CUSTOM_BACK == true then
		if CONTROL.ESTILO == 3 and OPCIONES.GUI_LIMPIA_ON == 1 and CONTROL.CUSTOM_LIST == true then
			Graphics.drawRect(CONTROL.LISTA_ANCHO-3, CONTROL.LISTA_ALTO-3, CONTROL.LISTA_X+236+6, CONTROL.LISTA_Y+6, COLOR.NEGRO_T)
		elseif CONTROL.ESTILO ~= 2 and CONTROL.CUSTOM_LIST == true then
			Graphics.drawRect(CONTROL.LISTA_ANCHO-3, CONTROL.LISTA_ALTO-3, CONTROL.LISTA_X+6, CONTROL.LISTA_Y+6, COLOR.NEGRO_T)
		end
		if CONTROL.CUSTOM_ART1 == true then
			Graphics.drawRect(CONTROL.IMG_ANCHO-5, CONTROL.IMG_ALTO-5, CONTROL.IMG_X+10, CONTROL.IMG_Y+10, COLOR.NEGRO_T)
			Graphics.drawRect(CONTROL.IMG_ANCHO-5, CONTROL.IMG_ALTO-5, CONTROL.IMG_X+10, CONTROL.IMG_Y+10, COLOR.NEGRO_T)
		end
		if (CONTROL.ESTILO == 3 or CONTROL.ESTILO == 5 or CONTROL.ESTILO == 6 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_ART2 == true then
			Graphics.drawRect(CONTROL.IMG_ANCHO_2-5, CONTROL.IMG_ALTO_2-5, CONTROL.IMG_X_2+10, CONTROL.IMG_Y_2+10, COLOR.NEGRO_T)
			Graphics.drawRect(CONTROL.IMG_ANCHO_2-5, CONTROL.IMG_ALTO_2-5, CONTROL.IMG_X_2+10, CONTROL.IMG_Y_2+10, COLOR.NEGRO_T)
		end
		if (CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_FLOW == true then
			Graphics.drawRect(CONTROL.FLOW_ANCHO-5, CONTROL.FLOW_ALTO-5, CONTROL.FLOW_X+10, CONTROL.FLOW_Y+10, COLOR.NEGRO_T)
			Graphics.drawRect(CONTROL.FLOW_ANCHO_2-5, CONTROL.FLOW_ALTO_2-5, CONTROL.FLOW_X_2+10, CONTROL.FLOW_Y_2+10, COLOR.NEGRO_T)
			Graphics.drawRect(CONTROL.FLOW_ANCHO-5, CONTROL.FLOW_ALTO-5, CONTROL.FLOW_X+10, CONTROL.FLOW_Y+10, COLOR.NEGRO_T)
			Graphics.drawRect(CONTROL.FLOW_ANCHO_2-5, CONTROL.FLOW_ALTO_2-5, CONTROL.FLOW_X_2+10, CONTROL.FLOW_Y_2+10, COLOR.NEGRO_T)
		end
	end
	if (CONTROL.ESTILO == 2 or CONTROL.CUSTOM_LIST == false) and CONTROL.CUSTOM_ART1 == true then
		Font.ftPrint(CONTROL.fontARCA, CONTROL.IMG_ANCHO+(CONTROL.IMG_X//2), CONTROL.IMG_ALTO+(CONTROL.IMG_Y//2)-44, 8, CONTROL.IMG_X, CONTROL.IMG_Y, "NO GAMES FOUND", COLOR.BLANCO)
	elseif CONTROL.ESTILO == 3 and OPCIONES.GUI_LIMPIA_ON == 1 and CONTROL.CUSTOM_LIST == true then
		Font.ftPrint(CONTROL.fontARCA, CONTROL.LISTA_ANCHO+((CONTROL.LISTA_X+236)//2), CONTROL.LISTA_ALTO+(CONTROL.LISTA_Y//2)-20, 8, CONTROL.LISTA_X+236, CONTROL.LISTA_Y, "NO GAMES FOUND", COLOR.BLANCO)
	elseif CONTROL.CUSTOM_LIST == true then
		Font.ftPrint(CONTROL.fontARCA, CONTROL.LISTA_ANCHO+(CONTROL.LISTA_X//2), CONTROL.LISTA_ALTO+(CONTROL.LISTA_Y//2)-30, 8, CONTROL.LISTA_X, CONTROL.LISTA_Y, "NO GAMES FOUND", COLOR.BLANCO)
	end
	if OPCIONES.GUI_LIMPIA_ON == 0 then dibujar_indicadores() end
end

--- Mostrar error de ejecución. ---------------------------------------------------------
function error_run()
	local fx_inicio, fy_inicio, fx_final, fy_final = CONTROL.LISTA_ANCHO, CONTROL.LISTA_ALTO, CONTROL.LISTA_X, CONTROL.LISTA_Y
	local x_inicio, y_inicio, x_final, y_final = CONTROL.LISTA_ANCHO+(CONTROL.LISTA_X//2)-3, CONTROL.LISTA_ALTO+(CONTROL.LISTA_Y//4), CONTROL.LISTA_X, CONTROL.LISTA_Y
	if LISTAS.SCREENSHOT_FULL == true or ((CONTROL.LISTA_X <= 250 or CONTROL.LISTA_Y <= 118) and CONTROL.CUSTOM_LIST == true) or ((CONTROL.IMG_X <= 250 or CONTROL.IMG_Y <= 118) and CONTROL.CUSTOM_LIST == false) then
		fx_inicio, fy_inicio, fx_final, fy_final = 35, 5+CONTROL.Y_FIX_PAL, 570, 410
		x_inicio, y_inicio, x_final, y_final = 35+(570//2), (5+(410//2)-60)+CONTROL.Y_FIX_PAL, 570, 410
	elseif (CONTROL.ESTILO == 2 or CONTROL.CUSTOM_LIST == false) and CONTROL.CUSTOM_ART1 == true then
		fx_inicio, fy_inicio, fx_final, fy_final = CONTROL.IMG_ANCHO, CONTROL.IMG_ALTO, CONTROL.IMG_X, CONTROL.IMG_Y
		x_inicio, y_inicio, x_final, y_final = CONTROL.IMG_ANCHO+(CONTROL.IMG_X//2)-1, CONTROL.IMG_ALTO+(CONTROL.IMG_Y//4), CONTROL.IMG_X, CONTROL.IMG_Y
	elseif CONTROL.ESTILO == 3 then
		if OPCIONES.GUI_LIMPIA_ON == 1 then
			x_inicio, y_inicio, x_final, fx_final = CONTROL.LISTA_ANCHO+((CONTROL.LISTA_X+236)//2)+2, CONTROL.LISTA_ALTO+(CONTROL.LISTA_Y//6), CONTROL.LISTA_X+236, CONTROL.LISTA_X+236
		else
			y_inicio = CONTROL.LISTA_ALTO+(CONTROL.LISTA_Y//6)
		end
	elseif CONTROL.ESTILO == 5 then
		y_inicio = CONTROL.LISTA_ALTO+(CONTROL.LISTA_Y//6)
	end
	local pausar = true
	CONTROL.JOYSTICK_ON = true
	JOYSTICK_LIMITE = control_FPS(1)
	dibujar()
	if LISTAS.SCREENSHOT_FULL == true or ((CONTROL.LISTA_X <= 250 or CONTROL.LISTA_Y <= 118)
		and CONTROL.CUSTOM_LIST == true) or ((CONTROL.IMG_X <= 250 or CONTROL.IMG_Y <= 118)
			and CONTROL.CUSTOM_LIST == false) then dibujar_fondos() end
	Graphics.drawRect(fx_inicio-2, fy_inicio-2, fx_final+4, fy_final+4, COLOR.BLANCO)
	Graphics.drawRect(fx_inicio, fy_inicio, fx_final, fy_final, COLOR.NEGRO)
	Font.ftPrint(CONTROL.fontARCA, x_inicio-2, y_inicio, 8, x_final, y_final, "ERROR!", COLOR.BLANCO)
	if LISTAS.IDENTIDAD <= 11 then
		Font.ftPrint(CONTROL.fontARCA, x_inicio, y_inicio+19, 8, x_final, y_final, "GAMES OR RETROARCH", COLOR.BLANCO)
	elseif LISTAS.IDENTIDAD == 12 then
		Font.ftPrint(CONTROL.fontARCA, x_inicio, y_inicio+19, 8, x_final, y_final, "APPLICATION OR ELF", COLOR.BLANCO)
	elseif LISTAS.IDENTIDAD == 13 then
		Font.ftPrint(CONTROL.fontARCA, x_inicio, y_inicio+19, 8, x_final, y_final, "POSP OR BINARIES", COLOR.BLANCO)
	elseif LISTAS.IDENTIDAD == 14 then
		Font.ftPrint(CONTROL.fontARCA, x_inicio, y_inicio+19, 8, x_final, y_final, "NEUTRINO OR ISOs", COLOR.BLANCO)
	end
	Font.ftPrint(CONTROL.fontARCA, x_inicio, y_inicio+38, 8, x_final, y_final, "NOT FOUND!", COLOR.BLANCO)
	Font.ftPrint(CONTROL.fontARCA, x_inicio+8, y_inicio+59, 8, x_final, y_final, "BACK", COLOR.BLANCO)
	Graphics.drawScaleImage(PAD_IMG.CIRCLE, x_inicio-49, y_inicio+59, 20, 20)
	refrescar(false)
	while pausar do
		capturar(JOYSTICK_LIMITE)
		if Pads.check(PAD, PAD_CIRCLE) and CONTROL.JOYSTICK_ON == false then
			if OPCIONES.SOUND_ON == 1 and S_CANCELAR ~= nil then
				Sound.playADPCM(1, S_CANCELAR)
			end
			if OPCIONES.VIBRATION_ON == 1 then
				Pads.rumble(0, 250, 250)
			end
			pausar = false
			CONTROL.JOYSTICK_ON = true
			JOYSTICK_LIMITE = control_FPS(1)
		end
		refrescar(true)
	end
end

--- Líneas para ejecutar. ---------------------------------------------------------------
function run_game()
	if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then Sound.playADPCM(1, S_EJECUTAR) end
	local alt = false
	if LISTAS.IDENTIDAD == 14 or ((Pads.check(PAD, PAD_CROSS) and Pads.check(PAD, PAD_CIRCLE)) and (LISTAS.IDENTIDAD == 1 or (LISTAS.IDENTIDAD >= 4 and LISTAS.IDENTIDAD <= 7) or LISTAS.IDENTIDAD == 11 or LISTAS.IDENTIDAD == 12)) then
		alt = alt_run(LISTAS.IDENTIDAD)
	end

	-- Verificar archivos. --------------------------------------------------------------
	local verificar = existe(LISTAS.IDENTIDAD, LISTAS.ROMS[LISTAS.INDICE], alt)
	if verificar == true then
		ejecutar_juego(LISTAS.IDENTIDAD, LISTAS.ROMS[LISTAS.INDICE], alt)
	elseif verificar == false and alt ~= nil then
		if OPCIONES.SOUND_ON == 1 and S_ERROR ~= nil then Sound.playADPCM(3, S_ERROR) end
		error_run()
		CONTROL.JOYSTICK_ON = true
		JOYSTICK_LIMITE = control_FPS(1)
	end
end

--- Líneas para controlar las listas. ---------------------------------------------------
function Controles_Listas()
	local move, shake_r, shake_l, velociraptor, salto, suma, formato, extras = false, 0, 0, 1, 1, true, false, false

	-- Salto de carácter. ---------------------------------------------------------------
	if (CONTROL.ESTILO ~= 2 and ((Pads.check(PAD, PAD_R2) and Pads.check(PAD, PAD_DOWN)) or (Left_X >= 90))) or (((CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_FLOW == true) and ((Pads.check(PAD, PAD_R2) and Pads.check(PAD, PAD_DOWN)) or (Left_Y >= 90))) and CONTROL.JOYSTICK_ON == false then
		move, shake_r, shake_l, velociraptor, salto, suma, formato, extras, CONTROL.ACT_FONTABC = true, 255, 100, 1, 1, true, true, true, true
	elseif (CONTROL.ESTILO ~= 2 and ((Pads.check(PAD, PAD_L2) and Pads.check(PAD, PAD_UP)) or (Left_X <= -90))) or (((CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_FLOW == true) and ((Pads.check(PAD, PAD_L2) and Pads.check(PAD, PAD_UP)) or (Left_Y <= -90))) and CONTROL.JOYSTICK_ON == false then
		move, shake_r, shake_l, velociraptor, salto, suma, formato, extras, CONTROL.ACT_FONTABC = true, 100, 255, 1, 1, false, true, true, true

	-- Movimiento lento. ----------------------------------------------------------------
	elseif (CONTROL.ESTILO ~= 2 and Pads.check(PAD, PAD_DOWN)) or (((CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_FLOW == true) and (Pads.check(PAD, PAD_RIGHT) or Pads.check(PAD, PAD_DOWN))) and CONTROL.JOYSTICK_ON == false then
		move, shake_r, shake_l, velociraptor, salto, suma, formato, extras = true, 255, 100, 1, 1, true, false, true
	elseif (CONTROL.ESTILO ~= 2 and Pads.check(PAD, PAD_UP)) or (((CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_FLOW == true) and (Pads.check(PAD, PAD_LEFT) or Pads.check(PAD, PAD_UP))) and CONTROL.JOYSTICK_ON == false then
		move, shake_r, shake_l, velociraptor, salto, suma, formato, extras = true, 100, 255, 1, 1, false, false, true

	-- Movimiento rápido. ---------------------------------------------------------------
	elseif (CONTROL.ESTILO ~= 2 and (Pads.check(PAD, PAD_RIGHT) or (Left_Y >= 90))) or (((CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_FLOW == true) and (Pads.check(PAD, PAD_R2) or (Left_X >= 90))) and CONTROL.JOYSTICK_ON == false then
		move, shake_r, shake_l, velociraptor, salto, suma, formato, extras = true, 255, 100, 2, 1, true, false, true
	elseif (CONTROL.ESTILO ~= 2 and (Pads.check(PAD, PAD_LEFT) or (Left_Y <= -90))) or (((CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and CONTROL.CUSTOM_FLOW == true) and (Pads.check(PAD, PAD_L2) or (Left_X <= -90))) and CONTROL.JOYSTICK_ON == false then
		move, shake_r, shake_l, velociraptor, salto, suma, formato, extras = true, 100, 255, 2, 1, false, false, true

	-- Salto de elementos. --------------------------------------------------------------
	elseif CONTROL.ESTILO ~= 2 and Pads.check(PAD, PAD_R2) and CONTROL.JOYSTICK_ON == false then
		move, shake_r, shake_l, velociraptor, salto, suma, formato, extras = true, 255, 100, 1, 11, true, false, false
	elseif CONTROL.ESTILO ~= 2 and Pads.check(PAD, PAD_L2) and CONTROL.JOYSTICK_ON == false then
		move, shake_r, shake_l, velociraptor, salto, suma, formato, extras = true, 100, 255, 1, 11, false, false, false

	-- Ejecutar juego. ------------------------------------------------------------------
	elseif Pads.check(PAD, PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
		run_game()
	end

	-- Ejecutar movimientos. ------------------------------------------------------------
	if move == true then
		if formato == true then
			LISTAS.INDICE = letter_breaks(LISTAS.ROMS[LISTAS.INDICE], LISTAS.INDICE, suma)
		else
			LISTAS.INDICE = cambiar_valor(LISTAS.INDICE, 1, #LISTAS.ROMS, salto, suma)
		end
		if (CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and extras == true and CONTROL.CUSTOM_FLOW == true then
			indices_extras()
		end
		CONTROL.JOYSTICK_ON = true
		JOYSTICK_LIMITE = control_FPS(velociraptor)
		LISTAS.SCROLL_TEX = 1
		reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
		LISTAS.SCREENSHOT_ON = false
		limpiar_art()
		LISTAS.MOSTRAR = 0-CONTROL.FPS
		if OPCIONES.VIBRATION_ON == 1 and velociraptor == 1 then
			Pads.rumble(0, shake_l, shake_r)
		end
		if OPCIONES.SOUND_ON == 1 and S_MOVER ~= nil and velociraptor == 1 then
			Sound.playADPCM(1, S_MOVER)
		end
	end

	-- Mostrar menú de configuración PS2. -----------------------------------------------
	if LISTAS.IDENTIDAD == 14 and LISTAS.SCREENSHOT_FULL == false then
		local text_con = "FOUND GAMES: " ..#LISTAS.ROMS
		if CONTROL.JOYSTICK_ON == false then text_con = "GAME SETTINGS" end
		local fix_estilo = 29
		if ((CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and (CONTROL.CUSTOM_FLOW == true or CONTROL.CUSTOM_LIST == false)) or (CONTROL.ESTILO == 3 or CONTROL.ESTILO == 5) then fix_estilo = 24 end
		Graphics.drawRect(CONTROL.LISTA_ANCHO-3, (CONTROL.LISTA_ALTO+CONTROL.LISTA_Y)-fix_estilo+1, CONTROL.LISTA_X+6, fix_estilo+1, COLOR.NEGRO)
		Graphics.drawScaleImage(PAD_IMG.CIRCLE, CONTROL.LISTA_ANCHO+3, (CONTROL.LISTA_ALTO+CONTROL.LISTA_Y)-(fix_estilo-4), 20, 20)
		Font.ftPrint(CONTROL.fontARCA, CONTROL.LISTA_ANCHO+30, (CONTROL.LISTA_ALTO+CONTROL.LISTA_Y)-(fix_estilo-4), 0, CONTROL.LISTA_X-30, 25, text_con, CAMBIOS_EMUS.COLOR_EMU)
		if Pads.check(PAD, PAD_CIRCLE) and CONTROL.JOYSTICK_ON == false then
			if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then
				Sound.playADPCM(1, S_EJECUTAR)
			end
			if string.sub(LISTAS.ROMS[LISTAS.INDICE], -4) ~= ".elf" then menu_neutrino(LISTAS.ROMS[LISTAS.INDICE]) end
		end

	-- Mostrar número de ROMs encontradas. ----------------------------------------------
	elseif LISTAS.IDENTIDAD ~= 14 and Pads.check(PAD, PAD_CIRCLE) and LISTAS.SCREENSHOT_FULL == false then
		local text_con = "FOUND GAMES: "
		if LISTAS.IDENTIDAD == 12 then text_con = "FOUND APPS: " end
		local fix_estilo = 29
		if ((CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and (CONTROL.CUSTOM_FLOW == true or CONTROL.CUSTOM_LIST == false)) or (CONTROL.ESTILO == 3 or CONTROL.ESTILO == 5) then fix_estilo = 24 end
		Graphics.drawRect(CONTROL.LISTA_ANCHO-3, (CONTROL.LISTA_ALTO+CONTROL.LISTA_Y)-fix_estilo+1, CONTROL.LISTA_X+6, fix_estilo+1, COLOR.NEGRO)
		Graphics.drawScaleImage(PAD_IMG.CIRCLE, CONTROL.LISTA_ANCHO+3, (CONTROL.LISTA_ALTO+CONTROL.LISTA_Y)-(fix_estilo-4), 20, 20)
		Font.ftPrint(CONTROL.fontARCA, CONTROL.LISTA_ANCHO+30, (CONTROL.LISTA_ALTO+CONTROL.LISTA_Y)-(fix_estilo-4), 0, CONTROL.LISTA_X-30, 25, text_con ..#LISTAS.ROMS, CAMBIOS_EMUS.COLOR_EMU)
	end
end

--- Mostrar salto de carácter. ----------------------------------------------------------
function abc()
	local x_inicio, y_inicio, fix_px = (CONTROL.LISTA_ANCHO+(CONTROL.LISTA_X//2))-3, CONTROL.LISTA_ALTO+(CONTROL.LISTA_Y//2)-52, 3
	if LISTAS.SCREENSHOT_FULL == true then
		x_inicio, y_inicio = 35+(570//2), (5+(410//2))+54
	elseif CONTROL.ESTILO == 7 and ((CONTROL.LISTA_ALTO+(CONTROL.LISTA_Y//2)-94 <= CONTROL.LISTA_ALTO and CONTROL.CUSTOM_LIST == true) or (CONTROL.IMG_Y <= 120 and CONTROL.CUSTOM_LIST == false)) then
		if CONTROL.CUSTOM_LIST == false then
			local acortar = CONTROL.IMG_Y//2
			if CONTROL.IMG_Y <= 88 then acortar = 26 end
			x_inicio, y_inicio = CONTROL.IMG_ANCHO+(CONTROL.IMG_X//2), (CONTROL.IMG_ALTO+CONTROL.IMG_Y)-acortar
		elseif CONTROL.CUSTOM_LIST == true then
			local acortar = CONTROL.LISTA_Y//2
			if CONTROL.LISTA_Y <= 88 then acortar = 26 end
			x_inicio, y_inicio = CONTROL.LISTA_ANCHO+(CONTROL.LISTA_X//2), (CONTROL.LISTA_ALTO+CONTROL.LISTA_Y)-acortar
		end
	elseif (CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and (CONTROL.CUSTOM_LIST == false or CONTROL.CUSTOM_FLOW == true) and CONTROL.CUSTOM_ART1 == true then
		x_inicio, y_inicio = CONTROL.IMG_ANCHO+(CONTROL.IMG_X//2), CONTROL.IMG_ALTO+(CONTROL.IMG_Y//2)+46
	elseif CONTROL.ESTILO == 3 or CONTROL.ESTILO == 5 then
		if OPCIONES.GUI_LIMPIA_ON == 1 and CONTROL.ESTILO == 3 then
			x_inicio = (CONTROL.LISTA_ANCHO+((CONTROL.LISTA_X+236)//2))
		end
		y_inicio = CONTROL.LISTA_ALTO+(CONTROL.LISTA_Y//2)
	end
	if OPCIONES.CAMBIO_FUENTE_ON ~= 1 then fix_px = 0 end
	Graphics.drawRect(x_inicio-37, y_inicio-42, 74, 68, COLOR.NEGRO)
	Font.ftPrint(CONTROL.fontABC, x_inicio+fix_px, y_inicio, 8, 70, 70, string.sub(LISTAS.ROMS[LISTAS.INDICE], 1, 1), COLOR.BLANCO)
end

--- Scroll de texto. --------------------------------------------------------------------
function create_scroll(limite)
	if CONTROL.ESPERA_CARGA_SCR == false then
		if OPCIONES.GUI_LIMPIA_ON == 1 and CONTROL.ESTILO == 3 then
			LISTAS.SCROLL_TEX = scroll_texto(LISTAS.SCROLL_TEX, string.sub(LISTAS.ROMS[LISTAS.INDICE], 1, -CONTROL.EXTENSION), 42)
		else
			LISTAS.SCROLL_TEX = scroll_texto(LISTAS.SCROLL_TEX, string.sub(LISTAS.ROMS[LISTAS.INDICE], 1, -CONTROL.EXTENSION), limite)
		end
	end
	if (LISTAS.IDENTIDAD == 14 or LISTAS.IDENTIDAD == 13) and string.match(string.sub(LISTAS.ROMS[LISTAS.INDICE], 1, 12), "%a+_%d+.%d+%.") and LISTAS.SCROLL_TEX <= 13 then
		LISTAS.SCROLL_TEX = 13
	end
end

--- Dibuja elementos de la lista. -------------------------------------------------------
function mostrar_lista(pos_linea, elemento)
	local largo = CONTROL.LISTA_X
	if CONTROL.ESTILO == 3 and OPCIONES.GUI_LIMPIA_ON == 1 then
		largo = CONTROL.LISTA_X+236
	end
	if elemento ~= 0 then
		local fix_ini_name = 1
		if (LISTAS.IDENTIDAD == 14 or LISTAS.IDENTIDAD == 13) and string.match(string.sub(LISTAS.ROMS[elemento], 1, 12), "%a+_%d+.%d+%.") then fix_ini_name = 13 end
		Font.ftPrint(CONTROL.fontARCA, CONTROL.LISTA_ANCHO+3, pos_linea, 0, largo-6, 25, string.sub(LISTAS.ROMS[elemento], fix_ini_name, -CONTROL.EXTENSION), COLOR.BLANCO_LISTA)
	else
		Font.ftPrint(CONTROL.fontARCA, CONTROL.LISTA_ANCHO+3, pos_linea, 0, largo-6, 25, string.sub(LISTAS.ROMS[LISTAS.INDICE], LISTAS.SCROLL_TEX, -CONTROL.EXTENSION), CAMBIOS_EMUS.COLOR_EMU)
	end
end

--- Líneas para mostrar listas. ---------------------------------------------------------
function generar_listas()
	-- Tiempos de scroll y arte. --------------------------------------------------------
	tiempo_de_scroll()
	tiempo_arte()

	-- Mostrar listas / estilo 1 / estilo 4 / estilo 6. ---------------------------------
	if CONTROL.ESTILO == 1 or CONTROL.ESTILO == 4 or CONTROL.ESTILO == 6 then
		-- Controlar scroll de texto / estilo 1 / estilo 4 / estilo 6. ------------------
		create_scroll(OPCIONES.SCROLL_MIN)

		-- Mostrar listas de juegos / estilo 1 / estilo 4 / estilo 6. -------------------
		local max_lista = 0
		if LISTAS.SCREENSHOT_FULL == false then
			for contador = 0, 11, 1 do
				local espacio_linea = CONTROL.LISTA_ALTO+((contador)*24)
				if contador == 0 then
					mostrar_lista(espacio_linea, contador)
				elseif (LISTAS.INDICE+contador) <= #LISTAS.ROMS then
					mostrar_lista(espacio_linea, (LISTAS.INDICE+contador))
				elseif max_lista <= #LISTAS.ROMS-1 and #LISTAS.ROMS >= 12 then
					max_lista = max_lista+1
					mostrar_lista(espacio_linea, max_lista)
				end
			end
		end

	-- Mostrar listas / estilo 2. -------------------------------------------------------
	elseif (CONTROL.ESTILO == 2 or CONTROL.ESTILO == 7) and (CONTROL.CUSTOM_FLOW == true or CONTROL.CUSTOM_LIST == false) then
		-- Controlar scroll de texto / estilo 2. ----------------------------------------
		create_scroll(OPCIONES.SCROLL_MIN)

		-- Mostrar listas de juegos / estilo 2. -----------------------------------------
		if LISTAS.SCREENSHOT_FULL == false then
			if CONTROL.CUSTOM_FLOW == true then
				-- Mostrar arte / izquierda / estilo 2. ---------------------------------
				Graphics.drawRect(CONTROL.FLOW_ANCHO, (CONTROL.FLOW_ALTO+CONTROL.FLOW_Y)+10, CONTROL.FLOW_X, 25, COLOR.NEGRO_T)
				local fix_ini_name1 = 1
				if (LISTAS.IDENTIDAD == 14 or LISTAS.IDENTIDAD == 13) and string.match(string.sub(LISTAS.ROMS[LISTAS.INDICE2], 1, 12), "%a+_%d+.%d+%.") then fix_ini_name1 = 13 end
				Font.ftPrint(CONTROL.fontARCA, CONTROL.FLOW_ANCHO+5, (CONTROL.FLOW_ALTO+CONTROL.FLOW_Y)+12, 0, CONTROL.FLOW_X-10, 25, string.sub(LISTAS.ROMS[LISTAS.INDICE2], fix_ini_name1, -CONTROL.EXTENSION), COLOR.BLANCO_LISTA)

				-- Mostrar arte / derecha / estilo 2. -----------------------------------
				Graphics.drawRect(CONTROL.FLOW_ANCHO_2, (CONTROL.FLOW_ALTO_2+CONTROL.FLOW_Y_2)+10, CONTROL.FLOW_X_2, 25, COLOR.NEGRO_T)
				local fix_ini_name2 = 1
				if (LISTAS.IDENTIDAD == 14 or LISTAS.IDENTIDAD == 13) and string.match(string.sub(LISTAS.ROMS[LISTAS.INDICE3], 1, 12), "%a+_%d+.%d+%.") then fix_ini_name2 = 13 end
				Font.ftPrint(CONTROL.fontARCA, CONTROL.FLOW_ANCHO_2+5, (CONTROL.FLOW_ALTO_2+CONTROL.FLOW_Y_2)+12, 0, CONTROL.FLOW_X_2-10, 25, string.sub(LISTAS.ROMS[LISTAS.INDICE3], fix_ini_name2, -CONTROL.EXTENSION), COLOR.BLANCO_LISTA)
			end

			-- Mostrar arte / centro / estilo 2. ----------------------------------------
			Graphics.drawRect(CONTROL.IMG_ANCHO-31, (CONTROL.IMG_ALTO+CONTROL.IMG_Y)+14, CONTROL.IMG_X+62, 25, COLOR.NEGRO_T)
			Font.ftPrint(CONTROL.fontARCA, (CONTROL.IMG_ANCHO-31)+5, (CONTROL.IMG_ALTO+CONTROL.IMG_Y)+16, 0, (CONTROL.IMG_X+62)-5, 25, string.sub(LISTAS.ROMS[LISTAS.INDICE], LISTAS.SCROLL_TEX, -CONTROL.EXTENSION), CAMBIOS_EMUS.COLOR_EMU)
		end

	-- Mostrar listas / estilo 3. -------------------------------------------------------
	elseif CONTROL.ESTILO == 3 then
		-- Correcciones del estilo / estilo 3. ------------------------------------------
		local largo = CONTROL.LISTA_X
		if OPCIONES.GUI_LIMPIA_ON == 1 then largo = CONTROL.LISTA_X+236 end

		-- Controlar scroll de texto / estilo 3. ----------------------------------------
		create_scroll(OPCIONES.SCROLL_MIN)
		-- Mostrar listas de juegos / estilo 3. -----------------------------------------
		local max_lista = 0
		if LISTAS.SCREENSHOT_FULL == false then
			for contador = 0, 5, 1 do
				local espacio_linea = CONTROL.LISTA_ALTO+((contador)*24)
				if contador == 0 then
					mostrar_lista(espacio_linea, contador)
				elseif (LISTAS.INDICE+contador) <= #LISTAS.ROMS then
					mostrar_lista(espacio_linea, (LISTAS.INDICE+contador))
				elseif max_lista <= #LISTAS.ROMS-1 and #LISTAS.ROMS >= 6 then
					max_lista = max_lista+1
					mostrar_lista(espacio_linea, max_lista)
				end
				if contador == 3 then
					Graphics.drawRect(CONTROL.LISTA_ANCHO, espacio_linea-4, largo, 24, Color.new(0, 0, 0, 30))
				end
				if contador == 4 then
					Graphics.drawRect(CONTROL.LISTA_ANCHO, espacio_linea-4, largo, 24, Color.new(0, 0, 0, 40))
				end
				if contador == 5 then
					Graphics.drawRect(CONTROL.LISTA_ANCHO, espacio_linea-4, largo, 24, Color.new(0, 0, 0, 60))
				end
			end
		end

	-- Mostrar listas / estilo 5. -------------------------------------------------------
	elseif CONTROL.ESTILO == 5 then
		-- Controlar scroll de texto / estilo 5. ----------------------------------------
		create_scroll(OPCIONES.SCROLL_MIN-1)

		-- Mostrar listas de juegos / estilo 5. -----------------------------------------
		local max_lista = 0
		if LISTAS.SCREENSHOT_FULL == false then
			for contador = 0, 4, 1 do
				local espacio_linea = CONTROL.LISTA_ALTO+((contador)*24)
				if contador == 0 then
					mostrar_lista(espacio_linea, contador)
				elseif (LISTAS.INDICE+contador) <= #LISTAS.ROMS then
					mostrar_lista(espacio_linea, (LISTAS.INDICE+contador))
				elseif max_lista <= #LISTAS.ROMS-1 and #LISTAS.ROMS >= 5 then
					max_lista = max_lista+1
					mostrar_lista(espacio_linea, max_lista)
				end
				if contador == 2 then
					Graphics.drawRect(CONTROL.LISTA_ANCHO, espacio_linea-4, CONTROL.LISTA_X, 25, Color.new(0, 0, 0, 30))
				end
				if contador == 3 then
					Graphics.drawRect(CONTROL.LISTA_ANCHO, espacio_linea-4, CONTROL.LISTA_X, 25, Color.new(0, 0, 0, 40))
				end
				if contador == 4 then
					Graphics.drawRect(CONTROL.LISTA_ANCHO, espacio_linea-4, CONTROL.LISTA_X, 25, Color.new(0, 0, 0, 60))
				end
			end
		end

	-- Mostrar listas / estilo 7. -------------------------------------------------------
	elseif CONTROL.ESTILO == 7 and CONTROL.CUSTOM_FLOW == false and CONTROL.CUSTOM_LIST == true then
		-- Controlar scroll de texto / estilo 7. ----------------------------------------
		create_scroll(OPCIONES.SCROLL_MIN)

		-- Mostrar listas de juegos / estilo 7. -----------------------------------------
		local max_lista = 0
		if LISTAS.SCREENSHOT_FULL == false then
			for contador = 0, LISTAS.ELEMENTOS_LIST, 1 do
				local espacio_linea = CONTROL.LISTA_ALTO+((contador)*24)
				if contador == 0 then
					mostrar_lista(espacio_linea, contador)
				elseif (LISTAS.INDICE+contador) <= #LISTAS.ROMS then
					mostrar_lista(espacio_linea, (LISTAS.INDICE+contador))
				elseif max_lista <= #LISTAS.ROMS-1 and #LISTAS.ROMS >= LISTAS.ELEMENTOS_LIST+1 then
					max_lista = max_lista+1
					mostrar_lista(espacio_linea, max_lista)
				end
			end
		end
	end
end

--- Dibujar y controlar RETROLauncher. --------------------------------------------------
function dibujar()
	-- Capturar controles. --------------------------------------------------------------
	capturar(JOYSTICK_LIMITE)

	-- Dibujar fondos. ------------------------------------------------------------------
	Screen.clear(COLOR.NEGRO)
	RGB()
	dibujar_fondos()
	if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true and OPCIONES.SCREENSHOT_BACK_ON == 1 then
		Graphics.drawScaleImage(LISTAS.SCREENSHOT, -5, 0, CONTROL.ANCHO+5, CONTROL.ALTO_F)
	end

	-- Dibujar listas y arte. -----------------------------------------------------------
	dibujar_covers()

	-- Cambiar de sistema. --------------------------------------------------------------
	if (Pads.check(PAD, PAD_R1) or Pads.check(PAD, PAD_L1)) and CONTROL.JOYSTICK_ON == false then
		local disabled, side, shake_l, shake_r = false, true, 100, 255
		if Pads.check(PAD, PAD_L1) then
			disabled, side, shake_l, shake_r = true, false, 255, 100
		end
		if OPCIONES.SOUND_ON == 1 and S_NETX ~= nil then
			Sound.playADPCM(1, S_NETX)
		end
		LAST_MOVE[LISTAS.IDENTIDAD] = LISTAS.INDICE
		desactivados(disabled)
		if LAST_MOVE[LISTAS.IDENTIDAD] <= #LISTAS.ROMS then
			LISTAS.INDICE = LAST_MOVE[LISTAS.IDENTIDAD]
		else
			LISTAS.INDICE = 1
			LAST_MOVE[LISTAS.IDENTIDAD] = 1
		end
		indices_extras()
		CONTROL.JOYSTICK_ON = true
		JOYSTICK_LIMITE = 2
		LISTAS.SCROLL_TEX = 1
		reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
		animaciones(side)
		LISTAS.SCREENSHOT_ON = false
		limpiar_art()
		LISTAS.MOSTRAR = 0-CONTROL.FPS
		if OPCIONES.VIBRATION_ON == 1 then
			Pads.rumble(0, shake_l, shake_r)
		end
	end

	-- Intercambiar arte. ---------------------------------------------------------------
	if Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false and LISTAS.MOSTRAR >= LISTAS.ART_LIMITE then
		if LISTAS.SCREENSHOT_ON == false then
			LISTAS.SCREENSHOT_ON = true
		else
			LISTAS.SCREENSHOT_ON = false
		end
		CONTROL.JOYSTICK_ON = true
		JOYSTICK_LIMITE = control_FPS(1)
		if OPCIONES.SOUND_ON == 1 and S_CANCELAR ~= nil then
			Sound.playADPCM(1, S_CANCELAR)
		end
		if OPCIONES.VIBRATION_ON == 1 then
			Pads.rumble(0, 250, 250)
		end
	end

	-- Mostrar arte a pantalla completa. ------------------------------------------------
	if Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
		if LISTAS.SCREENSHOT_FULL == false then
			LISTAS.SCREENSHOT_FULL = true
		else
			LISTAS.SCREENSHOT_FULL = false
		end
		if OPCIONES.SOUND_ON == 1 and S_CANCELAR ~= nil then
			Sound.playADPCM(1, S_CANCELAR)
		end
		CONTROL.JOYSTICK_ON = true
		JOYSTICK_LIMITE = control_FPS(1)
		if OPCIONES.VIBRATION_ON == 1 then
			Pads.rumble(0, 250, 250)
		end
	end

	-- Dibujar arte a pantalla completa. ------------------------------------------------
	if LISTAS.SCREENSHOT_FULL == true then
		local mostar_extras = false
		if LISTAS.SCREENSHOT_ON == true and #LISTAS.ROMS >= 1 and LISTAS.ROMS ~= nil then
			if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true then
				local Right_X, Right_Y, Right_XY = zoom(LISTAS.ART_ZOOM, LISTAS.EX_FIX_S, LISTAS.EX_FIX_S_Y)
				if CONTROL.CUSTOM_BACK == true then
					Graphics.drawRect(35-(Right_XY//2)-(Right_X//2), 5-(Right_Y//2)+CONTROL.Y_FIX_PAL, 570+Right_XY, 410+Right_Y, COLOR.NEGRO_T)
				end
				Graphics.drawScaleImage(LISTAS.SCREENSHOT, (60+(520-LISTAS.EX_FIX_S)//2)-(Right_XY//2)-(Right_X//2), 15+((390-LISTAS.EX_FIX_S_Y)//2)-(Right_Y//2)+CONTROL.Y_FIX_PAL, (LISTAS.EX_FIX_S+Right_XY), (LISTAS.EX_FIX_S_Y+Right_Y))
				if Right_X ~= 0 or Right_Y ~= 0 then mostar_extras = true end
			else
				if CONTROL.CUSTOM_BACK == true then
					Graphics.drawRect(35, 5+CONTROL.Y_FIX_PAL, 570, 410, COLOR.NEGRO_T)
				end
				if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
					Font.ftPrint(CONTROL.fontARCA, 35+(570//2), (5+(410//2)-20)+CONTROL.Y_FIX_PAL, 8, 570, 410, "-LOADING ART-", COLOR.BLANCO)
				else
					if OPCIONES.FONDO_RGB_FIJO_ON == 1 and CAMBIOS_EMUS.TRAS ~= 0 then
						Graphics.drawScaleImage(LISTAS.SCREENSHOT_DEFAULT, 45, 15+CONTROL.Y_FIX_PAL, 550, 390)
						if CONTROL.CUSTOM_BACK == true then
							Graphics.drawRect(45, 15+CONTROL.Y_FIX_PAL, 550, 390, CAMBIOS_EMUS.COLOR_EMU_BACK)
						end
					else
						Graphics.drawScaleImage(LISTAS.SCREENSHOT_DEFAULT, 45, 15+CONTROL.Y_FIX_PAL, 550, 390, CAMBIOS_EMUS.COLOR_EMU_BACK)
					end
				end
			end
		elseif #LISTAS.ROMS >= 1 and LISTAS.ROMS ~= nil then
			if LISTAS.COVER_ART ~= nil and LISTAS.EXISTE_COV == true then
				local Right_X, Right_Y, Right_XY = zoom(LISTAS.ART_ZOOM, LISTAS.EX_FIX_C, LISTAS.EX_FIX_C_Y)
				if CONTROL.CUSTOM_BACK == true then
					Graphics.drawRect(35-(Right_XY//2)-(Right_X//2), 5-(Right_Y//2)+CONTROL.Y_FIX_PAL, 570+Right_XY, 410+Right_Y, COLOR.NEGRO_T)
				end
				Graphics.drawScaleImage(LISTAS.COVER_ART, (60+(520-LISTAS.EX_FIX_C)//2)-(Right_XY//2)-(Right_X//2), 15+((390-LISTAS.EX_FIX_C_Y)//2)-(Right_Y//2)+CONTROL.Y_FIX_PAL, (LISTAS.EX_FIX_C+Right_XY), (LISTAS.EX_FIX_C_Y+Right_Y))
				if Right_X ~= 0 or Right_Y ~= 0 then mostar_extras = true end
			else
				if CONTROL.CUSTOM_BACK == true then
					Graphics.drawRect(35, 5+CONTROL.Y_FIX_PAL, 570, 410, COLOR.NEGRO_T)
				end
				if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
					Font.ftPrint(CONTROL.fontARCA, 35+(570//2), (5+(410//2)-20)+CONTROL.Y_FIX_PAL, 8, 570, 410, "-LOADING ART-", COLOR.BLANCO)
				else
					if OPCIONES.FONDO_RGB_FIJO_ON == 1 and CAMBIOS_EMUS.TRAS ~= 0 then
						Graphics.drawScaleImage(LISTAS.COVER_DEFAULT, 45, 15+CONTROL.Y_FIX_PAL, 550, 390)
						if CONTROL.CUSTOM_BACK == true then
							Graphics.drawRect(45, 15+CONTROL.Y_FIX_PAL, 550, 390, CAMBIOS_EMUS.COLOR_EMU_BACK)
						end
					else
						Graphics.drawScaleImage(LISTAS.COVER_DEFAULT, 45, 15+CONTROL.Y_FIX_PAL, 550, 390, CAMBIOS_EMUS.COLOR_EMU_BACK)
					end
				end
			end
		end

		-- Mostrar nombre del juego. ----------------------------------------------------
		if mostar_extras == false and #LISTAS.ROMS >= 1 and LISTAS.ROMS ~= nil then
			Graphics.drawRect(165, 403+CONTROL.Y_FIX_PAL, 310, 20, COLOR.NEGRO_T)
			Font.ftPrint(CONTROL.fontARCA, 170, 403+CONTROL.Y_FIX_PAL, 0, 307, 2, string.sub(LISTAS.ROMS[LISTAS.INDICE], LISTAS.SCROLL_TEX, -CONTROL.EXTENSION), CAMBIOS_EMUS.COLOR_EMU)
		end

		-- Dibujar indicadores de listas. -----------------------------------------------
		if mostar_extras == false then
			if OPCIONES.GUI_LIMPIA_ON == 0 and #LISTAS.ROMS >= 1 and LISTAS.ROMS ~= nil then
				if CONTROL.CUSTOM_BUTTON_T == true then
					Graphics.drawRect(38, 424+CONTROL.Y_FIX_PAL, (OPCIONES.FONT_SHADOW*OPCIONES.FONT_PIXEL_X*(string.len("CHANGE ART")/2)/3), 20, COLOR.NEGRO_T)
					Graphics.drawScaleImage(PAD_IMG.TRIANGLE, 38-27, 424+CONTROL.Y_FIX_PAL, 20, 20)
					Font.ftPrint(CONTROL.fontARCA, 38+3, 424+1+CONTROL.Y_FIX_PAL, 0, 0, 8, "CHANGE ART", COLOR.BLANCO)
				end
				if CONTROL.CUSTOM_BUTTON_S == true then
					Graphics.drawRect(483, 424+CONTROL.Y_FIX_PAL, (OPCIONES.FONT_SHADOW*OPCIONES.FONT_PIXEL_X*(string.len("FULL SCREEN")/2)/3), 20, COLOR.NEGRO_T)
					Graphics.drawScaleImage(PAD_IMG.SQUARE, 483-27, 424+CONTROL.Y_FIX_PAL, 20, 20)
					Font.ftPrint(CONTROL.fontARCA, 483+3, 424+1+CONTROL.Y_FIX_PAL, 0, 0, 8, "FULL SCREEN", COLOR.BLANCO)
				end
				if CONTROL.CUSTOM_BUTTON_X == true then
					Graphics.drawRect(275, 424+CONTROL.Y_FIX_PAL, (OPCIONES.FONT_SHADOW*OPCIONES.FONT_PIXEL_X*(string.len("RUN GAME")/2)/3), 20, COLOR.NEGRO_T)
					Graphics.drawScaleImage(PAD_IMG.CROSS, 275-27, 424+CONTROL.Y_FIX_PAL, 20, 20)
					Font.ftPrint(CONTROL.fontARCA, 275+3, 424+1+CONTROL.Y_FIX_PAL, 0, 0, 8, "RUN GAME", COLOR.BLANCO)
				end
			elseif OPCIONES.GUI_LIMPIA_ON == 0 then
				if CONTROL.CUSTOM_BUTTON_R3 == true then
					Graphics.drawRect(255, 424+CONTROL.Y_FIX_PAL, (OPCIONES.FONT_SHADOW*OPCIONES.FONT_PIXEL_X*(string.len("UPDATE LIST")/2)/3), 20, COLOR.NEGRO_T)
					Graphics.drawScaleImage(PAD_IMG.R3, 255-27, 424+CONTROL.Y_FIX_PAL, 20, 20)
					Font.ftPrint(CONTROL.fontARCA, 255+3, 424+1+CONTROL.Y_FIX_PAL, 0, 0, 25, "UPDATE LIST", COLOR.BLANCO)
				end
			end
			if #LISTAS.ROMS <= 0 or LISTAS.ROMS == nil then
				if CONTROL.CUSTOM_BACK == true then
					Graphics.drawRect(35, 5+CONTROL.Y_FIX_PAL, 570, 410, COLOR.NEGRO_T)
					Graphics.drawRect(35, 5+CONTROL.Y_FIX_PAL, 570, 410, COLOR.NEGRO_T)
				end
				Font.ftPrint(CONTROL.fontARCA, 35+(570//2), (5+(410//2)-50)+CONTROL.Y_FIX_PAL, 8, 570, 410, "NO GAMES FOUND", COLOR.BLANCO)
			end
		end
	end

	-- Dibujar salto de carácter. -------------------------------------------------------
	if #LISTAS.ROMS >= 1 and LISTAS.ROMS ~= nil and CONTROL.ACT_FONTABC == true and CONTROL.JOYSTICK_ON == true then
		abc()
	else
		CONTROL.ACT_FONTABC = false
	end

	-- Entrar en configuraciones. -------------------------------------------------------
	if Pads.check(PAD, PAD_START) then
		if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then
			Sound.playADPCM(1, S_EJECUTAR)
		end
		CONTROL.JOYSTICK_ON = true
		JOYSTICK_LIMITE = control_FPS(1)
		menu_config()
	end

	-- Refrescar lista actual. ----------------------------------------------------------
	if Pads.check(PAD, PAD_R3) then
		Pads.rumble(0, 0, 0)
		if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then
			Sound.playADPCM(1, S_EJECUTAR)
		end
		recargar_una(LISTAS.IDENTIDAD)
		LISTAS.ROMS = nil
		LISTAS.ROMS = PRE_CARGADAS[LISTAS.IDENTIDAD]
		LISTAS.INDICE = 1
		indices_extras()
		reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
		limpiar_art()
		LISTAS.MOSTRAR = 0-CONTROL.FPS
		CONTROL.JOYSTICK_ON = true
		JOYSTICK_LIMITE = control_FPS(1)
	end

	-- Reiniciar / Salir de RETROLauncher. ----------------------------------------------
	if (Pads.check(PAD, PAD_L3) or Pads.check(PAD, PAD_SELECT)) and CONTROL.JOYSTICK_ON == false then
		if OPCIONES.SOUND_ON == 1 and S_CANCELAR ~= nil then
			Sound.playADPCM(1, S_CANCELAR)
		end
		local pregunta = true
		local message_pause = {"RESET RETROLAUNCHER?", "RESET", "CANCEL"}
		local salir = nil
		if Pads.check(PAD, PAD_SELECT) then
			message_pause = {"QUIT RETROLAUNCHER?", "QUIT", "CANCEL"}
			salir = true
		end
		Graphics.drawRect(0, 160+CONTROL.Y_FIX_PAL, 640, 92, Color.new(128, 128, 128))
		Graphics.drawRect(0, 162+CONTROL.Y_FIX_PAL, 640, 88, Color.new(0, 0, 0))
		Font.ftPrint(CONTROL.fontARCA, (640//2), (162+8)+CONTROL.Y_FIX_PAL, 8, 640, 88, message_pause[1], COLOR.BLANCO)
		Graphics.drawScaleImage(PAD_IMG.CROSS, 300-35, 195+CONTROL.Y_FIX_PAL, 20, 20)
		Font.ftPrint(CONTROL.fontARCA, 300, 195+CONTROL.Y_FIX_PAL, 0, 160, 24, message_pause[2], COLOR.BLANCO)
		Graphics.drawScaleImage(PAD_IMG.CIRCLE, 300-35, 219+CONTROL.Y_FIX_PAL, 20, 20)
		Font.ftPrint(CONTROL.fontARCA, 300, 219+CONTROL.Y_FIX_PAL, 0, 160, 24, message_pause[3], COLOR.BLANCO)
		refrescar(false)
		local actual = System.currentDirectory()
		while pregunta do
			capturar(JOYSTICK_LIMITE)
			if Pads.check(PAD, PAD_CROSS) then
				if OPCIONES.SOUND_ON == 1 and S_EJECUTAR ~= nil then
					Sound.playADPCM(1, S_EJECUTAR)
				end
				if doesFileExist(actual .."/System/RetroarchPS2/APPS/WLE.elf") and (OPCIONES.SALIDA_RETROLANCHER_ON ~= 0 or salir == nil) then
					app_alt(salir)
					System.loadELF(actual .."/System/RetroarchPS2/APPS/WLE.elf", 0, actual .."/System/RetroarchPS2/APPS/")
				elseif salir == true and OPCIONES.SALIDA_RETROLANCHER_ON ~= 0 then
					System.loadELF(OPCIONES.SALIDA_RETROLANCHER, 0, salida_texto_dir(OPCIONES.SALIDA_RETROLANCHER, false))
				elseif salir == true then
					System.exitToBrowser()
				else
					System.loadELF(actual .."/RETROLauncher.elf", 0, actual .. "/System/system.lua")
				end
			elseif Pads.check(PAD, PAD_CIRCLE) or Pads.check(PAD, PAD_TRIANGLE) then
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
			refrescar(true)
		end
	end

	--SISTEMA TEST-----------------------------------------------------------------------
	--Font.ftPrint(CONTROL.fontARCA, 15, 0, 0, 0, 8, "RAM: ".. System.getFreeMemory(), COLOR.BLANCO)
	--Font.ftPrint(CONTROL.fontARCA, 15, 20, 0, 0, 8, "VRAM: ".. Screen.getFreeVRAM(), COLOR.BLANCO)
	--Font.ftPrint(CONTROL.fontARCA, 535, 0, 0, 0, 8, "FPS: ".. CONTROL.FPS, COLOR.BLANCO)
	--devs = System.listDevices()
	--for contador = 1, #devs, 1 do Font.ftPrint(CONTROL.fontARCA, 0, 10+((contador)*24), 0, 0, 8, devs[contador].name ..":", COLOR.BLANCO) end
	-------------------------------------------------------------------------------------
end
--[[------------------SPAGHETTICODE-------------------]]--