-- Prism PS2 Launcher - emu/retroarch.lua
-- RetroArch: locating the install, cores, forced retroarch.cfg values.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- Media folder per identity, including the systems with no EmulationStation alias
--- (APPS, PS1, PS2). This is the name used under "Roms/<here>/media/".
--- Booting RetroArch through "raboot.elf". ------------------------------------------
--- DISCARDED, and the reason is in RetroArch's own code. "raboot.elf" is the
--- Salamander, and in "frontend/drivers/platform_ps2.c" the block that hands the game
--- to the core sits inside a "#ifndef IS_SALAMANDER": the Salamander calls the core
--- with ZERO arguments. It can never boot a ROM, only open the RetroArch menu.
--- It also rewrites "retroarch-salamander.cfg" with its own choice, wiping ours out.
--- The path is left in place in case it helps with debugging, switched off.
RABOOT_ON = false

--- Returns the path to raboot.elf when available, otherwise nil. ---------------------
function RUTA_RABOOT()
	if RABOOT_ON ~= true or RAICES == nil then return nil end
	for i = 1, #RAICES do
		local base = RUTA_LIBRETRO()
		local cand = RAICES[i] .."/LibretroPS2Files/raboot.elf"
		if base ~= nil then cand = base .."/raboot.elf" end
		if doesFileExist(cand) then return cand end
	end
	return nil
end

--- Writes the chosen core into the salamander that raboot reads. --------------------
--- Path of the salamander matching a given raboot.elf. -------------------------------
function RUTA_SALAMANDER(ruta_raboot)
	if ruta_raboot == nil then return nil end
	-- "raboot.elf" is 10 characters: 10 have to come off, not 11. With -12 the slash
	-- went too, and the file was silently written to a path that did not exist.
	local base = string.sub(ruta_raboot, 1, string.len(ruta_raboot) - 10)
	return base .."retroarch/retroarch-salamander.cfg"
end

--- Writes the chosen core into the salamander that raboot reads. --------------------
--- It is read back afterwards: false is returned when the contents are not what was
--- expected, the launch falls back to the direct call instead of booting the old core.
function PREPARAR_RABOOT(ruta_raboot, ruta_core)
	if ruta_raboot == nil or ruta_core == nil then return false end
	local cfg = RUTA_SALAMANDER(ruta_raboot)
	local linea = "libretro_path = \"".. ruta_core .."\"\n"
	pcall(function()
		local f = System.openFile(cfg, FCREATE)
		System.writeFile(f, linea, string.len(linea))
		System.closeFile(f)
	end)
	local leido = nil
	pcall(function()
		local f = System.openFile(cfg, FREAD)
		local tam = System.sizeFile(f)
		System.seekFile(f, 0, SET)
		leido = System.readFile(f, tam)
		System.closeFile(f)
	end)
	return leido ~= nil and string.find(leido, ruta_core, 1, true) ~= nil
end

--- Folders of the RetroArch module. --------------------------------------------------
---
---   LibretroPS2Files/
---     cores/  info/  raboot.elf       the nightly, unzipped exactly as it comes
---     retroarch/retroarch.cfg         THE configuration. One. No factory copy.
---     retroarch/config/<Core>/        the per-core settings
---
--- There used to be a "DefaultCFGs/" folder here holding a second "retroarch.cfg" the
--- first one was rebuilt from. It is gone: two files with the same job is an invitation
--- for them to diverge, and it was not needed. A nightly ships no "retroarch/", and if
--- it is missing, RetroArch writes its own with its own values -- which is precisely
--- what a factory copy was trying to imitate. The launcher only has to reimpose its
--- keys on top, and it does that on every game launch.
---
--- RetroArch finds its own folders unaided: on boot, a core takes its own directory
--- and GOES UP ONE LEVEL ("path_parent_dir" in "frontend/drivers/platform_ps2.c"),
--- so the folder containing "cores/" is its root. Its name does not matter.
--- Where the nightly may live, in order of preference. Both unzipped into its own
--- subfolder and unzipped straight into LibretroPS2Files are accepted.
LIBRETRO_SUBS = {"/LibretroPS2Files", "/LibretroPS2Files/UnzippedFileHere"}

