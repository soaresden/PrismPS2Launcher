-- Prism PS2 Launcher - emu/cheats.lua
-- PlayStation 2 cheat files: the widescreen patches, and the switches for them.
--
-- A .cht is named after the game's serial and sits in CHT/ at the root of a drive,
-- exactly where OPL looks for it. Taking one apart:
--
--     "Final Fantasy X /ID SCES_504.91"    the title line
--     //ELF CRC A39517AE                   a note
--     Mastercode                           a NAMED cheat - required, always on
--     902faa58 0c0bea3e                      its code
--     //[Widescreen 16:9]                  a banner
--     // 16:9                              a LABEL: the group below is called this
--     201a5974 3c013f19                      two codes, and they are ON
--     201a5978 3421999a
--     // Render-Fix                        another label
--     2011973c 3c014440
--     20176144 3c01442b
--     // Progressive Scan
--     //202d98b4 3c050000                  a code behind "//" is OFF
--
-- So the file already carries its own state, and the authors of these collections use
-- it: shipping a group commented out is how they mark it optional. Switching a cheat on
-- means removing the "//" in front of its codes, switching it off means putting them
-- back. Nothing else in the file is touched - not a byte, not a blank line - so a file
-- edited here stays a file its author would recognise.
--
-- That also settles where the per-game preference is kept: in the file. It is already
-- one file per game, it already survives everything, and a second copy of the same
-- truth in games.cfg could only ever disagree with it.
--
-- WHY OPL AND NOT NEUTRINO
-- Neutrino has no cheat engine: its options are -bsd, -bsdfs, -dvd, -elf, -gc, -gsm,
-- -cwd, -cfg and nothing else. OPL has one and reads these files by serial. So a game
-- with a cheat switched on is launched with OPL instead, on its own; switch them all
-- off and it goes back to Neutrino, because there is then nothing to gain.

--- The serial in a file name: "SCES_504.91.Final Fantasy X.iso" -> "SCES_504.91". -----
function cheats_serial(name)
	return string.match(tostring(name or ""), "^(%a%a%a%a[_%-]%d%d%d%.%d%d)")
end

--- A row of two hex words, with or without a "//" in front. ---------------------------
local function code_of(line)
	local body = string.match(line, "^%s*//%s*(.*)$")
	local commented = (body ~= nil)
	if body == nil then body = string.match(line, "^%s*(.*)$") end
	if string.match(body, "^%x%x%x%x%x%x%x%x%s+%x%x%x%x%x%x%x%x%s*$") ~= nil then
		return true, commented
	end
	return false, commented
end

--- The .cht for a game, on any drive, or nil. -----------------------------------------
function cheats_file(game)
	if game == nil or game.kind ~= "ps2" then return nil end
	local serial = cheats_serial(game.file)
	if serial == nil or DRIVE_ROOTS == nil then return nil end
	for d = 1, #DRIVE_ROOTS do
		for _i, name in ipairs({serial ..".cht", string.upper(serial) ..".CHT"}) do
			local p = DRIVE_ROOTS[d] .."/CHT/".. name
			if doesFileExist(p) then return p end
		end
	end
	return nil
end

