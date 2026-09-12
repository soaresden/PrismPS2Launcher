--[[------------------SPAGHETTICODE-------------------]]--
--[[█▀█ ██▀ ▀█▀ █▀█ █▀█ █    ▄▄ ▄ ▄ ▄▄▄ ▄▄▄ █▄▄ ▄▄  ▄▄]]--
--[[█▀▄ █▄▄  █  █▀▄ █▄█ █▄▄ ▀▄█ █▄█ █ █ █▄▄ █ █ ██▄ █ ]]--
--[[------------------- v1.0/rev2 --------------------]]--

--- Enceladus 2024 <-> 2025+ compatibility layer ---------------------------------------
--- The 2024 build shipped with Prism defines FREAD/FWRITE/FCREATE, SET/CUR/END,
--- the "Sif" table and System.rename. Recent versions have replaced those with
--- O_RDONLY/O_WRONLY/O_CREAT..., the "IOP" table and System.moveFile.
--- This block does NOTHING on the old build: it only fills in what is missing.
if FREAD   == nil and O_RDONLY ~= nil then FREAD   = O_RDONLY end
if FWRITE  == nil and O_WRONLY ~= nil then FWRITE  = O_WRONLY end
if FRDWR   == nil and O_RDWR   ~= nil then FRDWR   = O_RDWR   end   -- used by guardar()
if FCREATE == nil and O_CREAT  ~= nil then FCREATE = O_RDWR | O_CREAT | O_TRUNC end
if SET == nil then SET = 0 end
if CUR == nil then CUR = 1 end
if END == nil then END = 2 end
if Sif == nil and IOP ~= nil then Sif = IOP end
if System.rename == nil and System.moveFile ~= nil then System.rename = System.moveFile end

--- Loading a module: dofile with an absolute path, the one mechanism proven on the
--- console (index.lua chains to this file the same way). require() with a nested
--- path is not. The journal gets the file name BEFORE it runs, so a module that
--- fails to load is named by the last line of the log.
function load_module(name)
	local path = System.currentDirectory() .."/System/".. name ..".lua"
	if boot_log ~= nil then
		boot_log("BOOT   module ".. name)
		boot_flush()
	end
	dofile(path)
end

load_module("core/devices")

--- Build detection: the global "IOP" table only exists on recent Enceladus. -----------
ENCELADUS_MODERNO = (IOP ~= nil)

--- Try to load "IRX" modules. ----------------------------------------------------------
--- Only attempted on the recent build. On the 2024-10-20 ELF shipped with
--- Prism, "Sif.loadModule" hangs the console on ANY call: tried with the
--- 1-argument and 3-argument forms, and even with a file that is not a valid
--- IRX at all. It freezes before video initialisation, with no message on
--- screen at all.
IRX_CARGA_ACTIVA = ENCELADUS_MODERNO

--- Order is forced: "ata_bd.irx" imports the "dev9" library, so the dev9 driver
--- has to be loaded BEFORE it. System.listDirectory guarantees no order at all.
---   dev9_ns.irx : dev9 driver (network adapter hardware).
---   ata_bd.irx  : exposes the internal disk to the BDM stack. Imports "dev9" and "bdm".
--- Nothing else is needed. "poweroff.irx" only existed to satisfy an import from
--- "ps2dev9.irx", dropped in favour of Neutrino's version, and "_test_dummy.irx"
--- was the diagnostic canary.
IRX_ORDEN = {"dev9_ns.irx", "ata_bd.irx"}

--- Do not load: Enceladus already loads these, or they are diagnostic leftovers.
IRX_IGNORAR = {"usbd.irx", "usbhdfsd.irx", "bdm.irx", "bdmfs_fatfs.irx", "usbmass_bd.irx",
	"iomanx.irx", "filexio.irx", "dev9_hidden.irx", "ps2dev9.irx", "poweroff.irx",
	"_test_dummy.irx"}

BDM_DEVICES = {}
BDM_ATA = {}   -- drives that are the internal ATA disk, not a USB

load_module("core/log")

