-- Prism PS2 Launcher - ui/theme_editor.lua
-- Theme editor: styles, preview, load and save of the visual theme.
-- Split from the original funciones.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Functions are globals; this file only defines them. Loaded by System/system.lua.

--- Carga sprites y define su tamaño. ---------------------------------------------------
function TEML(cargar_img)
	local actual = System.currentDirectory()
	local list_sprites = System.listDirectory(actual .."/System/Medias/Sprites")
	local comparar = {"Megadrive_"; "MasterSystem_"; "GameGear_"; "Famicom_"; "GameBoy_"; "GameBoyColor_"; "GameBoyAdvance_";
	"Atari2600_"; "AtariLynx_"; "SegaSG1000_"; "NeoGeoPocket_"; "SuperFamicom_"; "Apps_"; "PlayStation_"; "PlayStation2_";}
	local final = {"Megadrive_01000_4x4.png"; "MasterSystem_01000_4x4.png"; "GameGear_01000_4x4.png"; "Famicom_01000_4x4.png"; "GameBoy_01000_4x4.png";
	"GameBoyColor_01000_4x4.png"; "GameBoyAdvance_01000_4x4.png"; "Atari2600_01000_4x4.png"; "AtariLynx_01000_4x4.png"; "SegaSG1000_01000_4x4.png";
	"NeoGeoPocket_01000_4x4.png"; "SuperFamicom_01000_4x4.png"; "Apps_01000_4x4.png"; "PlayStation_01000_4x4.png"; "PlayStation2_01000_4x4.png";}
	if list_sprites ~= nil then
		for cont = 1, #comparar do
			local presente = false
			for cont2 = 1, #list_sprites do
				if string.match(string.lower(list_sprites[cont2].name), string.lower(comparar[cont] .."[%w#][%w#][%w#][%w#][%w#].%d.%d%.png")) and not (cont == 4 and string.match(list_sprites[cont2].name, "SuperFamicom_")) then
					SPRITES.MOVE[cont] = cha_res(string.sub(list_sprites[cont2].name, -13, -13), 62)
					SPRITES.SPEED_SPRITE[cont] = cha_res(string.sub(list_sprites[cont2].name, -12, -12), 62)
					SPRITES.TRAN_SPRITE_ON[cont] = cha_res(string.sub(list_sprites[cont2].name, -11, -11), 24)
					SPRITES.SPIN_SPRITE_ON[cont] = cha_res(string.sub(list_sprites[cont2].name, -10, -10), 62)
					SPRITES.AUTO_MOVE_SPRITE[cont] = cha_res(string.sub(list_sprites[cont2].name, -9, -9), 9)
					SPRITES.N_COLUMNS[cont] = tonumber(string.sub(list_sprites[cont2].name, -7, -7))
					SPRITES.N_ROWS[cont] = tonumber(string.sub(list_sprites[cont2].name, -5, -5))
					final[cont] = list_sprites[cont2].name
					presente = true
				end
			end
			if presente == false then
				SPRITES.MOVE[cont] = 0
				SPRITES.SPEED_SPRITE[cont] = 1
				SPRITES.TRAN_SPRITE_ON[cont] = 0
				SPRITES.SPIN_SPRITE_ON[cont] = 0
				SPRITES.AUTO_MOVE_SPRITE[cont] = 0
				SPRITES.N_COLUMNS[cont] = 1
				SPRITES.N_ROWS[cont] = 1
			end
			final[cont] = "System/Medias/Sprites/".. final[cont]
		end
	else
		for cont = 1, #final do final[cont] = "System/Medias/Sprites/".. final[cont] end
	end
	for carga = 1, 15 do
		if cargar_img == true then
			SPRITES[SPRITES.SPRITE_SYS[carga]] = Graphics.loadImage(verif_img(final[carga]))
		end
		SPRITES.WIDTH_X[carga] = (Graphics.getImageWidth(SPRITES[SPRITES.SPRITE_SYS[carga]])/SPRITES.N_COLUMNS[carga])
		SPRITES.HEIGHT_Y[carga] = (Graphics.getImageHeight(SPRITES[SPRITES.SPRITE_SYS[carga]])/SPRITES.N_ROWS[carga])
	end
end

