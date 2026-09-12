-- Prism PS2 Launcher - emu/pops.lua
-- POPStarter: POPS/ roots, .VCD lookup, USB delay patch, MC drivers.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- PlayStation 1 / POPStarter. --------------------------------------------------------
--- POPStarter always reads the .VCD and writes the virtual memory card into
--- "<drive>/POPS/<game name>/", wherever its ELF may sit (which is why the layout with
--- the ELF in "APPS/" works). The .VCD files live ONLY in "POPS/", at the root of the
--- drive: it is the only place POPStarter looks for them. PS1 artwork and titles,
--- whatever the game's format, live in "Roms/psx/", as in EmulationStation.

--- Drives that may hold a "POPS" folder at their root: the boot medium and every BDM
--- drive. The same collection is used both for searching and for launching.
function POPS_UNIDADES()
	local u = {}
	local actual = System.currentDirectory()
	local pos = string.find(actual, ":", 1, true)
	if pos ~= nil then table.insert(u, string.sub(actual, 1, pos)) end
	if BDM_DEVICES ~= nil then
		for i = 1, #BDM_DEVICES do
			local rep = false
			for j = 1, #u do if u[j] == BDM_DEVICES[i] then rep = true end end
			if rep == false then table.insert(u, BDM_DEVICES[i]) end
		end
	end
	return u
end

--- The drive whose "POPS/" holds that file. POPStarter demands that the .VCD, its ELF
--- and the memory card all sit on the SAME drive, so launching with POPS_RAIZ failed
--- whenever the game lived on the other medium.
function POPS_DE(nombre)
	if nombre ~= nil then
		local u = POPS_UNIDADES()
		for i = 1, #u do
			if doesFileExist(u[i] .."/POPS/".. nombre) then return u[i] end
		end
	end
	return POPS_RAIZ
end

--- Real path of the .VCD in the "POPS/" of each drive. nil if it is on none of them.
function RUTA_VCD(nombre)
	local u = POPS_UNIDADES()
	for i = 1, #u do
		if doesFileExist(u[i] .."/POPS/".. nombre) then
			return u[i] .."/POPS/".. nombre
		end
	end
	return nil
end

--- true if the .VCD is in the "POPS/" of the POPStarter drive. It used to fetch the
--- file from a library in "Roms/"; there is no library now: it is either there or not.
function VCD_A_POPS(nombre)
	return doesFileExist(POPS_RAIZ .."/POPS/".. nombre)
end

--- POPStarter USB access delay. ------------------------------------------------------
--- POPStarter gives the device up for lost if it is slow to answer, and then writes
--- "Opening mass:/POPS/... FAILED / No POPS directory ? / Increase the USB access
--- delay". The value lives in a single byte of its configuration table, offset 0x413,
--- and it has to be patched in EVERY "XX.<juego>.ELF": each shortcut is a complete
--- POPStarter. It ships as 3, too little for many sticks. 0 = touch nothing.
--- With the modern drivers on the Memory Card the stick mounts fast: 20 is enough and
--- does not lengthen the boot. Raise towards 60 only if the mount failure comes back.
POPS_USB_DELAY = 20

--- Reads the delay byte, so it can be WRITTEN TO THE JOURNAL: without this there is
--- no way to know whether the patch was really applied. nil = unreadable file.
function LEE_USB_DELAY(ruta)
	local valor = nil
	pcall(function()
		local f = System.openFile(ruta, FREAD)
		System.seekFile(f, 0x413, SET)
		local b = System.readFile(f, 1)
		System.closeFile(f)
		if b ~= nil and string.len(b) >= 1 then valor = string.byte(b, 1) end
	end)
	return valor
end

function PARCHE_USB_DELAY(ruta)
	if POPS_USB_DELAY == nil or POPS_USB_DELAY <= 0 then return end
	if ruta == nil or doesFileExist(ruta) == false then return end
	pcall(function()
		local f = System.openFile(ruta, FRDWR)
		-- Signature check: the bytes surrounding the delay. The first one varies
		-- between builds (0x00 in the main Rev 13, 0xFF in the community
		-- "USBDELAY" ones); the rest of the frame is stable.
		System.seekFile(f, 0x410, SET)
		local marco = System.readFile(f, 8)
		local b1 = (marco ~= nil and string.len(marco) >= 8) and string.byte(marco, 1) or -1
		if marco == nil or string.len(marco) < 8
		   or (b1 ~= 0 and b1 ~= 0xFF)
		   or string.byte(marco, 2) ~= 0 or string.byte(marco, 3) ~= 0
		   or string.byte(marco, 5) ~= 0x40 or string.byte(marco, 8) ~= 1 then
			System.closeFile(f)
			return
		end
		System.seekFile(f, 0x413, SET)
		System.writeFile(f, string.char(POPS_USB_DELAY), 1)
		System.closeFile(f)
	end)
end

