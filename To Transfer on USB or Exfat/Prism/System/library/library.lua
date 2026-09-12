-- Prism PS2 Launcher - library/library.lua
-- Builds the game library from systems.lua and the drives: which systems have games,
-- which games, where each one is, and its title and artwork. This is the only module
-- that walks the disk for the interface; the views read LIBRARY.
--
-- LIBRARY.systems : array of { folder, name, games }, only systems with games, sorted
-- game            : { file, stem, title, path, dir, ata, kind, warn,
--                     vcd, ember, ember_dir }   (PS1 games can have both a .VCD and an
--                     Ember folder: one entry, two ways to run it)

LIBRARY = { systems = {}, by_folder = {}, titles = {}, built = false }

local function lower_ext(name)
	return string.lower(string.match(name or "", "%.[^%.]+$") or "")
end

local function stem_of(name)
	local s = string.match(name or "", "^(.*)%.[^%.]+$")
	if s == nil or s == "" then return name end
	return s
end

local function has_ext(list, ext)
	for i = 1, #list do if list[i] == ext then return true end end
	return false
end

--- titles.txt: "file|title" per line. Keyed by stem, so a .VCD and an Ember folder of
--- the same game share the title.
local function read_titles(folder, dir)
	local path = dir .."/Roms/".. folder .."/titles.txt"
	if doesFileExist(path) == false then return end
	pcall(function()
		local fd = System.openFile(path, FREAD)
		local size = System.sizeFile(fd)
		System.seekFile(fd, 0, SET)
		local data = System.readFile(fd, size)
		System.closeFile(fd)
		if data == nil then return end
		local map = LIBRARY.titles[folder]
		if map == nil then map = {}; LIBRARY.titles[folder] = map end
		for line in string.gmatch(data, "[^\r\n]+") do
			local cut = string.find(line, "|", 1, true)
			if cut ~= nil then
				local file = string.sub(line, 1, cut - 1)
				local title = string.sub(line, cut + 1)
				if file ~= "" and title ~= "" then
					map[string.lower(stem_of(file))] = title
				end
			end
		end
	end)
end

--- The name to SHOW, when nothing better is known. ------------------------------------
--- OPL names a disc image after its serial: "SLES_504.08.PaRappa the Rapper 2.iso".
--- The serial is how the console finds the file and it has to stay in the file name,
--- but it is not the game's name, and leaving it in the list sorts a whole library by
--- publisher code - every SCES together, every SLUS together, alphabetical by nothing
--- anyone can see. The file keeps its name; the list shows the game's.
function pretty_title(stem)
	local cut = string.match(stem, "^%a%a%a%a[_%-]%d%d%d%.%d%d%.(.+)$")
	if cut ~= nil and cut ~= "" then return cut end
	return stem
end

local function title_for(folder, name)
	local map = LIBRARY.titles[folder]
	local stem = stem_of(name)
	if map ~= nil and map[string.lower(stem)] ~= nil then return map[string.lower(stem)] end
	return pretty_title(stem)
end

local function is_ata(path)
	if ES_RAIZ_ATA ~= nil then
		local ok, r = pcall(ES_RAIZ_ATA, path)
		if ok then return r == true end
	end
	return false
end

--- A loose PlayStation 1 disc image: what you get when a rom folder is copied straight
--- off a PC. None of these run on the PS2 as they are - POPStarter wants a .VCD and
--- Ember wants its own folder - but they are still the game, so they are listed, in
--- red, with what to do about it. A game you cannot see is a game you cannot fix.
local PSX_DISC = {
	[".cue"] = true, [".bin"] = true, [".img"] = true,
	[".iso"] = true, [".chd"] = true, [".pbp"] = true,
}

--- Names that are never a game, whatever folder they turn up in. ----------------------
--- POPStarter's own files share their extensions with disc images - PATCH_5.BIN,
--- TROJAN_7.BIN, IOPRP252.IMG - and a copy of them beside the games is normal. The
--- prefix is what identifies them, so a game called "Patch Quest" is safe.
local PSX_SUPPORT = {
	"pops", "popstarter", "ioprp", "patch_", "trojan_", "igr_", "cheats",
	"usbd", "usbhdfsd", "bdm", "bdmfs", "iomanx", "filexio", "ps2dev9",
}