--- Read the file and work out its groups. Cached on the game. -------------------------
--- A group is { label, on, mandatory, lines = { index, ... } } where the indices point
--- into CHEATS_LINES, so switching one only has to touch those lines.
function cheats_list(game)
	if game == nil then return {} end
	if game.cheats ~= nil then return game.cheats end
	game.cheats, game.cheats_lines = {}, {}

	local path = cheats_file(game)
	if path == nil then return game.cheats end
	game.cheats_path = path

	local data = nil
	pcall(function()
		local fd = System.openFile(path, FREAD)
		local size = System.sizeFile(fd)
		System.seekFile(fd, 0, SET)
		data = System.readFile(fd, size)
		System.closeFile(fd)
	end)
	if data == nil then return game.cheats end

	local lines = {}
	for raw in string.gmatch(data, "([^\n]*)\n?") do
		lines[#lines + 1] = string.gsub(raw, "\r$", "")
	end
	-- gmatch with an optional newline yields one extra empty piece at the end.
	if #lines > 0 and lines[#lines] == "" then table.remove(lines) end
	game.cheats_lines = lines

	local groups, current, title_seen = {}, nil, false
	for i = 1, #lines do
		local line = lines[i]
		local is_code, commented = code_of(line)
		local comment_body = string.match(line, "^%s*//%s*(.-)%s*$")
		local bare = string.match(line, "^%s*(.-)%s*$")

		if is_code then
			if current ~= nil then
				current.lines[#current.lines + 1] = i
				if commented == false then current.on = true end
			end
		elseif comment_body ~= nil then
			-- A label, unless it is empty or a decorative banner in brackets.
			local label = string.match(comment_body, "^%[(.+)%]$") or comment_body
			if label ~= "" then
				current = { label = label, on = false, mandatory = false, lines = {} }
				groups[#groups + 1] = current
			end
		elseif bare ~= "" then
			if title_seen == false and string.sub(bare, 1, 1) == "\"" then
				title_seen = true          -- the title line names nothing
			else
				title_seen = true
				-- A name with no "//" is a real Cheat Device entry. The Mastercode is
				-- one of these, and a widescreen file is useless without it, so these
				-- are shown but never offered as a switch.
				current = { label = bare, on = true, mandatory = true, lines = {} }
				groups[#groups + 1] = current
			end
		end
	end

	-- A label with no codes under it was a heading, not a group.
	local keep = {}
	for i = 1, #groups do
		if #groups[i].lines > 0 then keep[#keep + 1] = groups[i] end
	end
	game.cheats = keep
	return keep
end

function cheats_is_on(group)
	return group ~= nil and group.on == true
end

--- Switch one group and write the file straight away. ---------------------------------
--- Only the code lines of that group change, by adding or removing "//". The original
--- file is kept once, beside it, before the first edit.
function cheats_set(game, index, on)
	local groups = cheats_list(game)
	local g = groups[index]
	if g == nil or g.mandatory then return false end
	local lines = game.cheats_lines
	if lines == nil or game.cheats_path == nil then return false end

	local backup = game.cheats_path ..".prism-original"
	if doesFileExist(backup) == false then
		pcall(System.copyFile, game.cheats_path, backup)
	end

	for i = 1, #g.lines do
		local n = g.lines[i]
		local body = string.match(lines[n], "^%s*//%s*(.*)$")
		if on then
			if body ~= nil then lines[n] = body end
		else
			if body == nil then lines[n] = "//".. string.match(lines[n], "^%s*(.*)$") end
		end
	end
	g.on = on

	local text = table.concat(lines, "\n") .."\n"
	pcall(function()
		local fd = System.openFile(game.cheats_path, FCREATE)
		System.writeFile(fd, text, string.len(text))
		System.closeFile(fd)
	end)
	if log_event ~= nil then
		log_event("CHEAT", g.label .." -> ".. tostring(on) .."  in ".. game.cheats_path)
	end
	return true
end

--- How many optional groups are on, and how many there are. ---------------------------
--- The mandatory ones are not counted: they are not a choice, so reporting them as one
--- would only make the number lie.
function cheats_count(game)
	local list = cheats_list(game)
	local on, total = 0, 0
	for i = 1, #list do
		if list[i].mandatory == false then
			total = total + 1
			if list[i].on then on = on + 1 end
		end
	end
	return on, total
end

--- Should this game be launched with OPL? ---------------------------------------------
function cheats_want_opl(game)
	if game == nil or game.kind ~= "ps2" then return false end
	local on, _total = cheats_count(game)
	return on > 0
end

--- Forget what was read, so the next look re-reads the file from the drive. -----------
function cheats_forget(game)
	if game ~= nil then game.cheats, game.cheats_lines = nil, nil end
end

--- Turn OPL's cheat engine on for this game, in OPL's own configuration. ---------------
--- PS2RD ships OFF, and a .cht on the drive does nothing on its own. It is not a global
--- switch though: OPL keeps per-game settings in CFG/<ID>.cfg, and from its source
--- (guigame.c, guiGameLoadCheatsConfig / guiGameSaveConfig):
---
---     $CheatsSource = 1   read the two keys below from THIS file, not the global ones
---     $EnableCheat  = 1   run the cheat engine for this game
---     $CheatMode    = 0   auto-select: every cheat in the .cht. Mode 1, "select game
---                         cheats", is documented as not implemented - which is why
---                         choosing cheats has to be done by commenting their codes
---                         out, and why Prism does it that way.
---
--- The file is merged, never replaced: it can also hold $VMC, $Compatibility, a start-up
--- path. Only these keys are touched, and $EnableCheat is removed rather than set to 0,
--- which is what OPL itself does.
local CHEAT_KEYS = { ["$CheatsSource"] = true, ["$EnableCheat"] = true, ["$CheatMode"] = true }

local function write_opl_cfg(path, on)
	local lines = {}
	if doesFileExist(path) then
		pcall(function()
			local fd = System.openFile(path, FREAD)
			local size = System.sizeFile(fd)
			System.seekFile(fd, 0, SET)
			local data = System.readFile(fd, size)
			System.closeFile(fd)
			for raw in string.gmatch(tostring(data or ""), "([^\n]*)\n?") do
				lines[#lines + 1] = string.gsub(raw, "\r$", "")
			end
			if #lines > 0 and lines[#lines] == "" then table.remove(lines) end
		end)
	end
	-- Drop the keys we own, keep everything else exactly as it was.
	local kept = {}
	for i = 1, #lines do
		local key = string.match(lines[i], "^%s*([%$#][%w_]+)%s*=")
		if key == nil or CHEAT_KEYS[key] ~= true then kept[#kept + 1] = lines[i] end
	end
	if on then
		kept[#kept + 1] = "$CheatsSource=1"
		kept[#kept + 1] = "$EnableCheat=1"
		kept[#kept + 1] = "$CheatMode=0"
	end
	local text = table.concat(kept, "\n")
	if text ~= "" then text = text .."\n" end
	pcall(function()
		local fd = System.openFile(path, FCREATE)
		System.writeFile(fd, text, string.len(text))
		System.closeFile(fd)
	end)
	return doesFileExist(path)
end

--- Written to the CFG/ folder of every drive that has one, plus the drive the game is
--- on. OPL picks its configuration folder itself, from the device it is reading games
--- from, and Prism cannot know which it will settle on - so it tells all of them the
--- same thing rather than guess and be silently wrong.
function cheats_opl_config(game)
	if game == nil or game.kind ~= "ps2" then return 0 end
	local serial = cheats_serial(game.file)
	if serial == nil then return 0 end
	local on = cheats_want_opl(game)

	local drives, seen = {}, {}
	local function add(dev)
		if dev ~= nil and seen[dev] == nil then seen[dev] = true; drives[#drives + 1] = dev end
	end
	add(string.match(tostring(game.dir), "^[^:]+:"))
	for d = 1, #(DRIVE_ROOTS or {}) do add(DRIVE_ROOTS[d]) end

	local written = 0
	for i = 1, #drives do
		local dir = drives[i] .."/CFG"
		if System.listDirectory(dir) == nil and i == 1 then
			pcall(System.createDirectory, dir)     -- only on the game's own drive
		end
		if System.listDirectory(dir) ~= nil then
			if write_opl_cfg(dir .."/".. serial ..".cfg", on) then written = written + 1 end
		end
	end
	if log_event ~= nil then
		log_event("CHEAT", "OPL config for ".. serial ..": EnableCheat="
			.. tostring(on) .."  written to ".. written .." CFG folder(s)")
	end
	return written
end
