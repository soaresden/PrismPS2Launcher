-- Prism PS2 Launcher - core/log.lua
-- The session journal (log/Debug_*.log), launch log, inventories.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- =====================================================================================
--- ONE journal: "Prism.log", beside the ELF. ---------------------------------
--- There were four -- BOOT_LOG, LAUNCH_LOG, MEDIA_LOG, PREBOOT_LOG -- and none was
--- ever read end to end: what is needed is the ORDER of events, and spread across
--- four files the order is lost. Now everything goes to one, with a category per
--- line, which is what separated the files and fits in six characters:
---
---   PRE     the pre-boot (System/index.lua), before any of this exists
---   BOOT    boot medium, IRX, drives, roots
---   CARGA   the boot steps, the same ones seen on screen
---   CONF    what is imposed on "retroarch.cfg"
---   SAVES   the save bridge, disc <-> key
---   LANZA   the launch sequence of a game, and the dump written before loadELF
---   ART     the last image opened (see ART_LOG_ON)
---
--- Writes from the very first line of code. During the critical phase every line
--- rewrites the whole file (BOOT_FLUSH): if the console freezes, the last line
--- written names the culprit. If the file never even comes into existence, the hang
--- is BEFORE Lua -- a driver conflict in the Enceladus boot -- and no script can
--- ever see it.
--- The destination is resolved once and ALWAYS on the medium that launched the
--- program: "log/" beside the ELF, or plain beside the ELF if "log/" cannot be
--- created. Never on a Memory Card.
BOOT_LOG_ON = true
BOOT_FLUSH = true
BOOT_LOG_DESTINO = nil

--- ONE FILE PER SESSION, in log/. -----------------------------------------------------
--- "log/Debug_YYYY-MM-DD_HHMMSS.log", stamped with the moment the program started, so
--- two boots can never share a file and a failed launch that drops back to uLaunchELF
--- leaves its trace intact for the next attempt to sit beside, not on top of.
---
--- This also retires the history prefix the single-file journal needed: every line
--- used to rewrite the WHOLE file, previous sessions included, which on exFAT came to
--- nearly two megabytes of writes before the menu appeared. A session file starts
--- empty and only ever carries its own lines.
---
--- The folder is trimmed to LOG_KEEP files, oldest first by name - the name IS the
--- date - so the drive does not fill up with a thousand boots.
LOG_DIR = "log"
LOG_KEEP = 20
BOOT_LOG_TXT = ""
LOG_FILE = nil

if true then
	local sello, nombre = "", "Debug_unknown.log"
	pcall(function()
		sello = os.date("%Y-%m-%d %H:%M:%S")
		nombre = "Debug_".. os.date("%Y-%m-%d_%H%M%S") ..".log"
	end)
	LOG_FILE = nombre
	BOOT_LOG_TXT = "Prism - session ".. sello .."\n"
		.."One line per event, category first. BOOT_LOG_ON = false in\n"
		.."System/system.lua turns this off.\n"
		.."============================================================\n"

	-- The pre-boot (System/index.lua, run from the memory card before any of this
	-- exists) still writes its PRE lines to Prism.log beside the ELF. They are
	-- the only trace of the IRX loading, so they are pulled into this session's file
	-- and the old file goes - consumed, not lost.
	pcall(function()
		local previo = System.currentDirectory() .."/Prism.log"
		if doesFileExist(previo) == false then return end
		local f = System.openFile(previo, FREAD)
		local tam = System.sizeFile(f)
		System.seekFile(f, 0, SET)
		local t = System.readFile(f, tam)
		System.closeFile(f)
		if t ~= nil and string.len(t) > 0 then
			if string.len(t) > 12000 then t = "[...]\n".. string.sub(t, -12000) end
			BOOT_LOG_TXT = BOOT_LOG_TXT .."--- pre-boot (from Prism.log) ---\n"
				.. t .."--- end of pre-boot ---\n"
		end
	end)
end

--- The last image opened. It does not accumulate: it is replaced. ---------------------
--- This used to rewrite a file on EVERY cover loaded, that is on every movement
--- through the list. Now it is one line at the end of the journal, overwriting itself.
ART_ULTIMA = nil

