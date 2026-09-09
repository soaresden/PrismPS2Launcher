-- Prism PS2 Launcher - core/state.lua
-- Global state tables: logos, pads, sprites, colours, options, control, lists.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- Carga y verificación de imágenes. ---------------------------------------------------
function verif_img(dir)
	local actual = System.currentDirectory()
	if doesFileExist(actual .."/".. dir) == false then
		dir = "System/Medias/Default/ERROR.png"
	end
	return dir
end

load_step("preloading console logos")
-- Precargar logos. ---------------------------------------------------------------------
LOGOS = {
	DEFAULT = Graphics.loadImage(verif_img("System/Medias/Logos/Default.png"));
	DEFAULT_DEMO = Graphics.loadImage(verif_img("System/Medias/Logos/Default_DEMO.png"));
	MEGADRIVE = Graphics.loadImage(verif_img("System/Medias/Logos/Megadrive.png"));
	MASTERSYSTEM = Graphics.loadImage(verif_img("System/Medias/Logos/MasterSystem.png"));
	GAMEGEAR = Graphics.loadImage(verif_img("System/Medias/Logos/GameGear.png"));
	FAMICOM = Graphics.loadImage(verif_img("System/Medias/Logos/Famicom.png"));
	GAMEBOY = Graphics.loadImage(verif_img("System/Medias/Logos/GameBoy.png"));
	GAMEBOYCOLOR = Graphics.loadImage(verif_img("System/Medias/Logos/GameBoyColor.png"));
	GAMEBOYADVANCE = Graphics.loadImage(verif_img("System/Medias/Logos/GameBoyAdvance.png"));
	ATARI2600 = Graphics.loadImage(verif_img("System/Medias/Logos/Atari2600.png"));
	ATARILYNX = Graphics.loadImage(verif_img("System/Medias/Logos/AtariLynx.png"));
	SEGASG1000 = Graphics.loadImage(verif_img("System/Medias/Logos/SegaSG1000.png"));
	NEOGEOPOCKET = Graphics.loadImage(verif_img("System/Medias/Logos/NeoGeoPocket.png"));
	SUPERFAMICOM = Graphics.loadImage(verif_img("System/Medias/Logos/SuperFamicom.png"));
	APPS = Graphics.loadImage(verif_img("System/Medias/Logos/Apps.png"));
	PLAYSTATION = Graphics.loadImage(verif_img("System/Medias/Logos/PlayStation.png"));
	PLAYSTATION2 = Graphics.loadImage(verif_img("System/Medias/Logos/PlayStation2.png"));
};

load_step("preloading pad images")
-- Precargar imágenes de los pads. ------------------------------------------------------
PAD_IMG = {
	CIRCLE = Graphics.loadImage(verif_img("System/Medias/Pads/circle.png"));
	CROSS = Graphics.loadImage(verif_img("System/Medias/Pads/cross.png"));
	L1 = Graphics.loadImage(verif_img("System/Medias/Pads/L1.png"));
	R1 = Graphics.loadImage(verif_img("System/Medias/Pads/R1.png"));
	L2 = Graphics.loadImage(verif_img("System/Medias/Pads/L2.png"));
	R2 = Graphics.loadImage(verif_img("System/Medias/Pads/R2.png"));
	R3 = Graphics.loadImage(verif_img("System/Medias/Pads/R3.png"));
	SELECT_S = Graphics.loadImage(verif_img("System/Medias/Pads/select.png"));
	SQUARE = Graphics.loadImage(verif_img("System/Medias/Pads/square.png"));
	TRIANGLE = Graphics.loadImage(verif_img("System/Medias/Pads/triangle.png"));
	START = Graphics.loadImage(verif_img("System/Medias/Pads/start.png"));
};