--- POPStarter replacement USB drivers, on the Memory Card. ---------------------------
--- Verified on this console: POPStarter only mounts certain sticks if it finds
--- "mc0:/POPSTARTER/usbd.irx" and "usbhdfsd.irx" (BDMAssault) - and the names must be
--- in LOWER CASE; in upper case it does not see them and falls back on its internal
--- 2019 drivers, which fail with "Opening mass:/POPS/... FAILED".
--- This function REPAIRS the installation before every launch: it creates the
--- directory, copies whatever files are missing (from SYS-CONF on the card itself, or
--- from a POPSTARTER/ on any root) and fixes the name if the case is not as expected.
--- Returns a multi-line text for the launch journal.
function POPSTARTER_DRIVERS_MC()
	local dir = "mc0:/POPSTARTER"
	local lineas = {"Replacement drivers in ".. dir .." (lower case mandatory):"}

	local function listar()
		local reales = {}
		local c = System.listDirectory(dir)
		if c ~= nil then
			for i = 1, #c do
				if c[i].directory == false then
					reales[string.lower(c[i].name)] = c[i].name
				end
			end
		end
		return reales, (c ~= nil)
	end

	local reales, existe = listar()
	if existe == false then
		pcall(System.createDirectory, dir)
		reales, existe = listar()
		table.insert(lineas, "  directory created: ".. tostring(existe))
	end

	for _i, nombre in ipairs({"usbd.irx", "usbhdfsd.irx"}) do
		local real = reales[nombre]
		if real == nombre then
			table.insert(lineas, "  ".. nombre .." : ok")
		elseif real ~= nil then
			-- Wrong case. Renaming directly can fail in mcman when only the
			-- case changes, so it goes through an intermediate name.
			pcall(System.copyFile, dir .."/".. real, dir .."/fix.tmp")
			pcall(System.removeFile, dir .."/".. real)
			if System.rename ~= nil then
				pcall(System.rename, dir .."/fix.tmp", dir .."/".. nombre)
			end
			if listar()[nombre] ~= nombre then
				pcall(System.copyFile, dir .."/fix.tmp", dir .."/".. nombre)
				pcall(System.removeFile, dir .."/fix.tmp")
			end
			local ahora = listar()[nombre]
			table.insert(lineas, "  ".. nombre .." : renamed from '".. real .."' -> ".. tostring(ahora == nombre))
		else
			-- Absent: copy from the first source that exists.
			local fuentes = {"mc0:/SYS-CONF/".. string.upper(nombre),
				"mc0:/SYS-CONF/".. nombre}
			local pos = string.find(System.currentDirectory(), ":", 1, true)
			if pos ~= nil then
				local raiz = string.sub(System.currentDirectory(), 1, pos)
				table.insert(fuentes, raiz .."/POPSTARTER/".. string.upper(nombre))
				table.insert(fuentes, raiz .."/POPSTARTER/".. nombre)
			end
			if RAICES ~= nil then
				for r = 1, #RAICES do
					-- Both IRX ship with the launcher, in the "IRX/" folder at the
					-- root. The historic path is kept behind it, in case someone already
					-- has them placed the old way.
					table.insert(fuentes, RAICES[r] .."/IRX/".. nombre)
					table.insert(fuentes, RAICES[r] .."/Bios/POPSTARTER/".. nombre)
				end
			end
			local hecho = false
			for f = 1, #fuentes do
				if hecho == false and doesFileExist(fuentes[f]) then
					pcall(System.copyFile, fuentes[f], dir .."/".. nombre)
					hecho = (listar()[nombre] == nombre)
					if hecho then
						table.insert(lineas, "  ".. nombre .." : copied from ".. fuentes[f])
					end
				end
			end
			if hecho == false then
				table.insert(lineas, "  ".. nombre .." : ABSENT and no source to copy it from.")
				table.insert(lineas, "    Without it, POPStarter uses its 2019 drivers and")
				table.insert(lineas, "    may fail to mount the USB stick.")
			end
		end
	end
	return table.concat(lineas, "\n")
end

--- IOP reboot for POPStarter and Ember: NEVER. ---------------------------------------
--- Confirmed on real hardware and by the project's author: "restarting the IOP
--- causes the .ELF file to be lost, resulting in the game immediately closing and
--- returning to the PS2 menu". The reset unloads the USB drivers and the loader can no
--- longer read the very ELF it is meant to launch -> back to the console menu.
--- The value 1 was a diagnostic hypothesis for the VCDs; the real culprit was
--- POPStarter's USB access delay (POPS_USB_DELAY), not the state of the IOP.
IOP_REBOOT_POPS = 0
IOP_REBOOT_EMBER = 0

--- OPL is the exception, and it is not a guess. -----------------------------------------
--- CosmicScale/OPL-Launcher-BDM - the launcher PSBBN uses to boot a BDM game - resets
--- the IOP before handing OPL its four arguments:
---     if (argc > 1) { SifIopReset(NULL, 0); SifIopSync(); SifInitRpc(0); }
--- OPL brings up its own BDM stack, and bringing one up on top of Enceladus's already
--- registered one is the "BDM: ERROR: Already registered!" hang this project has met
--- before. Set to 0 to go back to the old behaviour, which gave a black screen.
--- Tested on hardware, in this order:
---   0  -> black screen that stays. OPL is brought up on top of Enceladus's BDM stack.
---   1  -> straight back to the console menu. Enceladus resets the IOP and is then left
---         with no driver able to read the ELF it was about to load, which is the same
---         fault already written down for the libretro cores.
--- Neither works from here, so OPL cannot be started directly by Prism at all: it needs
--- a small ELF in between that resets the IOP and THEN reads OPNPS2LD.ELF itself, which
--- is exactly what OPL-Launcher-BDM is and why PSBBN ships one.
IOP_REBOOT_OPL = 1
