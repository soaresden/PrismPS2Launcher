-- Prism PS2 Launcher - emu/ps2.lua
-- PlayStation 2: per-game launcher choice, virtual memory cards.
-- Split from the original system.lua (RETROLauncher, Spaghetticode / Boon Tobias).
-- Definitions only, except where noted; loaded by System/system.lua in boot order.

--- VMC (virtual memory card) per game for PS2 / Neutrino. ----------------------------
--- A single shared card -and worse, a 64 MB one- is exactly what corrupts saved
--- games: many games reject or damage cards larger than 8 MB, and one single card
--- lets a game trample another game's data. The cure is an 8 MB card PER GAME, which
--- is also what Neutrino expects (-mc0=<fichero>).
--- The launcher cannot format a PS2 card from Lua (ECC/FAT layout), so it carries an
--- empty pre-formatted mould, "Bios/vmc-template.bin" (8 MB raw), and COPIES it to
--- "VMC/<ID>.bin" the first time the game is launched. Neutrino fills it in later.
--- Set to false to return to the classic behaviour (a manual or real card).
VMC_AUTO_ON = true

--- What each PS2 ISO is launched with: Neutrino or OPL. ------------------------------
--- Stored per game in "System/Config/Launcher.cfg", one line "<fichero>=opl".
--- Only what departs from the norm is recorded: no line means Neutrino.
---
--- The choice already existed, but you had to HOLD CROSS+CIRCLE while launching, or
--- set RUN_DEFAULT to 1 so that it asked on every game. Neither of the two is
--- discoverable on its own, and a button combination is not a setting.
LAUNCHER_GAMES = {}
launcher_cfg_loaded = false

function launcher_cfg_path()
	return System.currentDirectory() .."/System/Config/Launcher.cfg"
end

function launcher_cfg_load()
	if launcher_cfg_loaded == true then return end
	launcher_cfg_loaded = true
	local f = launcher_cfg_path()
	if doesFileExist(f) == false then return end
	pcall(function()
		local h = System.openFile(f, FREAD)
		System.seekFile(h, 0, SET)
		local t = System.readFile(h, System.sizeFile(h))
		System.closeFile(h)
		if t == nil then return end
		for linea in string.gmatch(t .."\n", "([^\n]*)\n") do
			local clave, valor = string.match(linea, "^([^=]+)=(.*)$")
			if clave ~= nil then
				valor = string.gsub(valor, "%s+$", "")
				if valor ~= "" then LAUNCHER_GAMES[clave] = valor end
			end
		end
	end)
end

function launcher_cfg_save()
	pcall(function()
		local t = ""
		for juego, valor in pairs(LAUNCHER_GAMES) do
			t = t .. juego .."=".. valor .."\n"
		end
		local h = System.openFile(launcher_cfg_path(), FCREATE)
		System.writeFile(h, t, string.len(t))
		System.closeFile(h)
	end)
end

--- True if THIS game must be launched with OPL instead of Neutrino. -------------------
function launcher_is_opl(nombre)
	if nombre == nil then return false end
	launcher_cfg_load()
	return LAUNCHER_GAMES[nombre] == "opl"
end

--- Virtual card: ONE setting, per game, with no ambiguity. ---------------------------
--- "System/Config/VMC.cfg" holds one line per game, "<ID>=<valor>", where the value
--- is one of these three things:
---
---   (absent)                automatic -- a card whose name starts with the ID is
---                           looked for in the VMC of EVERY mounted drive; if there
---                           is none, one is created on the drive holding the ISO.
---   none                    no "-mc0=" at all: Neutrino uses the REAL cards.
---   mass1:/VMC/xxx.bin      that card and no other.
---
--- On top of this there used to be a global "where to create the cards" setting, and a
--- second file picker duplicating Boon's. Three ways of deciding the same thing, none
--- of which said which file was actually going to be used. One is left.
VMC_GAMES = {}
vmc_cfg_loaded = false

function vmc_cfg_path()
	return System.currentDirectory() .."/System/Config/VMC.cfg"
end

function vmc_cfg_load()
	if vmc_cfg_loaded == true then return end
	vmc_cfg_loaded = true
	local f = vmc_cfg_path()
	if doesFileExist(f) == false then return end
	pcall(function()
		local h = System.openFile(f, FREAD)
		System.seekFile(h, 0, SET)
		local t = System.readFile(h, System.sizeFile(h))
		System.closeFile(h)
		if t == nil then return end
		for linea in string.gmatch(t .."\n", "([^\n]*)\n") do
			local clave, valor = string.match(linea, "^([^=]+)=(.*)$")
			if clave ~= nil then
				clave = string.gsub(clave, "%s+$", "")
				valor = string.gsub(valor, "%s+$", "")
				if valor ~= "" then VMC_GAMES[clave] = valor end
			end
		end
	end)
