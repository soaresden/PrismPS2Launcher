--[[------------------SPAGHETTICODE-------------------]]--
--[[█▀█ ██▀ ▀█▀ █▀█ █▀█ █    ▄▄ ▄ ▄ ▄▄▄ ▄▄▄ █▄▄ ▄▄  ▄▄]]--
--[[█▀▄ █▄▄  █  █▀▄ █▄█ █▄▄ ▀▄█ █▄█ █ █ █▄▄ █ █ ██▄ █ ]]--
--[[--------------------------------------------------]]--

--- Líneas para dibujar elementos
-----------------------------------------------------------------------------------------
function Dibujar()
	-- Dibujar fondo
	Screen.clear(COLOR.NEGRO)
	RGB()
	if OPCIONES.FONDO_RGB_ON == 1 then
		Graphics.drawRect(0,0,640,480,CAMBIOS_EMUS.COLOR_EMU_BACK)
		Graphics.drawScaleImage(LISTAS.FONDO,-5,0,CONTROL.ANCHO+5,CONTROL.ALTO,CAMBIOS_EMUS.COLOR_EMU_BACK)
	else
		Graphics.drawScaleImage(LISTAS.FONDO,-5,0,CONTROL.ANCHO+5,CONTROL.ALTO)
	end	
	if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true and OPCIONES.SCREENSHOT_BACK_ON == 1 then
		Graphics.drawScaleImage(LISTAS.SCREENSHOT,-5,0,CONTROL.ANCHO+5,CONTROL.ALTO)
	end
	
	---SISTEMA TEST-----------------------------------------------------------------------------------
	--- Líneas para evitar cuelgue de memoria --------------------------------------------------------
	local freemem = System.getFreeMemory()
	local actual = System.currentDirectory() 
	if freemem <= 99999 then
		System.loadELF(actual .."/RETROLauncher.elf",0,actual .. "/System/system.lua")
	end
	--------------------------------------------------------------------------------------------------
	--local freevram = Screen.getFreeVRAM()
	--Font.ftPrint(CONTROL.fontARCA,15,0,0,0,8,"RAM: "..freemem,COLOR.BLANCO)
	--Font.ftPrint(CONTROL.fontARCA,15,20,0,0,8,"VRAM: ".. freevram,COLOR.BLANCO)
	--Font.ftPrint(CONTROL.fontARCA,535,0,0,0,8,"FPS: ".. CONTROL.FPS,COLOR.BLANCO)
	--------------------------------------------------------------------------------------------------
	
	-- Dibujar arte / estilo 1
	if CONTROL.ESTILO == 1 and LISTAS.SCREENSHOT_FULL == false then
		if OPCIONES.GUI_LIMPIA_ON == 0 then
			-- Dibujar indicadores para cambio de sistemas
			Graphics.drawScaleImage(PAD_IMG.L1,144,28,32,32)
			Graphics.drawScaleImage(PAD_IMG.R1,464,28,32,32)
			
			-- Dibujar indicadores de menú de configuración y salida de RETROlauncher / estilo 1
			if OPCIONES.CAMBIO_FUENTE_ON == 1 then	
				Graphics.drawRect(43,417,180,20,COLOR.NEGRO_T)
				Graphics.drawRect(421,417,209,20,COLOR.NEGRO_T)
			end
			Graphics.drawScaleImage(PAD_IMG.SELECT_S,10,410,32,32)
			Font.ftPrint(CONTROL.fontARCA,51,417,0,0,8,"PRESS TO EXIT",COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.START,385,410,32,32)
			Font.ftPrint(CONTROL.fontARCA,426,417,0,0,8,"PRESS TO CONFIG",COLOR.BLANCO)
			
			-- Dibujar indicadores de listas / estilo 1
			if #LISTAS.ROMS >= 1 then
				if OPCIONES.CAMBIO_FUENTE_ON == 1 then	 
					Graphics.drawRect(CONTROL.IMG_ANCHO+30,CONTROL.IMG_ALTO+206,141,20,COLOR.NEGRO_T)
					Graphics.drawRect(CONTROL.IMG_ANCHO+30,CONTROL.IMG_ALTO+234,153,20,COLOR.NEGRO_T)
					Graphics.drawRect(CONTROL.IMG_ANCHO+30,CONTROL.IMG_ALTO+262,115,20,COLOR.NEGRO_T)
				end
				Graphics.drawScaleImage(PAD_IMG.TRIANGLE,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO+203,25,25)
				Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+35,CONTROL.IMG_ALTO+206,0,0,8,"CHANGE ART",COLOR.BLANCO)
				
				Graphics.drawScaleImage(PAD_IMG.SQUARE,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO+231,25,25)
				Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+35,CONTROL.IMG_ALTO+234,0,0,8,"FULL SCREEN",COLOR.BLANCO)
				
				Graphics.drawScaleImage(PAD_IMG.CROSS,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO+259,25,25)
				Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+35,CONTROL.IMG_ALTO+262,0,0,8,"RUN GAME",COLOR.BLANCO)
			else
				if OPCIONES.CAMBIO_FUENTE_ON == 1 then	
					Graphics.drawRect(CONTROL.IMG_ANCHO+30,CONTROL.IMG_ALTO+206,155,20,COLOR.NEGRO_T)
				end
				Graphics.drawScaleImage(PAD_IMG.R3,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO+203,25,25)
				Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+35,CONTROL.IMG_ALTO+206,0,0,8,"UPDATE LIST",COLOR.BLANCO)
			end
		end
		
		-- Dibujar cover y capturas / estilo 1
		Graphics.drawScaleImage(LISTAS.LOGO,CONTROL.LOGO_ANCHO,CONTROL.LOGO_ALTO,252,76)
		Graphics.drawRect(CONTROL.LISTA_ANCHO-3,CONTROL.LISTA_ALTO-3,310+6,290+6,COLOR.NEGRO_T)
		Graphics.drawRect(CONTROL.IMG_ANCHO-5,CONTROL.IMG_ALTO-5,250+10,193+10,COLOR.NEGRO_T)
		if LISTAS.SCREENSHOT_ON == true then 
			if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true then
				Graphics.drawScaleImage(LISTAS.SCREENSHOT,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,250,193)
			else
				if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
					Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+38,CONTROL.IMG_ALTO+70,0,0,8,"-LOADING ART-",COLOR.BLANCO)
				else
					Graphics.drawScaleImage(LISTAS.SCREENSHOT_DEFAULT,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,250,193,CAMBIOS_EMUS.COLOR_EMU_BACK)
				end
			end
		else
			if LISTAS.COVER_ART ~= nil and LISTAS.EXISTE_COV == true then
				Graphics.drawScaleImage(LISTAS.COVER_ART,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,250,193)
			else
				if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
					Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+38,CONTROL.IMG_ALTO+70,0,0,8,"-LOADING ART-",COLOR.BLANCO)
				else
					Graphics.drawScaleImage(LISTAS.COVER_DEFAULT,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,250,193,CAMBIOS_EMUS.COLOR_EMU_BACK)
				end
			end
		end
		
	-- Dibujar arte / estilo 2
	elseif CONTROL.ESTILO == 2 and LISTAS.SCREENSHOT_FULL == false then
		if OPCIONES.GUI_LIMPIA_ON == 0 then
			-- Dibujar indicadores para cambio de sistemas
			Graphics.drawScaleImage(PAD_IMG.L1,144,28,32,32)
			Graphics.drawScaleImage(PAD_IMG.R1,464,28,32,32)
		
			-- Dibujar indicadores de menú de configuración y salida de RETROlauncher / estilo 2
			if OPCIONES.CAMBIO_FUENTE_ON == 1 then	
				Graphics.drawRect(43,417,180,20,COLOR.NEGRO_T)
				Graphics.drawRect(421,417,209,20,COLOR.NEGRO_T)
			end
			Graphics.drawScaleImage(PAD_IMG.SELECT_S,10,410,32,32)
			Font.ftPrint(CONTROL.fontARCA,51,417,0,0,8,"PRESS TO EXIT",COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.START,385,410,32,32)
			Font.ftPrint(CONTROL.fontARCA,426,417,0,0,8,"PRESS TO CONFIG",COLOR.BLANCO)
			
			-- Dibujar indicadores de listas / estilo 2
			if #LISTAS.ROMS >= 1 then
				local fix_ps2 = 0
				if LISTAS.IDENTIDAD == 14 then
					fix_ps2 = 3
				end
				if OPCIONES.CAMBIO_FUENTE_ON == 1 then	
					Graphics.drawRect(CONTROL.IMG_ANCHO-155,CONTROL.IMG_ALTO+265+fix_ps2,141,20,COLOR.NEGRO_T)
					Graphics.drawRect(CONTROL.IMG_ANCHO+280,CONTROL.IMG_ALTO+265+fix_ps2,153,20,COLOR.NEGRO_T)
					Graphics.drawRect(CONTROL.IMG_ANCHO+75,CONTROL.IMG_ALTO+265+fix_ps2,115,20,COLOR.NEGRO_T)
				end
				
				Graphics.drawScaleImage(PAD_IMG.TRIANGLE,CONTROL.IMG_ANCHO-185,CONTROL.IMG_ALTO+262+fix_ps2,25,25)
				Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO-150,CONTROL.IMG_ALTO+265+fix_ps2,0,0,8,"CHANGE ART",COLOR.BLANCO)
				
				Graphics.drawScaleImage(PAD_IMG.SQUARE,CONTROL.IMG_ANCHO+250,CONTROL.IMG_ALTO+262+fix_ps2,25,25)
				Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+285,CONTROL.IMG_ALTO+265+fix_ps2,0,0,8,"FULL SCREEN",COLOR.BLANCO)
				
				Graphics.drawScaleImage(PAD_IMG.CROSS,CONTROL.IMG_ANCHO+45,CONTROL.IMG_ALTO+262+fix_ps2,25,25)
				Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+80,CONTROL.IMG_ALTO+265+fix_ps2,0,0,8,"RUN GAME",COLOR.BLANCO)
			else
				if OPCIONES.CAMBIO_FUENTE_ON == 1 then	
					Graphics.drawRect(CONTROL.IMG_ANCHO+60,CONTROL.IMG_ALTO+265,155,20,COLOR.NEGRO_T)
				end
				Graphics.drawScaleImage(PAD_IMG.R3,CONTROL.IMG_ANCHO+35,CONTROL.IMG_ALTO+262,25,25)
				Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+65,CONTROL.IMG_ALTO+265,0,0,8,"UPDATE LIST",COLOR.BLANCO)
			end
		end
		
		-- Dibujar cover y capturas / estilo 2
		Graphics.drawScaleImage(LISTAS.LOGO,CONTROL.LOGO_ANCHO,CONTROL.LOGO_ALTO,252,76)
		Graphics.drawRect(CONTROL.IMG_ANCHO-5,CONTROL.IMG_ALTO-5,250+10,193+10,COLOR.NEGRO_T)
		Graphics.drawRect(CONTROL.IMG_ANCHO-180-5,CONTROL.IMG_ALTO+40-5,160+10,103+10,COLOR.NEGRO_T)
		Graphics.drawRect(CONTROL.IMG_ANCHO+270-5,CONTROL.IMG_ALTO+40-5,160+10,103+10,COLOR.NEGRO_T)
		if LISTAS.SCREENSHOT_ON == true then 
			if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true then
				Graphics.drawScaleImage(LISTAS.SCREENSHOT,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,250,193)
			else
				if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
					Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+38,CONTROL.IMG_ALTO+70,0,0,8,"-LOADING ART-",COLOR.BLANCO)
				else
					Graphics.drawScaleImage(LISTAS.SCREENSHOT_DEFAULT,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,250,193,CAMBIOS_EMUS.COLOR_EMU_BACK)
				end
			end
		else
			if LISTAS.COVER_ART ~= nil and LISTAS.EXISTE_COV == true then
				Graphics.drawScaleImage(LISTAS.COVER_ART,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,250,193)
			else
				if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
					Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+38,CONTROL.IMG_ALTO+70,0,0,8,"-LOADING ART-",COLOR.BLANCO)
				else
					Graphics.drawScaleImage(LISTAS.COVER_DEFAULT,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,250,193,CAMBIOS_EMUS.COLOR_EMU_BACK)
				end
			end
		end
		if LISTAS.COVER_ART2 ~= nil and LISTAS.EXISTE_COV2 == true then
			Graphics.drawScaleImage(LISTAS.COVER_ART2,CONTROL.IMG_ANCHO-180,CONTROL.IMG_ALTO+40,160,103)
		else
			if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
					Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO-171,CONTROL.IMG_ALTO+80,0,0,8,"LOADING ART",COLOR.BLANCO)
			else
				Graphics.drawScaleImage(LISTAS.COVER_DEFAULT,CONTROL.IMG_ANCHO-180,CONTROL.IMG_ALTO+40,160,103,CAMBIOS_EMUS.COLOR_EMU_BACK)
			end
		end
		if LISTAS.COVER_ART3 ~= nil and LISTAS.EXISTE_COV3 == true then
			Graphics.drawScaleImage(LISTAS.COVER_ART3,CONTROL.IMG_ANCHO+270,CONTROL.IMG_ALTO+40,160,103)
		else
			if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
					Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+279,CONTROL.IMG_ALTO+80,0,0,8,"LOADING ART",COLOR.BLANCO)
			else
				Graphics.drawScaleImage(LISTAS.COVER_DEFAULT,CONTROL.IMG_ANCHO+270,CONTROL.IMG_ALTO+40,160,103,CAMBIOS_EMUS.COLOR_EMU_BACK)
			end
		end
	
	-- Dibujar arte / estilo 3
	elseif CONTROL.ESTILO == 3 and LISTAS.SCREENSHOT_FULL == false then
		if OPCIONES.GUI_LIMPIA_ON == 0 then
			-- Dibujar indicadores para cambio de sistemas
			Graphics.drawScaleImage(PAD_IMG.L1,144,28,32,32)
			Graphics.drawScaleImage(PAD_IMG.R1,464,28,32,32)
		
			-- Dibujar indicadores de menú de configuración y salida de RETROlauncher / estilo 3
			if OPCIONES.CAMBIO_FUENTE_ON == 1 then	
				Graphics.drawRect(CONTROL.LISTA_ANCHO+356,384,180,20,COLOR.NEGRO_T)
				Graphics.drawRect(CONTROL.LISTA_ANCHO+356,412,209,20,COLOR.NEGRO_T)
			end
			Graphics.drawScaleImage(PAD_IMG.SELECT_S,CONTROL.LISTA_ANCHO+320,377,32,32)
			Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+362,384,0,0,8,"PRESS TO EXIT",COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.START,CONTROL.LISTA_ANCHO+320,405,32,32)
			Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+362,412,0,0,8,"PRESS TO CONFIG",COLOR.BLANCO)
			
			-- Dibujar indicadores de listas / estilo 3
			if #LISTAS.ROMS >= 1 then
				if OPCIONES.CAMBIO_FUENTE_ON == 1 then	 
					Graphics.drawRect(CONTROL.LISTA_ANCHO+353,298,141,20,COLOR.NEGRO_T)
					Graphics.drawRect(CONTROL.LISTA_ANCHO+353,326,153,20,COLOR.NEGRO_T)
					Graphics.drawRect(CONTROL.LISTA_ANCHO+353,354,115,20,COLOR.NEGRO_T)
				end
				Graphics.drawScaleImage(PAD_IMG.TRIANGLE,CONTROL.LISTA_ANCHO+323,295,25,25)
				Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+362,298,0,0,8,"CHANGE ART",COLOR.BLANCO)
				
				Graphics.drawScaleImage(PAD_IMG.SQUARE,CONTROL.LISTA_ANCHO+323,323,25,25)
				Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+362,326,0,0,8,"FULL SCREEN",COLOR.BLANCO)
				
				Graphics.drawScaleImage(PAD_IMG.CROSS,CONTROL.LISTA_ANCHO+323,351,25,25)
				Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+362,354,0,0,8,"RUN GAME",COLOR.BLANCO)
			else
				if OPCIONES.CAMBIO_FUENTE_ON == 1 then
					Graphics.drawRect(CONTROL.LISTA_ANCHO+353,298,155,20,COLOR.NEGRO_T)
				end
				Graphics.drawScaleImage(PAD_IMG.R3,CONTROL.LISTA_ANCHO+323,295,25,25)
				Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+362,298,0,0,8,"UPDATE LIST",COLOR.BLANCO)
			end
		end
		
		-- Dibujar cover y capturas / estilo 3
		Graphics.drawScaleImage(LISTAS.LOGO,CONTROL.LOGO_ANCHO,CONTROL.LOGO_ALTO,252,76)
		if OPCIONES.GUI_LIMPIA_ON == 1 then
			Graphics.drawRect(CONTROL.LISTA_ANCHO-3,CONTROL.LISTA_ALTO-3,544+6,137+6,COLOR.NEGRO_T)
		else
			Graphics.drawRect(CONTROL.LISTA_ANCHO-3,CONTROL.LISTA_ALTO-3,310+6,137+6,COLOR.NEGRO_T)
		end
		Graphics.drawRect(CONTROL.IMG_ANCHO-5,CONTROL.IMG_ALTO-5,250+10,193+10,COLOR.NEGRO_T)
		Graphics.drawRect(CONTROL.LISTA_ANCHO-5,CONTROL.IMG_ALTO-5,250+10,193+10,COLOR.NEGRO_T)
		if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true then
			Graphics.drawScaleImage(LISTAS.SCREENSHOT,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,250,193)
		else
			if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
				Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+38,CONTROL.IMG_ALTO+70,0,0,8,"-LOADING ART-",COLOR.BLANCO)
			else
				Graphics.drawScaleImage(LISTAS.SCREENSHOT_DEFAULT,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,250,193,CAMBIOS_EMUS.COLOR_EMU_BACK)
			end
		end
		if LISTAS.SCREENSHOT_ON == true then 
			if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true then
				Graphics.drawScaleImage(LISTAS.SCREENSHOT,CONTROL.LISTA_ANCHO,CONTROL.IMG_ALTO,250,193)
			else
				if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
					Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+38,CONTROL.IMG_ALTO+70,0,0,8,"-LOADING ART-",COLOR.BLANCO)
				else
					Graphics.drawScaleImage(LISTAS.SCREENSHOT_DEFAULT,CONTROL.LISTA_ANCHO,CONTROL.IMG_ALTO,250,193,CAMBIOS_EMUS.COLOR_EMU_BACK)
				end
			end
		else
			if LISTAS.COVER_ART ~= nil and LISTAS.EXISTE_COV == true then
				Graphics.drawScaleImage(LISTAS.COVER_ART,CONTROL.LISTA_ANCHO,CONTROL.IMG_ALTO,250,193)
			else
				if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
					Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+38,CONTROL.IMG_ALTO+70,0,0,8,"-LOADING ART-",COLOR.BLANCO)
				else
					Graphics.drawScaleImage(LISTAS.COVER_DEFAULT,CONTROL.LISTA_ANCHO,CONTROL.IMG_ALTO,250,193,CAMBIOS_EMUS.COLOR_EMU_BACK)
				end
			end
		end
	
	-- Dibujar arte / estilo 4
	elseif CONTROL.ESTILO == 4 and LISTAS.SCREENSHOT_FULL == false then
		if OPCIONES.GUI_LIMPIA_ON == 0 then
			-- Dibujar indicadores para cambio de sistemas
			Graphics.drawScaleImage(PAD_IMG.L1,144,28,32,32)
			Graphics.drawScaleImage(PAD_IMG.R1,464,28,32,32)
		
			-- Dibujar indicadores de menú de configuración y salida de RETROlauncher / estilo 4
			if OPCIONES.CAMBIO_FUENTE_ON == 1 then	
				Graphics.drawRect(43,417,180,20,COLOR.NEGRO_T)
				Graphics.drawRect(421,417,209,20,COLOR.NEGRO_T)
			end
			Graphics.drawScaleImage(PAD_IMG.SELECT_S,10,410,32,32)
			Font.ftPrint(CONTROL.fontARCA,51,417,0,0,8,"PRESS TO EXIT",COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.START,385,410,32,32)
			Font.ftPrint(CONTROL.fontARCA,426,417,0,0,8,"PRESS TO CONFIG",COLOR.BLANCO)
			
			-- Dibujar indicadores de listas / estilo 4
			if #LISTAS.ROMS >= 1 then
				if OPCIONES.CAMBIO_FUENTE_ON == 1 then	
					Graphics.drawRect(40,390,141,20,COLOR.NEGRO_T)
					Graphics.drawRect(475,390,153,20,COLOR.NEGRO_T)
					Graphics.drawRect(270,390,115,20,COLOR.NEGRO_T)
				end
				
				Graphics.drawScaleImage(PAD_IMG.TRIANGLE,10,387,25,25)
				Font.ftPrint(CONTROL.fontARCA,45,390,0,0,8,"CHANGE ART",COLOR.BLANCO)
				
				Graphics.drawScaleImage(PAD_IMG.SQUARE,445,387,25,25)
				Font.ftPrint(CONTROL.fontARCA,480,390,0,0,8,"FULL SCREEN",COLOR.BLANCO)
				
				Graphics.drawScaleImage(PAD_IMG.CROSS,240,387,25,25)
				Font.ftPrint(CONTROL.fontARCA,275,390,0,0,8,"RUN GAME",COLOR.BLANCO)
			else
				if OPCIONES.CAMBIO_FUENTE_ON == 1 then	
					Graphics.drawRect(255,390,155,20,COLOR.NEGRO_T)
				end
				Graphics.drawScaleImage(PAD_IMG.R3,230,387,25,25)
				Font.ftPrint(CONTROL.fontARCA,260,390,0,0,8,"UPDATE LIST",COLOR.BLANCO)
			end
		end
		
		-- Dibujar cover y capturas / estilo 4
		Graphics.drawScaleImage(LISTAS.LOGO,CONTROL.LOGO_ANCHO,CONTROL.LOGO_ALTO,252,76)
		Graphics.drawRect(CONTROL.LISTA_ANCHO-3,CONTROL.LISTA_ALTO-3,310+6,290+6,COLOR.NEGRO_T)
		Graphics.drawRect(CONTROL.IMG_ANCHO-5,CONTROL.IMG_ALTO-5,295+10,228+10,COLOR.NEGRO_T)
		if LISTAS.SCREENSHOT_ON == true then 
			if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true then
				Graphics.drawScaleImage(LISTAS.SCREENSHOT,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,295,228)
			else
				if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
					Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+61,CONTROL.IMG_ALTO+92,0,0,8,"-LOADING ART-",COLOR.BLANCO)
				else
					Graphics.drawScaleImage(LISTAS.SCREENSHOT_DEFAULT,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,295,228,CAMBIOS_EMUS.COLOR_EMU_BACK)
				end
			end
		else
			if LISTAS.COVER_ART ~= nil and LISTAS.EXISTE_COV == true then
				Graphics.drawScaleImage(LISTAS.COVER_ART,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,295,228)
			else
				if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
					Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+61,CONTROL.IMG_ALTO+92,0,0,8,"-LOADING ART-",COLOR.BLANCO)
				else
					Graphics.drawScaleImage(LISTAS.COVER_DEFAULT,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,295,228,CAMBIOS_EMUS.COLOR_EMU_BACK)
				end
			end
		end
		
	-- Dibujar arte / estilo 5
	elseif CONTROL.ESTILO == 5 and LISTAS.SCREENSHOT_FULL == false then
		if OPCIONES.GUI_LIMPIA_ON == 0 then
			-- Dibujar indicadores para cambio de sistemas
			Graphics.drawScaleImage(PAD_IMG.L1,324,252,32,32)
			Graphics.drawScaleImage(PAD_IMG.R1,602,252,32,32)
		
			-- Dibujar indicadores de menú de configuración y salida de RETROlauncher / estilo 5
			if OPCIONES.CAMBIO_FUENTE_ON == 1 then	
				Graphics.drawRect(43,417,180,20,COLOR.NEGRO_T)
				Graphics.drawRect(421,417,209,20,COLOR.NEGRO_T)
			end
			Graphics.drawScaleImage(PAD_IMG.SELECT_S,10,410,32,32)
			Font.ftPrint(CONTROL.fontARCA,51,417,0,0,8,"PRESS TO EXIT",COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.START,385,410,32,32)
			Font.ftPrint(CONTROL.fontARCA,426,417,0,0,8,"PRESS TO CONFIG",COLOR.BLANCO)
			
			-- Dibujar indicadores de listas / estilo 5
			if #LISTAS.ROMS >= 1 then
				if OPCIONES.CAMBIO_FUENTE_ON == 1 then	
					Graphics.drawRect(40,390,141,20,COLOR.NEGRO_T)
					Graphics.drawRect(475,390,153,20,COLOR.NEGRO_T)
					Graphics.drawRect(270,390,115,20,COLOR.NEGRO_T)
				end
				
				Graphics.drawScaleImage(PAD_IMG.TRIANGLE,10,387,25,25)
				Font.ftPrint(CONTROL.fontARCA,45,390,0,0,8,"CHANGE ART",COLOR.BLANCO)
				
				Graphics.drawScaleImage(PAD_IMG.SQUARE,445,387,25,25)
				Font.ftPrint(CONTROL.fontARCA,480,390,0,0,8,"FULL SCREEN",COLOR.BLANCO)
				
				Graphics.drawScaleImage(PAD_IMG.CROSS,240,387,25,25)
				Font.ftPrint(CONTROL.fontARCA,275,390,0,0,8,"RUN GAME",COLOR.BLANCO)
			else
				if OPCIONES.CAMBIO_FUENTE_ON == 1 then	
					Graphics.drawRect(255,390,155,20,COLOR.NEGRO_T)
				end
				Graphics.drawScaleImage(PAD_IMG.R3,230,387,25,25)
				Font.ftPrint(CONTROL.fontARCA,260,390,0,0,8,"UPDATE LIST",COLOR.BLANCO)
			end
		end
		
		-- Dibujar cover y capturas / estilo 5
		Graphics.drawScaleImage(LISTAS.LOGO,CONTROL.LOGO_ANCHO,CONTROL.LOGO_ALTO,252,76)
		Graphics.drawRect(CONTROL.LISTA_ANCHO-3,CONTROL.LISTA_ALTO-3,300+6,115+6,COLOR.NEGRO_T)
		Graphics.drawRect(CONTROL.IMG_ANCHO-5,CONTROL.IMG_ALTO-5,295+10,228+10,COLOR.NEGRO_T)
		Graphics.drawRect(CONTROL.IMG_ANCHO+315,CONTROL.IMG_ALTO-5,295+10,228+10,COLOR.NEGRO_T)
		if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true then
			Graphics.drawScaleImage(LISTAS.SCREENSHOT,CONTROL.IMG_ANCHO+320,CONTROL.IMG_ALTO,295,228)
		else
			if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
				Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+381,CONTROL.IMG_ALTO+92,0,0,8,"-LOADING ART-",COLOR.BLANCO)
			else
				Graphics.drawScaleImage(LISTAS.SCREENSHOT_DEFAULT,CONTROL.IMG_ANCHO+320,CONTROL.IMG_ALTO,295,228,CAMBIOS_EMUS.COLOR_EMU_BACK)
			end
		end
		if LISTAS.SCREENSHOT_ON == true then 
			if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true then
				Graphics.drawScaleImage(LISTAS.SCREENSHOT,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,295,228)
			else
				if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
					Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+61,CONTROL.IMG_ALTO+92,0,0,8,"-LOADING ART-",COLOR.BLANCO)
				else
					Graphics.drawScaleImage(LISTAS.SCREENSHOT_DEFAULT,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,295,228,CAMBIOS_EMUS.COLOR_EMU_BACK)
				end
			end
		else
			if LISTAS.COVER_ART ~= nil and LISTAS.EXISTE_COV == true then
				Graphics.drawScaleImage(LISTAS.COVER_ART,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,295,228)
			else
				if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
					Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+61,CONTROL.IMG_ALTO+92,0,0,8,"-LOADING ART-",COLOR.BLANCO)
				else
					Graphics.drawScaleImage(LISTAS.COVER_DEFAULT,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,295,228,CAMBIOS_EMUS.COLOR_EMU_BACK)
				end
			end
		end
		
	-- Dibujar arte / estilo 6
	elseif CONTROL.ESTILO == 6 and LISTAS.SCREENSHOT_FULL == false then
		if OPCIONES.GUI_LIMPIA_ON == 0 then
			-- Dibujar indicadores para cambio de sistemas
			Graphics.drawScaleImage(PAD_IMG.L1,17,64,32,24)
			Graphics.drawScaleImage(PAD_IMG.R1,305,64,32,24)
		
			-- Dibujar indicadores de menú de configuración y salida de RETROlauncher / estilo 6
			if OPCIONES.CAMBIO_FUENTE_ON == 1 then	
				Graphics.drawRect(55,417,66,20,COLOR.NEGRO_T)
				Graphics.drawRect(242,417,91,20,COLOR.NEGRO_T)
			end
			Graphics.drawScaleImage(PAD_IMG.SELECT_S,22,410,32,32)
			Font.ftPrint(CONTROL.fontARCA,63,417,0,0,8,"EXIT",COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.START,207,410,32,32)
			Font.ftPrint(CONTROL.fontARCA,248,417,0,0,8,"CONFIG",COLOR.BLANCO)
			
			-- Dibujar indicadores de listas / estilo 6
			if #LISTAS.ROMS >= 1 then
				if OPCIONES.CAMBIO_FUENTE_ON == 1 then	
					Graphics.drawRect(52,390,50,20,COLOR.NEGRO_T)
					Graphics.drawRect(272,390,60,20,COLOR.NEGRO_T)
					Graphics.drawRect(162,390,50,20,COLOR.NEGRO_T)
				end
				
				Graphics.drawScaleImage(PAD_IMG.TRIANGLE,22,387,25,25)
				Font.ftPrint(CONTROL.fontARCA,57,390,0,0,8,"ART",COLOR.BLANCO)
				
				Graphics.drawScaleImage(PAD_IMG.SQUARE,242,387,25,25)
				Font.ftPrint(CONTROL.fontARCA,277,390,0,0,8,"FULL",COLOR.BLANCO)
				
				Graphics.drawScaleImage(PAD_IMG.CROSS,132,387,25,25)
				Font.ftPrint(CONTROL.fontARCA,167,390,0,0,8,"RUN",COLOR.BLANCO)
			else
				if OPCIONES.CAMBIO_FUENTE_ON == 1 then	
					Graphics.drawRect(52,390,155,20,COLOR.NEGRO_T)
				end
				Graphics.drawScaleImage(PAD_IMG.R3,22,387,25,25)
				Font.ftPrint(CONTROL.fontARCA,57,390,0,0,8,"UPDATE LIST",COLOR.BLANCO)
			end
		end
		
		-- Dibujar cover y capturas / estilo 6
		Graphics.drawScaleImage(LISTAS.LOGO,CONTROL.LOGO_ANCHO,CONTROL.LOGO_ALTO,252,76)
		Graphics.drawRect(CONTROL.LISTA_ANCHO-3,CONTROL.LISTA_ALTO-3,310+6,290+6,COLOR.NEGRO_T)
		Graphics.drawRect(CONTROL.IMG_ANCHO-5,CONTROL.IMG_ALTO-5,270+10,208+10,COLOR.NEGRO_T)
		Graphics.drawRect(CONTROL.IMG_ANCHO-5,CONTROL.IMG_ALTO+220-5,270+10,208+10,COLOR.NEGRO_T)
		if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true then
			Graphics.drawScaleImage(LISTAS.SCREENSHOT,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO+220,270,208)
		else
			if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
				Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+49,CONTROL.IMG_ALTO+302,0,0,8,"-LOADING ART-",COLOR.BLANCO)
			else
				Graphics.drawScaleImage(LISTAS.SCREENSHOT_DEFAULT,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO+220,270,208,CAMBIOS_EMUS.COLOR_EMU_BACK)
			end
		end
		if LISTAS.SCREENSHOT_ON == true then 
			if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true then
				Graphics.drawScaleImage(LISTAS.SCREENSHOT,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,270,208)
			else
				if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
					Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+49,CONTROL.IMG_ALTO+82,0,0,8,"-LOADING ART-",COLOR.BLANCO)
				else
					Graphics.drawScaleImage(LISTAS.SCREENSHOT_DEFAULT,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,270,208,CAMBIOS_EMUS.COLOR_EMU_BACK)
				end
			end
		else
			if LISTAS.COVER_ART ~= nil and LISTAS.EXISTE_COV == true then
				Graphics.drawScaleImage(LISTAS.COVER_ART,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,270,208)
			else
				if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
					Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+49,CONTROL.IMG_ALTO+82,0,0,8,"-LOADING ART-",COLOR.BLANCO)
				else
					Graphics.drawScaleImage(LISTAS.COVER_DEFAULT,CONTROL.IMG_ANCHO,CONTROL.IMG_ALTO,270,208,CAMBIOS_EMUS.COLOR_EMU_BACK)
				end
			end
		end
	end