--- The RetroArch root: the folder that contains "cores/". ----------------------------
--- PRIORITY TO THE MEDIUM THE CORE WILL BE ABLE TO READ. A core boots by doing
--- SifIopReset: the ELF is already in RAM, but the IOP is wiped and the internal drive
--- stops existing for it. If its "cores/", "info/" and "retroarch/" are on that drive,
--- it has nothing left to read and dies before drawing the first frame. Not even
--- "raboot.elf" survives: it finds no cores and exits.
--- This is a known problem, not a quirk of this fork: the PSBBN author takes the same
--- detour in his issue #448 -- the ELF wherever you like, EVERYTHING else on the USB.
--- Hence the search starts on a medium other than the ATA drive, and only falls back
--- to the internal drive when there is nothing else (where it will work with patched
--- cores, and only with those).
--- Installation forced for this launch, if one had to be prepared. -------------------
LIBRETRO_FORZADO = nil

--- And the result of the last scan, so it is not repeated. ----------------------------
--- This is NOT a cosmetic optimisation. Each scan lists "cores/" in up to six places,
--- and that folder holds a dozen ELF files of several MB: over exFAT via BDM it costs
--- seconds. It was called three times during boot alone -- LIBRETRO_REPARAR, the
--- diagnostics, and the loading screen -- and the result cannot change between them.
--- The screen looked frozen because it was, quite simply, waiting for it.
--- "" means "already searched and there was nothing", which differs from "not searched
--- yet": without that distinction, the "no RetroArch" case would repeat the whole scan
--- on every call, which is precisely the most expensive one of all.
LIBRETRO_CACHE = nil

function RUTA_LIBRETRO()
	if LIBRETRO_FORZADO ~= nil then return LIBRETRO_FORZADO end
	if LIBRETRO_CACHE == "" then return nil end
	if LIBRETRO_CACHE ~= nil then return LIBRETRO_CACHE end
	if RAICES == nil then return nil end   -- no drives yet: nothing gets cached
	-- Three passes: first a complete installation off the internal drive, which is the
	-- only one a core will know how to read; then a complete one anywhere; and last of
	-- all anything that has cores, so at least something can be said.
	for pasada = 1, 3 do
		for i = 1, #RAICES do
			local es_ata = ES_RAIZ_ATA(RAICES[i] .."/x")
			if pasada ~= 1 or es_ata == false then
				for k = 1, #LIBRETRO_SUBS do
					local cand = RAICES[i] .. LIBRETRO_SUBS[k]
					if System.listDirectory(cand .."/cores") ~= nil then
						if pasada == 3 or LIBRETRO_COMPLETO(cand) == true then
							LIBRETRO_CACHE = cand
							return cand
						end
					end
				end
			end
		end
	end
	LIBRETRO_CACHE = ""
	return nil
end

--- An installation is only usable if it is COMPLETE. ---------------------------------
--- Having the folder is not enough: a half copy -- cut short mid-deployment, or from
--- an older version of the tree -- would win the selection and would block forever
--- the very deployment that ought to repair it. The bare minimum is required: the
--- cores, and the configuration.
function LIBRETRO_COMPLETO(base)
	if base == nil then return false end
	if System.listDirectory(base .."/cores") == nil then return false end
	if doesFileExist(base .."/retroarch/retroarch.cfg") == false then return false end
	return true
end

