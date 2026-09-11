-- Prism PS2 Launcher - launch/backends.lua
-- One function per way of running a game. Each one prepares what its emulator needs,
-- writes the launch block to the journal, and hands the console over with loadELF -
-- which never returns. If a function does return, the launch failed and it has already
-- said why on the progress screen.
--
-- The heavy lifting (RetroArch on the USB shuttle, save bridge, VMC files, POPStarter
-- patches) is in emu/: proven on the console, untouched here.

--- Entry point from the launch view. -------------------------------------------------
function launch_run(game, plan)
	if game.warn == "chd" then
		launch_begin(game.title)
		launch_fail("A .chd cannot run on the PS2. Convert it on the PC first.")
		return
	end
	local id = plan.backend
	if game.kind == "psx" then
		if id == "ember" then return launch_ember(game, plan) end
		return launch_pops(game, plan)
	elseif game.kind == "ps2" then
		if id == "opl" then return launch_opl(game, plan) end
		return launch_neutrino(game, plan)
	end
	return launch_retroarch(game, plan, id)
end

--- Enceladus names drives "massN:"; a program that mounts its own BDM stack sees the
--- first USB stick as "mass:". Strip the digit, for "mass" only (never "mc0:").
local function bdm_name(path)
	local pos = string.find(path, ":", 1, true)
	if pos == nil then return path end
	local dev = string.sub(path, 1, pos - 1)
	if string.lower(string.sub(dev, 1, 4)) ~= "mass" then return path end
	while string.len(dev) > 0 and string.match(string.sub(dev, -1), "%d") ~= nil do
		dev = string.sub(dev, 1, -2)
	end
	return dev ..":".. string.sub(path, pos + 1)
end

local function file_name(path)
	return string.match(path or "", "([^/]+)$") or path
end

--- RetroArch -------------------------------------------------------------------------------
--- core_id is the libretro name ("snes9x2002"); the file is <id>_libretro_ps2.elf.
function launch_retroarch(game, plan, core_id)
	launch_begin(game.title)
	if core_id == nil then
		launch_fail("No core for ".. tostring(game.kind))
		return
	end
	local core_file = core_id .."_libretro_ps2.elf"
	launch_step("Core: ".. core_file)

	-- 1. The core, in the master install (the one with every core).
	local core_path = core_master_path(core_file, core_file)
	if core_path == nil or doesFileExist(core_path) == false then
		launch_fail("Core not installed: LibretroPS2Files/cores/".. core_file)
		return
	end

	-- 2. The USB shuttle: cores cannot read the internal disk, so what this game needs
	--    is put on a USB stick (only what is missing is copied).
	launch_step("Checking the USB stick")
	local base = LIBRETRO_PREPARAR_PARA(core_file)
	if base ~= nil then core_path = RUTA_CORE(core_file, core_path) end
	if doesFileExist(core_path) == false then
		launch_fail("Core did not reach the USB stick: ".. core_file)
		return
	end
	local reads_ata = CORE_LEE_ATA(core_path)

	-- 3. Configuration RetroArch is not allowed to drift from: saves folders, video mode.
	launch_step("Writing retroarch.cfg")
	FORZAR_CONF_RETROARCH(prefs_is("video", "pal"), reads_ata)
	BIOS_LIBRETRO(reads_ata)

	-- 4. The ROM: on the internal disk it is invisible to the core, so it travels too,
	--    with its saves.
	local rom = game.path
	local moved = "not needed"
	if ES_RAIZ_ATA(rom) and reads_ata == false then
		launch_step("Copying ROM to the USB stick")
		local new_path, where = ROM_TRANSBORDO(rom, game.file)
		moved = tostring(where)
		if string.find(moved, "cache", 1, true) ~= nil then launch_replace("ROM already on the USB stick") end
		if new_path ~= nil then
			local n = SAVES_DESPLEGAR(DEV_DE_RUTA(new_path), CARPETA_DE_RUTA(rom), SIN_EXTENSION(game.file))
			if n > 0 then launch_step("Saves: ".. n .." file(s) travel with the ROM") end
			rom = new_path
		end
	end

	-- 5. argv[1] for the core: the drive name as the core will see it.
	local rom_arg = rom
	if ES_RAIZ_ATA(rom) and reads_ata == true then
		rom_arg = RUTA_ATA_CORE(rom)
	else
		rom_arg = bdm_name(rom)
	end

	log_lanzamiento("RETROARCH  ".. tostring(game.kind), {
		"game      : ".. tostring(game.file),
		"core      : ".. tostring(core_id),
		"",
		log_existe("core", core_path),
		log_existe("rom ", rom),
		"argv[1]   : ".. tostring(rom_arg),
		"core reads ATA : ".. tostring(reads_ata),
		"ROM moved : ".. moved,
		"IOP reboot: ".. tostring(IOP_REBOOT_CORES),
	})
	launch_step("Launching ".. game.title, true)

	-- raboot.elf is the nightlies' official bootstrap; preferred when present.
	local raboot = RUTA_RABOOT()
	if raboot ~= nil and PREPARAR_RABOOT(raboot, core_path) then
		System.loadELF(raboot, IOP_REBOOT_CORES, rom_arg)
	end
	System.loadELF(core_path, IOP_REBOOT_CORES, rom_arg)