load_step("preloading sprites")
-- Precargar imágenes de los sprites. ---------------------------------------------------
SPRITES = {
	MEGADRIVE = nil;
	MASTERSYSTEM = nil;
	GAMEGEAR = nil;
	FAMICOM = nil;
	GAMEBOY = nil;
	GAMEBOYCOLOR = nil;
	GAMEBOYADVANCE = nil;
	ATARI2600 = nil;
	ATARILYNX = nil;
	SEGASG1000 = nil;
	NEOGEOPOCKET = nil;
	SUPERFAMICOM = nil;
	APPS = nil;
	PLAYSTATION = nil;
	PLAYSTATION2 = nil;
	SPRITE_SYS = {"MEGADRIVE"; "MASTERSYSTEM"; "GAMEGEAR"; "FAMICOM"; "GAMEBOY"; "GAMEBOYCOLOR";
				"GAMEBOYADVANCE"; "ATARI2600"; "ATARILYNX"; "SEGASG1000"; "NEOGEOPOCKET";
				"SUPERFAMICOM"; "APPS"; "PLAYSTATION"; "PLAYSTATION2"};
	HEIGHT_Y = {45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45};
	WIDTH_X = {40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40};
	N_COLUMNS = {4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4};
	N_ROWS = {4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4};
	X = 0;
	Y = 0;
	ANI_FRAME = 0;
	FLIP = {0, 0};
	FONDO_ANI = false;
	FONDO_HEIGHT_Y = 640;
	FONDO_WIDTH_X = 448;
	FONDO_N_COLUMNS = 4;
	FONDO_N_ROWS = 4;
	FOND_X = 0;
	FOND_Y = 0;
	FONDO_ANI_FRAME = 0;
	LAYER = false;
	LAYER_TYPE = 0;
	LAYER_SPEED = 1;
	TRAN_TYPE = 0;
	TRAN_LEVEL = 1;
	TRAN_SPEED = 1;
	TRAN = {128, 128, 128, 128};
	TRAN_ALT = {false, false, false, false};
	SPIN_TYPE = 0;
	SPIN = 0;
	SPIN_SPEED = 1;
	LAYER_MULTI = 1;
	BACK_X = 0;
	BACK_Y = 0;
	LAYER_X_1 = 0;
	LAYER_X_2 = 0;
	LAYER_X_3 = 0;
	LAYER_X_4 = 0;
	LAYER_Y_1 = 0;
	LAYER_Y_2 = 0;
	LAYER_Y_3 = 0;
	LAYER_Y_4 = 0;
	ALTERNATE = false;
	ALTERNATE_R = false;
	ALTERNATE_T = false;
	ACTIVATE_ALTER_T = false;
	ANG = {0.00, 3.14};
	ZOOM = {0, false};
	MOVE = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	AUTO_MOVE_SPRITE = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	MOVE_X = 0;
	MOVE_Y = 0;
	MOVE_ALT_X = false;
	MOVE_ALT_Y = false;
	SPIN_SPRITE_ON = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	SPIN_SPRITE = 0.00;
	SPIN_SPRITE_ALT = false;
	TRAN_SPRITE_ON = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	TRAN_SPRITE = 128;
	TRAN_ALT_SPRITE = false;
	ANG_SPRITE = 0.00;
	ZOOM_SPRITE = {0, false};
	SPEED_SPRITE = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
};
TEML(true)

load_step("defining colours")
-- Define colores básicos. --------------------------------------------------------------
COLOR = {
	BLANCO = Color.new(128, 128, 128);
	BLANCO_LISTA = Color.new(128, 128, 128);
	NEGRO = Color.new(0, 0, 0);
	GRIS = Color.new(70, 70, 70);
	NEGRO_T = Color.new(0, 0, 0, 85);
	BLANCO_T = Color.new(128, 128, 128, 20);
	CC_BACK = {0, 0, 0, 85};
};

