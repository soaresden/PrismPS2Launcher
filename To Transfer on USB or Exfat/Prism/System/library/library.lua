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

local function title_for(folder, name)
	local map = LIBRARY.titles[folder]
	local stem = stem_of(name)
	if map ~= nil and map[string.lower(stem)] ~= nil then return map[string.lower(stem)] end
	return stem
end

local function is_ata(path)
	if ES_RAIZ_ATA ~= nil then
		local ok, r = pcall(ES_RAIZ_ATA, path)
		if ok then return r == true end
	end
	return false
end

--- PlayStation 1: POPS/ on each drive (.VCD) and Ember/games (one folder per game). -----
local function scan_psx(sys, games, seen)
	for r = 1, #RAICES do
		local dirs = scan_roots("psx", RAICES[r])
		for d = 1, #dirs do
			local dir = dirs[d]
			local list = System.listDirectory(dir)
			if list ~= nil then
				local is_ember = (string.find(string.lower(dir), "/ember/games", 1, true) ~= nil)
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
							entry.vcd = dir .."/".. name
							entry.file = name
							entry.stem = stem_of(name)
							entry.dir = dir
							entry.path = entry.vcd
							entry.ata = is_ata(dir)
						end
					end
				end
			end
		end
	end
	-- A game that only exists as an Ember folder holding a .chd cannot run anywhere.
	for i = 1, #games do
		local g = games[i]
		if g.vcd == nil and g.ember_chd == true then g.warn = "chd" end
		if g.path == nil and g.ember_dir ~= nil then g.path = g.ember_dir end
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
			end
			table.sort(games, function(a, b) return string.lower(a.title) < string.lower(b.title) end)
			local entry = { folder = sys.folder, name = sys.name, games = games }
			LIBRARY.systems[#LIBRARY.systems + 1] = entry
			LIBRARY.by_folder[sys.folder] = entry
			if log_event ~= nil then log_event("LIB", sys.folder .."  ".. #games .." game(s)") end
			if progress ~= nil then progress(sys.name, #games) end
		end
	end
	LIBRARY.built = true
	if boot_flush ~= nil then boot_flush() end
end

--- Artwork for a game: Roms/<folder>/media/<kind>/<stem>.png on any root. --------------
--- kind: "covers" or "screenshots". Cached on the game (false = looked, none).
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
	game[field] = false
	return nil
end

--- Short label of where a game lives, and its colour: "exFAT" yellow / "USB" cyan. ----
function library_where(game)
	if game.ata then return "exFAT", THEME.exfat end
	return "USB", THEME.usb
end
