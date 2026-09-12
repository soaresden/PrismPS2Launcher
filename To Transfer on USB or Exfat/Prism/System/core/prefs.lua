-- Prism PS2 Launcher - core/prefs.lua
-- Settings, two small text files in System/Config/:
--   prism.cfg   key=value          interface and global choices
--   games.cfg   <system>|<file>=<backend id>   which emulator/core runs one game
-- Read once at boot, written whenever something changes. Missing files mean defaults.

PREFS = {
	values = {},
	games = {},
	defaults = {
		sound = "on",           -- menu sounds
		music = "off",          -- background music
		video = "auto",         -- auto | ntsc | pal  (applied at next boot)
		show_hidden = "off",
		last_system = "",
		sort = "folder",        -- folder | maker | year, see library/collections.lua
		-- Which picture goes in each of the game column's three slots.
		art_a = "gamelogo",     -- beside the title: the game's own logo, which is what
		                        -- that slot is shaped for - a wide picture next to a name
		art_b = "screenshots",  -- bottom left
		art_c = "covers",       -- bottom right
		select_color = "blue",  -- the selection bar, see SELECTION_COLORS in ui/theme
		scroll_speed = "fast",  -- slow | normal | fast, for long lines of text
		show_where = "on",      -- "usb" / "exfat" in front of a game's name
	},
}

local function cfg_dir()
	return System.currentDirectory() .."/System/Config"
end

local function read_lines(path)
	local out = {}
	if doesFileExist(path) == false then return out end
	pcall(function()
		local fd = System.openFile(path, FREAD)
		local size = System.sizeFile(fd)
		System.seekFile(fd, 0, SET)
		local data = System.readFile(fd, size)
		System.closeFile(fd)
		if data == nil then return end
		for line in string.gmatch(data, "[^\r\n]+") do out[#out + 1] = line end
	end)
	return out
end

local function write_text(path, text)
	pcall(function()
		if System.listDirectory(cfg_dir()) == nil then pcall(System.createDirectory, cfg_dir()) end
		local fd = System.openFile(path, FCREATE)
		System.writeFile(fd, text, string.len(text))
		System.closeFile(fd)
	end)
end

function prefs_load()
	PREFS.values, PREFS.games = {}, {}
	local lines = read_lines(cfg_dir() .."/prism.cfg")
	for i = 1, #lines do
		local k, v = string.match(lines[i], "^%s*([%w_]+)%s*=%s*(.-)%s*$")
		if k ~= nil then PREFS.values[k] = v end
	end
	lines = read_lines(cfg_dir() .."/games.cfg")
	for i = 1, #lines do
		local k, v = string.match(lines[i], "^(.-)=([^=]*)$")
		if k ~= nil and k ~= "" and v ~= "" then PREFS.games[k] = v end
	end
	if log_event ~= nil then
		local n = 0
		for _k, _v in pairs(PREFS.games) do n = n + 1 end
		log_event("PREFS", "prism.cfg read, ".. n .." per-game choice(s)")
	end
end

function prefs_save()
	local keys = {}
	for k, _v in pairs(PREFS.values) do keys[#keys + 1] = k end
	table.sort(keys)
	local t = "# Prism settings. One key=value per line.\n"
	for i = 1, #keys do t = t .. keys[i] .."=".. PREFS.values[keys[i]] .."\n" end
	write_text(cfg_dir() .."/prism.cfg", t)

	local gk = {}
	for k, _v in pairs(PREFS.games) do gk[#gk + 1] = k end
	table.sort(gk)
	local g = "# Prism per-game emulator: <system>|<file>=<backend id>\n"
	for i = 1, #gk do g = g .. gk[i] .."=".. PREFS.games[gk[i]] .."\n" end
	write_text(cfg_dir() .."/games.cfg", g)
end

function prefs_get(key)
	local v = PREFS.values[key]
	if v == nil then v = PREFS.defaults[key] end
	return v
end

function prefs_set(key, value)
	PREFS.values[key] = tostring(value)
	if log_event ~= nil then log_event("SET", key .." = ".. tostring(value)) end
	prefs_save()
end

function prefs_is(key, value)
	return prefs_get(key) == value
end

--- Which backend runs a game: the per-game choice, else the system default. -----------
function prefs_backend(game)
	local k = game.kind .."|".. game.file
	if PREFS.games[k] ~= nil then return PREFS.games[k] end
	local sys = SYSTEMS[game.kind]
	if game.kind == "psx" then
		if game.vcd ~= nil then return "pops" end
		return "ember"
	end
	-- Cheats are OPL's business: Neutrino has no cheat engine at all. So a PS2 game
	-- whose cheats are switched on goes to OPL by itself, and goes back to Neutrino the
	-- moment they are all switched off. Widescreen was asked for as something that just
	-- works, and this is what that costs.
	--
	-- Getting OPL to start at all took two hardware tests and a detour: it must have
	-- the IOP reset before it runs, and Enceladus cannot read a USB stick after doing
	-- that. It is launched from a copy on the memory card instead - see opl_on_card in
	-- launch/backends.lua.
	if game.kind == "ps2" and cheats_want_opl ~= nil and cheats_want_opl(game) then
		return "opl"
	end
	if sys ~= nil then
		local b = backends_for(game.kind, game.file)
		if #b > 0 then return b[1].id end
		return sys.default
	end
	return nil
end

function prefs_set_backend(game, id)
	local k = game.kind .."|".. game.file
	PREFS.games[k] = id
	if log_event ~= nil then log_event("SET", k .." -> ".. tostring(id)) end
	prefs_save()
end

--- Other per-game options, same file: <system>|<file>|<option>=<value>. --------------
--- Used for the PS2 memory card choice ("card" = auto | real).
function prefs_game_option(game, name)
	return PREFS.games[game.kind .."|".. game.file .."|".. name]
end

function prefs_set_game_option(game, name, value)
	local k = game.kind .."|".. game.file .."|".. name
	PREFS.games[k] = tostring(value)
	if log_event ~= nil then log_event("SET", k .." = ".. tostring(value)) end
	prefs_save()
end
