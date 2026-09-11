-- Prism PS2 Launcher - emu/retroarch_shuttle.lua
-- RetroArch on the USB shuttle: core and ROM copy, saves bridge.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- ROM shuttle for the RetroArch cores. ----------------------------------------------
--- The cores mount THEIR OWN device stack at start, and ata_bd is not part of it:
--- "platform_ps2.c" only brings up memcard, usb, mx4sio, cdfs and the native HDD (APA).
--- Upshot: a ROM living on the internal exFAT disc is SIMPLY INVISIBLE to them.
--- This is not a launcher bug nor a path problem, it is the reach of the RetroArch port.
--- Fix: copy the ROM onto a medium they do read, in order of preference
--- USB (fast) and then Memory Card (slow and small, but enough for 8/16 bit).
--- The copy is cached: relaunching the same game does not copy it again.
--- Set to false to turn the shuttle off.
ROM_SHUTTLE_ON = true
--- Staging folder on the shuttle medium. Same shape as on the disc:
---   <medium>/Prism/Roms/<system>/<rom>
---   <medium>/Prism/Saves/<system>/<game>.srm
---   <medium>/Prism/SaveStates/<system>/<game>.state
---   <medium>/Prism/Bios/
---   <medium>/Prism/LibretroPS2Files/
---
--- That is: EXACTLY the same structure as on the internal disc. There used to be a
--- "TempUSB/" folder in the middle, a patch for a problem that no longer exists --
--- RUTA_LIBRETRO used to pick the working copy as the master install, and hiding it
--- under another name avoided that. The master is now recognised by sitting next to
--- the launcher (libretro_master_path), so the copy can go back where it belongs and
--- both halves of the mount are read the same way.
-- From the REAL name of the launcher folder, not from the literal "Prism": if
-- somebody renames it, the shuttle and the install copied alongside it have to keep
-- landing in the same place. CARPETA_LANZADOR is worked out at startup.
ROM_SHUTTLE_SUB = "/".. CARPETA_LANZADOR

function ROM_TAMANO(ruta)
	local tam = nil
	pcall(function()
		local f = System.openFile(ruta, FREAD)
		tam = System.sizeFile(f)
		System.closeFile(f)
	end)
	return tam
end

--- Media the cores can read, fastest first. ------------------------------------------
function ROM_DESTINOS()
	local out = {}
	local propio = ""
	local pos = string.find(System.currentDirectory(), ":", 1, true)
	if pos ~= nil then propio = string.sub(System.currentDirectory(), 1, pos) end
	-- The boot medium, unless it is the ATA disc (that is: only if it is a USB stick).
	if propio ~= "" and BDM_ATA[propio] ~= true then table.insert(out, propio) end
	if BDM_DEVICES ~= nil then
		for i = 1, #BDM_DEVICES do
			if BDM_ATA[BDM_DEVICES[i]] ~= true and BDM_DEVICES[i] ~= propio then
				table.insert(out, BDM_DEVICES[i])
			end
		end
	end
	table.insert(out, "mc0:")
	table.insert(out, "mc1:")
	return out
end

--- Copies the ROM to a readable medium. Returns (new_path, description).
--- The Memory Card holds 8 MB: a GBA ROM will not fit, and that has to be said plainly.
--- The position in the list, stored separately. ---------------------------------------
--- "System/Config/System.cfg" is a single line of forty-nine numbers read back by
--- position, and one of the slots holds a PATH. The reader pulls the numbers out with
--- "%d+": if that path gains or loses a digit, EVERYTHING after it is read one
--- place along. A yes/no switch has no business depending on that, so it
--- lives in its own one-character file.
function see_index_path()
	return System.currentDirectory() .."/System/Config/SeeIndex.cfg"
end

function see_index_load()
	local f = see_index_path()
	if doesFileExist(f) == false then return nil end
	local v = nil
	pcall(function()
		local h = System.openFile(f, FREAD)
		System.seekFile(h, 0, SET)
		local t = System.readFile(h, System.sizeFile(h))
		System.closeFile(h)
		if t ~= nil and string.find(t, "1", 1, true) ~= nil then v = 1 else v = 0 end
	end)
	return v
end

function see_index_save(valor)
	pcall(function()
		local t = tostring(valor)
		local h = System.openFile(see_index_path(), FCREATE)
		System.writeFile(h, t, string.len(t))
		System.closeFile(h)
	end)
end

