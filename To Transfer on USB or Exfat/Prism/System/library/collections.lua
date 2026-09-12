-- Prism PS2 Launcher - library/collections.lua
-- The three lists that are not a console: Recent, Favourites, and To finish.
-- They sit at the top of the systems column and behave like any other system, so the
-- gamelist view needs to know nothing about them.
--
-- Stored in System/Config/collections.cfg, one line each, in order:
--     recent=<system>|<file>       most recently played first, capped at RECENT_MAX
--     fav=<system>|<file>
--     todo=<system>|<file>
--
-- The key is the system folder and the file name, never a path: a game keeps its place
-- in your lists when it moves from the USB stick to the internal drive.
--
-- "To finish" is the one that does not exist in EmulationStation, and it is the reason
-- this file was written: a shelf for the games you mean to see the end of. Games pile
-- up faster than anyone finishes them, and a library sorted by console is no help in
-- answering "what was I in the middle of".

COLLECTIONS = { recent = {}, fav = {}, todo = {}, loaded = false }
RECENT_MAX = 30

function collections_key(g)
	if g == nil then return nil end
	return tostring(g.kind) .."|".. tostring(g.file)
end

local function cfg_path()
	return System.currentDirectory() .."/System/Config/collections.cfg"
end

function collections_load()
	COLLECTIONS.recent, COLLECTIONS.fav, COLLECTIONS.todo = {}, {}, {}
	COLLECTIONS.loaded = true
	local path = cfg_path()
	if doesFileExist(path) == false then return end
	pcall(function()
		local fd = System.openFile(path, FREAD)
		local size = System.sizeFile(fd)
		System.seekFile(fd, 0, SET)
		local data = System.readFile(fd, size)
		System.closeFile(fd)
		if data == nil then return end
		for line in string.gmatch(data, "[^\r\n]+") do
			local what, key = string.match(line, "^(%a+)=(.+)$")
			if what == "recent" then COLLECTIONS.recent[#COLLECTIONS.recent + 1] = key
			elseif what == "fav" then COLLECTIONS.fav[key] = true
			elseif what == "todo" then COLLECTIONS.todo[key] = true end
		end
	end)
	if log_event ~= nil then
		local nf, nt = 0, 0
		for _k, _v in pairs(COLLECTIONS.fav) do nf = nf + 1 end
		for _k, _v in pairs(COLLECTIONS.todo) do nt = nt + 1 end
		log_event("LIB", "collections: ".. #COLLECTIONS.recent .." recent, "
			.. nf .." favourite(s), ".. nt .." to finish")
	end
end

function collections_save()
	local dir = System.currentDirectory() .."/System/Config"
	if System.listDirectory(dir) == nil then pcall(System.createDirectory, dir) end
	local t = { "# Prism collections. Recent is in order, newest first.\n" }
	for i = 1, #COLLECTIONS.recent do t[#t + 1] = "recent=".. COLLECTIONS.recent[i] .."\n" end
	local keys = {}
	for k, _v in pairs(COLLECTIONS.fav) do keys[#keys + 1] = k end
	table.sort(keys)
	for i = 1, #keys do t[#t + 1] = "fav=".. keys[i] .."\n" end
	keys = {}
	for k, _v in pairs(COLLECTIONS.todo) do keys[#keys + 1] = k end
	table.sort(keys)
	for i = 1, #keys do t[#t + 1] = "todo=".. keys[i] .."\n" end
	local text = table.concat(t)
	pcall(function()
		local fd = System.openFile(cfg_path(), FCREATE)
		System.writeFile(fd, text, string.len(text))
		System.closeFile(fd)
	end)
end

--- Favourite ----------------------------------------------------------------------------
function collections_is_fav(g)
	local k = collections_key(g)
	return k ~= nil and COLLECTIONS.fav[k] == true
end

function collections_toggle_fav(g)
	local k = collections_key(g)
	if k == nil then return false end
	if COLLECTIONS.fav[k] == true then COLLECTIONS.fav[k] = nil else COLLECTIONS.fav[k] = true end
	collections_save()
	collections_refresh()
	if log_event ~= nil then log_event("LIB", "favourite ".. tostring(COLLECTIONS.fav[k] == true) .."  ".. k) end
	return COLLECTIONS.fav[k] == true
end

--- To finish ----------------------------------------------------------------------------
function collections_is_todo(g)
	local k = collections_key(g)
	return k ~= nil and COLLECTIONS.todo[k] == true
end

function collections_toggle_todo(g)
	local k = collections_key(g)
	if k == nil then return false end
	if COLLECTIONS.todo[k] == true then COLLECTIONS.todo[k] = nil else COLLECTIONS.todo[k] = true end
	collections_save()
	collections_refresh()
	if log_event ~= nil then log_event("LIB", "to finish ".. tostring(COLLECTIONS.todo[k] == true) .."  ".. k) end
	return COLLECTIONS.todo[k] == true
end

--- Recent -------------------------------------------------------------------------------
--- Called the moment a game is launched, which is also the last moment the launcher
--- runs: everything after this is the emulator's, so the list is written NOW.
function collections_played(g)
	local k = collections_key(g)
	if k == nil then return end
	local out = { k }
	for i = 1, #COLLECTIONS.recent do
		if COLLECTIONS.recent[i] ~= k and #out < RECENT_MAX then
			out[#out + 1] = COLLECTIONS.recent[i]
		end
	end
	COLLECTIONS.recent = out
	collections_save()
end

--- Building the three virtual systems ----------------------------------------------------
--- Every game of the library, by key, so a collection can be turned back into games.
local function index_games()
	local by_key = {}
	for i = 1, #LIBRARY.systems do
		local s = LIBRARY.systems[i]
		if s.virtual ~= true then
			for j = 1, #s.games do by_key[collections_key(s.games[j])] = s.games[j] end
		end
	end
	return by_key
end

--- Rebuilds the virtual systems in place and puts them at the top of the column.
--- Called after a build and after any toggle, so the lists are never stale.
function collections_refresh()
	if COLLECTIONS.loaded ~= true then collections_load() end

	-- Drop the virtual entries of the previous pass.
	local real = {}
	for i = 1, #LIBRARY.systems do
		if LIBRARY.systems[i].virtual ~= true then real[#real + 1] = LIBRARY.systems[i] end
	end

	local by_key = {}
	for i = 1, #real do
		for j = 1, #real[i].games do by_key[collections_key(real[i].games[j])] = real[i].games[j] end
	end

	-- Recent keeps the order of the file; the other two are sorted by title.
	local recent = {}
	for i = 1, #COLLECTIONS.recent do
		local g = by_key[COLLECTIONS.recent[i]]
		if g ~= nil then recent[#recent + 1] = g end
	end
	local function gather(set)
		local out = {}
		for k, _v in pairs(set) do
			local g = by_key[k]
			if g ~= nil then out[#out + 1] = g end
		end
		table.sort(out, function(a, b) return string.lower(a.title) < string.lower(b.title) end)
		return out
	end

	local virtual = {}
	local function add(folder, name, games, note)
		-- An empty collection still appears: an empty "To finish" is an invitation, and
		-- a list that comes and goes moves everything under it.
		virtual[#virtual + 1] = { folder = folder, name = name, games = games,
			virtual = true, note = note }
	end
	add("@recent", "Recent",    recent,            "the last games you played, newest first")
	add("@fav",    "Favourites", gather(COLLECTIONS.fav),  "triangle on a game, then Favourite")
	add("@todo",   "To finish",  gather(COLLECTIONS.todo), "games you mean to see the end of")

	local all = {}
	for i = 1, #virtual do all[#all + 1] = virtual[i] end
	for i = 1, #real do all[#all + 1] = real[i] end
	LIBRARY.systems = all
	LIBRARY.by_folder["@recent"] = virtual[1]
	LIBRARY.by_folder["@fav"] = virtual[2]
	LIBRARY.by_folder["@todo"] = virtual[3]

	-- LIBRARY.systems is a NEW table, so the column is now pointing at the old one.
	-- Re-seat it on the same system, by folder: marking a favourite must not make the
	-- selection jump somewhere else. Skipped during the boot, when no view exists yet.
	if SYSTEMS_VIEW ~= nil and SYSTEMS_VIEW.list ~= nil then
		local keep = list_current(SYSTEMS_VIEW.list)
		list_set(SYSTEMS_VIEW.list, LIBRARY.systems)
		if keep ~= nil then
			for i = 1, #LIBRARY.systems do
				if LIBRARY.systems[i].folder == keep.folder then SYSTEMS_VIEW.list.sel = i end
			end
			list_scroll(SYSTEMS_VIEW.list)
		end
	end
end

--- Sorting the real systems. The three collections never move. -------------------------
--- mode: "folder" (alphabetical, the folder you drop games into)
---       "maker"  (by manufacturer, then by year within it)
---       "year"   (oldest machine first)
SORT_MODES = { "folder", "maker", "year" }
SORT_LABELS = { "Folder name", "Manufacturer", "Console year" }

function collections_sort_systems(mode)
	local real, virtual = {}, {}
	for i = 1, #LIBRARY.systems do
		if LIBRARY.systems[i].virtual == true then virtual[#virtual + 1] = LIBRARY.systems[i]
		else real[#real + 1] = LIBRARY.systems[i] end
	end

	-- The two consoles this launcher is FOR come first, whatever the sort. Prism runs
	-- on a PlayStation 2 and its own library is the one you reach for; burying it
	-- between Neo Geo Pocket and Sega SG-1000 because the alphabet says so would be
	-- letting a rule win over the reason the rule exists.
	local FIRST = { ps2 = 1, psx = 2 }

	local function cmp(a, b)
		local fa, fb = FIRST[a.folder], FIRST[b.folder]
		if fa ~= nil or fb ~= nil then
			if fa == nil then return false end
			if fb == nil then return true end
			return fa < fb
		end
		if mode == "maker" then
			local ma, mb = system_maker(a), system_maker(b)
			if ma ~= mb then return ma < mb end
			local ya, yb = system_year(a) or 9999, system_year(b) or 9999
			if ya ~= yb then return ya < yb end
		elseif mode == "year" then
			local ya, yb = system_year(a) or 9999, system_year(b) or 9999
			if ya ~= yb then return ya < yb end
		end
		return a.folder < b.folder
	end
	table.sort(real, cmp)

	local all = {}
	for i = 1, #virtual do all[#all + 1] = virtual[i] end
	for i = 1, #real do all[#all + 1] = real[i] end
	LIBRARY.systems = all
end