--- Builds the "retroarch/" folder RetroArch demands. ---------------------------------
--- The contract with the user is simple: unzip a nightly inside
--- "LibretroPS2Files/" -- raboot.elf, cores/, info/ -- and it works. Everything else
--- is put here by the launcher.
---
--- And it does need putting there, because a nightly does NOT ship the "retroarch/"
--- folder, while RetroArch demands it and takes no argument: "create_path_names()"
--- takes the core directory, goes up one level and looks for "retroarch/retroarch.cfg"
--- there. That path is compiled into the binary. It is the one rigid anchor of the
--- whole arrangement; the other folders can be moved, because the launcher writes them
--- into the configuration afterwards ("libretro_directory", "system_directory"...).
---
--- Nothing is copied here: only the missing folders are created. "retroarch.cfg" is
--- not restored from any mould -- if it is absent, FORZAR_CONF_RETROARCH writes it with
--- the launcher keys, and RetroArch fills in the rest with its own values the first
--- time it saves.
function LIBRETRO_REPARAR()
	local base = RUTA_LIBRETRO()
	if base == nil then return false end

	local necesarias = {"/retroarch", "/retroarch/config", "/retroarch/config/remaps",
		"/retroarch/system", "/retroarch/logs", "/retroarch/temp",
		"/retroarch/savefiles", "/retroarch/savestates", "/retroarch/assets",
		"/retroarch/cheats", "/retroarch/playlists", "/retroarch/thumbnails",
		"/retroarch/downloads", "/retroarch/overlays", "/retroarch/database"}
	for i = 1, #necesarias do
		if System.listDirectory(base .. necesarias[i]) == nil then
			System.createDirectory(base .. necesarias[i])
		end
	end

	local cfg = base .."/retroarch/retroarch.cfg"
	if doesFileExist(cfg) == false then
		boot_log("CONF   no ".. cfg .." : it will be written when the first game launches")
		boot_flush()
	end
	return true
end

--- Where OUR three folders land -- Bios, Saves, SaveStates. ---------------------------
--- Normally next to the launcher, which is where the user sees them. But if the
--- launcher runs from the internal ATA drive and the core carries no ata_bd, that drive
--- does not exist for it: they then go to the same place as the shuttled ROM, and the
--- save bridge brings them back at boot. Returns the root and, if the core DOES read
--- ATA, the name that drive will have on the far side of the SifIopReset.
function RAIZ_DATOS(lee_ata)
	local actual = System.currentDirectory()
	if ES_RAIZ_ATA(actual .."/Saves") == false then return actual, nil end
	if lee_ata == true then return actual, DEV_ATA_PARA_CORE() end
	local destinos = ROM_DESTINOS()
	if #destinos >= 1 then
		CREAR_CADENA(destinos[1], string.sub(ROM_SHUTTLE_SUB, 2))
		return destinos[1] .. ROM_SHUTTLE_SUB, nil
	end
	return actual, nil
end

--- "Bios/" is the ONLY reference copy of each BIOS. -----------------------------------
--- It is handed to RetroArch as "system_directory", so there is no second copy to
--- maintain. Only one case needs one: when the core cannot read the drive holding
--- "Bios/", and then the little that RetroArch looks for there is dropped on the stick.
--- Every file here is small - the largest is 128 KB - so the list is the whole set of
--- BIOS the installed cores can ask for, not just the one that was noticed first. A
--- missing entry is not an error message: it is a core that boots to a blank screen on
--- the stick and works on the internal drive, which is the worst kind of bug to chase.
--- Anything absent from Bios/ is simply skipped.
BIOS_LIBRETRO_LISTA = {
	"gba_bios.bin",                                   -- gpSP (required), mGBA (optional)
	"gb_bios.bin", "gbc_bios.bin", "sgb_bios.bin",    -- Gambatte, Gearboy, mGBA: optional
	"lynxboot.img",                                   -- Handy, Gearlynx, Beetle Lynx: REQUIRED
	"exec.bin", "grom.bin",                           -- FreeIntv (Intellivision): REQUIRED
	"colecovision.rom", "coleco.rom", "bios.col",     -- Gearcoleco: REQUIRED, one of these
	"o2rom.bin", "c52.bin", "g7400.bin", "jopac.bin", -- O2EM (Odyssey 2 / Videopac): REQUIRED
	"disksys.rom",                                    -- FCEUmm, for Famicom Disk System
	"bios.sms", "bios.gg",                            -- Gearsystem: optional boot ROMs
	"bios_CD_E.bin", "bios_CD_U.bin", "bios_CD_J.bin",-- PicoDrive, for Sega CD only
	"neocd.bin", "ng-lo.rom",                         -- NeoCD: REQUIRED
}