--- Which ROMs are ALREADY on the stick. -----------------------------------------------
--- So the list can paint them green: green = nothing to copy, it boots straight away.
--- One listDirectory call per system, and only when the system changes.
--- The folder holds one ROM at a time, so the index has a single entry.
CACHE_USB_IDX = nil
CACHE_USB_ID = nil

function usb_cache_refresh(identidad)
	CACHE_USB_ID = identidad
	CACHE_USB_IDX = {}
	-- With no bridge there is no copy to skip: nothing is cached, everything boots alike.
	if PUENTE_HACE_FALTA() == false then return end
	local consola = ROMS_DIR[identidad]
	if consola == nil then return end
	local destinos = ROM_DESTINOS()
	for i = 1, #destinos do
		local c = System.listDirectory(destinos[i] .. ROM_SHUTTLE_SUB .."/Roms/".. consola)
		if c ~= nil then
			for j = 1, #c do
				if c[j].directory == false then CACHE_USB_IDX[c[j].name] = true end
			end
		end
	end
end

--- Which cores are ALREADY on the stick. Same idea as usb_cached, and a single
--- listing: the folder holds a handful of cores at most.
CORES_LLAVE_IDX = nil

function core_on_usb(nombre_core)
	if nombre_core == nil then return false end
	if CORES_LLAVE_IDX == nil then
		CORES_LLAVE_IDX = {}
		local destinos = ROM_DESTINOS()
		for i = 1, #destinos do
			if string.lower(string.sub(destinos[i], 1, 4)) == "mass" then
				local dir = destinos[i] .."/".. CARPETA_LANZADOR .."/LibretroPS2Files/cores"
				local c = System.listDirectory(dir)
				if c ~= nil then
					for j = 1, #c do
						if c[j].directory == false then CORES_LLAVE_IDX[c[j].name] = true end
					end
				end
			end
		end
	end
	return CORES_LLAVE_IDX[nombre_core] == true
end

function usb_cached(identidad, nombre)
	if nombre == nil or identidad == nil or identidad > 12 then return false end
	if CACHE_USB_ID ~= identidad then usb_cache_refresh(identidad) end
	if CACHE_USB_IDX == nil then return false end
	-- The scan appends a trailing space for three-letter extensions.
	local limpio = nombre
	while string.sub(limpio, -1) == " " do limpio = string.sub(limpio, 1, -2) end
	return CACHE_USB_IDX[limpio] == true
end

--- Chunked copy, with progress. -------------------------------------------------------
--- "System.copyFile" says nothing while it works, and over USB 1.1 -- 1 MB/s at best
--- -- a Game Boy Advance ROM means fifteen seconds of a frozen screen, which nobody
--- can tell apart from a crash. Here the copy runs in chunks, with a notice between
--- chunks. The chunk is deliberately large: on USB 1.1 the cost is the latency of each
--- transfer, not the bytes.
COPIA_TROZO = 262144

function copy_with_progress(origen, destino, etiqueta)
	local tam = ROM_TAMANO(origen)
	if tam == nil then return false end
	-- Below one chunk there is no progress worth showing: copy it straight.
	if tam <= COPIA_TROZO then
		local ok = pcall(System.copyFile, origen, destino)
		return ok == true and doesFileExist(destino)
	end
	local hechos = 0
	pcall(function()
		local fo = System.openFile(origen, FREAD)
		local fd = System.openFile(destino, FCREATE)
		System.seekFile(fo, 0, SET)
		while hechos < tam do
			local n = COPIA_TROZO
			if tam - hechos < n then n = tam - hechos end
			local datos = System.readFile(fo, n)
			if datos == nil then break end
			local largo = string.len(datos)
			if largo <= 0 then break end
			System.writeFile(fd, datos, largo)
			hechos = hechos + largo
			if copy_progress ~= nil then
				pcall(copy_progress, etiqueta, hechos, tam)
			end
		end
		System.closeFile(fd)
		System.closeFile(fo)
	end)
	return hechos >= tam
end