--- Identity of the boot medium. -------------------------------------------------------
--- Behaviour depends on WHERE the program was launched FROM:
---   mc0:/mc1:    Memory Card.
---   massN:       BDM: a USB or the internal ATA disk. Told apart by the marker.
---   hdd0:/pfs:   internal HDD with APA partitions (native stack, another world).
---   host:        PCSX2 / ps2link.
--- The "Roms/!Prism/internal-ata-disk.flag" marker is written from the PC onto
--- the internal disk. It is needed because dynamic detection ("the drive appeared
--- when ata_bd loaded") sees nothing appear when booting FROM the disk itself: in
--- that case the drivers were already resident, loaded by the launcher.
MARCA_ATA = "/Roms/!Prism/internal-ata-disk.flag"

BOOT_DEV = ""            -- "mass0:", "mc0:", "hdd0:"...
BOOT_TIPO = "desconocido"
BOOT_ES_ATA = false      -- true if the program boots from the internal disk

if true then
	local dir = System.currentDirectory()
	local pos = string.find(dir, ":", 1, true)
	if pos ~= nil then BOOT_DEV = string.sub(dir, 1, pos) end
	local base = string.lower(BOOT_DEV)
	if base == "mc0:" or base == "mc1:" then
		BOOT_TIPO = "Memory Card"
	elseif string.sub(base, 1, 4) == "mass" then
		if doesFileExist(dir .. MARCA_ATA) then
			BOOT_TIPO = "internal ATA disk on exFAT (marker present)"
			BOOT_ES_ATA = true
		else
			BOOT_TIPO = "BDM: USB (or internal disk with no marker)"
		end
	elseif string.sub(base, 1, 3) == "hdd" or string.sub(base, 1, 3) == "pfs" then
		BOOT_TIPO = "internal APA HDD (native stack)"
	elseif base == "host:" then
		BOOT_TIPO = "host (PCSX2 / ps2link)"
	elseif base == "cdfs:" then
		BOOT_TIPO = "optical disc"
	end
	local build = "2024 (Sif table, no IOP table)"
	if ENCELADUS_MODERNO then build = "2025+ (IOP table present)" end
	-- The first question the log has to answer when you open it: where the ELF
	-- comes from. It changes everything else -- whether the boot argument is needed,
	-- whether RetroArch can read itself, whether the ROMs have to be ferried over.
	if BOOT_ES_ATA == true then
		boot_log("BOOTED FROM     : INTERNAL exFAT DISK  (".. BOOT_DEV ..")")
	else
		boot_log("BOOTED FROM     : USB STICK / external medium  (".. BOOT_DEV ..")")
	end
	boot_log("Boot medium         : ".. BOOT_DEV .."  -> ".. BOOT_TIPO)
	boot_log("currentDirectory    : ".. dir)
	boot_log("Enceladus build     : ".. build)
	boot_log("ATA marker sought   : ".. dir .. MARCA_ATA)
	boot_log("")
end

--- Video mode, then the boot screen - as early as possible, so the console is never
--- black while the drives are probed. The theme and the drawing helpers come first:
--- the boot screen is drawn with them, and the fonts it creates are the interface's
--- fonts (Font.ftInit runs once).
load_module("ui/theme")
load_module("ui/gfx")
load_module("ui/loading")

if true then
	local res_x, res_y = 640, 448
	-- A marker file picks the mode: System/Defaults/PAL or NTSC (the START menu
	-- writes them). Neither present means NTSC, and the marker is created.
	if doesFileExist("System/Defaults/PAL") == false and doesFileExist("System/Defaults/NTSC") == false then
		local VMODE = System.openFile("System/Defaults/NTSC", FCREATE)
		System.closeFile(VMODE)
	elseif doesFileExist("System/Defaults/PAL") then
		Screen.setMode(PAL, 640, 512, CT24, INTERLACED, FIELD)
		res_x, res_y = 640, 512
	end
	-- Then ASK, rather than believe the above. Enceladus starts a PAL console at
	-- 640x512 on its own, whatever the marker file says, so a stick with no marker
	-- had the interface laying itself out for 448 lines on a 512-line screen - which
	-- is precisely the band of nothing that kept appearing under the credits.
	pcall(function()
		local m = Screen.getMode()
		if m ~= nil and m.width ~= nil and m.height ~= nil
		   and m.width > 0 and m.height > 0 then
			res_x, res_y = m.width, m.height
		end
	end)
	boot_log("BOOT   screen ".. res_x .."x".. res_y)
	loading_init(res_x, res_y)
	local origin, kind = origin_text()
	load_step(origin, kind)
	boot_log("BOOT   boot screen up")
	boot_flush()
end

load_step("loading drivers")
load_module("core/drives")
irx_load()
load_step("probing drives")

--- Game search roots ("append" USB + internal disk). ----------------------------------
--- RAICES[1] is ALWAYS the boot medium. ATA drives are added when they hold a
--- directory with the same name as the launcher's own.
--- Example: boot on "mass:/Prism", internal disk on "mass1:" holding a
--- "mass1:/Prism" => games are looked for on both.
RAICES = { System.currentDirectory() }

--- Name of the launcher folder, whatever it is. It is kept because other parts
--- need to build the same path on another medium, and assuming it is called
--- "Prism" would break the moment somebody renamed it.
CARPETA_LANZADOR = "Prism"

if true then
	local actual = System.currentDirectory()
	local nombre_carpeta = actual
	local corte = string.find(string.reverse(actual), "/", 1, true)
	if corte ~= nil then nombre_carpeta = string.sub(actual, -corte+1) end
	CARPETA_LANZADOR = nombre_carpeta
	-- ANY BDM drive with a same-named directory, ATA or USB. The "ATA only"
	-- restriction was right when boot always came from USB; booting FROM the
	-- internal disk inverts it, and now it is the USB stick that must be added.
	for i = 1, #BDM_DEVICES do
		local candidata = BDM_DEVICES[i] .."/".. nombre_carpeta
		if System.listDirectory(candidata) ~= nil then
			table.insert(RAICES, candidata)
		end
	end
	local resumen = "\nSearch roots:\n"
	for i = 1, #RAICES do resumen = resumen .."  ".. i ..". ".. RAICES[i] .."\n" end
	boot_log(resumen)
end

--- Drive where the "POPS" directory lives. It can be on the boot medium or on the
--- internal exFAT disk. The one holding the POPStarter binaries ("POPS_IOX.PAK") is
--- preferred, then any that exists, and as a last resort the boot medium.
POPS_RAIZ = nil

if true then
	local cand = {}
	local pos = string.find(System.currentDirectory(), ":", 1, true)
	if pos ~= nil then table.insert(cand, string.sub(System.currentDirectory(), 1, pos)) end
	for i = 1, #BDM_DEVICES do table.insert(cand, BDM_DEVICES[i]) end

	for i = 1, #cand do
		if POPS_RAIZ == nil and doesFileExist(cand[i] .."/POPS/POPS_IOX.PAK") then
			POPS_RAIZ = cand[i]
		end
	end
	if POPS_RAIZ == nil then
		for i = 1, #cand do
			if POPS_RAIZ == nil and System.listDirectory(cand[i] .."/POPS") ~= nil then
				POPS_RAIZ = cand[i]
			end
		end
	end
	if POPS_RAIZ == nil and #cand >= 1 then POPS_RAIZ = cand[1] end
	if POPS_RAIZ == nil then POPS_RAIZ = "mass:" end
end

boot_log("POPS_RAIZ = ".. tostring(POPS_RAIZ))

--- POPStarter configuration check. ---------------------------------------------------
--- The replacement USB drivers (BDMAssault) ONLY work from the Memory Card:
--- "mc0:/POPSTARTER/usbd.irx" and "usbhdfsd.irx". At boot, POPStarter cannot read
--- the USB yet -that is precisely what it is trying to mount- so a POPSTARTER/ on
--- the stick is dead letter. The EXACT names are listed here, because it is also
--- case sensitive.
if true then
	boot_log("")
	boot_log("POPStarter check (replacement drivers):")
	for _i, mc in ipairs({"mc0:", "mc1:"}) do
		local c = System.listDirectory(mc .."/POPSTARTER")
		if c == nil then
			boot_log("  ".. mc .."/POPSTARTER/  does not exist")
		else
			local linea = "  ".. mc .."/POPSTARTER/  (".. #c .." entries)"
			local vistos = {}
			for i = 1, #c do
				if c[i].directory == false then
					linea = linea .."\n      ".. c[i].name .."  (".. tostring(c[i].size) .." bytes)"
					vistos[string.lower(c[i].name)] = c[i].name
				end
			end
			for _j, esperado in ipairs({"usbd.irx", "usbhdfsd.irx"}) do
				local real = vistos[esperado]
				if real == nil then
					linea = linea .."\n      MISSING ".. esperado
				elseif real ~= esperado then
					linea = linea .."\n      NOTE: '".. real .."' should be called '".. esperado .."' (lowercase)"
				end
			end
			boot_log(linea)
		end
	end
	local pos_b = string.find(System.currentDirectory(), ":", 1, true)
	if pos_b ~= nil then
		local raiz_boot = string.sub(System.currentDirectory(), 1, pos_b)
		if System.listDirectory(raiz_boot .."/POPSTARTER") ~= nil then
			boot_log("  WARNING: there is a ".. raiz_boot .."/POPSTARTER/ - it is NO use there.")
			boot_log("  POPStarter can only read those drivers from the Memory Card.")
		end
	end
end

boot_log("")
boot_log("End of system boot. What follows is appended without a per-line flush.")
BOOT_FLUSH = false
boot_flush()

--- Everything below is definitions: paths, then one module per emulator. Nothing
--- runs until inventario() further down, so their order only follows the drive.
load_step("loading emulator modules")
load_module("core/paths")
load_module("emu/pops")
load_module("library/exfatdb")
load_module("emu/retroarch")
load_module("emu/ember")
load_module("emu/retroarch_shuttle")
load_module("emu/ps2")

--- inventario() uses ES_RAIZ_ATA, so it is called AFTER it is defined. ---------------
inventario()

--- The "retroarch/" folder RetroArch insists on. It is built HERE, when the
--- launcher starts, and not inside FORZAR_CONF_RETROARCH: that way it keeps working
--- even with the forced settings turned off, and the user only has to unpack the
--- nightly into "LibretroPS2Files/" and think no further.
LIBRETRO_REPARAR()

--- RetroArch install diagnostic, at boot. --------------------------------------------
--- This is the question that decides whether libretro games will work at all, so it
--- is worth writing down before any attempt is made.
if true then
	local base_ra = RUTA_LIBRETRO()
	if base_ra == nil then
		boot_log("")
		boot_log("RETROARCH  NOT FOUND. No medium carries LibretroPS2Files/cores.")
		boot_log("           The libretro systems will not be offered.")
	elseif ES_RAIZ_ATA(base_ra) == true then
		boot_log("")
		boot_log("RETROARCH  installed on the INTERNAL DISK : ".. base_ra)
		boot_log("           WARNING: an official core will not be able to read it. At")
		boot_log("           startup it does SifIopReset, the IOP is wiped and the")
		boot_log("           internal disk stops existing for it: no cores, no config")
		boot_log("           and no assets, and it dies before drawing anything. Black")
		boot_log("           screen. Fix: move LibretroPS2Files to a USB stick.")
		boot_log("           (Works as is with cores rebuilt against ata_bd.)")
	else
		boot_log("")
		boot_log("RETROARCH  ".. base_ra .."  (medium the cores can read)")
	end
	boot_flush()
end

usb_inventory()

--- Save bridge return leg: called right at startup, which is when we come back
--- from a game. It needs RAICES and BDM_DEVICES, hence its place here.
SAVES_RECUPERAR()

--- Audio format. -----------------------------------------------------------------------
Sound.setFormat(16, 48000, 3)

load_module("ui/sound")

--- The interface. -----------------------------------------------------------------------
--- Everything above is the machine: drives, journal, emulators, sound. Everything below
--- is what the user sees, and it only depends on the theme and the library.
load_module("emu/retroarch_prepare")
load_module("emu/ember_park")
load_module("emu/ps1_card")
load_module("systems")
load_module("systems_info")
load_module("core/prefs")
load_module("ui/input")
load_module("ui/widgets")
load_module("library/gamelist_xml")
load_module("library/library")
load_module("library/collections")
load_module("views/systems")
load_module("views/gamelist")
load_module("views/viewer")
load_module("views/launch")
load_module("views/menu")
load_module("launch/backends")
load_module("frontend")
boot_log("BOOT   modules loaded")
boot_flush()

frontend_start()
frontend_run()