end

--- POPStarter -----------------------------------------------------------------------------
--- Needs, on the SAME drive: POPS/<game>.VCD, POPS/XX.<game>.ELF (a renamed copy of
--- POPSTARTER.ELF), and the POPS binaries. PS1toPOPS.py lays all of that out.
function launch_pops(game, plan)
	launch_begin(game.title)
	if game.vcd == nil then
		launch_fail("No .VCD for this game")
		return
	end
	local drive = POPS_DE(game.file)
	local pops = drive .."/POPS"
	local elf = pops .."/XX.".. game.stem ..".ELF"
	launch_step("Drive: ".. drive)
	if doesFileExist(pops .."/POPS_IOX.PAK") == false then
		launch_fail("POPS_IOX.PAK missing in ".. pops .." - POPStarter is not installed there")
		return
	end
	if doesFileExist(elf) == false then
		-- No launcher for this game. POPStarter needs one per game; the PC tool makes
		-- them, and so can we if a copy of POPSTARTER.ELF is at hand.
		local src = System.currentDirectory() .."/POPStarter/POPSTARTER.ELF"
		if doesFileExist(src) then
			launch_step("Creating XX.".. game.stem ..".ELF")
			pcall(System.copyFile, src, elf)
		end
		if doesFileExist(elf) == false then
			launch_fail("Missing ".. file_name(elf) .." in POPS/ (run PS1toPOPS.py)")
			return
		end
	end
	launch_step("Launcher: ".. file_name(elf), true)
	PARCHE_USB_DELAY(elf)
	local reboot = IOP_REBOOT_POPS
	if ES_RAIZ_ATA(drive) then reboot = 0 end

	log_lanzamiento("PS1  POPStarter", {
		"game   : ".. tostring(game.file),
		"drive  : ".. tostring(drive),
		"",
		log_existe("elf ", elf),
		log_existe("vcd ", game.vcd),
		log_existe("iox ", pops .."/POPS_IOX.PAK"),
		log_existe("card", pops .."/".. game.stem .."/SLOT0.VMC"),
		"",
		POPSTARTER_DRIVERS_MC(),
		"",
		"USB delay byte (0x413): ".. tostring(LEE_USB_DELAY(elf)) .."  (setting: ".. tostring(POPS_USB_DELAY) ..")",
		"IOP reboot : ".. tostring(reboot),
	})
	discs_hint(pops .."/".. game.stem .."/DISCS.TXT", game.title)
	System.loadELF(elf, reboot, pops .."/", "--nr")
end

--- Ember -----------------------------------------------------------------------------------
--- Ember/ember.elf, Ember/bios.bin, games/<Folder>/ with the .cue and .bin. Argument =
--- the folder name; Ember resolves everything else from its own directory.
function launch_ember(game, plan)
	launch_begin(game.title)
	if game.ember == nil then
		launch_fail("No Ember folder for this game")
		return
	end
	local root, dir = ember_game(game.ember)
	if root == nil then
		launch_fail("Ember/games/".. game.ember .."/ not found")
		return
	end
	launch_step("Ember at ".. root)
	if ember_bios(root) ~= true then
		launch_fail("bios.bin missing: put a PS1 BIOS in Bios/bios.bin (copied to Ember/ once)")
		return
	end
	local what = ember_contents(dir)
	if what == "chd" then
		launch_fail("This folder holds a .chd - Ember reads .cue/.bin only")
		return
	end
	local reboot = IOP_REBOOT_EMBER
	if ES_RAIZ_ATA(root) then reboot = 0 end
	log_lanzamiento("PS1  Ember", {
		"game    : ".. tostring(game.ember),
		"folder  : ".. tostring(dir),
		"content : ".. tostring(what),
		"",
		log_existe("ember.elf", root .."/ember.elf"),
		log_existe("bios.bin ", root .."/bios.bin"),
		"",
		"argument   : ".. tostring(game.ember),
		"IOP reboot : ".. tostring(reboot),
	})
	launch_step("Launching ".. game.title, true)
	System.loadELF(root .."/ember.elf", reboot, root .."/", game.ember)