load_step("defining options")
-- Define opciones y configuraciones. ---------------------------------------------------
OPCIONES = {
	RGB_ON = 1;
	FONDO_RGB_ON = 1;
	FONDO_RGB_FIJO_ON = 0;
	R = 0;
	G = 80;
	B = 120;
	CAMBIO_FUENTE_ON = 1;
	FUENTES_ENCONTRADAS = {};
	CAMBIO_FONDO_ON = 1;
	FONDO_ENCONTRADOS = {};
	GUI_LIMPIA_ON = 0;
	APPS_MENU_FULL_PATH = 0;
	LIMITADOR_RAM_ON = 0;
	SALIDA_RETROLANCHER_ON = 0;
	SALIDA_RETROLANCHER = "PS2 SYSTEM MENU";
	SALIDA_DIR_ACTUALES = {};
	SALIDA_DIR_ANTERIORES = {};
	SOUND_ON = 0;
	SCREENSHOT_BACK_ON = 0;
	SCREENSHOT_BACK_TR = 128;
	SOUND_VOLUME = 65;
	VIDEO_MODE = 0;
	VIBRATION_ON = 0;
	VIBRATION = false;
	VIBRATION_MODE = nil;
	DIR_EXTRAS_ON = 1;
	PREGUNTAR_PS2 = false;
	LIBERAR_LISTAS = 0;
	FONT_PIXEL_X = 16;
	FONT_PIXEL_Y = 16;
	FONT_SHADOW = 5;
	SCROLL_MIN = 24;
	OPL_ELF = "mass:/Prism/OPL/OPNPS2LD.ELF";
	OPL_DIR = "DVD";
	SPRITE_ON = 0;
	SEE_INDEX = 0;
	COLOR_LISTA_B = 74;
	RUN_DEFAULT = 0
};

load_step("defining emulator states")
-- Define el estado de los emuladores (Activado / Desactivado). -------------------------
SISTEMAS = {
	MEGADRIVE_ON = 1;
	MASTERSYSTEM_ON = 1;
	GAMEGEAR_ON = 1;
	FAMICOM_ON = 1;
	GAMEBOY_ON = 1;
	GAMEBOYCOLOR_ON = 1;
	GAMEBOYADVANCE_ON = 1;
	ATARI2600_ON = 1;
	ATARILYNX_ON = 1;
	SEGASG1000_ON = 1;
	NEOGEOPOCKET_ON = 1;
	SUPERFAMICOM_ON = 1;
	APPS_ON = 1;
	PLAYSTATION_ON = 1;
	PLAYSTATION2_ON = 1;
};

load_step("loading fonts")
-- Define las variables usadas para la ejecución del programa. --------------------------
CONTROL = {
	ANCHO = 640;
	ALTO = 480;
	ALTO_F = 448;
	Y_FIX_PAL = 0;
	SELECTOR = 1;
	ESTILO = 1;
	JOYSTICK_ON = false;
	TIME = Timer.new();
	TIEMPO = 0;
	ESPERA_CARGA_SCR = false;
	PAUSA_SCR_TEX = 0;
	EXTENSION = 5;
	FPS = Screen.getFPS(1);
	LISTA_ANCHO = 30; LISTA_X = 310; LISTA_ALTO = 90; LISTA_Y = 290;
	IMG_ANCHO = 358; IMG_X = 250; IMG_ALTO = 92; IMG_Y = 193;
	IMG_ANCHO_2 = 358; IMG_X_2 = 250; IMG_ALTO_2 = 92; IMG_Y_2 = 193;
	FLOW_ANCHO = 15; FLOW_X = 160; FLOW_ALTO = 358; FLOW_Y = 103;
	FLOW_ANCHO_2 = 358; FLOW_X_2 = 250; FLOW_ALTO_2 = 92; FLOW_Y_2 = 250;
	LOGO_ANCHO = 194; LOGO_X = 252; LOGO_ALTO = 5; LOGO_Y = 76;
	X_BUTTON_X = 0; Y_BUTTON_X = 0;
	X_BUTTON_T = 0; Y_BUTTON_T = 0;
	X_BUTTON_S = 0; Y_BUTTON_S = 0;
	X_BUTTON_L1 = 0; Y_BUTTON_L1 = 0;
	X_BUTTON_R1 = 0; Y_BUTTON_R1 = 0;
	X_BUTTON_R3 = 0; Y_BUTTON_R3 = 0;
	X_BUTTON_STA = 0; Y_BUTTON_STA = 0;
	X_BUTTON_SEL = 0; Y_BUTTON_SEL = 0;
	CUSTOM_ANIM = 1;
	ANIM_VELOCIDAD = 29;
	CUSTOM_LIST = true;
	CUSTOM_ART1 = true;
	CUSTOM_ART2 = false;
	CUSTOM_FLOW = false;
	CUSTOM_LOGO = true;
	CUSTOM_BUTTON_X = true;
	CUSTOM_BUTTON_T = true;
	CUSTOM_BUTTON_S = true;
	CUSTOM_BUTTON_L1 = true;
	CUSTOM_BUTTON_R1 = true;
	CUSTOM_BUTTON_R3 = true;
	CUSTOM_BUTTON_STA = true;
	CUSTOM_BUTTON_SEL = true;
	CUSTOM_BACK = true;
	SPRITE_ANCHO = 30; SPRITE_X = 80; SPRITE_ALTO = 30; SPRITE_Y = 100;
	CUSTOM_SPRITE = false;
	Font.ftInit();
	fontARCA = Font.ftLoad("System/Medias/Font/PublicPixel.ttf");
	fontABC = Font.ftLoad("System/Medias/Font/PublicPixel.ttf");
	ACT_FONTABC = false;
};