function psx_support_file(name)
	local low = string.lower(name)
	for i = 1, #PSX_SUPPORT do
		if string.sub(low, 1, string.len(PSX_SUPPORT[i])) == PSX_SUPPORT[i] then
			return true
		end
	end
	return false
end

--- PlayStation 1: POPS/ (.VCD), Ember/games (one folder per game), Roms/psx (loose). ----
local function scan_psx(sys, games, seen)
	for r = 1, #RAICES do
		local dirs = scan_roots("psx", RAICES[r])
		for d = 1, #dirs do
			local dir = dirs[d]
			local list = System.listDirectory(dir)
			if list ~= nil then
				local low = string.lower(dir)
				local is_ember = (string.find(low, "/ember/games", 1, true) ~= nil)
				-- POPS/ holds ONE kind of game, the .VCD, and a pile of support files
				-- that are not games at all: POPS.ELF, IOPRP252.IMG, PATCH_5.BIN,
				-- TROJAN_7.BIN, the IGR screens. Reading loose disc images there put
				-- every one of them in the list. Loose images are a Roms/psx idea.
				local is_pops = (string.find(low, "/pops", 1, true) ~= nil)
				-- A .cue names its .bin, so the .bin must not be listed as a game of its
				-- own: one disc, one line. Collected first, because the directory does
				-- not come back in any promised order.
				local cued = {}
				for i = 1, #list do
					local e = list[i]
					if e.directory == false and lower_ext(e.name) == ".cue" then
						cued[string.lower(stem_of(e.name))] = true
					end
				end
				for i = 1, #list do
					local e = list[i]
					local name = e.name
					if string.sub(name, 1, 1) ~= "." then
						local key = nil
						local entry = nil
						if is_ember and e.directory == true then
							key = "psx|".. string.lower(ps1_key and ps1_key(name) or name)
							entry = seen[key]
							if entry == nil then
								entry = { file = name, stem = name, title = title_for("psx", name),
									kind = "psx", dir = dir, ata = is_ata(dir) }
								seen[key] = entry
								games[#games + 1] = entry
							end
							entry.ember = name
							entry.ember_dir = dir .."/".. name
							local what = nil
							if ember_contents ~= nil then
								local ok, w = pcall(ember_contents, entry.ember_dir)
								if ok then what = w end
							end
							if what == "chd" then entry.ember_chd = true end
						elseif is_ember == false and e.directory == false and lower_ext(name) == ".vcd" then
							key = "psx|".. string.lower(ps1_key and ps1_key(name) or stem_of(name))
							entry = seen[key]
							if entry == nil then
								entry = { file = name, stem = stem_of(name), title = title_for("psx", name),
									kind = "psx", dir = dir, ata = is_ata(dir) }
								seen[key] = entry
								games[#games + 1] = entry
							end
							if entry.vcd ~= nil and entry.vcd ~= dir .."/".. name then
								-- The same game, as a .VCD, on a second drive. One of
								-- them is played and the other is not, and each has its
								-- own memory card beside it - so the copy that is not
								-- played collects saves nobody will ever see again.
								-- Recorded here and shown in the game menu: the launcher
								-- has to pick one, but it must not pick one quietly.
								entry.dupes = entry.dupes or {}
								entry.dupes[#entry.dupes + 1] = dir .."/".. name
							else
								entry.vcd = dir .."/".. name
								entry.file = name
								entry.stem = stem_of(name)
								entry.dir = dir
								entry.path = entry.vcd
								entry.ata = is_ata(dir)
							end
						elseif is_ember == false and is_pops == false
						       and e.directory == false
						       and PSX_DISC[lower_ext(name)] == true
						       and psx_support_file(name) == false then
							local ext = lower_ext(name)
							-- The .bin of a .cue is not a game; the .cue already is.
							if ext ~= ".bin" or cued[string.lower(stem_of(name))] ~= true then
								key = "psx|".. string.lower(ps1_key and ps1_key(name) or stem_of(name))
								entry = seen[key]
								if entry == nil then
									entry = { file = name, stem = stem_of(name), title = title_for("psx", name),
										kind = "psx", dir = dir, ata = is_ata(dir) }
									seen[key] = entry
									games[#games + 1] = entry
								end
								if entry.disc == nil then
									entry.disc = dir .."/".. name
									entry.disc_ext = ext
									if entry.path == nil then
										entry.file = name
										entry.stem = stem_of(name)
										entry.dir = dir
										entry.path = entry.disc
										entry.ata = is_ata(dir)
									end
								end
							end
						end
					end
				end
			end
		end
	end
	-- Now decide what can actually be run. A game with a .VCD, or an Ember folder that
	-- is not a .chd, is fine however many other copies of it are lying about.
	for i = 1, #games do
		local g = games[i]
		if g.path == nil and g.ember_dir ~= nil then g.path = g.ember_dir end
		if g.vcd ~= nil then
			g.warn = nil
		elseif g.ember_dir ~= nil then
			-- An Ember folder holding a .chd cannot run anywhere.
			if g.ember_chd == true then g.warn = "chd" end
		elseif g.disc ~= nil then
			-- A loose image. A .cue or .bin is Ember's food: the launcher moves it into
			-- Ember/games/<Game>/ on the way in (emu/ember_park.lua), so it plays. The
			-- rest genuinely has nowhere to go without a conversion on the PC.
			if g.disc_ext == ".cue" or g.disc_ext == ".bin" then g.warn = nil
			elseif g.disc_ext == ".chd" then g.warn = "chd"
			else g.warn = "loose" end
		end
	end
end

--- Every other system: files with an accepted extension in each root. ------------------
local function scan_files(sys, games, seen)
	for r = 1, #RAICES do
		local dirs = scan_roots(sys.folder, RAICES[r])
		for d = 1, #dirs do
			local dir = dirs[d]
			local list = System.listDirectory(dir)
			if list ~= nil then
				local ata = is_ata(dir)
				for i = 1, #list do
					local e = list[i]
					if e.directory == false and string.sub(e.name, 1, 1) ~= "." then
						local ext = lower_ext(e.name)
						if has_ext(sys.ext, ext) then
							local key = sys.folder .."|".. string.lower(e.name)
							if seen[key] == nil then
								local g = { file = e.name, stem = stem_of(e.name),
									title = title_for(sys.folder, e.name),
									path = dir .."/".. e.name, dir = dir, ata = ata, kind = sys.folder }
								if ext == ".chd" then g.warn = "chd" end
								seen[key] = g
								games[#games + 1] = g
							end
						end
					end
				end
			end
		end
	end
end

--- Build (or rebuild) the whole library. Logs one line per system found. ---------------
function library_build(progress)
	LIBRARY.systems, LIBRARY.by_folder, LIBRARY.titles = {}, {}, {}
	-- A rescan replaces the inventory, it does not add to it: a game deleted from the
	-- drive has to leave exfatdb.json too, or the PC tools keep preparing artwork for
	-- something that is not there any more.
	if EXFATDB ~= nil then EXFATDB = {} end
	local folders = {}
	for folder, _s in pairs(SYSTEMS) do folders[#folders + 1] = folder end
	table.sort(folders, function(a, b) return SYSTEMS[a].name < SYSTEMS[b].name end)

	for i = 1, #folders do
		local sys = SYSTEMS[folders[i]]
		for r = 1, #RAICES do read_titles(sys.folder, RAICES[r]) end
		local games, seen = {}, {}
		if sys.folder == "psx" then scan_psx(sys, games, seen) else scan_files(sys, games, seen) end
		if #games > 0 then
			-- gamelist.xml (EmulationStation format) overrides titles and brings the
			-- description and artwork paths; a system without one gets a starter file.
			if gamelist_apply(sys.folder, games) == false then
				gamelist_write_default(sys.folder, games)
			else
				-- A gamelist exists, but a game copied in since the last scrape is not
				-- in it. Add it, with its name, instead of leaving it undescribed.
				gamelist_add_missing(sys.folder, games)
			end
			-- Write down what the console really sees, folder by folder, for the PC
			-- tools: exfatdb.json is the only honest source for a disk that lives
			-- inside the PlayStation and is never plugged into a computer. It used to
			-- fill up only as you opened systems in the menu - so it described where
			-- you had been, not what you own. It is written from the scan now, which
			-- means the whole library, every boot.
			if exfatdb_dir ~= nil then
				local por_dir = {}
				for gi = 1, #games do
					local g = games[gi]
					local d = g.dir
					if d ~= nil then
						if por_dir[d] == nil then por_dir[d] = {} end
						local lista = por_dir[d]
						lista[#lista + 1] = { fichero = g.file, titulo = g.title }
					end
				end
				for d, lista in pairs(por_dir) do
					local clave = sys.folder
					local low = string.lower(d)
					if string.find(low, "/pops", 1, true) ~= nil then clave = "POPS"
					elseif string.find(low, "/dvd", 1, true) ~= nil then clave = "DVD"
					elseif string.find(low, "/cd", 1, true) ~= nil then clave = "CD" end
					pcall(exfatdb_dir, sys.folder, sys.name, d, lista, clave)
				end
			end

			table.sort(games, function(a, b) return string.lower(a.title) < string.lower(b.title) end)
			local entry = { folder = sys.folder, name = sys.name, games = games }
			LIBRARY.systems[#LIBRARY.systems + 1] = entry
			LIBRARY.by_folder[sys.folder] = entry
			if log_event ~= nil then log_event("LIB", sys.folder .."  ".. #games .." game(s)") end
			if progress ~= nil then progress(sys.name, #games) end
		end
	end
	-- Recent, Favourites and To finish are built from the library and put at the top of
	-- the column; then the real systems are ordered the way the user asked for.
	collections_load()
	collections_refresh()
	collections_sort_systems(prefs_get("sort"))

	-- And onto the disk, once, now that every system has been walked.
	if exfatdb_escribir ~= nil then pcall(exfatdb_escribir) end

	LIBRARY.built = true
	if boot_flush ~= nil then boot_flush() end
end

--- OPL keeps its artwork in ART/ at the root of a drive, named after the game's
--- serial: "SLES_123.45_COV.png". A disk filled with OPL has hundreds of them and no
--- Prism folder anywhere, and there is no reason to make anyone copy that twice.
--- These are the suffixes it uses, mapped onto the four pictures Prism shows.
local OPL_ART = {
	covers      = { "_COV" },
	screenshots = { "_SCR", "_SCR2", "_BG" },
	cartridges  = { "_LAB" },     -- the disc label, which is a PS2 game's "cartridge"
	gamelogo    = { "_LGO" },
}

--- The OPL serial at the head of a file name, or nil. ---------------------------------
--- "SLES_123.45.Xenosaga.iso" -> "SLES_123.45"
local function opl_serial(name)
	return string.match(tostring(name or ""), "^(%a%a%a%a[_%-]%d%d%d%.%d%d)")
end

--- Artwork for a game. In order: Roms/<folder>/media/<kind>/<stem>.png on every root,
--- boot medium first - so a picture on the USB stick always wins over one on the
--- internal disk - and then OPL's own ART/ folder on every drive.
--- Cached on the game (false = looked, none).
function library_art(game, kind)
	local field = "art_".. kind
	if game[field] ~= nil then
		if game[field] == false then return nil end
		return game[field]
	end
	local names = { game.stem }
	if game.ember ~= nil and game.ember ~= game.stem then names[#names + 1] = game.ember end
	for r = 1, #RAICES do
		for n = 1, #names do
			local p = RAICES[r] .."/Roms/".. game.kind .."/media/".. kind .."/".. names[n] ..".png"
			if doesFileExist(p) then
				game[field] = p
				return p
			end
		end
	end

	-- Nothing of ours. Ask OPL, if this game has a serial to ask about.
	local serial = opl_serial(game.file)
	local sufijos = OPL_ART[kind]
	if serial ~= nil and sufijos ~= nil and DRIVE_ROOTS ~= nil then
		for d = 1, #DRIVE_ROOTS do
			for s = 1, #sufijos do
				-- PNG only, and deliberately. Graphics.loadImage has hung this console
				-- on a JPEG before - not returned an error, hung - and an ART/ folder
				-- filled by OPL holds pictures of any size and format anybody happened
				-- to download. A missing cover costs nothing; a freeze costs the
				-- session.
				local p = DRIVE_ROOTS[d] .."/ART/".. serial .. sufijos[s] ..".png"
				if doesFileExist(p) then
					game[field] = p
					return p
				end
			end
		end
	end

	game[field] = false
	return nil
end

--- Short label of where a game lives, and its colour: "exFAT" yellow / "USB" cyan. ----
function library_where(game)
	if game.ata then return "exFAT", THEME.exfat end
	return "USB", THEME.usb
end