function BIOS_LIBRETRO(lee_ata)
	local raiz = RAIZ_DATOS(lee_ata)
	if raiz == System.currentDirectory() then return end   -- already read where it is
	local destino = raiz .."/Bios"
	if System.listDirectory(destino) == nil then
		System.createDirectory(destino)
		if System.listDirectory(destino) == nil then return end
	end
	for i = 1, #BIOS_LIBRETRO_LISTA do
		local fichero = BIOS_LIBRETRO_LISTA[i]
		if doesFileExist(destino .."/".. fichero) == false then
			local origen = RUTA_BIOS(fichero, "")
			if doesFileExist(origen) then
				pcall(System.copyFile, origen, destino .."/".. fichero)
				boot_log("BIOS   ".. fichero .." -> ".. destino .." : ".. tostring(doesFileExist(destino .."/".. fichero)))
			else
				boot_log("BIOS   ".. fichero .." MISSING from Bios/")
			end
			boot_flush()
		end
	end
end

--- Can a RetroArch core be booted TODAY? ---------------------------------------------
--- Returns false and the reason when not. Two cases: there is no installation anywhere,
--- or there is one but on the internal drive and no USB stick to shuttle it to. The
--- memory card does not count: 8 MB is not even enough for one core.
function LIBRETRO_POSIBLE()
	-- "Is there an installation?" is asked of the master; "will a core be able to read
	-- it?" too, because what ends up on the stick is copied from it.
	local base = libretro_master_path()
	if base == nil then return false, "no RetroArch installation found" end
	if ES_RAIZ_ATA(base) == false then return true, base end
	local destinos = ROM_DESTINOS()
	for i = 1, #destinos do
		if string.lower(string.sub(destinos[i], 1, 4)) == "mass" then
			return true, base .." via ".. destinos[i]
		end
	end
	return false, "RetroArch on the internal drive and no USB stick"
end

--- With no core possible, the twelve libretro systems are not offered. ----------------
--- An absent console is better than a console that opens and returns "Games or
--- RetroArch not found" for every game.
LIBRETRO_SISTEMAS_OFF = false
LIBRETRO_SISTEMAS_MOTIVO = nil

function LIBRETRO_APAGAR_SI_IMPOSIBLE()
	local ok, motivo = LIBRETRO_POSIBLE()
	LIBRETRO_SISTEMAS_OFF = (ok ~= true)
	LIBRETRO_SISTEMAS_MOTIVO = motivo
	if ok == true then
		boot_log("SISTEMAS  libretro available: ".. tostring(motivo))
		boot_flush()
		return false
	end
	boot_log("SISTEMAS  libretro DISABLED: ".. tostring(motivo))
	boot_flush()
	SISTEMAS.MEGADRIVE_ON = 0
	SISTEMAS.MASTERSYSTEM_ON = 0
	SISTEMAS.GAMEGEAR_ON = 0
	SISTEMAS.FAMICOM_ON = 0
	SISTEMAS.GAMEBOY_ON = 0
	SISTEMAS.GAMEBOYCOLOR_ON = 0
	SISTEMAS.GAMEBOYADVANCE_ON = 0
	SISTEMAS.ATARI2600_ON = 0
	SISTEMAS.ATARILYNX_ON = 0
	SISTEMAS.SEGASG1000_ON = 0
	SISTEMAS.NEOGEOPOCKET_ON = 0
	SISTEMAS.SUPERFAMICOM_ON = 0
	return true
end

