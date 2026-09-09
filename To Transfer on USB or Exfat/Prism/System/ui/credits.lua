-- Prism PS2 Launcher - ui/credits.lua
-- Credits screen.
-- Split from the original funciones.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Functions are globals; this file only defines them. Loaded by System/system.lua.

--- Muestra los créditos. ---------------------------------------------------------------
function creditos(fondo)
	local res_x, res_y_tex, res_y = CONTROL.ANCHO, CONTROL.Y_FIX_PAL, CONTROL.ALTO_F
	local function cargar_creditos()
		fondo()
		Graphics.drawRect(-10, -10, res_x+20, res_y+20, COLOR.NEGRO_T)
		Font.ftPrint(CONTROL.fontARCA, 0+(res_x//2), (0+(res_y//2))-30, 8, res_x, res_y, TEXT_M_CON[46], COLOR.BLANCO)
		refrescar(false)
		System.sleep(1)
	end
	cargar_creditos()
	local ENCELADUS = Graphics.loadImage(verif_img("System/Medias/Credits/ENCELADUS.png"))
	local RETROARCH = Graphics.loadImage(verif_img("System/Medias/Credits/RETROARCH.png"))
	local GPSP = Graphics.loadImage(verif_img("System/Medias/Credits/GPSP.png"))
	local POPSTARTER = Graphics.loadImage(verif_img("System/Medias/Credits/POPSTARTER.png"))
	local NEUTRINO = Graphics.loadImage(verif_img("System/Medias/Credits/NEUTRINO.png"))
	local WLAUNCHELF = Graphics.loadImage(verif_img("System/Medias/Credits/WLAUNCHELF_ISR.png"))
	local OPL = Graphics.loadImage(verif_img("System/Medias/Credits/OPL.png"))
	local SNESTICLE = Graphics.loadImage(verif_img("System/Medias/Credits/SNESTATION.png"))
	local SPAGHETTICODE = Graphics.loadImage(verif_img("System/Medias/Credits/SPAGHETTICODE.png"))
	local RETROLAUNCHER = Graphics.loadImage(verif_img("System/Medias/Credits/RETROLAUNCHER.png"))
	local CREDITOS_IMG = {ENCELADUS, RETROARCH, GPSP, POPSTARTER, NEUTRINO, WLAUNCHELF, OPL, OPL, SNESTICLE, SPAGHETTICODE, RETROLAUNCHER, RETROLAUNCHER}
	local CREDITOS_TXT = {"Enceladus is an enhanced Lua environment for\ncreating homebrew software for the PS2.\nDanielSant0s X: "..
	"https://x.com/danadsees\n\nProject Link:\nhttps://github.com/DanielSant0s/Enceladus\nLicense: Distributed under GNU GPL-3.0 License.";
	"RetroArch port created by RetroArch contributor\nfjtrujy (Francisco J. Trujillo).\nfjtrujy X: https://x.com/fjtrujy\n\nRetroArch "..
	"Link:\nhttps://www.retroarch.com\n\nLicenses: There is software behind RetroArch\nthat is protected by Non-Commercial licenses.\n"..
	"It is important to respect the wishes of the\ndevelopers and people behind the respective\nprojects.\n"..
	"https://docs.libretro.com/development/licenses/";
	"gpSP is a GBA emulator ported to PS2\nby developer belek666.\n\nbelek666 GitHub: https://github.com/belek666\n\nGpSP - "..
	"PS2 link: https://www.psx-place.com/\nresources/gpsp-by-belek666.687/";
	"POPStarter is a launcher which lets you play\nyour PS1 games in combination with PS1 emulator\nfor PS2.\n\n"..
	"POPStarter v13 was created by developer krHACKen.\nPOPStarter Link: https://\nwww.psx-place.com/threads/popstarter.19139/\n\n"..
	"Configuration patches taken from Hugopocked.\nHugopocked Fixes Link: https://www.psx-place.com\n"..
	"/threads/hugopocked-fixes-for-popstarter.39750/";
	"Neutrino is a small, fast and modular PS2 device\nemulator that maximizes compatibility and\nperformance. "..
	"Neutrino was created by developer\nMaximus32 (Rick Gaiser).\n\nNeutrino Link:\nhttps://github.com/rickgaiser/neutrino\n\n"..
	"License: Academic Free License \"AFL\" v. 3.0";
	"wLaunchELF ISR is an open source file manager\nand executable launcher for the PS2 console.\n"..
	"wLaunchELF 4.43x_ISR was created by developer\nisrapps (Matías Israelson) and is a wLaunchELF\nmod.\n\n"..
	"israpps (Matías Israelson):\nhttps://israpps.github.io\nwLaunchELF 4.43x_ISR Project Link:\n"..
	"https://github.com/israpps/wLaunchELF_ISR\n\nwLaunchELF Project Link:\nhttps://github.com/ps2homebrew/wLaunchELF\n"..
	"License: Academic Free License \"AFL\" v. 2.0\nwLaunchELF / project by AKuHAK and SP193.\n"..
	"uLaunchELF / project by E P and dlanor.\nLaunchELF / project by Mirakichi.\nAnd to all the developers who contributed to uLE.";
	"OPL is a 100% open source game and application\nloader for PS2 and PS3 devices, created by\n"..
	"Ifcaro and jimmikaelkael in conjunction with a\nhuge community of developers who are constantly\nimproving it.\n\n"..
	"OPL Project Link:\nhttps://github.com/ps2homebrew/Open-PS2-Loader\n\nLicense:\nCopyright 2013, Ifcaro & jimmikaelkael Licensed\n"..
	"under Academic Free License version 3.0.";
	"Open PS2 Loader by Ps2homebrew Team:\n"..
	"BatRastard - belek666 - crazyc - dlanor\ndoctorxyz - hominem.te.esse - Ifcaro - izdubar\n"..
	"jimmikaelkael - KrahJohlito - kr_ps2\nMaximus32 - misfire - polo35 - reprep - SP193\n"..
	"volca - icyson55 - algol - Berion - El_Patas\nEP - gledson999 - jolek - lee4 - LocalH\n"..
	"RandQalan - ShaolinAssassin - yoshi314 - zero35\nMarcus R. Brown - Eric Young - fjtrujy\nand the anonymous\n\n"..
	"Support Forums: psx-place.com";
	"SNESticle is a SNES emulator that was ported\nby its creator, Icer Addis (Sardu), to several\nplatforms, including PS2.\n"..
	"Source code: https://github.com/iaddis/SNESticle\nLicense: MIT License Copyright 2022 Icer Addis\n\n"..
	"RadShell is a command line client for PS2\ncreated by developer RadAd, that allows the\nautomation of basic tasks within PS2.\n\n"..
	"BDM Assault is a PS2 homebrew project created\nby israpps (Matias Israelson) that aims to\n"..
	"bring USB EXFAT support to older closed-source\nhomebrew applications that can load external\n"..
	"USB controllers.\nProject: https://github.com/israpps/BDMAssault";
	"Thanks to public education for the support \nduring my technical training.\nSpaghetticode / LC - Mendoza - Argentina / 2026";
	"Original background created by < e s c p > Art\nLicense: This Image is licensed under the\nCreative Commons Zero v1.0 Universal.\n"..
	"Free images by https://www.artapixel.com\n\nFont \"Public Pixel\" Designed by GGBotNet.\n"..
	"GGBotNet X: https://twitter.com/ggbotnet\nPublic Pixel Link: https://www.ggbot.net/fonts/\n"..
	"License: This Font Software is licensed under\nthe Creative Commons Zero v1.0 Universal.\n"..
	"CC0 1.0 Link: https://\ncreativecommons.org/publicdomain/zero/1.0/\n";
	"A special thank you to the entire \"PSX-PLACE\"\ncommunity for providing support and visibility\nto the program.\n"..
	"We also thank all YouTube channels along with\ntheir communities for spreading and improving\n"..
	"RETROLauncher with their supportive messages\nand constructive feedback.\n\nThanks for using RETROLauncher.    Boon Tobias"}
	local color_img = 129
	local color_tex = 128
	local cambio = true
	local cambio_t = true
	local pasaje = false
	local estado = 1
	local lista_pos_imgY = {6, 26, 38, 0, 78, 8, 34, 34, 0, 21, 8, 8}
	local lista_pos_imgX = {(640//2)-(600//2), 0, 0, (640//2)-(444//2), 0, (640//2)-(436//2), 0, 0, (640//2)-(469//2), 0, (640//2)-(592//2), (640//2)-(592//2)}
	local lista_pos_tex = {309+res_y_tex, 185+res_y_tex, 240+res_y_tex, 233+res_y_tex, 260+res_y_tex, 99+res_y_tex, 190+res_y_tex, 190+res_y_tex, 138+res_y_tex, 360+res_y_tex, 210+res_y_tex, 234+res_y_tex}
	local lista_pos_img_x = {600, 640, 640, 444, 640, 436, 640, 640, 469, 640, 592, 592}
	local lista_pos_img_y = {297+res_y_tex, 150+res_y_tex, 169+res_y_tex, 228+res_y_tex, 123+res_y_tex, 86+res_y_tex, 131+res_y_tex, 131+res_y_tex, 138+res_y_tex, 301+res_y_tex, 200+res_y_tex, 200+res_y_tex}
	local autocambio, velo_cam = 0, 1
	local mostrar_sob = false
	local TheLastLive = true
	while TheLastLive do
		CONTROL.FPS = Screen.getFPS(1)
		capturar(JOYSTICK_LIMITE)

		-- Controla los créditos. -------------------------------------------------------
		if Pads.check(PAD, PAD_TRIANGLE) then
			TheLastLive = false
		elseif pasaje == false then
			if color_img >= 1 and cambio == true then
				color_img = color_img-velo_cam
			elseif color_img <= 0 and cambio == true then
				color_img = 0
			elseif color_img <= 127 and cambio == false then
				color_img = color_img+velo_cam
			elseif color_img >= 128 and cambio == false then
				color_img = 128
				cambio = true
				estado = estado+1
			end
			if color_tex >= 1 and cambio_t == true and color_img == 0 then
				color_tex = color_tex-velo_cam
			elseif color_tex <= 0 and cambio_t == true and color_img == 0 then
				color_tex = 0
				cambio_t = false
				pasaje = true
			elseif color_tex <= 127 and cambio_t == false and color_img == 0 then
				color_tex = color_tex+velo_cam
			elseif color_tex >= 128 and cambio_t == false and color_img == 0 then
				color_tex = 128
				cambio_t = true
				cambio = false
			end
			if color_img >= 128 then
				color_img = 128
			end
			if color_tex >= 128 then
				color_tex = 128
			end
			if color_img <= 0 then
				color_img = 0
			end
			if color_tex <= 0 then
				color_tex = 0
			end
			if estado == 7 and color_img == 0 and color_tex == 128 then
				mostrar_sob = true
			elseif estado == 8 and color_img == 0 and color_tex == 0 then
				mostrar_sob = false
			elseif estado == 11 and color_img == 0 and color_tex == 128 then
				mostrar_sob = true
			elseif estado == 12 and color_img == 0 and color_tex == 0 then
				mostrar_sob = false
			end
		elseif pasaje == true and autocambio >= 256 then
			pasaje = false
			autocambio = 0
		elseif pasaje == true then
			autocambio = autocambio+velo_cam
		end
		if PAD ~= 0 then
			velo_cam = 4
		else
			velo_cam = 1
		end

		-- Mostrar todo en pantalla. ----------------------------------------------------
		fondo()
		Graphics.drawRect(-10, -10, res_x+20, res_y+20, COLOR.NEGRO_T)
		if estado <= #CREDITOS_IMG then
			Graphics.drawScaleImage(CREDITOS_IMG[estado], lista_pos_imgX[estado]-5, lista_pos_imgY[estado], lista_pos_img_x[estado]+5, lista_pos_img_y[estado], Color.new(128, 128, 128, 128-color_img))
			if mostrar_sob == true then
				Graphics.drawScaleImage(CREDITOS_IMG[estado], lista_pos_imgX[estado]-5, lista_pos_imgY[estado], lista_pos_img_x[estado]+5, lista_pos_img_y[estado])
			end
			Font.ftPrint(CONTROL.fontARCA, 5, lista_pos_tex[estado], 0, res_x, res_y, CREDITOS_TXT[estado], Color.new(128, 128, 128, 128-color_tex))
		else
			TheLastLive = false
		end
		refrescar(false)
	end
	Graphics.freeImage(ENCELADUS)
	Graphics.freeImage(POPSTARTER)
	Graphics.freeImage(NEUTRINO)
	Graphics.freeImage(WLAUNCHELF)
	Graphics.freeImage(SNESTICLE)
	Graphics.freeImage(OPL)
	Graphics.freeImage(RETROARCH)
	Graphics.freeImage(GPSP)
	Graphics.freeImage(RETROLAUNCHER)
	Graphics.freeImage(SPAGHETTICODE)
	CREDITOS_IMG = nil
	cargar_creditos()
end