end

function vmc_cfg_save()
	pcall(function()
		local t = ""
		for id, valor in pairs(VMC_GAMES) do
			t = t .. id .."=".. valor .."\n"
		end
		local h = System.openFile(vmc_cfg_path(), FCREATE)
		System.writeFile(h, t, string.len(t))
		System.closeFile(h)
	end)
end

--- The drives where a VMC folder can live. --------------------------------------------
function vmc_drives()
	local out, vistos = {}, {}

	local function anadir(dev)
		if dev == nil or vistos[dev] == true then return end
		if string.lower(string.sub(dev, 1, 4)) ~= "mass" then return end
		vistos[dev] = true
		out[#out + 1] = dev
	end

	-- THE BOOT DEVICE FIRST, and that was the whole problem here.
	--
	-- "BDM_DEVICES" does not contain the drive the launcher runs from: it is filled
	-- with "if unidad ~= propio then table.insert(...)". Walking that alone left out
	-- precisely the disc the launcher lives on -- and where the cards live. Hence no
	-- VMC was ever found, and creating one on the internal disc was not even offered.
	-- The rest of the program already got it right: RUTA_ART adds the launcher's own
	-- drive before walking BDM_DEVICES.
	local actual = System.currentDirectory()
	local pos = string.find(actual, ":", 1, true)
	if pos ~= nil then anadir(string.sub(actual, 1, pos)) end

	if BDM_DEVICES ~= nil then
		for i = 1, #BDM_DEVICES do anadir(BDM_DEVICES[i]) end
	end
	return out
end

--- The ways one and the same ID may be written in a file name. -----------------------
--- "SLES-51191" is the convention of the cards, "SLES_511.91" that of the OPL ISOs,
--- and along the way both turn up with the other separator too. Comparing against one
--- single form is what left the list empty in front of a folder full of cards.
function vmc_id_variants(id)
	if id == nil then return {} end
	local reg, num = string.match(id, "^(%a%a%a%a)%-(%d%d%d%d%d)")
	if reg == nil then return {string.lower(id)} end
	local n3, n2 = string.sub(num, 1, 3), string.sub(num, 4, 5)
	return {string.lower(reg .."-".. num),        -- SLES-51191
	        string.lower(reg .."_".. num),        -- SLES_51191
	        string.lower(reg .."_".. n3 ..".".. n2),   -- SLES_511.91
	        string.lower(reg .."-".. n3 ..".".. n2),   -- SLES-511.91
	        string.lower(reg .. num)}             -- SLES51191
end

--- ALL the cards on ALL the drives. --------------------------------------------------
--- The ones that look like they belong to this game come first; the rest follow behind
--- instead of vanishing. An empty list in front of a full folder tells you nothing,
--- and besides, some people name their cards by hand, with no ID at all.
--- Returns two tables: paths, and whether each one belongs to the game.
function vmc_candidates(id)
	local propias, otras = {}, {}
	local variantes = vmc_id_variants(id)
	local unidades = vmc_drives()
	for i = 1, #unidades do
		local dir = unidades[i] .."/VMC"
		local c = System.listDirectory(dir)
		if c ~= nil then
			for j = 1, #c do
				local n = c[j].name
				if c[j].directory == false and string.lower(string.sub(n, -4)) == ".bin" then
					local nlow = string.lower(n)
					local mio = false
					-- The ID may sit ANYWHERE in the name, not only at the
					-- start. "SCES-50295 Dark Cloud Data (Europe).bin" begins with
					-- the ID, but "Dark Cloud SCES-50295.bin" does not, and it is the
					-- same save. Matching only the start left out half of the cards
					-- named by hand.
					for v = 1, #variantes do
						if string.find(nlow, variantes[v], 1, true) ~= nil then
							mio = true
						end
					end
					if mio then propias[#propias + 1] = dir .."/".. n
					else otras[#otras + 1] = dir .."/".. n end
				end
			end
		end
	end
	local todas = {}
	for i = 1, #propias do todas[#todas + 1] = propias[i] end
	for i = 1, #otras do todas[#todas + 1] = otras[i] end
	return todas, #propias
end

--- Creates an empty 8 MB card and returns its path, or nil. ---------------------------
--- "fichero" is the FULL name including its ".bin". It used to take the ID and glue
--- the extension on here, which made choosing the name from the menu impossible.
function vmc_create(dev, fichero)
	if dev == nil or fichero == nil then return nil end
	local dir = dev .."/VMC"
	if System.listDirectory(dir) == nil then pcall(System.createDirectory, dir) end
	if System.listDirectory(dir) == nil then return nil end
	local dest = dir .."/".. fichero
	if doesFileExist(dest) then return dest end
	local molde = RUTA_BIOS("vmc-template.bin", "")
	if doesFileExist(molde) == false then return nil end
	pcall(System.copyFile, molde, dest)
	if doesFileExist(dest) then return dest end
	return nil
end

--- Normalised game ID taken from the name of the ISO file. ----------------------------------------
--- "SCES_502.40.Extermination.iso" -> "SCES-50240", the convention of OPL and of the
--- save folders. nil if the name carries no recognisable ID.
function vmc_id(nombre)
	if nombre == nil then return nil end
	local reg, n1, n2 = string.match(nombre, "^(%a%a%a%a)_(%d%d%d)%.(%d%d)")
	if reg ~= nil then return reg .."-".. n1 .. n2 end
	-- variant with a hyphen or without the dot: "SLES-51044", "SLUS_20946"
	local reg2, num = string.match(nombre, "^(%a%a%a%a)[_%- ]?(%d%d%d%d%d)")
	if reg2 ~= nil then return reg2 .."-".. num end
	return nil
end

--- The ID exactly as OPL writes it: "SCES_502.95". ------------------------------------
--- It is the form the ISOs carry, and the one used to christen a new card, so that the
--- file name resembles that of the game sitting next to it.
function vmc_id_opl(nombre)
	local id = vmc_id(nombre)
	if id == nil then return nil end
	local reg, num = string.match(id, "^(%a%a%a%a)%-(%d%d%d%d%d)")
	if reg == nil then return id end
	return reg .."_".. string.sub(num, 1, 3) ..".".. string.sub(num, 4, 5)
end

--- The title that follows the ID in the ISO's name. -----------------------------------
--- "SCES_502.95.Dark Cloud.iso" -> "Dark Cloud". Returns "" if nothing is recognised,
--- and in that case the card keeps only the ID and the number.
function vmc_title(nombre)
	if nombre == nil then return "" end
	local t = nombre
	t = string.gsub(t, "%.[Ii][Ss][Oo]$", "")
	t = string.gsub(t, "^%a%a%a%a[_%- ]?%d%d%d%.?%d%d%.?", "")
	t = string.gsub(t, "^%s+", "")
	t = string.gsub(t, "%s+$", "")
	-- Strip out anything that is not safe in an exFAT file name.
	t = string.gsub(t, "[^%w%s%-_%(%)%[%]]", "")
	if string.len(t) > 40 then t = string.sub(t, 1, 40) end
	t = string.gsub(t, "%s+$", "")
	return t
end

--- Proposed name for a new card: "SCES_502.95_Dark Cloud-1.bin". ----------------------
--- The number at the end is moved by the user with up / down, so that several saves of
--- the same game can exist without one trampling the other.
function vmc_new_name(nombre, n)
	local idopl = vmc_id_opl(nombre)
	if idopl == nil then return nil end
	if n == nil or n < 1 then n = 1 end
	local titulo = vmc_title(nombre)
	if titulo == "" then return idopl .."-".. n ..".bin" end
	return idopl .."_".. titulo .."-".. n ..".bin"
end

--- Returns the "-mc0=<path>" argument for the game, creating the card if it is missing.
--- "unidad_iso" is the drive prefix where Neutrino will read the ISO, so as to put the
--- card on the SAME medium (with -bsd=ata all is "mass:"). nil if it does not apply.
function vmc_auto(nombre, unidad_iso)
	if VMC_AUTO_ON ~= true then return nil end
	vmc_cfg_load()
	local id = vmc_id(nombre)
	if id == nil then return nil end

	local elegido = VMC_GAMES[id]

	-- "none" means NO card at all, and it has to win over everything else.
	-- Here lay the nonsense: switching the card off in Boon's menu leaves the
	-- game without ".vmcd", that is without a manual choice, and this function read
	-- that as "nothing has been chosen, I shall create one". The game booted with a
	-- card the user had just removed.
	if elegido == "none" then return nil end

	-- A specific path, if it still exists.
	if elegido ~= nil and doesFileExist(elegido) then
		return "-mc0=".. elegido
	end

	-- Automatic: the first card that belongs TO THIS GAME.
	--
	-- vmc_candidates now returns every ".bin" in the folders, so that the menu
	-- list does not come up empty in front of a full folder. But nothing is chosen
	-- blindly here: the second value says how many of the leading ones carry the
	-- game's ID, and only those may be used unasked. Taking the first one
	-- in the folder would mean booting with another game's save.
	local cand, propias = vmc_candidates(id)
	if propias >= 1 then return "-mc0=".. cand[1] end

	-- No card and no choice: the game boots WITHOUT "-mc0=".
	--
	-- One used to be created right here, silently, the first time a game was
	-- launched. That is exactly what made the whole thing baffling: cards appeared
	-- that nobody had asked for, on a drive nobody had chosen. Creating one is now
	-- an explicit action in the game's menu, and nothing more.
	return nil
end