end

--- Neutrino ------------------------------------------------------------------------------
--- -bsd=usb for a stick, -bsd=ata for the internal disk (then the disk is the only
--- drive Neutrino sees, named mass:). The VMC is created on the REAL drive name first,
--- and only then rewritten for Neutrino - creating it under the rewritten name put the
--- card on the wrong drive.
function launch_neutrino(game, plan)
	launch_begin(game.title)
	local elf = System.currentDirectory() .."/Neutrino/neutrino.elf"
	if doesFileExist(elf) == false then
		launch_fail("Neutrino/neutrino.elf missing")
		return
	end
	local dir = game.dir
	local iso_path = dir .."/".. game.file
	local real_drive = string.match(dir, "^[^:]+:") or "mass0:"
	local bsd = "usb"
	local on_ata = ES_RAIZ_ATA(dir)
	if on_ata then bsd = "ata" end
	launch_step("Image on ".. real_drive .."  (-bsd=".. bsd ..")")

	local args = {}
	local vmc_arg = nil
	launch_step("Memory card")
	local ok, v = pcall(vmc_auto, game.file, real_drive)
	if ok and v ~= nil then
		vmc_arg = v
		if on_ata then
			-- With -bsd=ata the disk is the only drive Neutrino sees, as "mass:".
			local pv = string.find(vmc_arg, ":", 1, true)
			if pv ~= nil then vmc_arg = "-mc0=mass:".. string.sub(vmc_arg, pv + 1) end
		end
		launch_replace("Memory card: ".. string.gsub(v, "^%-mc0=", ""))
	else
		launch_replace("Memory card: real card in slot 1")
	end
	if vmc_arg ~= nil then args[#args + 1] = vmc_arg end
	args[#args + 1] = "-gsm="
	args[#args + 1] = "-bsd=".. bsd
	local dvd = iso_path
	if on_ata then
		local pos = string.find(dvd, ":", 1, true)
		if pos ~= nil then dvd = "mass:".. string.sub(dvd, pos + 1) end
	end
	args[#args + 1] = "-dvd=".. dvd

	log_lanzamiento("PS2  Neutrino", {
		"game   : ".. tostring(game.file),
		"iso    : ".. tostring(iso_path),
		"-bsd   : ".. bsd,
		"-dvd   : ".. dvd,
		"vmc    : ".. tostring(vmc_arg),
		"",
		log_existe("neutrino.elf", elf),
		log_existe("iso", iso_path),
	})
	launch_step("Launching ".. game.title, true)
	System.loadELF(elf, 0, table.unpack(args))
end

--- OPL ----------------------------------------------------------------------------------------
--- With an OPL-named image ("SLES_123.45.Title.iso") OPL can boot the game directly;
--- otherwise it opens on its own menu.
function launch_opl(game, plan)
	launch_begin(game.title)
	local elf = System.currentDirectory() .."/OPL/OPNPS2LD.ELF"
	if doesFileExist(elf) == false then
		launch_fail("OPL/OPNPS2LD.ELF missing")
		return
	end
	local id = string.match(game.file, "^(%u%u%u%u_%d%d%d%.%d%d)%.")
	local folder = file_name(game.dir)   -- "DVD" or "CD"
	log_lanzamiento("PS2  OPL", {
		"game   : ".. tostring(game.file),
		"id     : ".. tostring(id),
		"folder : ".. tostring(folder),
		log_existe("opl", elf),
	})
	launch_step("Launching OPL", true)
	if id ~= nil then
		System.loadELF(elf, 0, game.file, id, folder, "bdm")
	end
	System.loadELF(elf, 0)
end