--- Old sessions beyond LOG_KEEP, dropped oldest first. --------------------------------
local function log_rotate(dir)
	pcall(function()
		local lista = System.listDirectory(dir)
		if lista == nil then return end
		local nombres = {}
		for i = 1, #lista do
			local n = lista[i].name
			if lista[i].directory == false and string.sub(n, 1, 6) == "Debug_"
			   and string.sub(n, -4) == ".log" then
				nombres[#nombres + 1] = n
			end
		end
		table.sort(nombres)
		for i = 1, #nombres - LOG_KEEP do
			pcall(System.removeFile, dir .."/".. nombres[i])
		end
	end)
end

function boot_flush()
	if BOOT_LOG_ON ~= true then return end
	pcall(function()
		local texto = BOOT_LOG_TXT
		if ART_ULTIMA ~= nil then texto = texto .."ART    ".. ART_ULTIMA .."\n" end
		if BOOT_LOG_DESTINO == nil then
			-- ONLY on the medium that launched the program: log/ next to the ELF, or
			-- beside the ELF if log/ cannot be created. Never a memory card: a journal
			-- that lands on mc0 is one nobody finds, and it fills the card. If nothing
			-- here takes writes, the text stays in memory and the next flush retries.
			local actual = System.currentDirectory()
			local dirs = {actual .."/".. LOG_DIR, actual}
			for i = 1, #dirs do
				if System.listDirectory(dirs[i]) == nil then
					pcall(System.createDirectory, dirs[i])
				end
				local cand = dirs[i] .."/".. LOG_FILE
				local ok = pcall(function()
					local f = System.openFile(cand, FCREATE)
					System.writeFile(f, texto, string.len(texto))
					System.closeFile(f)
				end)
				if ok == true and doesFileExist(cand) then
					BOOT_LOG_DESTINO = cand
					log_rotate(dirs[i])
					if i > 1 then
						BOOT_LOG_TXT = BOOT_LOG_TXT .."LOG    ".. actual .."/".. LOG_DIR
							.." refused writes; journal kept beside the ELF instead\n"
					end
					break
				end
			end
			if BOOT_LOG_DESTINO == nil then return end
			-- The journals of earlier designs, now just clutter.
			local viejos = {"Prism.log", "BOOT_LOG.txt", "LAUNCH_LOG.txt",
			                "MEDIA_LOG.txt", "BDM_REPORT.txt", "PREBOOT_LOG.txt"}
			for i = 1, #viejos do
				local v = actual .."/".. viejos[i]
				if doesFileExist(v) then pcall(System.removeFile, v) end
			end
			return
		end
		local f = System.openFile(BOOT_LOG_DESTINO, FCREATE)
		System.writeFile(f, texto, string.len(texto))
		System.closeFile(f)
	end)
end

function boot_log(linea)
	if BOOT_LOG_ON ~= true then return end
	BOOT_LOG_TXT = BOOT_LOG_TXT .. linea .. "\n"
	if BOOT_FLUSH == true then boot_flush() end
end

--- log_event(category, text): the one call new code should use. -----------------------
--- Same file, same line format, a timestamp in front so a freeze can be timed against
--- the last thing that happened. Categories seen so far: PRE BOOT CARGA CONF SAVES
--- LANZA ART LLAVE SONIDO, and from here on MENU (a screen opened or closed), SET (a
--- setting changed, with old and new value), VMC (a card chosen or created), FILE
--- (something copied, moved, deleted).
function log_event(categoria, texto)
	local hora = ""
	pcall(function() hora = os.date("%H:%M:%S ") end)
	boot_log(hora .. string.format("%-6s ", tostring(categoria)) .. tostring(texto))
end

--- Historic aliases: some code still calls irx_log / irx_escribir. --------------------
irx_log = boot_log
irx_escribir = boot_flush

--- Inventory of what the launcher sees in each root. Added to the journal. -----
--- Set INVENTARIO_ON to false once it is no longer needed.
INVENTARIO_ON = false

function inventario()
	if INVENTARIO_ON ~= true then return end
	local sistemas = {"Sega Megadrive", "Sega Master System", "Sega Game Gear", "Nintendo Famicom",
		"Nintendo Game Boy", "Nintendo Game Boy Color", "Nintendo Game Boy Advance", "Atari 2600",
		"Atari Lynx", "Sega SG-1000", "Neo Geo Pocket", "Nintendo Super Famicom"}

	local function listar(etiqueta, ruta)
		local c = System.listDirectory(ruta)
		if c == nil then
			irx_log("    ".. etiqueta .."  ->  MISSING   (".. ruta ..")")
			return
		end
		local ficheros = 0
		for i = 1, #c do
			if c[i].directory == false then ficheros = ficheros + 1 end
		end
		local t = "    ".. etiqueta .."  ->  ".. ficheros .." file(s)   (".. ruta ..")"
		local n = 0
		for i = 1, #c do
			if c[i].directory == false and string.sub(c[i].name, 1, 1) ~= "." then
				n = n + 1
				if n <= 25 then t = t .."\n         ".. c[i].name end
			end
		end
		if n > 25 then t = t .."\n         ... and ".. (n-25) .." more" end
		irx_log(t)
	end

	irx_log("")
	irx_log("=====================================================================")
	irx_log("INVENTARIO: what Prism finds in each root")
	irx_log("=====================================================================")

	for i = 1, #RAICES do
		local r = RAICES[i]
		local etiqueta_raiz = "USB / boot medium"
		if ES_RAIZ_ATA(r) then etiqueta_raiz = "INTERNAL exFAT DISC (ATA)" end
		irx_log("")
		irx_log("ROOT ".. i ..": ".. r .."   [".. etiqueta_raiz .."]")
		for s = 1, #sistemas do
			listar(sistemas[s], r .."/Roms/Roms ".. sistemas[s])
		end
		listar("PS1 (CUEs + ember)", r .."/Roms/CUEs PlayStation 1")
		listar("PS2 (ISOs)",         r .."/Roms/ISOs PlayStation 2")
		listar("APPS",               r .."/Roms/APPS")
	end

	-- Drive-level directories (outside the launcher folder). -------------------------
	local unidades = {}
	local pos = string.find(System.currentDirectory(), ":", 1, true)
	if pos ~= nil then table.insert(unidades, string.sub(System.currentDirectory(), 1, pos)) end
	for i = 1, #BDM_DEVICES do table.insert(unidades, BDM_DEVICES[i]) end

	for i = 1, #unidades do
		local u = unidades[i]
		local etiqueta_u = "USB"
		if BDM_ATA[u] == true then etiqueta_u = "INTERNAL exFAT DISC (ATA)" end
		irx_log("")
		irx_log("DRIVE ".. u .."   [".. etiqueta_u .."]")
		listar("DVD",  u .."/DVD")
		listar("CD",   u .."/CD")
		listar("POPS", u .."/POPS")
		listar("APPS", u .."/APPS")
	end
	irx_log("")
	irx_log("End of inventory.")
	irx_escribir()
end

--- Launch journal. Written into Prism.log just before every loadELF, so that a
--- black screen leaves a usable trace for the next start-up.
--- Set LAUNCH_LOG_ON to false to disable.
LAUNCH_LOG_ON = true

--- IOP reset before launching a RetroArch core. --------------------------------------
--- 0 = do not reset.   1 = reset before handing over the ELF.
---
--- It sat at 0 for a long time, on this reasoning: RetroArch resets the IOP itself
--- as soon as it starts ("reset_IOP()" in frontend_ps2_init), so doing it twice added
--- nothing. That was true... as long as the IOP carried nothing special.
---
--- Now it does carry something: the pre-boot ("System/index.lua") loads dev9_ns and
--- ata_bd so the launcher can see the internal disc. Handing the core over without a
--- reset, RetroArch meets an ata_bd already resident and an ATA bus already taken, and
--- loads its own on top. Symptom: black screen, and not one line in RetroArch's log -
--- it dies before it can write.
---
--- The evidence that points to it: the SAME core, with the SAME game on the internal
--- disc, starts perfectly when launched by hand from uLaunchELF, which does reset the
--- IOP. It only fails by way of the launcher.
---
--- TESTED ON CONSOLE, AND NO: with 1 the screen stays black and the console returns
--- to the system menu. That return to the menu is the signature of an ELF that dies or
--- never gets loaded, not of a hang. Enceladus does NOT read the ELF before resetting
--- the IOP: it is left with no drivers to read it. Back to 0.
--- (With 0 the symptom is different: a black screen that stays, with no return to the
--- menu. They are two different faults, and only the second is still open.)
IOP_REBOOT_CORES = 0

--- Maximum size of the history. Past that it is trimmed from the START, never from the
--- end: what matters is always the most recent. At ~700 bytes per entry this holds
--- One launch entry, in the single journal. ------------------------------------------
--- It had its own file, LAUNCH_LOG.txt, with its own history and its own session
--- stamp. The journal core does both of those already, so all that is left here is to
--- format the block and send it through boot_log with the category in front.
LAUNCH_LOG_ON = true

function log_lanzamiento(titulo, campos)
	if LAUNCH_LOG_ON ~= true then return end
	boot_log("")
	boot_log("LANZA  ------------------------------------------------------")
	boot_log("LANZA  ".. tostring(titulo))
	for i = 1, #campos do
		boot_log("LANZA    ".. tostring(campos[i]))
	end
	if MEDIA_DIAG ~= nil and #MEDIA_DIAG >= 1 then
		boot_log("LANZA    cover art, paths tried in order:")
		for i = 1, #MEDIA_DIAG do boot_log("LANZA      ".. tostring(MEDIA_DIAG[i])) end
	end
	-- This comes out just before a loadELF, which never returns. If it is the last
	-- entry in the file, the fault is in the ELF it names.
	boot_flush()
end

--- Checks that a file exists and describes it for the journal. -----------------------
function log_existe(etiqueta, ruta)
	local marca = "MISSING"
	if ruta ~= nil and doesFileExist(ruta) then marca = "ok" end
	return etiqueta .." [".. marca .."] : ".. tostring(ruta)
end

--- What is on the key, at boot. -------------------------------------------------------
--- When a core comes up to a black screen the first question is always "what actually
--- reached the key", and until now that meant powering off, pulling it and looking on
--- the PC. Here it is written down. Four listings of small folders: the launcher root
--- on the key, the cores present, the cached ROM and the saves.
function usb_inventory()
	local destinos = ROM_DESTINOS()
	for d = 1, #destinos do
		local dev = destinos[d]
		if string.lower(string.sub(dev, 1, 4)) == "mass" then
			local raiz = dev .."/".. CARPETA_LANZADOR
			local top = System.listDirectory(raiz)
			if top ~= nil then
				boot_log("")
				boot_log("LLAVE  ".. raiz)
				for i = 1, #top do
					local n = top[i].name
					if n ~= "." and n ~= ".." then
						if top[i].directory == true then boot_log("       d ".. n)
						else boot_log("         ".. n) end
					end
				end
				-- The cores present: this is what decides whether a game will start
				-- without copying anything, and the first thing missing when it fails.
				local cores = System.listDirectory(raiz .."/LibretroPS2Files/cores")
				if cores == nil then
					boot_log("       LibretroPS2Files/cores : MISSING")
				else
					local n = 0
					for i = 1, #cores do
						if cores[i].directory == false then
							n = n + 1
							boot_log("       core : ".. cores[i].name)
						end
					end
					if n == 0 then boot_log("       LibretroPS2Files/cores : empty") end
				end
				local cfg = raiz .."/LibretroPS2Files/retroarch/retroarch.cfg"
				boot_log("       retroarch.cfg : ".. tostring(doesFileExist(cfg)))
				-- RetroArch's working folders. It does not create them: if they are
				-- missing, it opens files inside nothing. "temp" is "cache_directory",
				-- where a .zip is unpacked -- without it a compressed ROM will not start.
				local criticas = {"temp", "logs", "system", "savefiles", "savestates"}
				local ausentes = ""
				for i = 1, #criticas do
					if System.listDirectory(raiz .."/LibretroPS2Files/retroarch/".. criticas[i]) == nil then
						ausentes = ausentes .." ".. criticas[i]
					end
				end
				if ausentes == "" then
					boot_log("       retroarch/ working folders : all present")
				else
					boot_log("       retroarch/ MISSING :".. ausentes)
				end
				-- The cached ROM and the saves waiting for the return trip.
				local roms = System.listDirectory(raiz .."/Roms")
				if roms ~= nil then
					for i = 1, #roms do
						local c = roms[i].name
						if roms[i].directory == true and c ~= "." and c ~= ".." then
							local dentro = System.listDirectory(raiz .."/Roms/".. c)
							if dentro ~= nil then
								for j = 1, #dentro do
									if dentro[j].directory == false then
										boot_log("       rom  : ".. c .."/".. dentro[j].name)
									end
								end
							end
						end
					end
				end
			end
		end
	end
	boot_flush()
end