--- Diagnostic switches. --------------------------------------------------------------
--- Black screen when launching a game? Set one of these to false and try again,
--- one at a time. Nothing has to be recompiled.
---   RETROARCH_FORZAR_ON     to false: "retroarch.cfg" is not touched at all.
---   RETROARCH_FORZAR_VIDEO  to false: the folders are forced, but NOT the video
---                           mode. A "current_resolution_id" the television does not
---                           accept gives exactly a black screen.
RETROARCH_FORZAR_ON = true
--- False, and for a concrete reason. The PAL block writes current_resolution_id=1,
--- video_refresh_rate=54.5 and vrr_runloop_enable=true. Those values come from Boon
--- Tobias's configurations and have NEVER been checked on hardware. What has been
--- checked, on this very PAL console and with a game running, is the opposite:
--- current_resolution_id=0 and 59.940063, with "[PS2_GFX] New vmode: 0, 704x576" in
--- the RetroArch log. Forcing a video mode the console does not produce is one of the
--- two known ways of ending up with a black screen.
--- Set to true they are imposed again, if they are ever verified.
RETROARCH_FORZAR_VIDEO = false

--- Settings the launcher imposes on RetroArch before every game. ----------------------
--- RetroArch saves its configuration on exit and the user can change it from the
--- menu: what is here is rewritten on every boot. To add a setting, just put it in
--- the table.
RETROARCH_FORZADO = {
	-- Saves live OUTSIDE the RetroArch tree, in "Saves/" and "SaveStates/".
	-- "in_content_dir" would put them next to the ROM; "sort_..._enable" would group
	-- them by core, and then PicoDrive would mix four Sega consoles into one folder.
	-- By content folder it comes out as "Saves/<console>/", the same name as in "Roms/".
	{"savefiles_in_content_dir",          "false"},
	{"savestates_in_content_dir",         "false"},
	{"sort_savefiles_enable",             "false"},
	{"sort_savestates_enable",            "false"},
	{"sort_savefiles_by_content_enable",  "true"},
	{"sort_savestates_by_content_enable", "true"},

	-- 21 = "Square pixel": one console pixel is one screen pixel. What came as the
	-- default was 22, "Core provided", which on PS2 leaves the picture stretched.
	-- If what was wanted was the literal "1:1" from the RetroArch menu, that is 5.
	-- Per-core overrides still take precedence over this, which is right: a
	-- Game Boy is 10:9 come what may.
	{"aspect_ratio_index", "21"},
}

--- The only thing separating an NTSC configuration from a PAL one. --------------------
--- Boot Tobias kept twenty-four complete "retroarch.cfg" files for this, twelve per
--- video mode. The real difference is these six keys.
--- "aspect_ratio_index" and "video_scale_integer" are NOT here, though they used to be.
--- They are not properties of the video mode but user taste: a Game Boy is 10:9 in
--- NTSC as in PAL. Forcing them undid on every boot whatever had been chosen in the
--- RetroArch menu. Their value lives in retroarch/retroarch.cfg, which is the only one,
--- and each core tunes it with its override.
--- There is one key that also changed, "video_vsync", but not uniformly: in PAL it was
--- "false" only for Neo Geo Pocket, Game Boy, Game Boy Color and Super Famicom.
--- That is per system AND per mode at once, which does not fit in this table.
RETROARCH_VIDEO = {
	NTSC = {
		{"video_refresh_rate",     "59.940063"},
		{"crt_video_refresh_rate", "59.940063"},
		{"current_resolution_id",  "0"},
		{"vrr_runloop_enable",     "false"},
	},
	PAL = {
		{"video_refresh_rate",     "54.500000"},
		{"crt_video_refresh_rate", "54.500000"},
		{"current_resolution_id",  "1"},
		{"vrr_runloop_enable",     "true"},
	},
}