function ROM_TRANSBORDO(ruta_rom, nombre)
	if ROM_SHUTTLE_ON ~= true then return nil, "transbordo desactivado" end
	local tam = ROM_TAMANO(ruta_rom)
	if tam == nil then return nil, "ROM ilegible en el origen" end
	-- Name of the folder holding the ROM: "Roms/megadrive/game.gen" -> "megadrive".
	-- The copy keeps it because RetroArch groups saves under that name
	-- ("sort_savefiles_by_content_enable"). Without it, a shuttled game would save
	-- into "Saves/Prism-TMP" instead of "Saves/megadrive", and its saves
	-- would end up apart from those of the same game launched from a USB stick.
	local consola = CARPETA_DE_RUTA(ruta_rom)

	local destinos = ROM_DESTINOS()
	for i = 1, #destinos do
		-- Under "Roms/", same as on the disc. They used to sit loose in the root of
		-- the staging folder, mixed in with Saves and SaveStates.
		local raiz_tmp = destinos[i] .. ROM_SHUTTLE_SUB .."/Roms"
		local sufijo = string.sub(ROM_SHUTTLE_SUB, 2) .."/Roms"
		if consola ~= nil then sufijo = sufijo .."/".. consola end
		pcall(CREAR_CADENA, destinos[i], sufijo)
		local dir = raiz_tmp
		if consola ~= nil then dir = raiz_tmp .."/".. consola end
		local contenido = System.listDirectory(dir)
		if contenido ~= nil then
			local dest = dir .."/".. nombre
			-- Cache: if it is already there at the right size, do not copy again.
			if doesFileExist(dest) and ROM_TAMANO(dest) == tam then
				return dest, destinos[i] .." (ya en cache)"
			end
			-- Only ONE ROM is kept: the previous one goes, so the medium never fills.
			-- ALL the system folders must be swept, not just the current one, or
			-- changing system would pile up the earlier ROMs. "raiz_tmp" is now
			-- "Roms/", so there are only ROMs in here: nothing to exclude.
			local previo = System.listDirectory(raiz_tmp)
			if previo ~= nil then
				for c = 1, #previo do
					local nom = previo[c].name
					if nom ~= "." and nom ~= ".." then
						if previo[c].directory == false then
							pcall(System.removeFile, raiz_tmp .."/".. nom)
						else
							local dentro = System.listDirectory(raiz_tmp .."/".. nom)
							if dentro ~= nil then
								for d = 1, #dentro do
									if dentro[d].directory == false then
										pcall(System.removeFile, raiz_tmp .."/".. nom .."/".. dentro[d].name)
									end
								end
							end
						end
					end
				end
			end
			copy_with_progress(ruta_rom, dest, "ROM")
			if doesFileExist(dest) and ROM_TAMANO(dest) == tam then
				return dest, destinos[i] .." (copiada, ".. tostring(tam) .." bytes)"
			end
			pcall(System.removeFile, dest)
		end
	end
	return nil, "ningun soporte legible con espacio (ROM de ".. tostring(tam) .." bytes)"
end

--- Save bridge between the internal disc and the shuttle medium. ---------------------
--- An official core cannot read the internal disc, so the ROM is copied out to the
--- USB stick. Its saves are then written to the stick TOO, and would be left
--- stranded there. The bridge makes the return trip:
---
---   before launching  THIS game's save leaves the disc for the stick
---   the core plays    it writes to the stick, unaware there is a disc
---   on the way back   the launcher collects what was written and returns it to disc
---
--- So the disc stays the home of the saves and the stick is only a corridor.
--- Without the outward leg, a game would start blank and overwrite what was saved.
--- All of this only kicks in when the launcher lives on the internal disc: on a stick
--- or on a card, the saves are already where the core writes them.
SAVES_PUENTE_ON = true
SAVES_CARPETAS = {"Saves", "SaveStates"}

--- Creates a full path, one component at a time. ------------------------------------
--- "System.createDirectory" does not create the parents, and the staging folder now
--- has two levels ("Prism/Roms") plus the system below that.
function CREAR_CADENA(base, resto)
	if base == nil or resto == nil then return false end
	local ruta = base
	local desde = 1
	while true do
		local corte = string.find(resto, "/", desde, true)
		local trozo = nil
		if corte == nil then trozo = string.sub(resto, desde)
		else trozo = string.sub(resto, desde, corte-1) end
		if trozo ~= nil and trozo ~= "" then
			ruta = ruta .."/".. trozo
			if System.listDirectory(ruta) == nil then
				System.createDirectory(ruta)
				if System.listDirectory(ruta) == nil then return false end
			end
		end
		if corte == nil then break end
		desde = corte + 1
	end
	return true
end

--- Name of the folder holding a file: ".../Roms/gb/Tetris.zip" -> "gb". --------------
function CARPETA_DE_RUTA(ruta)
	if ruta == nil then return nil end
	local fin = string.len(ruta)
	while fin > 0 and string.sub(ruta, fin, fin) ~= "/" do fin = fin - 1 end
	if fin <= 1 then return nil end
	local ini = fin - 1
	while ini > 0 and string.sub(ruta, ini, ini) ~= "/" do ini = ini - 1 end
	local n = string.sub(ruta, ini+1, fin-1)
	if n == "" or string.find(n, ":", 1, true) ~= nil then return nil end
	return n