--- Definir las posiciones y configuración de cada estilo. ------------------------------
function definir_estilos()
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
		CONTROL.CUSTOM_BUTTON_SEL = true; CONTROL.CUSTOM_BACK = true;
		CONTROL.SPRITE_ANCHO = 286; CONTROL.SPRITE_X = 69; CONTROL.SPRITE_ALTO = 288; CONTROL.SPRITE_Y = 92;
		CONTROL.CUSTOM_SPRITE = false;
	elseif CONTROL.ESTILO == 2 then
		CONTROL.IMG_ANCHO = 197; CONTROL.IMG_X = 246; CONTROL.IMG_ALTO = 96; CONTROL.IMG_Y = 231;
		CONTROL.IMG_ANCHO_2 = 197; CONTROL.IMG_X_2 = 246; CONTROL.IMG_ALTO_2 = 96; CONTROL.IMG_Y_2 = 231;
		CONTROL.LISTA_ANCHO = 169; CONTROL.LISTA_X = 302; CONTROL.LISTA_ALTO = 341; CONTROL.LISTA_Y = 50;
		CONTROL.LOGO_ANCHO = 194; CONTROL.LOGO_X = 252; CONTROL.LOGO_ALTO = 5; CONTROL.LOGO_Y = 76;
		CONTROL.FLOW_ANCHO = 12; CONTROL.FLOW_X = 168; CONTROL.FLOW_ALTO = 115; CONTROL.FLOW_Y = 182;
		CONTROL.FLOW_ANCHO_2 = 460; CONTROL.FLOW_X_2 = 168; CONTROL.FLOW_ALTO_2 = 115; CONTROL.FLOW_Y_2 = 182;
		CONTROL.X_BUTTON_X = 273; CONTROL.Y_BUTTON_X = 398; CONTROL.X_BUTTON_T = 44; CONTROL.Y_BUTTON_T = 398;
		CONTROL.X_BUTTON_S = 475; CONTROL.Y_BUTTON_S = 398; CONTROL.X_BUTTON_L1 = 144; CONTROL.Y_BUTTON_L1 = 28;
		CONTROL.X_BUTTON_R1 = 464; CONTROL.Y_BUTTON_R1 = 28; CONTROL.X_BUTTON_R3 = 260; CONTROL.Y_BUTTON_R3 = 398;
		CONTROL.X_BUTTON_STA = 423; CONTROL.Y_BUTTON_STA = 424; CONTROL.X_BUTTON_SEL = 45; CONTROL.Y_BUTTON_SEL = 424;
		CONTROL.CUSTOM_ANIM = 2; CONTROL.ANIM_VELOCIDAD = 29;
		CONTROL.CUSTOM_LIST = false; CONTROL.CUSTOM_ART1 = true; CONTROL.CUSTOM_ART2 = false;
		CONTROL.CUSTOM_FLOW = true; CONTROL.CUSTOM_LOGO = true; CONTROL.CUSTOM_BUTTON_X = true;
		CONTROL.CUSTOM_BUTTON_T = true; CONTROL.CUSTOM_BUTTON_S = true; CONTROL.CUSTOM_BUTTON_L1 = true;
		CONTROL.CUSTOM_BUTTON_R1 = true; CONTROL.CUSTOM_BUTTON_R3 = true; CONTROL.CUSTOM_BUTTON_STA = true;
		CONTROL.CUSTOM_BUTTON_SEL = true; CONTROL.CUSTOM_BACK = true;
		CONTROL.SPRITE_ANCHO = 477; CONTROL.SPRITE_X = 48; CONTROL.SPRITE_ALTO = 337; CONTROL.SPRITE_Y = 54;
		CONTROL.CUSTOM_SPRITE = false;
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
		CONTROL.CUSTOM_BUTTON_SEL = true; CONTROL.CUSTOM_BACK = true;
		CONTROL.SPRITE_ANCHO = 300; CONTROL.SPRITE_X = 60; CONTROL.SPRITE_ALTO = 362; CONTROL.SPRITE_Y = 75;
		CONTROL.CUSTOM_SPRITE = false;
	elseif CONTROL.ESTILO == 4 then
		CONTROL.IMG_ANCHO = 333; CONTROL.IMG_X = 295; CONTROL.IMG_ALTO = 92; CONTROL.IMG_Y = 228;
		CONTROL.IMG_ANCHO_2 = 333; CONTROL.IMG_X_2 = 295; CONTROL.IMG_ALTO_2 = 92; CONTROL.IMG_Y_2 = 228;
		CONTROL.LISTA_ANCHO = 10; CONTROL.LISTA_X = 310; CONTROL.LISTA_ALTO = 90; CONTROL.LISTA_Y = 290;
		CONTROL.LOGO_ANCHO = 194; CONTROL.LOGO_X = 252; CONTROL.LOGO_ALTO = 5; CONTROL.LOGO_Y = 76;
		CONTROL.FLOW_ANCHO = 333; CONTROL.FLOW_X = 295; CONTROL.FLOW_ALTO = 92; CONTROL.FLOW_Y = 228;
		CONTROL.FLOW_ANCHO_2 = 333; CONTROL.FLOW_X_2 = 295; CONTROL.FLOW_ALTO_2 = 92; CONTROL.FLOW_Y_2 = 228;
		CONTROL.X_BUTTON_X = 273; CONTROL.Y_BUTTON_X = 391; CONTROL.X_BUTTON_T = 44; CONTROL.Y_BUTTON_T = 391;
		CONTROL.X_BUTTON_S = 475; CONTROL.Y_BUTTON_S = 391; CONTROL.X_BUTTON_L1 = 144; CONTROL.Y_BUTTON_L1 = 28;
		CONTROL.X_BUTTON_R1 = 464; CONTROL.Y_BUTTON_R1 = 28; CONTROL.X_BUTTON_R3 = 260; CONTROL.Y_BUTTON_R3 = 391;
		CONTROL.X_BUTTON_STA = 423; CONTROL.Y_BUTTON_STA = 415; CONTROL.X_BUTTON_SEL = 45; CONTROL.Y_BUTTON_SEL = 415;
		CONTROL.CUSTOM_ANIM = 1; CONTROL.ANIM_VELOCIDAD = 29;
		CONTROL.CUSTOM_LIST = true; CONTROL.CUSTOM_ART1 = true; CONTROL.CUSTOM_ART2 = false;
		CONTROL.CUSTOM_FLOW = false; CONTROL.CUSTOM_LOGO = true; CONTROL.CUSTOM_BUTTON_X = true;
		CONTROL.CUSTOM_BUTTON_T = true; CONTROL.CUSTOM_BUTTON_S = true; CONTROL.CUSTOM_BUTTON_L1 = true;
		CONTROL.CUSTOM_BUTTON_R1 = true; CONTROL.CUSTOM_BUTTON_R3 = true; CONTROL.CUSTOM_BUTTON_STA = true;
		CONTROL.CUSTOM_BUTTON_SEL = true; CONTROL.CUSTOM_BACK = true;
		CONTROL.SPRITE_ANCHO = 257; CONTROL.SPRITE_X = 64; CONTROL.SPRITE_ALTO = 297; CONTROL.SPRITE_Y = 83;
		CONTROL.CUSTOM_SPRITE = false;
	elseif CONTROL.ESTILO == 5 then
		CONTROL.IMG_ANCHO = 12; CONTROL.IMG_X = 295; CONTROL.IMG_ALTO = 20; CONTROL.IMG_Y = 228;
		CONTROL.IMG_ANCHO_2 = 332; CONTROL.IMG_X_2 = 295; CONTROL.IMG_ALTO_2 = 20; CONTROL.IMG_Y_2 = 228;
		CONTROL.LISTA_ANCHO = 10; CONTROL.LISTA_X = 299; CONTROL.LISTA_ALTO = 263; CONTROL.LISTA_Y = 115;
		CONTROL.LOGO_ANCHO = 352; CONTROL.LOGO_X = 252; CONTROL.LOGO_ALTO = 280; CONTROL.LOGO_Y = 76;
		CONTROL.FLOW_ANCHO = 12; CONTROL.FLOW_X = 295; CONTROL.FLOW_ALTO = 20; CONTROL.FLOW_Y = 228;
		CONTROL.FLOW_ANCHO_2 = 12; CONTROL.FLOW_X_2 = 295; CONTROL.FLOW_ALTO_2 = 20; CONTROL.FLOW_Y_2 = 228;
		CONTROL.X_BUTTON_X = 273; CONTROL.Y_BUTTON_X = 391; CONTROL.X_BUTTON_T = 44; CONTROL.Y_BUTTON_T = 391;
		CONTROL.X_BUTTON_S = 475; CONTROL.Y_BUTTON_S = 391; CONTROL.X_BUTTON_L1 = 324; CONTROL.Y_BUTTON_L1 = 252;
		CONTROL.X_BUTTON_R1 = 602; CONTROL.Y_BUTTON_R1 = 252; CONTROL.X_BUTTON_R3 = 260; CONTROL.Y_BUTTON_R3 = 391;
		CONTROL.X_BUTTON_STA = 423; CONTROL.Y_BUTTON_STA = 415; CONTROL.X_BUTTON_SEL = 45; CONTROL.Y_BUTTON_SEL = 415;
		CONTROL.CUSTOM_ANIM = 2; CONTROL.ANIM_VELOCIDAD = 29;
		CONTROL.CUSTOM_LIST = true; CONTROL.CUSTOM_ART1 = true; CONTROL.CUSTOM_ART2 = true;
		CONTROL.CUSTOM_FLOW = false; CONTROL.CUSTOM_LOGO = true; CONTROL.CUSTOM_BUTTON_X = true;
		CONTROL.CUSTOM_BUTTON_T = true; CONTROL.CUSTOM_BUTTON_S = true; CONTROL.CUSTOM_BUTTON_L1 = true;
		CONTROL.CUSTOM_BUTTON_R1 = true; CONTROL.CUSTOM_BUTTON_R3 = true; CONTROL.CUSTOM_BUTTON_STA = true;
		CONTROL.CUSTOM_BUTTON_SEL = true; CONTROL.CUSTOM_BACK = true;
		CONTROL.SPRITE_ANCHO = 263; CONTROL.SPRITE_X = 66; CONTROL.SPRITE_ALTO = 291; CONTROL.SPRITE_Y = 87;
		CONTROL.CUSTOM_SPRITE = false;
	elseif CONTROL.ESTILO == 6 then
		CONTROL.IMG_ANCHO = 345; CONTROL.IMG_X = 270; CONTROL.IMG_ALTO = 10; CONTROL.IMG_Y = 208;
		CONTROL.IMG_ANCHO_2 = 345; CONTROL.IMG_X_2 = 270; CONTROL.IMG_ALTO_2 = 230; CONTROL.IMG_Y_2 = 208;
		CONTROL.LISTA_ANCHO = 22; CONTROL.LISTA_X = 310; CONTROL.LISTA_ALTO = 90; CONTROL.LISTA_Y = 290;
		CONTROL.LOGO_ANCHO = 52; CONTROL.LOGO_X = 252; CONTROL.LOGO_ALTO = 5; CONTROL.LOGO_Y = 76;
		CONTROL.FLOW_ANCHO = 345; CONTROL.FLOW_X = 270; CONTROL.FLOW_ALTO = 10; CONTROL.FLOW_Y = 208;
		CONTROL.FLOW_ANCHO_2 = 345; CONTROL.FLOW_X_2 = 270; CONTROL.FLOW_ALTO_2 = 10; CONTROL.FLOW_Y_2 = 208;
		CONTROL.X_BUTTON_X = 52; CONTROL.Y_BUTTON_X = 386; CONTROL.X_BUTTON_T = 202; CONTROL.Y_BUTTON_T = 386;
		CONTROL.X_BUTTON_S = 52; CONTROL.Y_BUTTON_S = 417; CONTROL.X_BUTTON_L1 = 17; CONTROL.Y_BUTTON_L1 = 60;
		CONTROL.X_BUTTON_R1 = 305; CONTROL.Y_BUTTON_R1 = 60; CONTROL.X_BUTTON_R3 = 52; CONTROL.Y_BUTTON_R3 = 386;
		CONTROL.X_BUTTON_STA = 152; CONTROL.Y_BUTTON_STA = 417; CONTROL.X_BUTTON_SEL = 264; CONTROL.Y_BUTTON_SEL = 417;
		CONTROL.CUSTOM_ANIM = 1; CONTROL.ANIM_VELOCIDAD = 29;
		CONTROL.CUSTOM_LIST = true; CONTROL.CUSTOM_ART1 = true; CONTROL.CUSTOM_ART2 = true;
		CONTROL.CUSTOM_FLOW = false; CONTROL.CUSTOM_LOGO = true; CONTROL.CUSTOM_BUTTON_X = true;
		CONTROL.CUSTOM_BUTTON_T = true; CONTROL.CUSTOM_BUTTON_S = true; CONTROL.CUSTOM_BUTTON_L1 = true;
		CONTROL.CUSTOM_BUTTON_R1 = true; CONTROL.CUSTOM_BUTTON_R3 = true; CONTROL.CUSTOM_BUTTON_STA = true;
		CONTROL.CUSTOM_BUTTON_SEL = true; CONTROL.CUSTOM_BACK = true;
		CONTROL.SPRITE_ANCHO = 282; CONTROL.SPRITE_X = 66; CONTROL.SPRITE_ALTO = 298; CONTROL.SPRITE_Y = 83;
		CONTROL.CUSTOM_SPRITE = false;
	elseif CONTROL.ESTILO == 7 then
		cargar_style(false)
	end
end