--- Writes all of the above into RetroArch's "retroarch.cfg". --------------------------
function FORZAR_CONF_RETROARCH(pal, lee_ata)
	if RETROARCH_FORZAR_ON ~= true then
		boot_log("CONF   disabled (RETROARCH_FORZAR_ON = false)")
		boot_flush()
		return false
	end
	local base = RUTA_LIBRETRO()
	if base == nil then
		boot_log("CONF   RetroArch folder not found, no settings to force")
		boot_flush()
		return false
	end
	-- There is no factory copy to take it from: if missing, it is created empty and
	-- the keys below fill it. RetroArch adds its own afterwards when it saves.
	local cfg = base .."/retroarch/retroarch.cfg"
	if doesFileExist(cfg) == false then
		if System.listDirectory(base .."/retroarch") == nil then
			System.createDirectory(base .."/retroarch")
		end
		pcall(function()
			local f = System.openFile(cfg, FCREATE)
			System.writeFile(f, "\n", 1)
			System.closeFile(f)
		end)
		boot_log("CONF   ".. cfg .." did not exist, created")
		if doesFileExist(cfg) == false then
			boot_log("CONF   cannot create it: read-only medium?")
			boot_flush()
			return false
		end
	end

	-- Saves have to land on a medium the core CAN read. If the launcher runs from the
	-- internal ATA drive and the core carries no ata_bd, that drive does not exist for
	-- it: the same destination as the ROM shuttle is then used.
	local raiz_saves, dev_saves = RAIZ_DATOS(lee_ata)
	if dev_saves ~= nil then
		boot_log("CONF   launcher on ATA drive, core compatible: data on ".. dev_saves)
	elseif raiz_saves ~= System.currentDirectory() then
		boot_log("CONF   launcher on ATA drive, core without ata_bd: data on ".. raiz_saves)
	end

	-- Enceladus sees "mass0:"; RetroArch resets the IOP and calls the same USB "mass:".
	-- But "mc0:" is called the same on both sides, and "mc:" does not exist: hence the
	-- translation only touches "massN:".
	local function para_core(ruta)
		if ruta == nil then return nil end
		if dev_saves ~= nil and ES_RAIZ_ATA(ruta) then
			local pos = string.find(ruta, ":", 1, true)
			if pos ~= nil then return dev_saves .. string.sub(ruta, pos+1) end
		end
		return DEV_PARA_CORE(ruta)
	end

	-- The three folders that are OURS, not RetroArch's: they go next to the launcher
	-- and not inside its tree. "Bios/" is the only reference copy of the BIOS files, so
	-- it is handed over as "system_directory" instead of keeping a second copy.
	local quiero = {}
	local dirs = {{"savefile_directory",  raiz_saves .."/Saves"},
	              {"savestate_directory", raiz_saves .."/SaveStates"},
	              {"system_directory",    raiz_saves .."/Bios"}}
	for i = 1, #dirs do
		if System.listDirectory(dirs[i][2]) == nil then
			System.createDirectory(dirs[i][2])
		end
		quiero[dirs[i][1]] = para_core(dirs[i][2])
	end

	-- Where RetroArch's own file browser opens. Not a folder of ours to create, but an
	-- absolute path all the same - and an absolute path that is not rewritten is an
	-- absolute path that goes stale the day the launcher moves to another drive.
	-- Everything in this function is recomputed from where the launcher REALLY is, on
	-- every boot: install Prism on the internal disk tomorrow and the whole
	-- configuration follows it, with nothing to edit by hand.
	quiero["rgui_browser_directory"] = para_core(raiz_saves .."/Roms")

	-- RetroArch's OWN FOLDERS, written out explicitly. ---------------------------------
	-- Without these keys RetroArch works them out from its own directory, and there is
	-- the trap: booted from the internal drive that directory can be a name that exists
	-- but whose root does not list, and then assets, config, system and savefiles all
	-- point at an empty place. They are recomputed on every boot from where the folder
	-- REALLY is, so moving the launcher fixes them by itself.
	local base_ra = para_core(base)
	if base_ra ~= nil then
		local carpetas = {
			{"libretro_directory",        "/cores"},
			{"libretro_info_path",        "/info"},
			{"rgui_config_directory",     "/retroarch/config"},
			{"input_remapping_directory", "/retroarch/config/remaps"},
			{"cheat_database_path",       "/retroarch/cheats"},
			{"content_database_path",     "/retroarch/database/rdb"},
			{"assets_directory",          "/retroarch/assets"},
			{"core_assets_directory",     "/retroarch/downloads"},
			{"playlist_directory",        "/retroarch/playlists"},
			{"thumbnails_directory",      "/retroarch/thumbnails"},
			{"cache_directory",           "/retroarch/temp"},
			{"log_dir",                   "/retroarch/logs"},
			{"overlay_directory",         "/retroarch/overlays"},
			-- These five are not folders but files, and RetroArch stores them
			-- separately: changing "playlist_directory" does not drag them. Without
			-- putting them here they keep pointing at wherever the last install was.
			{"content_favorites_path",      "/retroarch/playlists/builtin/content_favorites.lpl"},
			{"content_history_path",        "/retroarch/playlists/builtin/content_history.lpl"},
			{"content_image_history_path",  "/retroarch/playlists/builtin/content_image_history.lpl"},
			{"content_music_history_path",  "/retroarch/playlists/builtin/content_music_history.lpl"},
			{"content_video_history_path",  "/retroarch/playlists/builtin/content_video_history.lpl"},
		}
		for i = 1, #carpetas do
			quiero[carpetas[i][1]] = base_ra .. carpetas[i][2]
		end
		boot_log("CONF   RetroArch folders set to ".. base_ra)
	end

	for i = 1, #RETROARCH_FORZADO do
		quiero[RETROARCH_FORZADO[i][1]] = RETROARCH_FORZADO[i][2]
	end
	local modo = "NTSC"
	if pal == true then modo = "PAL" end
	if RETROARCH_FORZAR_VIDEO == true then
		local vid = RETROARCH_VIDEO[modo]
		for i = 1, #vid do quiero[vid[i][1]] = vid[i][2] end
	else
		modo = modo .." (video NOT forced)"
	end

	local txt = nil
	pcall(function()
		local f = System.openFile(cfg, FREAD)
		local tam = System.sizeFile(f)
		System.seekFile(f, 0, SET)
		txt = System.readFile(f, tam)
		System.closeFile(f)
	end)
	if txt == nil then
		boot_log("CONF   unreadable: ".. cfg)
		boot_flush()
		return false
	end

	-- The file already ends in a newline. Without removing it, the "txt..newline" below
	-- would add an empty line on every boot.
	if string.sub(txt, -1) == "\n" then txt = string.sub(txt, 1, -2) end

	-- A single pass over the lines: cheaper than one gsub per key over 44 KB.
	local salida, vistas, cambios = {}, {}, 0
	for cruda in string.gmatch(txt .."\n", "([^\n]*)\n") do
		-- The control variable of a "for" is constant since Lua 5.4: it has to be
		-- copied before being touched. And the file may arrive with CRLF endings.
		local linea = cruda
		if string.sub(linea, -1) == "\r" then linea = string.sub(linea, 1, -2) end
		local clave = string.match(linea, "^([%w_]+) = ")
		if clave ~= nil and quiero[clave] ~= nil then
			vistas[clave] = true
			local nueva = clave .. ' = "'.. quiero[clave] ..'"'
			if linea ~= nueva then cambios = cambios + 1 end
			salida[#salida + 1] = nueva
		else
			salida[#salida + 1] = linea
		end
	end
	for clave, valor in pairs(quiero) do
		if vistas[clave] ~= true then
			salida[#salida + 1] = clave .. ' = "'.. valor ..'"'
			cambios = cambios + 1
		end
	end

	if cambios == 0 then
		boot_log("CONF   ".. modo .." already correct  ".. tostring(quiero["savefile_directory"]))
		boot_flush()
		return true
	end

	local nuevo = table.concat(salida, "\n") .."\n"
	local ok = false
	pcall(function()
		local f = System.openFile(cfg, FCREATE)
		System.writeFile(f, nuevo, string.len(nuevo))
		System.closeFile(f)
		ok = true
	end)
	boot_log("CONF   ".. modo .."  ".. tostring(cambios) .." key(s) forced, written=".. tostring(ok))
	boot_log("       ".. tostring(quiero["savefile_directory"]) .." , ".. tostring(quiero["savestate_directory"]))
	-- This comes out just before loadELF, which never returns: if it is not flushed
	-- now, the diagnostics are lost with the process.
	boot_flush()
	return ok
end

--- The MASTER installation: the one with ALL the cores. -------------------------------
--- There are two installations and confusing them was the underlying bug:
---
---   the master   next to the launcher, with the nightly's 60 cores. Says WHAT
---                can be played. No core has to be able to read it.
---   the stick    "<stick>/Prism/LibretroPS2Files", with THE core of the game
---                and nothing else. Says what it is run with.
---
--- RUTA_LIBRETRO returns the second as soon as it exists, because it is the only one
--- a core can read after the SifIopReset. Asking it "do you have handy?" gives no,
--- and the game was rejected before trying anything -- which is the "Games or
--- RetroArch not found" of Lynx, GBA, GB, GBC and NES with sixty cores on the drive.
function libretro_master_path()
	local propia = System.currentDirectory() .."/LibretroPS2Files"
	if System.listDirectory(propia .."/cores") ~= nil then return propia end
	if RAICES ~= nil then
		for i = 1, #RAICES do
			for k = 1, #LIBRETRO_SUBS do
				local cand = RAICES[i] .. LIBRETRO_SUBS[k]
				if System.listDirectory(cand .."/cores") ~= nil then return cand end
			end
		end
	end
	return RUTA_LIBRETRO()
end

--- Resolves a core in the master installation. ---------------------------------------
function core_master_path(nombre_core, ruta_original)
	if nombre_core == nil or nombre_core == " " then return ruta_original end
	local base = libretro_master_path()
	if base ~= nil then
		local cand = base .."/cores/".. nombre_core
		if doesFileExist(cand) then return cand end
	end
	return ruta_original
end

function RUTA_CORE(nombre_core, ruta_original)
	if nombre_core == nil or nombre_core == " " then return ruta_original end
	-- A single installation, whichever RUTA_LIBRETRO chose: the one the core will be
	-- able to read after resetting the IOP.
	local base = RUTA_LIBRETRO()
	if base ~= nil then
		local cand = base .."/cores/".. nombre_core
		if doesFileExist(cand) then return cand end
	end
	return ruta_original
end

--- Extensions declared by a core, read from its ".info". ----------------------------
--- "picodrive_libretro_ps2.elf" -> "info/picodrive_libretro.info".
function core_extensions(ruta_core)
	local n = nombre_fichero(ruta_core)
	if string.len(n) < 9 or string.sub(n, -8) ~= "_ps2.elf" then return nil end
	local info = string.sub(n, 1, -9) ..".info"

	-- In the MASTER first. The stick installation carries a single ".info", that of the
	-- core of the current game: searching there, every other core was left with no
	-- declared extensions, CORE_SIRVE wrote them off as useless, and each system's core
	-- list came out empty. The sixty cores on the drive were invisible.
	local sitios = {}
	local maestra = libretro_master_path()
	if maestra ~= nil then table.insert(sitios, maestra) end
	if RAICES ~= nil then
		for i = 1, #RAICES do
			for k = 1, #LIBRETRO_SUBS do
				table.insert(sitios, RAICES[i] .. LIBRETRO_SUBS[k])
			end
		end
	end
	local base_ra = RUTA_LIBRETRO()
	if base_ra ~= nil then table.insert(sitios, base_ra) end

	for i = 1, #sitios do
		local p = sitios[i] .."/info/".. info
		if doesFileExist(p) then
			local txt = nil
			pcall(function()
				local f = System.openFile(p, FREAD)
				local tam = System.sizeFile(f)
				System.seekFile(f, 0, SET)
				txt = System.readFile(f, tam)
				System.closeFile(f)
			end)
			if txt ~= nil then
				return string.match(txt, "supported_extensions%s*=%s*\"([^\"]*)\"")
			end
		end
	end
	return nil
end

--- A core serves a system if it declares one of its extensions. ---------------------
function CORE_SIRVE(ruta_core, identidad)
	local exts = SISTEMA_EXTEN[identidad]
	if exts == nil then return true end
	local sup = core_extensions(ruta_core)
	if sup == nil then return false end
	sup = "|".. string.lower(sup) .."|"
	for i = 1, #exts do
		if string.find(sup, "|".. exts[i] .."|", 1, true) ~= nil then return true end
	end
	return false
end