end

--- A file name without its extension: "Tetris (World).zip" -> "Tetris (World)". ------
function SIN_EXTENSION(nombre)
	if nombre == nil then return nil end
	local punto = string.len(nombre)
	while punto > 0 and string.sub(nombre, punto, punto) ~= "." do punto = punto - 1 end
	if punto > 1 then return string.sub(nombre, 1, punto-1) end
	return nombre
end

--- Device prefix of a path: "mass0:/x/y" -> "mass0:". --------------------------------
function DEV_DE_RUTA(ruta)
	if ruta == nil then return nil end
	local pos = string.find(ruta, ":", 1, true)
	if pos == nil then return nil end
	return string.sub(ruta, 1, pos)
end

--- Copies a file tree, creating any missing directories. ------------------------------
--- "System.createDirectory" does not create the parents, hence the ordered recursion.
--- The depth limit keeps an odd link from hanging the console.
function COPIAR_ARBOL(origen, destino, nivel)
	if nivel == nil then nivel = 0 end
	if nivel > 4 then return end
	local lista = System.listDirectory(origen)
	if lista == nil then return end
	if System.listDirectory(destino) == nil then
		System.createDirectory(destino)
	end
	for i = 1, #lista do
		local nom = lista[i].name
		if nom ~= "." and nom ~= ".." then
			if lista[i].directory == true then
				COPIAR_ARBOL(origen .."/".. nom, destino .."/".. nom, nivel + 1)
			else
				System.copyFile(origen .."/".. nom, destino .."/".. nom)
			end
		end
	end
end
--- Empties a file tree. The reverse of COPIAR_ARBOL. ---------------------------------
--- The folders stay behind, empty: Enceladus exposes "System.removeFile" but not the
--- directory equivalent. That is no trouble -- an empty folder is harmless, and
--- "directorios_faltantes" relies on them being there in the first place.
function BORRAR_ARBOL(ruta, nivel)
	if nivel == nil then nivel = 0 end
	if nivel > 4 then return end
	local lista = System.listDirectory(ruta)
	if lista == nil then return end
	for i = 1, #lista do
		local nom = lista[i].name
		if nom ~= "." and nom ~= ".." then
			if lista[i].directory == true then
				BORRAR_ARBOL(ruta .."/".. nom, nivel + 1)
			else
				pcall(System.removeFile, ruta .."/".. nom)
			end
		end
	end
end

--- Copies the files of one directory into another. Returns how many. -----------------
function COPIAR_PLANO(origen, destino, borrar)
	local lista = System.listDirectory(origen)
	if lista == nil then return 0 end
	if System.listDirectory(destino) == nil then System.createDirectory(destino) end
	if System.listDirectory(destino) == nil then return 0 end
	local n = 0
	for i = 1, #lista do
		if lista[i].directory == false then
			local ok = pcall(System.copyFile, origen .."/".. lista[i].name, destino .."/".. lista[i].name)
			if ok == true and doesFileExist(destino .."/".. lista[i].name) then
				n = n + 1
				if borrar == true then pcall(System.removeFile, origen .."/".. lista[i].name) end
			end
		end
	end
	return n
end

--- Does the launcher live on the internal disc? Only then is the bridge needed. -------
function PUENTE_HACE_FALTA()
	if SAVES_PUENTE_ON ~= true then return false end
	return ES_RAIZ_ATA(System.currentDirectory() .."/Saves")
end

--- OUTWARD: moves a game's saves off the disc onto the shuttle medium. ---------------
--- "consola" is the ROM folder ("gb", "nes"...), "base" the game name without its
--- extension. RetroArch names the save after the ROM: "Tetris.zip" -> "Tetris.srm",
--- and save states add a suffix ("Tetris.state", "Tetris.state1"...). That is why
--- everything STARTING with the game name is copied, not just one extension.
function SAVES_DESPLEGAR(dev, consola, base)
	if PUENTE_HACE_FALTA() == false or dev == nil or base == nil then return 0 end
	local actual = System.currentDirectory()
	local n = 0
	for c = 1, #SAVES_CARPETAS do
		local origen = actual .."/".. SAVES_CARPETAS[c]
		local destino = dev .. ROM_SHUTTLE_SUB .."/".. SAVES_CARPETAS[c]
		if consola ~= nil then
			origen = origen .."/".. consola
			destino = destino .."/".. consola
		end
		local lista = System.listDirectory(origen)
		if lista ~= nil then
			local sufijo = string.sub(ROM_SHUTTLE_SUB, 2) .."/".. SAVES_CARPETAS[c]
			if consola ~= nil then sufijo = sufijo .."/".. consola end
			CREAR_CADENA(dev, sufijo)
			for i = 1, #lista do
				local nom = lista[i].name
				if lista[i].directory == false and string.sub(nom, 1, string.len(base)) == base then
					local ok = pcall(System.copyFile, origen .."/".. nom, destino .."/".. nom)
					if ok == true then n = n + 1 end
				end
			end
		end
	end
	return n