--[[Líneas para las funciones encargadas del editor de estilos.]]--
--- Dibuja en pantalla la vista previa de todos los elementos. --------------------------
function dibujar_demo(selector_elementos, elementos_pos_new, elementos_tam_new, cambio_tama_pos, fijar, largo_lista, estado_elementos_new, lis_ext)
	-- Vista previa del arte relacionado con cover flow. --------------------------------
	if estado_elementos_new[4] == true then
		if CONTROL.CUSTOM_BACK == true then
			Graphics.drawRect(elementos_pos_new[7]-5, elementos_pos_new[8]-5+CONTROL.Y_FIX_PAL, elementos_tam_new[7]+10, elementos_tam_new[8]+10, COLOR.NEGRO_T)
			Graphics.drawRect((CONTROL.ANCHO-(elementos_pos_new[7]+elementos_tam_new[7]))-5, elementos_pos_new[8]-5+CONTROL.Y_FIX_PAL, elementos_tam_new[7]+10, elementos_tam_new[8]+10, COLOR.NEGRO_T)
		end
		dibujar_arte(LISTAS.COVER_ART, LISTAS.EXISTE_COV, LISTAS.COVER_DEFAULT, elementos_pos_new[7], elementos_pos_new[8]+CONTROL.Y_FIX_PAL, elementos_tam_new[7], elementos_tam_new[8], lis_ext[9], lis_ext[10], lis_ext[11], lis_ext[12], nil)
		dibujar_arte(LISTAS.COVER_ART, LISTAS.EXISTE_COV, LISTAS.COVER_DEFAULT, (CONTROL.ANCHO-(elementos_pos_new[7]+elementos_tam_new[7])), elementos_pos_new[8]+CONTROL.Y_FIX_PAL, elementos_tam_new[7], elementos_tam_new[8], lis_ext[9], lis_ext[10], lis_ext[11], lis_ext[12], nil)
	end

	-- Vista previa del arte extra. -----------------------------------------------------
	if estado_elementos_new[3] == true then
		dibujar_arte(LISTAS.SCREENSHOT, LISTAS.EXISTE_SCR, LISTAS.SCREENSHOT_DEFAULT, elementos_pos_new[5], elementos_pos_new[6]+CONTROL.Y_FIX_PAL, elementos_tam_new[5], elementos_tam_new[6], lis_ext[5], lis_ext[6], lis_ext[7], lis_ext[8], false)
	end

	-- Vista previa del fondo de lista. -------------------------------------------------
	if estado_elementos_new[1] == true then
		Graphics.drawRect(elementos_pos_new[1]-3, elementos_pos_new[2]-3+CONTROL.Y_FIX_PAL, elementos_tam_new[1]+6, elementos_tam_new[2]+6, COLOR.NEGRO_T)
	end

	-- Vista previa de las listas de juegos. --------------------------------------------
	--
	-- Con los nombres REALES del sistema en curso, no trece veces la misma palabra de
	-- ejemplo. Aqui se esta colocando una lista y decidiendo su ancho: nombres todos
	-- del mismo largo no dicen nada sobre lo que se va a ver, y un titulo de verdad
	-- ensena enseguida donde se corta. Si no hay lista cargada se cae en los de antes.
	local function nombre_ejemplo(n)
		if LISTAS.ROMS ~= nil and #LISTAS.ROMS > 0 and LISTAS.INDICE ~= nil then
			local idx = ((LISTAS.INDICE + n - 2) % #LISTAS.ROMS) + 1
			if LISTAS.ROMS[idx] ~= nil then
				return NOMBRE_VISIBLE(LISTAS.IDENTIDAD, LISTAS.ROMS[idx], 1)
			end
		end
		return n ..".".. TEXT_M_STI[1]
	end

	local lista_ejemplo = {}
	if estado_elementos_new[4] == false and estado_elementos_new[1] == true then
		for agregar = 1, largo_lista do table.insert(lista_ejemplo, nombre_ejemplo(agregar)) end
		local espacio_linea = elementos_pos_new[2]+((0)*24)+CONTROL.Y_FIX_PAL
		for contador = 1, largo_lista, 1 do
			if contador == 1 then
				Font.ftPrint(CONTROL.fontARCA, elementos_pos_new[1]+3, espacio_linea, 0, elementos_tam_new[1]-6, 25, lista_ejemplo[contador], CAMBIOS_EMUS.COLOR_EMU)
			else
				Font.ftPrint(CONTROL.fontARCA, elementos_pos_new[1]+3, espacio_linea, 0, elementos_tam_new[1]-6, 25, lista_ejemplo[contador], COLOR.BLANCO_LISTA)
			end
			espacio_linea = elementos_pos_new[2]+((contador)*24)+CONTROL.Y_FIX_PAL
		end

	-- Vista previa de las listas de juegos en cover flow. ------------------------------
	elseif estado_elementos_new[4] == true or estado_elementos_new[1] == false then
		lista_ejemplo = {nombre_ejemplo(1), nombre_ejemplo(2), nombre_ejemplo(3)}
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
		local text_con = TEXT_M_STI[5] ..": "
		local fix_estilo = 29
		if (estado_elementos_new[4] == true or estado_elementos_new[1] == false) then
			fix_estilo = 24
		end
		Graphics.drawRect(elementos_pos_new[1]-3, (elementos_pos_new[2]+elementos_tam_new[2])-fix_estilo+1+CONTROL.Y_FIX_PAL, elementos_tam_new[1]+6, fix_estilo+1, COLOR.NEGRO)
		Font.ftPrint(CONTROL.fontARCA, elementos_pos_new[1]+3, (elementos_pos_new[2]+elementos_tam_new[2])-(fix_estilo-4)+CONTROL.Y_FIX_PAL, 0, elementos_tam_new[1]-30, 25, text_con .. #lista_ejemplo, CAMBIOS_EMUS.COLOR_EMU)
	end

	-- Vista previa de indicadores. -----------------------------------------------------
	local message = {TEXT_M_STI[6], TEXT_M_STI[7], TEXT_M_STI[8], TEXT_M_STI[9], TEXT_M_STI[10], TEXT_M_STI[11]}

	-- Vista previa de indicador para actualizar la lista. ------------------------------
	-- Se dibujaba SOLO mientras estaba seleccionado, asi que R3 podia estar en ON y no
	-- aparecer por ninguna parte: no habia forma de verlo ni de colocarlo respecto a
	-- los demas. Como todos los otros indicadores: si esta encendido, se ve.
	if estado_elementos_new[11] == true then
		dibujar_indicador(elementos_pos_new[21], elementos_pos_new[22], message[6], PAD_IMG.R3, 25, 25, 1, true)
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
		dibujar_indicador(elementos_pos_new[25], elementos_pos_new[26], message[1], PAD_IMG.SELECT_S, 32, 32, 2, true)
	end

	-- Vista previa del indicador de configuración. -------------------------------------
	if estado_elementos_new[12] == true then
		dibujar_indicador(elementos_pos_new[23], elementos_pos_new[24], message[2], PAD_IMG.START, 32, 32, 2, true)
	end
	do
		-- Los tres indicadores de abajo tampoco dependen ya de cual este seleccionado:
		-- desaparecian todos en cuanto se tocaba R3, que era justo el momento en que
		-- hacia falta verlos para no ponerlo encima de ellos.
		-- Vista previa: indicador del menu del juego. ----------------------------------
		-- El rotulo tiene que ser el MISMO que en el menu real: aqui seguia diciendo
		-- "Cambiar arte", que es lo que TRIANGULO hacia antes.
		if estado_elementos_new[7] == true then
			dibujar_indicador(elementos_pos_new[13], elementos_pos_new[14], "Game Menu", PAD_IMG.TRIANGLE, 25, 25, 1, true)
		end

		-- Vista previa: indicadores / arte a pantalla completa. ------------------------
		if estado_elementos_new[8] == true then
			dibujar_indicador(elementos_pos_new[15], elementos_pos_new[16], message[4], PAD_IMG.SQUARE, 25, 25, 1, true)
		end

		-- Vista previa: indicadores / ejecución. ---------------------------------------
		if estado_elementos_new[6] == true then
			dibujar_indicador(elementos_pos_new[11], elementos_pos_new[12], message[5], PAD_IMG.CROSS, 25, 25, 1, true)
		end
	end

	-- Vista previa de portadas / capturas / fondos. ------------------------------------
	if estado_elementos_new[2] == true then
		dibujar_arte(LISTAS.COVER_ART, LISTAS.EXISTE_COV, LISTAS.COVER_DEFAULT, elementos_pos_new[3], elementos_pos_new[4]+CONTROL.Y_FIX_PAL, elementos_tam_new[3], elementos_tam_new[4], lis_ext[1], lis_ext[2], lis_ext[3], lis_ext[4], false)
	end

	-- Vista previa del logo. -----------------------------------------------------------
	if estado_elementos_new[5] == true then
		Graphics.drawScaleImage(LISTAS.LOGO, elementos_pos_new[9], elementos_pos_new[10]+CONTROL.Y_FIX_PAL, elementos_tam_new[9], elementos_tam_new[10])
	end

	-- Vista previa del sprite. ---------------------------------------------------------
	if estado_elementos_new[14] == true then
		dibujar_sprites(LISTAS.IDENTIDAD, elementos_pos_new[27], elementos_pos_new[28]+CONTROL.Y_FIX_PAL, elementos_tam_new[11], elementos_tam_new[12], 0.00, SPRITES.FLIP[1], SPRITES.FLIP[2], false)
	end

	-- Marca sobre el elemento seleccionado. --------------------------------------------
	local color_selector = Color.new(0, 128, 0, 90)
	if cambio_tama_pos == true and (selector_elementos <= 5 or selector_elementos == 14) then
		color_selector = Color.new(0, 0, 128, 90)
	end
	if fijar[selector_elementos] == true then
		color_selector = Color.new(128, 0, 0, 90)
	end
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
		Graphics.drawRect(elementos_pos_new[23]-30, elementos_pos_new[24]-3+CONTROL.Y_FIX_PAL, 25, 25, color_selector)
	elseif selector_elementos == 13 and estado_elementos_new[13] == true then
		Graphics.drawRect(elementos_pos_new[25]-30, elementos_pos_new[26]-3+CONTROL.Y_FIX_PAL, 25, 25, color_selector)
	elseif selector_elementos == 14 and estado_elementos_new[14] == true then
		Graphics.drawRect(elementos_pos_new[27]-1, elementos_pos_new[28]-1+CONTROL.Y_FIX_PAL, elementos_tam_new[11]+2, elementos_tam_new[12]+2, color_selector)
	end
end

--- Líneas para configurar el estilo personalizado. -------------------------------------
function editor_tema()
	JOYSTICK_LIMITE = control_FPS(1)
	local actual = System.currentDirectory()
	local FONT_CNF = Font.ftLoad("System/Medias/Font/PublicPixel.ttf")
	Font.ftSetPixelSize(FONT_CNF, 17, 16)

	-- Corrige la relación de aspecto en el editor de estilos). -------------------------
	local function fix_art_edit(tama_x, tama_y, img)
		local x_prin, y_prin, x_fix, y_fix = tama_x, tama_y, 0, 0
		local x, y = Graphics.getImageWidth(img), Graphics.getImageHeight(img)
		local eiuqal, ymot = (tama_y*x)/y, (tama_x*y)/x
		if eiuqal <= tama_x then
			x_prin, y_prin, x_fix, y_fix = eiuqal, tama_y, (tama_x-eiuqal)//2, 0
		elseif ymot <= tama_y then
			x_prin, y_prin, x_fix, y_fix = tama_x, ymot, 0, (tama_y-ymot)//2
		end
		return x_prin, y_prin, x_fix, y_fix
	end

	-- Cambio entre elementos activados y desactivados. ---------------------------------
	local function estado(selector_X_Y, selector_elementos, lado, estado_elementos_new)
		-- Busca el siguiente elemento ACTIVO. Si no hay ninguno, se para.
		--
		-- Sin ese limite la consola se congela, y no hace falta nada raro para llegar
		-- ahi: basta con desactivar todos los elementos desde el editor. El bucle solo
		-- sabia salir al encontrar un elemento a true, asi que con todos a false daba
		-- vueltas para siempre, sin dibujar ni leer el mando. Es exactamente lo que
		-- pasa al entrar en "active elements" y apagarlos.
		local buscar = true
		local vueltas = 0
		local limite = (#estado_elementos_new * 2) + 2
		while buscar do
			vueltas = vueltas + 1
			if vueltas > limite then
				-- Ninguno activo: se deja el que estaba y se sale.
				break
			end
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

	-- Dibujar líneas de guía en pantalla. ----------------------------------------------
	local function reglas(X, Y, cuadricula, selector_elementos, estado)
		if selector_elementos == 1 or selector_elementos == 14 then
			X, Y = X-3, Y-3
		elseif selector_elementos >= 2 and selector_elementos <= 5 then
			X, Y = X-5, Y-5
		elseif (selector_elementos >= 6 and selector_elementos <= 8) or (selector_elementos >= 11 and selector_elementos <= 13) then
			X, Y = X-30, Y-3
		elseif selector_elementos == 9 or selector_elementos == 10 then
			Y = Y+4
		end
		if estado == false then
			Graphics.drawLine(X, Y+CONTROL.Y_FIX_PAL, CONTROL.ANCHO, Y+CONTROL.Y_FIX_PAL, COLOR.BLANCO)
			Graphics.drawLine(X, Y+CONTROL.Y_FIX_PAL, -10, Y+CONTROL.Y_FIX_PAL, COLOR.BLANCO)
			Graphics.drawLine(X, Y+CONTROL.Y_FIX_PAL, X, CONTROL.ALTO_F, COLOR.BLANCO)
			Graphics.drawLine(X, Y+CONTROL.Y_FIX_PAL, X, -10, COLOR.BLANCO)
			if cuadricula == 2 or cuadricula == 4 then
				local size_X, size_Y = 40, 32
				for ancho = -size_X, CONTROL.ANCHO+(size_X*2), size_X do
					Graphics.drawLine(ancho, -size_Y, ancho, CONTROL.ALTO_F+size_Y, Color.new(80, 80, 80))
				end
				for alto = -size_Y, CONTROL.ALTO_F+(size_Y*2), size_Y do
					Graphics.drawLine(-size_X, alto, CONTROL.ANCHO+size_X, alto, Color.new(80, 80, 80))
				end
			end
		elseif estado == true then
			return X, Y+CONTROL.Y_FIX_PAL
		end
	end

	-- Reparar problema en acceso a valores nulos en listas. ----------------------------
	local function parche(numero)
		local fix = numero
		if fix == 27 then
			fix = 11
		end
		return fix
	end

	-- Estados previos de activación de elementos. --------------------------------------
	local estado_elementos_ant = {CONTROL.CUSTOM_LIST; CONTROL.CUSTOM_ART1; CONTROL.CUSTOM_ART2; CONTROL.CUSTOM_FLOW;
	CONTROL.CUSTOM_LOGO; CONTROL.CUSTOM_BUTTON_X; CONTROL.CUSTOM_BUTTON_T; CONTROL.CUSTOM_BUTTON_S; CONTROL.CUSTOM_BUTTON_L1;
	CONTROL.CUSTOM_BUTTON_R1; CONTROL.CUSTOM_BUTTON_R3; CONTROL.CUSTOM_BUTTON_STA; CONTROL.CUSTOM_BUTTON_SEL;
	CONTROL.CUSTOM_SPRITE;};

	-- Nuevos estados de activación de elementos. ---------------------------------------
	local selector_elementos = 1
	local estado_elementos_new = {CONTROL.CUSTOM_LIST; CONTROL.CUSTOM_ART1; CONTROL.CUSTOM_ART2; CONTROL.CUSTOM_FLOW;
	CONTROL.CUSTOM_LOGO; CONTROL.CUSTOM_BUTTON_X; CONTROL.CUSTOM_BUTTON_T; CONTROL.CUSTOM_BUTTON_S; CONTROL.CUSTOM_BUTTON_L1;
	CONTROL.CUSTOM_BUTTON_R1; CONTROL.CUSTOM_BUTTON_R3; CONTROL.CUSTOM_BUTTON_STA; CONTROL.CUSTOM_BUTTON_SEL; CONTROL.CUSTOM_SPRITE;};

	-- Lista con los nombres de objetos y opciones extras. ------------------------------
	local nombres_opciones = {TEXT_M_STI[12]; TEXT_M_STI[13]; TEXT_M_STI[14]; TEXT_M_STI[15]; TEXT_M_STI[16]; TEXT_M_STI[17];
	TEXT_M_STI[18]; TEXT_M_STI[19]; TEXT_M_STI[20]; TEXT_M_STI[21]; TEXT_M_STI[22]; TEXT_M_STI[23]; TEXT_M_STI[24];
	TEXT_M_STI[25]; TEXT_M_STI[26]; TEXT_M_STI[27]; TEXT_M_STI[28]; TEXT_M_STI[29];};
	local nombres_acciones = {TEXT_M_STI[30]; TEXT_M_STI[31]; TEXT_M_STI[32]; TEXT_M_STI[33]; TEXT_M_STI[34];
	TEXT_M_STI[35]; TEXT_M_STI[36]; TEXT_M_STI[37]; TEXT_M_STI[38]; TEXT_M_STI[39]; TEXT_M_STI[40];};

	-- Lista para fijar el estado de elementos durante la edición. ----------------------
	local fijar = {false, false, false, false, false, false, false, false, false, false, false, false, false, false}

	-- Configuración de restauración completa. ------------------------------------------
	local restaura_estado = {true; true; false; false; true; true; true; true; true; true; true; true; true; false;};
	local restaura_pos = {30; 90; 358; 92; 358; 92; 30; 92; 194; 5; 273; 391; 44; 391; 475; 391; 144; 28; 464; 28; 260; 391; 423; 415; 45; 415; 286; 288;};
	local restaura_tam = {310; 290; 250; 193; 250; 193; 160; 103; 252; 76; 69; 92;};

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
	CONTROL.X_BUTTON_SEL; CONTROL.Y_BUTTON_SEL;
	CONTROL.SPRITE_ANCHO; CONTROL.SPRITE_ALTO-CONTROL.Y_FIX_PAL;};
	local elementos_tam_ant = {
	CONTROL.LISTA_X; CONTROL.LISTA_Y;
	CONTROL.IMG_X; CONTROL.IMG_Y;
	CONTROL.IMG_X_2; CONTROL.IMG_Y_2;
	CONTROL.FLOW_X; CONTROL.FLOW_Y;
	CONTROL.LOGO_X; CONTROL.LOGO_Y;
	CONTROL.SPRITE_X; CONTROL.SPRITE_Y;};

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
	CONTROL.X_BUTTON_SEL; CONTROL.Y_BUTTON_SEL;
	CONTROL.SPRITE_ANCHO; CONTROL.SPRITE_ALTO-CONTROL.Y_FIX_PAL;};
	local elementos_tam_new = {
	CONTROL.LISTA_X; CONTROL.LISTA_Y;
	CONTROL.IMG_X; CONTROL.IMG_Y;
	CONTROL.IMG_X_2; CONTROL.IMG_Y_2;
	CONTROL.FLOW_X; CONTROL.FLOW_Y;
	CONTROL.LOGO_X; CONTROL.LOGO_Y;
	CONTROL.SPRITE_X; CONTROL.SPRITE_Y;};

	-- Largo de la lista de juegos. -----------------------------------------------------
	local largo_lista = LISTAS.ELEMENTOS_LIST
	local anterior_anim, anterior_anim_vel = CONTROL.CUSTOM_ANIM, CONTROL.ANIM_VELOCIDAD
	local cov_x_asp, cov_y_asp, cov_x_fix, cov_y_fix = fix_art_edit(elementos_tam_new[3], elementos_tam_new[4], LISTAS.COVER_DEFAULT)
	local scr_x_asp, scr_y_asp, scr_x_fix, scr_y_fix = fix_art_edit(elementos_tam_new[5], elementos_tam_new[6], LISTAS.SCREENSHOT_DEFAULT)
	local flo_x_asp, flo_y_asp, flo_x_fix, flo_y_fix = fix_art_edit(elementos_tam_new[7], elementos_tam_new[8], LISTAS.COVER_DEFAULT)
	local lis_ext = {cov_x_asp; cov_y_asp; cov_x_fix; cov_y_fix; scr_x_asp; scr_y_asp; scr_x_fix; scr_y_fix; flo_x_asp; flo_y_asp; flo_x_fix; flo_y_fix;}
	local function set_aspect()
		cov_x_asp, cov_y_asp, cov_x_fix, cov_y_fix = fix_art_edit(elementos_tam_new[3], elementos_tam_new[4], LISTAS.COVER_DEFAULT)
		scr_x_asp, scr_y_asp, scr_x_fix, scr_y_fix = fix_art_edit(elementos_tam_new[5], elementos_tam_new[6], LISTAS.SCREENSHOT_DEFAULT)
		flo_x_asp, flo_y_asp, flo_x_fix, flo_y_fix = fix_art_edit(elementos_tam_new[7], elementos_tam_new[8], LISTAS.COVER_DEFAULT)
		lis_ext = {cov_x_asp; cov_y_asp; cov_x_fix; cov_y_fix; scr_x_asp; scr_y_asp; scr_x_fix; scr_y_fix; flo_x_asp; flo_y_asp; flo_x_fix; flo_y_fix;}
	end

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
		dibujar_demo(selector_elementos, elementos_pos_new, elementos_tam_new, cambio_tama_pos, fijar, largo_lista, estado_elementos_new, lis_ext)

		-- Dibujar líneas de guía. ------------------------------------------------------
		if act_reglas >= 1 then
			reglas(elementos_pos_new[selector_X_Y], elementos_pos_new[selector_X_Y+1], act_reglas, selector_elementos, false)
		end

		-- Reubicar la ayuda en pantalla. -----------------------------------------------
		local hud_Y, hud_X, hud_alto, fix_hud, r_pos_Y = 0, 0, 102, 0, 102
		local tex_x, tex_y = reglas(elementos_pos_new[selector_X_Y], elementos_pos_new[selector_X_Y+1], act_reglas, selector_elementos, true)
		if hud == false then
			hud_alto, fix_hud, r_pos_Y = 42, 52, 42
		end
		if (elementos_pos_new[selector_X_Y] <= CONTROL.ANCHO//2 and cambio_tama_pos == false) or ((selector_elementos <= 5 or selector_elementos == 14) and elementos_pos_new[selector_X_Y]+elementos_tam_new[parche(selector_X_Y)] <= CONTROL.ANCHO//2 and cambio_tama_pos == true) then
			hud_X = CONTROL.ANCHO-(CONTROL.ANCHO//2)+fix_hud
		end
		if (elementos_pos_new[selector_X_Y+1] <= CONTROL.ALTO_F//2 and cambio_tama_pos == false) or ((selector_elementos <= 5 or selector_elementos == 14) and elementos_pos_new[selector_X_Y+1]+elementos_tam_new[parche(selector_X_Y)+1] <= CONTROL.ALTO_F//2 and cambio_tama_pos == true) then
			hud_Y = CONTROL.ALTO_F-(hud_alto)-2
			r_pos_Y = hud_Y-25
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
			if cambio_tama_pos == true and (selector_elementos <= 5 or selector_elementos == 14) then
				Font.ftPrint(FONT_CNF, hud_X+29, hud_Y+63, 0, CONTROL.ANCHO//2, 20, nombres_acciones[3], COLOR.BLANCO)
			else
				Font.ftPrint(FONT_CNF, hud_X+29, hud_Y+63, 0, CONTROL.ANCHO//2, 20, nombres_acciones[4], COLOR.BLANCO)
			end
			Graphics.drawScaleImage(PAD_IMG.R2, hud_X+160, hud_Y+60, 25, 25)
			Font.ftPrint(FONT_CNF, hud_X+188, hud_Y+63, 0, CONTROL.ANCHO//2, 20, nombres_acciones[5] ..":".. velocidad, COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.TRIANGLE, hud_X+6, hud_Y+83, 16, 16)
			Font.ftPrint(FONT_CNF, hud_X+28, hud_Y+81, 0, CONTROL.ANCHO//2, 20, nombres_acciones[2], COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.START, hud_X+161, hud_Y+78, 25, 25)
			Font.ftPrint(FONT_CNF, hud_X+188, hud_Y+81, 0, CONTROL.ANCHO//2, 20, nombres_acciones[11], COLOR.BLANCO)
			if act_reglas >= 1 then
				Graphics.drawRect(hud_X, r_pos_Y, CONTROL.ANCHO//2, 25, Color.new(117, 117, 117))
				Graphics.drawRect(hud_X+2, r_pos_Y+2, (CONTROL.ANCHO//2)-4, 25-4, Color.new(20, 20, 20))
				Font.ftPrint(FONT_CNF, hud_X+28, r_pos_Y+3, 0, CONTROL.ANCHO//2, 20, "X: ".. tex_x, COLOR.BLANCO)
				Font.ftPrint(FONT_CNF, hud_X+140, r_pos_Y+3, 0, CONTROL.ANCHO//2, 20, "Y: ".. tex_y, COLOR.BLANCO)
			end
		elseif hud == false and submenu == false then
			Graphics.drawRect(hud_X, hud_Y, (CONTROL.ANCHO//2)-52, hud_alto, Color.new(117, 117, 117))
			Graphics.drawRect(hud_X+2, hud_Y+2, (CONTROL.ANCHO//2)-56, hud_alto-4, Color.new(20, 20, 20))
			Graphics.drawScaleImage(PAD_IMG.SQUARE, hud_X+6, hud_Y+5, 16, 16)
			Font.ftPrint(FONT_CNF, hud_X+28, hud_Y+3, 0, CONTROL.ANCHO//2, 20, nombres_acciones[9], COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.START, hud_X+112, hud_Y, 25, 25)
			Font.ftPrint(FONT_CNF, hud_X+140, hud_Y+3, 0, CONTROL.ANCHO//2, 20, TEXT_GEN[12], COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.SELECT_S, hud_X+6, hud_Y+17, 25, 25)
			Font.ftPrint(FONT_CNF, hud_X+28, hud_Y+19, 0, CONTROL.ANCHO//2, 20, TEXT_M_STI[41], COLOR.BLANCO)
			Graphics.drawScaleImage(PAD_IMG.R2, hud_X+112, hud_Y+16, 25, 25)
			Font.ftPrint(FONT_CNF, hud_X+140, hud_Y+19, 0, CONTROL.ANCHO//2, 20, TEXT_M_STI[42] ..":".. velocidad, COLOR.BLANCO)
			if act_reglas >= 1 then
				Graphics.drawRect(hud_X, r_pos_Y, (CONTROL.ANCHO//2)-52, 25, Color.new(117, 117, 117))
				Graphics.drawRect(hud_X+2, r_pos_Y+2, (CONTROL.ANCHO//2)-56, 25-4, Color.new(20, 20, 20))
				Font.ftPrint(FONT_CNF, hud_X+28, r_pos_Y+3, 0, CONTROL.ANCHO//2, 20, "X: ".. tex_x, COLOR.BLANCO)
				Font.ftPrint(FONT_CNF, hud_X+140, r_pos_Y+3, 0, CONTROL.ANCHO//2, 20, "Y: ".. tex_y, COLOR.BLANCO)
			end
		end

		-- Controlar el menú de edición. ------------------------------------------------
		if submenu == false then
			-- Mostrar submenú de elementos. --------------------------------------------
			if Pads.check(PAD, PAD_SELECT) and CONTROL.JOYSTICK_ON == false then
				submenu = true
				repro_sfx(S_EJECUTAR, 1, false, nil)
				JOYSTICK_LIMITE = control_FPS(1)

			-- Guardar configuración. ---------------------------------------------------
			elseif Pads.check(PAD, PAD_START) and CONTROL.JOYSTICK_ON == false then
				repro_sfx(S_EJECUTAR, 1, false, nil)
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
				JOYSTICK_LIMITE = control_FPS(1)

			-- Salir del editor. --------------------------------------------------------
			elseif Pads.check(PAD, PAD_CIRCLE) and CONTROL.JOYSTICK_ON == false then
				salida = true
				JOYSTICK_LIMITE = control_FPS(1)

			-- Cambiar entre los elementos en pantalla. ---------------------------------
			elseif (Pads.check(PAD, PAD_L1) or Pads.check(PAD, PAD_R1)) and CONTROL.JOYSTICK_ON == false then
				local lado_elemento = false
				if Pads.check(PAD, PAD_R1) then
					lado_elemento = true
				end
				selector_X_Y, selector_elementos = estado(selector_X_Y, selector_elementos, lado_elemento, estado_elementos_new)
				cambio_tama_pos = false
				repro_sfx(S_EJECUTAR, 1, false, nil)
				JOYSTICK_LIMITE = control_FPS(1)

			-- Intercambiar menú de ayuda en pantalla. ----------------------------------
			elseif Pads.check(PAD, PAD_SQUARE) and CONTROL.JOYSTICK_ON == false then
				if hud == false then
					hud = true
				else
					hud = false
				end
				repro_sfx(S_EJECUTAR, 1, false, nil)
				JOYSTICK_LIMITE = control_FPS(1)

			-- Activar / desactivar las líneas de guía en pantalla. ---------------------
			elseif Pads.check(PAD, PAD_TRIANGLE) and CONTROL.JOYSTICK_ON == false then
				act_reglas = cambiar_valor(act_reglas, 0, 4, 1, true)
				repro_sfx(S_EJECUTAR, 1, false, nil)
				JOYSTICK_LIMITE = control_FPS(1)

			-- Fijar un elemento para evitar su edición. --------------------------------
			elseif Pads.check(PAD, PAD_CROSS) and CONTROL.JOYSTICK_ON == false then
				if fijar[selector_elementos] == false then
					fijar[selector_elementos] = true
				else
					fijar[selector_elementos] = false
				end
				repro_sfx(S_EJECUTAR, 1, false, nil)
				JOYSTICK_LIMITE = control_FPS(1)

			-- Restaura el elemento a su última posición guardada. ----------------------
			elseif Pads.check(PAD, PAD_R3) and CONTROL.JOYSTICK_ON == false and fijar[selector_elementos] == false then
				elementos_pos_new[selector_X_Y] = elementos_pos_ant[selector_X_Y]
				elementos_pos_new[selector_X_Y+1] = elementos_pos_ant[selector_X_Y+1]
				if (selector_elementos <= 5 or selector_elementos == 14) then
					elementos_tam_new[parche(selector_X_Y)] = elementos_tam_ant[parche(selector_X_Y)]
					elementos_tam_new[parche(selector_X_Y)+1] = elementos_tam_ant[parche(selector_X_Y)+1]
				end
				set_aspect()
				repro_sfx(S_CANCELAR, 1, false, nil)
				JOYSTICK_LIMITE = control_FPS(1)

			-- Ver controles del editor. ------------------------------------------------
			elseif Pads.check(PAD, PAD_L3) and CONTROL.JOYSTICK_ON == false then
				repro_sfx(S_EJECUTAR, 1, false, nil)
				ver_controles(true)

			-- Cambia las posiciones y tamaños de los elementos. ------------------------
			elseif (Pads.check(PAD, PAD_DOWN) or Pads.check(PAD, PAD_UP) or Pads.check(PAD, PAD_LEFT) or Pads.check(PAD, PAD_RIGHT) or stick_moved(Left_Y) or stick_moved(Left_X) or Pads.check(PAD, PAD_L2) or Pads.check(PAD, PAD_R2)) and CONTROL.JOYSTICK_ON == false then
				-- Cambiar el salto de píxeles. -----------------------------------------
				if Pads.check(PAD, PAD_R2) then
					velocidad = cambiar_valor(velocidad, 1, 10, 1, true)
				end

				-- Intercambiar entre cambio de posición o tamaño. ----------------------
				if Pads.check(PAD, PAD_L2) and cambio_tama_pos == false and (selector_elementos <= 5 or selector_elementos == 14) then
					cambio_tama_pos = true
				elseif Pads.check(PAD, PAD_L2) and cambio_tama_pos == true and (selector_elementos <= 5 or selector_elementos == 14) then
					cambio_tama_pos = false
				end

				-- Realizar los movimientos de posicionamiento y redimensión. -----------
				if (Pads.check(PAD, PAD_UP) or Left_Y <= -90) and cambio_tama_pos == true and (selector_elementos <= 5 or selector_elementos == 14) and fijar[selector_elementos] == false then
					elementos_tam_new[parche(selector_X_Y)+1] = cambiar_valor(elementos_tam_new[parche(selector_X_Y)+1], 48, ((CONTROL.ALTO_F-CONTROL.Y_FIX_PAL)-elementos_pos_new[selector_X_Y+1]), velocidad, false)
				elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) and cambio_tama_pos == true and (selector_elementos <= 5 or selector_elementos == 14) and fijar[selector_elementos] == false then
					elementos_tam_new[parche(selector_X_Y)+1] = cambiar_valor(elementos_tam_new[parche(selector_X_Y)+1], 48, ((CONTROL.ALTO_F-CONTROL.Y_FIX_PAL)-elementos_pos_new[selector_X_Y+1]), velocidad, true)
				elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and cambio_tama_pos == true and (selector_elementos <= 5 or selector_elementos == 14) and fijar[selector_elementos] == false then
					elementos_tam_new[parche(selector_X_Y)] = cambiar_valor(elementos_tam_new[parche(selector_X_Y)], 48, (CONTROL.ANCHO-elementos_pos_new[selector_X_Y]), velocidad, false)
				elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and cambio_tama_pos == true and (selector_elementos <= 5 or selector_elementos == 14) and fijar[selector_elementos] == false then
					elementos_tam_new[parche(selector_X_Y)] = cambiar_valor(elementos_tam_new[parche(selector_X_Y)], 48, (CONTROL.ANCHO-elementos_pos_new[selector_X_Y]), velocidad, true)
				elseif (Pads.check(PAD, PAD_UP) or Left_Y <= -90) and fijar[selector_elementos] == false then
					elementos_pos_new[selector_X_Y+1] = cambiar_valor(elementos_pos_new[selector_X_Y+1], 0, (CONTROL.ALTO_F-(CONTROL.Y_FIX_PAL*2)), velocidad, false)
				elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) and fijar[selector_elementos] == false then
					elementos_pos_new[selector_X_Y+1] = cambiar_valor(elementos_pos_new[selector_X_Y+1], 0, (CONTROL.ALTO_F-(CONTROL.Y_FIX_PAL*2)), velocidad, true)
				elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and fijar[selector_elementos] == false then
					elementos_pos_new[selector_X_Y] = cambiar_valor(elementos_pos_new[selector_X_Y], 0, CONTROL.ANCHO, velocidad, false)
				elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and fijar[selector_elementos] == false then
					elementos_pos_new[selector_X_Y] = cambiar_valor(elementos_pos_new[selector_X_Y], 0, CONTROL.ANCHO, velocidad, true)
				end
				if cambio_tama_pos == true then
					set_aspect()
				end
				local kabal = 1 if (stick_moved(Left_Y) or stick_moved(Left_X)) and not (Pads.check(PAD, PAD_R2) or Pads.check(PAD, PAD_L2)) then
					kabal = 2
				end
				if Pads.check(PAD, PAD_R2) or Pads.check(PAD, PAD_L2) then
					repro_sfx(S_EJECUTAR, 1, false, nil)
				elseif kabal == 1 then
					repro_sfx(S_MOVER, 1, false, nil)
				end
				JOYSTICK_LIMITE = control_FPS(kabal)
			end

		-- Muestra submenú de elementos. ------------------------------------------------
		else
			-- Dibujar las opciones del submenú y su estado. ----------------------------
			Graphics.drawRect((CONTROL.ANCHO//2), 0, 320, CONTROL.ALTO_F, Color.new(117, 117, 117))
			Graphics.drawRect((CONTROL.ANCHO//2)+2, 2, 316, CONTROL.ALTO_F-4, Color.new(20, 20, 20))
			Font.ftPrint(FONT_CNF, (CONTROL.ANCHO//2)+160, 12+CONTROL.Y_FIX_PAL, 8, 320, 21, "-".. TEXT_M_STI[43] .."-", COLOR.BLANCO)
			local espacio_linea = 12+((0)*21)+CONTROL.Y_FIX_PAL
			local art_shadow, art_sprite = TEXT_GEN[3], TEXT_GEN[2]
			if CONTROL.CUSTOM_BACK == false then
				art_shadow = TEXT_GEN[2]
			end
			if estado_elementos_new[14] == true then
				art_sprite = TEXT_GEN[3]
			end
			for elementos = 1, 13 do
				espacio_linea = 12+((elementos)*21)+CONTROL.Y_FIX_PAL
				local estado_on = TEXT_GEN[2]
				if estado_elementos_new[elementos] == true then
					estado_on = TEXT_GEN[3]
				end
				if selector_submenu == elementos then
					Graphics.drawRect((CONTROL.ANCHO//2)+9, espacio_linea-2, 302, 23, COLOR.BLANCO)
					Graphics.drawRect((CONTROL.ANCHO//2)+11, espacio_linea, 298, 19, Color.new(30, 30, 30))
					Font.ftPrint(FONT_CNF, (CONTROL.ANCHO//2)+13, espacio_linea, 0, 320, 21, nombres_opciones[elementos], COLOR.BLANCO)
					Font.ftPrint(FONT_CNF, CONTROL.ANCHO-52, espacio_linea, 0, 320, 21, estado_on, COLOR.BLANCO)
				else
					Font.ftPrint(FONT_CNF, (CONTROL.ANCHO//2)+13, espacio_linea, 0, 320, 21, nombres_opciones[elementos], COLOR.GRIS)
					Font.ftPrint(FONT_CNF, CONTROL.ANCHO-52, espacio_linea, 0, 320, 21, estado_on, COLOR.GRIS)
				end
				if elementos == 1 then
					Graphics.drawScaleImage(PAD_IMG.R1, CONTROL.ANCHO-234, espacio_linea-3, 25, 25)
					Font.ftPrint(FONT_CNF, CONTROL.ANCHO-204, espacio_linea, 0, 320, 21, "SPRITE ".. art_sprite, Color.new(30, 30, 30))
				end
				if elementos == 2 then
					Graphics.drawScaleImage(PAD_IMG.R1, CONTROL.ANCHO-234, espacio_linea-3, 25, 25)
					Font.ftPrint(FONT_CNF, CONTROL.ANCHO-204, espacio_linea, 0, 320, 21, TEXT_M_STI[44] .." ".. art_shadow, Color.new(30, 30, 30))
				end
			end
			Font.ftPrint(FONT_CNF, (CONTROL.ANCHO//2)+160, 304+CONTROL.Y_FIX_PAL, 8, 320, 21, "-".. TEXT_M_STI[45] .."-", COLOR.BLANCO)
			local espacio_linea2 = 33+((0)*21)+CONTROL.Y_FIX_PAL
			for elementos = 14, #nombres_opciones do
				espacio_linea2 = 33+((elementos)*21)+CONTROL.Y_FIX_PAL
				if selector_submenu == elementos then
					Graphics.drawRect((CONTROL.ANCHO//2)+9, espacio_linea2-2, 302, 23, COLOR.BLANCO)
					Graphics.drawRect((CONTROL.ANCHO//2)+11, espacio_linea2, 298, 19, Color.new(30, 30, 30))
					Font.ftPrint(FONT_CNF, (CONTROL.ANCHO//2)+13, espacio_linea2, 0, 320, 21, nombres_opciones[elementos], COLOR.BLANCO)
					if elementos == 14 then
						Font.ftPrint(FONT_CNF, CONTROL.ANCHO-52, espacio_linea2, 0, 320, 21, CONTROL.CUSTOM_ANIM, COLOR.BLANCO)
					elseif elementos == 15 then
						Font.ftPrint(FONT_CNF, CONTROL.ANCHO-52, espacio_linea2, 0, 320, 21, CONTROL.ANIM_VELOCIDAD, COLOR.BLANCO)
					end
				else
					Font.ftPrint(FONT_CNF, (CONTROL.ANCHO//2)+13, espacio_linea2, 0, 320, 21, nombres_opciones[elementos], COLOR.GRIS)
					if elementos == 14 then
						Font.ftPrint(FONT_CNF, CONTROL.ANCHO-52, espacio_linea2, 0, 320, 21, CONTROL.CUSTOM_ANIM, COLOR.GRIS)
					elseif elementos == 15 then
						Font.ftPrint(FONT_CNF, CONTROL.ANCHO-52, espacio_linea2, 0, 320, 21, CONTROL.ANIM_VELOCIDAD, COLOR.GRIS)
					end
				end
			end

			-- Salir del submenú. -------------------------------------------------------
			if (Pads.check(PAD, PAD_SELECT) or Pads.check(PAD, PAD_TRIANGLE) or Pads.check(PAD, PAD_CIRCLE)) and CONTROL.JOYSTICK_ON == false then
				submenu = false
				repro_sfx(S_EJECUTAR, 1, false, nil)
				selector_X_Y, selector_elementos = estado(selector_X_Y, selector_elementos, nil, estado_elementos_new)
				JOYSTICK_LIMITE = control_FPS(1)

			-- Moverse entre los elementos del submenú. ---------------------------------
			elseif (Pads.check(PAD, PAD_DOWN) or Pads.check(PAD, PAD_UP) or stick_moved(Left_Y)) and CONTROL.JOYSTICK_ON == false then
				if (Pads.check(PAD, PAD_UP) or Left_Y <= -90) then
					selector_submenu = cambiar_valor(selector_submenu, 1, #nombres_opciones, 1, false)
				elseif (Pads.check(PAD, PAD_DOWN) or Left_Y >= 90) then
					selector_submenu = cambiar_valor(selector_submenu, 1, #nombres_opciones, 1, true)
				end
				repro_sfx(S_MOVER, 1, false, nil)
				JOYSTICK_LIMITE = control_FPS(1)

			-- Activa y desactiva las sombras tras el arte. -----------------------------
			elseif Pads.check(PAD, PAD_R1) and estado_elementos_new[2] == true and selector_submenu == 2 and CONTROL.JOYSTICK_ON == false then
				repro_sfx(S_EJECUTAR, 1, false, nil)
				if CONTROL.CUSTOM_BACK == true then
					CONTROL.CUSTOM_BACK = false
				else
					CONTROL.CUSTOM_BACK = true
				end
				JOYSTICK_LIMITE = control_FPS(1)

			-- Activa y desactiva los sprites. ------------------------------------------
			elseif Pads.check(PAD, PAD_R1) and selector_submenu == 1 and CONTROL.JOYSTICK_ON == false then
				repro_sfx(S_EJECUTAR, 1, false, nil)
				if estado_elementos_new[14] == true then
					estado_elementos_new[14] = false
				else
					estado_elementos_new[14] = true
				end
				JOYSTICK_LIMITE = control_FPS(1)

			-- Cambiar el estado de los elementos del submenú. --------------------------
			elseif (Pads.check(PAD, PAD_CROSS) or Pads.check(PAD, PAD_LEFT) or Pads.check(PAD, PAD_RIGHT) or stick_moved(Left_X)) and CONTROL.JOYSTICK_ON == false then
				-- Activar / desactivar elemento. ---------------------------------------
				repro_sfx(S_EJECUTAR, 1, false, nil)
				if ((Pads.check(PAD, PAD_LEFT) or Left_X <= -90) or (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) or Pads.check(PAD, PAD_CROSS)) and selector_submenu <= 13 then
					if estado_elementos_new[selector_submenu] == false then
						estado_elementos_new[selector_submenu] = true
					else
						estado_elementos_new[selector_submenu] = false
					end

				-- Vista previa de la animación de transición. --------------------------
				elseif Pads.check(PAD, PAD_CROSS) and selector_submenu == 14 then
					Pads.rumble(0, 0, 0)
					animaciones(true, false)

				-- Cambiar entre las animaciones de transición disponibles. -------------
				elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and selector_submenu == 14 then
					CONTROL.CUSTOM_ANIM = cambiar_valor(CONTROL.CUSTOM_ANIM, 1, 15, 1, false)
				elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and selector_submenu == 14 then
					CONTROL.CUSTOM_ANIM = cambiar_valor(CONTROL.CUSTOM_ANIM, 1, 15, 1, true)

				-- Cambiar la velocidad de las animaciones de transición. ---------------
				elseif (Pads.check(PAD, PAD_LEFT) or Left_X <= -90) and selector_submenu == 15 then
					CONTROL.ANIM_VELOCIDAD = cambiar_valor(CONTROL.ANIM_VELOCIDAD, 10, 50, 1, false)
				elseif (Pads.check(PAD, PAD_RIGHT) or Left_X >= 90) and selector_submenu == 15 then
					CONTROL.ANIM_VELOCIDAD = cambiar_valor(CONTROL.ANIM_VELOCIDAD, 10, 50, 1, true)

				-- Reiniciar todas las posiciones y tamaños a los de por defecto. -------
				elseif Pads.check(PAD, PAD_CROSS) and selector_submenu == 16 then
					local confirmar = false
					local pregunta_res = true
					local lista_resp = {TEXT_GEN[11], TEXT_GEN[6]}
					submenu_selector({}, nil, "- ".. TEXT_M_STI[46] .." -", 160, 202, true, CONTROL.ANCHO//2, lista_resp, false, false, {}, nil)
					refrescar(false)
					while pregunta_res do
						capturar(JOYSTICK_LIMITE)
						if Pads.check(PAD, PAD_SQUARE) then
							confirmar = true
							pregunta_res = false
							repro_sfx(S_EJECUTAR, 1, false, nil)
						elseif Pads.check(PAD, PAD_TRIANGLE) then
							confirmar = false
							pregunta_res = false
							repro_sfx(S_CANCELAR, 1, false, nil)
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
						CONTROL.CUSTOM_BACK = true
						set_aspect()
					end

				-- Guardar configuración. -----------------------------------------------
				elseif Pads.check(PAD, PAD_CROSS) and selector_submenu == 17 then
					repro_sfx(S_EJECUTAR, 1, false, nil)
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
				JOYSTICK_LIMITE = control_FPS(1)
			end
		end

		-- Confirmar la salida del editor. ----------------------------------------------
		if salida == true then
			repro_sfx(S_CANCELAR, 1, false, nil)
			local cambio_realizado = false
			for chequeo1 = 1, #estado_elementos_new do
				if estado_elementos_new[chequeo1] ~= estado_elementos_ant[chequeo1] then
					cambio_realizado = true
				end
			end
			for chequeo2 = 1, #elementos_pos_new do
				if elementos_pos_new[chequeo2] ~= elementos_pos_ant[chequeo2] then
					cambio_realizado = true
				end
			end
			for chequeo3 = 1, #elementos_tam_new do
				if elementos_tam_new[chequeo3] ~= elementos_tam_ant[chequeo3] then
					cambio_realizado = true
				end
			end
			if CONTROL.CUSTOM_ANIM ~= anterior_anim or CONTROL.ANIM_VELOCIDAD ~= anterior_anim_vel then
				cambio_realizado = true
			end
			if cambio_realizado == true then
				local pregunta = true
				local lista_resp = {TEXT_GEN[7], TEXT_GEN[6]}
				submenu_selector({TEXT_M_CON[27]}, nil, TEXT_M_CON[26], 160, 226, true, CONTROL.ANCHO//2, lista_resp, false, false, {}, nil)
				refrescar(false)
				while pregunta do
					capturar(JOYSTICK_LIMITE)
					if Pads.check(PAD, PAD_SQUARE) then
						CONTROL.CUSTOM_ANIM, CONTROL.ANIM_VELOCIDAD = anterior_anim, anterior_anim_vel
						editar = false
						pregunta = false
					elseif Pads.check(PAD, PAD_TRIANGLE) then
						repro_sfx(S_CANCELAR, 1, false, nil)
						pregunta = false
						salida = false
					end
					refrescar(true)
				end
			else
				editar = false
			end
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
	-- Define y guarda las opciones por defecto. ----------------------------------------
	local function custom_style_default()
		CONTROL.IMG_ANCHO = 358; CONTROL.IMG_X = 250; CONTROL.IMG_ALTO = 92; CONTROL.IMG_Y = 193;
		CONTROL.IMG_ANCHO_2 = 358; CONTROL.IMG_X_2 = 250; CONTROL.IMG_ALTO_2 = 92; CONTROL.IMG_Y_2 = 193;
		CONTROL.LISTA_ANCHO = 30; CONTROL.LISTA_X = 310; CONTROL.LISTA_ALTO = 90; CONTROL.LISTA_Y = 290;
		CONTROL.LOGO_ANCHO = 194; CONTROL.LOGO_X = 252; CONTROL.LOGO_ALTO = 5; CONTROL.LOGO_Y = 76;
		CONTROL.FLOW_ANCHO = 30; CONTROL.FLOW_X = 160; CONTROL.FLOW_ALTO = 92; CONTROL.FLOW_Y = 103;
		CONTROL.FLOW_ANCHO_2 = 30; CONTROL.FLOW_X_2 = 160; CONTROL.FLOW_ALTO_2 = 92; CONTROL.FLOW_Y_2 = 103;
		CONTROL.X_BUTTON_X = 273; CONTROL.Y_BUTTON_X = 391; CONTROL.X_BUTTON_T = 44; CONTROL.Y_BUTTON_T = 391;
		CONTROL.X_BUTTON_S = 475; CONTROL.Y_BUTTON_S = 391; CONTROL.X_BUTTON_L1 = 144; CONTROL.Y_BUTTON_L1 = 28;
		CONTROL.X_BUTTON_R1 = 464; CONTROL.Y_BUTTON_R1 = 28; CONTROL.X_BUTTON_R3 = 260; CONTROL.Y_BUTTON_R3 = 391;
		CONTROL.X_BUTTON_STA = 423; CONTROL.Y_BUTTON_STA = 415; CONTROL.X_BUTTON_SEL = 45; CONTROL.Y_BUTTON_SEL = 415;
		CONTROL.CUSTOM_ANIM = 1; CONTROL.ANIM_VELOCIDAD = 29;
		CONTROL.CUSTOM_LIST = true; CONTROL.CUSTOM_ART1 = true; CONTROL.CUSTOM_ART2 = false;
		CONTROL.CUSTOM_FLOW = false; CONTROL.CUSTOM_LOGO = true; CONTROL.CUSTOM_BUTTON_X = true;
		CONTROL.CUSTOM_BUTTON_T = true; CONTROL.CUSTOM_BUTTON_S = true; CONTROL.CUSTOM_BUTTON_L1 = true;
		CONTROL.CUSTOM_BUTTON_R1 = true; CONTROL.CUSTOM_BUTTON_R3 = true; CONTROL.CUSTOM_BUTTON_STA = true;
		CONTROL.CUSTOM_BUTTON_SEL = true; CONTROL.CUSTOM_BACK = true;
		LISTAS.ELEMENTOS_LIST = 11;
		CONTROL.SPRITE_ANCHO = 286; CONTROL.SPRITE_X = 69; CONTROL.SPRITE_ALTO = 288; CONTROL.SPRITE_Y = 92;
		CONTROL.CUSTOM_SPRITE = false;
	end
	local function activ_opt(valor)
		local resultado = false
		if valor == 1 then
			resultado = true
		end
		return resultado
	end

	-- Cargar opciones guardadas. -------------------------------------------------------
	local actual = System.currentDirectory()
	if doesFileExist(actual .."/System/Config/style.cfg") then
		local carga_de_style = System.openFile(actual .."/System/Config/style.cfg", FREAD)
		System.seekFile(carga_de_style, 0, SET)
		local size_config = System.sizeFile(carga_de_style)
		local temp2 = System.readFile(carga_de_style, size_config)
		System.closeFile(carga_de_style)
		local lista_style = {}
		lista_style = sub_string(temp2, "%d+", lista_style, true)
		if lista_style ~= nil and #lista_style == 62 then
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
			if lista_style[41] <= 15 and lista_style[1] >= 1 then
				CONTROL.CUSTOM_ANIM = lista_style[41];
			else
				CONTROL.CUSTOM_ANIM = 1;
			end
			if lista_style[42] <= 50 and lista_style[1] >= 10 then
				CONTROL.ANIM_VELOCIDAD = lista_style[42];
			else
				CONTROL.ANIM_VELOCIDAD = 29;
			end
			CONTROL.CUSTOM_LIST = activ_opt(lista_style[43])
			CONTROL.CUSTOM_ART1 = activ_opt(lista_style[44])
			CONTROL.CUSTOM_ART2 = activ_opt(lista_style[45])
			CONTROL.CUSTOM_FLOW = activ_opt(lista_style[46])
			CONTROL.CUSTOM_LOGO = activ_opt(lista_style[47])
			CONTROL.CUSTOM_BUTTON_X = activ_opt(lista_style[48])
			CONTROL.CUSTOM_BUTTON_T = activ_opt(lista_style[49])
			CONTROL.CUSTOM_BUTTON_S = activ_opt(lista_style[50])
			CONTROL.CUSTOM_BUTTON_L1 = activ_opt(lista_style[51])
			CONTROL.CUSTOM_BUTTON_R1 = activ_opt(lista_style[52])
			CONTROL.CUSTOM_BUTTON_R3 = activ_opt(lista_style[53])
			CONTROL.CUSTOM_BUTTON_STA = activ_opt(lista_style[54])
			CONTROL.CUSTOM_BUTTON_SEL = activ_opt(lista_style[55])
			LISTAS.ELEMENTOS_LIST = lista_style[56];
			CONTROL.CUSTOM_BACK = activ_opt(lista_style[57])
			CONTROL.SPRITE_ANCHO = lista_style[58]; CONTROL.SPRITE_X = lista_style[59];
			CONTROL.SPRITE_ALTO = lista_style[60]; CONTROL.SPRITE_Y = lista_style[61];
			CONTROL.CUSTOM_SPRITE = activ_opt(lista_style[62])
		else
			custom_style_default()
		end
	else
		custom_style_default()
	end
	if fix_pal == true then
		CONTROL.LISTA_ALTO = CONTROL.LISTA_ALTO + CONTROL.Y_FIX_PAL
		CONTROL.IMG_ALTO = CONTROL.IMG_ALTO + CONTROL.Y_FIX_PAL
		CONTROL.LOGO_ALTO = CONTROL.LOGO_ALTO + CONTROL.Y_FIX_PAL
		CONTROL.IMG_ALTO_2 = CONTROL.IMG_ALTO_2 + CONTROL.Y_FIX_PAL
		CONTROL.FLOW_ALTO = CONTROL.FLOW_ALTO + CONTROL.Y_FIX_PAL
		CONTROL.FLOW_ALTO_2 = CONTROL.FLOW_ALTO_2 + CONTROL.Y_FIX_PAL
		CONTROL.SPRITE_ALTO = CONTROL.SPRITE_ALTO + CONTROL.Y_FIX_PAL
	end
end

--- Líneas para guardar el estilo personalizado. ----------------------------------------
function guardar_style(estado_elementos_new, elementos_pos_new, elementos_tam_new, largo_lista, FONT_CNF)
	local actual = System.currentDirectory()
	JOYSTICK_LIMITE = control_FPS(1)
	-- Confirmar el guardado. -----------------------------------------------------------
	local submenu_lista = {}
	submenu_lista = sub_string(TEXT_M_STI[48], "[^\n]+", submenu_lista, false)
	local lista_resp = {TEXT_GEN[12], TEXT_GEN[6]}
	submenu_selector(submenu_lista, nil, TEXT_M_STI[47], 160, 274, true, CONTROL.ANCHO//2, lista_resp, false, false, {}, nil)
	refrescar(false)
	local confirmar = false
	local pregunta = true
	while pregunta do
		capturar(JOYSTICK_LIMITE)
		if Pads.check(PAD, PAD_TRIANGLE) then
			pregunta = false
			repro_sfx(S_CANCELAR, 1, false, nil)
		elseif Pads.check(PAD, PAD_SQUARE) then
			confirmar = true
			pregunta = false
			repro_sfx(S_EJECUTAR, 1, false, nil)
		end
		refrescar(true)
	end

	-- Guardar la configuración. --------------------------------------------------------
	if confirmar == true then
		-- Reubicar posiciones de elementos desactivados. -------------------------------
		local n1, n2 = 1, 2
		if estado_elementos_new[1] == false then
			n1, n2 = 3, 4
		end
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
		if CONTROL.CUSTOM_BACK == true then
			table.insert(estado_binario, "1")
		else
			table.insert(estado_binario, "0")
		end

		-- Crear archivo de configuración para el estilo personalizado. -----------------
		local style_conf_final = ("".. elementos_pos_new[3] .." ".. elementos_tam_new[3] .." ".. elementos_pos_new[4] .." ".. elementos_tam_new[4] ..
		" ".. elementos_pos_new[5] .." ".. elementos_tam_new[5] .." ".. elementos_pos_new[6] .." ".. elementos_tam_new[6] .." ".. elementos_pos_new[1] ..
		" ".. elementos_tam_new[1] .." ".. elementos_pos_new[2] .." ".. elementos_tam_new[2] .." ".. elementos_pos_new[9] .." ".. elementos_tam_new[9] ..
		" ".. elementos_pos_new[10] .." ".. elementos_tam_new[10] .." ".. elementos_pos_new[7] .." ".. elementos_tam_new[7] .." ".. elementos_pos_new[8] ..
		" ".. elementos_tam_new[8] .." ".. (CONTROL.ANCHO-(elementos_pos_new[7]+elementos_tam_new[7])) .." ".. elementos_tam_new[7] ..
		" ".. elementos_pos_new[8] .." ".. elementos_tam_new[8] .." ".. elementos_pos_new[11] .." ".. elementos_pos_new[12] .." ".. elementos_pos_new[13] ..
		" ".. elementos_pos_new[14] .." ".. elementos_pos_new[15] .." ".. elementos_pos_new[16] .." ".. elementos_pos_new[17] .." ".. elementos_pos_new[18] ..
		" ".. elementos_pos_new[19] .." ".. elementos_pos_new[18] .." ".. elementos_pos_new[21] .." ".. elementos_pos_new[22] .." ".. elementos_pos_new[23] ..
		" ".. elementos_pos_new[24] .." ".. elementos_pos_new[25] .." ".. elementos_pos_new[26] .." ".. CONTROL.CUSTOM_ANIM .." ".. CONTROL.ANIM_VELOCIDAD ..
		" ".. estado_binario[1] .." ".. estado_binario[2] .." ".. estado_binario[3] .." ".. estado_binario[4] .." ".. estado_binario[5] ..
		" ".. estado_binario[6] .." ".. estado_binario[7] .." ".. estado_binario[8] .." ".. estado_binario[9] .." ".. estado_binario[10] ..
		" ".. estado_binario[11] .." ".. estado_binario[12] .." ".. estado_binario[13] .." ".. largo_lista-1 .." ".. estado_binario[15] ..
		" ".. elementos_pos_new[27] .." ".. elementos_tam_new[11] .." ".. elementos_pos_new[28] .." ".. elementos_tam_new[12] .." ".. estado_binario[14] ..
		"                                                                                                    ")

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
