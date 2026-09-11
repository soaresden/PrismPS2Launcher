-- Prism PS2 Launcher - core/devices.lua
-- Drive names: mass:/massN: normalisation, which device a core can read.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- Normalises the drive prefix of a path. --------------------------------------------
--- "mass:/X" and "mass0:/X" mean the same thing, but the name depends on WHO launches
--- the program: from the OSD or FMCB you get "mass:", from uLaunchELF "mass0:".
--- Without this, the launcher believes the installation has moved and offers to
--- relocate the configurations (losing the RetroArch settings) on every change
--- of boot method.
function NORM_DEV(ruta)
	if ruta == nil then return "" end
	local pos = string.find(ruta, ":", 1, true)
	if pos == nil then return string.lower(ruta) end
	local dev = string.sub(ruta, 1, pos-1)
	while string.len(dev) > 0 and string.match(string.sub(dev, -1), "%d") ~= nil do
		dev = string.sub(dev, 1, -2)
	end
	return string.lower(dev ..":".. string.sub(ruta, pos+1))
end

--- Strips the numbering from the drive prefix and LEAVES THE REST INTACT. ------------
--- "mass0:/POPS/Juego.VCD" -> "mass:/POPS/Juego.VCD".
--- Not to be confused with NORM_DEV, which also lowercases everything because it is
--- meant for comparing paths; here that would wreck the file name.
--- Needed because Enceladus 2025 mounts the devices as "mass0:", "mass1:",
--- whereas the homebrew that predates BDM -POPStarter v13, Neutrino, RetroArch-
--- only knows "mass:". The 2024 build that Prism was written against
--- reported "mass:", which is why all that worked without touching anything.
function DEV_SIN_NUM(ruta)
	if ruta == nil then return nil end
	local pos = string.find(ruta, ":", 1, true)
	if pos == nil then return ruta end
	local dev = string.sub(ruta, 1, pos-1)
	while string.len(dev) > 0 and string.match(string.sub(dev, -1), "%d") ~= nil do
		dev = string.sub(dev, 1, -2)
	end
	return dev ..":".. string.sub(ruta, pos+1)
end

--- Cores able to read the internal ATA disk. -----------------------------------------
--- The same disk has TWO names, depending on who is looking:
---     Enceladus, with its own BDM stack ....... mass0:
---     a RetroArch core ........................ ata0:
--- Not a whim. "ps2atad.c" gives the ATA disk the name "ata" ("g_ata_bd[i].path"),
--- and the current "bdmfs_fatfs" registers one iomanX device per distinct name,
--- treating "mass" separately. USB declares no name and stays on "mass". The
--- "bdmfs_fatfs" that Enceladus ships is older and puts everything in "mass". Hence the
--- two names for the same disk.
--- Only cores compiled with the patch know about "ata0:". For the others -the 57
--- official nightlies- the internal disk still does not exist, and the ROM has to be
--- transferred to a medium they can read. Hence this list: whatever is not in it gets
--- transferred, which is the safe behaviour.
--- When more cores are recompiled, add them here.
--- At false: NO core reads the internal disk, everything goes through the transfer. That
--- is the right setting with the official nightlies, which carry no ata_bd. Set to true
--- only if cores recompiled with the patch are used, and list them in CORES_ATA.
CORES_ATA_ON = false
CORES_ATA = {
	"fceumm_libretro_ps2.elf",
	"gambatte_libretro_ps2.elf",
	"picodrive_libretro_ps2.elf",
	"snes9x2002_libretro_ps2.elf",
}

function CORE_LEE_ATA(ruta_core)
	if CORES_ATA_ON ~= true or ruta_core == nil then return false end
	local n = string.lower(nombre_fichero(ruta_core))
	for i = 1, #CORES_ATA do
		if n == string.lower(CORES_ATA[i]) then return true end
	end
	return false
end

--- Name of the internal disk as the core will see it. ---------------------------------
--- Verified on console: with a USB stick plugged in, the internal disk shows up as
--- "mass1:"; with no stick, as "mass0:". Not chance, it is the order RetroArch loads
--- the drivers in "init_drivers()": usbmass_bd first, then mx4sio, and ata_bd
--- last. BDM volumes are numbered by order of connection, so the index of the
--- internal disk is exactly the number of USB drives sitting ahead of it.
--- The launcher already knows how many: BDM_DEVICES minus those flagged in BDM_ATA.
---
--- There is also a stable name, "ata0:", which a recent bdmfs_fatfs registers from
--- "bd->path". It is better when it works, because it does not depend on how many sticks
--- are plugged in. Set ATA_DEV_CORE = "ata0:" to use it; nil to compute it.
ATA_DEV_CORE = nil

function DEV_ATA_PARA_CORE()
	if ATA_DEV_CORE ~= nil then return ATA_DEV_CORE end
	local usb = 0
	local propio = ""
	local pos = string.find(System.currentDirectory(), ":", 1, true)
	if pos ~= nil then propio = string.sub(System.currentDirectory(), 1, pos) end
	if propio ~= "" and BDM_ATA[propio] ~= true then usb = usb + 1 end
	if BDM_DEVICES ~= nil then
		for i = 1, #BDM_DEVICES do
			if BDM_ATA[BDM_DEVICES[i]] ~= true and BDM_DEVICES[i] ~= propio then
				usb = usb + 1
			end
		end
	end
	return "mass".. tostring(usb) ..":"
end

--- Translates a path on the internal disk to the name the core will use. --------------
function RUTA_ATA_CORE(ruta)
	if ruta == nil then return nil end
	local pos = string.find(ruta, ":", 1, true)
	if pos == nil then return ruta end
	return DEV_ATA_PARA_CORE() .. string.sub(ruta, pos+1)
end

--- Device name as a RetroArch core will see it. -------------------------------------
--- Only the number has to come off "massN:": RetroArch resets the IOP and mounts its
--- own stack, where USB is called "mass:" with no number. But "mc0:" is called "mc0:"
--- on both sides, and "mc:" does not exist: applying DEV_SIN_NUM blindly produced
--- "mc:/Prism/Saves", a path RetroArch discards for not being a directory,
--- and the saves fell back inside its own folder again.
function DEV_PARA_CORE(ruta)
	if ruta == nil then return nil end
	local pos = string.find(ruta, ":", 1, true)
	if pos == nil then return ruta end
	local dev = string.sub(ruta, 1, pos-1)
	if string.lower(string.sub(dev, 1, 4)) ~= "mass" then return ruta end
	return DEV_SIN_NUM(ruta)
end