end

--- Loose files: their system is worked out before they are brought back. --------------
--- "Zelda.state1" does not say which system it is from, but "Roms/<system>/Zelda.*"
--- does. ROMS_DIR is walked for a ROM whose name without extension matches; if one
--- turns up, the save goes to "<folder>/<system>/", which is where it would have
--- landed with sort-by-content on. If none turns up, it stays in the root as before.
function saves_relocate(origen, casa)
	local lista = System.listDirectory(origen)
	if lista == nil then return 0 end
	local actual = System.currentDirectory()
	local n = 0
	for i = 1, #lista do
		if lista[i].directory == false then
			local nom = lista[i].name
			local base = SIN_EXTENSION(nom)
			local consola = nil
			-- States append a suffix to the full ROM name:
			-- "Zelda.zip" -> "Zelda.state1", so TWO extensions have to come off.
			local base2 = SIN_EXTENSION(base)
			for c = 1, #ROMS_DIR do
				if consola == nil then
					local dir = actual .."/Roms/".. ROMS_DIR[c]
					local roms = System.listDirectory(dir)
					if roms ~= nil then
						for r = 1, #roms do
							if roms[r].directory == false then
								local rb = SIN_EXTENSION(roms[r].name)
								if rb == base or rb == base2 then consola = ROMS_DIR[c] end
							end
						end
					end
				end
			end
			local destino = casa
			if consola ~= nil then
				destino = casa .."/".. consola
				if System.listDirectory(destino) == nil then
					System.createDirectory(destino)
				end
			end
			local ok = pcall(System.copyFile, origen .."/".. nom, destino .."/".. nom)
			if ok == true and doesFileExist(destino .."/".. nom) then
				n = n + 1
				pcall(System.removeFile, origen .."/".. nom)
				if consola ~= nil then
					boot_log("SAVES  ".. nom .." -> ".. consola .."/ (was loose)")
				end
			end
		end
	end
	return n
end

--- RETURN: gathers what the cores wrote on the media and puts it back on the disc.
--- Called as the launcher starts, which is exactly when you come back from a game.
--- The copy on the medium ALWAYS wins: the core has just written it, and the PS2 Lua
--- API does not expose a file's date, so there is no other way to decide.
function SAVES_RECUPERAR()
	if PUENTE_HACE_FALTA() == false then return 0 end
	local actual = System.currentDirectory()
	local destinos = ROM_DESTINOS()
	local total = 0
	for d = 1, #destinos do
		for c = 1, #SAVES_CARPETAS do
			local raiz = destinos[d] .. ROM_SHUTTLE_SUB .."/".. SAVES_CARPETAS[c]
			if System.listDirectory(raiz) ~= nil then
				local casa = actual .."/".. SAVES_CARPETAS[c]
				if System.listDirectory(casa) == nil then System.createDirectory(casa) end
				-- Loose in the root. Happens when a core override turns off
				-- sorting by content folder -- that is what hit Zelda
				-- DX, whose ".srm" landed in "Saves/gbc/" and whose states landed in
				-- the root of "SaveStates/". Rather than bring them back loose, the
				-- system each one belongs to is found by looking for the ROM in
				-- "Roms/", and they are stored where they should have been.
				total = total + saves_relocate(raiz, casa)
				-- And one folder per system.
				local subs = System.listDirectory(raiz)
				if subs ~= nil then
					for i = 1, #subs do
						local nom = subs[i].name
						if subs[i].directory == true and nom ~= "." and nom ~= ".." then
							total = total + COPIAR_PLANO(raiz .."/".. nom, casa .."/".. nom, true)
						end
					end
				end
			end
		end
	end
	if total > 0 then
		boot_log("SAVES  ".. tostring(total) .." save(s) returned to the internal disc")
		boot_flush()
	end
	return total
end