end

--- Líneas para crear y moverse por las listas
-----------------------------------------------------------------------------------------
function Generar_Listas()
	-- Control de listas
	tiempo_cargar()
	tiempo_de_scroll()
	tiempo_arte()
	if CONTROL.TIEMPO > 1100 then
		Timer.reset(CONTROL.TIME)
		tiempo_cargar()
	end
	capturar(JOYSTICK_LIMITE)

	--- Líneas para mostrar las listas / estilo 1 / estilo 4 / estilo 6
	-----------------------------------------------------------------------------------------
	if CONTROL.ESTILO == 1 or CONTROL.ESTILO == 4 or CONTROL.ESTILO == 6 then
		if #LISTAS.ROMS >= 1 then
			-- Correcciones del estilo / estilo 1 / estilo 4 / estilo 6
			local largo_fix = 0
			if CONTROL.ESTILO == 4 then
				largo_fix = 20
			elseif CONTROL.ESTILO == 6 then
				largo_fix = 6
			end
		
			-- Controlar Scroll de texto / estilo 1 / estilo 4 / estilo 6
			if CONTROL.ESPERA_CARGA_SCR == false then
				LISTAS.SCROLL_TEX = scroll_texto(LISTAS.SCROLL_TEX,string.sub(LISTAS.ROMS[LISTAS.INDICE],1,- CONTROL.EXTENSION),24)
			end
			
			-- Mostrar listas de juegos / estilo 1 / estilo 4 / estilo 6
			local mostrar_lista = 0
			if LISTAS.SCREENSHOT_FULL == false then
				for contador = 0,11,1 do
					local espacio_linea = 90+((contador)*24)
					if contador == 0 then
						Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+3,espacio_linea,0,310-3,2,string.sub(LISTAS.ROMS[LISTAS.INDICE],LISTAS.SCROLL_TEX,-CONTROL.EXTENSION),CAMBIOS_EMUS.COLOR_EMU)
					elseif (LISTAS.INDICE+contador) <= #LISTAS.ROMS then
						Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+3,espacio_linea,0,310-3,2,string.sub(LISTAS.ROMS[LISTAS.INDICE+contador],1,-CONTROL.EXTENSION),COLOR.BLANCO_LISTA)
					elseif mostrar_lista <= #LISTAS.ROMS-1 and #LISTAS.ROMS >= 12 then
						mostrar_lista = mostrar_lista+1
						Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+3,espacio_linea,0,310-3,2,string.sub(LISTAS.ROMS[mostrar_lista],1,-CONTROL.EXTENSION),COLOR.BLANCO_LISTA)
					end
				end
			end
			
			-- Cargar arte / estilo 1 / estilo 4 / estilo 6
			cargar_art()
			
			--- Líneas para moverse en las listas / estilo 1 / estilo 4 / estilo 6
			-----------------------------------------------------------------------------------------
			if Pads.check(PAD,PAD_DOWN) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE <= (#LISTAS.ROMS-1) then
					LISTAS.INDICE = LISTAS.INDICE+1
				else
					LISTAS.INDICE = 1
				end
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS
				if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.MOVER ~= nil then
					Sound.playADPCM(1,MENU_SONIDOS.MOVER)
				end
				if OPCIONES.VIBRATION_ON == 1 then
					Pads.rumble(255,1)
				end
			elseif Pads.check(PAD,PAD_UP) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE >= 2 then
					LISTAS.INDICE = LISTAS.INDICE-1
				else
					LISTAS.INDICE = #LISTAS.ROMS
				end
				CONTROL.JOYSTICK_ON = true 
				JOYSTICK_LIMITE = control_FPS(1) 
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS
				if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.MOVER ~= nil then
					Sound.playADPCM(1,MENU_SONIDOS.MOVER)
				end
				if OPCIONES.VIBRATION_ON == 1 then
					Pads.rumble(1,255)
				end
			elseif Pads.check(PAD,PAD_R2) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE <= (#LISTAS.ROMS-11) then
					LISTAS.INDICE = LISTAS.INDICE+11
				else
					LISTAS.INDICE = 1
				end
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS	
				if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.MOVER ~= nil then
					Sound.playADPCM(1,MENU_SONIDOS.MOVER)
				end
				if OPCIONES.VIBRATION_ON == 1 then
					Pads.rumble(255,1)
				end
			elseif Pads.check(PAD,PAD_L2) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE >= 12 then
					LISTAS.INDICE = LISTAS.INDICE-11
				else
					LISTAS.INDICE = #LISTAS.ROMS
				end
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS
				if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.MOVER ~= nil then
					Sound.playADPCM(1,MENU_SONIDOS.MOVER)
				end
				if OPCIONES.VIBRATION_ON == 1 then
					Pads.rumble(1,255)
				end
			elseif Pads.check(PAD,PAD_RIGHT) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE <= (#LISTAS.ROMS-1) then
					LISTAS.INDICE = LISTAS.INDICE+1
				else
					LISTAS.INDICE = 1
				end
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				JOYSTICK_LIMITE = control_FPS(2)
				CONTROL.JOYSTICK_ON = true
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS
			elseif Pads.check(PAD,PAD_LEFT) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE-1 >= 2 then
					LISTAS.INDICE = LISTAS.INDICE-1
				else
					LISTAS.INDICE = #LISTAS.ROMS
				end
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				JOYSTICK_LIMITE = control_FPS(2)
				CONTROL.JOYSTICK_ON = true
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS
				
			-- Ejecutar juego / estilo 1 / estilo 4 / estilo 6
			elseif Pads.check(PAD,PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
				-- Verificar archivos / estilo 1 / estilo 4 / estilo 6
				local alt = false
				if Pads.check(PAD,PAD_CIRCLE) and (LISTAS.IDENTIDAD == 1 or LISTAS.IDENTIDAD == 4) then
					alt = true
				end
				local verificar = existe(LISTAS.IDENTIDAD,LISTAS.ROMS[LISTAS.INDICE],alt)
				if verificar == true then
					if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.EJECUTAR ~= nil then
						Sound.playADPCM(1,MENU_SONIDOS.EJECUTAR)
					end
					ejecutar_juego(LISTAS.IDENTIDAD,LISTAS.ROMS[LISTAS.INDICE],alt)
				else
					if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.ERROR ~= nil then
						Sound.playADPCM(1,MENU_SONIDOS.ERROR)
					end
					CONTROL.JOYSTICK_ON = true
					JOYSTICK_LIMITE = control_FPS(1)
					local pausar = true
					while pausar do -- Mostrar error de carga / estilo 1 / estilo 4 / estilo 6
						capturar(JOYSTICK_LIMITE)
						Graphics.drawRect(CONTROL.LISTA_ANCHO-3,CONTROL.LISTA_ALTO-3,310+6,290+6,COLOR.NEGRO)
						if LISTAS.IDENTIDAD ~= 8 and LISTAS.IDENTIDAD ~= 13 and LISTAS.IDENTIDAD ~= 14 then
							Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+40,CONTROL.LISTA_ALTO+90,0,310,290,"      ERROR\nNO GAMES/RETROARCH\n      FOUND",COLOR.BLANCO)
							LISTAS.SCREENSHOT_FULL = false
						elseif LISTAS.IDENTIDAD == 8 then
							Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+44,CONTROL.LISTA_ALTO+90,0,310,290,"      ERROR\nNO POPS /BINARIES \n  NO GAMES FOUND  ",COLOR.BLANCO)
							LISTAS.SCREENSHOT_FULL = false
						elseif LISTAS.IDENTIDAD == 13 then
							Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+40,CONTROL.LISTA_ALTO+90,0,310,290,"      ERROR\nNO APPLICATION/ELF\n      FOUND",COLOR.BLANCO)
							LISTAS.SCREENSHOT_FULL = false
						elseif LISTAS.IDENTIDAD == 14 then
							Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+40,CONTROL.LISTA_ALTO+90,0,310,290,"      ERROR\nNO NEUTRINO OR ISO\n      FOUND",COLOR.BLANCO)
							LISTAS.SCREENSHOT_FULL = false
						end
						Graphics.drawScaleImage(PAD_IMG.CIRCLE,134-largo_fix,240,20,20)
						Font.ftPrint(CONTROL.fontARCA,169-largo_fix,240,0,0,8,"BACK",COLOR.BLANCO)
						if Pads.check(PAD,PAD_CIRCLE) and CONTROL.JOYSTICK_ON == false then
							if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.CANCELAR ~= nil then
								Sound.playADPCM(1,MENU_SONIDOS.CANCELAR)
							end
							if OPCIONES.VIBRATION_ON == 1 then
								Pads.rumble(255,255)
							end
							pausar = false
							CONTROL.JOYSTICK_ON = true 
							JOYSTICK_LIMITE = control_FPS(1)
						end
						refrescar()
					end
				end
			end	
			-----------------------------------------------------------------------------------------
			
		-- Mostrar listas vacías / estilo 1 / estilo 4
		else
			Graphics.drawRect(CONTROL.LISTA_ANCHO-3,CONTROL.LISTA_ALTO-3,310+6,290+6,COLOR.NEGRO_T)
			if CONTROL.ESTILO == 4 then
				Graphics.drawRect(CONTROL.IMG_ANCHO-5,CONTROL.IMG_ALTO-5,295+10,228+10,COLOR.NEGRO_T)
			elseif CONTROL.ESTILO == 6 then
				Graphics.drawRect(CONTROL.IMG_ANCHO-5,CONTROL.IMG_ALTO-5,270+10,208+10,COLOR.NEGRO_T)
				Graphics.drawRect(CONTROL.IMG_ANCHO-5,CONTROL.IMG_ALTO+220-5,270+10,208+10,COLOR.NEGRO_T)
			else
				Graphics.drawRect(CONTROL.IMG_ANCHO-5,CONTROL.IMG_ALTO-5,250+10,193+10,COLOR.NEGRO_T)
			end
			Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+64,180,0,0,8,"NO GAMES FOUND",COLOR.BLANCO)
		end
	
	--- Líneas para mostrar las listas / estilo 2
	-----------------------------------------------------------------------------------------
	elseif CONTROL.ESTILO == 2 then
		if #LISTAS.ROMS >= 1 then
			-- Controlar Scroll de texto / estilo 2
			if CONTROL.ESPERA_CARGA_SCR == false then
				LISTAS.SCROLL_TEX = scroll_texto(LISTAS.SCROLL_TEX,string.sub(LISTAS.ROMS[LISTAS.INDICE],1,- CONTROL.EXTENSION),24)
			end
			
			-- Mostrar listas de juegos / estilo 2
			if LISTAS.SCREENSHOT_FULL == false then
				-- Mostrar arte centro / estilo 2
				Graphics.drawRect(164,CONTROL.IMG_ALTO+218,311,25,COLOR.NEGRO_T)
				Font.ftPrint(CONTROL.fontARCA,169,CONTROL.IMG_ALTO+220,0,307,2,string.sub(LISTAS.ROMS[LISTAS.INDICE],LISTAS.SCROLL_TEX,-CONTROL.EXTENSION),CAMBIOS_EMUS.COLOR_EMU)
				-- Mostrar arte izquierda / estilo 2
				Graphics.drawRect(CONTROL.IMG_ANCHO-180,CONTROL.IMG_ALTO+158,160,25,COLOR.NEGRO_T)
				Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO-175,CONTROL.IMG_ALTO+160,0,150,2,string.sub(LISTAS.ROMS[LISTAS.INDICE2],1,-CONTROL.EXTENSION),COLOR.BLANCO_LISTA)
				-- Mostrar arte derecha / estilo 2
				Graphics.drawRect(CONTROL.IMG_ANCHO+270,CONTROL.IMG_ALTO+158,160,25,COLOR.NEGRO_T)
				Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+275,CONTROL.IMG_ALTO+160,0,150,2,string.sub(LISTAS.ROMS[LISTAS.INDICE3],1,-CONTROL.EXTENSION),COLOR.BLANCO_LISTA)
			end
			
			-- Cargar arte / estilo 2
			cargar_art()
			
			--- Líneas para moverse en las listas / estilo 2
			-----------------------------------------------------------------------------------------
			if (Pads.check(PAD,PAD_RIGHT) or Pads.check(PAD,PAD_DOWN)) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE <= (#LISTAS.ROMS-1) then
					LISTAS.INDICE = LISTAS.INDICE+1
				else
					LISTAS.INDICE = 1
				end
				indices_extras()
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS
				if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.MOVER ~= nil then
					Sound.playADPCM(1,MENU_SONIDOS.MOVER)
				end
				if OPCIONES.VIBRATION_ON == 1 then
					Pads.rumble(255,1)
				end
			elseif (Pads.check(PAD,PAD_LEFT) or Pads.check(PAD,PAD_UP)) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE >= 2 then
					LISTAS.INDICE = LISTAS.INDICE-1
				else
					LISTAS.INDICE = #LISTAS.ROMS
				end
				indices_extras()
				CONTROL.JOYSTICK_ON = true 
				JOYSTICK_LIMITE = control_FPS(1) 
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS
				if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.MOVER ~= nil then
					Sound.playADPCM(1,MENU_SONIDOS.MOVER)
				end
				if OPCIONES.VIBRATION_ON == 1 then
					Pads.rumble(1,255)
				end
			elseif Pads.check(PAD,PAD_R2) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE <= (#LISTAS.ROMS-1) then
					LISTAS.INDICE = LISTAS.INDICE+1
				else
					LISTAS.INDICE = 1
				end
				indices_extras()
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				JOYSTICK_LIMITE = control_FPS(2)
				CONTROL.JOYSTICK_ON = true
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS
			elseif Pads.check(PAD,PAD_L2) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE-1 >= 2 then
					LISTAS.INDICE = LISTAS.INDICE-1
				else
					LISTAS.INDICE = #LISTAS.ROMS
				end
				indices_extras()
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				JOYSTICK_LIMITE = control_FPS(2)
				CONTROL.JOYSTICK_ON = true
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS
				
			-- Ejecutar juego / estilo 2
			elseif Pads.check(PAD,PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
				-- Verificar archivos / estilo 2
				local alt = false
				if Pads.check(PAD,PAD_CIRCLE) and (LISTAS.IDENTIDAD == 1 or LISTAS.IDENTIDAD == 4) then
					alt = true
				end
				local verificar = existe(LISTAS.IDENTIDAD,LISTAS.ROMS[LISTAS.INDICE],alt)
				if verificar == true then
					if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.EJECUTAR ~= nil then
						Sound.playADPCM(1,MENU_SONIDOS.EJECUTAR)
					end
					ejecutar_juego(LISTAS.IDENTIDAD,LISTAS.ROMS[LISTAS.INDICE],alt)
				else
					if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.ERROR ~= nil then
						Sound.playADPCM(1,MENU_SONIDOS.ERROR)
					end
					CONTROL.JOYSTICK_ON = true
					JOYSTICK_LIMITE = control_FPS(1)
					local pausar = true
					while pausar do -- Mostrar error de carga / estilo 2
						capturar(JOYSTICK_LIMITE)
						Graphics.drawRect(CONTROL.IMG_ANCHO-5,CONTROL.IMG_ALTO-5,250+10,193+10,COLOR.NEGRO)
						if LISTAS.IDENTIDAD ~= 8 and LISTAS.IDENTIDAD ~= 13 and LISTAS.IDENTIDAD ~= 14 then
							Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+10,170,0,310,290,"      ERROR\nNO GAMES/RETROARCH\n      FOUND",COLOR.BLANCO)
							LISTAS.SCREENSHOT_FULL = false
						elseif LISTAS.IDENTIDAD == 8 then
							Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+14,170,0,310,290,"      ERROR\nNO POPS /BINARIES \n  NO GAMES FOUND  ",COLOR.BLANCO)
							LISTAS.SCREENSHOT_FULL = false
						elseif LISTAS.IDENTIDAD == 13 then
							Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+10,170,0,310,290,"      ERROR\nNO APPLICATION/ELF\n      FOUND",COLOR.BLANCO)
							LISTAS.SCREENSHOT_FULL = false
						elseif LISTAS.IDENTIDAD == 14 then
							Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+10,170,0,310,290,"      ERROR\nNO NEUTRINO OR ISO\n      FOUND",COLOR.BLANCO)
							LISTAS.SCREENSHOT_FULL = false
							Graphics.drawRect(CONTROL.LISTA_ANCHO+134,CONTROL.LISTA_ALTO+258,311,26,COLOR.NEGRO)
						end
						Graphics.drawRect(164,CONTROL.IMG_ALTO+218,311,25,COLOR.NEGRO)
						Graphics.drawScaleImage(PAD_IMG.CIRCLE,269,228,20,20)
						Font.ftPrint(CONTROL.fontARCA,304,228,0,0,8,"BACK",COLOR.BLANCO)
						if Pads.check(PAD,PAD_CIRCLE) and CONTROL.JOYSTICK_ON == false then
							if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.CANCELAR ~= nil then
								Sound.playADPCM(1,MENU_SONIDOS.CANCELAR)
							end
							if OPCIONES.VIBRATION_ON == 1 then
								Pads.rumble(255,255)
							end
							pausar = false
							CONTROL.JOYSTICK_ON = true 
							JOYSTICK_LIMITE = control_FPS(1)
						end
						refrescar()
					end
				end
			end
			-----------------------------------------------------------------------------------------
			
		-- Mostrar listas vacías / estilo 2
		else
			Graphics.drawRect(CONTROL.IMG_ANCHO-5,CONTROL.IMG_ALTO-5,250+10,193+10,COLOR.NEGRO)
			Graphics.drawRect(CONTROL.IMG_ANCHO-180-5,CONTROL.IMG_ALTO+40-5,160+10,103+10,COLOR.NEGRO_T)
			Graphics.drawRect(CONTROL.IMG_ANCHO+270-5,CONTROL.IMG_ALTO+40-5,160+10,103+10,COLOR.NEGRO_T)
			Font.ftPrint(CONTROL.fontARCA,CONTROL.IMG_ANCHO+34,180,0,0,8,"NO GAMES FOUND",COLOR.BLANCO)
		end
	
	--- Líneas para mostrar las listas / estilo 3
	-----------------------------------------------------------------------------------------
	elseif CONTROL.ESTILO == 3 then
		-- Correcciones del estilo / estilo 3
		local largo = 310
		local largo_fix = 0
		if OPCIONES.GUI_LIMPIA_ON == 1 then
			largo = 544
			largo_fix = 118
		end
			
		if #LISTAS.ROMS >= 1 then
			-- Controlar Scroll de texto / estilo 3
			if CONTROL.ESPERA_CARGA_SCR == false then
				if OPCIONES.GUI_LIMPIA_ON == 1 then
					LISTAS.SCROLL_TEX = scroll_texto(LISTAS.SCROLL_TEX,string.sub(LISTAS.ROMS[LISTAS.INDICE],1,- CONTROL.EXTENSION),42)
				else
					LISTAS.SCROLL_TEX = scroll_texto(LISTAS.SCROLL_TEX,string.sub(LISTAS.ROMS[LISTAS.INDICE],1,-CONTROL.EXTENSION),24)
				end
			end
			
			-- Mostrar listas de juegos / estilo 3
			local mostrar_lista = 0
			if LISTAS.SCREENSHOT_FULL == false then
				for contador = 0,5,1 do
					local espacio_linea = CONTROL.LISTA_ALTO+((contador)*24)
					if contador == 0 then
						Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+3,espacio_linea,0,largo-3,2,string.sub(LISTAS.ROMS[LISTAS.INDICE],LISTAS.SCROLL_TEX,-CONTROL.EXTENSION),CAMBIOS_EMUS.COLOR_EMU)
					elseif (LISTAS.INDICE+contador) <= #LISTAS.ROMS then
						Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+3,espacio_linea,0,largo-3,2,string.sub(LISTAS.ROMS[LISTAS.INDICE+contador],1,-CONTROL.EXTENSION),COLOR.BLANCO_LISTA)
					elseif mostrar_lista <= #LISTAS.ROMS-1 and #LISTAS.ROMS >= 6 then
						mostrar_lista = mostrar_lista+1
						Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+3,espacio_linea,0,largo-3,2,string.sub(LISTAS.ROMS[mostrar_lista],1,-CONTROL.EXTENSION),COLOR.BLANCO_LISTA)
					end
					if contador == 3 then
						Graphics.drawRect(CONTROL.LISTA_ANCHO-3,espacio_linea-3,largo+2,25,Color.new(0,0,0,30))
					end
					if contador == 4 then
						Graphics.drawRect(CONTROL.LISTA_ANCHO-3,espacio_linea-3,largo+2,25,Color.new(0,0,0,40))
					end
					if contador == 5 then
						Graphics.drawRect(CONTROL.LISTA_ANCHO-3,espacio_linea-3,largo+2,25,Color.new(0,0,0,60))
					end
				end
			end
			
			-- Cargar arte / estilo 3
			cargar_art()
			
			--- Líneas para moverse en las listas / estilo 3
			-----------------------------------------------------------------------------------------
			if Pads.check(PAD,PAD_DOWN) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE <= (#LISTAS.ROMS-1) then
					LISTAS.INDICE = LISTAS.INDICE+1
				else
					LISTAS.INDICE = 1
				end
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS
				if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.MOVER ~= nil then
					Sound.playADPCM(1,MENU_SONIDOS.MOVER)
				end
				if OPCIONES.VIBRATION_ON == 1 then
					Pads.rumble(255,1)
				end
			elseif Pads.check(PAD,PAD_UP) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE >= 2 then
					LISTAS.INDICE = LISTAS.INDICE-1
				else
					LISTAS.INDICE = #LISTAS.ROMS
				end
				CONTROL.JOYSTICK_ON = true 
				JOYSTICK_LIMITE = control_FPS(1) 
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS
				if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.MOVER ~= nil then
					Sound.playADPCM(1,MENU_SONIDOS.MOVER)
				end
				if OPCIONES.VIBRATION_ON == 1 then
					Pads.rumble(1,255)
				end
			elseif Pads.check(PAD,PAD_R2) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE <= (#LISTAS.ROMS-11) then
					LISTAS.INDICE = LISTAS.INDICE+11
				else
					LISTAS.INDICE = 1
				end
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS	
				if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.MOVER ~= nil then
					Sound.playADPCM(1,MENU_SONIDOS.MOVER)
				end
				if OPCIONES.VIBRATION_ON == 1 then
					Pads.rumble(255,1)
				end
			elseif Pads.check(PAD,PAD_L2) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE >= 12 then
					LISTAS.INDICE = LISTAS.INDICE-11
				else
					LISTAS.INDICE = #LISTAS.ROMS
				end
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS
				if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.MOVER ~= nil then
					Sound.playADPCM(1,MENU_SONIDOS.MOVER)
				end
				if OPCIONES.VIBRATION_ON == 1 then
					Pads.rumble(1,255)
				end
			elseif Pads.check(PAD,PAD_RIGHT) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE <= (#LISTAS.ROMS-1) then
					LISTAS.INDICE = LISTAS.INDICE+1
				else
					LISTAS.INDICE = 1
				end
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				JOYSTICK_LIMITE = control_FPS(2)
				CONTROL.JOYSTICK_ON = true
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS
			elseif Pads.check(PAD,PAD_LEFT) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE-1 >= 2 then
					LISTAS.INDICE = LISTAS.INDICE-1
				else
					LISTAS.INDICE = #LISTAS.ROMS
				end
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				JOYSTICK_LIMITE = control_FPS(2)
				CONTROL.JOYSTICK_ON = true
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS
				
			-- Ejecutar juego / estilo 3
			elseif Pads.check(PAD,PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
				-- Verificar archivos / estilo 3
				local alt = false
				if Pads.check(PAD,PAD_CIRCLE) and (LISTAS.IDENTIDAD == 1 or LISTAS.IDENTIDAD == 4) then
					alt = true
				end
				local verificar = existe(LISTAS.IDENTIDAD,LISTAS.ROMS[LISTAS.INDICE],alt)
				if verificar == true then
					if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.EJECUTAR ~= nil then
						Sound.playADPCM(1,MENU_SONIDOS.EJECUTAR)
					end
					ejecutar_juego(LISTAS.IDENTIDAD,LISTAS.ROMS[LISTAS.INDICE],alt)
				else
					if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.ERROR ~= nil then
						Sound.playADPCM(1,MENU_SONIDOS.ERROR)
					end
					CONTROL.JOYSTICK_ON = true
					JOYSTICK_LIMITE = control_FPS(1)
					local pausar = true
					while pausar do -- Mostrar error de carga / estilo 3 
						capturar(JOYSTICK_LIMITE)
						Graphics.drawRect(CONTROL.LISTA_ANCHO-3,CONTROL.LISTA_ALTO-3,largo+6,137+6,COLOR.NEGRO)
						if LISTAS.IDENTIDAD ~= 8 and LISTAS.IDENTIDAD ~= 13 and LISTAS.IDENTIDAD ~= 14 then
							Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+40+largo_fix,CONTROL.LISTA_ALTO+20,0,310,290,"      ERROR\nNO GAMES/RETROARCH\n      FOUND",COLOR.BLANCO)
							LISTAS.SCREENSHOT_FULL = false
						elseif LISTAS.IDENTIDAD == 8 then
							Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+44+largo_fix,CONTROL.LISTA_ALTO+20,0,310,290,"      ERROR\nNO POPS /BINARIES \n  NO GAMES FOUND  ",COLOR.BLANCO)
							LISTAS.SCREENSHOT_FULL = false
						elseif LISTAS.IDENTIDAD == 13 then
							Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+40+largo_fix,CONTROL.LISTA_ALTO+20,0,310,290,"      ERROR\nNO APPLICATION/ELF\n      FOUND",COLOR.BLANCO)
							LISTAS.SCREENSHOT_FULL = false
						elseif LISTAS.IDENTIDAD == 14 then
							Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+40+largo_fix,CONTROL.LISTA_ALTO+20,0,310,290,"      ERROR\nNO NEUTRINO OR ISO\n      FOUND",COLOR.BLANCO)
							LISTAS.SCREENSHOT_FULL = false
						end
						Graphics.drawScaleImage(PAD_IMG.CIRCLE,152+largo_fix,378,20,20)
						Font.ftPrint(CONTROL.fontARCA,188+largo_fix,378,0,0,8,"BACK",COLOR.BLANCO)
						if Pads.check(PAD,PAD_CIRCLE) and CONTROL.JOYSTICK_ON == false then
							if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.CANCELAR ~= nil then
								Sound.playADPCM(1,MENU_SONIDOS.CANCELAR)
							end
							if OPCIONES.VIBRATION_ON == 1 then
								Pads.rumble(255,255)
							end
							pausar = false
							CONTROL.JOYSTICK_ON = true 
							JOYSTICK_LIMITE = control_FPS(1)
						end
						refrescar()
					end
				end
			end	
			-----------------------------------------------------------------------------------------
			
		-- Mostrar listas vacías / estilo 3
		else
			Graphics.drawRect(CONTROL.LISTA_ANCHO-3,CONTROL.LISTA_ALTO-3,largo+6,137+6,COLOR.NEGRO)
			Graphics.drawRect(CONTROL.IMG_ANCHO-5,CONTROL.IMG_ALTO-5,250+10,193+10,COLOR.NEGRO_T)
			Graphics.drawRect(CONTROL.LISTA_ANCHO-5,CONTROL.IMG_ALTO-5,250+10,193+10,COLOR.NEGRO_T)
			Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+64+largo_fix,360,0,0,8,"NO GAMES FOUND",COLOR.BLANCO)
		end
		
	--- Líneas para mostrar las listas / estilo 5
	-----------------------------------------------------------------------------------------
	elseif CONTROL.ESTILO == 5 then
		if #LISTAS.ROMS >= 1 then
			-- Controlar Scroll de texto / estilo 5
			if CONTROL.ESPERA_CARGA_SCR == false then
				LISTAS.SCROLL_TEX = scroll_texto(LISTAS.SCROLL_TEX,string.sub(LISTAS.ROMS[LISTAS.INDICE],1,-CONTROL.EXTENSION),23)
			end
			
			-- Mostrar listas de juegos / estilo 5
			local mostrar_lista = 0
			if LISTAS.SCREENSHOT_FULL == false then
				for contador = 0,4,1 do
					local espacio_linea = CONTROL.LISTA_ALTO+((contador)*24)
					if contador == 0 then
						Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+3,espacio_linea,0,300-3,2,string.sub(LISTAS.ROMS[LISTAS.INDICE],LISTAS.SCROLL_TEX,-CONTROL.EXTENSION),CAMBIOS_EMUS.COLOR_EMU)
					elseif (LISTAS.INDICE+contador) <= #LISTAS.ROMS then
						Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+3,espacio_linea,0,300-3,2,string.sub(LISTAS.ROMS[LISTAS.INDICE+contador],1,-CONTROL.EXTENSION),COLOR.BLANCO_LISTA)
					elseif mostrar_lista <= #LISTAS.ROMS-1 and #LISTAS.ROMS >= 5 then
						mostrar_lista = mostrar_lista+1
						Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+3,espacio_linea,0,300-3,2,string.sub(LISTAS.ROMS[mostrar_lista],1,-CONTROL.EXTENSION),COLOR.BLANCO_LISTA)
					end
					if contador == 2 then
						Graphics.drawRect(CONTROL.LISTA_ANCHO-3,espacio_linea-3,302,25,Color.new(0,0,0,30))
					end
					if contador == 3 then
						Graphics.drawRect(CONTROL.LISTA_ANCHO-3,espacio_linea-3,302,25,Color.new(0,0,0,40))
					end
					if contador == 4 then
						Graphics.drawRect(CONTROL.LISTA_ANCHO-3,espacio_linea-3,302,25,Color.new(0,0,0,60))
					end
				end
			end
			
			-- Cargar arte / estilo 5
			cargar_art()
			
			--- Líneas para moverse en las listas / estilo 5
			-----------------------------------------------------------------------------------------
			if Pads.check(PAD,PAD_DOWN) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE <= (#LISTAS.ROMS-1) then
					LISTAS.INDICE = LISTAS.INDICE+1
				else
					LISTAS.INDICE = 1
				end
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS
				if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.MOVER ~= nil then
					Sound.playADPCM(1,MENU_SONIDOS.MOVER)
				end
				if OPCIONES.VIBRATION_ON == 1 then
					Pads.rumble(255,1)
				end
			elseif Pads.check(PAD,PAD_UP) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE >= 2 then
					LISTAS.INDICE = LISTAS.INDICE-1
				else
					LISTAS.INDICE = #LISTAS.ROMS
				end
				CONTROL.JOYSTICK_ON = true 
				JOYSTICK_LIMITE = control_FPS(1) 
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS
				if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.MOVER ~= nil then
					Sound.playADPCM(1,MENU_SONIDOS.MOVER)
				end
				if OPCIONES.VIBRATION_ON == 1 then
					Pads.rumble(1,255)
				end
			elseif Pads.check(PAD,PAD_R2) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE <= (#LISTAS.ROMS-11) then
					LISTAS.INDICE = LISTAS.INDICE+11
				else
					LISTAS.INDICE = 1
				end
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS	
				if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.MOVER ~= nil then
					Sound.playADPCM(1,MENU_SONIDOS.MOVER)
				end
				if OPCIONES.VIBRATION_ON == 1 then
					Pads.rumble(255,1)
				end
			elseif Pads.check(PAD,PAD_L2) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE >= 12 then
					LISTAS.INDICE = LISTAS.INDICE-11
				else
					LISTAS.INDICE = #LISTAS.ROMS
				end
				CONTROL.JOYSTICK_ON = true
				JOYSTICK_LIMITE = control_FPS(1)
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS
				if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.MOVER ~= nil then
					Sound.playADPCM(1,MENU_SONIDOS.MOVER)
				end
				if OPCIONES.VIBRATION_ON == 1 then
					Pads.rumble(1,255)
				end
			elseif Pads.check(PAD,PAD_RIGHT) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE <= (#LISTAS.ROMS-1) then
					LISTAS.INDICE = LISTAS.INDICE+1
				else
					LISTAS.INDICE = 1
				end
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				JOYSTICK_LIMITE = control_FPS(2)
				CONTROL.JOYSTICK_ON = true
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS
			elseif Pads.check(PAD,PAD_LEFT) and CONTROL.JOYSTICK_ON == false then
				if LISTAS.INDICE-1 >= 2 then
					LISTAS.INDICE = LISTAS.INDICE-1
				else
					LISTAS.INDICE = #LISTAS.ROMS
				end
				LISTAS.SCROLL_TEX = 1
				reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
				JOYSTICK_LIMITE = control_FPS(2)
				CONTROL.JOYSTICK_ON = true
				LISTAS.SCREENSHOT_ON = false
				limpiar_art()
				LISTAS.MOSTRAR = 0-CONTROL.FPS
				
			-- Ejecutar juego / estilo 5
			elseif Pads.check(PAD,PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
				-- Verificar archivos / estilo 5
				local alt = false
				if Pads.check(PAD,PAD_CIRCLE) and (LISTAS.IDENTIDAD == 1 or LISTAS.IDENTIDAD == 4) then
					alt = true
				end
				local verificar = existe(LISTAS.IDENTIDAD,LISTAS.ROMS[LISTAS.INDICE],alt)
				if verificar == true then
					if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.EJECUTAR ~= nil then
						Sound.playADPCM(1,MENU_SONIDOS.EJECUTAR)
					end
					ejecutar_juego(LISTAS.IDENTIDAD,LISTAS.ROMS[LISTAS.INDICE],alt)
				else
					if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.ERROR ~= nil then
						Sound.playADPCM(1,MENU_SONIDOS.ERROR)
					end
					CONTROL.JOYSTICK_ON = true
					JOYSTICK_LIMITE = control_FPS(1)
					local pausar = true
					while pausar do -- Mostrar error de carga / estilo 5
						capturar(JOYSTICK_LIMITE)
						Graphics.drawRect(CONTROL.LISTA_ANCHO-3,CONTROL.LISTA_ALTO-3,300+6,115+6,COLOR.NEGRO)
						if LISTAS.IDENTIDAD ~= 8 and LISTAS.IDENTIDAD ~= 13 and LISTAS.IDENTIDAD ~= 14 then
							Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+32,CONTROL.LISTA_ALTO+20,0,300,290,"      ERROR\nNO GAMES/RETROARCH\n      FOUND",COLOR.BLANCO)
							LISTAS.SCREENSHOT_FULL = false
						elseif LISTAS.IDENTIDAD == 8 then
							Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+36,CONTROL.LISTA_ALTO+20,0,300,290,"      ERROR\nNO POPS /BINARIES \n  NO GAMES FOUND  ",COLOR.BLANCO)
							LISTAS.SCREENSHOT_FULL = false
						elseif LISTAS.IDENTIDAD == 13 then
							Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+32,CONTROL.LISTA_ALTO+20,0,300,290,"      ERROR\nNO APPLICATION/ELF\n      FOUND",COLOR.BLANCO)
							LISTAS.SCREENSHOT_FULL = false
						elseif LISTAS.IDENTIDAD == 14 then
							Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+32,CONTROL.LISTA_ALTO+20,0,300,290,"      ERROR\nNO NEUTRINO OR ISO\n      FOUND",COLOR.BLANCO)
							LISTAS.SCREENSHOT_FULL = false
						end
						Graphics.drawScaleImage(PAD_IMG.CIRCLE,106,340,20,20)
						Font.ftPrint(CONTROL.fontARCA,142,340,0,0,8,"BACK",COLOR.BLANCO)
						if Pads.check(PAD,PAD_CIRCLE) and CONTROL.JOYSTICK_ON == false then
							if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.CANCELAR ~= nil then
								Sound.playADPCM(1,MENU_SONIDOS.CANCELAR)
							end
							if OPCIONES.VIBRATION_ON == 1 then
								Pads.rumble(255,255)
							end
							pausar = false
							CONTROL.JOYSTICK_ON = true 
							JOYSTICK_LIMITE = control_FPS(1)
						end
						refrescar()
					end
				end
			end	
			-----------------------------------------------------------------------------------------
			
		-- Mostrar listas vacías / estilo 5
		else
			Graphics.drawRect(CONTROL.LISTA_ANCHO-3,CONTROL.LISTA_ALTO-3,300+6,115+6,COLOR.NEGRO)
			Graphics.drawRect(CONTROL.IMG_ANCHO-5,CONTROL.IMG_ALTO-5,295+10,228+10,COLOR.NEGRO_T)
			Graphics.drawRect(CONTROL.IMG_ANCHO+315,CONTROL.IMG_ALTO-5,295+10,228+10,COLOR.NEGRO_T)
			Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+60,305,0,0,8,"NO GAMES FOUND",COLOR.BLANCO)
		end
	end
	
	-- Mostrar Menú de Configuración PS2
	if #LISTAS.ROMS >= 1 and LISTAS.IDENTIDAD == 14 then
		local fix_ps2_pos1 = 0
		local fix_ps2_pos2 = 0
		local fix_ps2_cen = 0
		local fix_ps2_lag = 0
		if CONTROL.ESTILO == 1 then
			fix_ps2_pos1 = 270
			fix_ps2_cen = 46
		elseif CONTROL.ESTILO == 2 then
			fix_ps2_pos1 = 262
			fix_ps2_pos2 = 137
			fix_ps2_cen = 46
			fix_ps2_lag = 4
		elseif CONTROL.ESTILO == 3 then
			fix_ps2_pos1 = 118
			fix_ps2_cen = 46
		elseif CONTROL.ESTILO == 4 then
			fix_ps2_pos1 = 270
			fix_ps2_cen = 46
		elseif CONTROL.ESTILO == 5 then
			fix_ps2_pos1 = 96
			fix_ps2_lag = 9
			fix_ps2_cen = 44
		elseif CONTROL.ESTILO == 6 then
			fix_ps2_pos1 = 270
			fix_ps2_cen = 46
		end
		if OPCIONES.GUI_LIMPIA_ON == 0 and LISTAS.SCREENSHOT_FULL == false then
			Graphics.drawRect(CONTROL.LISTA_ANCHO+fix_ps2_pos2-3,CONTROL.LISTA_ALTO+fix_ps2_pos1-4,315-fix_ps2_lag,26,COLOR.NEGRO)
			if CONTROL.JOYSTICK_ON == false then
				Graphics.drawScaleImage(PAD_IMG.CIRCLE,CONTROL.LISTA_ANCHO+fix_ps2_cen+fix_ps2_pos2,CONTROL.LISTA_ALTO+fix_ps2_pos1,20,20)
				Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+25+fix_ps2_cen+fix_ps2_pos2,CONTROL.LISTA_ALTO+fix_ps2_pos1,0,0,5,"GAME SETTINGS",COLOR.BLANCO)
			else
				Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+3+fix_ps2_pos2,CONTROL.LISTA_ALTO+fix_ps2_pos1,0,0,5,"FOUND GAMES: " .. #LISTAS.ROMS,CAMBIOS_EMUS.COLOR_EMU)
			end
		end
		if Pads.check(PAD,PAD_CIRCLE) and CONTROL.JOYSTICK_ON == false then
			menu_neutrino(LISTAS.ROMS[LISTAS.INDICE])
		end
	elseif #LISTAS.ROMS >= 1 and LISTAS.IDENTIDAD ~= 14 and Pads.check(PAD,PAD_CIRCLE) and OPCIONES.GUI_LIMPIA_ON == 0 and LISTAS.SCREENSHOT_FULL == false then
		local fix_ps2_pos1 = 0
		local fix_ps2_pos2 = 0
		local fix_ps2_cen = 0
		local fix_ps2_lag = 0
		local text_con = "FOUND GAMES: "
		if  LISTAS.IDENTIDAD == 13 then
			text_con = "FOUND APPS: "
		end
		if CONTROL.ESTILO == 1 then
			fix_ps2_pos1 = 270
			fix_ps2_cen = 46
		elseif CONTROL.ESTILO == 2 then
			fix_ps2_pos1 = 262
			fix_ps2_pos2 = 137
			fix_ps2_cen = 46
			fix_ps2_lag = 4
		elseif CONTROL.ESTILO == 3 then
			fix_ps2_pos1 = 118
			fix_ps2_cen = 46
		elseif CONTROL.ESTILO == 4 then
			fix_ps2_pos1 = 270
			fix_ps2_cen = 46
		elseif CONTROL.ESTILO == 5 then
			fix_ps2_pos1 = 96
			fix_ps2_lag = 9
			fix_ps2_cen = 44
		elseif CONTROL.ESTILO == 6 then
			fix_ps2_pos1 = 270
			fix_ps2_cen = 46
		end
		Graphics.drawRect(CONTROL.LISTA_ANCHO+fix_ps2_pos2-3,CONTROL.LISTA_ALTO+fix_ps2_pos1-4,315-fix_ps2_lag,26,COLOR.NEGRO)
		Font.ftPrint(CONTROL.fontARCA,CONTROL.LISTA_ANCHO+3+fix_ps2_pos2,CONTROL.LISTA_ALTO+fix_ps2_pos1,0,0,5,text_con .. #LISTAS.ROMS,CAMBIOS_EMUS.COLOR_EMU)
	end
	
	--- Líneas para cambiar de emulador
	-----------------------------------------------------------------------------------------
	if Pads.check(PAD,PAD_R1) and CONTROL.JOYSTICK_ON == false then
		if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.NETX ~= nil then
			Sound.playADPCM(1,MENU_SONIDOS.NETX)
		end
		desactivados(false)
		LISTAS.ROMS = nil
		LISTAS.ROMS = PRE_CARGADAS[LISTAS.IDENTIDAD]
		if #LISTAS.ROMS >= 1 and LISTAS.IDENTIDAD ~= 13 then
			table.sort(LISTAS.ROMS,orden_alfabetico)
		end
		LISTAS.INDICE = 1
		indices_extras()
		CONTROL.JOYSTICK_ON = true
		JOYSTICK_LIMITE = 2
		LISTAS.SCROLL_TEX = 1
		reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
		CONTROL.LADO_ANI = true
		animaciones()
		LISTAS.SCREENSHOT_ON = false
		limpiar_art()
		LISTAS.MOSTRAR = 0-CONTROL.FPS
		if OPCIONES.VIBRATION_ON == 1 then
			Pads.rumble(1,255)
		end
			
	elseif Pads.check(PAD,PAD_L1) and CONTROL.JOYSTICK_ON == false then
		if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.NETX ~= nil then
			Sound.playADPCM(1,MENU_SONIDOS.NETX)
		end
		desactivados(true)
		LISTAS.ROMS = nil
		LISTAS.ROMS = PRE_CARGADAS[LISTAS.IDENTIDAD]
		if #LISTAS.ROMS >= 1 and LISTAS.IDENTIDAD ~= 13 then
			table.sort(LISTAS.ROMS,orden_alfabetico)
		end
		LISTAS.INDICE = 1
		indices_extras()
		CONTROL.JOYSTICK_ON = true
		JOYSTICK_LIMITE = 2
		LISTAS.SCROLL_TEX = 1
		reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
		CONTROL.LADO_ANI = false
		animaciones()
		LISTAS.SCREENSHOT_ON = false
		limpiar_art()
		LISTAS.MOSTRAR = 0-CONTROL.FPS
		if OPCIONES.VIBRATION_ON == 1 then
			Pads.rumble(255,1)
		end
	end
	
	--- Líneas para mostrar screenshot
	-----------------------------------------------------------------------------------------
	if Pads.check(PAD,PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false and LISTAS.MOSTRAR >= LISTAS.ART_LIMITE then
		if LISTAS.SCREENSHOT_ON == false then
			LISTAS.SCREENSHOT_ON = true
		else 
			LISTAS.SCREENSHOT_ON = false
		end
		CONTROL.JOYSTICK_ON = true
		JOYSTICK_LIMITE = control_FPS(1)
		if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.CANCELAR ~= nil then
			Sound.playADPCM(1,MENU_SONIDOS.CANCELAR)
		end
		if OPCIONES.VIBRATION_ON == 1 then
			Pads.rumble(1,200)
		end
	end
	
	--- Líneas para mostrar screenshot a pantalla completa
	-----------------------------------------------------------------------------------------
	if Pads.check(PAD,PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
		if LISTAS.SCREENSHOT_FULL == false then
			LISTAS.SCREENSHOT_FULL = true
		else 
			LISTAS.SCREENSHOT_FULL = false
		end
		if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.CANCELAR ~= nil then
			Sound.playADPCM(1,MENU_SONIDOS.CANCELAR)
		end
		CONTROL.JOYSTICK_ON = true
		JOYSTICK_LIMITE = control_FPS(1)
		if OPCIONES.VIBRATION_ON == 1 then
			Pads.rumble(1,200)
		end
	end
	if #LISTAS.ROMS <= 0 or LISTAS.ROMS == nil then
		LISTAS.SCREENSHOT_FULL = false
	end
	if LISTAS.SCREENSHOT_FULL == true then 
		if LISTAS.SCREENSHOT_ON == true then 
			if LISTAS.SCREENSHOT ~= nil and LISTAS.EXISTE_SCR == true then
				Graphics.drawRect(35,5,570,410,COLOR.NEGRO_T)
				Graphics.drawScaleImage(LISTAS.SCREENSHOT,45,15,550,390)
				Graphics.drawRect(165,403,310,20,COLOR.NEGRO_T)
				Font.ftPrint(CONTROL.fontARCA,170,403,0,307,2,string.sub(LISTAS.ROMS[LISTAS.INDICE],LISTAS.SCROLL_TEX,-CONTROL.EXTENSION),CAMBIOS_EMUS.COLOR_EMU)
			else
				Graphics.drawRect(35,5,570,410,COLOR.NEGRO_T)
				if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
					Font.ftPrint(CONTROL.fontARCA,233,180,0,0,8,"-LOADING ART-",COLOR.BLANCO)
				else
					Graphics.drawScaleImage(LISTAS.SCREENSHOT_DEFAULT,45,15,550,390,CAMBIOS_EMUS.COLOR_EMU_BACK)
				end
				Graphics.drawRect(165,403,310,20,COLOR.NEGRO_T)
				Font.ftPrint(CONTROL.fontARCA,170,403,0,307,2,string.sub(LISTAS.ROMS[LISTAS.INDICE],LISTAS.SCROLL_TEX,-CONTROL.EXTENSION),CAMBIOS_EMUS.COLOR_EMU)
			end
		else
			if LISTAS.COVER_ART ~= nil and LISTAS.EXISTE_COV == true then
				Graphics.drawRect(35,5,570,410,COLOR.NEGRO_T)
				Graphics.drawScaleImage(LISTAS.COVER_ART,45,15,550,390)
				Graphics.drawRect(165,403,310,20,COLOR.NEGRO_T)
				Font.ftPrint(CONTROL.fontARCA,170,403,0,307,2,string.sub(LISTAS.ROMS[LISTAS.INDICE],LISTAS.SCROLL_TEX,-CONTROL.EXTENSION),CAMBIOS_EMUS.COLOR_EMU)
			else
				Graphics.drawRect(35,5,570,410,COLOR.NEGRO_T)
				if LISTAS.MOSTRAR <= LISTAS.ART_LIMITE then
					Font.ftPrint(CONTROL.fontARCA,233,180,0,0,8,"-LOADING ART-",COLOR.BLANCO)
				else
					Graphics.drawScaleImage(LISTAS.COVER_DEFAULT,45,15,550,390,CAMBIOS_EMUS.COLOR_EMU_BACK)
				end
				Graphics.drawRect(165,403,310,20,COLOR.NEGRO_T)
				Font.ftPrint(CONTROL.fontARCA,170,403,0,307,2,string.sub(LISTAS.ROMS[LISTAS.INDICE],LISTAS.SCROLL_TEX,-CONTROL.EXTENSION),CAMBIOS_EMUS.COLOR_EMU)
			end
		end
		
		-- Dibujar indicadores de listas
		if OPCIONES.GUI_LIMPIA_ON == 0 then
			if #LISTAS.ROMS >= 1 then
				if OPCIONES.CAMBIO_FUENTE_ON == 1 then	
					Graphics.drawRect(33,424,141,20,COLOR.NEGRO_T)
					Graphics.drawRect(478,424,153,20,COLOR.NEGRO_T)
					Graphics.drawRect(270,424,115,20,COLOR.NEGRO_T)
				end
				Graphics.drawScaleImage(PAD_IMG.TRIANGLE,7,424,20,20)
				Font.ftPrint(CONTROL.fontARCA,38,424,0,0,8,"CHANGE ART",COLOR.BLANCO)
				Graphics.drawScaleImage(PAD_IMG.SQUARE,452,424,20,20)
				Font.ftPrint(CONTROL.fontARCA,483,424,0,0,8,"FULL SCREEN",COLOR.BLANCO)
				Graphics.drawScaleImage(PAD_IMG.CROSS,244,424,20,20)
				Font.ftPrint(CONTROL.fontARCA,275,424,0,0,8,"RUN GAME",COLOR.BLANCO)
			else
				if OPCIONES.CAMBIO_FUENTE_ON == 1 then	
					Graphics.drawRect(255,424,155,20,COLOR.NEGRO_T)
				end
				Graphics.drawScaleImage(PAD_IMG.R3,229,424,20,20)
				Font.ftPrint(CONTROL.fontARCA,260,424,0,0,8,"UPDATE LIST",COLOR.BLANCO)
			end
		end
	end
	
	--- Líneas para entrar en configuraciones
	-----------------------------------------------------------------------------------------
	if Pads.check(PAD,PAD_START) then
		if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.EJECUTAR ~= nil then
			Sound.playADPCM(1,MENU_SONIDOS.EJECUTAR)
		end
		CONTROL.JOYSTICK_ON = true 
		JOYSTICK_LIMITE = control_FPS(1)
		menu_config()
	end
	
	--- Líneas para refrescar lista actual
	-----------------------------------------------------------------------------------------
	if Pads.check(PAD,PAD_R3) then
		Pads.rumble(0,0)
		if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.EJECUTAR ~= nil then
			Sound.playADPCM(1,MENU_SONIDOS.EJECUTAR)
		end
		recargar_una(LISTAS.IDENTIDAD)
		LISTAS.ROMS = nil
		LISTAS.ROMS = PRE_CARGADAS[LISTAS.IDENTIDAD]
		if #LISTAS.ROMS >= 1 and LISTAS.IDENTIDAD ~= 13 then
			table.sort(LISTAS.ROMS,orden_alfabetico)
		end
		LISTAS.INDICE = 1
		indices_extras()
		reset_tiempo_espera(-CONTROL.FPS-CONTROL.FPS)
		limpiar_art()
		LISTAS.MOSTRAR = 0-CONTROL.FPS
		CONTROL.JOYSTICK_ON = true 
		JOYSTICK_LIMITE = control_FPS(1)
	end
	
	--- Líneas para reiniciar RETROLauncher
	-----------------------------------------------------------------------------------------
	if Pads.check(PAD,PAD_L3) then
		local pregunta = true
		while pregunta do
			capturar(JOYSTICK_LIMITE)
			Graphics.drawRect(175,162,290,94,Color.new(0,0,0,10))
			Font.ftPrint(CONTROL.fontARCA,184,180,0,0,8,"RESET RETROLAUNCHER ?",COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.CROSS,193,215,20,20)
			Font.ftPrint(CONTROL.fontARCA,228,215,0,0,8,"RESET",COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.CIRCLE,330,215,20,20)
			Font.ftPrint(CONTROL.fontARCA,365,215,0,0,8,"CANCEL",COLOR.BLANCO)
			if Pads.check(PAD,PAD_CROSS) then
				if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.EJECUTAR ~= nil then
					Sound.playADPCM(1,MENU_SONIDOS.EJECUTAR)
				end
				local actual = System.currentDirectory()
				System.loadELF(actual .."/RETROLauncher.elf",0,actual .. "/System/system.lua")
			elseif Pads.check(PAD,PAD_CIRCLE) or Pads.check(PAD,PAD_TRIANGLE) then
				if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.CANCELAR ~= nil then
					Sound.playADPCM(1,MENU_SONIDOS.CANCELAR)
				end
				if OPCIONES.VIBRATION_ON == 1 then
					Pads.rumble(1,255)
				end
				pregunta = false
				CONTROL.JOYSTICK_ON = true 
				JOYSTICK_LIMITE = control_FPS(1)
			end
			refrescar()
		end
	end
	
	--- Líneas para salir de RETROLauncher
	-----------------------------------------------------------------------------------------
	if Pads.check(PAD,PAD_SELECT) then 
		local pregunta = true
		while pregunta do
			capturar(JOYSTICK_LIMITE)
			Graphics.drawRect(175,162,290,94,Color.new(0,0,0,10))
			Font.ftPrint(CONTROL.fontARCA,188,180,0,0,8,"QUIT RETROLAUNCHER ?",COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.CROSS,193,215,20,20)
			Font.ftPrint(CONTROL.fontARCA,228,215,0,0,8,"QUIT",COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.CIRCLE,330,215,20,20)
			Font.ftPrint(CONTROL.fontARCA,365,215,0,0,8,"CANCEL",COLOR.BLANCO)
			if Pads.check(PAD,PAD_CROSS) then
				if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.EJECUTAR ~= nil then
					Sound.playADPCM(1,MENU_SONIDOS.EJECUTAR)
				end
				if OPCIONES.SALIDA_RETROLANCHER_ON ~= 0 then
					System.loadELF(OPCIONES.SALIDA_RETROLANCHER,0,salida_texto_dir(OPCIONES.SALIDA_RETROLANCHER,false))
					System.exitToBrowser()
				else
					System.exitToBrowser() 
				end
			elseif Pads.check(PAD,PAD_CIRCLE) or Pads.check(PAD,PAD_TRIANGLE) then
				if OPCIONES.SOUND_ON == 1 and MENU_SONIDOS.CANCELAR ~= nil then
					Sound.playADPCM(1,MENU_SONIDOS.CANCELAR)
				end
				if OPCIONES.VIBRATION_ON == 1 then
					Pads.rumble(1,200)
				end
				pregunta = false
				CONTROL.JOYSTICK_ON = true 
				JOYSTICK_LIMITE = control_FPS(1)
			end
			refrescar()
		end
	end
end
--[[------------------SPAGHETTICODE-------------------]]--