load_step("preparing list images")
-- Define las variables usadas para la ejecución de las listas. -------------------------
LISTAS = {
	FONDO = Graphics.loadImage(verif_img("System/Medias/Default/FONDO.png"));
	LOADING = Graphics.loadImage(verif_img("System/Medias/Default/LOADING.png"));
	COVER_DEFAULT = Graphics.loadImage(verif_img("System/Medias/Default/".. img_lang("COVER_DEFAULT", true) ..".png"));
	SCREENSHOT_DEFAULT = Graphics.loadImage(verif_img("System/Medias/Default/".. img_lang("SCREENSHOT_DEFAULT", false) ..".png"));
	LOGO = LOGOS.DEFAULT;
	IDENTIDAD = 1;
	INDICE = 1;
	INDICE2 = 1;
	INDICE3 = 1;
	ROMS = {};
	DIR_FULL_APP = {};
	MOSTRAR = 0;
	ART_LIMITE = 8;
	SCREENSHOT_ON = false;
	SCREENSHOT_FULL = false;
	COVER_ART = nil;
	COVER_DIR = " "; COVER_DIR_ALT = " ";
	COVER_ART2 = nil;
	COVER_DIR2 = " "; COVER_DIR2_ALT = " ";
	COVER_ART3 = nil;
	COVER_DIR3 = " "; COVER_DIR3_ALT = " ";
	SCREENSHOT = nil;
	SCREENSHOT_DIR = " "; SCREENSHOT_DIR_ALT = " ";
	SCROLL_TEX = 1;
	EXISTE_COV = false;
	EXISTE_SCR = false;
	EXISTE_COV2 = false;
	EXISTE_COV3 = false;
	COV_X = 250; COV_Y = 193; COV_FIX = 0; COV_FIX_Y = 0;
	SCR_X = 250; SCR_Y = 193; SCR_FIX = 0; SCR_FIX_Y = 0;
	SCR_ART2_X = 250; SCR_ART2_Y = 193; SCR_FIX_ART2 = 0; SCR_FIX_Y_ART2 = 0;
	COV_1_X = 160; COV_1_Y = 103; COV_1_FIX = 0; COV_1_FIX_Y = 0;
	COV_2_X = 160; COV_2_Y = 103; COV_2_FIX = 0; COV_2_FIX_Y = 0;
	EX_FIX_S = 0; EX_FIX_S_Y = 0;
	EX_FIX_C = 0; EX_FIX_C_Y = 0;
	ELEMENTOS_LIST = 11;
	ART_ZOOM = 2;
};

load_step("defining system colours")
-- Define los colores usados para cada sistema. -----------------------------------------
CAMBIOS_EMUS = {
	COLOR_EMU = Color.new(0, 0, 0);
	COLOR_EMU_BACK = Color.new(0, 80, 120);
	COLOR_ACTUAL = 0;
	COLOR_MAX = 0;
	COLOR_MIN = 0;
	RGB_COLOR = 1;
	CAM_COLOR_ACTUAL = false;
	R = 0;
	G = 80;
	B = 120;
	TRAS = 74;
};
